import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/goals/application/goals_page_controller.dart';
import 'package:aimgo/features/goals/presentation/widgets/goal_switcher_sheet.dart';
import 'package:aimgo/features/goals/presentation/widgets/milestone_card.dart';
import 'package:aimgo/features/goals/presentation/widgets/planning_entry_sheet.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncState = ref.watch(goalsPageControllerProvider);
    final controller = ref.read(goalsPageControllerProvider.notifier);
    final data = asyncState.valueOrNull;

    if (asyncState.isLoading && data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar:
          _isSearching
              ? AppBar(
                title: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: l10n.goalsSearchHint,
                  ),
                  onChanged: (value) => controller.updateSearchQuery(value),
                ),
                leading: const Icon(Icons.search),
                actions: [
                  IconButton(
                    onPressed: () async {
                      _searchController.clear();
                      await controller.clearSearch();
                      if (mounted) {
                        setState(() {
                          _isSearching = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.close),
                    tooltip: l10n.commonClose,
                  ),
                ],
              )
              : null,
      body: Stack(
        children: [
          if (data != null)
            _isSearching
                ? _buildBody(data)
                : NestedScrollView(
                  headerSliverBuilder:
                      (context, innerBoxIsScrolled) => [
                        SliverAppBar(
                          floating: true,
                          snap: true,
                          title: Text(l10n.goalsMyGoalsTitle),
                          actions: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isSearching = true;
                                  _searchController.text = data.searchQuery;
                                });
                              },
                              icon: const Icon(Icons.search),
                              tooltip: l10n.goalsSearchHint,
                            ),
                            IconButton(
                              onPressed: () => _openMenuSheet(data),
                              icon: const Icon(Icons.more_horiz),
                              tooltip: l10n.goalsMenuTooltip,
                            ),
                          ],
                        ),
                      ],
                  body: _buildBody(data),
                ),
          if (asyncState.isLoading)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onTapAdd(data),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(GoalsPageState state) {
    final l10n = AppLocalizations.of(context)!;
    final selectedGoal = state.selectedGoalTree;
    final controller = ref.read(goalsPageControllerProvider.notifier);

    if (state.goalTree.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: LayoutTokens.listPagePadding,
          children: [
            _GoalsEmptyStatePanel(
              title: l10n.goalsNoGoal,
              actionLabel: l10n.goalsAddGoal,
              onAction: () {
                _openCreateComposer(
                  state: state,
                  initialType: PlanningComposerType.goal,
                );
              },
            ),
          ],
        ),
      );
    }

    if (selectedGoal == null) {
      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: LayoutTokens.listPagePadding,
          children: [
            _GoalsEmptyStatePanel(
              title: l10n.goalsSelectGoalFirst,
              actionLabel: l10n.goalsSwitchTooltip,
              onAction: () => _openGoalSwitcher(state),
            ),
          ],
        ),
      );
    }

    final milestones = state.visibleMilestones;
    final hasSearchQuery = state.searchQuery.trim().isNotEmpty;

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          LayoutTokens.pageHorizontal,
          LayoutTokens.pageTop,
          LayoutTokens.pageHorizontal,
          84,
        ),
        children: [
          _GoalSummaryPanel(
            goal: selectedGoal.goal,
            onEdit: () => _showGoalDialog(existingGoal: selectedGoal.goal),
            onSwitchGoal: () => _openGoalSwitcher(state),
          ),
          const SizedBox(height: LayoutTokens.sectionGapLarge),
          _GoalsSectionHeader(
            title: l10n.goalsMilestonesSection,
            actionLabel: l10n.goalsAddMilestone,
            onAction:
                () => _openCreateComposer(
                  state: state,
                  initialType: PlanningComposerType.milestone,
                  initialGoalId: selectedGoal.goal.id,
                ),
          ),
          const SizedBox(height: LayoutTokens.compactGap),
          if (milestones.isEmpty)
            _GoalsEmptyStatePanel(
              title:
                  hasSearchQuery
                      ? l10n.goalsNoSearchResult
                      : l10n.goalsNoMilestone,
              actionLabel:
                  hasSearchQuery
                      ? l10n.goalsFilterReset
                      : l10n.goalsAddMilestone,
              onAction:
                  hasSearchQuery
                      ? () => controller.clearSearch()
                      : () => _openCreateComposer(
                        state: state,
                        initialType: PlanningComposerType.milestone,
                        initialGoalId: selectedGoal.goal.id,
                      ),
            )
          else ...[
            for (final node in milestones)
              MilestoneCard(
                milestoneNode: node,
                searchQuery: state.searchQuery,
                expanded: state.isMilestoneExpanded(node.milestone.id),
                editLabel: l10n.commonEdit,
                deleteLabel: l10n.commonDelete,
                addTaskLabel: l10n.goalsAddTask,
                onToggleExpanded: () {
                  controller.toggleMilestoneExpanded(node.milestone.id);
                },
                onEditMilestone:
                    () => _editMilestoneDialog(
                      goalId: selectedGoal.goal.id,
                      milestone: node.milestone,
                    ),
                onDeleteMilestone:
                    () => _deleteMilestone(
                      goalId: selectedGoal.goal.id,
                      milestone: node.milestone,
                    ),
                onAddTask:
                    () => _openCreateComposer(
                      state: state,
                      initialType: PlanningComposerType.task,
                      initialGoalId: selectedGoal.goal.id,
                      initialMilestoneId: node.milestone.id,
                    ),
                onToggleTask:
                    (taskId, targetCompleted) =>
                        controller.toggleTaskCompletion(
                          goalId: selectedGoal.goal.id,
                          taskId: taskId,
                          completed: targetCompleted,
                        ),
                onEditTask:
                    (taskId) => _editTaskDialog(
                      goalId: selectedGoal.goal.id,
                      taskId: taskId,
                    ),
                onDeleteTask:
                    (taskId) => _deleteTask(
                      goalId: selectedGoal.goal.id,
                      taskId: taskId,
                    ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _openGoalSwitcher(GoalsPageState state) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return GoalSwitcherSheet(
          goals: state.goalTree,
          selectedGoalId: state.selectedGoalId,
          addGoalLabel: l10n.goalsAddGoal,
          manageLabel: l10n.goalsManage,
          editLabel: l10n.commonEdit,
          deleteLabel: l10n.commonDelete,
          onSelectGoal: (goalId) async {
            await ref
                .read(goalsPageControllerProvider.notifier)
                .selectGoal(goalId);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          onAddGoal: () {
            Navigator.of(context).pop();
            _openCreateComposer(
              state: state,
              initialType: PlanningComposerType.goal,
            );
          },
          onEditGoal: (goalId) {
            Navigator.of(context).pop();
            final goal =
                state.goalTree
                    .firstWhere((node) => node.goal.id == goalId)
                    .goal;
            _showGoalDialog(existingGoal: goal);
          },
          onDeleteGoal: (goalId) async {
            Navigator.of(context).pop();
            final goal =
                state.goalTree
                    .firstWhere((node) => node.goal.id == goalId)
                    .goal;
            await _deleteGoal(goal);
          },
        );
      },
    );
  }

  Future<void> _openFilterSheet(GoalsPageState state) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(goalsPageControllerProvider.notifier);

    var completionFilter = state.completionFilter;
    var progressFilter = state.progressFilter;
    var updatedFilter = state.updatedFilter;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                            tooltip: l10n.commonClose,
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
                        l10n.goalsFilterCompletionTitle,
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
                            for (final filter in GoalCompletionFilter.values)
                              ChoiceChip(
                                label: Text(
                                  _completionFilterLabel(l10n, filter),
                                ),
                                selected: completionFilter == filter,
                                onSelected: (_) {
                                  setSheetState(() {
                                    completionFilter = filter;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        l10n.goalsFilterProgressTitle,
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
                            for (final filter in GoalProgressFilter.values)
                              ChoiceChip(
                                label: Text(_progressFilterLabel(l10n, filter)),
                                selected: progressFilter == filter,
                                onSelected: (_) {
                                  setSheetState(() {
                                    progressFilter = filter;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        l10n.goalsFilterUpdatedTitle,
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
                            for (final filter in GoalUpdatedFilter.values)
                              ChoiceChip(
                                label: Text(_updatedFilterLabel(l10n, filter)),
                                selected: updatedFilter == filter,
                                onSelected: (_) {
                                  setSheetState(() {
                                    updatedFilter = filter;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await controller.clearFilters();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(l10n.goalsFilterReset),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              await controller.setFilters(
                                completionFilter: completionFilter,
                                progressFilter: progressFilter,
                                updatedFilter: updatedFilter,
                              );
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(l10n.commonConfirm),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openMenuSheet(GoalsPageState state) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(goalsPageControllerProvider.notifier);

    await showModalBottomSheet<void>(
      context: context,
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
                        tooltip: l10n.commonClose,
                      ),
                      Expanded(
                        child: Text(
                          l10n.goalsMenuTooltip,
                          textAlign: TextAlign.center,
                          style: sheetTheme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: LayoutTokens.sectionGap),
                DecoratedBox(
                  decoration: LayoutTokens.tainCardDecoration(sheetTheme),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: LayoutTokens.cardPadding,
                        ),
                        leading: const Icon(Icons.swap_horiz_rounded),
                        title: Text(l10n.goalsSwitchTooltip),
                        onTap: () {
                          Navigator.of(context).pop();
                          _openGoalSwitcher(state);
                        },
                      ),
                      Divider(
                        indent: 16,
                        endIndent: 16,
                        height: 1,
                        color: sheetTheme.colorScheme.outlineVariant.withValues(
                          alpha: 0.28,
                        ),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: LayoutTokens.cardPadding,
                        ),
                        leading: const Icon(Icons.tune_rounded),
                        title: Text(l10n.goalsFilterTooltip),
                        onTap: () {
                          Navigator.of(context).pop();
                          _openFilterSheet(state);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: LayoutTokens.sectionGapLarge),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    l10n.goalsMenuSortTitle,
                    style: sheetTheme.textTheme.bodySmall?.copyWith(
                      color: sheetTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: LayoutTokens.tainCardDecoration(sheetTheme),
                  child: Column(
                    children: [
                      for (final mode in GoalSortMode.values) ...[
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: LayoutTokens.cardPadding,
                          ),
                          leading: Icon(
                            state.sortMode == mode
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                          ),
                          title: Text(_sortModeLabel(l10n, mode)),
                          onTap: () async {
                            await controller.setSortMode(mode);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        if (mode != GoalSortMode.values.last)
                          Divider(
                            indent: 16,
                            endIndent: 16,
                            height: 1,
                            color: sheetTheme.colorScheme.outlineVariant
                                .withValues(alpha: 0.28),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: LayoutTokens.sectionGapLarge),
                DecoratedBox(
                  decoration: LayoutTokens.tainCardDecoration(sheetTheme),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: LayoutTokens.cardPadding,
                    ),
                    leading: const Icon(Icons.done_all_outlined),
                    title: Text(l10n.goalsMenuBatchManage),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        LayoutTokens.radiusCard,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _openBatchManageSheet();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openBatchManageSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(goalsPageControllerProvider.notifier);

    await showModalBottomSheet<void>(
      context: context,
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
                        tooltip: l10n.commonClose,
                      ),
                      Expanded(
                        child: Text(
                          l10n.goalsBatchTitle,
                          textAlign: TextAlign.center,
                          style: sheetTheme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: LayoutTokens.sectionGap),
                DecoratedBox(
                  decoration: LayoutTokens.tainCardDecoration(sheetTheme),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: LayoutTokens.cardPadding,
                        ),
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(l10n.goalsBatchCompleteVisible),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(LayoutTokens.radiusCard),
                          ),
                        ),
                        onTap: () async {
                          final changed = await controller
                              .bulkSetVisibleTasksCompletion(completed: true);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            _showInfoToast(
                              l10n.goalsBatchResult(changed.toString()),
                            );
                          }
                        },
                      ),
                      Divider(
                        indent: 16,
                        endIndent: 16,
                        height: 1,
                        color: sheetTheme.colorScheme.outlineVariant.withValues(
                          alpha: 0.28,
                        ),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: LayoutTokens.cardPadding,
                        ),
                        leading: const Icon(Icons.remove_circle_outline),
                        title: Text(l10n.goalsBatchUncompleteVisible),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(LayoutTokens.radiusCard),
                          ),
                        ),
                        onTap: () async {
                          final changed = await controller
                              .bulkSetVisibleTasksCompletion(completed: false);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            _showInfoToast(
                              l10n.goalsBatchResult(changed.toString()),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _completionFilterLabel(
    AppLocalizations l10n,
    GoalCompletionFilter filter,
  ) {
    switch (filter) {
      case GoalCompletionFilter.all:
        return l10n.goalsFilterCompletionAll;
      case GoalCompletionFilter.completed:
        return l10n.goalsFilterCompletionCompleted;
      case GoalCompletionFilter.inProgress:
        return l10n.goalsFilterCompletionInProgress;
    }
  }

  String _progressFilterLabel(
    AppLocalizations l10n,
    GoalProgressFilter filter,
  ) {
    switch (filter) {
      case GoalProgressFilter.all:
        return l10n.goalsFilterProgressAll;
      case GoalProgressFilter.below50:
        return l10n.goalsFilterProgressBelow50;
      case GoalProgressFilter.between50And100:
        return l10n.goalsFilterProgress50To100;
      case GoalProgressFilter.over100:
        return l10n.goalsFilterProgressOver100;
    }
  }

  String _updatedFilterLabel(AppLocalizations l10n, GoalUpdatedFilter filter) {
    switch (filter) {
      case GoalUpdatedFilter.all:
        return l10n.historyRangeAll;
      case GoalUpdatedFilter.today:
        return l10n.historyRangeToday;
      case GoalUpdatedFilter.thisWeek:
        return l10n.historyRangeThisWeek;
      case GoalUpdatedFilter.thisMonth:
        return l10n.historyRangeThisMonth;
    }
  }

  String _sortModeLabel(AppLocalizations l10n, GoalSortMode mode) {
    switch (mode) {
      case GoalSortMode.manual:
        return l10n.goalsMenuSortManual;
      case GoalSortMode.updatedDesc:
        return l10n.goalsMenuSortUpdated;
      case GoalSortMode.progressDesc:
        return l10n.goalsMenuSortProgressHigh;
      case GoalSortMode.progressAsc:
        return l10n.goalsMenuSortProgressLow;
    }
  }

  Future<void> _onTapAdd(GoalsPageState? state) async {
    await _openCreateComposer(state: state);
  }

  Future<void> _openCreateComposer({
    GoalsPageState? state,
    PlanningComposerType initialType = PlanningComposerType.task,
    int? initialGoalId,
    int? initialMilestoneId,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final entryState =
        state ?? ref.read(goalsPageControllerProvider).valueOrNull;
    final selectedGoal = entryState?.selectedGoalTree;
    final resolvedGoalId = initialGoalId ?? selectedGoal?.goal.id;
    final resolvedMilestoneId =
        initialMilestoneId ??
        _resolveDefaultMilestoneId(entryState, selectedGoal: selectedGoal);

    final request = await _showPlanningEntrySheet<PlanningComposerRequest>(
      PlanningComposerSheet(
        goalTree: entryState?.goalTree ?? const <GoalWithMilestones>[],
        submitLabel: l10n.goalsCreateEntry,
        initialType: initialType,
        initialGoalId: resolvedGoalId,
        initialMilestoneId: resolvedMilestoneId,
      ),
    );

    if (request == null || !mounted) {
      return;
    }

    final controller = ref.read(goalsPageControllerProvider.notifier);
    switch (request.type) {
      case PlanningComposerType.goal:
        await controller.createGoal(
          title: request.title,
          description: request.description,
        );
        return;
      case PlanningComposerType.milestone:
        final goalId = request.goalId;
        if (goalId == null) {
          _showInfoToast(l10n.goalsSelectGoalFirst);
          return;
        }
        await controller.createMilestone(
          goalId: goalId,
          title: request.title,
          description: request.description,
        );
        return;
      case PlanningComposerType.task:
        final goalId = request.goalId;
        final milestoneId = request.milestoneId;
        final estimateMinutes = request.estimateMinutes;
        if (goalId == null) {
          _showInfoToast(l10n.goalsSelectGoalFirst);
          return;
        }
        if (milestoneId == null || estimateMinutes == null) {
          _showInfoToast(l10n.goalsSelectMilestoneFirst);
          return;
        }
        await controller.createTask(
          goalId: goalId,
          milestoneId: milestoneId,
          title: request.title,
          description: request.description,
          estimateMinutes: estimateMinutes,
        );
        return;
    }
  }

  int? _resolveDefaultMilestoneId(
    GoalsPageState? state, {
    GoalWithMilestones? selectedGoal,
  }) {
    final goal = selectedGoal ?? state?.selectedGoalTree;
    if (goal == null || goal.milestones.isEmpty) {
      return null;
    }
    final expandedIds = state?.expandedMilestoneIds ?? const <int>{};
    for (final milestoneNode in goal.milestones) {
      if (expandedIds.contains(milestoneNode.milestone.id)) {
        return milestoneNode.milestone.id;
      }
    }
    return goal.milestones.first.milestone.id;
  }

  Future<void> _showGoalDialog({GoalModel? existingGoal}) async {
    final l10n = AppLocalizations.of(context)!;
    final input = await _showPlanningEntrySheet<CreateGoalInput>(
      GoalEntrySheet(
        title:
            existingGoal == null
                ? l10n.goalsCreateGoalDialogTitle
                : l10n.goalsEditGoalDialogTitle,
        submitLabel:
            existingGoal == null ? l10n.goalsCreateEntry : l10n.commonSave,
        initialTitle: existingGoal?.title,
        initialDescription: existingGoal?.description,
      ),
    );

    if (input == null || !mounted) {
      return;
    }

    final controller = ref.read(goalsPageControllerProvider.notifier);
    if (existingGoal == null) {
      await controller.createGoal(
        title: input.title,
        description: input.description,
      );
    } else {
      await controller.updateGoal(
        goalId: existingGoal.id,
        title: input.title,
        description: input.description,
        sortOrder: existingGoal.sortOrder,
        colorHex: existingGoal.colorHex,
        dueAt: existingGoal.dueAt,
      );
    }
  }

  Future<void> _deleteGoal(GoalModel goal) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      title: l10n.commonDelete,
      message: l10n.goalsDeleteGoalConfirm,
    );
    if (!confirmed) {
      return;
    }
    await ref.read(goalsPageControllerProvider.notifier).deleteGoal(goal.id);
  }

  Future<void> _showMilestoneDialog({
    required int goalId,
    MilestoneModel? existingMilestone,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final input = await _showPlanningEntrySheet<CreateMilestoneInput>(
      MilestoneEntrySheet(
        goalId: goalId,
        title:
            existingMilestone == null
                ? l10n.goalsCreateMilestoneDialogTitle
                : l10n.goalsEditMilestoneDialogTitle,
        submitLabel:
            existingMilestone == null ? l10n.goalsCreateEntry : l10n.commonSave,
        initialTitle: existingMilestone?.title,
        initialDescription: existingMilestone?.description,
      ),
    );

    if (input == null || !mounted) {
      return;
    }

    final controller = ref.read(goalsPageControllerProvider.notifier);
    if (existingMilestone == null) {
      await controller.createMilestone(
        goalId: goalId,
        title: input.title,
        description: input.description,
      );
    } else {
      await controller.updateMilestone(
        goalId: goalId,
        milestoneId: existingMilestone.id,
        title: input.title,
        description: input.description,
        sortOrder: existingMilestone.sortOrder,
        dueAt: existingMilestone.dueAt,
      );
    }
  }

  Future<void> _editMilestoneDialog({
    required int goalId,
    required MilestoneModel milestone,
  }) {
    return _showMilestoneDialog(goalId: goalId, existingMilestone: milestone);
  }

  Future<void> _deleteMilestone({
    required int goalId,
    required MilestoneModel milestone,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      title: l10n.commonDelete,
      message: l10n.goalsDeleteMilestoneConfirm,
    );
    if (!confirmed) {
      return;
    }
    await ref
        .read(goalsPageControllerProvider.notifier)
        .deleteMilestone(goalId: goalId, milestoneId: milestone.id);
  }

  Future<void> _showTaskDialog({
    required int goalId,
    required int selectedMilestoneId,
    required List<MilestoneModel> availableMilestones,
    TaskModel? existingTask,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final input = await _showPlanningEntrySheet<CreateTaskInput>(
      TaskEntrySheet(
        title:
            existingTask == null
                ? l10n.goalsCreateTaskDialogTitle
                : l10n.goalsEditTaskDialogTitle,
        submitLabel:
            existingTask == null ? l10n.goalsCreateEntry : l10n.commonSave,
        availableMilestones: availableMilestones,
        initialMilestoneId: existingTask?.milestoneId ?? selectedMilestoneId,
        initialTitle: existingTask?.title,
        initialDescription: existingTask?.description,
        initialEstimateMinutes: existingTask?.estimateMinutes ?? 25,
      ),
    );

    if (input == null || !mounted) {
      return;
    }

    final controller = ref.read(goalsPageControllerProvider.notifier);
    if (existingTask == null) {
      await controller.createTask(
        goalId: goalId,
        milestoneId: input.milestoneId,
        title: input.title,
        description: input.description,
        estimateMinutes: input.estimateMinutes,
      );
    } else {
      await controller.updateTask(
        goalId: goalId,
        taskId: existingTask.id,
        milestoneId: input.milestoneId,
        title: input.title,
        description: input.description,
        estimateMinutes: input.estimateMinutes,
        sortOrder: existingTask.sortOrder,
        dueAt: existingTask.dueAt,
      );
    }
  }

  Future<T?> _showPlanningEntrySheet<T>(Widget child) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) => child,
    );
  }

  Future<void> _editTaskDialog({
    required int goalId,
    required int taskId,
  }) async {
    final state = ref.read(goalsPageControllerProvider).valueOrNull;
    final selectedGoal = state?.selectedGoalTree;
    if (selectedGoal == null) {
      return;
    }

    TaskModel? targetTask;
    for (final milestoneNode in selectedGoal.milestones) {
      for (final task in milestoneNode.tasks) {
        if (task.id == taskId) {
          targetTask = task;
          break;
        }
      }
      if (targetTask != null) {
        break;
      }
    }

    if (targetTask == null) {
      return;
    }

    await _showTaskDialog(
      goalId: goalId,
      selectedMilestoneId: targetTask.milestoneId,
      availableMilestones:
          selectedGoal.milestones.map((node) => node.milestone).toList(),
      existingTask: targetTask,
    );
  }

  Future<void> _deleteTask({required int goalId, required int taskId}) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      title: l10n.commonDelete,
      message: l10n.goalsDeleteTaskConfirm,
    );
    if (!confirmed) {
      return;
    }
    await ref
        .read(goalsPageControllerProvider.notifier)
        .deleteTask(goalId: goalId, taskId: taskId);
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.commonConfirm),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  void _showInfoToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

class _GoalSummaryPanel extends StatelessWidget {
  const _GoalSummaryPanel({
    required this.goal,
    required this.onEdit,
    required this.onSwitchGoal,
  });

  final GoalModel goal;
  final VoidCallback onEdit;
  final VoidCallback onSwitchGoal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final colorScheme = theme.colorScheme;
    final progressPercent = (goal.progressRatio * 100).round();
    final dueAt = goal.dueAt;
    final dueLabel =
        dueAt == null ? null : DateFormat.yMMMd(locale).format(dueAt);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(LayoutTokens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.homeCurrentGoal,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onSwitchGoal,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    foregroundColor: colorScheme.primary,
                  ),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: Text(l10n.goalsSwitchTooltip),
                ),
              ],
            ),
            const SizedBox(height: 6),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: onEdit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  goal.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (goal.description != null && goal.description!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  goal.description!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.78),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '$progressPercent%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${formatMinutes(goal.effectiveMinutes)} / ${formatMinutes(goal.estimateMinutes)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progressRatio.clamp(0, 1).toDouble(),
              minHeight: 8,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: colorScheme.primary.withValues(alpha: 0.10),
            ),
            if (dueLabel != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 15,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.78),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dueLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.78,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoalsSectionHeader extends StatelessWidget {
  const _GoalsSectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: const Size(0, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _GoalsEmptyStatePanel extends StatelessWidget {
  const _GoalsEmptyStatePanel({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 10),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
