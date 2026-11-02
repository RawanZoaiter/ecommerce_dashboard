import 'package:equatable/equatable.dart';

/// Guide §7 lists the notification endpoints as agreed but unbuilt, and does
/// not yet describe the payload. These fields are the shape the dashboard
/// needs; they are the concrete proposal to confirm with the backend team
/// rather than a documented contract.
enum NotificationKind {
  orderStatusChanged,
  lowStock,
  other;

  static NotificationKind fromApi(String? value) => switch (value) {
    'order_status_changed' => NotificationKind.orderStatusChanged,
    'low_stock' => NotificationKind.lowStock,
    _ => NotificationKind.other,
  };
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.orderId,
    this.readAt,
  });

  final int id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;

  /// Set when the notification is about an order, so the row can link to it.
  final int? orderId;

  final DateTime? readAt;

  bool get isUnread => readAt == null;

  AppNotification markRead(DateTime at) => AppNotification(
    id: id,
    kind: kind,
    title: title,
    body: body,
    createdAt: createdAt,
    orderId: orderId,
    readAt: at,
  );

  @override
  List<Object?> get props => [
    id,
    kind,
    title,
    body,
    createdAt,
    orderId,
    readAt,
  ];
}
