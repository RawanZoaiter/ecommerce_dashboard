import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';
import '../cubit/order_details_cubit.dart';
import '../widgets/order_timeline.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({required this.orderId, super.key});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderDetailsCubit(sl<OrderRepository>(), orderId)..load(),
      child: const _OrderDetailsView(),
    );
  }
}

class _OrderDetailsView extends StatelessWidget {
  const _OrderDetailsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => context.go(Routes.orders),
                icon: Icon(
                  context.isRtl ? Icons.arrow_forward : Icons.arrow_back,
                  size: 16,
                ),
                label: Text(context.l10n.ordersTitle),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            switch (state.status) {
              OrderDetailsStatus.failure => ErrorStateView(
                failure: state.failure!,
                onRetry: context.read<OrderDetailsCubit>().load,
              ),
              OrderDetailsStatus.initial ||
              OrderDetailsStatus.loading => const AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 180, height: 24),
                    SizedBox(height: AppSpacing.xxl),
                    SkeletonBox(height: 48, radius: AppRadius.md),
                    SizedBox(height: AppSpacing.xxl),
                    SkeletonBox(height: 12),
                    SizedBox(height: AppSpacing.sm),
                    SkeletonBox(height: 12),
                  ],
                ),
              ),
              OrderDetailsStatus.loaded => _Loaded(state: state),
            },
          ],
        );
      },
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state});

  final OrderDetailsState state;

  @override
  Widget build(BuildContext context) {
    final order = state.order!;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.orderDetailsTitle(order.id),
                    style: context.text.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      StatusChip(order.status),
                      const SizedBox(width: AppSpacing.md),
                      if (order.createdAt != null)
                        Text(
                          DateFormatter.dateTime(
                            order.createdAt!,
                            context.localeName,
                          ),
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        if (state.updateFailure != null) ...[
          InfoBanner(
            message: _updateMessage(context, state),
            tone: BannerTone.danger,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],

        AppCard(
          title: l10n.orderDetailsTimeline,
          clipBody: true,
          child: OrderTimeline(status: order.status),
        ),
        const SizedBox(height: AppSpacing.xl),
        _StatusActions(order: order, isUpdating: state.isUpdating),
        const SizedBox(height: AppSpacing.xl),
        _Body(order: order),
      ],
    );
  }

  String _updateMessage(BuildContext context, OrderDetailsState state) {
    final l10n = context.l10n;
    return switch (state.updateFailure) {
      StatusTransitionFailure() => l10n.orderActionFinalMessage,
      ForbiddenFailure() => l10n.errorForbidden,
      NetworkFailure() => l10n.errorNetwork,
      _ => l10n.errorGeneric,
    };
  }
}

/// Buttons for the transitions the order can actually make.
///
/// Built from [OrderStatus.nextStates], so delivered and cancelled orders show
/// an explanation instead of buttons that would come back 409.
class _StatusActions extends StatelessWidget {
  const _StatusActions({required this.order, required this.isUpdating});

  final Order order;
  final bool isUpdating;

  Future<void> _change(BuildContext context, OrderStatus next) async {
    final l10n = context.l10n;
    final isCancel = next == OrderStatus.cancelled;

    final confirmed = await ConfirmDialog.show(
      context,
      title: isCancel ? l10n.orderActionCancel : l10n.orderConfirmDialogTitle,
      message: isCancel
          ? l10n.orderCancelDialogMessage(order.id)
          : l10n.orderConfirmDialogMessage(
              order.id,
              StatusChip.labelFor(context, order.status),
              StatusChip.labelFor(context, next),
            ),
      confirmLabel: _label(l10n, next),
      isDestructive: isCancel,
    );
    if (!confirmed || !context.mounted) return;

    final cubit = context.read<OrderDetailsCubit>();
    final succeeded = await cubit.changeStatus(next);
    if (succeeded && context.mounted) {
      context.showSnack(l10n.orderStatusUpdated);
    }
  }

  String _label(AppLocalizations l10n, OrderStatus next) => switch (next) {
    OrderStatus.confirmed => l10n.orderActionConfirm,
    OrderStatus.shipped => l10n.orderActionShip,
    OrderStatus.delivered => l10n.orderActionDeliver,
    OrderStatus.cancelled => l10n.orderActionCancel,
    // Never offered: nothing transitions back to pending (guide §5.14).
    OrderStatus.pending => l10n.actionConfirm,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (order.status.isFinal) {
      return InfoBanner(
        title: l10n.orderActionFinalTitle,
        message: l10n.orderActionFinalMessage,
        icon: Icons.lock_outline,
      );
    }

    return AppCard(
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          for (final next in order.status.nextStates)
            if (next == OrderStatus.cancelled)
              OutlinedButton.icon(
                onPressed: isUpdating ? null : () => _change(context, next),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.semantic.danger,
                  side: BorderSide(
                    color: context.semantic.danger.withValues(alpha: 0.5),
                  ),
                ),
                icon: const Icon(Icons.close, size: 18),
                label: Text(_label(l10n, next)),
              )
            else
              FilledButton.icon(
                onPressed: isUpdating ? null : () => _change(context, next),
                icon: isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward, size: 18),
                label: Text(_label(l10n, next)),
              ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final items = _ItemsCard(order: order);
    final side = _SideColumn(order: order);

    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          items,
          const SizedBox(height: AppSpacing.xl),
          side,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: items),
        const SizedBox(width: AppSpacing.xl),
        SizedBox(width: 320, child: side),
      ],
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      title: l10n.orderDetailsItems,
      subtitle: l10n.orderDetailsItemCount(order.itemCount),
      clipBody: true,
      child: AppTable(
        minWidth: 520,
        columns: [
          AppTableColumn(label: l10n.productsColumnName, flex: 4),
          AppTableColumn(
            label: l10n.orderDetailsUnitPrice,
            width: 110,
            numeric: true,
          ),
          AppTableColumn(
            label: l10n.orderDetailsQuantity,
            width: 70,
            numeric: true,
          ),
          AppTableColumn(
            label: l10n.orderDetailsLineTotal,
            width: 120,
            numeric: true,
          ),
        ],
        rows: [
          for (final line in order.lines)
            AppTableRow(
              onTap: () => context.go(Routes.productDetails(line.productId)),
              cells: [
                Text(
                  line.name,
                  style: context.text.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  line.unitPrice.format(locale: context.localeName),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  NumberFormatter.count(line.quantity, context.localeName),
                  style: context.text.bodyMedium,
                ),
                Text(
                  line.lineTotal.format(locale: context.localeName),
                  style: context.text.titleSmall,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          title: l10n.orderDetailsCustomer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                UserAvatar(
                  initials: order.customer.initials,
                  seed: order.customer.email,
                  size: 42,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        order.customer.name,
                        style: context.text.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        order.customer.email,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppCard(
          title: l10n.orderDetailsSummary,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.orderDetailsTotal,
                    style: context.text.bodyMedium,
                  ),
                ),
                Text(
                  // The server's figure, shown as sent. Recomputing it here
                  // could disagree with the invoice.
                  order.total.format(locale: context.localeName),
                  style: context.text.headlineSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
