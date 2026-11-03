import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/new_product.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

enum NewProductStatus { editing, submitting, success, failure }

/// Why a chosen file was rejected before it was ever sent.
enum ImageRejection { type, size }

class NewProductState extends Equatable {
  const NewProductState({
    this.status = NewProductStatus.editing,
    this.categories = const [],
    this.imageBytes,
    this.imageFileName,
    this.imageRejection,
    this.created,
    this.failure,
  });

  final NewProductStatus status;
  final List<Category> categories;
  final Uint8List? imageBytes;
  final String? imageFileName;
  final ImageRejection? imageRejection;
  final Product? created;
  final Failure? failure;

  bool get isSubmitting => status == NewProductStatus.submitting;
  bool get hasImage => imageBytes != null;

  /// Per-field messages from a 422, shown beside the matching input.
  Map<String, List<String>> get fieldErrors => switch (failure) {
    ValidationFailure(:final fieldErrors) => fieldErrors,
    _ => const {},
  };

  NewProductState copyWith({
    NewProductStatus? status,
    List<Category>? categories,
    Uint8List? imageBytes,
    String? imageFileName,
    bool clearImage = false,
    ImageRejection? imageRejection,
    Product? created,
    Failure? failure,
  }) {
    return NewProductState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      imageFileName: clearImage ? null : (imageFileName ?? this.imageFileName),
      imageRejection: imageRejection,
      created: created ?? this.created,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    imageBytes,
    imageFileName,
    imageRejection,
    created,
    failure,
  ];
}

class NewProductCubit extends Cubit<NewProductState> {
  NewProductCubit(this._repository) : super(const NewProductState());

  /// §5.10: jpg, jpeg, png or webp, up to 5 MB.
  static const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const maxImageBytes = 5 * 1024 * 1024;

  final ProductRepository _repository;

  Future<void> loadCategories() async {
    final result = await _repository.categories();
    emit(state.copyWith(categories: result.valueOrNull ?? const []));
  }

  /// Checks the file against the server's own rules before accepting it, so a
  /// too-large image is refused instantly instead of after a 5 MB upload.
  void pickImage({required Uint8List bytes, required String fileName}) {
    final extension = fileName.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      emit(state.copyWith(imageRejection: ImageRejection.type));
      return;
    }
    if (bytes.lengthInBytes > maxImageBytes) {
      emit(state.copyWith(imageRejection: ImageRejection.size));
      return;
    }

    emit(state.copyWith(imageBytes: bytes, imageFileName: fileName));
  }

  void removeImage() => emit(state.copyWith(clearImage: true));

  Future<void> submit({
    required String name,
    required String description,
    required String price,
    required int categoryId,
  }) async {
    final bytes = state.imageBytes;
    final fileName = state.imageFileName;
    if (bytes == null || fileName == null || state.isSubmitting) return;

    emit(state.copyWith(status: NewProductStatus.submitting));

    final result = await _repository.create(
      NewProduct(
        name: name.trim(),
        description: description.trim(),
        price: Money.parse(price.trim()),
        categoryId: categoryId,
        imageBytes: bytes,
        imageFileName: fileName,
      ),
    );

    emit(
      result.fold(
        onOk: (product) =>
            state.copyWith(status: NewProductStatus.success, created: product),
        onErr: (failure) =>
            state.copyWith(status: NewProductStatus.failure, failure: failure),
      ),
    );
  }
}
