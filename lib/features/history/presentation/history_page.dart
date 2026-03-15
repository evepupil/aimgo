import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/core/widgets/app_confirm_dialog.dart';
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
              ? RefreshIndicator(
                onRefresh: controller.refresh,
                child: _SearchResultsView(
                  state: data,
                  onEdit: _openEditSessionSheet,
                ),
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
                      child: _HistoryViewModeTabs(
                        selectedMode: data.viewMode,
                        onModeChanged: controller.setViewMode,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final sheetTheme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              LayoutTokens.pageHorizontal,
              0,
              LayoutTokens.pageHorizontal,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                      Expanded(
                        child: Text(
                          l10n.goalsFilterTooltip,
                          textAlign: TextAlign.center,
                          style: sheetTheme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: LayoutTokens.sectionGap),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    l10n.historyGoalFilter,
                    style: sheetTheme.textTheme.bodySmall?.copyWith(
                      color: sheetTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: LayoutTokens.tainCardDecoration(sheetTheme),
                  child: Padding(
                    padding: const EdgeInsets.all(LayoutTokens.cardPadding),
                    child: DropdownButtonFormField<int?>(
                      value: data.goalFilterId,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l10n.historyAllGoals),
                        ),
                        for (final goal in data.goalOptions)
                          DropdownMenuItem(
                            value: goal.id,
                            child: Text(goal.title),
                          ),
                      ],
                      onChanged: controller.setGoalFilter,
                    ),
                  ),
                ),
                const SizedBox(height: LayoutTokens.sectionGapLarge),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    l10n.historyRangeFilter,
                    style: sheetTheme.textTheme.bodySmall?.copyWith(
                      color: sheetTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: LayoutTokens.tainCardDecoration(sheetTheme),
                  child: Padding(
                    padding: const EdgeInsets.all(LayoutTokens.cardPadding),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _RangeChip(
                          selected: data.rangeFilter == HistoryRangeFilter.all,
                          label: l10n.historyRangeAll,
                          onTap:
                              () => controller.setRangeFilter(
                                HistoryRangeFilter.all,
                              ),
                        ),
                        _RangeChip(
                          selected:
                              data.rangeFilter == HistoryRangeFilter.today,
                          label: l10n.historyRangeToday,
                          onTap:
                              () => controller.setRangeFilter(
                                HistoryRangeFilter.today,
                              ),
                        ),
                        _RangeChip(
                          selected:
                              data.rangeFilter == HistoryRangeFilter.thisWeek,
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
                          selected:
                              data.rangeFilter == HistoryRangeFilter.custom,
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
                  ),
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
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
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

class _HistoryViewModeTabs extends StatelessWidget {
  const _HistoryViewModeTabs({
    required this.selectedMode,
    required this.onModeChanged,
  });

  final HistoryViewMode selectedMode;
  final void Function(HistoryViewMode) onModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _HistoryModeSegment(
      selectedMode: selectedMode,
      timelineLabel: l10n.historyTimelineTab,
      calendarLabel: l10n.historyCalendarTab,
      onModeChanged: onModeChanged,
    );
  }
}

class _HistoryModeSegment extends StatelessWidget {
  const _HistoryModeSegment({
    required this.selectedMode,
    required this.timelineLabel,
    required this.calendarLabel,
    required this.onModeChanged,
  });

  final HistoryViewMode selectedMode;
  final String timelineLabel;
  final String calendarLabel;
  final void Function(HistoryViewMode mode) onModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _HistoryModeSegmentItem(
                label: timelineLabel,
                selected: selectedMode == HistoryViewMode.timeline,
                onTap: () => onModeChanged(HistoryViewMode.timeline),
              ),
            ),
            Expanded(
              child: _HistoryModeSegmentItem(
                label: calendarLabel,
                selected: selectedMode == HistoryViewMode.calendar,
                onTap: () => onModeChanged(HistoryViewMode.calendar),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryModeSegmentItem extends StatelessWidget {
  const _HistoryModeSegmentItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.10)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color:
                selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SearchResultsView extends StatelessWidget {
  const _SearchResultsView({required this.state, required this.onEdit});

  final HistoryPageState state;
  final void Function(HistorySessionEntry entry) onEdit;

  @override
  Widget build(BuildContext context) {
    final results = state.filteredSessions;
    if (results.isEmpty) {
      return ListView(
        padding: LayoutTokens.listPagePadding,
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
      itemCount: results.length,
      itemBuilder: (context, index) {
        final entry = results[index];
        return _HistorySessionCard(
          entry: entry,
          onEdit: () => onEdit(entry),
        );
      },
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                LayoutTokens.cardPadding,
                8,
                LayoutTokens.cardPadding,
                LayoutTokens.cardPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 28,
                      height: 3,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.24,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.historyEditTitle,
                    style: theme.textTheme.titleMedium,
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
                      style: theme.textTheme.bodySmall,
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
                          foregroundColor: theme.colorScheme.error,
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
    final confirm = await showAppConfirmDialog(
      context: context,
      title: l10n.historyDeleteConfirmTitle,
      message: l10n.historyDeleteConfirmMessage,
      confirmText: l10n.commonDelete,
      cancelText: l10n.commonCancel,
      destructive: true,
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
        final totalMinutes = section.sessions.fold<int>(
          0,
          (sum, item) => sum + item.session.durationMinutes,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TimelineSectionHeader(
              title: _timelineSectionTitle(context, section.groupKey),
              sessionCount: section.sessions.length,
              totalMinutes: totalMinutes,
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

class _TimelineSectionHeader extends StatelessWidget {
  const _TimelineSectionHeader({
    required this.title,
    required this.sessionCount,
    required this.totalMinutes,
  });

  final String title;
  final int sessionCount;
  final int totalMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(
        top: LayoutTokens.compactGap,
        bottom: LayoutTokens.compactGap,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${l10n.analyticsSummarySessions} $sessionCount · ${formatMinutes(totalMinutes)}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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

    return DecoratedBox(
      decoration: LayoutTokens.tainCardDecoration(Theme.of(context)),
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
    final theme = Theme.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final session = entry.session;
    final title =
        entry.pathLabel.isNotEmpty
            ? entry.pathLabel
            : (entry.taskTitle ??
                entry.milestoneTitle ??
                entry.goalTitle ??
                l10n.focusContextEmpty);
    final timeRange =
        '${DateFormat.yMMMd(localeName).format(session.startedAt)} · ${DateFormat.Hm(localeName).format(session.startedAt)}-${DateFormat.Hm(localeName).format(session.endedAt)}';
    final note = (session.note ?? '').trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: LayoutTokens.sectionGap),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onEdit,
          child: DecoratedBox(
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
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _SessionStatusBadge(isAbandoned: session.isAbandoned),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeRange,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HistoryMetricPill(
                        label: _compactHistoryMetricLabel(
                          context,
                          type: _CompactHistoryMetricType.duration,
                          value: formatMinutes(session.durationMinutes),
                        ),
                      ),
                      _HistoryMetricPill(
                        label: _compactHistoryMetricLabel(
                          context,
                          type: _CompactHistoryMetricType.efficiency,
                          value: '${session.efficiencyPercent}%',
                        ),
                      ),
                      _HistoryMetricPill(
                        label: _compactHistoryMetricLabel(
                          context,
                          type: _CompactHistoryMetricType.effective,
                          value: formatMinutes(session.effectiveMinutes),
                        ),
                      ),
                    ],
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryMetricPill extends StatelessWidget {
  const _HistoryMetricPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(LayoutTokens.radiusMedium),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary.withValues(alpha: 0.92),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

enum _CompactHistoryMetricType { duration, efficiency, effective }

String _compactHistoryMetricLabel(
  BuildContext context, {
  required _CompactHistoryMetricType type,
  required String value,
}) {
  final languageCode = Localizations.localeOf(context).languageCode;
  final prefix = switch ((languageCode, type)) {
    ('zh', _CompactHistoryMetricType.duration) => '时长',
    ('zh', _CompactHistoryMetricType.efficiency) => '效率',
    ('zh', _CompactHistoryMetricType.effective) => '有效',
    (_, _CompactHistoryMetricType.duration) => 'Time',
    (_, _CompactHistoryMetricType.efficiency) => 'Eff.',
    (_, _CompactHistoryMetricType.effective) => 'Effective',
  };
  return '$prefix $value';
}

class _SessionStatusBadge extends StatelessWidget {
  const _SessionStatusBadge({required this.isAbandoned});

  final bool isAbandoned;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bgColor =
        isAbandoned ? const Color(0xFFFCEEEE) : const Color(0xFFEEF8F0);
    final textColor =
        isAbandoned ? const Color(0xFFB71C1C) : const Color(0xFF1B5E20);
    final dotColor =
        isAbandoned ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
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
