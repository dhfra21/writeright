// Distance-based handwriting evaluation (No ML model required)
// Uses Dynamic Time Warping (DTW) for stroke similarity
// Good fallback or MVP solution

import 'ml_inference_service.dart';
import 'dart:math' as math;

/// Distance-based service that doesn't require an ML model
/// Uses mathematical distance metrics for similarity calculation
class DistanceBasedService implements MLInferenceService {
  // Reference templates for each character
  final Map<String, List<List<Point>>> _templates = {};

  @override
  Future<void> loadModel() async {
    // No model to load, but we can load reference templates here
    // Templates would be pre-defined stroke sequences for each character
    _initializeTemplates();
  }

  @override
  Future<HandwritingScore> evaluateHandwriting(
    String character,
    List<Point> strokes,
  ) async {
    // Normalize the input strokes
    final normalizedStrokes = _normalizeStrokes(strokes);
    
    // Get reference template for this character
    final template = _templates[character.toLowerCase()];
    
    if (template == null || template.isEmpty) {
      return HandwritingScore(
        similarity: 0.5,
        correctness: 0.5,
        feedback: 'Character template not available',
      );
    }

    // Calculate similarity using Dynamic Time Warping
    final similarity = _calculateDTWSimilarity(normalizedStrokes, template[0]);
    
    // Calculate correctness based on similarity
    final correctness = _calculateCorrectness(similarity);
    
    // Generate feedback
    final feedback = _generateFeedback(similarity, correctness);

    return HandwritingScore(
      similarity: similarity,
      correctness: correctness,
      feedback: feedback,
    );
  }

  /// Normalize strokes to a standard size and position
  List<Point> _normalizeStrokes(List<Point> strokes) {
    if (strokes.isEmpty) return strokes;

    // Find bounding box
    double minX = strokes[0].x;
    double maxX = strokes[0].x;
    double minY = strokes[0].y;
    double maxY = strokes[0].y;

    for (final point in strokes) {
      minX = math.min(minX, point.x);
      maxX = math.max(maxX, point.x);
      minY = math.min(minY, point.y);
      maxY = math.max(maxY, point.y);
    }

    final width = maxX - minX;
    final height = maxY - minY;
    final maxDim = math.max(width, height);

    if (maxDim == 0) return strokes;

    // Normalize to 0-100 range and center
    final normalized = strokes.map((point) {
      final normalizedX = ((point.x - minX) / maxDim) * 100;
      final normalizedY = ((point.y - minY) / maxDim) * 100;
      return Point(x: normalizedX, y: normalizedY);
    }).toList();

    return normalized;
  }

  /// Calculate similarity using Dynamic Time Warping
  double _calculateDTWSimilarity(List<Point> sequence1, List<Point> sequence2) {
    if (sequence1.isEmpty || sequence2.isEmpty) return 0.0;

    final n = sequence1.length;
    final m = sequence2.length;

    // Create DTW matrix
    final dtw = List.generate(
      n + 1,
      (_) => List.filled(m + 1, double.infinity),
    );

    dtw[0][0] = 0.0;

    // Fill DTW matrix
    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        final cost = _euclideanDistance(sequence1[i - 1], sequence2[j - 1]);
        dtw[i][j] = cost +
            math.min(
              math.min(dtw[i - 1][j], dtw[i][j - 1]),
              dtw[i - 1][j - 1],
            );
      }
    }

    // Normalize by path length
    final pathLength = math.max(n, m);
    final normalizedDistance = dtw[n][m] / pathLength;

    // Convert distance to similarity (0.0 - 1.0)
    // Lower distance = higher similarity
    final maxDistance = 100.0; // Approximate max distance for normalized points
    final similarity = math.max(0.0, 1.0 - (normalizedDistance / maxDistance));

    return similarity.clamp(0.0, 1.0);
  }

  /// Calculate Euclidean distance between two points
  double _euclideanDistance(Point p1, Point p2) {
    final dx = p1.x - p2.x;
    final dy = p1.y - p2.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Calculate correctness score from similarity
  double _calculateCorrectness(double similarity) {
    // Map similarity to correctness with some threshold
    if (similarity >= 0.8) return 1.0;
    if (similarity >= 0.6) return 0.7;
    if (similarity >= 0.4) return 0.5;
    return 0.3;
  }

  /// Generate user-friendly feedback
  String _generateFeedback(double similarity, double correctness) {
    if (similarity >= 0.8) {
      return 'Excellent! Great job! 🌟';
    } else if (similarity >= 0.6) {
      return 'Good! Keep practicing! 👍';
    } else if (similarity >= 0.4) {
      return 'Not bad! Try to match the shape better.';
    } else {
      return 'Keep trying! Follow the template more closely.';
    }
  }

  /// Initialize reference templates for characters
  /// In a real app, these would be loaded from assets or generated
  void _initializeTemplates() {
    // Example: Simple templates for basic characters
    // In production, load from ml_models/templates/ directory
    
    // Example template for letter 'A' (simplified)
    _templates['a'] = [
      [
        Point(x: 50, y: 90), // Start at bottom left
        Point(x: 50, y: 10), // Up to top
        Point(x: 90, y: 10), // Across to right
        Point(x: 70, y: 50), // Down to middle
        Point(x: 30, y: 50), // Across to left
      ],
    ];
    
    // Add more templates as needed
    // In production, these should be loaded from template files
  }
}
