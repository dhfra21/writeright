import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_theme.dart';
import '../features/parent_controls/screens/create_child_account_screen.dart';
import '../features/parent_controls/screens/parent_login_screen.dart';
import '../services/children/children_service.dart';
import 'level_selection_screen.dart';
import 'parent_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCheckingChildren = false;

  Future<void> _onPlayTap() async {
    final appState = context.read<AppState>();

    if (!appState.isLoggedIn) {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelSelectionScreen()));
      return;
    }

    // Already have a selected child — go straight to play
    if (appState.selectedChild != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelSelectionScreen()));
      return;
    }

    // Logged in but no child selected — check the API
    setState(() => _isCheckingChildren = true);
    try {
      final children = await ChildrenService().getChildren(appState.accessToken!);
      if (!mounted) return;

      if (children.isNotEmpty) {
        appState.selectChild(children.first);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelSelectionScreen()));
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateChildAccountScreen(fromPlay: true)),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingChildren = false);
    }
  }

  void _onParentTap() {
    final appState = context.read<AppState>();
    if (appState.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ParentDashboardScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ParentLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: BubbleBackgroundPainter(
          colors: const [
            AppTheme.accentYellow,
            AppTheme.accentPink,
            AppTheme.accentGreen,
            AppTheme.accentBlue,
            AppTheme.primaryPurple,
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                Image.asset(
                  'assets/images/iss_logo.png',
                  width: 260,
                  height: 260,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),

                Text(
                  'WriteRight!',
                  style: GoogleFonts.nunito(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryOrange,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('⭐  ⭐  ⭐', style: TextStyle(fontSize: 22)),
                const SizedBox(height: 10),
                Text(
                  'Learn to write with fun!',
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 2),

                // Start Playing button
                _PlayButton(
                  isLoading: _isCheckingChildren,
                  onTap: _onPlayTap,
                ),

                const SizedBox(height: 18),

                // Parent Dashboard button
                _ParentButton(onTap: _onParentTap),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _PlayButton({required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 90,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.accentYellow, AppTheme.primaryOrange],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  'Start Playing!',
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ParentButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ParentButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 68,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.primaryOrange, width: 2.5),
        ),
        child: Center(
          child: Text(
            'Parent Dashboard',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryOrange,
            ),
          ),
        ),
      ),
    );
  }
}
