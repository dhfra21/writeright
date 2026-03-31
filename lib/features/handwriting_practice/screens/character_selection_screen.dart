import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/buddy_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/gamification/gamification_service.dart';
import 'practice_screen.dart';

class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({super.key});

  static const List<String> _characters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  static const List<Color> _cardColors = [
    AppTheme.accentPink,
    AppTheme.primaryOrange,
    AppTheme.accentYellow,
    AppTheme.accentGreen,
    AppTheme.accentBlue,
    AppTheme.primaryPurple,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Letter'),
      ),
      body: CustomPaint(
        painter: BubbleBackgroundPainter(),
        child: SafeArea(
          child: Column(
            children: [
              // Level / XP bar
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _LevelBar(),
              ),
              const SizedBox(height: 10),

              // Buddy picker
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: _BuddyPicker(),
              ),
              const SizedBox(height: 8),

              Text(
                'Which letter do you want to practice?',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),

              // A-Z grid
              Expanded(
                child: Consumer<GamificationService>(
                  builder: (context, gam, _) => GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _characters.length,
                    itemBuilder: (context, i) {
                      final char = _characters[i];
                      final stars = gam.starsPerCharacter[char] ?? 0;
                      final color = _cardColors[i % _cardColors.length];
                      return _LetterCard(
                        character: char,
                        stars: stars,
                        color: color,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PracticeScreen(initialIndex: i),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Level Bar ────────────────────────────────────────────────────────────────

class _LevelBar extends StatelessWidget {
  const _LevelBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationService>(
      builder: (context, gam, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Level circle
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppTheme.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${gam.level}',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // XP bar + label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level ${gam.level}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                      Text(
                        '${gam.xp} / ${gam.xpForNextLevel} XP',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: gam.levelProgress,
                      minHeight: 8,
                      backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Star count
            Column(
              children: [
                const Text('\u2B50', style: TextStyle(fontSize: 22)),
                Text(
                  '${gam.totalStars}',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentYellow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Buddy Picker ─────────────────────────────────────────────────────────────

class _BuddyPicker extends StatelessWidget {
  const _BuddyPicker();

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationService>(
      builder: (context, gam, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Buddy',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(BuddyData.all.length, (i) {
              final buddy = BuddyData.all[i];
              final selected = gam.selectedBuddyIndex == i;
              return GestureDetector(
                onTap: () => context.read<GamificationService>().selectBuddy(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected
                        ? buddy.color.withValues(alpha: 0.18)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? buddy.color
                          : buddy.color.withValues(alpha: 0.25),
                      width: selected ? 2.5 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      buddy.emoji,
                      style: TextStyle(fontSize: selected ? 26 : 22),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Letter Card ──────────────────────────────────────────────────────────────

class _LetterCard extends StatelessWidget {
  final String character;
  final int stars;
  final Color color;
  final VoidCallback onTap;

  const _LetterCard({
    required this.character,
    required this.stars,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final practiced = stars > 0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: practiced ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: practiced ? color : color.withValues(alpha: 0.35),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: practiced ? 0.28 : 0.10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              character,
              style: GoogleFonts.nunito(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: practiced ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Icon(
                  i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14,
                  color: i < stars
                      ? (practiced ? Colors.white : AppTheme.accentYellow)
                      : (practiced
                          ? Colors.white.withValues(alpha: 0.35)
                          : color.withValues(alpha: 0.25)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
