import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../screens/parent_dashboard_screen.dart';

class ProgressService {
  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  /// Fetches game progress for a specific child.
  /// Returns null if progress doesn't exist or on error.
  Future<GameProgress?> getGameProgress(
    String accessToken,
    String childId,
  ) async {
    try {
      final resp = await http.get(
        Uri.parse('$_apiBase/progress/$childId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('[ProgressService] getGameProgress for child $childId - HTTP ${resp.statusCode}');
      debugPrint('[ProgressService] Response: ${resp.body}');

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        if (data != null) {
          debugPrint('[ProgressService] Progress data: $data');
          return GameProgress.fromJson(data);
        }
      } else {
        debugPrint('[ProgressService] Error response: ${resp.body}');
      }
      return null;
    } catch (e) {
      debugPrint('[ProgressService] getGameProgress error: $e');
      return null;
    }
  }

  /// Fetches character mastery data for a specific child.
  Future<List<CharacterMastery>> getCharacterMastery(
    String accessToken,
    String childId,
  ) async {
    try {
      final resp = await http.get(
        Uri.parse('$_apiBase/progress/$childId/character-mastery'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('[ProgressService] getCharacterMastery HTTP ${resp.statusCode}');

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final list = body['data'] as List<dynamic>? ?? [];
        return list
            .map((e) => CharacterMastery.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ProgressService] getCharacterMastery error: $e');
      return [];
    }
  }
}

/// Model for character mastery data
class CharacterMastery {
  final String characterType;
  final String characterValue;
  final int practiceCount;
  final double averageScore;
  final double bestScore;
  final String masteryLevel;

  const CharacterMastery({
    required this.characterType,
    required this.characterValue,
    required this.practiceCount,
    required this.averageScore,
    required this.bestScore,
    required this.masteryLevel,
  });

  factory CharacterMastery.fromJson(Map<String, dynamic> json) {
    return CharacterMastery(
      characterType: json['character_type'] as String,
      characterValue: json['character_value'] as String,
      practiceCount: (json['practice_count'] as num?)?.toInt() ?? 0,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      bestScore: (json['best_score'] as num?)?.toDouble() ?? 0.0,
      masteryLevel: json['mastery_level'] as String? ?? 'beginner',
    );
  }
}
