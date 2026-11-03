import 'package:equatable/equatable.dart';

import '../../../../core/utils/money.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_status.dart';

class DailyRevenue extends Equatable {
  const DailyRevenue({required this.day, required this.amount});

  final DateTime day;
  final Money amount;

  @override
  List<Object?> get props => [day, amount];
}

/// Everything the home screen shows.
///
/// There is no aggregate endpoint yet. Once `GET /admin/stats` exists this maps
/// straight onto it; until then the live implementation would have to derive
/// the counters from the paginated order lists, which is why the request was
/// raised with the backend team.
class DashboardStats extends Equatable {
  const DashboardStats({
    required this.ordersByStatus,
    required this.revenue,
    required this.productCount,
    required this.lowStockCount,
    required this.revenueByDay,
    required this.recentOrders,
    required this.inventoryReachable,
  });

  final Map<OrderStatus, int> ordersByStatus;
  final Money revenue;
  final int productCount;

  /// Products at or below the low-stock threshold. Cannot be computed from the
  /// product list endpoint today, because it carries no quantity.
  final int lowStockCount;

  final List<DailyRevenue> revenueByDay;
  final List<Order> recentOrders;

  /// Drives the warning banner. Comes from a health check rather than from
  /// guessing at a null quantity.
  final bool inventoryReachable;

  int get totalOrders =>
      ordersByStatus.values.fold(0, (sum, count) => sum + count);

  @override
  List<Object?> get props => [
    ordersByStatus,
    revenue,
    productCount,
    lowStockCount,
    revenueByDay,
    recentOrders,
    inventoryReachable,
  ];
}
