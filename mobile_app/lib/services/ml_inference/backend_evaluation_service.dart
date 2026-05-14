import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import 'groq_vision_service.dart';
import 'ml_inference_service.dart';

/// Calls the backend POST /api/v1/evaluate endpoint, which proxies the request
/// to Groq Vision and returns a structured evaluation result.
class BackendEvaluationService {
  final http.Client _client;

  BackendEvaluationService({http.Client? client})
      : _client = client ?? http.Client();

  /// Sends [imageBytes] (PNG) to the backend and returns a [VisionResult].
  /// [character] is the target letter, word, or sentence.
  /// [exerciseType] is one of: "letter", "word", "sentence".
  Future<VisionResult> evaluate({
    required String character,
    required List<int> imageBytes,
    String exerciseType = 'letter',
  }) async {
    final base64Image = base64Encode(imageBytes);

    debugPrint('[BackendEval] POST ${AppConstants.evaluateEndpoint} — character="$character" exerciseType=$exerciseType');

    final response = await _client.post(
      Uri.parse(AppConstants.evaluateEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'character': character,
        'imageBase64': base64Image,
        'exerciseType': exerciseType,
      }),
    );

    debugPrint('[BackendEval] HTTP ${response.statusCode}');

    if (response.statusCode == 429) {
      throw const GroqRateLimitException();
    }

    if (response.statusCode != 200) {
      debugPrint('[BackendEval] Error body: ${response.body}');
      return _fallback();
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      debugPrint('[BackendEval] success=false: ${body['error']}');
      return _fallback();
    }

    return _parse(body['data'] as Map<String, dynamic>);
  }

  VisionResult _parse(Map<String, dynamic> data) {
    final score = (data['score'] as num).toDouble();
    return VisionResult(
      score: HandwritingScore(
        similarity: score / 100.0,
        correctness: score / 100.0,
        feedback: data['feedback'] as String? ?? 'Nice try!',
      ),
      detailedFeedback: data['detailed_feedback'] as String? ?? '',
      encouragement: data['encouragement'] as String? ?? 'Keep going! ⭐',
      tips: List<String>.from(data['tips'] as List? ?? []),
    );
  }

  VisionResult _fallback() {
    return VisionResult(
      score: HandwritingScore(
        similarity: 0.5,
        correctness: 0.5,
        feedback: 'Nice try! Keep practicing!',
      ),
      detailedFeedback: 'You are learning well. Practice makes perfect!',
      encouragement: 'You are a writing superstar! ⭐',
      tips: ['Try to trace the guide letter slowly.'],
    );
  }
}
