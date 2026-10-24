import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/blood_badge.dart';
import '../providers/dashboard_provider.dart';
import '../data/dashboard_model.dart';

/// Admin Dashboard: KPI metric cards, fl_chart inventory bar chart, and requests donut chart.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh Stats',
            onPressed: () => ref.read(dashboardProvider.notifier).fetchDashboard(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).fetchDashboard(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI STATS CARDS
                _buildKpiGrid(context, data.stats),
                const SizedBox(height: 24),

                // INVENTORY BAR CHART
                _buildInventoryBarChartSection(context, data),
                const SizedBox(height: 24),

                // REQUEST STATUS DONUT CHART
                _buildRequestDonutSection(context, data),
                const SizedBox(height: 24),

                // RECENT EMERGENCY REQUESTS
                _buildRecentRequestsSection(context, data),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        loading: () => const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ShimmerLoading(width: double.infinity, height: 180, borderRadius: 16),
              SizedBox(height: 16),
              ShimmerLoading(width: double.infinity, height: 260, borderRadius: 16),
              SizedBox(height: 16),
              ShimmerLoading(width: double.infinity, height: 240, borderRadius: 16),
            ],
          ),
        ),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.read(dashboardProvider.notifier).fetchDashboard(),
        ),
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, DashboardStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Units',
                value: '${stats.totalUnitsAvailable}',
                icon: Icons.water_drop_rounded,
                color: AppColors.primary,
                subtitle: 'In central bank',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Active Donors',
                value: '${stats.totalDonors}',
                icon: Icons.people_alt_rounded,
                color: AppColors.healthy,
                subtitle: 'Registered donors',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Pending Reqs',
                value: '${stats.pendingRequests}',
                icon: Icons.pending_actions_rounded,
                color: AppColors.low,
                subtitle: 'Awaiting dispatch',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Fulfilled Reqs',
                value: '${stats.fulfilledRequests}',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF0288D1),
                subtitle: 'Successfully closed',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryBarChartSection(BuildContext context, DashboardData data) {
    final theme = Theme.of(context);
    final sortedInv = [...data.inventory]..sort((a, b) => a.bloodGroup.compareTo(b.bloodGroup));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inventory Units by Blood Group',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Bar height represents available unit count',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final bg = sortedInv[group.x.toInt()].bloodGroup;
                      return BarTooltipItem(
                        '$bg\n${rod.toY.toInt()} Units',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, meta) {
                        if (val % 5 == 0) {
                          return Text(
                            val.toInt().toString(),
                            style: const TextStyle(fontSize: 10, color: AppColors.lightTextMuted),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < sortedInv.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              sortedInv[idx].bloodGroup,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white12
                        : AppColors.lightBorder,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: sortedInv.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final barColor = AppColors.getStockColor(item.units);

                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: item.units.toDouble(),
                        color: barColor,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDonutSection(BuildContext context, DashboardData data) {
    final theme = Theme.of(context);

    // Compute request status counts
    int pendingCount = data.stats.pendingRequests;
    int fulfilledCount = data.stats.fulfilledRequests;
    int total = data.stats.totalRequests;
    int otherCount = (total - pendingCount - fulfilledCount).clamp(0, 999);

    final sections = <PieChartSectionData>[
      if (pendingCount > 0)
        PieChartSectionData(
          color: AppColors.low,
          value: pendingCount.toDouble(),
          title: '$pendingCount',
          radius: 38,
          titleStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (fulfilledCount > 0)
        PieChartSectionData(
          color: AppColors.healthy,
          value: fulfilledCount.toDouble(),
          title: '$fulfilledCount',
          radius: 38,
          titleStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (otherCount > 0)
        PieChartSectionData(
          color: const Color(0xFF0288D1),
          value: otherCount.toDouble(),
          title: '$otherCount',
          radius: 38,
          titleStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Requests by Status',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.pie_chart_rounded, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      sections: sections.isEmpty
                          ? [
                              PieChartSectionData(
                                color: Colors.grey.shade400,
                                value: 1,
                                title: '0',
                                radius: 32,
                              )
                            ]
                          : sections,
                      centerSpaceRadius: 36,
                      sectionsSpace: 3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendDot('Pending', AppColors.low, pendingCount),
                    const SizedBox(height: 8),
                    _buildLegendDot('Fulfilled', AppColors.healthy, fulfilledCount),
                    const SizedBox(height: 8),
                    _buildLegendDot('Other', const Color(0xFF0288D1), otherCount),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color, int count) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label ($count)',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRequestsSection(BuildContext context, DashboardData data) {
    final theme = Theme.of(context);

    if (data.recentRequests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Emergency Requests',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.recentRequests.take(4).length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final req = data.recentRequests[index];
            final isPending = req.status.toLowerCase() == 'pending';

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  BloodBadge(bloodGroup: req.bloodGroup, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.patientName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '${req.quantity} Units • ${req.hospital}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending ? AppColors.badgeAmberBg : AppColors.badgeGreenBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      req.status.toUpperCase(),
                      style: TextStyle(
                        color: isPending ? AppColors.low : AppColors.healthy,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
