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
    this.search = '',
    this.perPage = AppConfig.defaultPerPage,
    this.failure,
  });

  final ProductsStatus status;
  final Paginated<Product> page;
  final List<Category> categories;
  final int? categoryId;
  final String search;
  final int perPage;
  final Failure? failure;

  bool get isLoading =>
      status == ProductsStatus.loading || status == ProductsStatus.initial;

  bool get hasFilters => categoryId != null || search.isNotEmpty;

  ProductsState copyWith({
    ProductsStatus? status,
    Paginated<Product>? page,
    List<Category>? categories,
    int? categoryId,
    bool clearCategory = false,
    String? search,
    int? perPage,
    Failure? failure,
  }) {
    return ProductsState(
      status: status ?? this.status,
      page: page ?? this.page,
      categories: categories ?? this.categories,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      search: search ?? this.search,
      perPage: perPage ?? this.perPage,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    page,
    categories,
    categoryId,
    search,
    perPage,
    failure,
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
      search: state.search.isEmpty ? null : state.search,
    );

    emit(
      result.fold(
        onOk: (data) =>
            state.copyWith(status: ProductsStatus.loaded, page: data),
        onErr: (failure) =>
            state.copyWith(status: ProductsStatus.failure, failure: failure),
      ),
    );
  }

  /// Filters always reset to page 1: staying on page 3 of a narrower result
  /// set would show an empty table for no visible reason.
  Future<void> filterByCategory(int? categoryId) async {
    emit(
      state.copyWith(categoryId: categoryId, clearCategory: categoryId == null),
    );
    await fetch();
  }

  Future<void> searchFor(String query) async {
    emit(state.copyWith(search: query));
    await fetch();
  }

  Future<void> clearFilters() async {
    emit(state.copyWith(clearCategory: true, search: ''));
    await fetch();
  }

  Future<void> changePerPage(int perPage) async {
    emit(state.copyWith(perPage: perPage));
    await fetch();
  }
}
