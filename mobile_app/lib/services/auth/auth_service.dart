import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

/// Result of a sign-in or registration call.
class AuthResult {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? error;

  const AuthResult._({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.error,
  });

  factory AuthResult.ok({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) =>
      AuthResult._(
        success: true,
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
      );

  factory AuthResult.fail(String error) =>
      AuthResult._(success: false, error: error);
}

/// Handles Supabase Auth via direct REST calls (no SDK dependency).
///
/// Login  → POST {supabaseUrl}/auth/v1/token?grant_type=password
/// Register → POST {apiBase}/auth/register   (backend creates user + accounts row)
/// Refresh  → POST {supabaseUrl}/auth/v1/token?grant_type=refresh_token
class AuthService {
  static const _supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const _supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1', // 10.0.2.2 is the default Android emulator address for localhost
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '624665855558-dt2tj89bl31eg772f18gfsbmk7hfuk91.apps.googleusercontent.com',
  );

  // ── Sign in ────────────────────────────────────────────────────────────────

  Future<AuthResult> signIn(String email, String password) async {
    if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
      return AuthResult.fail(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be provided via --dart-define',
      );
    }
    try {
      final resp = await http
          .post(
            Uri.parse('$_supabaseUrl/auth/v1/token?grant_type=password'),
            headers: {
              'apikey': _supabaseAnonKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      debugPrint('[AuthService] signIn HTTP ${resp.statusCode}');

      if (resp.statusCode == 200) {
        return AuthResult.ok(
          accessToken: body['access_token'] as String,
          refreshToken: body['refresh_token'] as String,
          userId: (body['user'] as Map<String, dynamic>)['id'] as String,
        );
      }
      final msg = (body['error_description'] ?? body['msg'] ?? body['error'] ?? 'Login failed')
          .toString();
      return AuthResult.fail(msg);
    } catch (e) {
      debugPrint('[AuthService] signIn error: $e');
      return AuthResult.fail('Could not connect to server. Check your connection.');
    }
  }

  // ── Google Sign in ──────────────────────────────────────────────────────────

  Future<AuthResult> signInWithGoogle() async {
    if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
      return AuthResult.fail(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be provided via --dart-define',
      );
    }
    try {
      // 1. Force the account picker to show by signing out of the local Google session first
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // Ignore errors if we weren't signed in
      }

      // 2. Now start the sign in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return AuthResult.fail('Sign in aborted');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final resp = await http.post(
        Uri.parse('$_supabaseUrl/auth/v1/token?grant_type=id_token'),
        headers: {
          'apikey': _supabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'provider': 'google',
          'id_token': googleAuth.idToken,
          'access_token': googleAuth.accessToken,
        }),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      debugPrint('[AuthService] googleSignIn HTTP ${resp.statusCode}');

      if (resp.statusCode == 200) {
        return AuthResult.ok(
          accessToken: body['access_token'] as String,
          refreshToken: body['refresh_token'] as String,
          userId: (body['user'] as Map<String, dynamic>)['id'] as String,
        );
      }
      final msg = (body['error_description'] ?? body['msg'] ?? body['error'] ?? 'Google Login failed')
          .toString();
      return AuthResult.fail(msg);
    } catch (e) {
      debugPrint('[AuthService] googleSignIn error: $e');
      return AuthResult.fail('Google Sign-In failed');
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────

  Future<AuthResult> register(
      String email, String password, String parentName) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$_apiBase/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'parentName': parentName,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      debugPrint('[AuthService] register HTTP ${resp.statusCode}');

      if (resp.statusCode == 201) {
        if (body['access_token'] != null) {
          return AuthResult.ok(
            accessToken: body['access_token'] as String,
            refreshToken: body['refresh_token'] as String,
            userId: body['user_id'] as String,
          );
        }
        // Backend created user but couldn't return a session — sign in explicitly
        return signIn(email, password);
      }
      return AuthResult.fail(
          (body['error'] ?? 'Registration failed').toString());
    } catch (e) {
      debugPrint('[AuthService] register error: $e');
      return AuthResult.fail('Could not connect to server. Check your connection.');
    }
  }

  // ── Refresh ────────────────────────────────────────────────────────────────

  Future<AuthResult> refresh(String refreshToken) async {
    if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
      return AuthResult.fail('Missing Supabase config');
    }
    try {
      final resp = await http
          .post(
            Uri.parse(
                '$_supabaseUrl/auth/v1/token?grant_type=refresh_token'),
            headers: {
              'apikey': _supabaseAnonKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200) {
        return AuthResult.ok(
          accessToken: body['access_token'] as String,
          refreshToken: body['refresh_token'] as String,
          userId: (body['user'] as Map<String, dynamic>)['id'] as String,
        );
      }
      return AuthResult.fail('Session expired. Please sign in again.');
    } catch (e) {
      return AuthResult.fail('Could not refresh session.');
    }
  }
}
