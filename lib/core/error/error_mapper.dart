import 'package:dio/dio.dart';

import 'failure.dart';

/// Turns a [DioException] into a typed [Failure].
///
/// This is the single place that knows HTTP status codes. Repositories return
/// failures, cubits switch over them, and screens render localized copy — no
/// layer above this one looks at a status code or at the API's English
/// `message`.
abstract final class ErrorMapper {
  static Failure fromDio(DioException error) {
    final response = error.response;

    if (response == null) {
      return NetworkFailure(debugMessage: error.message);
    }

    final requestId = response.headers.value('x-request-id');
    final body = response.data;
    final envelope = body is Map<String, dynamic>
        ? body
        : const <String, dynamic>{};
    final message = envelope['message'] as String?;
    final data = envelope['data'];

    return fromStatus(
      statusCode: response.statusCode ?? 0,
      message: message,
      data: data,
      requestId: requestId,
      retryAfterHeader: response.headers.value('retry-after'),
    );
  }

  static Failure fromStatus({
    required int statusCode,
    String? message,
    Object? data,
    String? requestId,
    String? retryAfterHeader,
  }) {
    switch (statusCode) {
      case 401:
        return UnauthenticatedFailure(
          debugMessage: message,
          requestId: requestId,
        );

      case 403:
        return ForbiddenFailure(debugMessage: message, requestId: requestId);

      case 404:
        return NotFoundFailure(debugMessage: message, requestId: requestId);

      case 405:
        // Wrong HTTP verb: a bug on our side, not something a user can fix.
        return UnknownFailure(debugMessage: message, requestId: requestId);

      case 409:
        return _conflict(message: message, data: data, requestId: requestId);

      case 422:
        return ValidationFailure(
          fieldErrors: _fieldErrors(data),
          debugMessage: message,
          requestId: requestId,
        );

      case 429:
        return ThrottledFailure(
          retryAfter: Duration(
            seconds: int.tryParse(retryAfterHeader ?? '') ?? 60,
          ),
          debugMessage: message,
          requestId: requestId,
        );

      case 503:
        // Laravel returns 503 both when its database is down (§5.1) and when
        // the inventory service does not answer (inventory update §3.2). Only
        // the message separates them, and the two need different copy.
        final isInventory =
            message != null && message.toLowerCase().contains('inventory');
        return isInventory
            ? InventoryUnavailableFailure(
                debugMessage: message,
                requestId: requestId,
              )
            : ServerFailure(debugMessage: message, requestId: requestId);

      case 500:
      case 502:
      case 504:
        return ServerFailure(debugMessage: message, requestId: requestId);

      default:
        return UnknownFailure(debugMessage: message, requestId: requestId);
    }
  }

  /// Three different 409s share one status code. The order-creation pair is
  /// told apart by the shape of `data` first (`insufficient_items` is
  /// structured and stable) and only falls back to matching the message when
  /// `data` is null, which is the one case the API gives us nothing else.
  static Failure _conflict({String? message, Object? data, String? requestId}) {
    if (data is Map<String, dynamic> && data['insufficient_items'] is List) {
      final raw = data['insufficient_items'] as List;
      return InsufficientStockFailure(
        items: raw
            .whereType<Map<String, dynamic>>()
            .map(InsufficientStockItem.fromJson)
            .toList(),
        debugMessage: message,
        requestId: requestId,
      );
    }

    final lower = message?.toLowerCase() ?? '';
    if (lower.contains('not available for ordering')) {
      return ProductsUnavailableFailure(
        debugMessage: message,
        requestId: requestId,
      );
    }

    // "Cannot change order status from X to Y."
    return StatusTransitionFailure(debugMessage: message, requestId: requestId);
  }

  static Map<String, List<String>> _fieldErrors(Object? data) {
    if (data is! Map<String, dynamic>) return const {};
    final result = <String, List<String>>{};
    data.forEach((field, value) {
      if (value is List) {
        result[field] = value.map((item) => item.toString()).toList();
      } else if (value is String) {
        result[field] = [value];
      }
    });
    return result;
  }
}
