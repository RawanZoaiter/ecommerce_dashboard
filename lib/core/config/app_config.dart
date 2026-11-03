abstract final class AppConfig {
  /// Override at build time:
  /// `flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.5:8080/api`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  /// Generous on purpose.
  ///
  /// The development backend runs from a Windows bind mount, where PHP reads
  /// hundreds of files per request: measured about 6 seconds for even
  /// `/app-status`. A browser also sends a CORS preflight before any JSON
  /// POST, so signing in costs two round trips — roughly 14 seconds measured.
  /// A tighter limit cuts a request that was going to succeed and reports it
  /// as if the server were unreachable.
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// §5.8: the API caps `per_page` at 50.
  static const int maxPerPage = 50;
  static const int defaultPerPage = 15;
}
