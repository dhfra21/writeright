import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/buddy_data.dart';
import '../../../core/constants/word_data.dart';
import '../../../services/gamification/gamification_service.dart';
import '../../../services/ml_inference/groq_vision_service.dart';
import '../../../services/tts/tts_service.dart';
import '../widgets/drawing_canvas.dart';

class WordPracticeScreen extends StatefulWidget {
  final int initialIndex;

  const WordPracticeScreen({super.key, this.initialIndex = 0});

  @override
  State<WordPracticeScreen> createState() => _WordPracticeScreenState();
}

class _WordPracticeScreenState extends State<WordPracticeScreen> {
  late int _currentIndex;

  WordEntry get _currentWord => WordData.all[_currentIndex];

  final GlobalKey<DrawingCanvasState> _canvasKey =
      GlobalKey<DrawingCanvasState>();
  final TtsService _tts = TtsService();
  final ScrollController _scrollController = ScrollController();
  late final GroqVisionService _groqService;

  bool _isEvaluating = false;
  bool _hasDrawn = false;
  bool _resultReady = false;
  bool _lockScroll = false;
  int _canvasStrokeCount = 0;
  VisionResult? _visionResult;
  bool _showCelebration = false;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _groqService = GroqVisionService(
      apiKey: const String.fromEnvironment('GROQ_API_KEY'),
    );
    // Speak the word aloud when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.speak(_currentWord.word);
    });
  }

  @override
  void dispose() {
    _tts.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetState() {
    _tts.stop();
    _visionResult = null;
    _hasDrawn = false;
    _resultReady = false;
    _isEvaluating = false;
    _showCelebration = false;
    _showHint = false;
    _canvasStrokeCount = 0;
  }

  void _nextWord() {
    if (_currentIndex < WordData.all.length - 1) {
      setState(() {
        _currentIndex++;
        _resetState();
      });
      _canvasKey.currentState?.clear();
      _tts.speak(_currentWord.word);
    }
  }

  void _previousWord() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _resetState();
      });
      _canvasKey.currentState?.clear();
      _tts.speak(_currentWord.word);
    }
  }

  void _clearCanvas() {
    _canvasKey.currentState?.clear();
    setState(() {
      _visionResult = null;
      _hasDrawn = false;
      _resultReady = false;
      _isEvaluating = false;
      _showCelebration = false;
      _canvasStrokeCount = 0;
    });
  }

  void _undoStroke() {
    _canvasKey.currentState?.undo();
    final newCount = _canvasKey.currentState?.strokeCount ?? 0;
    setState(() {
      _canvasStrokeCount = newCount;
      if (newCount == 0) _hasDrawn = false;
    });
  }

  void _toggleHint() {
    setState(() => _showHint = !_showHint);
    // Auto-hide hint after 3 seconds
    if (_showHint) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showHint = false);
      });
    }
  }

  Future<void> _evaluateHandwriting() async {
    final canvasState = _canvasKey.currentState;
    if (canvasState == null || !canvasState.hasStrokes) return;

    final gamification = context.read<GamificationService>();

    setState(() {
      _isEvaluating = true;
      _resultReady = true;
    });

    try {
      final imageBytes = await canvasState.exportAsImage();
      if (imageBytes != null && mounted) {
        final visionResult = await _groqService.evaluateFromImage(
          // Pass word context so AI knows what to evaluate
          character: _currentWord.word,
          imageBytes: imageBytes,
        );

        if (mounted) {
          final score = visionResult.score.similarity;
          final stars = _starsForScore(score);

          gamification.processPracticeResult(_currentWord.word, score);

          setState(() {
            _visionResult = visionResult;
            _isEvaluating = false;
            if (stars >= 2) _showCelebration = true;
          });

          // Speak encouragement + word again
          _tts.speak(
            '${visionResult.encouragement}. ${visionResult.detailedFeedback}',
          );
        }
      }
    } catch (e, stack) {
      debugPrint('[WordPracticeScreen] Groq Vision call failed: $e');
      debugPrint('[WordPracticeScreen] Stack: $stack');
      if (mounted) setState(() => _isEvaluating = false);
    }
  }

  int _starsForScore(double score) {
    if (score >= 0.8) return 3;
    if (score >= 0.5) return 2;
    if (score > 0.0) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word: ${_currentWord.word}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${WordData.all.length}',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomPaint(
            painter: BubbleBackgroundPainter(),
            child: SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: _lockScroll
                    ? const NeverScrollableScrollPhysics()
                    : const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // XP strip — identical to Level 1
                    const _XpStrip(),
                    const SizedBox(height: 14),

                    // Word display card with emoji + hint button
                    _WordDisplayCard(
                      entry: _currentWord,
                      showHint: _showHint,
                      onHintTap: _toggleHint,
                      onSpeakTap: () => _tts.speak(_currentWord.word),
                    ),
                    const SizedBox(height: 12),

                    // Buddy + speech bubble — same as Level 1
                    _BuddySection(
                      word: _currentWord.word,
                      isEvaluating: _isEvaluating,
                      visionResult: _visionResult,
                      hasDrawn: _hasDrawn,
                    ),
                    const SizedBox(height: 16),

                    // Drawing canvas — wider for words
                    Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (_) =>
                          setState(() => _lockScroll = true),
                      onPointerUp: (_) =>
                          setState(() => _lockScroll = false),
                      onPointerCancel: (_) =>
                          setState(() => _lockScroll = false),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Use available width but fixed height — never infinity
                          final canvasW = constraints.maxWidth == double.infinity
                              ? 360.0
                              : constraints.maxWidth;
                          const canvasH = 180.0;
                          return SizedBox(
                            width: canvasW,
                            height: canvasH,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Writing guidelines (baseline + midline)
                                _WritingGuides(
                                  width: canvasW,
                                  height: canvasH,
                                ),
                                // Drawing canvas — fixed size so exportAsImage works
                                DrawingCanvas(
                                  key: _canvasKey,
                                  width: canvasW,
                                  height: canvasH,
                                  onStrokesChanged: (strokes) {
                                    setState(() {
                                      _canvasStrokeCount = strokes.length;
                                      if (!_hasDrawn && strokes.isNotEmpty) {
                                        _hasDrawn = true;
                                      }
                                    });
                                  },
                                ),
                                // Ghost hint overlay
                                if (_showHint)
                                  _GhostWordHint(word: _currentWord.word),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action buttons — Undo | Clear | Hint | Check!
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.undo_rounded,
                          label: 'Undo',
                          color: AppTheme.accentBlue,
                          onPressed:
                              _canvasStrokeCount > 0 && !_isEvaluating
                                  ? _undoStroke
                                  : null,
                        ),
                        const SizedBox(width: 10),
                        _ActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'Clear',
                          color: AppTheme.accentPink,
                          onPressed: _hasDrawn && !_isEvaluating
                              ? _clearCanvas
                              : null,
                        ),
                        const SizedBox(width: 10),
                        _ActionButton(
                          icon: Icons.lightbulb_rounded,
                          label: 'Hint',
                          color: AppTheme.accentYellow,
                          onPressed:
                              !_isEvaluating ? _toggleHint : null,
                        ),
                        const SizedBox(width: 10),
                        _ActionButton(
                          icon: Icons.check_circle_rounded,
                          label: 'Check!',
                          color: AppTheme.accentGreen,
                          onPressed: (_hasDrawn &&
                                  !_isEvaluating &&
                                  !_resultReady)
                              ? _evaluateHandwriting
                              : null,
                          isLoading: _isEvaluating,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Feedback panel
                    if (_visionResult != null)
                      _FeedbackPanel(visionResult: _visionResult!),
                    const SizedBox(height: 20),

                    // Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed:
                              _currentIndex > 0 ? _previousWord : null,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Previous'),
                        ),
                        OutlinedButton.icon(
                          onPressed:
                              _currentIndex < WordData.all.length - 1
                                  ? _nextWord
                                  : null,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Next'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Star celebration overlay — identical to Level 1
          if (_showCelebration)
            _StarCelebrationOverlay(
              onComplete: () {
                if (mounted) setState(() => _showCelebration = false);
              },
            ),
        ],
      ),
    );
  }
}

