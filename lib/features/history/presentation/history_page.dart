import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/focus/application/focus_context_provider.dart';
import 'package:aimgo/features/focus/application/focus_models.dart';
import 'package:aimgo/features/history/application/history_page_controller.dart';
import 'package:aimgo/shared/models/planning_models.dart';
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
              : null,
      body:
          data == null
              ? const SizedBox.shrink()
              : _searchMode
              ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      LayoutTokens.pageHorizontal,
                      LayoutTokens.pageTop,
                      LayoutTokens.pageHorizontal,
                      LayoutTokens.compactGap,
                    ),
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
                              ? _TimelineView(
                                state: data,
                                onEdit: _openEditSessionSheet,
                              )
                              : _CalendarView(
                                state: data,
                                onDateSelected:
                                    controller.setSelectedCalendarDate,
                                onEdit: _openEditSessionSheet,
                              ),
                    ),
                  ),
                ],
              )
              : NestedScrollView(
                headerSliverBuilder:
                    (context, innerBoxIsScrolled) => [
                      SliverAppBar(
                        floating: true,
                        snap: true,
                        title: Text(l10n.historyTitle),
                        actions: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _searchMode = true;
                                _searchController.text = data.searchQuery;
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
                    ],
                body: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        LayoutTokens.pageHorizontal,
                        LayoutTokens.pageTop,
                        LayoutTokens.pageHorizontal,
                        LayoutTokens.compactGap,
                      ),
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
                                ? _TimelineView(
                                  state: data,
                                  onEdit: _openEditSessionSheet,
                                )
                                : _CalendarView(
                                  state: data,
                                  onDateSelected:
                                      controller.setSelectedCalendarDate,
                                  onEdit: _openEditSessionSheet,
                                ),
                      ),
                    ),
                  ],
                ),
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
            padding: const EdgeInsets.all(LayoutTokens.cardPadding),
            child: Wrap(
              children: [
                Text(
                  l10n.historyGoalFilter,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: LayoutTokens.compactGap),
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
                const SizedBox(height: LayoutTokens.sectionGap),
                Text(
                  l10n.historyRangeFilter,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: LayoutTokens.compactGap),
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

  Future<void> _openEditSessionSheet(HistorySessionEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(historyPageControllerProvider.notifier);
    List<FocusHierarchyItem> hierarchy;
    try {
      hierarchy = await ref.read(focusHierarchyProvider.future);
    } catch (_) {
      hierarchy = const <FocusHierarchyItem>[];
    }

    if (!mounted) {
      return;
    }

    final result = await showModalBottomSheet<_HistoryEditResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _HistorySessionEditSheet(entry: entry, hierarchy: hierarchy);
      },
    );
    if (!mounted || result == null) {
      return;
    }

    try {
      if (result.deleteRequested) {
        await controller.deleteSession(entry.session.id);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.historyDeleteSuccess)));
        }
        return;
      }
      await controller.updateSession(
        sessionId: entry.session.id,
        goalId: result.goalId,
        milestoneId: result.milestoneId,
        taskId: result.taskId,
        focusTargetLevel: result.focusTargetLevel,
        efficiencyPercent: result.efficiencyPercent,
        note: result.note,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.historyEditSaved)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.deleteRequested
                  ? l10n.historyDeleteFailed(error.toString())
                  : l10n.historyEditFailed(error.toString()),
            ),
          ),
        );
      }
    }
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

class _HistoryEditResult {
  const _HistoryEditResult({
    required this.goalId,
    required this.milestoneId,
    required this.taskId,
    required this.focusTargetLevel,
    required this.efficiencyPercent,
    required this.note,
    this.deleteRequested = false,
  });

  final int? goalId;
  final int? milestoneId;
  final int? taskId;
  final FocusTargetLevel focusTargetLevel;
  final int efficiencyPercent;
  final String? note;
  final bool deleteRequested;
}

class _HistorySessionEditSheet extends StatefulWidget {
  const _HistorySessionEditSheet({
    required this.entry,
    required this.hierarchy,
  });

  final HistorySessionEntry entry;
  final List<FocusHierarchyItem> hierarchy;

  @override
  State<_HistorySessionEditSheet> createState() =>
      _HistorySessionEditSheetState();
}

