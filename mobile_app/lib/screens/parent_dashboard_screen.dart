import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_theme.dart';
import '../features/handwriting_practice/screens/character_selection_screen.dart';
import '../features/parent_controls/screens/create_child_account_screen.dart';
import '../features/parent_controls/screens/parent_login_screen.dart';
import '../models/child_profile.dart';
import '../services/children/children_service.dart';
import '../services/gamification/gamification_service.dart';
import '../services/progress/progress_service.dart';

/// Model for game progress data
class GameProgress {
  final int totalXp;
  final int currentLevel;
  final int totalStars;
  final int streakDays;
  final DateTime? lastPracticeDate;

  const GameProgress({
    required this.totalXp,
    required this.currentLevel,
    required this.totalStars,
    required this.streakDays,
    this.lastPracticeDate,
  });

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    return GameProgress(
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      currentLevel: (json['current_level'] as num?)?.toInt() ?? 1,
      totalStars: (json['total_stars'] as num?)?.toInt() ?? 0,
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      lastPracticeDate: json['last_practice_date'] != null
          ? DateTime.tryParse(json['last_practice_date'] as String)
          : null,
    );
  }
}

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> with WidgetsBindingObserver {
  final _childrenService = ChildrenService();
  final _progressService = ProgressService();

  List<ChildProfile> _children = [];
  GameProgress? _selectedChildProgress;
  bool _isLoading = true;
  bool _isLoadingProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload progress when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      final appState = context.read<AppState>();
      if (appState.selectedChild != null) {
        _loadProgressForChild(appState.selectedChild!);
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final appState = context.read<AppState>();
    if (appState.accessToken == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final children = await _childrenService.getChildren(appState.accessToken!);

      if (!mounted) return;
      setState(() {
        _children = children;
        _isLoading = false;
      });

      // Load progress for selected child
      if (appState.selectedChild != null) {
        final gamService = context.read<GamificationService>();
        gamService.setAccessToken(appState.accessToken);
        await gamService.setChildId(appState.selectedChild!.id);
        _loadProgressForChild(appState.selectedChild!);
      } else if (children.isNotEmpty) {
        // Select first child by default
        appState.selectChild(children.first);
        final gamService = context.read<GamificationService>();
        gamService.setAccessToken(appState.accessToken);
        await gamService.setChildId(children.first.id);
        _loadProgressForChild(children.first);
      }
    } catch (e) {
      debugPrint('[ParentDashboard] _loadData error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load data. Please try again.')),
      );
    }
  }

  Future<void> _loadProgressForChild(ChildProfile child) async {
    setState(() => _isLoadingProgress = true);

    final appState = context.read<AppState>();
    if (appState.accessToken == null) {
      setState(() => _isLoadingProgress = false);
      return;
    }

    try {
      final progress = await _progressService.getGameProgress(
        appState.accessToken!,
        child.id,
      );

      if (!mounted) return;
      setState(() {
        _selectedChildProgress = progress;
        _isLoadingProgress = false;
      });
    } catch (e) {
      debugPrint('[ParentDashboard] _loadProgressForChild error: $e');
      if (!mounted) return;
      setState(() => _isLoadingProgress = false);
    }
  }

  Future<void> _handleAddChild() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateChildAccountScreen(),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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

  Future<void> _handleStartLearning() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CharacterSelectionScreen(),
      ),
    );

    // Reload progress when returning from practice
    if (!mounted) return;
    final appState = context.read<AppState>();
    if (appState.selectedChild != null) {
      _loadProgressForChild(appState.selectedChild!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomPaint(
              painter: BubbleBackgroundPainter(),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildChildSelector(),
                      const SizedBox(height: 24),
                      if (_children.isEmpty)
                        _buildNoChildrenState()
                      else ...[
                        _buildProgressCard(),
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleAddChild,
        icon: const Icon(Icons.add),
        label: const Text('Add Child'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }

  Widget _buildChildSelector() {
    final appState = context.watch<AppState>();
    final selectedChild = appState.selectedChild;

    if (_children.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No children added yet',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Child',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _children.map((child) {
                final isSelected = selectedChild?.id == child.id;
                return GestureDetector(
                  onTap: () async {
                    appState.selectChild(child);
                    final gamService = context.read<GamificationService>();
                    gamService.setAccessToken(appState.accessToken);
                    await gamService.setChildId(child.id);
                    _loadProgressForChild(child);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryOrange.withValues(alpha: 0.15)
                          : AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryOrange
                            : const Color(0xFFE8E8E8),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          child.avatarEmoji ?? '👦',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          child.name,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppTheme.primaryOrange
                                : AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoChildrenState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text('👶', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'No Children Yet',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a child profile to start tracking\ntheir learning progress!',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final appState = context.watch<AppState>();
    final selectedChild = appState.selectedChild;

    if (selectedChild == null) return const SizedBox.shrink();

    if (_isLoadingProgress) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final progress = _selectedChildProgress;
    if (progress == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'No Practice Yet',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start practicing to see progress!',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  selectedChild.avatarEmoji ?? '👦',
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedChild.name}\'s Progress',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'Age ${selectedChild.age}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatRow('Level', '${progress.currentLevel}', '🏆'),
            const SizedBox(height: 16),
            _buildStatRow('Total XP', '${progress.totalXp}', '⭐'),
            const SizedBox(height: 16),
            _buildStatRow('Stars Earned', '${progress.totalStars}', '⭐'),
            const SizedBox(height: 16),
            _buildStatRow('Streak', '${progress.streakDays} days', '🔥'),
            if (progress.lastPracticeDate != null) ...[
              const SizedBox(height: 16),
              Text(
                'Last practiced: ${_formatDate(progress.lastPracticeDate!)}',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _handleStartLearning,
          icon: const Text('✏️', style: TextStyle(fontSize: 20)),
          label: const Text('Start Learning'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.accentGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
