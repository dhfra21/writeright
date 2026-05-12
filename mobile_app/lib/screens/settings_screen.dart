import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/state/app_state.dart';
import '../core/state/app_settings.dart';
import '../core/theme/app_theme.dart';
import '../models/child_profile.dart';
import '../services/children/children_service.dart';
import '../features/parent_controls/screens/parent_login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _childrenService = ChildrenService();
  List<ChildProfile> _children = [];
  bool _isLoadingChildren = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final token = context.read<AppState>().accessToken;
    if (token == null) return;
    final children = await _childrenService.getChildren(token);
    if (!mounted) return;
    setState(() {
      _children = children;
      _isLoadingChildren = false;
    });
  }

  // ── Child edit/delete ──────────────────────────────────────────────────────

  Future<void> _editChild(ChildProfile child) async {
    final result = await showDialog<ChildProfile>(
      context: context,
      builder: (_) => _EditChildDialog(child: child),
    );
    if (result == null) return;

    final token = context.read<AppState>().accessToken;
    if (token == null) return;

    final updated = await _childrenService.updateChild(
      accessToken: token,
      childId: child.id,
      name: result.name,
      age: result.age,
      avatarEmoji: result.avatarEmoji ?? '👦',
    );

    if (!mounted) return;
    if (updated != null) {
      setState(() {
        final idx = _children.indexWhere((c) => c.id == child.id);
        if (idx != -1) _children[idx] = updated;
      });
      // Update selected child in AppState if it was the one edited
      final appState = context.read<AppState>();
      if (appState.selectedChild?.id == child.id) {
        appState.selectChild(updated);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child profile updated!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update. Please try again.')),
      );
    }
  }

  Future<void> _deleteChild(ChildProfile child) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete ${child.name}?'),
        content: Text(
          'This will permanently delete ${child.name}\'s profile and all their progress. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accentPink),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final token = context.read<AppState>().accessToken;
    if (token == null) return;

    final success = await _childrenService.deleteChild(
      accessToken: token,
      childId: child.id,
    );

    if (!mounted) return;
    if (success) {
      setState(() => _children.removeWhere((c) => c.id == child.id));
      final appState = context.read<AppState>();
      if (appState.selectedChild?.id == child.id) {
        appState.clearChild();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${child.name}\'s profile deleted.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete. Please try again.')),
      );
    }
  }

  // ── Account actions ────────────────────────────────────────────────────────

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AppState>().signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ParentLoginScreen()),
            (route) => false,
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: CustomPaint(
        painter: BubbleBackgroundPainter(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // ── Practice section ───────────────────────────────────────────
            _SectionHeader(title: 'Practice', emoji: '✏️'),
            _SettingsCard(
              children: [
                _ToggleTile(
                  icon: Icons.record_voice_over_rounded,
                  iconColor: AppTheme.accentBlue,
                  title: 'Voice Feedback',
                  subtitle: 'Read encouragement aloud after each attempt',
                  value: settings.voiceFeedbackEnabled,
                  onChanged: settings.setVoiceFeedback,
                ),
                const _Divider(),
                _ToggleTile(
                  icon: Icons.auto_awesome_rounded,
                  iconColor: AppTheme.primaryPurple,
                  title: 'AI Evaluation',
                  subtitle: 'Use Groq Vision for detailed handwriting feedback',
                  value: settings.aiEvaluationEnabled,
                  onChanged: settings.setAiEvaluation,
                ),
                if (settings.voiceFeedbackEnabled) ...[
                  const _Divider(),
                  _SliderTile(
                    icon: Icons.speed_rounded,
                    iconColor: AppTheme.accentGreen,
                    title: 'Voice Speed',
                    value: settings.voiceSpeed,
                    min: 0.5,
                    max: 1.5,
                    divisions: 4,
                    labelBuilder: (v) {
                      if (v <= 0.5) return 'Slow';
                      if (v <= 0.75) return 'Slower';
                      if (v <= 1.0) return 'Normal';
                      if (v <= 1.25) return 'Faster';
                      return 'Fast';
                    },
                    onChanged: settings.setVoiceSpeed,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // ── Children section ───────────────────────────────────────────
            _SectionHeader(title: 'Children', emoji: '👦'),
            _SettingsCard(
              children: [
                if (_isLoadingChildren)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_children.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No children added yet.',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: AppTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ..._children.asMap().entries.map((entry) {
                    final i = entry.key;
                    final child = entry.value;
                    return Column(
                      children: [
                        _ChildTile(
                          child: child,
                          onEdit: () => _editChild(child),
                          onDelete: () => _deleteChild(child),
                        ),
                        if (i < _children.length - 1) const _Divider(),
                      ],
                    );
                  }),
              ],
            ),
            const SizedBox(height: 24),

            // ── Account section ────────────────────────────────────────────
            _SectionHeader(title: 'Account', emoji: '👤'),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.logout_rounded,
                  iconColor: AppTheme.accentPink,
                  title: 'Sign Out',
                  onTap: _handleSignOut,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String emoji;

  const _SectionHeader({required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.cardWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: Color(0xFFF0F0F0),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) => onChanged(v),
            activeColor: AppTheme.primaryOrange,
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) labelBuilder;
  final Future<void> Function(double) onChanged;

  const _SliderTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      labelBuilder(value),
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  activeColor: AppTheme.primaryOrange,
                  onChanged: (v) => onChanged(v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: iconColor,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }
}

class _ChildTile extends StatelessWidget {
  final ChildProfile child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChildTile({
    required this.child,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            child.avatarEmoji ?? '👦',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  'Age ${child.age}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            color: AppTheme.accentBlue,
            tooltip: 'Edit',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppTheme.accentPink,
            tooltip: 'Delete',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ── Edit child dialog ─────────────────────────────────────────────────────────

class _EditChildDialog extends StatefulWidget {
  final ChildProfile child;

  const _EditChildDialog({required this.child});

  @override
  State<_EditChildDialog> createState() => _EditChildDialogState();
}

class _EditChildDialogState extends State<_EditChildDialog> {
  late final TextEditingController _nameController;
  late int _age;
  late String _avatar;

  static const _avatars = [
    '🐱', '🐶', '🦊', '🐸',
    '🐼', '🦁', '🐯', '🐨',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.name);
    _age = widget.child.age;
    _avatar = widget.child.avatarEmoji ?? '👦';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit ${widget.child.name}',
        style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar picker
            Text(
              'Avatar',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _avatars.map((emoji) {
                final selected = emoji == _avatar;
                return GestureDetector(
                  onTap: () => setState(() => _avatar = emoji),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryOrange.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primaryOrange
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Name field
            Text(
              'Name',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Child\'s name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Age picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Age',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppTheme.primaryOrange,
                      onPressed: _age > 3 ? () => setState(() => _age--) : null,
                    ),
                    Text(
                      '$_age',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppTheme.primaryOrange,
                      onPressed: _age < 12 ? () => setState(() => _age++) : null,
                    ),
                  ],
                ),

              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
              context,
              ChildProfile(
                id: widget.child.id,
                name: name,
                age: _age,
                avatarEmoji: _avatar,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}