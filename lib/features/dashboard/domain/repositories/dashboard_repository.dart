import '../../../../core/error/result.dart';
import '../entities/dashboard_stats.dart';

abstract interface class DashboardRepository {
  /// Everything the home screen needs, in one call.
  ///
  /// Maps onto `GET /admin/stats` once that exists. Without it, a live
  /// implementation has to fan out across the paginated order lists and read
  /// `meta.total` from each, which is why the endpoint was requested.
  Future<Result<DashboardStats>> stats();
}
