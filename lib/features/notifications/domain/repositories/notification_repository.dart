import '../../../../core/error/result.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  /// `GET /notifications` (guide §7, not built yet).
  Future<Result<List<AppNotification>>> notifications();

  /// `PATCH /notifications/{id}/read` (guide §7, not built yet).
  Future<Result<AppNotification>> markRead(int id);

  /// No endpoint proposed for this yet. Marking each notification
  /// individually would mean one request per row, so a bulk route — or an
  /// `unread_count` on the list response — was raised with the backend team.
  Future<Result<void>> markAllRead();
}
