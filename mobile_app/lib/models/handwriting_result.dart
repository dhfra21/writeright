// Handwriting evaluation result model
class HandwritingResult {
  final String character;
  final double score;
  final String feedback;
  final DateTime timestamp;

  HandwritingResult({
    required this.character,
    required this.score,
    required this.feedback,
    required this.timestamp,
  });
}
