import '../../../../core/error/result.dart';
import '../../../../core/mock/mock_seed.dart';
import '../../../../core/mock/mock_support.dart';
import '../../../../core/utils/money.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_status.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Sample-data implementation of [DashboardRepository].
///
/// The numbers are derived from the same seed the other screens read, so the
/// home page agrees with the orders table instead of showing invented totals.
class MockDashboardRepository with MockSupport implements DashboardRepository {
  @override
  Future<Result<DashboardStats>> stats() async {
    await settle();

    final orders = MockSeed.orders;

    final ordersByStatus = <OrderStatus, int>{
      for (final status in OrderStatus.values)
        status: orders.where((order) => order.status == status).length,
    };

    // Cancelled orders were never paid for, so they do not count as revenue.
    final earning = orders
        .where((order) => order.status != OrderStatus.cancelled)
        .map((order) => order.total);

    final lowStock = MockSeed.products.where((product) {
      final availability = product.availability;
      return availability is InStock &&
          (availability.isLow || availability.isSoldOut);
    }).length;

    return Ok(
      DashboardStats(
        ordersByStatus: ordersByStatus,
        revenue: Money.sum(earning),
        productCount: MockSeed.products.length,
        lowStockCount: lowStock,
        revenueByDay: _revenueByDay(orders),
        recentOrders: orders.take(5).toList(),
        inventoryReachable: true,
      ),
    );
  }

  /// Revenue for the last seven days, oldest first, so the chart reads
  /// left-to-right in English and is mirrored for Arabic by the layout.
  List<DailyRevenue> _revenueByDay(List<Order> orders) {
    final today = DateTime(
      MockSeed.now.year,
      MockSeed.now.month,
      MockSeed.now.day,
    );

    return List.generate(7, (offset) {
      final day = today.subtract(Duration(days: 6 - offset));
      final amounts = orders
          .where(
            (order) =>
                order.status != OrderStatus.cancelled &&
                order.createdAt != null &&
                _isSameDay(order.createdAt!, day),
          )
          .map((order) => order.total);
      return DailyRevenue(day: day, amount: Money.sum(amounts));
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
