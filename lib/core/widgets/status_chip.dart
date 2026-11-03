import 'package:flutter/material.dart';

import '../../features/orders/domain/entities/order_status.dart';
import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

/// The order status pill.
///
/// Status is carried by a colored dot plus its name, never by color alone, so
/// the table stays readable for anyone who cannot separate amber from emerald.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {this.dense = false, super.key});

  final OrderStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = colorFor(context, status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.sm : AppSpacing.md,
        vertical: dense ? 3 : AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm - 2),
          Text(
            labelFor(context, status),
            style: (dense ? context.text.labelSmall : context.text.labelMedium)
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  static Color colorFor(BuildContext context, OrderStatus status) {
    final semantic = context.semantic;
    return switch (status) {
      OrderStatus.pending => semantic.statusPending,
      OrderStatus.confirmed => semantic.statusConfirmed,
      OrderStatus.shipped => semantic.statusShipped,
      OrderStatus.delivered => semantic.statusDelivered,
      OrderStatus.cancelled => semantic.statusCancelled,
    };
  }

  static String labelFor(BuildContext context, OrderStatus status) {
    final l10n = context.l10n;
    return switch (status) {
      OrderStatus.pending => l10n.orderStatusPending,
      OrderStatus.confirmed => l10n.orderStatusConfirmed,
      OrderStatus.shipped => l10n.orderStatusShipped,
      OrderStatus.delivered => l10n.orderStatusDelivered,
      OrderStatus.cancelled => l10n.orderStatusCancelled,
    };
  }
}
