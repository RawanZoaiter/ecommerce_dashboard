import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/dashboard_stats.dart';

/// Revenue for the last seven days.
class RevenueChart extends StatelessWidget {
  const RevenueChart({required this.days, super.key});

  final List<DailyRevenue> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox(height: 220);

    final maxMinor = days
        .map((day) => day.amount.minorUnits)
        .reduce((a, b) => a > b ? a : b);

    // A flat zero week would divide by zero and draw nothing; give the axis a
    // nominal ceiling so the empty bars still render at the baseline.
    final maxY = maxMinor == 0 ? 1.0 : maxMinor / 100;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            maxY: maxY * 1.2,
            alignment: BarChartAlignment.spaceAround,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: maxY / 2,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: context.semantic.border, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= days.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        DateFormatter.weekdayShort(
                          days[index].day,
                          context.localeName,
                        ),
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => context.colors.inverseSurface,
                getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                  days[group.x].amount.format(locale: context.localeName),
                  context.text.bodySmall!.copyWith(
                    color: context.colors.onInverseSurface,
                  ),
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < days.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: days[i].amount.minorUnits / 100,
                      width: 18,
                      color: context.colors.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.sm),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
