import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/analytics/application/analytics_page_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final asyncState = ref.watch(analyticsPageControllerProvider);
    final controller = ref.read(analyticsPageControllerProvider.notifier);
    final state = asyncState.valueOrNull;

    if (asyncState.isLoading && state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.analyticsTitle)),
        body: const SizedBox.shrink(),
      );
    }

    final dailyMap = state.dailyEffectiveMinutes();
    final dailyEntries =
        dailyMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final hourlyHeat = state.hourlyEfficiency();
    final periodDistribution = state.periodEfficiencyDistribution();
    final goalContribution = state.goalContribution();

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(l10n.analyticsTitle),
              ),
            ],
        body: RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView(
            padding: LayoutTokens.listPagePadding,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<AnalyticsRange>(
                  selected: {state.range},
                  segments: [
                    ButtonSegment(
                      value: AnalyticsRange.day,
                      label: Text(l10n.analyticsRangeDay),
                    ),
                    ButtonSegment(
                      value: AnalyticsRange.week,
                      label: Text(l10n.analyticsRangeWeek),
                    ),
                    ButtonSegment(
                      value: AnalyticsRange.month,
                      label: Text(l10n.analyticsRangeMonth),
                    ),
                    ButtonSegment(
                      value: AnalyticsRange.year,
                      label: Text(l10n.analyticsRangeYear),
                    ),
                  ],
                  onSelectionChanged: (selection) {
                    controller.setRange(selection.first);
                  },
                ),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              Card(
                child: ListTile(
                  title: Text(l10n.analyticsTotalFocus),
                  subtitle: Text(formatMinutes(state.totalEffectiveMinutes)),
                  trailing: Text(
                    analyticsChangeLabel(state.changeRatio),
                    style: TextStyle(
                      color:
                          state.changeRatio >= 0 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              _SectionCard(
                title: l10n.analyticsDailyBar,
                child: SizedBox(
                  height: 220,
                  child:
                      dailyEntries.isEmpty
                          ? Center(child: Text(l10n.goalsNoSearchResult))
                          : BarChart(
                            BarChartData(
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 ||
                                          index >= dailyEntries.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Text(
                                        DateFormat(
                                          'MM/dd',
                                        ).format(dailyEntries[index].key),
                                        style: theme.textTheme.labelSmall,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: [
                                for (var i = 0; i < dailyEntries.length; i++)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: dailyEntries[i].value,
                                        width: 14,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                ),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              _SectionCard(
                title: l10n.analyticsHeatmap,
                child: Wrap(
                  spacing: LayoutTokens.compactGap,
                  runSpacing: LayoutTokens.compactGap,
                  children: [
                    for (var hour = 0; hour < 24; hour++)
                      _HeatCell(
                        hour: hour,
                        intensity: normalizeHeat(hourlyHeat[hour] ?? 0),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              _SectionCard(
                title: l10n.analyticsEfficiencyPeriod,
                child: Column(
                  children: [
                    _EfficiencyRow(
                      label: l10n.analyticsMorning,
                      value: periodDistribution['morning'] ?? 0,
                    ),
                    _EfficiencyRow(
                      label: l10n.analyticsAfternoon,
                      value: periodDistribution['afternoon'] ?? 0,
                    ),
                    _EfficiencyRow(
                      label: l10n.analyticsEvening,
                      value: periodDistribution['evening'] ?? 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              _SectionCard(
                title: l10n.analyticsGoalContribution,
                child: SizedBox(
                  height: 240,
                  child:
                      goalContribution.isEmpty
                          ? Center(child: Text(l10n.goalsNoSearchResult))
                          : PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 30,
                              sections: _buildGoalSections(
                                context,
                                labelStyle: theme.textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                state: state,
                                contribution: goalContribution,
                              ),
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildGoalSections(
    BuildContext context, {
    required TextStyle? labelStyle,
    required AnalyticsPageState state,
    required Map<int, double> contribution,
  }) {
    final entries =
        contribution.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.redAccent,
    ];
    return [
      for (var i = 0; i < entries.length; i++)
        PieChartSectionData(
          value: entries[i].value,
          title: state.labelForGoal(entries[i].key),
          color: colors[i % colors.length],
          radius: 68,
          titleStyle: labelStyle,
        ),
    ];
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LayoutTokens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: LayoutTokens.sectionGap),
            child,
          ],
        ),
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.hour, required this.intensity});

  final int hour;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(Colors.grey.shade200, Colors.orange, intensity);

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        hour.toString().padLeft(2, '0'),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _EfficiencyRow extends StatelessWidget {
  const _EfficiencyRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: LayoutTokens.sectionGap),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0, 1).toDouble(),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: LayoutTokens.compactGap),
          Text('${value.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}
