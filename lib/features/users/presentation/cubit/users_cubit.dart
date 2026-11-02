import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_response.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

enum UsersStatus { initial, loading, loaded, failure }

class UsersState extends Equatable {
  const UsersState({
    this.status = UsersStatus.initial,
    this.page = const Paginated.empty(),
    this.failure,
  });

  final UsersStatus status;
  final Paginated<User> page;
  final Failure? failure;

  @override
  List<Object?> get props => [status, page, failure];
}

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this._repository) : super(const UsersState());

  final UserRepository _repository;

  Future<void> fetch({int page = 1}) async {
    emit(UsersState(status: UsersStatus.loading, page: state.page));

    final result = await _repository.users(
      page: page,
      perPage: AppConfig.defaultPerPage,
    );

    emit(
      result.fold(
        onOk: (data) => UsersState(status: UsersStatus.loaded, page: data),
        onErr: (failure) =>
            UsersState(status: UsersStatus.failure, failure: failure),
      ),
    );
  }
}
