import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GamificationService extends ChangeNotifier {
  final String _childId = 'default';
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

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt('gam_xp') ?? 0;
    _selectedBuddyIndex = prefs.getInt('gam_buddy') ?? 0;

    final starsJson = prefs.getString('gam_stars');
    if (starsJson != null) {
      final decoded = jsonDecode(starsJson) as Map<String, dynamic>;
      _starsPerCharacter
          .addAll(decoded.map((k, v) => MapEntry(k, (v as num).toInt())));
    }

    final badgesJson = prefs.getString('gam_badges');
    if (badgesJson != null) {
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

  /// Called after Groq evaluates a practice attempt.
  /// [score] is 0.0–1.0 from the vision model.
  void processPracticeResult(String character, double score) {
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
    _persist();
    notifyListeners();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

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
    await prefs.setInt('gam_xp', _xp);
    await prefs.setInt('gam_buddy', _selectedBuddyIndex);
    await prefs.setString('gam_stars', jsonEncode(_starsPerCharacter));
    await prefs.setString('gam_badges', jsonEncode(_unlockedBadges));
  }
}

class _BadgeDef {
  final String title;
  final String description;
  const _BadgeDef(this.title, this.description);
}
