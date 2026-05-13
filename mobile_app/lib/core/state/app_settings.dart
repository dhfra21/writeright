import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted user preferences for the app.
/// Register as a ChangeNotifierProvider alongside AppState.
class AppSettings extends ChangeNotifier {
  static const _keyVoiceFeedback = 'setting_voice_feedback';
  static const _keyAiEvaluation = 'setting_ai_evaluation';
  static const _keyVoiceSpeed = 'setting_voice_speed';

  bool _voiceFeedbackEnabled = true;
  bool _aiEvaluationEnabled = true;
  double _voiceSpeed = 1.0; // 0.5 = slow, 1.0 = normal, 1.5 = fast

  bool get voiceFeedbackEnabled => _voiceFeedbackEnabled;
  bool get aiEvaluationEnabled => _aiEvaluationEnabled;
  double get voiceSpeed => _voiceSpeed;

  /// Call once at app startup (alongside AppState.init()).
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _voiceFeedbackEnabled = prefs.getBool(_keyVoiceFeedback) ?? true;
    _aiEvaluationEnabled = prefs.getBool(_keyAiEvaluation) ?? true;
    _voiceSpeed = prefs.getDouble(_keyVoiceSpeed) ?? 1.0;
    notifyListeners();
  }

  Future<void> setVoiceFeedback(bool value) async {
    _voiceFeedbackEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVoiceFeedback, value);
  }

  Future<void> setAiEvaluation(bool value) async {
    _aiEvaluationEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAiEvaluation, value);
  }

  Future<void> setVoiceSpeed(double value) async {
    _voiceSpeed = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyVoiceSpeed, value);
  }
}