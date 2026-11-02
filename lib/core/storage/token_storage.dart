import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The token pair issued by login, register and refresh (guide §4).
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresIn: Duration(seconds: json['expires_in'] as int? ?? 3600),
    );
  }

  final String accessToken;
  final String refreshToken;
  final Duration expiresIn;

  bool get isEmpty => accessToken.isEmpty;
}

abstract interface class TokenStorage {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
}

/// Backed by `flutter_secure_storage`, which on web falls back to encrypted
/// `localStorage`. That is the practical ceiling for a browser app: a web page
/// has no Keychain, so the mobile app — not this dashboard — is where the
/// guide's secure-storage requirement really applies.
class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage(this._storage);

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _expiresKey = 'expires_in';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthTokens?> read() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || access.isEmpty || refresh == null) return null;

    final expires = int.tryParse(await _storage.read(key: _expiresKey) ?? '');
    return AuthTokens(
      accessToken: access,
      refreshToken: refresh,
      expiresIn: Duration(seconds: expires ?? 3600),
    );
  }

  @override
  Future<void> write(AuthTokens tokens) async {
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
    await _storage.write(
      key: _expiresKey,
      value: tokens.expiresIn.inSeconds.toString(),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _expiresKey);
  }
}

/// In-memory storage, used while the dashboard runs on mock data and in tests.
class InMemoryTokenStorage implements TokenStorage {
  AuthTokens? _tokens;

  @override
  Future<AuthTokens?> read() async => _tokens;

  @override
  Future<void> write(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}
