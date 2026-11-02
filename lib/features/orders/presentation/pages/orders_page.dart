import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_paginator.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';
import '../cubit/orders_cubit.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersCubit(sl<OrderRepository>())..fetch(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final cubit = context.read<OrdersCubit>();

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            PageHeader(
              title: l10n.ordersTitle,
              subtitle: l10n.ordersSubtitle,
              actions: [
                OutlinedButton.icon(
                  onPressed: cubit.fetch,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.actionRefresh),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _StatusFilter(selected: state.filter),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              clipBody: true,
              padding: EdgeInsets.zero,
              child: switch (state.status) {
                OrdersStatus.failure => Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: ErrorStateView(
                    failure: state.failure!,
                    onRetry: cubit.fetch,
                  ),
                ),
                OrdersStatus.initial ||
                OrdersStatus.loading => const TableSkeleton(),
                OrdersStatus.loaded when state.page.isEmpty => Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: EmptyStateView(
                    title: state.filter == null
                        ? l10n.ordersEmptyTitle
                        : l10n.emptyNoResultsTitle,
                    message: state.filter == null
                        ? l10n.ordersEmptyMessage
                        : l10n.emptyNoResultsMessage,
                    icon: Icons.receipt_long_outlined,
                    action: state.filter == null
                        ? null
                        : TextButton(
                            onPressed: () => cubit.filterBy(null),
                            child: Text(l10n.actionClear),
                          ),
                  ),
                ),
                OrdersStatus.loaded => Column(
                  children: [
                    _OrdersTable(orders: state.page.items),
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

/// Status tabs as filter chips.
///
/// All five statuses are always offered, even when a tab would come back
/// empty: an admin looking for cancelled orders should find the filter, not
/// have it disappear because there happen to be none today.
class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.selected});

  final OrderStatus? selected;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrdersCubit>();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ChoiceChip(
          label: Text(context.l10n.commonAll),
          selected: selected == null,
          onSelected: (_) => cubit.filterBy(null),
        ),
        for (final status in OrderStatus.values)
          ChoiceChip(
            label: Text(StatusChip.labelFor(context, status)),
            selected: selected == status,
            avatar: CircleAvatar(
              radius: 5,
              backgroundColor: StatusChip.colorFor(context, status),
            ),
            onSelected: (_) => cubit.filterBy(status),
          ),
      ],
    );
  }
}

class _OrdersTable extends StatelessWidget {
  const _OrdersTable({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppTable(
      columns: [
        AppTableColumn(label: l10n.ordersColumnId, width: 76),
        AppTableColumn(label: l10n.ordersColumnCustomer, flex: 3),
        AppTableColumn(label: l10n.commonCreatedAt, flex: 2),
        AppTableColumn(label: l10n.ordersColumnItems, width: 80, numeric: true),
        AppTableColumn(label: l10n.ordersColumnStatus, width: 140),
        AppTableColumn(
          label: l10n.ordersColumnTotal,
          width: 120,
          numeric: true,
        ),
      ],
      rows: [
        for (final order in orders)
          AppTableRow(
            onTap: () => context.go(Routes.orderDetails(order.id)),
            cells: [
              Text('#${order.id}', style: context.text.titleSmall),
              Row(
                children: [
                  UserAvatar(
                    initials: order.customer.initials,
                    seed: order.customer.email,
                    size: 30,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.customer.name,
                          style: context.text.bodyMedium,
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
              Text(
                order.createdAt == null
                    ? '—'
                    : DateFormatter.dateTime(
                        order.createdAt!,
                        context.localeName,
                      ),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text('${order.itemCount}', style: context.text.bodyMedium),
              StatusChip(order.status, dense: true),
              Text(
                order.total.format(locale: context.localeName),
                style: context.text.titleSmall,
              ),
            ],
          ),
      ],
    );
  }
}
