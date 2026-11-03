import '../../../../core/error/result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  /// `POST /auth/login`, storing the returned token pair.
  ///
  /// A successful login by a customer is still a success as far as the API is
  /// concerned; it is this dashboard that rejects non-admins, so the caller
  /// checks [User.role] rather than expecting a failure here.
  Future<Result<User>> login({required String email, required String password});

  /// `GET /auth/user-info`, used on startup to restore a session.
  Future<Result<User>> currentUser();

  /// `POST /auth/logout`, then clears local tokens either way: if the call
  /// fails the token is unusable to us regardless, and keeping it would leave
  /// the dashboard stuck on a session it cannot refresh.
  Future<Result<void>> logout();

  /// True when a token pair is on disk, so startup can decide whether to try
  /// restoring a session before showing the login screen.
  Future<bool> hasStoredSession();
}