class _HistorySessionEditSheetState extends State<_HistorySessionEditSheet> {
  late final List<_HistoryTargetOption> _targetOptions;
  _HistoryTargetOption? _selectedTarget;
  late final TextEditingController _efficiencyController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _targetOptions = _buildTargetOptions(widget.hierarchy);
    _selectedTarget = _findMatchingTarget(_targetOptions, widget.entry.session);
    if (_selectedTarget == null &&
        (widget.entry.session.goalId != null ||
            widget.entry.session.milestoneId != null ||
            widget.entry.session.taskId != null)) {
      final fallback = _HistoryTargetOption(
        label:
            widget.entry.pathLabel.isEmpty
                ? widget.entry.session.focusTargetLevel.name
                : widget.entry.pathLabel,
        goalId: widget.entry.session.goalId,
        milestoneId: widget.entry.session.milestoneId,
        taskId: widget.entry.session.taskId,
        focusTargetLevel: widget.entry.session.focusTargetLevel,
      );
      _targetOptions.insert(0, fallback);
      _selectedTarget = fallback;
    }
    _efficiencyController = TextEditingController(
      text: widget.entry.session.efficiencyPercent.toString(),
    );
    _noteController = TextEditingController(
      text: widget.entry.session.note ?? '',
    );
  }

  @override
  void dispose() {
    _efficiencyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final insets = MediaQuery.viewInsetsOf(context);
    final hasTargetOptions = _targetOptions.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.historyEditTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              if (hasTargetOptions) ...[
                DropdownButtonFormField<_HistoryTargetOption>(
                  value: _selectedTarget,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.historyEditTarget,
                  ),
                  items: [
                    for (final option in _targetOptions)
                      DropdownMenuItem<_HistoryTargetOption>(
                        value: option,
                        child: Text(
                          option.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedTarget = value;
                    });
                  },
                ),
              ] else ...[
                Text(
                  l10n.goalsNoGoal,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: LayoutTokens.sectionGap),
              TextField(
                controller: _efficiencyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.historyEditEfficiency,
                ),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: l10n.historyEditNote),
              ),
              const SizedBox(height: LayoutTokens.sectionGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _confirmDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.commonDelete),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.commonCancel),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed:
                            () => _submit(hasTargetOptions: hasTargetOptions),
                        child: Text(l10n.commonSave),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit({required bool hasTargetOptions}) {
    final l10n = AppLocalizations.of(context)!;
    final efficiency = int.tryParse(_efficiencyController.text.trim());
    if (efficiency == null || efficiency < 0 || efficiency > 100) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.focusManualInvalidInput)));
      return;
    }

    final selectedTarget = _selectedTarget;
    if (hasTargetOptions && selectedTarget == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.focusManualInvalidInput)));
      return;
    }

    Navigator.of(context).pop(
      _HistoryEditResult(
        goalId:
            selectedTarget == null
                ? widget.entry.session.goalId
                : selectedTarget.goalId,
        milestoneId:
            selectedTarget == null
                ? widget.entry.session.milestoneId
                : selectedTarget.milestoneId,
        taskId:
            selectedTarget == null
                ? widget.entry.session.taskId
                : selectedTarget.taskId,
        focusTargetLevel:
            selectedTarget == null
                ? widget.entry.session.focusTargetLevel
                : selectedTarget.focusTargetLevel,
        efficiencyPercent: efficiency,
        note:
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.historyDeleteConfirmTitle),
          content: Text(l10n.historyDeleteConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
    if (confirm != true || !mounted) {
      return;
    }
    Navigator.of(context).pop(
      const _HistoryEditResult(
        goalId: null,
        milestoneId: null,
        taskId: null,
        focusTargetLevel: FocusTargetLevel.goal,
        efficiencyPercent: 0,
        note: null,
        deleteRequested: true,
      ),
    );
  }

  static List<_HistoryTargetOption> _buildTargetOptions(
    List<FocusHierarchyItem> hierarchy,
  ) {
    final options = <_HistoryTargetOption>[];
    for (final goal in hierarchy) {
      options.add(
        _HistoryTargetOption(
          label: goal.goal.title,
          goalId: goal.goal.id,
          milestoneId: null,
          taskId: null,
          focusTargetLevel: FocusTargetLevel.goal,
        ),
      );
      for (final milestone in goal.milestones) {
        options.add(
          _HistoryTargetOption(
            label: '${goal.goal.title} > ${milestone.milestone.title}',
            goalId: goal.goal.id,
            milestoneId: milestone.milestone.id,
            taskId: null,
            focusTargetLevel: FocusTargetLevel.milestone,
          ),
        );
        for (final task in milestone.tasks) {
          options.add(
            _HistoryTargetOption(
              label:
                  '${goal.goal.title} > ${milestone.milestone.title} > ${task.title}',
              goalId: goal.goal.id,
              milestoneId: milestone.milestone.id,
              taskId: task.id,
              focusTargetLevel: FocusTargetLevel.task,
            ),
          );
        }
      }
    }
    return options;
  }

  static _HistoryTargetOption? _findMatchingTarget(
    List<_HistoryTargetOption> options,
    FocusSessionModel session,
  ) {
    for (final option in options) {
      if (option.focusTargetLevel != session.focusTargetLevel) {
        continue;
      }
      if (option.goalId != session.goalId) {
        continue;
      }
      if (option.milestoneId != session.milestoneId) {
        continue;
      }
      if (option.taskId != session.taskId) {
        continue;
      }
      return option;
    }
    return null;
  }
}

