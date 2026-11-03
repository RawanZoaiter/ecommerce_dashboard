import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';

/// The configured Dio instance every remote data source shares.
///
/// Fully wired and ready, but nothing calls it yet: while
/// [AppConfig.dataSource] is `mock` the repositories resolve to their mock
/// implementations and no request leaves the browser.
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required Future<void> Function() onSessionExpired,
  }) {
    _dio = Dio(_baseOptions);

    // Interceptor order matters: auth attaches the token on the way out,
    // refresh reacts to 401s on the way back, logging sees the final error.
    _dio.interceptors.addAll([
      AuthInterceptor(tokenStorage),
      RefreshInterceptor(
        tokenStorage: tokenStorage,
        retryClient: _dio,
        refreshClient: Dio(_baseOptions),
        onSessionExpired: onSessionExpired,
      ),
      const LoggingInterceptor(),
    ]);
  }

  static BaseOptions get _baseOptions => BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    headers: {'Accept': 'application/json'},
    contentType: Headers.jsonContentType,
    // Let every status reach the interceptors; ErrorMapper decides what each
    // one means, so Dio should not pre-judge which are "errors".
    validateStatus: (status) => status != null && status < 400,
  );

  late final Dio _dio;

  Dio get dio => _dio;
}
