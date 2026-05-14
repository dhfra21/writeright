import 'dart:math';
import 'dart:ui';
import 'letter_reference_paths.dart';

/// Evaluates handwriting quality by comparing the drawn strokes against a
/// normalized reference path using resampling + average Euclidean distance.
///
/// All computation is local and runs synchronously — no network required.
class DistanceBasedService {
  static const int _resampleCount = 64;

  /// Returns a score in [0, 100].
  /// Returns null if there are no strokes or no reference for the character.
  double? evaluate(String character, List<List<Offset>> strokes) {
    if (strokes.isEmpty) return null;

    final reference = LetterReferencePaths.getPath(character);
    if (reference.isEmpty) return null;

    final drawn = _flattenStrokes(strokes);
    if (drawn.length < 2) return null;

    final refResampled = _resample(reference, _resampleCount);
    final drawnResampled = _resample(drawn, _resampleCount);

    final normalized = _normalize(drawnResampled);
    final refNormalized = _normalize(refResampled);

    final distance = _averageDistance(normalized, refNormalized);

    // Map distance [0, 0.5] → score [100, 0].
    // A perfect match gives distance ≈ 0 → 100.
    // Distance ≥ 0.5 in normalized space is considered entirely wrong → 0.
    final score = (1.0 - (distance / 0.5).clamp(0.0, 1.0)) * 100.0;
    return score.clamp(0.0, 100.0);
  }

  List<Offset> _flattenStrokes(List<List<Offset>> strokes) {
    final points = <Offset>[];
    for (final stroke in strokes) {
      points.addAll(stroke);
    }
    return points;
  }

  /// Resamples a path to exactly [n] evenly-spaced points.
  List<Offset> _resample(List<Offset> points, int n) {
    if (points.length == 1) return List.filled(n, points[0]);

    final totalLength = _pathLength(points);
    final interval = totalLength / (n - 1);

    final result = <Offset>[points.first];
    double accumulated = 0.0;
    int i = 1;

    while (result.length < n && i < points.length) {
      final d = (points[i] - points[i - 1]).distance;
      if (accumulated + d >= interval) {
        final t = (interval - accumulated) / d;
        final q = Offset(
          points[i - 1].dx + t * (points[i].dx - points[i - 1].dx),
          points[i - 1].dy + t * (points[i].dy - points[i - 1].dy),
        );
        result.add(q);
        points.insert(i, q);
        accumulated = 0.0;
      } else {
        accumulated += d;
        i++;
      }
    }

    // Fill any remainder due to floating-point drift
    while (result.length < n) {
      result.add(points.last);
    }

    return result.sublist(0, n);
  }

  double _pathLength(List<Offset> points) {
    double len = 0;
    for (int i = 1; i < points.length; i++) {
      len += (points[i] - points[i - 1]).distance;
    }
    return len;
  }

  /// Translates and scales a path to fit in [0,1]×[0,1].
  List<Offset> _normalize(List<Offset> points) {
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;

    for (final p in points) {
      minX = min(minX, p.dx);
      minY = min(minY, p.dy);
      maxX = max(maxX, p.dx);
      maxY = max(maxY, p.dy);
    }

    final rangeX = maxX - minX;
    final rangeY = maxY - minY;
    final scale = max(rangeX, rangeY);

    if (scale == 0) return points;

    return points.map((p) => Offset(
      (p.dx - minX) / scale,
      (p.dy - minY) / scale,
    )).toList();
  }

  double _averageDistance(List<Offset> a, List<Offset> b) {
    double total = 0;
    for (int i = 0; i < a.length; i++) {
      total += (a[i] - b[i]).distance;
    }
    return total / a.length;
  }
}
