import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';
import '../api_endpoints.dart';

/// Attaches `Authorization: Bearer <access_token>` to protected requests.
///
/// Public endpoints are listed rather than inferred: the guide says a token
/// sent to a public endpoint is harmless, but keeping it off them makes the
/// network log readable and matches the role table in §6.
class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._tokenStorage);

  static const _publicPaths = {
    ApiEndpoints.appStatus,
    ApiEndpoints.register,
    ApiEndpoints.login,
    ApiEndpoints.refresh,
    ApiEndpoints.categories,
  };

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_needsAuth(options)) {
      handler.next(options);
      return;
    }

    final tokens = await _tokenStorage.read();
    if (tokens != null && tokens.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  bool _needsAuth(RequestOptions options) {
    if (_publicPaths.contains(options.path)) return false;
    // Reading products is public, but POST /products is admin-only, so the
    // method decides here rather than the path.
    if (options.path.startsWith(ApiEndpoints.products) &&
        options.method.toUpperCase() == 'GET') {
      return false;
    }
    return true;
  }
}
