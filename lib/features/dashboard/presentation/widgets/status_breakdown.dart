import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../orders/domain/entities/order_status.dart';

/// Orders per status as labelled bars.
///
/// A pie would need a legend and a hover to answer "how many are pending?",
/// which is the only question this panel exists for. Bars put the count, the
/// label and the share on one line.
class StatusBreakdown extends StatelessWidget {
  const StatusBreakdown({required this.ordersByStatus, super.key});

  final Map<OrderStatus, int> ordersByStatus;

  @override
  Widget build(BuildContext context) {
    final total = ordersByStatus.values.fold(0, (sum, count) => sum + count);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final status in OrderStatus.values) ...[
            _StatusRow(
              status: status,
              count: ordersByStatus[status] ?? 0,
              total: total,
            ),
            if (status != OrderStatus.values.last)
              const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.status,
    required this.count,
    required this.total,
  });

  final OrderStatus status;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final color = StatusChip.colorFor(context, status);
    final share = total == 0 ? 0.0 : count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                StatusChip.labelFor(context, status),
                style: context.text.bodySmall,
              ),
            ),
            Text('$count', style: context.text.titleSmall),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 44,
              child: Text(
                '${(share * 100).round()}%',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm - 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: share,
            minHeight: 6,
            backgroundColor: context.semantic.surfaceSunken,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
