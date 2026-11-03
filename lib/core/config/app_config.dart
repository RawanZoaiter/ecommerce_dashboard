abstract final class AppConfig {
  /// Override at build time:
  /// `flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.5:8080/api`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// §5.8: the API caps `per_page` at 50.
  static const int maxPerPage = 50;
  static const int defaultPerPage = 15;
}
