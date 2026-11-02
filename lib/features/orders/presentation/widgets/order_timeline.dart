import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/order_status.dart';

/// The order's progress along pending → confirmed → shipped → delivered.
///
/// A cancelled order is off that path entirely, so it gets its own single
/// marker rather than a rail with an arbitrary step highlighted.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({required this.status, super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) return const _CancelledMarker();

    final currentIndex = status.timelineIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Row(
        children: [
          for (var i = 0; i < OrderStatus.happyPath.length; i++) ...[
            _Step(
              status: OrderStatus.happyPath[i],
              isDone: i <= currentIndex,
              isCurrent: i == currentIndex,
            ),
            if (i < OrderStatus.happyPath.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  color: i < currentIndex
                      ? context.colors.primary
                      : context.semantic.border,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.status,
    required this.isDone,
    required this.isCurrent,
  });

  final OrderStatus status;
  final bool isDone;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? context.colors.primary
        : context.colors.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isDone ? context.colors.primary : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone ? context.colors.primary : context.semantic.border,
              width: 2,
            ),
          ),
          child: isDone
              ? Icon(Icons.check, size: 15, color: context.colors.onPrimary)
              : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          StatusChip.labelFor(context, status),
          style: (isCurrent ? context.text.labelMedium : context.text.bodySmall)
              ?.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CancelledMarker extends StatelessWidget {
  const _CancelledMarker();

  @override
  Widget build(BuildContext context) {
    final color = context.semantic.statusCancelled;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(Icons.close, size: 15, color: context.colors.onPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            StatusChip.labelFor(context, OrderStatus.cancelled),
            style: context.text.titleSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
