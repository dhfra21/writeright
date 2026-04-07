import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GamificationService extends ChangeNotifier {
  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  String _childId = 'default';
  String? _accessToken;
  int _xp = 0;
  int _level = 1;
  int _selectedBuddyIndex = 0;
  final Map<String, int> _starsPerCharacter = {};
  final List<String> _unlockedBadges = [];
  bool _justLeveledUp = false;
  String? _justUnlockedBadge;

  static const List<int> _levelThresholds = [
    0, 100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200,
  ];

  static const Map<String, _BadgeDef> _badgeDefs = {
    'first_letter': _BadgeDef('First Letter!', 'Practiced your first letter'),
    'five_stars': _BadgeDef('Star Collector', 'Earned 5 stars total'),
    'ten_stars': _BadgeDef('Super Star', 'Earned 10 stars total'),
    'perfect_score': _BadgeDef('Perfect!', 'Got a perfect score'),
    'five_letters': _BadgeDef('Explorer', 'Practiced 5 different letters'),
    'all_letters': _BadgeDef('Alphabet Master', 'Practiced all 26 letters'),
    'level_3': _BadgeDef('Rising Writer', 'Reached level 3'),
    'level_5': _BadgeDef('Writing Pro', 'Reached level 5'),
  };

  // ── Getters ────────────────────────────────────────────────────────────────

  int get level => _level;
  int get xp => _xp;
  int get selectedBuddyIndex => _selectedBuddyIndex;
  Map<String, int> get starsPerCharacter => Map.unmodifiable(_starsPerCharacter);
  List<String> get unlockedBadges => List.unmodifiable(_unlockedBadges);
  bool get justLeveledUp => _justLeveledUp;
  String? get justUnlockedBadge => _justUnlockedBadge;

  int get totalStars =>
      _starsPerCharacter.values.fold(0, (sum, s) => sum + s);

  int get xpForNextLevel {
    if (_level >= _levelThresholds.length) {
      return _levelThresholds.last + 1000;
    }
    return _levelThresholds[_level];
  }

  double get levelProgress {
    if (_level >= _levelThresholds.length) return 1.0;
    final currentThreshold = _levelThresholds[_level - 1];
    final nextThreshold = _levelThresholds[_level];
    if (nextThreshold <= currentThreshold) return 1.0;
    return ((_xp - currentThreshold) / (nextThreshold - currentThreshold))
        .clamp(0.0, 1.0);
  }

  // ── Public methods ─────────────────────────────────────────────────────────

  /// Set the current child ID and reload their progress
  Future<void> setChildId(String childId) async {
    if (_childId == childId) return; // Already loaded

    _childId = childId;

    // Clear current state
    _xp = 0;
    _level = 1;
    _selectedBuddyIndex = 0;
    _starsPerCharacter.clear();
    _unlockedBadges.clear();
    _justLeveledUp = false;
    _justUnlockedBadge = null;

    // Load progress for this child
    await loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = 'child_${_childId}_';

    _xp = prefs.getInt('${prefix}gam_xp') ?? 0;
    _selectedBuddyIndex = prefs.getInt('${prefix}gam_buddy') ?? 0;

    final starsJson = prefs.getString('${prefix}gam_stars');
    if (starsJson != null) {
      final decoded = jsonDecode(starsJson) as Map<String, dynamic>;
      _starsPerCharacter.clear();
      _starsPerCharacter
          .addAll(decoded.map((k, v) => MapEntry(k, (v as num).toInt())));
    }

    final badgesJson = prefs.getString('${prefix}gam_badges');
    if (badgesJson != null) {
      _unlockedBadges.clear();
      _unlockedBadges.addAll((jsonDecode(badgesJson) as List).cast<String>());
    }

    _computeLevel();
    notifyListeners();
  }

  void selectBuddy(int index) {
    _selectedBuddyIndex = index;
    _persist();
    notifyListeners();
  }

  /// Set the access token for backend API calls
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  /// Sync local progress to backend
  Future<void> syncToBackend() async {
    if (_accessToken == null || _childId == 'default') {
      debugPrint('[GamificationService] Skipping sync: no token or default child');
      return;
    }

    try {
      debugPrint('[GamificationService] Syncing progress to backend for child $_childId');
      final response = await http.put(
        Uri.parse('$_apiBase/progress/$_childId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'total_xp': _xp,
          'current_level': _level,
          'total_stars': totalStars,
          'streak_days': 0,
          'badges': _unlockedBadges,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        debugPrint('[GamificationService] Sync successful');
      } else {
        debugPrint('[GamificationService] Sync failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('[GamificationService] Sync error: $e');
    }
  }

  /// Called after Groq evaluates a practice attempt.
  /// [score] is 0.0–1.0 from the vision model.
  Future<void> processPracticeResult(String character, double score) async {
    final stars = _starsForScore(score);
    final prevStars = _starsPerCharacter[character] ?? 0;
    if (stars > prevStars) {
      _starsPerCharacter[character] = stars;
    }

    final xpGain = switch (stars) {
      3 => 30,
      2 => 20,
      1 => 10,
      _ => 5,
    };
    _xp += xpGain;

    _justLeveledUp = false;
    final oldLevel = _level;
    _computeLevel();
    if (_level > oldLevel) _justLeveledUp = true;

    _justUnlockedBadge = null;
    _checkBadges();
    await _persist();

    // Record session in backend (triggers DB auto-update of character_mastery + game_progress)
    await _insertPracticeSession(character, score, xpGain, stars);

    // Sync local totals to backend as well
    await syncToBackend();

    notifyListeners();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _insertPracticeSession(
      String character, double score, int xpEarned, int starsEarned) async {
    if (_accessToken == null || _childId == 'default') return;
    try {
      final characterType = RegExp(r'[0-9]').hasMatch(character) ? 'number' : 'letter';
      await http.post(
        Uri.parse('$_apiBase/progress/$_childId/sessions'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'character_type': characterType,
          'character_value': character,
          'score': (score * 100).roundToDouble(), // convert 0-1 to 0-100
          'xp_earned': xpEarned,
          'stars_earned': starsEarned,
        }),
      ).timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[GamificationService] insertPracticeSession error: $e');
    }
  }

  int _starsForScore(double score) {
    if (score >= 0.8) return 3;
    if (score >= 0.5) return 2;
    if (score > 0.0) return 1;
    return 0;
  }

  void _computeLevel() {
    _level = 1;
    for (int i = 1; i < _levelThresholds.length; i++) {
      if (_xp >= _levelThresholds[i]) {
        _level = i + 1;
      } else {
        break;
      }
    }
    _level = _level.clamp(1, _levelThresholds.length);
  }

  void _checkBadges() {
    void unlock(String key) {
      if (!_unlockedBadges.contains(key)) {
        _unlockedBadges.add(key);
        _justUnlockedBadge = key;
      }
    }

    final practiced = _starsPerCharacter.keys.length;
    final stars = totalStars;

    if (practiced >= 1) unlock('first_letter');
    if (stars >= 5) unlock('five_stars');
    if (stars >= 10) unlock('ten_stars');
    if (_starsPerCharacter.values.any((s) => s == 3)) unlock('perfect_score');
    if (practiced >= 5) unlock('five_letters');
    if (practiced >= 26) unlock('all_letters');
    if (_level >= 3) unlock('level_3');
    if (_level >= 5) unlock('level_5');
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = 'child_${_childId}_';

    await prefs.setInt('${prefix}gam_xp', _xp);
    await prefs.setInt('${prefix}gam_buddy', _selectedBuddyIndex);
    await prefs.setString('${prefix}gam_stars', jsonEncode(_starsPerCharacter));
    await prefs.setString('${prefix}gam_badges', jsonEncode(_unlockedBadges));
  }
}

class _BadgeDef {
  final String title;
  final String description;
  const _BadgeDef(this.title, this.description);
}
