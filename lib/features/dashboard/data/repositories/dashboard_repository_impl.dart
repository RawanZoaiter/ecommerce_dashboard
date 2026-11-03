import '../../../../core/error/result.dart';
import '../../../../core/network/remote_support.dart';
import '../../../orders/data/datasources/order_remote_data_source.dart';
import '../../../orders/domain/entities/order_status.dart';
import '../../../products/data/datasources/product_remote_data_source.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Builds the home screen's figures from the list endpoints.
///
/// There is no `GET /admin/stats`, so each counter comes from a list call's
/// `meta.total` with `per_page: 1` — the rows are discarded and only the total
/// is kept. That is six small requests instead of one, which is exactly why the
/// aggregate endpoint was requested from the backend team.
class DashboardRepositoryImpl
    with RemoteSupport
    implements DashboardRepository {
  const DashboardRepositoryImpl(this._orders, this._products);

  final OrderRemoteDataSource _orders;
  final ProductRemoteDataSource _products;

  @override
  Future<Result<DashboardStats>> stats() {
    return guard(() async {
      // Issued together rather than one after another: six sequential round
      // trips would make the home screen several times slower to appear.
      final counts = await Future.wait(
        OrderStatus.values.map(_orders.countByStatus),
      );

      final productPage = await _products.products(page: 1, perPage: 1);
      final recent = await _orders.orders(page: 1, perPage: 5);

      return DashboardStats(
        ordersByStatus: {
          for (var i = 0; i < OrderStatus.values.length; i++)
            OrderStatus.values[i]: counts[i],
        },
        productCount: productPage.meta.total,
        recentOrders: recent.items,
      );
    });
  }
}
