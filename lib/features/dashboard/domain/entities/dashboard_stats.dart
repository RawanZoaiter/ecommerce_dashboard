import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_status.dart';

/// What the home screen shows.
///
/// Every field here is derived from an endpoint that actually exists. Revenue,
/// a low-stock count and a weekly trend were dropped rather than approximated:
/// there is no aggregate endpoint, the product list carries no quantity, and
/// summing one page of orders would print a number that looks authoritative
/// while being wrong. They come back when `GET /admin/stats` does.
class DashboardStats extends Equatable {
  const DashboardStats({
    required this.ordersByStatus,
    required this.productCount,
    required this.recentOrders,
  });

  /// One `meta.total` per status, read from `GET /orders?status=…`.
  final Map<OrderStatus, int> ordersByStatus;

  /// `meta.total` from `GET /products`.
  final int productCount;

  final List<Order> recentOrders;

  int get totalOrders =>
      ordersByStatus.values.fold(0, (sum, count) => sum + count);

  @override
  List<Object?> get props => [ordersByStatus, productCount, recentOrders];
}
