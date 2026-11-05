import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

enum ProductsStatus { initial, loading, loaded, failure }

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.page = const Paginated.empty(),
    this.categories = const [],
    this.categoryId,
    this.perPage = AppConfig.defaultPerPage,
    this.failure,
    this.isLoadingStock = false,
  });

  final ProductsStatus status;
  final Paginated<Product> page;
  final List<Category> categories;
  final int? categoryId;
  final int perPage;
  final Failure? failure;

  /// Quantities arrive after the rows, so the column shows its own progress
  /// without the table waiting on it.
  final bool isLoadingStock;

  bool get isLoading =>
      status == ProductsStatus.loading || status == ProductsStatus.initial;

  bool get hasFilters => categoryId != null;

  ProductsState copyWith({
    ProductsStatus? status,
    Paginated<Product>? page,
    List<Category>? categories,
    int? categoryId,
    bool clearCategory = false,
    int? perPage,
    Failure? failure,
    bool? isLoadingStock,
  }) {
    return ProductsState(
      status: status ?? this.status,
      page: page ?? this.page,
      categories: categories ?? this.categories,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      perPage: perPage ?? this.perPage,
      failure: failure,
      isLoadingStock: isLoadingStock ?? this.isLoadingStock,
    );
  }

  @override
  List<Object?> get props => [
    status,
    page,
    categories,
    categoryId,
    perPage,
    failure,
    isLoadingStock,
  ];
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._repository) : super(const ProductsState());

  final ProductRepository _repository;

  /// Loads the filter options and the first page together.
  Future<void> start() async {
    final categoriesResult = await _repository.categories();
    emit(state.copyWith(categories: categoriesResult.valueOrNull ?? const []));
    await fetch();
  }

  Future<void> fetch({int page = 1}) async {
    emit(state.copyWith(status: ProductsStatus.loading));

    final result = await _repository.products(
      page: page,
      perPage: state.perPage,
      categoryId: state.categoryId,
    );

    emit(
      result.fold(
        onOk: (data) =>
            state.copyWith(status: ProductsStatus.loaded, page: data),
        onErr: (failure) =>
            state.copyWith(status: ProductsStatus.failure, failure: failure),
      ),
    );

    if (result.isOk) await _loadStock();
  }

  /// Fills the quantity column for the rows now on screen.
  ///
  /// Deliberately after [fetch] rather than inside it: the list endpoint has
  /// no quantity, so this is one extra request per row, and making the table
  /// wait for them would turn a fast page into a slow one.
  Future<void> _loadStock() async {
    final ids = state.page.items.map((product) => product.id).toList();
    if (ids.isEmpty) return;

    emit(state.copyWith(isLoadingStock: true));
    final result = await _repository.availabilityFor(ids);

    // The rows may have been replaced by a filter or a page change while this
    // was in flight; applying stale quantities would mislabel them.
    final current = state.page.items.map((product) => product.id).toList();
    if (!_sameIds(ids, current)) return;

    emit(
      state.copyWith(
        isLoadingStock: false,
        page: result.fold(
          onOk: (byId) => Paginated(
            items: [
              for (final product in state.page.items)
                if (byId.containsKey(product.id))
                  product.copyWith(availability: byId[product.id])
                else
                  product,
            ],
            meta: state.page.meta,
          ),
          // Leaving the rows untouched keeps every cell on "unknown", which is
          // the honest reading when the lookup itself failed.
          onErr: (_) => state.page,
        ),
      ),
    );
  }

  bool _sameIds(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Filtering always resets to page 1: staying on page 3 of a narrower result
  /// set would show an empty table for no visible reason.
  Future<void> filterByCategory(int? categoryId) async {
    emit(
      state.copyWith(categoryId: categoryId, clearCategory: categoryId == null),
    );
    await fetch();
  }

  Future<void> clearFilters() async {
    emit(state.copyWith(clearCategory: true));
    await fetch();
  }

  Future<void> changePerPage(int perPage) async {
    emit(state.copyWith(perPage: perPage));
    await fetch();
  }
}
