import 'package:equatable/equatable.dart';

import '../../../../core/utils/money.dart';
import 'order_status.dart';

/// One product line inside an order.
///
/// `unit_price` is the price captured when the order was placed, which is why
/// the order total cannot be recomputed from today's product prices.
class OrderLine extends Equatable {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  final int productId;
  final String name;
  final int quantity;
  final Money unitPrice;

  Money get lineTotal => unitPrice.times(quantity);

  @override
  List<Object?> get props => [productId, name, quantity, unitPrice];
}

/// Who placed the order. The orders endpoint returns a trimmed user object,
/// without the role, so this is not the full [User] entity.
class OrderCustomer extends Equatable {
  const OrderCustomer({
    required this.id,
    required this.name,
    required this.email,
  });

  final int id;
  final String name;
  final String email;

  @override
  List<Object?> get props => [id, name, email];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.status,
    required this.total,
    required this.customer,
    required this.lines,
    this.createdAt,
  });

  final int id;
  final OrderStatus status;

  /// The server's total. Shown as sent rather than recomputed, so the
  /// dashboard can never disagree with the invoice.
  final Money total;

  final OrderCustomer customer;
  final List<OrderLine> lines;
  final DateTime? createdAt;

  int get itemCount => lines.fold(0, (count, line) => count + line.quantity);

  @override
  List<Object?> get props => [id, status, total, customer, lines, createdAt];
}
