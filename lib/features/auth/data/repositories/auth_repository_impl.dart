import '../../../../core/error/result.dart';
import '../../../../core/network/remote_support.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl with RemoteSupport implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) {
    return guard(() async {
      final result = await _remote.login(email: email, password: password);
      // Stored before returning, so the very next request already carries the
      // token rather than racing the screen that triggered it.
      await _tokenStorage.write(result.tokens);
      return result.user;
    });
  }

  @override
  Future<Result<User>> currentUser() => guard(_remote.currentUser);

  @override
  Future<Result<void>> logout() async {
    final stored = await _tokenStorage.read();
    final result = await guard(
      () => _remote.logout(refreshToken: stored?.refreshToken),
    );

    // Cleared either way: if the call failed, the token is unusable to us
    // regardless, and keeping it would strand the dashboard on a session it
    // can no longer refresh.
    await _tokenStorage.clear();
    return result;
  }

  @override
  Future<bool> hasStoredSession() async => (await _tokenStorage.read()) != null;
}
