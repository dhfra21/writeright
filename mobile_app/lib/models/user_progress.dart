// User progress data model
class UserProgress {
  final String userId;
  final int level;
  final int xp;
  final Map<String, int> starsPerCharacter;
  final List<String> unlockedBadges;

  UserProgress({
    required this.userId,
    required this.level,
    required this.xp,
    required this.starsPerCharacter,
    required this.unlockedBadges,
  });
}
