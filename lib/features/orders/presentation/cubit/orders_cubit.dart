import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/realtime/realtime_service.dart';
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
    this.newOrderIds = const {},
  });

  final OrdersStatus status;
  final Paginated<Order> page;

  /// Null means "all statuses", which is the API's default too.
  final OrderStatus? filter;

  final int perPage;
  final Failure? failure;

  /// Orders that arrived live since the last fetch, so the table can highlight them.
  final Set<int> newOrderIds;

  bool get isLoading =>
      status == OrdersStatus.loading || status == OrdersStatus.initial;

  OrdersState copyWith({
    OrdersStatus? status,
    Paginated<Order>? page,
    OrderStatus? filter,
    bool clearFilter = false,
    int? perPage,
    Failure? failure,
    Set<int>? newOrderIds,
  }) {
    return OrdersState(
      status: status ?? this.status,
      page: page ?? this.page,
      filter: clearFilter ? null : (filter ?? this.filter),
      perPage: perPage ?? this.perPage,
      failure: failure,
      newOrderIds: newOrderIds ?? this.newOrderIds,
    );
  }

  @override
  List<Object?> get props =>
      [status, page, filter, perPage, failure, newOrderIds];
}

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repository, this._realtime) : super(const OrdersState()) {
    _listenForNewOrders();
  }

  final OrderRepository _repository;
  final RealtimeService _realtime;
  StreamSubscription<dynamic>? _live;

  /// Requirement 4, scenario 1: a customer creates an order and it appears here with no refresh. Laravel
  /// publishes `NewOrderPlaced` on the private channel `admin.orders`, which only admins may join.
  void _listenForNewOrders() {
    _live = _realtime.newOrders().listen(
      _onNewOrder,
      // A refused subscription (not an admin) or a dropped connection must never break the page.
      onError: (Object _) {},
    );
  }

  void _onNewOrder(Order order) {
    if (state.status != OrdersStatus.loaded) return;
    // The list is showing something else (page 2, or a filter that excludes new orders): leave it alone.
    final onFirstPage = state.page.meta.currentPage == 1;
    final matchesFilter =
        state.filter == null || state.filter == order.status;
    if (!onFirstPage || !matchesFilter) return;
    if (state.page.items.any((o) => o.id == order.id)) return;

    final items = [order, ...state.page.items].take(state.perPage).toList();
    final meta = state.page.meta;
    emit(
      state.copyWith(
        page: Paginated(
          items: items,
          meta: PageMeta(
            currentPage: meta.currentPage,
            lastPage: meta.lastPage,
            perPage: meta.perPage,
            total: meta.total + 1,
          ),
        ),
        newOrderIds: {...state.newOrderIds, order.id},
      ),
    );
  }

  @override
  Future<void> close() {
    _live?.cancel();
    return super.close();
  }

  Future<void> fetch({int page = 1}) async {
    emit(state.copyWith(status: OrdersStatus.loading));

    final result = await _repository.orders(
      page: page,
      perPage: state.perPage,
      status: state.filter,
    );

    emit(
      result.fold(
        onOk: (data) => state.copyWith(
              status: OrdersStatus.loaded,
              page: data,
              newOrderIds: const {},
            ),
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
