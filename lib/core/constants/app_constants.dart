class AppConstants {
  /// Characters available for practice (A-Z)
  static const List<String> practiceCharacters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  /// Canvas dimensions
  static const double canvasSize = 280.0;

  /// Claude Vision API endpoint
  static const String claudeApiUrl = 'https://api.anthropic.com/v1/messages';

  /// Claude model to use for handwriting evaluation
  static const String claudeModel = 'claude-sonnet-4-20250514';
}