// ─── Word Display Card ────────────────────────────────────────────────────────

class _WordDisplayCard extends StatelessWidget {
  final WordEntry entry;
  final bool showHint;
  final VoidCallback onHintTap;
  final VoidCallback onSpeakTap;

  const _WordDisplayCard({
    required this.entry,
    required this.showHint,
    required this.onHintTap,
    required this.onSpeakTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Big emoji
          Text(entry.emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(width: 16),

          // Word + hint text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.word,
                  style: GoogleFonts.nunito(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryPurple,
                    letterSpacing: 4,
                  ),
                ),
                if (showHint)
                  Text(
                    entry.hint,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
              ],
            ),
          ),

          // Speak button
          GestureDetector(
            onTap: onSpeakTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                color: AppTheme.accentBlue,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Writing Guides ───────────────────────────────────────────────────────────

class _WritingGuides extends StatelessWidget {
  final double width;
  final double height;

  const _WritingGuides({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: CustomPaint(
        painter: _GuideLinesPainter(),
      ),
    );
  }
}

class _GuideLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentBlue.withValues(alpha: 0.2)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = AppTheme.accentPink.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Baseline (solid)
    final baselineY = size.height * 0.72;
    canvas.drawLine(
      Offset(16, baselineY),
      Offset(size.width - 16, baselineY),
      paint,
    );

    // Midline (dashed)
    final midlineY = size.height * 0.38;
    _drawDashedLine(
      canvas,
      Offset(16, midlineY),
      Offset(size.width - 16, midlineY),
      dashPaint,
    );
  }

