import 'package:flutter/material.dart';

import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

class AppTableColumn {
  const AppTableColumn({
    required this.label,
    this.flex = 1,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.numeric = false,
  });

  final String label;

  /// Share of the remaining width. Ignored when [width] is set.
  final int flex;

  /// Fixed width, for columns whose content never grows (a thumbnail, a chip).
  final double? width;

  final Alignment alignment;

  /// Numeric columns are tabular-aligned to the end so digits line up.
  final bool numeric;
}

class AppTableRow {
  const AppTableRow({required this.cells, this.onTap, this.highlight = false});

  final List<Widget> cells;
  final VoidCallback? onTap;

  /// Draws a subtle tint, used for rows that need attention.
  final bool highlight;
}

/// A dense, themed table.
///
/// Material's [DataTable] is built for spreadsheets and fights custom cells, so
/// this is a plain header row plus body rows sharing one column spec. Below
/// [minWidth] the whole table scrolls sideways rather than squeezing columns
/// into unreadable slivers.
class AppTable extends StatelessWidget {
  const AppTable({
    required this.columns,
    required this.rows,
    this.minWidth = 760,
    super.key,
  });

  final List<AppTableColumn> columns;
  final List<AppTableRow> rows;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final needsScroll = constraints.maxWidth < minWidth;
        final table = SizedBox(
          width: needsScroll ? minWidth : constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(columns: columns),
              const Divider(),
              for (var i = 0; i < rows.length; i++) ...[
                _Row(columns: columns, row: rows[i]),
                if (i < rows.length - 1) const Divider(),
              ],
            ],
          ),
        );

        return needsScroll
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: table,
              )
            : table;
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.columns});

  final List<AppTableColumn> columns;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.semantic.surfaceSunken,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            for (final column in columns)
              _cell(
                column,
                Align(
                  alignment: column.numeric
                      ? AlignmentDirectional.centerEnd
                      : column.alignment,
                  child: Text(
                    column.label,
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.columns, required this.row});

  final List<AppTableColumn> columns;
  final AppTableRow row;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++)
            _cell(
              columns[i],
              Align(
                alignment: columns[i].numeric
                    ? AlignmentDirectional.centerEnd
                    : columns[i].alignment,
                child: i < row.cells.length
                    ? row.cells[i]
                    : const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );

    final tinted = row.highlight
        ? ColoredBox(
            color: context.semantic.warningContainer.withValues(alpha: 0.35),
            child: content,
          )
        : content;

    if (row.onTap == null) return tinted;

    return InkWell(onTap: row.onTap, child: tinted);
  }
}

/// Applies a column's sizing to one cell. Shared so the header and the body
/// can never drift out of alignment.
Widget _cell(AppTableColumn column, Widget child) {
  final padded = Padding(
    padding: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
    child: child,
  );

  return column.width != null
      ? SizedBox(width: column.width, child: padded)
      : Expanded(flex: column.flex, child: padded);
}
