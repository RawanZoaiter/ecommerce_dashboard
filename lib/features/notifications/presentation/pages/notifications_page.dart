import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/app_notification.dart';
import '../cubit/notifications_cubit.dart';

/// Reads the app-wide [NotificationsCubit] rather than creating its own, so
/// the unread badge in the sidebar and this list can never disagree.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationsCubit>();

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            PageHeader(
              title: l10n.notificationsTitle,
              subtitle: l10n.notificationsUnreadCount(state.unreadCount),
              actions: [
                if (state.unreadCount > 0)
                  OutlinedButton.icon(
                    onPressed: cubit.markAllRead,
                    icon: const Icon(Icons.done_all, size: 18),
                    label: Text(l10n.notificationsMarkAllRead),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Guide §7: agreed with the backend team, not built yet.
            InfoBanner(
              message: l10n.mockBannerMessage,
              tone: BannerTone.warning,
              icon: Icons.construction_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),

            switch (state.status) {
              NotificationsStatus.failure => AppCard(
                child: ErrorStateView(
                  failure: state.failure!,
                  onRetry: cubit.load,
                ),
              ),
              NotificationsStatus.initial ||
              NotificationsStatus.loading => const AppCard(
                clipBody: true,
                padding: EdgeInsets.zero,
                child: TableSkeleton(rows: 5, columns: 2),
              ),
              NotificationsStatus.loaded when state.items.isEmpty => AppCard(
                child: EmptyStateView(
                  title: l10n.notificationsEmptyTitle,
                  message: l10n.notificationsEmptyMessage,
                  icon: Icons.notifications_none,
                ),
              ),
              NotificationsStatus.loaded => Column(
                children: [
                  for (final notification in state.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _NotificationTile(notification: notification),
                    ),
                ],
              ),
            },
          ],
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isUnread;
    final (icon, tint) = switch (notification.kind) {
      NotificationKind.orderStatusChanged => (
        Icons.local_shipping_outlined,
        context.semantic.info,
      ),
      NotificationKind.lowStock => (
        Icons.warning_amber_rounded,
        context.semantic.warning,
      ),
      NotificationKind.other => (
        Icons.info_outline,
        context.colors.onSurfaceVariant,
      ),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (isUnread) {
            context.read<NotificationsCubit>().markRead(notification.id);
          }
          final orderId = notification.orderId;
          if (orderId != null) context.go(Routes.orderDetails(orderId));
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 19, color: tint),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: isUnread
                                ? context.text.titleSmall
                                : context.text.bodyMedium,
                          ),
                        ),
                        // Unread is marked by a dot as well as weight, so it
                        // does not rely on a font-weight difference alone.
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      notification.body,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      DateFormatter.dateTime(
                        notification.createdAt,
                        context.localeName,
                      ),
                      style: context.text.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
