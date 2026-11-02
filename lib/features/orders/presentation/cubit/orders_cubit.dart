import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';

enum OrdersStatus { initial, loading, loaded, failure }

class OrdersState extends Equatable {
  const OrdersState({
    this.status = OrdersStatus.initial,
    this.page = const Paginated.empty(),
    this.filter,
    this.perPage = AppConfig.defaultPerPage,
    this.failure,
  });

  final OrdersStatus status;
  final Paginated<Order> page;

  /// Null means "all statuses", which is the API's default too.
  final OrderStatus? filter;

  final int perPage;
  final Failure? failure;

  bool get isLoading =>
      status == OrdersStatus.loading || status == OrdersStatus.initial;

  OrdersState copyWith({
    OrdersStatus? status,
    Paginated<Order>? page,
    OrderStatus? filter,
    bool clearFilter = false,
    int? perPage,
    Failure? failure,
  }) {
    return OrdersState(
      status: status ?? this.status,
      page: page ?? this.page,
      filter: clearFilter ? null : (filter ?? this.filter),
      perPage: perPage ?? this.perPage,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, page, filter, perPage, failure];
}

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repository) : super(const OrdersState());

  final OrderRepository _repository;

  Future<void> fetch({int page = 1}) async {
    emit(state.copyWith(status: OrdersStatus.loading));

    final result = await _repository.orders(
      page: page,
      perPage: state.perPage,
      status: state.filter,
    );

    emit(
      result.fold(
        onOk: (data) => state.copyWith(status: OrdersStatus.loaded, page: data),
        onErr: (failure) =>
            state.copyWith(status: OrdersStatus.failure, failure: failure),
      ),
    );
  }

  Future<void> filterBy(OrderStatus? status) async {
    emit(state.copyWith(filter: status, clearFilter: status == null));
    await fetch();
  }

  Future<void> changePerPage(int perPage) async {
    emit(state.copyWith(perPage: perPage));
    await fetch();
  }
}
