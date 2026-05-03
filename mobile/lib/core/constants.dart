class AppConstants {
  static const String appName = 'NeuroSign';
  static const String appTagline = 'Bridging silence, connecting minds';

  // Override with --dart-define=API_BASE_URL=http://<host>:8000/api/v1 when needed.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const String recognizeFrameEndpoint = '/recognize/frame';
  static const String textToSignEndpoint = '/text-to-sign';
}
