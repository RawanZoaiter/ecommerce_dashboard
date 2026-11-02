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
import '../../../../core/widgets/info_banner.dart';
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
import '../widgets/revenue_chart.dart';
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

            if (stats != null && !stats.inventoryReachable) ...[
              InfoBanner(
                title: l10n.dashboardInventoryDownTitle,
                message: l10n.dashboardInventoryDownMessage,
                tone: BannerTone.warning,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            _MetricGrid(stats: stats, isLoading: state.isLoading),
            const SizedBox(height: AppSpacing.xl),
            _Panels(stats: stats, isLoading: state.isLoading),
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
        label: l10n.dashboardMetricRevenue,
        value: stats?.revenue.formatCompact(locale: locale) ?? '—',
        icon: Icons.payments_outlined,
        tint: context.semantic.success,
        isLoading: isLoading,
      ),
      MetricCard(
        label: l10n.dashboardMetricProducts,
        value: NumberFormatter.count(stats?.productCount ?? 0, locale),
        icon: Icons.inventory_2_outlined,
        tint: context.semantic.info,
        isLoading: isLoading,
        onTap: () => context.go(Routes.products),
      ),
      MetricCard(
        label: l10n.dashboardMetricLowStock,
        value: NumberFormatter.count(stats?.lowStockCount ?? 0, locale),
        icon: Icons.warning_amber_rounded,
        tint: context.semantic.warning,
        isLoading: isLoading,
        onTap: () => context.go(Routes.inventory),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth) {
          < 560 => 1,
          < 980 => 2,
          _ => 4,
        };
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

class _Panels extends StatelessWidget {
  const _Panels({required this.stats, required this.isLoading});

  final DashboardStats? stats;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final breakdown = AppCard(
      title: l10n.dashboardOrdersByStatus,
      clipBody: true,
      child: isLoading || stats == null
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: TableSkeleton(rows: 5, columns: 2),
            )
          : StatusBreakdown(ordersByStatus: stats!.ordersByStatus),
    );

    final revenue = AppCard(
      title: l10n.dashboardRevenueTrend,
      clipBody: true,
      child: isLoading || stats == null
          ? const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: SkeletonBox(height: 200, radius: AppRadius.md),
            )
          : RevenueChart(days: stats!.revenueByDay),
    );

    if (context.isCompact) {
      return Column(
        children: [
          breakdown,
          const SizedBox(height: AppSpacing.xl),
          revenue,
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 2, child: breakdown),
          const SizedBox(width: AppSpacing.xl),
          Expanded(flex: 3, child: revenue),
        ],
      ),
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
