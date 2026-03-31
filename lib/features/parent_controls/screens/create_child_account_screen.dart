import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/children/children_service.dart';

class _AvatarOption {
  final String emoji;
  final String label;
  final Color color;
  final String greeting;

  const _AvatarOption(this.emoji, this.label, this.color, this.greeting);
}

class CreateChildAccountScreen extends StatefulWidget {
  const CreateChildAccountScreen({super.key});

  @override
  State<CreateChildAccountScreen> createState() =>
      _CreateChildAccountScreenState();
}

class _CreateChildAccountScreenState extends State<CreateChildAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _selectedAvatarIndex = 0;
  int _selectedAge = 5;
  bool _isLoading = false;

  final _childrenService = ChildrenService();

  static const _minAge = 3;
  static const _maxAge = 12;
  late final FixedExtentScrollController _ageScrollController =
      FixedExtentScrollController(initialItem: _selectedAge - _minAge);
  static const _avatars = [
    _AvatarOption(
      '🦁',
      'Lion',
      AppTheme.primaryOrange,
      "Roar! I'm Lion! I'll help you write like a champion! 💪",
    ),
    _AvatarOption(
      '🐻',
      'Bear',
      AppTheme.accentPink,
      "Hey there! I'm Bear! Writing with you will be so much fun! 🐾",
    ),
    _AvatarOption(
      '🐰',
      'Bunny',
      AppTheme.primaryPurple,
      "Hi hi! I'm Bunny! Let's hop through every letter together! 🥕",
    ),
    _AvatarOption(
      '🦊',
      'Fox',
      AppTheme.accentGreen,
      "Hey smarty! I'm Fox! We're going to be the best writers ever! 🌟",
    ),
    _AvatarOption(
      '🐧',
      'Penguin',
      AppTheme.accentBlue,
      "Waddle! I'm Penguin! Let's slide through every letter! ❄️",
    ),
    _AvatarOption(
      '🦄',
      'Unicorn',
      AppTheme.accentYellow,
      "Hi! I'm Unicorn! Writing is pure magic with me! ✨",
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageScrollController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final appState = context.read<AppState>();
    final accessToken = appState.accessToken;

    if (accessToken != null) {
      final child = await _childrenService.createChild(
        accessToken: accessToken,
        name: _nameController.text.trim(),
        age: _selectedAge,
        avatarEmoji: _avatars[_selectedAvatarIndex].emoji,
      );
      if (child != null && mounted) {
        appState.selectChild(child);
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _skipToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final selectedAvatar = _avatars[_selectedAvatarIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Add Child Profile')),
      body: CustomPaint(
        painter: BubbleBackgroundPainter(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Who is learning?',
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create a profile so we can personalize\\ntheir learning adventure!',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.elasticOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: _BuddyPreview(
                      key: ValueKey(_selectedAvatarIndex),
                      avatar: selectedAvatar,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pick a Buddy! 🐾',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _avatars.length,
                      itemBuilder: (context, index) {
                        final avatar = _avatars[index];
                        final isSelected = _selectedAvatarIndex == index;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedAvatarIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            width: 90,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? avatar.color.withValues(alpha: 0.15)
                                  : AppTheme.cardWhite,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? avatar.color
                                    : const Color(0xFFE8E8E8),
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color:
                                            avatar.color.withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  avatar.emoji,
                                  style: TextStyle(
                                    fontSize: isSelected ? 40 : 34,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  avatar.label,
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? avatar.color
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildLabel("✍️  What's their name?"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Type their name here...',
                      prefixIcon: Icon(Icons.face_rounded,
                          color: AppTheme.primaryOrange),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  _buildLabel('🎂  How old are they?'),
                  const SizedBox(height: 14),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFE8E8E8),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.primaryOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  AppTheme.primaryOrange.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        ListWheelScrollView.useDelegate(
                          controller: _ageScrollController,
                          itemExtent: 50,
                          perspective: 0.003,
                          diameterRatio: 1.5,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() => _selectedAge = _minAge + index);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: _maxAge - _minAge + 1,
                            builder: (context, index) {
                              final age = _minAge + index;
                              final isSelected = _selectedAge == age;
                              return Center(
                                child: Text(
                                  '$age years old',
                                  style: GoogleFonts.nunito(
                                    fontSize: isSelected ? 22 : 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w900
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? AppTheme.primaryOrange
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  FilledButton(
                    onPressed: _isLoading ? null : _handleCreateAccount,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      shadowColor: AppTheme.accentGreen.withValues(alpha: 0.4),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text("Let's Go! 🎉"),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _skipToHome,
                    child: Text(
                      "I'll do this later",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
      ),
    );
  }
}

// ─── Buddy Preview + Chat Bubble ─────────────────────────────────────────────

class _BuddyPreview extends StatelessWidget {
  final _AvatarOption avatar;

  const _BuddyPreview({super.key, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: avatar.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: avatar.color.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(avatar.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomPaint(
                  size: const Size(14, 22),
                  painter: _BubbleTailPainter(color: avatar.color),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: avatar.color.withValues(alpha: 0.55),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: avatar.color.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      avatar.greeting,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width, 4)
      ..lineTo(size.width, size.height - 4)
      ..lineTo(0, size.height / 2)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter old) => old.color != color;
}
