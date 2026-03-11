import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/analytics/application/analytics_page_controller.dart';
import 'package:aimgo/shared/models/planning_models.dart';
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

    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final trendBuckets = _buildTrendBuckets(
      range: state.range,
      sessions: state.currentSessions,
      localeTag: localeTag,
    );
    final hourlyHeat = state.hourlyEfficiency();
    final periodDistribution = state.periodEfficiencyDistribution();
    final goalContribution = state.goalContribution();
    final goalChartData = _buildGoalChartData(state, goalContribution);

    final sessionCount = state.currentSessions.length;
    final completedCount =
        state.currentSessions.where((session) => !session.isAbandoned).length;
    final abandonedCount = sessionCount - completedCount;
    final averageEfficiency =
        sessionCount == 0
            ? 0
            : state.currentSessions.fold<int>(
                  0,
                  (sum, session) => sum + session.efficiencyPercent,
                ) /
                sessionCount;
    final modeMinutes = state.modeEffectiveMinutes();
    final pomodoroMinutes = modeMinutes[FocusSessionMode.pomodoro] ?? 0;
    final freeMinutes = modeMinutes[FocusSessionMode.free] ?? 0;
    final totalModeMinutes = pomodoroMinutes + freeMinutes;
    final pomodoroRatio =
        totalModeMinutes <= 0 ? 0 : (pomodoroMinutes / totalModeMinutes) * 100;
    final freeRatio =
        totalModeMinutes <= 0 ? 0 : (freeMinutes / totalModeMinutes) * 100;

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
              _AnalyticsTabBar(
                selectedRange: state.range,
                onRangeChanged: controller.setRange,
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              _SummaryCard(
                totalFocusLabel: l10n.analyticsTotalFocus,
                totalFocusValue: formatMinutes(state.totalEffectiveMinutes),
                changeLabel: analyticsChangeLabel(state.changeRatio),
                isPositive: state.changeRatio >= 0,
                sessionsLabel: l10n.analyticsSummarySessions,
                sessionsValue: sessionCount.toString(),
                efficiencyLabel: l10n.analyticsSummaryAvgEfficiency,
                efficiencyValue: '${averageEfficiency.toStringAsFixed(1)}%',
                completedLabel: l10n.historyStatusCompleted,
                completedValue: completedCount.toString(),
                abandonedLabel: l10n.historyStatusAbandoned,
                abandonedValue: abandonedCount.toString(),
                pomodoroLabel: l10n.focusModePomodoro,
                pomodoroValue:
                    '${pomodoroRatio.toStringAsFixed(0)}% · ${formatMinutes(pomodoroMinutes)}',
                freeLabel: l10n.focusModeFree,
                freeValue:
                    '${freeRatio.toStringAsFixed(0)}% · ${formatMinutes(freeMinutes)}',
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              _SectionCard(
                title: l10n.analyticsSectionTrend,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _trendSubtitle(l10n, state.range),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: LayoutTokens.compactGap),
                    SizedBox(
                      height: 240,
                      child:
                          trendBuckets.isEmpty
                              ? Center(child: Text(l10n.goalsNoSearchResult))
                              : _TrendChart(buckets: trendBuckets, l10n: l10n),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              _SectionCard(
                title: l10n.analyticsSectionDistribution,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionSubHeader(label: l10n.analyticsHeatmap),
                    const SizedBox(height: 6),
                    _HeatLegend(
                      lowLabel: l10n.analyticsHeatLegendLow,
                      highLabel: l10n.analyticsHeatLegendHigh,
                    ),
                    const SizedBox(height: LayoutTokens.compactGap),
                    _HeatPeriodRow(
                      label: l10n.analyticsMorning,
                      hours: const [5, 6, 7, 8, 9, 10, 11],
                      hourlyHeat: hourlyHeat,
                    ),
                    const SizedBox(height: 10),
                    _HeatPeriodRow(
                      label: l10n.analyticsAfternoon,
                      hours: const [12, 13, 14, 15, 16, 17],
                      hourlyHeat: hourlyHeat,
                    ),
                    const SizedBox(height: 10),
                    _HeatPeriodRow(
                      label: l10n.analyticsEvening,
                      hours: const [18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 4],
                      hourlyHeat: hourlyHeat,
                    ),
                    const SizedBox(height: LayoutTokens.sectionGap),
                    Divider(color: theme.colorScheme.outlineVariant),
                    const SizedBox(height: LayoutTokens.compactGap),
                    _SectionSubHeader(label: l10n.analyticsEfficiencyPeriod),
                    const SizedBox(height: 6),
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
                      isLast: true,
                    ),
                    const SizedBox(height: LayoutTokens.sectionGap),
                    Divider(color: theme.colorScheme.outlineVariant),
                    const SizedBox(height: LayoutTokens.compactGap),
                    _SectionSubHeader(label: l10n.analyticsGoalContribution),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 230,
                      child:
                          goalChartData.isEmpty
                              ? Center(child: Text(l10n.goalsNoSearchResult))
                              : PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 34,
                                  sections: [
                                    for (final item in goalChartData)
                                      PieChartSectionData(
                                        value: item.minutes,
                                        title:
                                            item.percent >= 8
                                                ? '${item.percent.toStringAsFixed(0)}%'
                                                : '',
                                        color: item.color,
                                        radius: 66,
                                        titleStyle: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                    ),
                    if (goalChartData.isNotEmpty) ...[
                      const SizedBox(height: LayoutTokens.compactGap),
                      for (final item in goalChartData)
                        _GoalLegendRow(
                          color: item.color,
                          title: item.title,
                          minutesLabel: formatMinutes(item.minutes),
                          percentLabel: '${item.percent.toStringAsFixed(1)}%',
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<_GoalChartItem> _buildGoalChartData(
    AnalyticsPageState state,
    Map<int, double> contribution,
  ) {
    final entries =
        contribution.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final colors = [
      const Color(0xFF2F6FED),
      const Color(0xFF19A974),
      const Color(0xFFFF8C42),
      const Color(0xFF5E60CE),
      const Color(0xFF1B9AAA),
      const Color(0xFFD94862),
    ];
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);

    return [
      for (var i = 0; i < entries.length; i++)
        _GoalChartItem(
          title: state.labelForGoal(entries[i].key),
          minutes: entries[i].value,
          percent: total <= 0 ? 0 : (entries[i].value / total) * 100,
          color: colors[i % colors.length],
        ),
    ];
  }

  static String _trendSubtitle(AppLocalizations l10n, AnalyticsRange range) {
    switch (range) {
      case AnalyticsRange.day:
      case AnalyticsRange.week:
        return l10n.analyticsDailyBar;
      case AnalyticsRange.month:
        return '${l10n.analyticsDailyBar} (${l10n.analyticsRangeWeek})';
      case AnalyticsRange.year:
        return '${l10n.analyticsDailyBar} (${l10n.analyticsRangeMonth})';
    }
  }

  static List<_TrendBucket> _buildTrendBuckets({
    required AnalyticsRange range,
    required List<FocusSessionModel> sessions,
    required String localeTag,
  }) {
    final now = DateTime.now();
    switch (range) {
      case AnalyticsRange.day:
        final dayStart = DateTime(now.year, now.month, now.day);
        final dayEnd = dayStart.add(const Duration(days: 1));
        final daySessions = sessions
            .where(
              (session) =>
                  !session.startedAt.isBefore(dayStart) &&
                  session.startedAt.isBefore(dayEnd),
            )
            .toList(growable: false);
        return [
          _bucketFromSessions(
            axisLabel: DateFormat('MM/dd', localeTag).format(dayStart),
            tooltipLabel: DateFormat('yyyy-MM-dd', localeTag).format(dayStart),
            start: dayStart,
            end: dayEnd,
            sessions: daySessions,
            isCurrent: true,
            showAxisLabel: true,
          ),
        ];
      case AnalyticsRange.week:
        final today = DateTime(now.year, now.month, now.day);
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final buckets = <_TrendBucket>[];
        const weekAxisLabels = ['一', '二', '三', '四', '五', '六', '日'];
        for (var i = 0; i < 7; i++) {
          final start = weekStart.add(Duration(days: i));
          final end = start.add(const Duration(days: 1));
          final daySessions = sessions
              .where(
                (session) =>
                    !session.startedAt.isBefore(start) &&
                    session.startedAt.isBefore(end),
              )
              .toList(growable: false);
          buckets.add(
            _bucketFromSessions(
              axisLabel: weekAxisLabels[i],
              tooltipLabel: DateFormat('MM/dd', localeTag).format(start),
              start: start,
              end: end,
              sessions: daySessions,
              isCurrent:
                  now.isAtSameMomentAs(start) ||
                  (!now.isBefore(start) && now.isBefore(end)),
              showAxisLabel: true,
            ),
          );
        }
        return buckets;
      case AnalyticsRange.month:
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 1);
        final buckets = <_TrendBucket>[];
        var cursor = monthStart;
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        while (cursor.isBefore(monthEnd)) {
          final next = cursor.add(const Duration(days: 1));
          final daySessions = sessions
              .where(
                (session) =>
                    !session.startedAt.isBefore(cursor) &&
                    session.startedAt.isBefore(next),
              )
              .toList(growable: false);
          final day = cursor.day;
          buckets.add(
            _bucketFromSessions(
              axisLabel: '$day',
              tooltipLabel: DateFormat('MM/dd', localeTag).format(cursor),
              start: cursor,
              end: next,
              sessions: daySessions,
              isCurrent:
                  now.isAtSameMomentAs(cursor) ||
                  (!now.isBefore(cursor) && now.isBefore(next)),
              showAxisLabel: day == 1 || day % 5 == 0 || day == daysInMonth,
            ),
          );
          cursor = next;
        }
        return buckets;
      case AnalyticsRange.year:
        final yearStart = DateTime(now.year, 1, 1);
        final buckets = <_TrendBucket>[];
        for (var month = 1; month <= 12; month++) {
          final start = DateTime(yearStart.year, month, 1);
          final end = DateTime(yearStart.year, month + 1, 1);
          final monthSessions = sessions
              .where(
                (session) =>
                    !session.startedAt.isBefore(start) &&
                    session.startedAt.isBefore(end),
              )
              .toList(growable: false);
          buckets.add(
            _bucketFromSessions(
              axisLabel: month.toString(),
              tooltipLabel: DateFormat.MMMM(localeTag).format(start),
              start: start,
              end: end,
              sessions: monthSessions,
              isCurrent: now.year == start.year && now.month == start.month,
              showAxisLabel: true,
            ),
          );
        }
        return buckets;
    }
  }

  static _TrendBucket _bucketFromSessions({
    required String axisLabel,
    required String tooltipLabel,
    required DateTime start,
    required DateTime end,
    required List<FocusSessionModel> sessions,
    required bool isCurrent,
    required bool showAxisLabel,
  }) {
    final sessionCount = sessions.length;
    var totalMinutes = 0.0;
    var totalEfficiency = 0;
    for (final session in sessions) {
      totalMinutes += session.effectiveMinutes;
      totalEfficiency += session.efficiencyPercent;
    }
    final averageEfficiency =
        sessionCount == 0 ? 0.0 : totalEfficiency / sessionCount;
    return _TrendBucket(
      axisLabel: axisLabel,
      tooltipLabel: tooltipLabel,
      start: start,
      end: end,
      totalMinutes: totalMinutes,
      sessionCount: sessionCount,
      averageEfficiency: averageEfficiency,
      isCurrent: isCurrent,
      showAxisLabel: showAxisLabel,
    );
  }
}

class _AnalyticsTabBar extends StatelessWidget {
  const _AnalyticsTabBar({
    required this.selectedRange,
    required this.onRangeChanged,
  });

  final AnalyticsRange selectedRange;
  final void Function(AnalyticsRange) onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final labels = {
      AnalyticsRange.day: l10n.analyticsRangeDay,
      AnalyticsRange.week: l10n.analyticsRangeWeek,
      AnalyticsRange.month: l10n.analyticsRangeMonth,
      AnalyticsRange.year: l10n.analyticsRangeYear,
    };

    return DecoratedBox(
      decoration: LayoutTokens.tainCardDecoration(theme),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final range in AnalyticsRange.values)
              Expanded(
                child: GestureDetector(
                  onTap: () => onRangeChanged(range),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          selectedRange == range
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      labels[range]!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            selectedRange == range
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            selectedRange == range
                                ? FontWeight.w700
                                : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalFocusLabel,
    required this.totalFocusValue,
    required this.changeLabel,
    required this.isPositive,
    required this.sessionsLabel,
    required this.sessionsValue,
    required this.efficiencyLabel,
    required this.efficiencyValue,
    required this.completedLabel,
    required this.completedValue,
    required this.abandonedLabel,
    required this.abandonedValue,
    required this.pomodoroLabel,
    required this.pomodoroValue,
    required this.freeLabel,
    required this.freeValue,
  });

  final String totalFocusLabel;
  final String totalFocusValue;
  final String changeLabel;
  final bool isPositive;
  final String sessionsLabel;
  final String sessionsValue;
  final String efficiencyLabel;
  final String efficiencyValue;
  final String completedLabel;
  final String completedValue;
  final String abandonedLabel;
  final String abandonedValue;
  final String pomodoroLabel;
  final String pomodoroValue;
  final String freeLabel;
  final String freeValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: LayoutTokens.tainCardDecoration(theme),
      child: Padding(
        padding: const EdgeInsets.all(LayoutTokens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        totalFocusLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        totalFocusValue,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isPositive
                            ? const Color(0xFFEAF6EC)
                            : const Color(0xFFFFF2E8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    changeLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color:
                          isPositive
                              ? const Color(0xFF1B5E20)
                              : const Color(0xFFB26A00),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: sessionsLabel,
                    value: sessionsValue,
                  ),
                ),
                const SizedBox(width: LayoutTokens.compactGap),
                Expanded(
                  child: _SummaryMetric(
                    label: efficiencyLabel,
                    value: efficiencyValue,
                  ),
                ),
                const SizedBox(width: LayoutTokens.compactGap),
                Expanded(
                  child: _SummaryMetric(
                    label: completedLabel,
                    value: completedValue,
                  ),
                ),
                const SizedBox(width: LayoutTokens.compactGap),
                Expanded(
                  child: _SummaryMetric(
                    label: abandonedLabel,
                    value: abandonedValue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.compactGap),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: pomodoroLabel,
                    value: pomodoroValue,
                  ),
                ),
                const SizedBox(width: LayoutTokens.compactGap),
                Expanded(
                  child: _SummaryMetric(label: freeLabel, value: freeValue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.buckets, required this.l10n});

  final List<_TrendBucket> buckets;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = buckets
        .map((entry) => entry.totalMinutes)
        .fold<double>(0, (max, value) => value > max ? value : max);
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.inverseSurface,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex < 0 || groupIndex >= buckets.length) {
                return null;
              }
              final bucket = buckets[groupIndex];
              return BarTooltipItem(
                '${bucket.tooltipLabel}\n'
                '${formatMinutes(bucket.totalMinutes)}\n'
                '${l10n.analyticsSummarySessions}: ${bucket.sessionCount}\n'
                '${l10n.analyticsSummaryAvgEfficiency}: ${bucket.averageEfficiency.toStringAsFixed(1)}%',
                theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                    ) ??
                    TextStyle(
                      color: theme.colorScheme.onInverseSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
              );
            },
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: maxY / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: theme.textTheme.labelSmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= buckets.length) {
                  return const SizedBox.shrink();
                }
                if (!buckets[index].showAxisLabel) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    buckets[index].axisLabel,
                    style: theme.textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < buckets.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: buckets[i].totalMinutes,
                  width: buckets.length > 20 ? 8 : 12,
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors:
                        buckets[i].isCurrent
                            ? const [Color(0xFFAFC6FF), Color(0xFF5A8BFF)]
                            : const [Color(0xFF8FB1FF), Color(0xFF2F6FED)],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: LayoutTokens.tainCardDecoration(theme),
      child: Padding(
        padding: const EdgeInsets.all(LayoutTokens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: LayoutTokens.sectionGap),
            child,
          ],
        ),
      ),
    );
  }
}

