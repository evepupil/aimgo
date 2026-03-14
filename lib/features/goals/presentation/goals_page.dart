import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/core/widgets/anchored_action_menu.dart';
import 'package:aimgo/features/goals/application/goals_page_controller.dart';
import 'package:aimgo/features/goals/presentation/widgets/goal_switcher_sheet.dart';
import 'package:aimgo/features/goals/presentation/widgets/milestone_card.dart';
import 'package:aimgo/features/goals/presentation/widgets/planning_entry_sheet.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _topMenuAnchorKey = GlobalKey();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
                toolbarHeight: 56,
                scrolledUnderElevation: 0,
                leadingWidth: 40,
                titleSpacing: 0,
                actionsPadding: const EdgeInsets.only(right: 4),
                title: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: l10n.goalsSearchHint,
                    hintStyle: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.48,
                      ),
                    ),
                  ),
                  onChanged: (value) => controller.updateSearchQuery(value),
                ),
                leading: Icon(
                  Icons.search,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
                ? _buildBody(data, isSearching: true)
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
                                  _searchController
                                      .selection = TextSelection.collapsed(
                                    offset: _searchController.text.length,
                                  );
                                });
                              },
                              icon: const Icon(Icons.search),
                              tooltip: l10n.goalsSearchHint,
                            ),
                            IconButton(
                              key: _topMenuAnchorKey,
                              onPressed: () async {
                                final action = await showAnchoredActionMenu<
                                  _GoalsTopAction
                                >(
                                  context: context,
                                  anchorKey: _topMenuAnchorKey,
                                  items: [
                                    AnchoredMenuItem<_GoalsTopAction>(
                                      value: _GoalsTopAction.switchGoal,
                                      child: _GoalsMenuActionRow(
                                        icon: Icons.swap_horiz_rounded,
                                        label: l10n.goalsSwitchTooltip,
                                      ),
                                    ),
                                    AnchoredMenuItem<_GoalsTopAction>(
                                      value: _GoalsTopAction.filter,
                                      child: _GoalsMenuActionRow(
                                        icon: Icons.tune_rounded,
                                        label: l10n.goalsFilterTooltip,
                                        showChevron: true,
                                      ),
                                    ),
                                    AnchoredMenuItem<_GoalsTopAction>(
                                      value: _GoalsTopAction.sort,
                                      child: _GoalsMenuActionRow(
                                        icon: Icons.swap_vert_rounded,
                                        label: l10n.goalsMenuSortTitle,
                                        trailingLabel: _sortModeLabel(
                                          l10n,
                                          data.sortMode,
                                        ),
                                        showChevron: true,
                                      ),
                                    ),
                                    AnchoredMenuItem<_GoalsTopAction>(
                                      value: _GoalsTopAction.batch,
                                      child: _GoalsMenuActionRow(
                                        icon: Icons.done_all_outlined,
                                        label: l10n.goalsMenuBatchManage,
                                      ),
                                    ),
                                    AnchoredMenuItem<_GoalsTopAction>(
                                      value: _GoalsTopAction.share,
                                      child: _GoalsMenuActionRow(
                                        icon: Icons.ios_share_rounded,
                                        label: l10n.goalsMenuShare,
                                      ),
                                    ),
                                  ],
                                );
                                if (!mounted || action == null) {
                                  return;
                                }
                                switch (action) {
                                  case _GoalsTopAction.switchGoal:
                                    await _openGoalSwitcher(data);
                                    return;
                                  case _GoalsTopAction.filter:
                                    await _openFilterSheet(data);
                                    return;
                                  case _GoalsTopAction.sort:
                                    await _openSortSheet(data);
                                    return;
                                  case _GoalsTopAction.batch:
                                    _showGoalsMenuPlaceholder(
                                      l10n.goalsMenuBatchManage,
                                    );
                                    return;
                                  case _GoalsTopAction.share:
                                    _showGoalsMenuPlaceholder(
                                      l10n.goalsMenuShare,
                                    );
                                    return;
                                }
                              },
                              icon: const Icon(Icons.more_horiz),
                              tooltip: l10n.goalsMenuTooltip,
                            ),
                          ],
                        ),
                      ],
                  body: _buildBody(data, isSearching: false),
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
      floatingActionButton:
          _isSearching
              ? null
              : FloatingActionButton(
                onPressed: () => _onTapAdd(data),
                child: const Icon(Icons.add),
              ),
    );
  }

  Widget _buildBody(GoalsPageState state, {required bool isSearching}) {
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
              description: l10n.goalsNoGoalGuide,
              icon: Icons.flag_outlined,
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
              description: l10n.goalsSelectGoalGuide,
              icon: Icons.swap_horiz_rounded,
              actionLabel: l10n.goalsSwitchTooltip,
              onAction: () => _openGoalSwitcher(state),
            ),
          ],
        ),
      );
    }

    final hasSearchQuery = state.searchQuery.trim().isNotEmpty;
    final milestones =
        isSearching && hasSearchQuery
            ? const <MilestoneWithTasks>[]
            : state.visibleMilestones;
    final searchResults =
        isSearching && hasSearchQuery
            ? state.visibleSearchResults
            : const <GoalWithMilestones>[];
    final milestoneCount = selectedGoal.milestones.length;
    final taskCount = selectedGoal.milestones.fold<int>(
      0,
      (sum, node) => sum + node.tasks.length,
    );

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          LayoutTokens.pageHorizontal,
          isSearching ? 12 : LayoutTokens.pageTop,
          LayoutTokens.pageHorizontal,
          isSearching ? 24 : 84,
        ),
        children: [
          if (!isSearching)
            _GoalSummaryPanel(
              goal: selectedGoal.goal,
              milestoneCount: milestoneCount,
              taskCount: taskCount,
              onEdit: () => _showGoalDialog(existingGoal: selectedGoal.goal),
              onSwitchGoal: () => _openGoalSwitcher(state),
              onOpenMilestoneProgress:
                  () => context.push(
                    '${RoutePaths.goalMilestones}?goalId=${selectedGoal.goal.id}',
                  ),
            ),
          if (_hasActiveBrowseState(state)) ...[
            SizedBox(height: isSearching ? 0 : LayoutTokens.sectionGap),
            _GoalsBrowseStateBar(
              chips: _buildBrowseStateChips(context, state),
              onReset: () => _resetBrowseState(state),
            ),
          ],
          SizedBox(
            height:
                _hasActiveBrowseState(state)
                    ? LayoutTokens.sectionGapLarge
                    : (isSearching ? 8 : LayoutTokens.sectionGapLarge),
          ),
          _GoalsSectionHeader(
            title:
                isSearching && hasSearchQuery
                    ? l10n.goalsSearchResultsSection
                    : l10n.goalsMilestonesSection,
            actionLabel: isSearching ? null : l10n.goalsAddMilestone,
            onAction:
                isSearching
                    ? null
                    : () => _openCreateComposer(
                      state: state,
                      initialType: PlanningComposerType.milestone,
                      initialGoalId: selectedGoal.goal.id,
                    ),
          ),
          const SizedBox(height: LayoutTokens.compactGap),
          if (isSearching && hasSearchQuery)
            if (searchResults.isEmpty)
              _GoalsEmptyStatePanel(
                title: l10n.goalsNoSearchResult,
                description: l10n.goalsNoSearchResultGuide,
                icon: Icons.search_off_rounded,
                actionLabel: l10n.goalsFilterReset,
                onAction: () => _resetBrowseState(state),
              )
            else ...[
              for (final group in searchResults) ...[
                _GoalSearchResultHeader(goalTitle: group.goal.title),
                const SizedBox(height: 8),
                for (final node in group.milestones)
                  _buildMilestoneCard(
                    state: state,
                    goalId: group.goal.id,
                    milestoneNode: node,
                  ),
                const SizedBox(height: 14),
              ],
            ]
          else if (milestones.isEmpty)
            _GoalsEmptyStatePanel(
              title:
                  hasSearchQuery
                      ? l10n.goalsNoSearchResult
                      : l10n.goalsNoMilestone,
              description:
                  hasSearchQuery
                      ? l10n.goalsNoSearchResultGuide
                      : l10n.goalsNoMilestoneGuide,
              icon:
                  hasSearchQuery
                      ? Icons.search_off_rounded
                      : Icons.flag_circle_outlined,
              actionLabel:
                  hasSearchQuery
                      ? l10n.goalsFilterReset
                      : l10n.goalsAddMilestone,
              onAction:
                  hasSearchQuery
                      ? () => _resetBrowseState(state)
                      : () => _openCreateComposer(
                        state: state,
                        initialType: PlanningComposerType.milestone,
                        initialGoalId: selectedGoal.goal.id,
                      ),
            )
          else ...[
            for (final node in milestones)
              _buildMilestoneCard(
                state: state,
                goalId: selectedGoal.goal.id,
                milestoneNode: node,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMilestoneCard({
    required GoalsPageState state,
    required int goalId,
    required MilestoneWithTasks milestoneNode,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(goalsPageControllerProvider.notifier);
    return MilestoneCard(
      milestoneNode: milestoneNode,
      searchQuery: state.searchQuery,
      expanded: state.isMilestoneExpanded(milestoneNode.milestone.id),
      editLabel: l10n.commonEdit,
      deleteLabel: l10n.commonDelete,
      addTaskLabel: l10n.goalsAddTask,
      onToggleExpanded: () {
        controller.toggleMilestoneExpanded(milestoneNode.milestone.id);
      },
      onEditMilestone:
          () => _editMilestoneDialog(
            goalId: goalId,
            milestone: milestoneNode.milestone,
          ),
      onDeleteMilestone:
          () => _deleteMilestone(
            goalId: goalId,
            milestone: milestoneNode.milestone,
          ),
      onAddTask:
          () => _openCreateComposer(
            state: state,
            initialType: PlanningComposerType.task,
            initialGoalId: goalId,
            initialMilestoneId: milestoneNode.milestone.id,
          ),
      onToggleTask:
          (taskId, targetCompleted) => controller.toggleTaskCompletion(
            goalId: goalId,
            taskId: taskId,
            completed: targetCompleted,
          ),
      onEditTask: (taskId) => _editTaskDialog(goalId: goalId, taskId: taskId),
      onDeleteTask: (taskId) => _deleteTask(goalId: goalId, taskId: taskId),
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

  Future<void> _openSortSheet(GoalsPageState state) async {
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
                          l10n.goalsMenuSortTitle,
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGoalsMenuPlaceholder(String label) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.commonComingSoon(label))));
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
    final entryState =
        state ?? ref.read(goalsPageControllerProvider).valueOrNull;
    await _openCreateComposer(
      state: entryState,
      initialType: _defaultCreateTypeForState(entryState),
    );
  }

  PlanningComposerType _defaultCreateTypeForState(GoalsPageState? state) {
    final selectedGoal = state?.selectedGoalTree;
    if (state == null || state.goalTree.isEmpty) {
      return PlanningComposerType.goal;
    }
    if (selectedGoal == null || selectedGoal.milestones.isEmpty) {
      return PlanningComposerType.milestone;
    }
    return PlanningComposerType.task;
  }

  Future<void> _resetBrowseState(GoalsPageState state) async {
    final controller = ref.read(goalsPageControllerProvider.notifier);
    if (state.searchQuery.trim().isNotEmpty) {
      await controller.clearSearch();
    }
    if (state.completionFilter != GoalCompletionFilter.all ||
        state.progressFilter != GoalProgressFilter.all ||
        state.updatedFilter != GoalUpdatedFilter.all) {
      await controller.clearFilters();
    }
  }

  bool _hasActiveBrowseState(GoalsPageState state) {
    return state.searchQuery.trim().isNotEmpty ||
        state.completionFilter != GoalCompletionFilter.all ||
        state.progressFilter != GoalProgressFilter.all ||
        state.updatedFilter != GoalUpdatedFilter.all;
  }

  List<_GoalsBrowseChipData> _buildBrowseStateChips(
    BuildContext context,
    GoalsPageState state,
  ) {
    final theme = Theme.of(context);
    final chips = <_GoalsBrowseChipData>[];
    final query = state.searchQuery.trim();
    if (query.isNotEmpty) {
      chips.add(
        _GoalsBrowseChipData(
          label: query,
          icon: Icons.search_rounded,
          accentColor: theme.colorScheme.primary,
        ),
      );
    }
    if (state.completionFilter != GoalCompletionFilter.all) {
      chips.add(
        _GoalsBrowseChipData(
          label: _completionFilterLabel(
            AppLocalizations.of(context)!,
            state.completionFilter,
          ),
          icon: Icons.done_all_rounded,
          accentColor: theme.colorScheme.primary,
        ),
      );
    }
    if (state.progressFilter != GoalProgressFilter.all) {
      chips.add(
        _GoalsBrowseChipData(
          label: _progressFilterLabel(
            AppLocalizations.of(context)!,
            state.progressFilter,
          ),
          icon: Icons.stacked_bar_chart_rounded,
          accentColor: theme.colorScheme.primary,
        ),
      );
    }
    if (state.updatedFilter != GoalUpdatedFilter.all) {
      chips.add(
        _GoalsBrowseChipData(
          label: _updatedFilterLabel(
            AppLocalizations.of(context)!,
            state.updatedFilter,
          ),
          icon: Icons.schedule_rounded,
          accentColor: theme.colorScheme.primary,
        ),
      );
    }
    return chips;
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
    final controller = ref.read(goalsPageControllerProvider.notifier);

    if (existingGoal == null) {
      final input = await _showPlanningEntrySheet<CreateGoalInput>(
        GoalEntrySheet(
          title: l10n.goalsCreateGoalDialogTitle,
          submitLabel: l10n.goalsCreateEntry,
          initialTitle: null,
          initialDescription: null,
        ),
      );
      if (input == null || !mounted) {
        return;
      }
      await controller.createGoal(
        title: input.title,
        description: input.description,
      );
      return;
    }

    final state = ref.read(goalsPageControllerProvider).valueOrNull;
    final request = await _showPlanningEntrySheet<PlanningComposerRequest>(
      PlanningComposerSheet(
        goalTree: state?.goalTree ?? const <GoalWithMilestones>[],
        submitLabel: l10n.commonSave,
        initialType: PlanningComposerType.goal,
        initialTitle: existingGoal.title,
        initialDescription: existingGoal.description,
        lockType: true,
        lockSelection: true,
        isEditing: true,
      ),
    );
    if (request == null || !mounted) {
      return;
    }

    await controller.updateGoal(
      goalId: existingGoal.id,
      title: request.title,
      description: request.description,
      sortOrder: existingGoal.sortOrder,
      colorHex: existingGoal.colorHex,
      dueAt: existingGoal.dueAt,
    );
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
    final controller = ref.read(goalsPageControllerProvider.notifier);

    if (existingMilestone == null) {
      final input = await _showPlanningEntrySheet<CreateMilestoneInput>(
        MilestoneEntrySheet(
          goalId: goalId,
          title: l10n.goalsCreateMilestoneDialogTitle,
          submitLabel: l10n.goalsCreateEntry,
          initialTitle: null,
          initialDescription: null,
        ),
      );
      if (input == null || !mounted) {
        return;
      }
      await controller.createMilestone(
        goalId: goalId,
        title: input.title,
        description: input.description,
      );
      return;
    }

    final state = ref.read(goalsPageControllerProvider).valueOrNull;
    final request = await _showPlanningEntrySheet<PlanningComposerRequest>(
      PlanningComposerSheet(
        goalTree: state?.goalTree ?? const <GoalWithMilestones>[],
        submitLabel: l10n.commonSave,
        initialType: PlanningComposerType.milestone,
        initialGoalId: goalId,
        initialTitle: existingMilestone.title,
        initialDescription: existingMilestone.description,
        lockType: true,
        lockSelection: false,
        isEditing: true,
      ),
    );
    if (request == null || !mounted) {
      return;
    }

    await controller.updateMilestone(
      goalId: goalId,
      milestoneId: existingMilestone.id,
      title: request.title,
      description: request.description,
      sortOrder: existingMilestone.sortOrder,
      dueAt: existingMilestone.dueAt,
    );
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
    final controller = ref.read(goalsPageControllerProvider.notifier);
    if (existingTask == null) {
      final input = await _showPlanningEntrySheet<CreateTaskInput>(
        TaskEntrySheet(
          title: l10n.goalsCreateTaskDialogTitle,
          submitLabel: l10n.goalsCreateEntry,
          availableMilestones: availableMilestones,
          initialMilestoneId: selectedMilestoneId,
          initialTitle: null,
          initialDescription: null,
          initialEstimateMinutes: 25,
        ),
      );
      if (input == null || !mounted) {
        return;
      }
      await controller.createTask(
        goalId: goalId,
        milestoneId: input.milestoneId,
        title: input.title,
        description: input.description,
        estimateMinutes: input.estimateMinutes,
      );
      return;
    }

    final state = ref.read(goalsPageControllerProvider).valueOrNull;
    final request = await _showPlanningEntrySheet<PlanningComposerRequest>(
      PlanningComposerSheet(
        goalTree: state?.goalTree ?? const <GoalWithMilestones>[],
        submitLabel: l10n.commonSave,
        initialType: PlanningComposerType.task,
        initialGoalId: goalId,
        initialMilestoneId: existingTask.milestoneId,
        initialTitle: existingTask.title,
        initialDescription: existingTask.description,
        initialEstimateMinutes: existingTask.estimateMinutes,
        lockType: true,
        lockSelection: false,
        isEditing: true,
      ),
    );
    if (request == null || !mounted) {
      return;
    }

    await controller.updateTask(
      goalId: goalId,
      taskId: existingTask.id,
      milestoneId: request.milestoneId!,
      title: request.title,
      description: request.description,
      estimateMinutes: request.estimateMinutes!,
      sortOrder: existingTask.sortOrder,
      dueAt: existingTask.dueAt,
    );
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
    required this.milestoneCount,
    required this.taskCount,
    required this.onEdit,
    required this.onSwitchGoal,
    required this.onOpenMilestoneProgress,
  });

  final GoalModel goal;
  final int milestoneCount;
  final int taskCount;
  final VoidCallback onEdit;
  final VoidCallback onSwitchGoal;
  final VoidCallback onOpenMilestoneProgress;

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
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _GoalSummaryChip(
                        icon: Icons.flag_outlined,
                        label: '$milestoneCount',
                      ),
                      _GoalSummaryChip(
                        icon: Icons.checklist_rtl_outlined,
                        label: '$taskCount',
                      ),
                      if (dueLabel != null)
                        _GoalSummaryChip(
                          icon: Icons.event_outlined,
                          label: dueLabel,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _GoalSummaryChip(
                  icon: Icons.timeline_rounded,
                  label: l10n.goalsMilestoneProgress,
                  onTap: onOpenMilestoneProgress,
                  highlighted: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalSummaryChip extends StatelessWidget {
  const _GoalSummaryChip({
    required this.icon,
    required this.label,
    this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: (highlighted ? colorScheme.primary : colorScheme.primary)
            .withValues(alpha: highlighted ? 0.10 : 0.07),
        borderRadius: BorderRadius.circular(LayoutTokens.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color:
                highlighted
                    ? colorScheme.primary
                    : colorScheme.primary.withValues(alpha: 0.72),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color:
                  highlighted
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
              fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(LayoutTokens.radiusMedium),
        onTap: onTap,
        child: chip,
      ),
    );
  }
}

enum _GoalsTopAction { switchGoal, filter, sort, batch, share }

class _GoalsMenuActionRow extends StatelessWidget {
  const _GoalsMenuActionRow({
    required this.icon,
    required this.label,
    this.trailingLabel,
    this.showChevron = false,
  });

  final IconData icon;
  final String label;
  final String? trailingLabel;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurface),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (trailingLabel != null || showChevron)
          SizedBox(
            width: trailingLabel == null ? 26 : 132,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (trailingLabel != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        trailingLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.66,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                if (showChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.62,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _GoalsSectionHeader extends StatelessWidget {
  const _GoalsSectionHeader({
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
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _GoalSearchResultHeader extends StatelessWidget {
  const _GoalSearchResultHeader({required this.goalTitle});

  final String goalTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        goalTitle,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

final class _GoalsBrowseChipData {
  const _GoalsBrowseChipData({
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
}

class _GoalsBrowseStateBar extends StatelessWidget {
  const _GoalsBrowseStateBar({required this.chips, required this.onReset});

  final List<_GoalsBrowseChipData> chips;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(LayoutTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final chip in chips)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: chip.accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(
                      LayoutTokens.radiusMedium,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(chip.icon, size: 14, color: chip.accentColor),
                      const SizedBox(width: 5),
                      Text(
                        chip.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onReset,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 30),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(l10n.goalsFilterReset),
          ),
        ],
      ),
    );
  }
}

class _GoalsEmptyStatePanel extends StatelessWidget {
  const _GoalsEmptyStatePanel({
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final IconData icon;
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
            Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 26),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
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