class _HistoryTargetOption {
  const _HistoryTargetOption({
    required this.label,
    required this.goalId,
    required this.milestoneId,
    required this.taskId,
    required this.focusTargetLevel,
  });

  final String label;
  final int? goalId;
  final int? milestoneId;
  final int? taskId;
  final FocusTargetLevel focusTargetLevel;
}

class _TimelineView extends StatelessWidget {
  const _TimelineView({required this.state, required this.onEdit});

  final HistoryPageState state;
  final void Function(HistorySessionEntry entry) onEdit;

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
      padding: LayoutTokens.listPagePadding,
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: LayoutTokens.compactGap,
              ),
              child: Text(
                _timelineSectionTitle(context, section.groupKey),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (var i = 0; i < section.sessions.length; i++)
              _TimelineSessionItem(
                entry: section.sessions[i],
                isLast: i == section.sessions.length - 1,
                onEdit: onEdit,
              ),
          ],
        );
      },
    );
  }
}

class _TimelineSessionItem extends StatelessWidget {
  const _TimelineSessionItem({
    required this.entry,
    required this.isLast,
    required this.onEdit,
  });

  final HistorySessionEntry entry;
  final bool isLast;
  final void Function(HistorySessionEntry entry) onEdit;

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
          const SizedBox(width: LayoutTokens.compactGap),
          Expanded(
            child: _HistorySessionCard(
              entry: entry,
              onEdit: () => onEdit(entry),
            ),
          ),
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
  const _CalendarView({
    required this.state,
    required this.onDateSelected,
    required this.onEdit,
  });

  final HistoryPageState state;
  final void Function(DateTime date) onDateSelected;
  final void Function(HistorySessionEntry entry) onEdit;

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
      padding: LayoutTokens.listPagePadding,
      children: [
        _MonthCalendar(
          visibleMonth: _visibleMonth,
          selectedDate: widget.state.selectedCalendarDate,
          recordDates: recordDates,
          onPrevMonth: () => _changeMonth(-1),
          onNextMonth: () => _changeMonth(1),
          onDateSelected: widget.onDateSelected,
        ),
        const SizedBox(height: LayoutTokens.sectionGap),
        Text(
          DateFormat('yyyy-MM-dd').format(widget.state.selectedCalendarDate),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: LayoutTokens.compactGap),
        if (sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: LayoutTokens.pageBottom,
            ),
            child: Text(AppLocalizations.of(context)!.goalsNoSearchResult),
          ),
        for (final session in sessions)
          _HistorySessionCard(
            entry: session,
            onEdit: () => widget.onEdit(session),
          ),
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
        padding: const EdgeInsets.all(LayoutTokens.cardPadding),
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
            const SizedBox(height: LayoutTokens.compactGap),
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
            const SizedBox(height: LayoutTokens.compactGap),
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
  const _HistorySessionCard({required this.entry, required this.onEdit});

  final HistorySessionEntry entry;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = entry.session;
    final title =
        entry.taskTitle ??
        entry.milestoneTitle ??
        entry.goalTitle ??
        l10n.focusContextEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: LayoutTokens.sectionGap),
      child: Padding(
        padding: const EdgeInsets.all(LayoutTokens.cardPadding),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 84),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  if (entry.pathLabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.pathLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: LayoutTokens.compactGap),
                  Text(
                    '${DateFormat('HH:mm').format(session.startedAt)} - ${DateFormat('HH:mm').format(session.endedAt)}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.evaluationDuration}: ${formatMinutes(session.durationMinutes)}',
                  ),
                  Text(
                    '${l10n.evaluationEfficiencyLabel(session.efficiencyPercent.toString())} | ${l10n.evaluationEffectiveDuration}: ${formatMinutes(session.effectiveMinutes)}',
                  ),
                  if ((session.note ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.evaluationNoteLabel}: ${session.note!.trim()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _SessionStatusBadge(isAbandoned: session.isAbandoned),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: l10n.commonEdit,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionStatusBadge extends StatelessWidget {
  const _SessionStatusBadge({required this.isAbandoned});

  final bool isAbandoned;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bgColor =
        isAbandoned ? const Color(0xFFFDECEC) : const Color(0xFFEAF6EC);
    final borderColor =
        isAbandoned ? const Color(0xFFF3B2B2) : const Color(0xFFB8DDBE);
    final textColor =
        isAbandoned ? const Color(0xFFB71C1C) : const Color(0xFF1B5E20);
    final dotColor =
        isAbandoned ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isAbandoned
                ? l10n.historyStatusAbandoned
                : l10n.historyStatusCompleted,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
