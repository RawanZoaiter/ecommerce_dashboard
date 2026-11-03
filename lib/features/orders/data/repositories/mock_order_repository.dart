import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/mock/mock_seed.dart';
import '../../../../core/mock/mock_support.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';

/// Sample-data implementation of [OrderRepository].
///
/// Status changes are applied to the in-memory list, and a move that the
/// transition table forbids returns the same [StatusTransitionFailure] the
/// server's 409 maps to — so the screen's error path is exercised even though
/// the UI should never offer that button in the first place.
class MockOrderRepository with MockSupport implements OrderRepository {
  final List<Order> _orders = [...MockSeed.orders];

  @override
  Future<Result<Paginated<Order>>> orders({
    int page = 1,
    int perPage = 15,
    OrderStatus? status,
  }) async {
    await settle();

    final filtered =
        (status == null
              ? _orders.toList()
              : _orders.where((order) => order.status == status).toList())
          ..sort((a, b) => b.id.compareTo(a.id));

    return Ok(paginate(filtered, page: page, perPage: perPage));
  }

  @override
  Future<Result<Order>> order(int id) async {
    await settle();
    final match = _orders.where((order) => order.id == id).firstOrNull;
    return match == null ? const Err(NotFoundFailure()) : Ok(match);
  }

  @override
  Future<Result<Order>> updateStatus({
    required int id,
    required OrderStatus status,
  }) async {
    await settle();

    final index = _orders.indexWhere((order) => order.id == id);
    if (index == -1) return const Err(NotFoundFailure());

    final current = _orders[index];
    if (!current.status.nextStates.contains(status)) {
      return Err(
        StatusTransitionFailure(
          debugMessage:
              'Cannot change order status from ${current.status.apiValue} '
              'to ${status.apiValue}.',
        ),
      );
    }

    final updated = Order(
      id: current.id,
      status: status,
      total: current.total,
      customer: current.customer,
      lines: current.lines,
      createdAt: current.createdAt,
    );
    _orders[index] = updated;
    return Ok(updated);
  }
}
