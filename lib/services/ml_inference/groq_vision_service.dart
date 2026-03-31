import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'ml_inference_service.dart';

/// Groq Vision service using Llama 4 Scout Vision for handwriting feedback.
/// Supports both single-letter (Level 1) and full-word (Level 2) evaluation.
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
  /// Works for both single letters (Level 1) and words (Level 2).
  Future<VisionResult> evaluateFromImage({
    required String character,
    required List<int> imageBytes,
  }) async {
    if (_apiKey.isEmpty) {
      debugPrint('[GroqVision] ✗ API key is empty! '
          'Run with: flutter run --dart-define=GROQ_API_KEY=your_key_here');
      return _fallbackResult(character);
    }

    final base64Image = base64Encode(imageBytes);
    final isWord = character.length > 1;

    final requestBody = {
      'model': _model,
      'max_tokens': 500,
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
              'text': isWord
                  ? _buildWordPrompt(character)
                  : _buildLetterPrompt(character),
            },
          ],
        },
      ],
    };

    debugPrint('[GroqVision] >>> Sending evaluation for "${isWord ? "word" : "letter"}: $character"');
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
        return _fallbackResult(character);
      }
    } catch (e, stack) {
      debugPrint('[GroqVision] ✗ Network/exception error: $e');
      debugPrint('[GroqVision]   Stack: $stack');
      return _fallbackResult(character);
    }
  }

  // ─── Letter Prompt (Level 1 — unchanged logic) ──────────────────────────────

  String _buildLetterPrompt(String character) {
    return '''You are a handwriting teacher for young children (ages 4-8).
The child is practicing the letter "$character".

Step 1 — Identify: Look carefully at the drawing and determine which letter or shape was actually written.
Step 2 — Compare: Does it match the letter "$character"?
Step 3 — Score using this strict scale:
  - Blank or unrecognisable canvas → score: 0
  - Wrong letter entirely → score: 5-25
  - Correct letter but very hard to read (very shaky, broken, missing strokes) → score: 26-40
  - Correct letter, somewhat readable but poor proportions → score: 41-60
  - Correct letter, clearly readable with minor issues → score: 61-80
  - Correct letter, well-formed and nicely written → score: 81-100

Respond ONLY with this exact JSON (no extra text, no markdown):
{
  "identified_letter": "<letter/shape you see, or 'unclear' if blank>",
  "correct_letter": <true if matches "$character", else false>,
  "score": <0-100>,
  "feedback": "<one short sentence, max 15 words>",
  "detailed_feedback": "<2-3 sentences praising effort and pointing out what to improve>",
  "encouragement": "<motivating short phrase with emoji>",
  "tips": ["<specific tip 1>", "<specific tip 2>"]
}

Rules:
- Use simple words a 5-year-old understands.
- Always be kind and positive.
- If wrong letter: gently name the correct letter "$character".
- Be STRICT with scores — a wobbly, barely readable letter should NOT get above 50.
- Include fun emojis in encouragement.''';
  }

  // ─── Word Prompt (Level 2 — new) ─────────────────────────────────────────────

  String _buildWordPrompt(String word) {
    final letterCount = word.length;
    final letters = word.split('').join(', ');

    return '''You are a handwriting teacher for young children (ages 4-12).
The child is practicing writing the word "$word" ($letterCount letters: $letters).

IMPORTANT: The canvas has writing guidelines (a solid baseline and a dashed midline).

Step 1 — Read: Look very carefully at ALL the letters written on the canvas.
Step 2 — Compare letter by letter to "$word". 
Step 3 — Score using this STRICT scale:

  SCORE 0:
  - Canvas is blank or completely unreadable

  SCORE 5-20:
  - Completely wrong word, or only 1 out of $letterCount letters is correct
  - Random scribbles that don't form letters

  SCORE 21-40 (1-2 stars):
  - Some letters of "$word" are visible but most are wrong or backwards
  - Word is very hard to read
  - Letters are extremely shaky, overlapping, or way too big/small

  SCORE 41-60 (2-3 stars):
  - About half the letters of "$word" are correct and readable
  - Word is somewhat recognisable but has clear mistakes
  - Letters are inconsistent in size or spacing

  SCORE 61-75 (3-4 stars):
  - Most letters of "$word" are correct and readable
  - Word is recognisable with some imperfections
  - Letters stay mostly on the baseline

  SCORE 76-88 (4 stars):
  - All letters of "$word" are correct and clearly readable
  - Minor issues with size, spacing, or smoothness
  - Letters sit on the baseline well

  SCORE 89-100 (5 stars):
  - All letters of "$word" are correct, well-formed and neatly written
  - Consistent letter size and spacing
  - Letters sit on the baseline and respect the midline

Respond ONLY with this exact JSON (no extra text, no markdown):
{
  "identified_word": "<the word you actually read from the canvas, or 'unclear'>",
  "correct_word": <true if it matches "$word", else false>,
  "letters_correct": <how many letters out of $letterCount are correct, e.g. 2>,
  "score": <0-100>,
  "feedback": "<one short sentence max 15 words, name what letters were good or wrong>",
  "detailed_feedback": "<2-3 sentences: what they did well + what specific letters to fix>",
  "encouragement": "<motivating short phrase with emoji>",
  "tips": ["<specific handwriting tip 1>", "<specific handwriting tip 2>"]
}

Rules:
- Be STRICT. A barely readable word with shaky letters must NOT score above 50.
- A word with 1-2 wrong letters should score 40-65 depending on readability.
- Use simple words a child understands.
- Always be kind and encouraging even for low scores.
- Give SPECIFIC tips (e.g. "Make your letter A taller", not just "keep practicing").
- Include fun emojis in encouragement.''';
  }

  // ─── Response Parser ──────────────────────────────────────────────────────────

  VisionResult _parseResponse(Map<String, dynamic> data, String character) {
    try {
      final content = data['choices'][0]['message']['content'] as String;
      debugPrint('[GroqVision]     Raw text content: $content');

      // Strip markdown code blocks if present
      String jsonStr = content;
      if (content.contains('{')) {
        jsonStr = content.substring(
          content.indexOf('{'),
          content.lastIndexOf('}') + 1,
        );
      }
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

      final isWord = character.length > 1;

      // ── Word result ──
      if (isWord) {
        final identifiedWord =
            parsed['identified_word'] as String? ?? 'unclear';
        final correctWord = parsed['correct_word'] as bool? ?? false;
        final lettersCorrect = parsed['letters_correct'] as int? ?? 0;
        var score = (parsed['score'] as num).toDouble();

        // Safety clamp: if word is wrong but score is suspiciously high
        if (!correctWord && score > 65) {
          debugPrint('[GroqVision] ⚠ Wrong word "$identifiedWord" '
              'but score $score is too high — clamping to 40.');
          score = 40.0;
        }

        // Safety clamp: if no letters correct, score can't be above 20
        if (lettersCorrect == 0 && score > 20) {
          score = 15.0;
        }

        final result = VisionResult(
          score: HandwritingScore(
            similarity: score / 100.0,
            correctness: score / 100.0,
            feedback: parsed['feedback'] as String? ?? 'Great effort!',
          ),
          detailedFeedback: parsed['detailed_feedback'] as String? ?? '',
          encouragement: parsed['encouragement'] as String? ?? 'Keep going! ⭐',
          tips: List<String>.from(parsed['tips'] as List? ?? []),
        );

        debugPrint('[GroqVision] ✓ Word result for "$character":');
        debugPrint('[GroqVision]   identified  : $identifiedWord');
        debugPrint('[GroqVision]   correct     : $correctWord');
        debugPrint('[GroqVision]   letters ok  : $lettersCorrect / ${character.length}');
        debugPrint('[GroqVision]   score       : $score / 100');
        debugPrint('[GroqVision]   encouragement: ${result.encouragement}');
        debugPrint('[GroqVision]   tips        : ${result.tips}');

        return result;
      }

      // ── Letter result (Level 1 — unchanged) ──
      final identifiedLetter =
          parsed['identified_letter'] as String? ?? 'unclear';
      final correctLetter = parsed['correct_letter'] as bool? ?? false;
      var score = (parsed['score'] as num).toDouble();

      if (!correctLetter && score > 30) {
        debugPrint('[GroqVision] ⚠ Wrong letter "$identifiedLetter" '
            'but score $score — clamping to 20.');
        score = 20.0;
      }

      final result = VisionResult(
        score: HandwritingScore(
          similarity: score / 100.0,
          correctness: score / 100.0,
          feedback: parsed['feedback'] as String? ?? 'Great effort!',
        ),
        detailedFeedback: parsed['detailed_feedback'] as String? ?? '',
        encouragement: parsed['encouragement'] as String? ?? 'Keep going! ⭐',
        tips: List<String>.from(parsed['tips'] as List? ?? []),
      );

      debugPrint('[GroqVision] ✓ Letter result for "$character":');
      debugPrint('[GroqVision]   identified  : $identifiedLetter');
      debugPrint('[GroqVision]   correct     : $correctLetter');
      debugPrint('[GroqVision]   score       : $score / 100');
      debugPrint('[GroqVision]   encouragement: ${result.encouragement}');
      debugPrint('[GroqVision]   tips        : ${result.tips}');

      return result;
    } catch (e, stack) {
      debugPrint('[GroqVision] ✗ Failed to parse response: $e');
      debugPrint('[GroqVision]   Stack: $stack');
      return _fallbackResult(character);
    }
  }

  VisionResult _fallbackResult(String character) {
    final isWord = character.length > 1;
    return VisionResult(
      score: HandwritingScore(
        similarity: 0.5,
        correctness: 0.5,
        feedback: isWord
            ? 'Nice try! Keep practicing your word!'
            : 'Nice try! Keep practicing!',
      ),
      detailedFeedback: 'You are learning well. Practice makes perfect!',
      encouragement: 'You are a writing superstar! ⭐',
      tips: [
        isWord
            ? 'Try writing each letter slowly one at a time.'
            : 'Try to trace the guide letter slowly.',
      ],
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
