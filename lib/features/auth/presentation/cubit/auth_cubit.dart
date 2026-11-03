import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus {
  /// Startup, before a stored session has been checked. The router shows a
  /// splash rather than flashing the login screen at a signed-in user.
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.user});

  final AuthStatus status;
  final User? user;

  bool get isAdmin => user?.role.isAdmin ?? false;

  @override
  List<Object?> get props => [status, user];
}

/// Owns the session for the whole app.
///
/// Sign-in itself lives in [LoginCubit]; this cubit only records who is signed
/// in, so the router and the shell have one source of truth to read.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  /// Called once at startup. Without a stored session there is nothing to
  /// restore, so it skips the network call entirely.
  Future<void> restoreSession() async {
    if (!await _repository.hasStoredSession()) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }

    final result = await _repository.currentUser();
    emit(
      result.fold(
        onOk: (user) => AuthState(status: AuthStatus.authenticated, user: user),
        onErr: (_) => const AuthState(status: AuthStatus.unauthenticated),
      ),
    );
  }

  void onSignedIn(User user) =>
      emit(AuthState(status: AuthStatus.authenticated, user: user));

  Future<void> signOut() async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
