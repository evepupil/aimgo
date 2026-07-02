import 'dart:math' as math;

import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/theme/daybook_extension.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/core/widgets/remaining_days_text.dart';
import 'package:aimgo/features/home/application/home_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeTodayOverviewCard extends StatelessWidget {
  const HomeTodayOverviewCard({
    required this.dateLabel,
    required this.effectiveMinutes,
    super.key,
  });

  final String dateLabel;
  final double effectiveMinutes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return _HomePanel(
      child: Padding(
        padding: const EdgeInsets.all(LayoutTokens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateLabel.toUpperCase(),
              style: LayoutTokens.daybookEyebrow(context),
            ),
            const SizedBox(height: 14),
            Text(
              formatMinutes(effectiveMinutes),
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 40,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.homeTodayEffectiveFocus,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeCurrentGoalCard extends StatelessWidget {
  const HomeCurrentGoalCard({
    required this.summary,
    required this.onOpenGoals,
    super.key,
  });

  final CurrentGoalSummary? summary;
  final VoidCallback onOpenGoals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (summary == null) {
      return _HomePanel(
        child: InkWell(
          onTap: onOpenGoals,
          borderRadius: BorderRadius.circular(LayoutTokens.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(LayoutTokens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeCurrentGoal.toUpperCase(),
                  style: LayoutTokens.daybookEyebrow(context),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.goalsNoGoal,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onOpenGoals,
                  child: Text(l10n.homeOpenGoals),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final progressPercent = (summary!.goal.progressRatio * 100).round();
    return _HomePanel(
      child: InkWell(
        onTap: onOpenGoals,
        borderRadius: BorderRadius.circular(LayoutTokens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeCurrentGoal.toUpperCase(),
                style: LayoutTokens.daybookEyebrow(context),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      summary!.goal.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (summary!.estimatedRemainingDays != null) ...[
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: RemainingDaysText(
                        days: summary!.estimatedRemainingDays!,
                        baseStyle: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        highlightColor: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      '$progressPercent%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${formatMinutes(summary!.goal.effectiveMinutes)} / ${formatMinutes(summary!.goal.estimateMinutes)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.88,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _OverflowProgressBar(progressRatio: summary!.goal.progressRatio),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeLastSessionCard extends StatelessWidget {
  const HomeLastSessionCard({
    required this.entry,
    required this.onContinue,
    super.key,
  });

  final RecentSessionEntry? entry;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    return _HomePanel(
      child: Padding(
        padding: const EdgeInsets.all(LayoutTokens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeLastFocus.toUpperCase(),
              style: LayoutTokens.daybookEyebrow(context),
            ),
            const SizedBox(height: 10),
            if (entry == null) ...[
              Text(
                l10n.homeLastFocusEmptyTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.homeLastFocusEmptySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              Text(
                entry!.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry!.path.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  entry!.path,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.72,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                '${DateFormat.yMMMd(localeName).format(entry!.session.startedAt)} · ${DateFormat.Hm(localeName).format(entry!.session.startedAt)}-${DateFormat.Hm(localeName).format(entry!.session.endedAt)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.68,
                  ),
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricChip(
                    label: _compactSessionMetricLabel(
                      context,
                      type: _CompactSessionMetricType.duration,
                      value: formatMinutes(entry!.session.durationMinutes),
                    ),
                  ),
                  _MetricChip(
                    label: _compactSessionMetricLabel(
                      context,
                      type: _CompactSessionMetricType.efficiency,
                      value: '${entry!.session.efficiencyPercent}%',
                    ),
                  ),
                  _MetricChip(
                    label: _compactSessionMetricLabel(
                      context,
                      type: _CompactSessionMetricType.effective,
                      value: formatMinutes(entry!.session.effectiveMinutes),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      LayoutTokens.radiusMedium,
                    ),
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                child: Text(
                  entry == null ? l10n.homeStartFocus : l10n.homeContinueFocus,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CompactSessionMetricType { duration, efficiency, effective }

String _compactSessionMetricLabel(
  BuildContext context, {
  required _CompactSessionMetricType type,
  required String value,
}) {
  final languageCode = Localizations.localeOf(context).languageCode;
  final prefix = switch ((languageCode, type)) {
    ('zh', _CompactSessionMetricType.duration) => '时长',
    ('zh', _CompactSessionMetricType.efficiency) => '效率',
    ('zh', _CompactSessionMetricType.effective) => '有效',
    (_, _CompactSessionMetricType.duration) => 'Time',
    (_, _CompactSessionMetricType.efficiency) => 'Eff.',
    (_, _CompactSessionMetricType.effective) => 'Effective',
  };
  return '$prefix $value';
}

class HomeHeatmapCard extends StatefulWidget {
  const HomeHeatmapCard({required this.days, super.key});

  final List<HeatmapDayPoint> days;

  @override
  State<HomeHeatmapCard> createState() => _HomeHeatmapCardState();
}

class _HomeHeatmapCardState extends State<HomeHeatmapCard> {
  static const double _cellSize = 12;
  static const double _gap = 3;
  static const double _rowExtent = _cellSize + _gap;

  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final today = _normalizeDate(DateTime.now());
    final selectedDate = _resolveSelectedDate(today);
    final selectedPoint =
        selectedDate == null ? null : _findPointByDate(selectedDate);
    final weeks = _buildWeeks(widget.days);
    final monthLabels = _buildMonthLabels(widget.days, localeName);
    final gridWidth =
        weeks.isEmpty
            ? 0.0
            : weeks.length * _cellSize + (weeks.length - 1) * _gap;
    final daybook = DaybookColors.of(context);
    final heatmapSectionColor = daybook.paperWell;
    final infoSectionColor = daybook.accentSofter;

    return _HomePanel(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    l10n.homeHeatmapTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _HeatmapLegend(
                  lowLabel: l10n.homeHeatmapLegendLow,
                  highLabel: l10n.homeHeatmapLegendHigh,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.homeHeatmapSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              decoration: BoxDecoration(
                color: heatmapSectionColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: _rowExtent - 1),
                      child: _WeekdayLegend(
                        localeName: localeName,
                        cellSize: _cellSize,
                        gap: _gap,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: _rowExtent - 1,
                          width: gridWidth,
                          child: Stack(
                            children: [
                              for (final label in monthLabels)
                                Positioned(
                                  left: label.offset,
                                  child: Text(
                                    label.label,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 10,
                                      color: colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.62),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var index = 0; index < weeks.length; index++)
                              Padding(
                                padding: EdgeInsets.only(
                                  right: index == weeks.length - 1 ? 0 : _gap,
                                ),
                                child: Column(
                                  children: [
                                    for (
                                      var dayIndex = 0;
                                      dayIndex < weeks[index].length;
                                      dayIndex++
                                    )
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom:
                                              dayIndex ==
                                                      weeks[index].length - 1
                                                  ? 0
                                                  : _gap,
                                        ),
                                        child: _HeatCell(
                                          day: weeks[index][dayIndex],
                                          size: _cellSize,
                                          today: today,
                                          isSelected:
                                              selectedDate ==
                                              _normalizeDate(
                                                weeks[index][dayIndex].date,
                                              ),
                                          onTap:
                                              () => _handleTap(
                                                weeks[index][dayIndex],
                                              ),
                                          tooltipMessage: l10n
                                              .homeHeatmapDetail(
                                                DateFormat.yMMMd(
                                                  localeName,
                                                ).format(
                                                  weeks[index][dayIndex].date,
                                                ),
                                                formatMinutes(
                                                  weeks[index][dayIndex]
                                                      .effectiveMinutes,
                                                ),
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (selectedPoint != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: infoSectionColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      DateFormat.MMMd(localeName).format(selectedPoint.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.homeHeatmapSelectedFocus(
                          formatMinutes(selectedPoint.effectiveMinutes),
                        ),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleTap(HeatmapDayPoint day) {
    setState(() {
      _selectedDate = _normalizeDate(day.date);
    });
  }

  DateTime? _resolveSelectedDate(DateTime today) {
    if (_selectedDate != null) {
      return _selectedDate;
    }

    final todayPoint = _findPointByDate(today);
    if (todayPoint != null) {
      return _normalizeDate(todayPoint.date);
    }

    for (var index = widget.days.length - 1; index >= 0; index--) {
      final candidate = _normalizeDate(widget.days[index].date);
      if (!candidate.isAfter(today)) {
        return candidate;
      }
    }

    return widget.days.isEmpty ? null : _normalizeDate(widget.days.last.date);
  }

  HeatmapDayPoint? _findPointByDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    for (final day in widget.days) {
      if (_normalizeDate(day.date) == normalizedDate) {
        return day;
      }
    }
    return null;
  }

  List<List<HeatmapDayPoint>> _buildWeeks(List<HeatmapDayPoint> source) {
    if (source.isEmpty) {
      return const [];
    }

    final valuesByDay = {
      for (final day in source)
        DateTime(day.date.year, day.date.month, day.date.day): day,
    };

    final firstSourceDay = source.first.date;
    final lastSourceDay = source.last.date;
    final alignedStart = firstSourceDay.subtract(
      Duration(days: firstSourceDay.weekday - 1),
    );
    final alignedEnd = lastSourceDay.add(
      Duration(days: DateTime.daysPerWeek - lastSourceDay.weekday),
    );

    final aligned = <HeatmapDayPoint>[];
    for (
      var day = alignedStart;
      !day.isAfter(alignedEnd);
      day = day.add(const Duration(days: 1))
    ) {
      aligned.add(
        valuesByDay[DateTime(day.year, day.month, day.day)] ??
            HeatmapDayPoint(date: day, effectiveMinutes: 0),
      );
    }

    return [
      for (var index = 0; index < aligned.length; index += 7)
        aligned.sublist(index, index + 7),
    ];
  }

  List<_MonthLabel> _buildMonthLabels(
    List<HeatmapDayPoint> source,
    String localeName,
  ) {
    if (source.isEmpty) {
      return const [];
    }

    final labels = <_MonthLabel>[];
    final firstVisibleDay = source.first.date.subtract(
      Duration(days: source.first.date.weekday - 1),
    );
    final lastVisibleDay = source.last;
    var monthCursor = DateTime(
      source.first.date.year,
      source.first.date.month,
      1,
    );

    while (!monthCursor.isAfter(lastVisibleDay.date)) {
      final weekIndex = monthCursor.difference(firstVisibleDay).inDays ~/ 7;
      labels.add(
        _MonthLabel(
          offset: weekIndex * (_cellSize + _gap),
          label: DateFormat.MMM(localeName).format(monthCursor),
        ),
      );

      monthCursor = DateTime(monthCursor.year, monthCursor.month + 1, 1);
    }

    return labels;
  }

  DateTime _normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

class _HomePanel extends StatelessWidget {
  const _HomePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: LayoutTokens.tainCardDecoration(Theme.of(context)),
      child: child,
    );
  }
}

class _OverflowProgressBar extends StatelessWidget {
  const _OverflowProgressBar({required this.progressRatio});

  final double progressRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = progressRatio.clamp(0, 1).toDouble();
    final overflow = math.max(progressRatio - 1, 0);
    return SizedBox(
      height: 10,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          FractionallySizedBox(
            widthFactor: clamped,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          if (overflow > 0)
            Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: math.min(overflow, 1).toDouble(),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        DaybookColors.of(context).overflow,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daybook = DaybookColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: daybook.accentSoft,
        borderRadius: BorderRadius.circular(LayoutTokens.radiusSmall),
        border: Border.all(color: daybook.rule),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend({required this.lowLabel, required this.highLabel});

  final String lowLabel;
  final String highLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final daybook = DaybookColors.of(context);
    final ramp = daybook.heatmapRamp;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          lowLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 2),
        Icon(
          Icons.arrow_right_alt_rounded,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 2),
        Text(
          highLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        for (var index = 0; index < ramp.length; index++)
          Padding(
            padding: EdgeInsets.only(right: index == ramp.length - 1 ? 0 : 3),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: ramp[index],
                borderRadius: BorderRadius.circular(2.5),
                border: Border.all(color: daybook.rule),
              ),
            ),
          ),
      ],
    );
  }
}

class _WeekdayLegend extends StatelessWidget {
  const _WeekdayLegend({
    required this.localeName,
    required this.cellSize,
    required this.gap,
  });

  final String localeName;
  final double cellSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final languageCode = localeName.split('-').first;
    final labels =
        languageCode == 'zh'
            ? const ['\u4e00', '', '\u4e09', '', '\u4e94', '', '\u65e5']
            : const ['Mon', '', 'Wed', '', 'Fri', '', 'Sun'];

    return Column(
      children: [
        for (var index = 0; index < labels.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == labels.length - 1 ? 0 : gap,
            ),
            child: SizedBox(
              height: cellSize,
              width: 22,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  labels[index],
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.68),
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({
    required this.day,
    required this.size,
    required this.today,
    required this.isSelected,
    required this.onTap,
    required this.tooltipMessage,
  });

  final HeatmapDayPoint day;
  final double size;
  final DateTime today;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltipMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final daybook = DaybookColors.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
    final isFuture = dayDate.isAfter(today);
    final isToday = dayDate == today;
    final value = day.effectiveMinutes;
    final ramp = daybook.heatmapRamp;
    final color = switch (_level(value)) {
      0 => daybook.heatmapEmpty,
      1 => ramp[0],
      2 => ramp[1],
      3 => ramp[2],
      4 => ramp[3],
      _ => ramp[4],
    };
    // 未来日期淡化，不参与「已完成」暖阶。
    final resolvedColor =
        isFuture
            ? daybook.heatmapEmpty.withValues(alpha: isDark ? 0.5 : 0.6)
            : color;

    return Tooltip(
      message: tooltipMessage,
      triggerMode: TooltipTriggerMode.longPress,
      preferBelow: false,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: resolvedColor,
            borderRadius: BorderRadius.circular(3.5),
            border: Border.all(
              color:
                  isSelected
                      ? colorScheme.primary
                      : isToday
                      ? colorScheme.outline.withValues(alpha: 0.58)
                      : colorScheme.outlineVariant.withValues(alpha: 0.28),
              width: isSelected ? 1.6 : (isToday ? 0.9 : 0.6),
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.14),
                        blurRadius: 0,
                        spreadRadius: 0.8,
                      ),
                    ]
                    : null,
          ),
        ),
      ),
    );
  }

  int _level(double value) {
    if (value <= 0) {
      return 0;
    }
    if (value < 20) {
      return 1;
    }
    if (value < 45) {
      return 2;
    }
    if (value < 90) {
      return 3;
    }
    if (value < 150) {
      return 4;
    }
    return 5;
  }
}

final class _MonthLabel {
  const _MonthLabel({required this.offset, required this.label});

  final double offset;
  final String label;
}