  void _drawDashedLine(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double distance = 0;
    final totalDistance = (end - start).distance;
    final direction = (end - start) / totalDistance;

    while (distance < totalDistance) {
      final dashStart = start + direction * distance;
      final dashEnd = start +
          direction * (distance + dashWidth).clamp(0, totalDistance);
      canvas.drawLine(dashStart, dashEnd, paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Ghost Word Hint ──────────────────────────────────────────────────────────

class _GhostWordHint extends StatelessWidget {
  final String word;

  const _GhostWordHint({required this.word});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Text(
          word,
          style: GoogleFonts.nunito(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryPurple.withValues(alpha: 0.12),
            letterSpacing: 8,
          ),
        ),
      ),
    );
  }
}

// ─── Buddy Section (mirrors Level 1) ─────────────────────────────────────────

class _BuddySection extends StatelessWidget {
  final String word;
  final bool isEvaluating;
  final VisionResult? visionResult;
  final bool hasDrawn;

  const _BuddySection({
    required this.word,
    required this.isEvaluating,
    required this.visionResult,
    required this.hasDrawn,
  });

  String _bubbleMessage(BuddyData buddy) {
    if (visionResult != null) return visionResult!.encouragement;
    if (isEvaluating) return 'Checking your word... 🔍';
    if (hasDrawn) return 'Great effort! Tap Check when ready! ✅';
    return 'Write the word $word! ${buddy.idleMessage}';
  }

  @override
  Widget build(BuildContext context) {
    final buddyIndex =
        context.watch<GamificationService>().selectedBuddyIndex;
    final buddy = BuddyData.all[buddyIndex];
    final message = _bubbleMessage(buddy);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(buddy.emoji, style: const TextStyle(fontSize: 68)),
        const SizedBox(width: 6),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _SpeechBubble(
              key: ValueKey(message),
              message: message,
              color: buddy.color,
              isLoading: isEvaluating,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String message;
  final Color color;
  final bool isLoading;

  const _SpeechBubble({
    super.key,
    required this.message,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomPaint(
          size: const Size(12, 20),
          painter: _BubbleTailPainter(color: color),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: color.withValues(alpha: 0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      height: 1.4,
                    ),
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;
  const _BubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = AppTheme.cardWhite
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width, 3)
      ..lineTo(size.width, size.height - 3)
      ..lineTo(0, size.height / 2)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter old) =>
      old.color != color;
}

// ─── XP Strip (identical to Level 1) ─────────────────────────────────────────

class _XpStrip extends StatelessWidget {
  const _XpStrip();

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationService>(
      builder: (context, gam, _) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              'Lv ${gam.level}',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: gam.levelProgress,
                  minHeight: 10,
                  backgroundColor:
                      AppTheme.primaryPurple.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryPurple),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${gam.xp} XP',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '⭐ ${gam.totalStars}',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentYellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Star Celebration Overlay (identical to Level 1) ─────────────────────────

class _StarCelebrationOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  const _StarCelebrationOverlay({required this.onComplete});

  @override
  State<_StarCelebrationOverlay> createState() =>
      _StarCelebrationOverlayState();
}

class _StarCelebrationOverlayState extends State<_StarCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<double> _dy;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _scale = Tween<double>(begin: 0.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
      ),
    );
    _dy = Tween<double>(begin: 0.0, end: -70.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );
    _ctrl.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => Opacity(
            opacity: _opacity.value,
            child: Transform.translate(
              offset: Offset(0, _dy.value),
              child: Transform.scale(
                scale: _scale.value,
                child: const Text(
                  '⭐⭐⭐',
                  style: TextStyle(fontSize: 60),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Action Button (identical to Level 1) ────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: 4,
          shadowColor: color.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: onPressed != null
                    ? color
                    : color.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(icon, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

// ─── Feedback Panel (identical to Level 1) ───────────────────────────────────

class _FeedbackPanel extends StatelessWidget {
  final VisionResult visionResult;

  const _FeedbackPanel({required this.visionResult});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreStars(visionResult.score.similarity),
          const SizedBox(height: 12),
          Text(
            visionResult.encouragement,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryOrange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            visionResult.detailedFeedback,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
              height: 1.5,
            ),
          ),
          if (visionResult.tips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Tips:',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryPurple,
              ),
            ),
            ...visionResult.tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreStars(double score) {
    final starCount = (score * 5).round().clamp(0, 5);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            i < starCount
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            color: i < starCount
                ? AppTheme.accentYellow
                : AppTheme.textMuted.withValues(alpha: 0.3),
            size: 36,
          ),
        ),
      ),
    );
  }
}
