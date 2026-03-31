import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

/// Displays the target character as a faded "ghost" guide behind the drawing canvas.
class CharacterTemplate extends StatelessWidget {
  final String character;
  final double size;
  final Color color;
  final double opacity;

  const CharacterTemplate({
    super.key,
    required this.character,
    this.size = 280,
    this.color = AppTheme.primaryPurple,
    this.opacity = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          character.toUpperCase(),
          style: GoogleFonts.nunito(
            fontSize: size * 0.75,
            fontWeight: FontWeight.w800,
            color: color.withValues(alpha: opacity),
          ),
        ),
      ),
    );
  }
}
