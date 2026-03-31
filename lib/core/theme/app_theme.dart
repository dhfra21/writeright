import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Child-friendly color palette ──
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryPurple = Color(0xFF7B2FF7);
  static const Color accentYellow = Color(0xFFFFD93D);
  static const Color accentGreen = Color(0xFF6BCB77);
  static const Color accentPink = Color(0xFFFF6B6B);
  static const Color accentBlue = Color(0xFF4ECDC4);
  static const Color backgroundCream = Color(0xFFFFF8F0);
  static const Color backgroundLight = Color(0xFFFFFDF7);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMuted = Color(0xFF636E72);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        primary: primaryOrange,
        secondary: primaryPurple,
        tertiary: accentYellow,
        surface: backgroundCream,
        onSurface: textDark,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundCream,
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        headlineLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textMuted,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textMuted,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textDark,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryOrange, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: accentPink, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: accentPink, width: 2.5),
        ),
        labelStyle: GoogleFonts.nunito(
          color: textMuted,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.nunito(
          color: const Color(0xFFB0B0B0),
          fontWeight: FontWeight.w500,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
          shadowColor: primaryOrange.withValues(alpha: 0.4),
          textStyle: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
          shadowColor: primaryOrange.withValues(alpha: 0.4),
          textStyle: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          side: const BorderSide(color: primaryPurple, width: 2.5),
          textStyle: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          textStyle: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryPurple,
        contentTextStyle: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Reusable decorative bubble painter for backgrounds.
class BubbleBackgroundPainter extends CustomPainter {
  final List<Color> colors;

  BubbleBackgroundPainter({
    this.colors = const [
      AppTheme.accentYellow,
      AppTheme.accentPink,
      AppTheme.accentGreen,
      AppTheme.accentBlue,
      AppTheme.primaryPurple,
    ],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final bubbles = [
      _Bubble(Offset(size.width * 0.1, size.height * 0.08), 35, 0),
      _Bubble(Offset(size.width * 0.85, size.height * 0.05), 25, 1),
      _Bubble(Offset(size.width * 0.92, size.height * 0.35), 20, 2),
      _Bubble(Offset(size.width * 0.05, size.height * 0.55), 28, 3),
      _Bubble(Offset(size.width * 0.75, size.height * 0.85), 22, 4),
      _Bubble(Offset(size.width * 0.15, size.height * 0.9), 18, 0),
      _Bubble(Offset(size.width * 0.95, size.height * 0.65), 15, 1),
    ];

    for (final bubble in bubbles) {
      paint.color = colors[bubble.colorIndex % colors.length]
          .withValues(alpha: 0.15);
      canvas.drawCircle(bubble.position, bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Bubble {
  final Offset position;
  final double radius;
  final int colorIndex;
  _Bubble(this.position, this.radius, this.colorIndex);
}
