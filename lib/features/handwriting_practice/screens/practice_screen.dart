import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/buddy_data.dart';
import '../../../services/gamification/gamification_service.dart';
import '../../../services/ml_inference/groq_vision_service.dart';
import '../../../services/tts/tts_service.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/character_template.dart';

class PracticeScreen extends StatefulWidget {
  final int initialIndex;

  const PracticeScreen({super.key, this.initialIndex = 0});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  static const List<String> _characters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  late int _currentIndex;
  String get _currentCharacter => _characters[_currentIndex];

  final GlobalKey<DrawingCanvasState> _canvasKey = GlobalKey<DrawingCanvasState>();
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _groqService = GroqVisionService(
      apiKey: const String.fromEnvironment('GROQ_API_KEY'),
    );
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
    _canvasStrokeCount = 0;
  }

  void _nextCharacter() {
    if (_currentIndex < _characters.length - 1) {
      setState(() {
        _currentIndex++;
        _resetState();
      });
      _canvasKey.currentState?.clear();
    }
  }

  void _previousCharacter() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _resetState();
      });
      _canvasKey.currentState?.clear();
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

  Future<void> _evaluateHandwriting() async {
    final canvasState = _canvasKey.currentState;
    if (canvasState == null || !canvasState.hasStrokes) return;

    // Capture service before async gap
    final gamification = context.read<GamificationService>();

    setState(() {
      _isEvaluating = true;
      _resultReady = true; // prevent re-submission while loading
    });

    try {
      final imageBytes = await canvasState.exportAsImage();
      if (imageBytes != null && mounted) {
        final visionResult = await _groqService.evaluateFromImage(
          character: _currentCharacter,
          imageBytes: imageBytes,
        );

        if (mounted) {
          final score = visionResult.score.similarity;
          final stars = _starsForScore(score);

          // Award XP and stars based on the AI score
          gamification.processPracticeResult(_currentCharacter, score);

          // Reveal results and start TTS simultaneously
          setState(() {
            _visionResult = visionResult;
            _isEvaluating = false;
            if (stars >= 2) _showCelebration = true;
          });

          _tts.speak(
            '${visionResult.encouragement}. ${visionResult.detailedFeedback}',
          );
        }
      }
    } catch (e, stack) {
      debugPrint('[PracticeScreen] Groq Vision call failed: $e');
      debugPrint('[PracticeScreen] Stack: $stack');
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
        title: Text('Letter $_currentCharacter'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${_characters.length}',
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // XP/Level strip
                    const _XpStrip(),
                    const SizedBox(height: 14),

                    // Buddy + animated speech bubble
                    _BuddySection(
                      character: _currentCharacter,
                      isEvaluating: _isEvaluating,
                      visionResult: _visionResult,
                      hasDrawn: _hasDrawn,
                    ),
                    const SizedBox(height: 16),

                    // Drawing area: template behind canvas.
                    Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (_) =>
                          setState(() => _lockScroll = true),
                      onPointerUp: (_) =>
                          setState(() => _lockScroll = false),
                      onPointerCancel: (_) =>
                          setState(() => _lockScroll = false),
                      child: SizedBox(
                        width: 280,
                        height: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CharacterTemplate(character: _currentCharacter),
                            DrawingCanvas(
                              key: _canvasKey,
                              width: 280,
                              height: 280,
                              onStrokesChanged: (strokes) {
                                setState(() {
                                  _canvasStrokeCount = strokes.length;
                                  if (!_hasDrawn && strokes.isNotEmpty) {
                                    _hasDrawn = true;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action buttons: Undo | Clear | Check!
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.undo_rounded,
                          label: 'Undo',
                          color: AppTheme.accentBlue,
                          onPressed: _canvasStrokeCount > 0 && !_isEvaluating
                              ? _undoStroke
                              : null,
                        ),
                        const SizedBox(width: 12),
                        _ActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'Clear',
                          color: AppTheme.accentPink,
                          onPressed: _hasDrawn && !_isEvaluating
                              ? _clearCanvas
                              : null,
                        ),
                        const SizedBox(width: 12),
                        _ActionButton(
                          icon: Icons.check_circle_rounded,
                          label: 'Check!',
                          color: AppTheme.accentGreen,
                          onPressed: (_hasDrawn && !_isEvaluating && !_resultReady)
                              ? _evaluateHandwriting
                              : null,
                          isLoading: _isEvaluating,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Feedback panel — only visible once Groq returns
                    if (_visionResult != null)
                      _FeedbackPanel(visionResult: _visionResult!),
                    const SizedBox(height: 20),

                    // Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _currentIndex > 0 ? _previousCharacter : null,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Previous'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _currentIndex < _characters.length - 1
                              ? _nextCharacter
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

          // Star celebration overlay
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

// ─── Buddy Section ───────────────────────────────────────────────────────────

class _BuddySection extends StatelessWidget {
  final String character;
  final bool isEvaluating;
  final VisionResult? visionResult;
  final bool hasDrawn;

  const _BuddySection({
    required this.character,
    required this.isEvaluating,
    required this.visionResult,
    required this.hasDrawn,
  });

  String _bubbleMessage(BuddyData buddy) {
    if (visionResult != null) return visionResult!.encouragement;
    if (isEvaluating) return 'Checking your writing... \uD83D\uDD0D';
    if (hasDrawn) return 'Looking good! Tap Check when you\'re ready! \u2705';
    return 'Write the letter $character! ${buddy.idleMessage}';
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
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
  bool shouldRepaint(covariant _BubbleTailPainter old) => old.color != color;
}

// ─── XP Strip ────────────────────────────────────────────────────────────────

class _XpStrip extends StatelessWidget {
  const _XpStrip();

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationService>(
      builder: (context, gam, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
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
              '\u2B50 ${gam.totalStars}',
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

// ─── Star Celebration Overlay ─────────────────────────────────────────────────

class _StarCelebrationOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const _StarCelebrationOverlay({required this.onComplete});

  @override
  State<_StarCelebrationOverlay> createState() => _StarCelebrationOverlayState();
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
                  '\u2B50\u2B50\u2B50',
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

// ─── Action Button ────────────────────────────────────────────────────────────

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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: onPressed != null ? color : color.withValues(alpha: 0.4),
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
                    : Icon(icon, color: Colors.white, size: 32),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

// ─── Feedback Panel ───────────────────────────────────────────────────────────

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
          // Star rating from Groq score
          _buildScoreStars(visionResult.score.similarity),
          const SizedBox(height: 12),

          // Encouragement headline
          Text(
            visionResult.encouragement,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryOrange,
            ),
          ),
          const SizedBox(height: 8),

          // Detailed feedback
          Text(
            visionResult.detailedFeedback,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
              height: 1.5,
            ),
          ),

          // Tips
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
                    const Text('\uD83D\uDCA1 ', style: TextStyle(fontSize: 14)),
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
            i < starCount ? Icons.star_rounded : Icons.star_outline_rounded,
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
