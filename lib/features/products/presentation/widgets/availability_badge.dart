import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/product.dart';

/// Renders one of the four availability cases.
///
/// Each gets its own colour and wording, because for an admin "23 left",
/// "sold out", "nobody registered stock for this" and "we cannot reach the
/// inventory service" call for four different reactions.
class AvailabilityBadge extends StatelessWidget {
  const AvailabilityBadge({required this.availability, super.key});

  final Availability availability;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final semantic = context.semantic;

    final (color, icon, label) = switch (availability) {
      InStock(:final quantity) when quantity == 0 => (
        semantic.danger,
        Icons.remove_shopping_cart_outlined,
        l10n.productOutOfStock,
      ),
      InStock(:final quantity) when quantity <= 5 => (
        semantic.warning,
        Icons.warning_amber_rounded,
        l10n.productInStock(quantity),
      ),
      InStock(:final quantity) => (
        semantic.success,
        Icons.check_circle_outline,
        l10n.productInStock(quantity),
      ),
      NoStockRecord() => (
        semantic.danger,
        Icons.inventory_outlined,
        l10n.productNoStockRecord,
      ),
      AvailabilityUnknown() => (
        semantic.info,
        Icons.help_outline,
        l10n.productQuantityUnknown,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm - 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.sm - 2),
          Text(label, style: context.text.labelMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// The sentence under the badge that explains an ambiguous state.
class AvailabilityHint extends StatelessWidget {
  const AvailabilityHint({required this.availability, super.key});

  final Availability availability;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final hint = switch (availability) {
      NoStockRecord() => l10n.productNoStockRecordHint,
      AvailabilityUnknown() => l10n.productQuantityUnknownHint,
      InStock() => null,
    };

    if (hint == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        hint,
        style: context.text.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
