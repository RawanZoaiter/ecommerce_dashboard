/// Every path the dashboard knows about, relative to [AppConfig.apiBaseUrl].
///
/// Paths under "not built yet" are written down so the switch from mock to
/// live data is a one-line change per repository rather than a hunt through
/// the guide. They are documented in the frontend guide but not implemented
/// on the server, so nothing calls them yet.
abstract final class ApiEndpoints {
  // Health
  static const String appStatus = '/app-status';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String userInfo = '/auth/user-info';

  // Catalogue
  static const String categories = '/categories';
  static const String products = '/products';
  static String product(int id) => '/products/$id';

  // Orders
  static const String orders = '/orders';
  static String order(int id) => '/orders/$id';
  static String orderStatus(int id) => '/orders/$id/status';
  static String orderCancel(int id) => '/orders/$id/cancel';

  // --- Not built yet (frontend guide §7 and the open requests) ---

  /// Needs `GET /users` for admins, paginated like products and orders.
  static const String users = '/users';

  /// Guide §7: agreed with the backend team, still in progress.
  static const String notifications = '/notifications';
  static String notificationRead(int id) => '/notifications/$id/read';

  /// Requested: a Laravel-side write for stock. The dashboard must never talk
  /// to the inventory service directly — the guide is explicit that the
  /// frontend only ever speaks to Laravel.
  static String productStock(int id) => '/products/$id/stock';

  /// Requested: aggregate counters for the dashboard home, so the KPI cards
  /// do not have to be derived from five paginated list calls.
  static const String adminStats = '/admin/stats';
}
