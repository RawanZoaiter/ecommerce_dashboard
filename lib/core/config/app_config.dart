/// Where repositories read their data from.
///
/// The UI is written against repository interfaces only, so flipping this
/// changes the whole dashboard from sample data to the live API without
/// touching a single screen.
enum DataSource { mock, live }

abstract final class AppConfig {
  /// Override at build time:
  /// `flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.5:8080/api`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  /// Flip to `live` (or pass `--dart-define=DATA_SOURCE=live`) once the
  /// backend is reachable. Everything needed for that already exists under
  /// `core/network`; only the bindings in `core/di/injector.dart` change.
  static const DataSource dataSource = bool.fromEnvironment('USE_LIVE_API')
      ? DataSource.live
      : DataSource.mock;

  static bool get usesMockData => dataSource == DataSource.mock;

  /// §4 of the frontend guide: access tokens last 60 minutes.
  static const Duration accessTokenLifetime = Duration(minutes: 60);

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Creating an order can sit for up to 3s while Laravel waits on the
  /// inventory service before giving up with a 503, so this one request needs
  /// a longer ceiling than the rest.
  static const Duration orderSendTimeout = Duration(seconds: 15);

  /// §5.8: the API caps `per_page` at 50.
  static const int maxPerPage = 50;
  static const int defaultPerPage = 15;

  /// Artificial latency for mock repositories, so loading and empty states
  /// are actually visible while building the UI.
  static const Duration mockLatency = Duration(milliseconds: 450);
}
