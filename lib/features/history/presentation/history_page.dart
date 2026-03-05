import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/history/application/history_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({this.initialGoalFilterId, super.key});

  final int? initialGoalFilterId;

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _searchMode = false;
  bool _initialFilterApplied = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncState = ref.watch(historyPageControllerProvider);
    final controller = ref.read(historyPageControllerProvider.notifier);
    final data = asyncState.valueOrNull;

    if (!_initialFilterApplied &&
        data != null &&
        widget.initialGoalFilterId != null) {
      _initialFilterApplied = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        controller.setGoalFilter(widget.initialGoalFilterId);
      });
    }

    if (asyncState.isLoading && data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar:
          _searchMode
              ? AppBar(
                title: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.goalsSearchHint,
                    border: InputBorder.none,
                  ),
                  onChanged: controller.setSearchQuery,
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      controller.setSearchQuery('');
                      setState(() {
                        _searchMode = false;
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              )
              : AppBar(
                title: Text(l10n.historyTitle),
                actions: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _searchMode = true;
                        _searchController.text = data?.searchQuery ?? '';
                      });
                    },
                    icon: const Icon(Icons.search),
                    tooltip: l10n.goalsSearchHint,
                  ),
                  IconButton(
                    onPressed: () => _openFilterSheet(data),
                    icon: const Icon(Icons.filter_list),
                    tooltip: l10n.goalsFilterTooltip,
                  ),
                ],
              ),
      body:
          data == null
              ? const SizedBox.shrink()
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<HistoryViewMode>(
                        selected: {data.viewMode},
                        segments: [
                          ButtonSegment(
                            value: HistoryViewMode.timeline,
                            icon: const Icon(Icons.timeline),
                            label: Text(l10n.historyTimelineTab),
                          ),
                          ButtonSegment(
                            value: HistoryViewMode.calendar,
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: Text(l10n.historyCalendarTab),
                          ),
                        ],
                        onSelectionChanged: (selection) {
                          controller.setViewMode(selection.first);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.refresh,
                      child:
                          data.viewMode == HistoryViewMode.timeline
                              ? _TimelineView(state: data)
                              : _CalendarView(
                                state: data,
                                onDateSelected:
                                    controller.setSelectedCalendarDate,
                              ),
                    ),
                  ),
                ],
              ),
    );
  }

  Future<void> _openFilterSheet(HistoryPageState? data) async {
    if (data == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(historyPageControllerProvider.notifier);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                Text(
                  l10n.historyGoalFilter,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  value: data.goalFilterId,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.historyAllGoals),
                    ),
                    for (final goal in data.goalOptions)
                      DropdownMenuItem(value: goal.id, child: Text(goal.title)),
                  ],
                  onChanged: controller.setGoalFilter,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.historyRangeFilter,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RangeChip(
                      selected: data.rangeFilter == HistoryRangeFilter.all,
                      label: l10n.historyRangeAll,
                      onTap:
                          () =>
                              controller.setRangeFilter(HistoryRangeFilter.all),
                    ),
                    _RangeChip(
                      selected: data.rangeFilter == HistoryRangeFilter.today,
                      label: l10n.historyRangeToday,
                      onTap:
                          () => controller.setRangeFilter(
                            HistoryRangeFilter.today,
                          ),
                    ),
                    _RangeChip(
                      selected: data.rangeFilter == HistoryRangeFilter.thisWeek,
                      label: l10n.historyRangeThisWeek,
                      onTap:
                          () => controller.setRangeFilter(
                            HistoryRangeFilter.thisWeek,
                          ),
                    ),
                    _RangeChip(
                      selected:
                          data.rangeFilter == HistoryRangeFilter.thisMonth,
                      label: l10n.historyRangeThisMonth,
                      onTap:
                          () => controller.setRangeFilter(
                            HistoryRangeFilter.thisMonth,
                          ),
                    ),
                    _RangeChip(
                      selected: data.rangeFilter == HistoryRangeFilter.custom,
                      label: l10n.historyRangeCustom,
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDateRange:
                              data.customRangeStart != null &&
                                      data.customRangeEnd != null
                                  ? DateTimeRange(
                                    start: data.customRangeStart!,
                                    end: data.customRangeEnd!,
                                  )
                                  : null,
                        );
                        if (picked != null) {
                          await controller.setCustomDateRange(
                            picked.start,
                            picked.end,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onTap(),
    );
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView({required this.state});

  final HistoryPageState state;

  @override
  Widget build(BuildContext context) {
    final sections = state.buildTimelineSections();
    if (sections.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(AppLocalizations.of(context)!.goalsNoSearchResult),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _timelineSectionTitle(context, section.groupKey),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (var i = 0; i < section.sessions.length; i++)
              _TimelineSessionItem(
                entry: section.sessions[i],
                isLast: i == section.sessions.length - 1,
              ),
          ],
        );
      },
    );
  }
}

class _TimelineSessionItem extends StatelessWidget {
  const _TimelineSessionItem({required this.entry, required this.isLast});

  final HistorySessionEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.8);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _HistorySessionCard(entry: entry)),
        ],
      ),
    );
  }
}

