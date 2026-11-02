import '../../../../core/error/result.dart';
import '../../../../core/network/api_response.dart';
import '../entities/order.dart';
import '../entities/order_status.dart';

abstract interface class OrderRepository {
  /// `GET /orders`. An admin token returns every customer's orders.
  Future<Result<Paginated<Order>>> orders({
    int page,
    int perPage,
    OrderStatus? status,
  });

  /// `GET /orders/{id}`.
  Future<Result<Order>> order(int id);

  /// `PATCH /orders/{id}/status`. Admin only, and only along the transitions
  /// in [OrderStatus.nextStates] — anything else answers 409.
  Future<Result<Order>> updateStatus({
    required int id,
    required OrderStatus status,
  });
}
