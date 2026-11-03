import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';

enum OrderDetailsStatus { initial, loading, loaded, failure }

class OrderDetailsState extends Equatable {
  const OrderDetailsState({
    this.status = OrderDetailsStatus.initial,
    this.order,
    this.failure,
    this.isUpdating = false,
    this.updateFailure,
  });

  final OrderDetailsStatus status;
  final Order? order;
  final Failure? failure;

  /// A status change in progress. Kept apart from [status] so the page keeps
  /// showing the order while its buttons are disabled, rather than collapsing
  /// back to a skeleton.
  final bool isUpdating;

  /// A failed status change, reported without discarding the loaded order.
  final Failure? updateFailure;

  OrderDetailsState copyWith({
    OrderDetailsStatus? status,
    Order? order,
    Failure? failure,
    bool? isUpdating,
    Failure? updateFailure,
  }) {
    return OrderDetailsState(
      status: status ?? this.status,
      order: order ?? this.order,
      failure: failure ?? this.failure,
      isUpdating: isUpdating ?? this.isUpdating,
      updateFailure: updateFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    order,
    failure,
    isUpdating,
    updateFailure,
  ];
}

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._repository, this.orderId)
    : super(const OrderDetailsState());

  final OrderRepository _repository;
  final int orderId;

  Future<void> load() async {
    emit(const OrderDetailsState(status: OrderDetailsStatus.loading));

    final result = await _repository.order(orderId);
    emit(
      result.fold(
        onOk: (order) =>
            OrderDetailsState(status: OrderDetailsStatus.loaded, order: order),
        onErr: (failure) => OrderDetailsState(
          status: OrderDetailsStatus.failure,
          failure: failure,
        ),
      ),
    );
  }

  /// Returns true when the change went through, so the page can show a
  /// confirmation only on success.
  Future<bool> changeStatus(OrderStatus status) async {
    if (state.isUpdating) return false;
    emit(state.copyWith(isUpdating: true));

    final result = await _repository.updateStatus(id: orderId, status: status);

    return result.fold(
      onOk: (order) {
        emit(
          OrderDetailsState(status: OrderDetailsStatus.loaded, order: order),
        );
        return true;
      },
      onErr: (failure) {
        emit(state.copyWith(isUpdating: false, updateFailure: failure));
        return false;
      },
    );
  }
}
