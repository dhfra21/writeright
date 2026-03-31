import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/child_profile.dart';
import '../../services/auth/auth_service.dart';

/// Global app state — tracks the logged-in parent session and the
/// currently selected child. Persists tokens across app restarts.
class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  ChildProfile? _selectedChild;
  bool _initialized = false;

  bool get isLoggedIn => _accessToken != null;
  bool get initialized => _initialized;
  String? get accessToken => _accessToken;
  String? get userId => _userId;
  ChildProfile? get selectedChild => _selectedChild;

  // ── Bootstrap ──────────────────────────────────────────────────────────────

  /// Call once at startup. Restores a saved session from SharedPreferences
  /// and tries to refresh the JWT if it exists.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('auth_refresh_token');
    final savedUserId = prefs.getString('auth_user_id');

    if (saved != null && savedUserId != null) {
      final result = await _authService.refresh(saved);
      if (result.success) {
        _accessToken = result.accessToken;
        _refreshToken = result.refreshToken;
        _userId = result.userId;
        await _persist();
      } else {
        await _clear(prefs);
      }
    }

    _initialized = true;
    notifyListeners();
  }

  // ── Session management ─────────────────────────────────────────────────────

  Future<void> setSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
    await _persist();
    notifyListeners();
  }

  Future<void> signOut() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _selectedChild = null;
    final prefs = await SharedPreferences.getInstance();
    await _clear(prefs);
    notifyListeners();
  }

  // ── Child selection ────────────────────────────────────────────────────────

  void selectChild(ChildProfile child) {
    _selectedChild = child;
    notifyListeners();
  }

  void clearChild() {
    _selectedChild = null;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_refreshToken != null) {
      await prefs.setString('auth_refresh_token', _refreshToken!);
    }
    if (_userId != null) {
      await prefs.setString('auth_user_id', _userId!);
    }
  }

  Future<void> _clear(SharedPreferences prefs) async {
    await prefs.remove('auth_refresh_token');
    await prefs.remove('auth_user_id');
  }
}
