import 'dart:math' as math;

import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
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
              dateLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Text(l10n.homeTodayOverview, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              formatMinutes(effectiveMinutes),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
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
                Text(l10n.homeCurrentGoal, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Text(l10n.goalsNoGoal),
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
              Text(l10n.homeCurrentGoal, style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),
              Text(
                summary!.goal.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$progressPercent%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${formatMinutes(summary!.goal.effectiveMinutes)} / ${formatMinutes(summary!.goal.estimateMinutes)}',
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _OverflowProgressBar(progressRatio: summary!.goal.progressRatio),
              const SizedBox(height: 12),
              Text(
                l10n.homeCompletedMilestones(
                  '${summary!.completedMilestones}',
                  '${summary!.totalMilestones}',
                ),
                style: theme.textTheme.bodyMedium,
              ),
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
            Text(l10n.homeLastFocus, style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            if (entry == null) ...[
              Text(
                l10n.homeLastFocusEmptyTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.homeLastFocusEmptySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              Text(entry!.title, style: theme.textTheme.titleMedium),
              if (entry!.path.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  entry!.path,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '${DateFormat.yMMMd(localeName).format(entry!.session.startedAt)}  ${DateFormat.Hm(localeName).format(entry!.session.startedAt)} - ${DateFormat.Hm(localeName).format(entry!.session.endedAt)}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricChip(
                    label: formatMinutes(entry!.session.durationMinutes),
                  ),
                  _MetricChip(
                    label: l10n.homeEfficiency(
                      entry!.session.efficiencyPercent.toString(),
                    ),
                  ),
                  _MetricChip(
                    label: l10n.homeEffective(
                      entry!.session.effectiveMinutes.round().toString(),
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

class HomeHeatmapCard extends StatefulWidget {
  const HomeHeatmapCard({required this.days, super.key});

  final List<HeatmapDayPoint> days;

  @override
  State<HomeHeatmapCard> createState() => _HomeHeatmapCardState();
}

class _HomeHeatmapCardState extends State<HomeHeatmapCard> {
  static const double _cellSize = 12;
  static const double _gap = 4;
  static const double _rowExtent = _cellSize + _gap;

  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final today = _normalizeDate(DateTime.now());
    final weeks = _buildWeeks(widget.days);
    final monthLabels = _buildMonthLabels(widget.days, localeName);
    final gridWidth =
        weeks.isEmpty
            ? 0.0
            : weeks.length * _cellSize + (weeks.length - 1) * _gap;

    return _HomePanel(
      child: Padding(
        padding: const EdgeInsets.all(LayoutTokens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeHeatmapTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.homeHeatmapSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: _rowExtent),
                    child: _WeekdayLegend(
                      localeName: localeName,
                      cellSize: _cellSize,
                      gap: _gap,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: _rowExtent,
                        width: gridWidth,
                        child: Stack(
                          children: [
                            for (final label in monthLabels)
                              Positioned(
                                left: label.offset,
                                child: Text(
                                  label.label,
                                  style: Theme.of(context).textTheme.labelSmall,
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
                                            dayIndex == weeks[index].length - 1
                                                ? 0
                                                : _gap,
                                      ),
                                      child: _HeatCell(
                                        day: weeks[index][dayIndex],
                                        size: _cellSize,
                                        today: today,
                                        isSelected:
                                            _selectedDate ==
                                            _normalizeDate(
                                              weeks[index][dayIndex].date,
                                            ),
                                        onTap:
                                            () => _handleTap(
                                              context,
                                              weeks[index][dayIndex],
                                            ),
                                        tooltipMessage: l10n.homeHeatmapDetail(
                                          DateFormat.yMMMd(
                                            localeName,
                                          ).format(weeks[index][dayIndex].date),
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
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, HeatmapDayPoint day) {
    setState(() {
      _selectedDate = _normalizeDate(day.date);
    });
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
                      colors: [Colors.orange.shade300, Colors.orange.shade700],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: theme.textTheme.labelSmall),
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
    final languageCode = localeName.split('-').first;
    final labels =
        languageCode == 'zh'
            ? const ['一', '二', '三', '四', '五', '六', '日']
            : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        for (var index = 0; index < labels.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == labels.length - 1 ? 0 : gap,
            ),
            child: SizedBox(
              height: cellSize,
              width: 20,
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    labels[index],
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 1,
                    softWrap: false,
                  ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
    final isFuture = dayDate.isAfter(today);
    final isToday = dayDate == today;
    final emptyPastColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final emptyFutureColor =
        isDark ? Colors.grey.shade900 : Colors.grey.shade100;
    final value = day.effectiveMinutes;
    final color = switch (_level(value)) {
      0 => isFuture ? emptyFutureColor : emptyPastColor,
      1 => const Color(0xFFDBE8FE),
      2 => const Color(0xFFA3C4FD),
      3 => const Color(0xFF5B9BF8),
      _ => const Color(0xFF2563EB),
    };
    return Tooltip(
      message: tooltipMessage,
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: false,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color:
                  isSelected
                      ? colorScheme.primary
                      : isToday
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: isSelected ? 1.8 : (isToday ? 1.4 : 0.6),
            ),
          ),
        ),
      ),
    );
  }

  int _level(double value) {
    if (value <= 0) {
      return 0;
    }
    if (value < 30) {
      return 1;
    }
    if (value < 60) {
      return 2;
    }
    if (value < 120) {
      return 3;
    }
    return 4;
  }
}

final class _MonthLabel {
  const _MonthLabel({required this.offset, required this.label});

  final double offset;
  final String label;
}
