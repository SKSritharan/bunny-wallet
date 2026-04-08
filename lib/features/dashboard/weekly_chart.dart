import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/core/theme/app_colors.dart';
import 'package:bunny_wallet/core/utils/date_helpers.dart';
import 'package:bunny_wallet/data/providers/providers.dart';

final _weeklyDataProvider = FutureProvider<Map<String, double>>((ref) {
  ref.watch(transactionRefreshProvider);
  final days = DateHelpers.last7Days();
  final start = days.first;
  final end = DateTime(days.last.year, days.last.month, days.last.day, 23, 59, 59);
  return ref.read(transactionRepoProvider).getDailyTotals(start, end);
});

class WeeklyChart extends ConsumerWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_weeklyDataProvider);
    final days = DateHelpers.last7Days();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Week', style: context.textTheme.titleSmall),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: dataAsync.when(
                data: (data) => _buildChart(context, data, days),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
      BuildContext context, Map<String, double> data, List<DateTime> days) {
    final maxY = data.values.fold<double>(
          0,
          (max, v) => v.abs() > max ? v.abs() : max,
        ) *
        1.3;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY == 0 ? 100 : maxY,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) =>
                context.isDark ? AppColors.darkSurfaceVariant : Colors.white,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= days.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateHelpers.formatDayOfWeek(days[idx]),
                    style: context.textTheme.labelSmall,
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(days.length, (i) {
          final key =
              '${days[i].year}-${days[i].month}-${days[i].day}';
          final value = (data[key] ?? 0).abs();
          final isExpense = (data[key] ?? 0) < 0;

          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: value == 0 ? 2 : value,
                color: isExpense
                    ? AppColors.expense.withValues(alpha: 0.7)
                    : AppColors.income.withValues(alpha: 0.7),
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