class _SectionSubHeader extends StatelessWidget {
  const _SectionSubHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _HeatLegend extends StatelessWidget {
  const _HeatLegend({required this.lowLabel, required this.highLabel});

  final String lowLabel;
  final String highLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(lowLabel, style: theme.textTheme.labelSmall),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [Colors.grey.shade200, const Color(0xFFFF8C42)],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(highLabel, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _HeatPeriodRow extends StatelessWidget {
  const _HeatPeriodRow({
    required this.label,
    required this.hours,
    required this.hourlyHeat,
  });

  final String label;
  final List<int> hours;
  final Map<int, double> hourlyHeat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final hour in hours) ...[
                _HeatCell(
                  hour: hour,
                  intensity: normalizeHeat(hourlyHeat[hour] ?? 0),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
      ],
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
      width: 32,
      height: 32,
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
  const _EfficiencyRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final double value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        top: 6,
        bottom: isLast ? 0 : LayoutTokens.compactGap,
      ),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (value / 100).clamp(0, 1).toDouble(),
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: LayoutTokens.compactGap),
          SizedBox(
            width: 48,
            child: Text(
              '${value.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalLegendRow extends StatelessWidget {
  const _GoalLegendRow({
    required this.color,
    required this.title,
    required this.minutesLabel,
    required this.percentLabel,
  });

  final Color color;
  final String title;
  final String minutesLabel;
  final String percentLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            minutesLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            percentLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalChartItem {
  const _GoalChartItem({
    required this.title,
    required this.minutes,
    required this.percent,
    required this.color,
  });

  final String title;
  final double minutes;
  final double percent;
  final Color color;
}

class _TrendBucket {
  const _TrendBucket({
    required this.axisLabel,
    required this.tooltipLabel,
    required this.start,
    required this.end,
    required this.totalMinutes,
    required this.sessionCount,
    required this.averageEfficiency,
    required this.isCurrent,
    required this.showAxisLabel,
  });

  final String axisLabel;
  final String tooltipLabel;
  final DateTime start;
  final DateTime end;
  final double totalMinutes;
  final int sessionCount;
  final double averageEfficiency;
  final bool isCurrent;
  final bool showAxisLabel;
}
