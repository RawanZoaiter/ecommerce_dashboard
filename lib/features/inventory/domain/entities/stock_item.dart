import 'package:equatable/equatable.dart';

/// A product's stock level as the dashboard would display it.
///
/// No endpoint serves this yet. The quantities live in the inventory service's
/// own database and the frontend is not allowed to talk to that service, so
/// this screen stays on sample data until Laravel exposes a stock read and
/// write of its own.
class StockItem extends Equatable {
  const StockItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.quantityOnHand,
    this.updatedAt,
  });

  final int productId;
  final String productName;
  final String imageUrl;

  /// Null when the product has no stock record at all, which is the state
  /// every product added through the dashboard starts in.
  final int? quantityOnHand;

  final DateTime? updatedAt;

  bool get hasRecord => quantityOnHand != null;
  bool get isSoldOut => quantityOnHand == 0;
  bool get isLow => (quantityOnHand ?? 99) > 0 && (quantityOnHand ?? 99) <= 5;

  @override
  List<Object?> get props => [
    productId,
    productName,
    imageUrl,
    quantityOnHand,
    updatedAt,
  ];
}
