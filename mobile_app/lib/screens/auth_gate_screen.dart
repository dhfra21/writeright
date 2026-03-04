import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/state/app_state.dart';
import '../features/parent_controls/screens/parent_login_screen.dart';
import '../services/children/children_service.dart';
import 'parent_dashboard_screen.dart';

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
    final appState = context.read<AppState>();

    // Wait for AppState to finish initialization
    while (!appState.initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    // If logged in, load children
    if (appState.isLoggedIn && appState.accessToken != null) {
      final children = await _childrenService.getChildren(appState.accessToken!);

      if (!mounted) return;

      // If has children, select the first one by default
      if (children.isNotEmpty) {
        appState.selectChild(children.first);
      }

      // Navigate to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ParentDashboardScreen()),
      );
    } else {
      // Not logged in, show login screen
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ParentLoginScreen()),
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
