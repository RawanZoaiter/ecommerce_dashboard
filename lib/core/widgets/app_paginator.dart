import 'package:flutter/material.dart';

import '../extensions/context_x.dart';
import '../network/api_response.dart';
import '../theme/app_spacing.dart';

/// Page controls driven by the API's `meta` block.
///
/// Arrow icons are resolved against the reading direction, so "next" points
/// left in Arabic and right in English.
class AppPaginator extends StatelessWidget {
  const AppPaginator({
    required this.meta,
    required this.onPageChanged,
    this.onPerPageChanged,
    super.key,
  });

  final PageMeta meta;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onPerPageChanged;

  static const _perPageOptions = [15, 25, 50];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.paginationShowing(meta.from, meta.to, meta.total),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          if (onPerPageChanged != null && context.isExpanded) ...[
            Text(
              l10n.paginationRowsPerPage,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DropdownButton<int>(
              value: _perPageOptions.contains(meta.perPage)
                  ? meta.perPage
                  : _perPageOptions.first,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(AppRadius.md),
              style: context.text.bodySmall,
              items: [
                for (final option in _perPageOptions)
                  DropdownMenuItem(value: option, child: Text('$option')),
              ],
              onChanged: (value) {
                if (value != null) onPerPageChanged!(value);
              },
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
          IconButton(
            tooltip: l10n.paginationPrevious,
            onPressed: meta.hasPrevious
                ? () => onPageChanged(meta.currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              l10n.paginationPageOf(meta.currentPage, meta.lastPage),
              style: context.text.bodySmall,
            ),
          ),
          IconButton(
            tooltip: l10n.paginationNext,
            onPressed: meta.hasNext
                ? () => onPageChanged(meta.currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
