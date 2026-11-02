import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/stock_item.dart';
import '../../domain/repositories/inventory_repository.dart';

enum InventoryStatus { initial, loading, loaded, failure }

class InventoryState extends Equatable {
  const InventoryState({
    this.status = InventoryStatus.initial,
    this.page = const Paginated.empty(),
    this.perPage = AppConfig.defaultPerPage,
    this.failure,
  });

  final InventoryStatus status;
  final Paginated<StockItem> page;
  final int perPage;
  final Failure? failure;

  bool get isLoading =>
      status == InventoryStatus.loading || status == InventoryStatus.initial;

  InventoryState copyWith({
    InventoryStatus? status,
    Paginated<StockItem>? page,
    int? perPage,
    Failure? failure,
  }) {
    return InventoryState(
      status: status ?? this.status,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, page, perPage, failure];
}

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit(this._repository) : super(const InventoryState());

  final InventoryRepository _repository;

  Future<void> fetch({int page = 1}) async {
    emit(state.copyWith(status: InventoryStatus.loading));

    final result = await _repository.stock(page: page, perPage: state.perPage);
    emit(
      result.fold(
        onOk: (data) =>
            state.copyWith(status: InventoryStatus.loaded, page: data),
        onErr: (failure) =>
            state.copyWith(status: InventoryStatus.failure, failure: failure),
      ),
    );
  }

  Future<bool> setQuantity({
    required int productId,
    required int quantity,
  }) async {
    final result = await _repository.setQuantity(
      productId: productId,
      quantity: quantity,
    );

    return result.fold(
      onOk: (updated) {
        final items = [
          for (final item in state.page.items)
            if (item.productId == updated.productId) updated else item,
        ];
        emit(
          state.copyWith(
            page: Paginated(items: items, meta: state.page.meta),
          ),
        );
        return true;
      },
      onErr: (_) => false,
    );
  }
}
