abstract final class Routes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static const String products = '/products';
  static const String newProduct = '/products/new';
  static String productDetails(int id) => '/products/$id';

  static const String orders = '/orders';
  static String orderDetails(int id) => '/orders/$id';
}
