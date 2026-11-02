import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

enum LoginStatus { idle, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.idle,
    this.user,
    this.failure,
    this.notAdmin = false,
  });

  final LoginStatus status;
  final User? user;
  final Failure? failure;

  /// Credentials were right, but the account is a customer. The dashboard
  /// refuses it here rather than letting them in to a screen where every
  /// admin call would come back 403.
  final bool notAdmin;

  bool get isSubmitting => status == LoginStatus.submitting;

  /// Per-field messages from a 422, to render under the inputs.
  Map<String, List<String>> get fieldErrors => switch (failure) {
    ValidationFailure(:final fieldErrors) => fieldErrors,
    _ => const {},
  };

  @override
  List<Object?> get props => [status, user, failure, notAdmin];
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginState());

  final AuthRepository _repository;

  Future<void> submit({required String email, required String password}) async {
    if (state.isSubmitting) return;
    emit(const LoginState(status: LoginStatus.submitting));

    final result = await _repository.login(email: email, password: password);

    emit(
      result.fold(
        onOk: (user) => user.role.isAdmin
            ? LoginState(status: LoginStatus.success, user: user)
            : const LoginState(status: LoginStatus.failure, notAdmin: true),
        onErr: (failure) =>
            LoginState(status: LoginStatus.failure, failure: failure),
      ),
    );
  }

  /// Clears the error so the message disappears as soon as the user edits a
  /// field, instead of lingering under a value they already corrected.
  void clearError() {
    if (state.status == LoginStatus.failure) emit(const LoginState());
  }
}
