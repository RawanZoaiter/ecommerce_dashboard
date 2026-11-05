import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_paginator.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/product_thumbnail.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../cubit/products_cubit.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductsCubit(sl<ProductRepository>())..start(),
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatelessWidget {
  const _ProductsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final cubit = context.read<ProductsCubit>();

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            PageHeader(
              title: l10n.productsTitle,
              subtitle: l10n.productsSubtitle,
              actions: [
                FilledButton.icon(
                  onPressed: () => context.go(Routes.newProduct),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.productsAdd),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _Filters(state: state),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              clipBody: true,
              padding: EdgeInsets.zero,
              child: switch (state.status) {
                ProductsStatus.failure => Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: ErrorStateView(
                    failure: state.failure!,
                    onRetry: cubit.fetch,
                  ),
                ),
                ProductsStatus.initial ||
                ProductsStatus.loading => const TableSkeleton(),
                ProductsStatus.loaded when state.page.isEmpty => Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: state.hasFilters
                      ? EmptyStateView(
                          title: l10n.emptyNoResultsTitle,
                          message: l10n.emptyNoResultsMessage,
                          icon: Icons.filter_alt_off_outlined,
                          action: TextButton(
                            onPressed: cubit.clearFilters,
                            child: Text(l10n.actionClear),
                          ),
                        )
                      : EmptyStateView(
                          title: l10n.productsEmptyTitle,
                          message: l10n.productsEmptyMessage,
                          icon: Icons.inventory_2_outlined,
                        ),
                ),
                ProductsStatus.loaded => Column(
                  children: [
                    const _ProductsTable(),
                    const Divider(),
                    AppPaginator(
                      meta: state.page.meta,
                      onPageChanged: (page) => cubit.fetch(page: page),
                      onPerPageChanged: cubit.changePerPage,
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

class _Filters extends StatelessWidget {
  const _Filters({required this.state});

  final ProductsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ProductsCubit>();

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // No search box: GET /products has no `?search=` parameter, and a box
        // that only filtered the page already on screen would look like a
        // search while quietly ignoring every other page.
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<int?>(
            initialValue: state.categoryId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.productsFilterCategory,
              prefixIcon: const Icon(Icons.category_outlined, size: 20),
            ),
            items: [
              DropdownMenuItem(child: Text(l10n.commonAll)),
              for (final Category category in state.categories)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: cubit.filterByCategory,
          ),
        ),
        if (state.hasFilters)
          TextButton.icon(
            onPressed: cubit.clearFilters,
            icon: const Icon(Icons.close, size: 16),
            label: Text(l10n.actionClear),
          ),
      ],
    );
  }
}

class _ProductsTable extends StatelessWidget {
  const _ProductsTable();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final products = context.select<ProductsCubit, List<Product>>(
      (cubit) => cubit.state.page.items,
    );
    final isLoadingStock = context.select<ProductsCubit, bool>(
      (cubit) => cubit.state.isLoadingStock,
    );

    return AppTable(
      columns: [
        AppTableColumn(label: l10n.productsColumnImage, width: 56),
        AppTableColumn(label: l10n.productsColumnName, flex: 4),
        AppTableColumn(label: l10n.productsColumnCategory, flex: 2),
        AppTableColumn(label: l10n.commonCreatedAt, flex: 2),
        AppTableColumn(
          label: l10n.productsColumnQuantity,
          width: 110,
          numeric: true,
        ),
        AppTableColumn(
          label: l10n.productsColumnPrice,
          width: 120,
          numeric: true,
        ),
      ],
      rows: [
        for (final product in products)
          AppTableRow(
            onTap: () => context.go(Routes.productDetails(product.id)),
            cells: [
              ProductThumbnail(imageUrl: product.imageUrl, name: product.name),
              Text(
                product.name,
                style: context.text.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                product.category.name,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                product.createdAt == null
                    ? '—'
                    : DateFormatter.date(
                        product.createdAt!,
                        context.localeName,
                      ),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              _StockCell(
                availability: product.availability,
                isLoading: isLoadingStock,
              ),
              Text(
                product.price.format(locale: context.localeName),
                style: context.text.titleSmall,
              ),
            ],
          ),
      ],
    );
  }
}

/// The quantity cell.
///
/// Three states, because the API gives three answers: a number, "no quantity
/// is known for this product", and "we have not asked yet". Showing 0 for the
/// last two would be a lie about stock, which is the one thing this column
/// must never do.
class _StockCell extends StatelessWidget {
  const _StockCell({required this.availability, required this.isLoading});

  final Availability availability;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return switch (availability) {
      InStock(:final quantity) => Text(
        NumberFormatter.count(quantity, context.localeName),
        style: context.text.titleSmall?.copyWith(
          color: switch (quantity) {
            0 => context.semantic.danger,
            <= 5 => context.semantic.warning,
            _ => context.colors.onSurface,
          },
        ),
      ),
      // Still being fetched: a muted placeholder rather than a spinner per
      // row, which would make the whole table flicker.
      NoStockRecord() || AvailabilityUnknown() when isLoading => Text(
        '·',
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      NoStockRecord() || AvailabilityUnknown() => Tooltip(
        message: context.l10n.productQuantityUnknownHint,
        child: Text(
          '—',
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ),
    };
  }
}
