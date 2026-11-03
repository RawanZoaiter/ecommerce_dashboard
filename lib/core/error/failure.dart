import 'package:equatable/equatable.dart';

/// A typed, UI-facing description of why a call failed.
///
/// Sealed so a `switch` over it is exhaustive: when the backend adds a new
/// error case, every place that renders failures stops compiling until it is
/// handled, instead of silently falling through to "something went wrong".
sealed class Failure extends Equatable {
  const Failure({this.debugMessage, this.requestId});

  /// The API's English `message`. For logs and bug reports only — screens
  /// render their own localized copy (frontend guide §3).
  final String? debugMessage;

  /// `X-Request-ID` of the failed response, which the backend team asks for
  /// when reporting a problem.
  final String? requestId;

  @override
  List<Object?> get props => [debugMessage, requestId];
}

/// No usable response: the server refused the connection, the host does not
/// resolve, or the browser blocked the request.
class NetworkFailure extends Failure {
  const NetworkFailure({super.debugMessage, super.requestId});
}

/// The server was reached but did not answer in time.
///
/// Kept apart from [NetworkFailure] because the two call for opposite
/// reactions: "the server is down, check it is running" sends someone hunting
/// for a process that is in fact working, when the honest message is that it
/// is simply too slow right now.
class TimeoutFailure extends Failure {
  const TimeoutFailure({super.debugMessage, super.requestId});
}

/// 401. Either sign in, or a token refresh is due.
class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure({super.debugMessage, super.requestId});
}

/// 403. Signed in, but the role does not allow this. Never retry.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.debugMessage, super.requestId});
}

/// 404. Also returned for another user's resource, deliberately, so that the
/// existence of other people's orders is not leaked (guide §5.13).
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.debugMessage, super.requestId});
}

/// 422 with per-field messages in `data`, to be shown beside each input.
class ValidationFailure extends Failure {
  const ValidationFailure({
    this.fieldErrors = const {},
    super.debugMessage,
    super.requestId,
  });

  final Map<String, List<String>> fieldErrors;

  /// First message for [field], or null when that field is fine.
  String? firstFor(String field) {
    final messages = fieldErrors[field];
    return (messages == null || messages.isEmpty) ? null : messages.first;
  }

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// 429. Wait [retryAfter] before trying again (guide §5.3).
class ThrottledFailure extends Failure {
  const ThrottledFailure({
    required this.retryAfter,
    super.debugMessage,
    super.requestId,
  });

  final Duration retryAfter;

  @override
  List<Object?> get props => [...super.props, retryAfter];
}

/// 409 on a status change: the transition is not allowed (guide §5.14).
class StatusTransitionFailure extends Failure {
  const StatusTransitionFailure({super.debugMessage, super.requestId});
}

/// One line of a 409 "not enough stock" response.
class InsufficientStockItem extends Equatable {
  const InsufficientStockItem({
    required this.productId,
    required this.name,
    required this.requestedQuantity,
    required this.availableQuantity,
  });

  factory InsufficientStockItem.fromJson(Map<String, dynamic> json) {
    return InsufficientStockItem(
      productId: json['product_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      requestedQuantity: json['requested_quantity'] as int? ?? 0,
      availableQuantity: json['available_quantity'] as int? ?? 0,
    );
  }

  final int productId;
  final String name;
  final int requestedQuantity;
  final int availableQuantity;

  @override
  List<Object?> get props => [
    productId,
    name,
    requestedQuantity,
    availableQuantity,
  ];
}

/// 409 while creating an order: at least one product is short. No order was
/// created and no quantity was taken — it is all-or-nothing (inventory
/// update §3.2), so the user can simply lower the quantities and resend.
class InsufficientStockFailure extends Failure {
  const InsufficientStockFailure({
    this.items = const [],
    super.debugMessage,
    super.requestId,
  });

  final List<InsufficientStockItem> items;

  @override
  List<Object?> get props => [...super.props, items];
}

/// 409 while creating an order: a product has no stock record at all. This is
/// the state every product created through the dashboard starts in, until
/// someone registers a quantity for it.
class ProductsUnavailableFailure extends Failure {
  const ProductsUnavailableFailure({super.debugMessage, super.requestId});
}

/// 503. The inventory service did not answer, so no order was created.
/// Retrying must reuse the very same Idempotency-Key (inventory update §3.2).
class InventoryUnavailableFailure extends Failure {
  const InventoryUnavailableFailure({super.debugMessage, super.requestId});
}

/// 500, or a 503 that is not about the inventory service.
class ServerFailure extends Failure {
  const ServerFailure({super.debugMessage, super.requestId});
}

/// Anything that did not match a known shape, including malformed JSON.
class UnknownFailure extends Failure {
  const UnknownFailure({super.debugMessage, super.requestId});
}
