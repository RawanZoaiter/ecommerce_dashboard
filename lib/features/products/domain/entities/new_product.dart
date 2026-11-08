import 'dart:typed_data';

import '../../../../core/utils/money.dart';
import 'product.dart';

/// A product the admin is about to create.
///
/// The image travels as bytes, not a path: on web there is no file path to
/// hand to a multipart request, so the picker returns the contents directly.
class NewProduct {
  const NewProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.initialQuantity,
    required this.imageBytes,
    required this.imageFileName,
  });

  final String name;
  final String description;
  final Money price;
  final int categoryId;

  /// The opening stock, required by the API.
  ///
  /// It is not stored on the product: Laravel forwards it to the inventory
  /// service, which owns quantities. Zero is allowed — a product can be
  /// listed before any of it arrives.
  final int initialQuantity;

  final Uint8List imageBytes;
  final String imageFileName;
}

/// Whether a new product's opening stock actually reached the inventory
/// service.
///
/// Creating a product is two steps behind one request: the row is saved, then
/// the stock is registered over gRPC. The second can fail on its own, so the
/// API answers 201 when both happened and 202 when only the first did.
/// Treating 202 as plain success would tell the admin a product is ready for
/// sale when nobody can order it.
enum StockProvisioning {
  confirmed,
  pending;

  static StockProvisioning fromApi(String? value) => value == 'ready'
      ? StockProvisioning.confirmed
      : StockProvisioning.pending;

  bool get isPending => this == StockProvisioning.pending;
}

/// The outcome of creating a product.
class ProductCreation {
  const ProductCreation({required this.product, required this.provisioning});

  final Product product;
  final StockProvisioning provisioning;
}
