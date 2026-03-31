import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Typecast cloud TTS — expressive, enthusiastic female voice.
///
/// Endpoint: POST https://api.typecast.ai/v1/text-to-speech
///   Auth:    X-API-KEY header
///   Returns: binary WAV on 200, JSON error on 4xx/5xx.
class TtsService {
  static const _apiKey = String.fromEnvironment('TYPECAST_API_KEY');

  static const _baseUrl = 'https://api.typecast.ai/v1';
  static const _voiceId = 'tc_63c76c7474190a31f3d02cc3';

  final AudioPlayer _player = AudioPlayer();

  /// Cached model name resolved at first speak() call.
  String? _model;

  // ── Model resolution ──────────────────────────────────────────────────────

  /// Fetches the first supported model for [_voiceId] from GET /v1/voices.
  /// Falls back to 'ssfm-v21' if the lookup fails.
  Future<String> _resolveModel() async {
    if (_model != null) return _model!;

    try {
      final resp = await http
          .get(
            Uri.parse('$_baseUrl/voices'),
            headers: {'X-API-KEY': _apiKey},
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('[TTS-Typecast] /voices response: ${resp.statusCode}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        // Response may be a list or {"voices": [...]}
        final list = data is List ? data : (data['voices'] as List? ?? []);

        for (final v in list) {
          if ((v['voice_id'] ?? v['id']) == _voiceId) {
            final models = (v['models'] as List?)?.cast<String>() ?? [];
            debugPrint('[TTS-Typecast] voice models: $models');
            if (models.isNotEmpty) {
              _model = models.first;
              return _model!;
            }
          }
        }
        debugPrint('[TTS-Typecast] voice not found in list — trying ssfm-v21');
      } else {
        debugPrint('[TTS-Typecast] /voices error: ${resp.body}');
      }
    } catch (e) {
      debugPrint('[TTS-Typecast] model resolve error: $e');
    }

    _model = 'ssfm-v21'; // safe fallback
    return _model!;
  }

  // ── Speak ─────────────────────────────────────────────────────────────────

  Future<void> speak(String text) async {
    try {
      await _player.stop();

      final model = await _resolveModel();

      final body = jsonEncode({
        'voice_id': _voiceId,
        'text': text,
        'model': model,
        'language': 'eng',
        'output': {
          'audio_format': 'wav',
          'audio_tempo': 0.9,
          'volume': 100,
        },
      });

      debugPrint('[TTS-Typecast] Requesting (model=$model): "${text.length > 60 ? "${text.substring(0, 60)}…" : text}"');

      final resp = await http
          .post(
            Uri.parse('$_baseUrl/text-to-speech'),
            headers: {
              'X-API-KEY': _apiKey,
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (resp.statusCode == 200) {
        await _player.play(BytesSource(resp.bodyBytes));
        debugPrint('[TTS-Typecast] Playing ${resp.bodyBytes.length} bytes');
      } else {
        debugPrint('[TTS-Typecast] HTTP ${resp.statusCode}: ${resp.body}');
        // If this model also fails, reset so next call retries lookup
        _model = null;
      }
    } catch (e) {
      debugPrint('[TTS-Typecast] Speak error: $e');
    }
  }

  // ── Stop / Dispose ────────────────────────────────────────────────────────

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('[TTS-Typecast] Stop error: $e');
    }
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
