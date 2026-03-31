import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/child_profile.dart';

class ChildrenService {
  static const _apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  Future<List<ChildProfile>> getChildren(String accessToken) async {
    try {
      final resp = await http.get(
        Uri.parse('$_apiBase/children'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('[ChildrenService] getChildren HTTP ${resp.statusCode}');
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final list = body['data'] as List<dynamic>? ?? [];
        return list
            .map((e) => ChildProfile.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ChildrenService] getChildren error: $e');
      return [];
    }
  }

  /// Returns the created [ChildProfile] or null on failure.
  Future<ChildProfile?> createChild({
    required String accessToken,
    required String name,
    required int age,
    required String avatarEmoji,
  }) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$_apiBase/children'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'child_name': name,
              'age': age,
              'avatar_url': avatarEmoji,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('[ChildrenService] createChild HTTP ${resp.statusCode}');
      if (resp.statusCode == 201) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        return ChildProfile.fromJson(body['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('[ChildrenService] createChild error: $e');
      return null;
    }
  }
}
