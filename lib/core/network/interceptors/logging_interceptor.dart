import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs failed requests together with their `X-Request-ID`.
///
/// The backend team asks for that header when reporting a problem, so it is
/// printed next to the path instead of being buried in the response.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final status = err.response?.statusCode ?? 0;
      final requestId = err.response?.headers.value('x-request-id') ?? '-';
      developer.log(
        '${err.requestOptions.method} ${err.requestOptions.path} '
        '-> $status (X-Request-ID: $requestId)',
        name: 'api',
      );
    }
    handler.next(err);
  }
}
