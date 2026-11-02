import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/mock/mock_seed.dart';
import '../../../../core/mock/mock_support.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

/// Sample-data implementation of [NotificationRepository]. Guide §7 lists
/// these endpoints as agreed but unbuilt, so this is the only implementation.
class MockNotificationRepository
    with MockSupport
    implements NotificationRepository {
  final List<AppNotification> _notifications = [...MockSeed.notifications];

  @override
  Future<Result<List<AppNotification>>> notifications() async {
    await settle();
    return Ok(List.unmodifiable(_notifications));
  }

  @override
  Future<Result<AppNotification>> markRead(int id) async {
    await settle();

    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );
    if (index == -1) return const Err(NotFoundFailure());

    final updated = _notifications[index].markRead(DateTime.now());
    _notifications[index] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<void>> markAllRead() async {
    await settle();

    final now = DateTime.now();
    for (var i = 0; i < _notifications.length; i++) {
      if (_notifications[i].isUnread) {
        _notifications[i] = _notifications[i].markRead(now);
      }
    }
    return const Ok(null);
  }
}
