import '../../../../core/config/app_config.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/remote_support.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl with RemoteSupport implements OrderRepository {
  const OrderRepositoryImpl(this._remote);

  final OrderRemoteDataSource _remote;

  @override
  Future<Result<Paginated<Order>>> orders({
    int page = 1,
    int perPage = AppConfig.defaultPerPage,
    OrderStatus? status,
  }) {
    return guard(
      () => _remote.orders(page: page, perPage: perPage, status: status),
    );
  }

  @override
  Future<Result<Order>> order(int id) => guard(() => _remote.order(id));

  @override
  Future<Result<Order>> updateStatus({
    required int id,
    required OrderStatus status,
  }) {
    return guard(() => _remote.updateStatus(id: id, status: status));
  }
}
