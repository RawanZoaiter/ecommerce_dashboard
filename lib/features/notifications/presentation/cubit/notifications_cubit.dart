import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

enum NotificationsStatus { initial, loading, loaded, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const [],
    this.failure,
  });

  final NotificationsStatus status;
  final List<AppNotification> items;
  final Failure? failure;

  int get unreadCount => items.where((item) => item.isUnread).length;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? items,
    Failure? failure,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, items, failure];
}

/// Provided app-wide, because the shell's bell badge and the notifications
/// page read the same list; two cubits would show two different counts.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final NotificationRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: NotificationsStatus.loading));

    final result = await _repository.notifications();
    emit(
      result.fold(
        onOk: (items) => NotificationsState(
          status: NotificationsStatus.loaded,
          items: items,
        ),
        onErr: (failure) => NotificationsState(
          status: NotificationsStatus.failure,
          failure: failure,
        ),
      ),
    );
  }

  Future<void> markRead(int id) async {
    final result = await _repository.markRead(id);
    result.fold(
      onOk: (updated) {
        final items = [
          for (final item in state.items)
            if (item.id == updated.id) updated else item,
        ];
        emit(state.copyWith(items: items));
      },
      // A failed read-receipt is not worth interrupting the user for; the row
      // simply stays unread and the next load corrects it.
      onErr: (_) {},
    );
  }

  Future<void> markAllRead() async {
    final result = await _repository.markAllRead();
    if (result.isOk) await load();
  }
}
