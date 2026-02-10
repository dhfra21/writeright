// ML Inference Service - Handles pretrained model loading and inference
abstract class MLInferenceService {
  Future<void> loadModel();
  Future<HandwritingScore> evaluateHandwriting(String character, List<Point> strokes);
}

class HandwritingScore {
  final double similarity;
  final double correctness;
  final String feedback;

  HandwritingScore({
    required this.similarity,
    required this.correctness,
    required this.feedback,
  });
}

class Point {
  final double x;
  final double y;

  Point({required this.x, required this.y});
}
