import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';

abstract final class OrderModel {
  static Order fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final products = json['products'];

    return Order(
      id: json['id'] as int? ?? 0,
      status: OrderStatus.fromApi(json['status'] as String?),
      // The server's own total, kept as sent so the dashboard can never
      // disagree with the invoice.
      total: Money.parse(json['total']?.toString() ?? ''),
      customer: user is Map<String, dynamic>
          ? OrderCustomer(
              id: user['id'] as int? ?? 0,
              name: user['name'] as String? ?? '',
              email: user['email'] as String? ?? '',
            )
          : const OrderCustomer(id: 0, name: '', email: ''),
      lines: products is List
          ? products
                .whereType<Map<String, dynamic>>()
                .map(_lineFromJson)
                .toList()
          : const [],
      createdAt: DateFormatter.tryParse(json['created_at'] as String?),
    );
  }

  static OrderLine _lineFromJson(Map<String, dynamic> json) {
    return OrderLine(
      productId: json['product_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      // The price captured when the order was placed, not today's price.
      unitPrice: Money.parse(json['unit_price']?.toString() ?? ''),
    );
  }
}
