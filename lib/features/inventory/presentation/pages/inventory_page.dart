import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_paginator.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/product_thumbnail.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/stock_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../cubit/inventory_cubit.dart';
import '../widgets/stock_quantity_dialog.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InventoryCubit(sl<InventoryRepository>())..fetch(),
      child: const _InventoryView(),
    );
  }
}

class _InventoryView extends StatelessWidget {
  const _InventoryView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        final cubit = context.read<InventoryCubit>();

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            PageHeader(
              title: l10n.inventoryTitle,
              subtitle: l10n.inventorySubtitle,
              actions: [
                OutlinedButton.icon(
                  onPressed: cubit.fetch,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.actionRefresh),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // This screen has no server behind it at all: the quantities live
            // in the inventory service's own database, and the frontend is not
            // allowed to call that service directly.
            InfoBanner(
              message: l10n.mockBannerMessage,
              tone: BannerTone.warning,
              icon: Icons.construction_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),

            AppCard(
              clipBody: true,
              padding: EdgeInsets.zero,
              child: switch (state.status) {
                InventoryStatus.failure => Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: ErrorStateView(
                    failure: state.failure!,
                    onRetry: cubit.fetch,
                  ),
                ),
                InventoryStatus.initial ||
                InventoryStatus.loading => const TableSkeleton(),
                InventoryStatus.loaded when state.page.isEmpty => Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: EmptyStateView(
                    title: l10n.emptyTitle,
                    message: l10n.emptyMessage,
                    icon: Icons.warehouse_outlined,
                  ),
                ),
                InventoryStatus.loaded => Column(
                  children: [
                    _StockTable(items: state.page.items),
                    const Divider(),
                    AppPaginator(
                      meta: state.page.meta,
                      onPageChanged: (page) => cubit.fetch(page: page),
                    ),
                  ],
                ),
              },
            ),
          ],
        );
      },
    );
  }
}

class _StockTable extends StatelessWidget {
  const _StockTable({required this.items});

  final List<StockItem> items;

  Future<void> _edit(BuildContext context, StockItem item) async {
    final quantity = await StockQuantityDialog.show(context, item: item);
    if (quantity == null || !context.mounted) return;

    final cubit = context.read<InventoryCubit>();
    final succeeded = await cubit.setQuantity(
      productId: item.productId,
      quantity: quantity,
    );
    if (context.mounted) {
      context.showSnack(
        succeeded ? context.l10n.actionSave : context.l10n.errorGeneric,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppTable(
      columns: [
        AppTableColumn(label: l10n.productsColumnImage, width: 56),
        AppTableColumn(label: l10n.inventoryColumnProduct, flex: 4),
        AppTableColumn(label: l10n.inventoryColumnUpdated, flex: 2),
        AppTableColumn(
          label: l10n.inventoryColumnQuantity,
          width: 120,
          numeric: true,
        ),
        AppTableColumn(label: l10n.commonActions, width: 56),
      ],
      rows: [
        for (final item in items)
          AppTableRow(
            // Products that cannot be sold are tinted, because they look
            // perfectly normal in the store until someone tries to order one.
            highlight: !item.hasRecord || item.isSoldOut,
            cells: [
              ProductThumbnail(imageUrl: item.imageUrl, name: item.productName),
              Text(
                item.productName,
                style: context.text.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.updatedAt == null
                    ? '—'
                    : DateFormatter.date(item.updatedAt!, context.localeName),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              _QuantityCell(item: item),
              IconButton(
                tooltip: l10n.inventoryUpdateStock,
                onPressed: () => _edit(context, item),
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
            ],
          ),
      ],
    );
  }
}

class _QuantityCell extends StatelessWidget {
  const _QuantityCell({required this.item});

  final StockItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (!item.hasRecord) {
      return Text(
        l10n.productNoStockRecord,
        style: context.text.labelMedium?.copyWith(
          color: context.semantic.danger,
        ),
        textAlign: TextAlign.end,
      );
    }

    final color = item.isSoldOut
        ? context.semantic.danger
        : item.isLow
        ? context.semantic.warning
        : context.colors.onSurface;

    return Text(
      '${item.quantityOnHand}',
      style: context.text.titleSmall?.copyWith(color: color),
    );
  }
}
