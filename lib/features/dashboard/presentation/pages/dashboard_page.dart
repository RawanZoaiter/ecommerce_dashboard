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
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/status_breakdown.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(sl<DashboardRepository>())..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.watch<AuthCubit>().state.user;

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.status == DashboardStatus.failure) {
          return ErrorStateView(
            failure: state.failure!,
            onRetry: context.read<DashboardCubit>().load,
          );
        }

        final stats = state.stats;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            PageHeader(
              title: user == null
                  ? l10n.dashboardTitle
                  : l10n.dashboardGreeting(user.name),
              subtitle: l10n.dashboardSubtitle,
              actions: [
                OutlinedButton.icon(
                  onPressed: context.read<DashboardCubit>().load,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.actionRefresh),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            _MetricGrid(stats: stats, isLoading: state.isLoading),
            const SizedBox(height: AppSpacing.xl),
            _Breakdown(stats: stats, isLoading: state.isLoading),
            const SizedBox(height: AppSpacing.xl),
            _RecentOrders(
              orders: stats?.recentOrders ?? const [],
              isLoading: state.isLoading,
            ),
          ],
        );
      },
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.stats, required this.isLoading});

  final DashboardStats? stats;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeName;

    final cards = [
      MetricCard(
        label: l10n.dashboardMetricOrders,
        value: NumberFormatter.count(stats?.totalOrders ?? 0, locale),
        icon: Icons.receipt_long_outlined,
        isLoading: isLoading,
        onTap: () => context.go(Routes.orders),
      ),
      MetricCard(
        label: l10n.dashboardMetricProducts,
        value: NumberFormatter.count(stats?.productCount ?? 0, locale),
        icon: Icons.inventory_2_outlined,
        tint: context.semantic.info,
        isLoading: isLoading,
        onTap: () => context.go(Routes.products),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 560 ? 1 : 2;
        const spacing = AppSpacing.lg;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.stats, required this.isLoading});

  final DashboardStats? stats;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: context.l10n.dashboardOrdersByStatus,
      clipBody: true,
      child: isLoading || stats == null
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: TableSkeleton(rows: 5, columns: 2),
            )
          : StatusBreakdown(ordersByStatus: stats!.ordersByStatus),
    );
  }
}

class _RecentOrders extends StatelessWidget {
  const _RecentOrders({required this.orders, required this.isLoading});

  final List<Order> orders;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      title: l10n.dashboardRecentOrders,
      clipBody: true,
      trailing: TextButton(
        onPressed: () => context.go(Routes.orders),
        child: Text(l10n.actionViewAll),
      ),
      child: isLoading
          ? const TableSkeleton(rows: 5)
          : AppTable(
              minWidth: 640,
              columns: [
                AppTableColumn(label: l10n.ordersColumnId, width: 72),
                AppTableColumn(label: l10n.ordersColumnCustomer, flex: 3),
                AppTableColumn(label: l10n.commonCreatedAt, flex: 2),
                AppTableColumn(label: l10n.ordersColumnStatus, width: 130),
                AppTableColumn(
                  label: l10n.ordersColumnTotal,
                  width: 110,
                  numeric: true,
                ),
              ],
              rows: [
                for (final order in orders)
                  AppTableRow(
                    onTap: () => context.go(Routes.orderDetails(order.id)),
                    cells: [
                      Text('#${order.id}', style: context.text.titleSmall),
                      Text(
                        order.customer.name,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium,
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
                      StatusChip(order.status, dense: true),
                      Text(
                        order.total.format(locale: context.localeName),
                        style: context.text.titleSmall,
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}
