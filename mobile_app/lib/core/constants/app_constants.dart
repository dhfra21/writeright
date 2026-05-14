class AppConstants {
  /// Characters available for practice (A-Z)
  static const List<String> practiceCharacters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  /// Canvas dimensions
  static const double canvasSize = 280.0;

  /// Backend evaluate endpoint (set via --dart-define=BACKEND_URL=https://...)
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static String get evaluateEndpoint => '$backendBaseUrl/api/v1/evaluate';
}
