import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/state/app_state.dart';
import '../services/children/children_service.dart';
import 'home_screen.dart';

/// Auth gate that determines initial route based on authentication state.
/// Shows loading while checking auth, then routes to:
/// - ParentLoginScreen if not logged in
/// - ParentDashboard if logged in
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  final _childrenService = ChildrenService();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final appState = context.read<AppState>();

      // Wait for AppState to finish initialization (max 5 seconds)
      int attempts = 0;
      while (!appState.initialized && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (!mounted) return;

      // Preload children if already logged in
      if (appState.isLoggedIn && appState.accessToken != null) {
        try {
          final children = await _childrenService.getChildren(appState.accessToken!);
          if (!mounted) return;
          if (children.isNotEmpty) {
            appState.selectChild(children.first);
          }
        } catch (_) {}
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      debugPrint('[AuthGate] _checkAuthState error: $e');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '✏️',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
