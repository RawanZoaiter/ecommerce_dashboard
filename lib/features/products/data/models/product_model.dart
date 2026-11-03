import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

abstract final class CategoryModel {
  static Category fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}

abstract final class ProductModel {
  /// Builds a product from either response shape.
  ///
  /// The list endpoint omits `available_quantity` entirely while the details
  /// endpoint always includes it, possibly null. Those are different facts, so
  /// a missing key maps to [AvailabilityUnknown] rather than being read as a
  /// null quantity.
  static Product fromJson(
    Map<String, dynamic> json, {
    bool? inventoryReachable,
  }) {
    final category = json['category'];

    return Product(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      // The API sends the price as a decimal string on purpose; parsing it
      // into minor units keeps the arithmetic exact (guide §5.8).
      price: Money.parse(json['price']?.toString() ?? ''),
      category: category is Map<String, dynamic>
          ? CategoryModel.fromJson(category)
          : const Category(id: 0, name: ''),
      imageUrl: json['image_url'] as String? ?? '',
      createdAt: DateFormatter.tryParse(json['created_at'] as String?),
      availability: json.containsKey('available_quantity')
          ? Availability.fromApi(
              json['available_quantity'] as int?,
              inventoryReachable: inventoryReachable,
            )
          : const AvailabilityUnknown(),
    );
  }
}