String _timelineSectionTitle(BuildContext context, String groupKey) {
  final l10n = AppLocalizations.of(context)!;
  switch (groupKey) {
    case 'today':
      return l10n.historyGroupToday;
    case 'yesterday':
      return l10n.historyGroupYesterday;
    case 'this_week':
      return l10n.historyGroupThisWeek;
    case 'last_week':
      return l10n.historyGroupLastWeek;
    default:
      if (groupKey.startsWith('date:')) {
        return groupKey.substring(5);
      }
      return groupKey;
  }
}

class _CalendarView extends StatefulWidget {
  const _CalendarView({required this.state, required this.onDateSelected});

  final HistoryPageState state;
  final void Function(DateTime date) onDateSelected;

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = _monthStartOf(widget.state.selectedCalendarDate);
  }

  @override
  void didUpdateWidget(covariant _CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedMonth = _monthStartOf(widget.state.selectedCalendarDate);
    if (!_isSameMonth(selectedMonth, _visibleMonth)) {
      _visibleMonth = selectedMonth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = widget.state.sessionsOfSelectedDate();
    final recordDates =
        widget.state.filteredSessions
            .map((entry) => _dayStart(entry.session.startedAt))
            .toSet();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _MonthCalendar(
          visibleMonth: _visibleMonth,
          selectedDate: widget.state.selectedCalendarDate,
          recordDates: recordDates,
          onPrevMonth: () => _changeMonth(-1),
          onNextMonth: () => _changeMonth(1),
          onDateSelected: widget.onDateSelected,
        ),
        const SizedBox(height: 12),
        Text(
          DateFormat('yyyy-MM-dd').format(widget.state.selectedCalendarDate),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(AppLocalizations.of(context)!.goalsNoSearchResult),
          ),
        for (final session in sessions) _HistorySessionCard(entry: session),
      ],
    );
  }

  void _changeMonth(int monthDelta) {
    final updatedMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + monthDelta,
      1,
    );
    setState(() {
      _visibleMonth = updatedMonth;
    });
    if (!_isSameMonth(widget.state.selectedCalendarDate, updatedMonth)) {
      widget.onDateSelected(updatedMonth);
    }
  }

  static DateTime _monthStartOf(DateTime value) {
    return DateTime(value.year, value.month, 1);
  }

  static DateTime _dayStart(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static bool _isSameMonth(DateTime left, DateTime right) {
    return left.year == right.year && left.month == right.month;
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.visibleMonth,
    required this.selectedDate,
    required this.recordDates,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final Set<DateTime> recordDates;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final void Function(DateTime date) onDateSelected;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final leadingEmptyCells = firstDay.weekday - 1;
    final daysInMonth =
        DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final totalCells = ((leadingEmptyCells + daysInMonth + 6) ~/ 7) * 7;
    final today = DateTime.now();
    final weekDayLabels = [
      for (var i = 0; i < 7; i++)
        DateFormat.E(locale).format(DateTime(2024, 1, 1 + i)),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onPrevMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    DateFormat('yyyy-MM', locale).format(visibleMonth),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (final label in weekDayLabels)
                  Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalCells,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.08,
              ),
              itemBuilder: (context, index) {
                if (index < leadingEmptyCells) {
                  return const SizedBox.shrink();
                }

                final day = index - leadingEmptyCells + 1;
                if (day > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final date = DateTime(
                  visibleMonth.year,
                  visibleMonth.month,
                  day,
                );
                final isToday = _isSameDay(date, today);
                final isSelected = _isSameDay(date, selectedDate);
                final hasRecord = recordDates.contains(date);
                final colorScheme = Theme.of(context).colorScheme;

                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onDateSelected(date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? colorScheme.primary
                                : isToday
                                ? colorScheme.outline
                                : Colors.transparent,
                        width: isSelected ? 2 : 1,
                      ),
                      color:
                          isSelected
                              ? colorScheme.primary.withValues(alpha: 0.08)
                              : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 6,
                          height: 6,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  hasRecord
                                      ? colorScheme.primary
                                      : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

class _HistorySessionCard extends StatelessWidget {
  const _HistorySessionCard({required this.entry});

  final HistorySessionEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = entry.session;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.taskTitle ??
                  entry.milestoneTitle ??
                  entry.goalTitle ??
                  l10n.focusContextEmpty,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            if (entry.pathLabel.isNotEmpty)
              Text(
                entry.pathLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 6),
            Text(
              '${DateFormat('HH:mm').format(session.startedAt)} - ${DateFormat('HH:mm').format(session.endedAt)}',
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.evaluationDuration}: ${formatMinutes(session.durationMinutes)}',
            ),
            Text(
              '${l10n.evaluationEfficiencyLabel(session.efficiencyPercent.toString())} · ${l10n.evaluationEffectiveDuration}: ${formatMinutes(session.effectiveMinutes)}',
            ),
            Text(
              session.isAbandoned
                  ? l10n.historyStatusAbandoned
                  : l10n.historyStatusCompleted,
            ),
          ],
        ),
      ),
    );
  }
}
