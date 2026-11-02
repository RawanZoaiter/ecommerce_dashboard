import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';
import '../api_endpoints.dart';

/// Refreshes an expired access token and replays the request that hit the 401.
///
/// The guide is emphatic about two things (§4): a refresh token may be used
/// exactly once, and two refreshes must never be in flight together. A
/// dashboard breaks that rule by default — the home screen fires several
/// requests at once, so an expired session produces a burst of simultaneous
/// 401s. Three things keep that safe here:
///
///  1. [QueuedInterceptor] serializes error handling, so the 401s arrive one
///     at a time rather than all at once.
///  2. [_refreshOnce] holds a single in-flight future, so overlapping callers
///     share one network refresh instead of starting their own.
///  3. Before refreshing, a request compares the token it actually sent with
///     the one now in storage. If another request already refreshed, this one
///     just replays with the new token — otherwise the first retry would spend
///     a second, needless refresh and rotate the token again.
class RefreshInterceptor extends QueuedInterceptor {
  RefreshInterceptor({
    required TokenStorage tokenStorage,
    required Dio retryClient,
    required Dio refreshClient,
    required Future<void> Function() onSessionExpired,
  }) : _tokenStorage = tokenStorage,
       _retryClient = retryClient,
       _refreshClient = refreshClient,
       _onSessionExpired = onSessionExpired;

  /// Marks a request that has already been replayed, so a second 401 on the
  /// same request ends the session instead of looping.
  static const _retriedFlag = 'retried_after_refresh';

  final TokenStorage _tokenStorage;

  /// The configured client, used to replay the original request.
  final Dio _retryClient;

  /// A bare client with no interceptors — refreshing through the main client
  /// would recurse straight back into this handler.
  final Dio _refreshClient;

  final Future<void> Function() _onSessionExpired;

  Future<AuthTokens?>? _inFlight;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldAttemptRefresh(err)) {
      handler.next(err);
      return;
    }

    final sentToken = err.requestOptions.headers['Authorization'] as String?;
    final stored = await _tokenStorage.read();

    // Somebody else already refreshed while this request was failing.
    if (stored != null &&
        stored.accessToken.isNotEmpty &&
        sentToken != 'Bearer ${stored.accessToken}') {
      await _replay(err, stored.accessToken, handler);
      return;
    }

    final refreshed = await _refreshOnce();
    if (refreshed == null) {
      await _onSessionExpired();
      handler.next(err);
      return;
    }

    await _replay(err, refreshed.accessToken, handler);
  }

  bool _shouldAttemptRefresh(DioException err) {
    if (err.response?.statusCode != 401) return false;
    if (err.requestOptions.extra[_retriedFlag] == true) return false;

    // A 401 from login or refresh itself is a real credential problem.
    final path = err.requestOptions.path;
    return path != ApiEndpoints.refresh && path != ApiEndpoints.login;
  }

  Future<AuthTokens?> _refreshOnce() {
    return _inFlight ??= _performRefresh().whenComplete(() => _inFlight = null);
  }

  Future<AuthTokens?> _performRefresh() async {
    final current = await _tokenStorage.read();
    if (current == null || current.refreshToken.isEmpty) return null;

    try {
      final response = await _refreshClient.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refresh_token': current.refreshToken},
      );

      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) return null;

      final tokens = AuthTokens.fromJson(data);
      if (tokens.isEmpty) return null;

      // Replace the pair immediately: the old refresh token is dead now.
      await _tokenStorage.write(tokens);
      return tokens;
    } on DioException {
      // 401 here means the refresh token is expired, already used, or unknown.
      await _tokenStorage.clear();
      return null;
    }
  }

  Future<void> _replay(
    DioException err,
    String accessToken,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..extra[_retriedFlag] = true;

    try {
      final response = await _retryClient.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (error) {
      handler.next(error);
    }
  }
}
