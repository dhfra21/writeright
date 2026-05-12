import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'ml_inference_service.dart';

/// Groq Vision service using Llama 3.2 Vision for handwriting feedback.
/// Uses Groq's OpenAI-compatible API endpoint (free tier).
class GroqVisionService implements MLInferenceService {
  final String _apiKey;
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'meta-llama/llama-4-scout-17b-16e-instruct';

  GroqVisionService({required String apiKey}) : _apiKey = apiKey;

  @override
  Future<void> loadModel() async {
    // No model to load — Groq is a cloud API
  }

  @override
  Future<HandwritingScore> evaluateHandwriting(
    String character,
    List<Point> strokes,
  ) async {
    // Stroke-based evaluation not supported — use evaluateFromImage() instead.
    return HandwritingScore(
      similarity: 0.0,
      correctness: 0.0,
      feedback: 'Use evaluateFromImage for Groq Vision evaluation.',
    );
  }

  /// Sends a canvas PNG to Groq (Llama Vision) and returns rich feedback.
  Future<VisionResult> evaluateFromImage({
    required String character,
    required List<int> imageBytes,
  }) async {
    if (_apiKey.isEmpty) {
      debugPrint('[GroqVision] ✗ API key is empty! '
          'Run with: flutter run --dart-define=GROQ_API_KEY=your_key_here');
      return _fallbackResult();
    }

    final base64Image = base64Encode(imageBytes);

    final requestBody = {
      'model': _model,
      'max_tokens': 400,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/png;base64,$base64Image',
              },
            },
            {
              'type': 'text',
              'text': _buildPrompt(character),
            },
          ],
        },
      ],
    };

    debugPrint('[GroqVision] >>> Sending evaluation request for "$character"');
    debugPrint('[GroqVision]     Image size: ${imageBytes.length} bytes');
    debugPrint('[GroqVision]     Model: $_model');

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('[GroqVision] <<< HTTP ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('[GroqVision]     Raw response body:');
        debugPrint(response.body);
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseResponse(data, character);
      } else {
        debugPrint('[GroqVision] ✗ Non-200 status. Response body:');
        debugPrint(response.body);
        return _fallbackResult();
      }
    } catch (e, stack) {
      debugPrint('[GroqVision] ✗ Network/exception error: $e');
      debugPrint('[GroqVision]   Stack: $stack');
      return _fallbackResult();
    }
  }

  String _buildPrompt(String character) {
    return '''You are a handwriting teacher for young children (ages 4-8).
The child is practicing the letter "$character".

Step 1 — Identify: Look carefully at the drawing and determine which letter or shape was actually written.
Step 2 — Compare: Does it match the letter "$character"?
Step 3 — Score:
  - If the drawing does NOT look like "$character" → score MUST be 0-30. Tell the child kindly that they wrote the wrong letter and ask them to try "$character" again.
  - If the drawing IS "$character" (even roughly) → score 50-100 based on how well formed it is.

Respond ONLY with this exact JSON object, no extra text:
{
  "identified_letter": "<the letter/shape you actually see, or 'unclear' if blank/unrecognisable>",
  "correct_letter": <true if identified_letter matches "$character", else false>,
  "score": <0-100>,
  "feedback": "<one short sentence, max 15 words>",
  "detailed_feedback": "<2-3 sentences>",
  "encouragement": "<motivating phrase with emoji>",
  "tips": ["<tip 1>", "<tip 2>"]
}

Additional rules:
- Use simple words a 5-year-old can understand.
- Always be kind and positive, even when the wrong letter is written.
- If wrong letter: feedback must clearly but gently name the correct letter "$character".
- Include fun emojis in encouragement.''';
  }


  Future<VisionResult> evaluateFromImageSentence({
    required String word,
    required String sentence,
    required List<int> imageBytes,
  }) async {
    if (_apiKey.isEmpty) return _fallbackResult();

    final base64Image = base64Encode(imageBytes);

    final requestBody = {
      'model': _model,
      'max_tokens': 400,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/png;base64,$base64Image',
              },
            },
            {
              'type': 'text',
              'text': _buildSentencePrompt(word, sentence),
            },
          ],
        },
      ],
    };

    debugPrint('[GroqVision] >>> Sentence evaluation for "$word" in "$sentence"');

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('[GroqVision] <<< HTTP ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseResponse(data, word);
      } else {
        debugPrint('[GroqVision] ✗ Non-200: ${response.body}');
        return _fallbackResult();
      }
    } catch (e, stack) {
      debugPrint('[GroqVision] ✗ Error: $e\n$stack');
      return _fallbackResult();
    }
  }

  String _buildSentencePrompt(String word, String sentence) {
    return '''You are a handwriting teacher for young children (ages 4-8).
The child is completing a fill-in-the-blank sentence.
 
Sentence: "$sentence"
The correct missing word is: "$word"
 
The child has written their answer on the canvas. Your job is to:
Step 1 — Read: Look at the handwritten word on the canvas.
Step 2 — Compare: Does it match "$word"?
Step 3 — Score:
  - If the word does NOT match "$word" → score 0-30. Kindly tell the child the correct answer is "$word".
  - If the word matches "$word" (even roughly written) → score 50-100 based on how legible it is.
 
Respond ONLY with this exact JSON object, no extra text:
{
  "identified_letter": "<the word you see written, or 'unclear'>",
  "correct_letter": <true if it matches "$word", else false>,
  "score": <0-100>,
  "feedback": "<one short sentence, max 15 words>",
  "detailed_feedback": "<2-3 sentences>",
  "encouragement": "<motivating phrase with emoji>",
  "tips": ["<tip 1>", "<tip 2>"]
}
 
Rules:
- Use simple words a 5-year-old understands.
- Always be kind and positive.
- If wrong: gently tell them the answer is "$word".
- Include fun emojis in encouragement.''';
  }

  VisionResult _parseResponse(Map<String, dynamic> data, String character) {
    try {
      final content =
          data['choices'][0]['message']['content'] as String;
      debugPrint('[GroqVision]     Raw text content: $content');

      // Extract JSON (handle markdown code blocks)
      String jsonStr = content;
      if (content.contains('{')) {
        jsonStr = content.substring(
          content.indexOf('{'),
          content.lastIndexOf('}') + 1,
        );
      }
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

      final identifiedLetter = parsed['identified_letter'] as String? ?? 'unclear';
      final correctLetter = parsed['correct_letter'] as bool? ?? false;
      var score = (parsed['score'] as num).toDouble();

      // Safety net: if model says wrong letter but gave a high score, clamp it.
      if (!correctLetter && score > 30) {
        debugPrint('[GroqVision] ⚠ Model flagged wrong letter "$identifiedLetter" '
            'but gave score $score — clamping to 20.');
        score = 20.0;
      }

      final result = VisionResult(
        score: HandwritingScore(
          similarity: score / 100.0,
          correctness: score / 100.0,
          feedback: parsed['feedback'] as String? ?? 'Great effort!',
        ),
        detailedFeedback: parsed['detailed_feedback'] as String? ?? '',
        encouragement: parsed['encouragement'] as String? ?? 'Keep going!',
        tips: List<String>.from(parsed['tips'] as List? ?? []),
      );

      debugPrint('[GroqVision] ✓ Parsed result for "$character":');
      debugPrint('[GroqVision]   identified  : $identifiedLetter');
      debugPrint('[GroqVision]   correct     : $correctLetter');
      debugPrint('[GroqVision]   score       : $score / 100');
      debugPrint('[GroqVision]   encouragement: ${result.encouragement}');
      debugPrint('[GroqVision]   feedback    : ${result.score.feedback}');
      debugPrint('[GroqVision]   detailed    : ${result.detailedFeedback}');
      debugPrint('[GroqVision]   tips        : ${result.tips}');

      return result;
    } catch (e, stack) {
      debugPrint('[GroqVision] ✗ Failed to parse response: $e');
      debugPrint('[GroqVision]   Stack: $stack');
      return _fallbackResult();
    }
  }

  VisionResult _fallbackResult() {
    return VisionResult(
      score: HandwritingScore(
        similarity: 0.5,
        correctness: 0.5,
        feedback: 'Nice try! Keep practicing!',
      ),
      detailedFeedback: 'You are learning well. Practice makes perfect!',
      encouragement: 'You are a writing superstar! \u2b50',
      tips: ['Try to trace the guide letter slowly.'],
    );
  }
}

/// Result from Groq/Llama Vision with rich child-friendly feedback.
class VisionResult {
  final HandwritingScore score;
  final String detailedFeedback;
  final String encouragement;
  final List<String> tips;

  VisionResult({
    required this.score,
    required this.detailedFeedback,
    required this.encouragement,
    required this.tips,
  });
}
