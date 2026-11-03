import 'package:equatable/equatable.dart';

import '../../../../core/utils/money.dart';
import 'category.dart';

/// What the dashboard knows about a product's stock.
///
/// The API reports a plain `available_quantity` that is either a number or
/// `null`, and `null` means two different things: the inventory service is
/// down, or this product has no stock record (inventory update §3.1). A
/// customer can treat both the same way, but an admin cannot — "our service is
/// down" and "you forgot to register stock for this" need different screens.
/// Until `/app-status` reports inventory health we cannot tell them apart from
/// one product alone, so the ambiguity is named here instead of being guessed
/// at in the widget.
sealed class Availability extends Equatable {
  const Availability();

  /// Builds availability from the API field plus, when known, whether the
  /// inventory service is currently reachable.
  factory Availability.fromApi(int? quantity, {bool? inventoryReachable}) {
    if (quantity != null) return InStock(quantity);
    if (inventoryReachable == false) return const AvailabilityUnknown();
    if (inventoryReachable == true) return const NoStockRecord();
    return const AvailabilityUnknown();
  }

  @override
  List<Object?> get props => const [];
}

/// A real number came back. It is a snapshot: somebody else may buy a second
/// later, so the guide warns against using it to block a purchase.
class InStock extends Availability {
  const InStock(this.quantity);

  final int quantity;

  bool get isSoldOut => quantity == 0;

  /// Threshold for the "low stock" badge and the dashboard counter.
  bool get isLow => quantity > 0 && quantity <= 5;

  @override
  List<Object?> get props => [quantity];
}

/// `null`, and the inventory service is known to be up: the product genuinely
/// has no stock row, so ordering it returns 409.
class NoStockRecord extends Availability {
  const NoStockRecord();
}

/// `null`, and we cannot say why.
class AvailabilityUnknown extends Availability {
  const AvailabilityUnknown();
}

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.createdAt,
    this.availability = const AvailabilityUnknown(),
  });

  final int id;
  final String name;
  final String description;
  final Money price;
  final Category category;
  final String imageUrl;
  final DateTime? createdAt;

  /// Only the details endpoint carries a quantity; rows coming from the list
  /// endpoint stay [AvailabilityUnknown] until that field is added to it.
  final Availability availability;

  Product copyWith({Availability? availability}) {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      category: category,
      imageUrl: imageUrl,
      createdAt: createdAt,
      availability: availability ?? this.availability,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    category,
    imageUrl,
    createdAt,
    availability,
  ];
}
