import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.stats,
    this.failure,
  });

  final DashboardStatus status;
  final DashboardStats? stats;
  final Failure? failure;

  bool get isLoading =>
      status == DashboardStatus.loading || status == DashboardStatus.initial;

  @override
  List<Object?> get props => [status, stats, failure];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState());

  final DashboardRepository _repository;

  Future<void> load() async {
    emit(const DashboardState(status: DashboardStatus.loading));

    final result = await _repository.stats();
    emit(
      result.fold(
        onOk: (stats) =>
            DashboardState(status: DashboardStatus.loaded, stats: stats),
        onErr: (failure) =>
            DashboardState(status: DashboardStatus.failure, failure: failure),
      ),
    );
  }
}
