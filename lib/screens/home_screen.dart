import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../features/handwriting_practice/screens/character_selection_screen.dart';
import '../features/handwriting_practice/screens/word_selection_screen.dart'; // ✅ added
import '../features/parent_controls/screens/parent_login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: BubbleBackgroundPainter(),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Pencil mascot area
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentYellow, AppTheme.primaryOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '\u270F\uFE0F',
                      style: TextStyle(fontSize: 72),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // App name
                Text(
                  'WriteRight!',
                  style: GoogleFonts.nunito(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryOrange,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s make handwriting\nfun and easy!',
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 1),

                // Start Learning (Level 1)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CharacterSelectionScreen(),
                        ),
                      );
                    },
                    icon: const Text('\u270F\uFE0F',
                        style: TextStyle(fontSize: 22)),
                    label: const Text('Start Learning'),
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ Level 2 button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const WordSelectionScreen(),
                        ),
                      );
                    },
                    icon: const Text('✏️', style: TextStyle(fontSize: 22)),
                    label: const Text('Level 2 — Simple Words'),
                  ),
                ),

                const SizedBox(height: 16),

                const Spacer(flex: 1),

                // Parent button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ParentLoginScreen(),
                        ),
                      );
                    },
                    icon: const Text(
                      '\uD83D\uDC68\u200D\uD83D\uDC69\u200D\uD83D\uDC67',
                      style: TextStyle(fontSize: 22),
                    ),
                    label: const Text('I am a Parent'),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
