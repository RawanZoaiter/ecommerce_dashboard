import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

enum ProductDetailsStatus { initial, loading, loaded, failure }

class ProductDetailsState extends Equatable {
  const ProductDetailsState({
    this.status = ProductDetailsStatus.initial,
    this.product,
    this.failure,
  });

  final ProductDetailsStatus status;
  final Product? product;
  final Failure? failure;

  @override
  List<Object?> get props => [status, product, failure];
}

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._repository, this.productId)
    : super(const ProductDetailsState());

  final ProductRepository _repository;
  final int productId;

  Future<void> load() async {
    emit(const ProductDetailsState(status: ProductDetailsStatus.loading));

    final result = await _repository.product(productId);
    emit(
      result.fold(
        onOk: (product) => ProductDetailsState(
          status: ProductDetailsStatus.loaded,
          product: product,
        ),
        onErr: (failure) => ProductDetailsState(
          status: ProductDetailsStatus.failure,
          failure: failure,
        ),
      ),
    );
  }
}
