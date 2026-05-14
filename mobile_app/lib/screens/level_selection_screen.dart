import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';
import '../features/handwriting_practice/screens/character_selection_screen.dart';
import '../features/handwriting_practice/screens/sentence_selection_screen.dart';
import '../features/handwriting_practice/screens/word_selection_screen.dart';

class _LevelData {
  final String emoji;
  final String levelLabel;
  final String title;
  final String difficulty;
  final int stars;
  final String description;
  final List<Color> gradient;
  final Color accentColor;
  final Widget screen;

  const _LevelData({
    required this.emoji,
    required this.levelLabel,
    required this.title,
    required this.difficulty,
    required this.stars,
    required this.description,
    required this.gradient,
    required this.accentColor,
    required this.screen,
  });
}

const _levels = [
  _LevelData(
    emoji: '🔤',
    levelLabel: 'Level 1',
    title: 'Letters',
    difficulty: 'Easy',
    stars: 1,
    description: 'Trace and write every letter\nfrom A all the way to Z!',
    gradient: [AppTheme.accentYellow, AppTheme.primaryOrange],
    accentColor: AppTheme.primaryOrange,
    screen: CharacterSelectionScreen(),
  ),
  _LevelData(
    emoji: '✏️',
    levelLabel: 'Level 2',
    title: 'Words',
    difficulty: 'Medium',
    stars: 2,
    description: 'Practice spelling and writing\ncommon everyday words!',
    gradient: [AppTheme.accentBlue, AppTheme.primaryPurple],
    accentColor: AppTheme.primaryPurple,
    screen: WordSelectionScreen(),
  ),
  _LevelData(
    emoji: '📖',
    levelLabel: 'Level 3',
    title: 'Sentences',
    difficulty: 'Hard',
    stars: 3,
    description: 'Fill in the blanks and\ncomplete full sentences!',
    gradient: [Color(0xFFFF8A65), Color(0xFFE91E63)],
    accentColor: Color(0xFFE91E63),
    screen: SentenceSelectionScreen(),
  ),
];

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  double _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.80);
    _pageController.addListener(() {
      setState(() => _currentPage = _pageController.page ?? 0);
    });

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activePage = _currentPage.round().clamp(0, _levels.length - 1);

    return Scaffold(
      body: CustomPaint(
        painter: BubbleBackgroundPainter(),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Choose Your Level',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Swipe to explore  👈  👉',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),

              // Carousel
              Expanded(
                child: FadeTransition(
                  opacity: _entranceFade,
                  child: SlideTransition(
                    position: _entranceSlide,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _levels.length,
                      itemBuilder: (context, index) {
                        final distance = (_currentPage - index).abs().clamp(0.0, 1.0);
                        final scale = lerpDouble(1.0, 0.86, distance)!;
                        final opacity = lerpDouble(1.0, 0.55, distance)!;

                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: _LevelCard(
                              data: _levels[index],
                              isActive: distance < 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Page indicator dots
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_levels.length, (index) {
                    final isActive = activePage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: isActive ? 30 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isActive
                            ? _levels[activePage].accentColor
                            : AppTheme.textMuted.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final _LevelData data;
  final bool isActive;

  const _LevelCard({required this.data, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: data.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: data.accentColor.withValues(alpha: isActive ? 0.45 : 0.15),
              blurRadius: isActive ? 36 : 16,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Level badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.levelLabel,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Emoji
              Text(data.emoji, style: const TextStyle(fontSize: 88)),
              const SizedBox(height: 16),

              // Title
              Text(
                data.title,
                style: GoogleFonts.nunito(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 10),

              // Stars + difficulty badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '⭐' * data.stars,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data.difficulty,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                data.description,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Play button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => data.screen),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: data.accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                    textStyle: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: const Text("Let's Play! 🚀"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
