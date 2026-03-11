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
                              onPressed: () => _openGoalSwitcher(data),
                              icon: const Icon(Icons.swap_vert),
                              tooltip: l10n.goalsSwitchTooltip,
                            ),
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
                              onPressed: () => _openFilterSheet(data),
                              icon: const Icon(Icons.filter_list),
                              tooltip: l10n.goalsFilterTooltip,
                            ),
                            IconButton(
                              onPressed: () => _openMenuSheet(data),
                              icon: const Icon(Icons.more_vert),
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
    final taskCount = selectedGoal.milestones.fold<int>(
      0,
      (sum, node) => sum + node.tasks.length,
    );

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
            milestoneCount: selectedGoal.milestones.length,
            taskCount: taskCount,
            onEdit: () => _showGoalDialog(existingGoal: selectedGoal.goal),
          ),
          const SizedBox(height: LayoutTokens.sectionGap),
          _GoalActionRow(
            icon: Icons.add_task_outlined,
            label: l10n.goalsAddMilestone,
            onTap:
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
              actionLabel: hasSearchQuery ? l10n.goalsFilterReset : null,
              onAction: hasSearchQuery ? () => controller.clearSearch() : null,
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Wrap(
                  children: [
                    Text(
                      l10n.goalsFilterCompletionTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final filter in GoalCompletionFilter.values)
                          ChoiceChip(
                            label: Text(_completionFilterLabel(l10n, filter)),
                            selected: completionFilter == filter,
                            onSelected: (_) {
                              setSheetState(() {
                                completionFilter = filter;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.goalsFilterProgressTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
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
                    const SizedBox(height: 14),
                    Text(
                      l10n.goalsFilterUpdatedTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
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
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Wrap(
              children: [
                Text(
                  l10n.goalsMenuSortTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                for (final mode in GoalSortMode.values)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
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
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.done_all_outlined),
                  title: Text(l10n.goalsMenuBatchManage),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openBatchManageSheet();
                  },
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
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                title: Text(l10n.goalsBatchTitle),
                leading: const Icon(Icons.tune_outlined),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(l10n.goalsBatchCompleteVisible),
                onTap: () async {
                  final changed = await controller
                      .bulkSetVisibleTasksCompletion(completed: true);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    _showInfoToast(l10n.goalsBatchResult(changed.toString()));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline),
                title: Text(l10n.goalsBatchUncompleteVisible),
                onTap: () async {
                  final changed = await controller
                      .bulkSetVisibleTasksCompletion(completed: false);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    _showInfoToast(l10n.goalsBatchResult(changed.toString()));
                  }
                },
              ),
            ],
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
    required this.milestoneCount,
    required this.taskCount,
    required this.onEdit,
  });

  final GoalModel goal;
  final int milestoneCount;
  final int taskCount;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final progressPercent = (goal.progressRatio * 100).round();
    final dueAt = goal.dueAt;
    final dueLabel =
        dueAt == null ? null : DateFormat.yMMMd(locale).format(dueAt);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(LayoutTokens.radiusLarge),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          LayoutTokens.cardPadding,
          LayoutTokens.cardPadding,
          LayoutTokens.cardPadding,
          10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: onEdit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        goal.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (goal.isCompleted)
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.green.shade600,
                  ),
              ],
            ),
            if (goal.description != null && goal.description!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  goal.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$progressPercent%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${formatMinutes(goal.effectiveMinutes)} / ${formatMinutes(goal.estimateMinutes)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progressRatio.clamp(0, 1).toDouble(),
              minHeight: 7,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                  _GoalSummaryChip(icon: Icons.event_outlined, label: dueLabel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalSummaryChip extends StatelessWidget {
  const _GoalSummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalActionRow extends StatelessWidget {
  const _GoalActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(LayoutTokens.radiusMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(LayoutTokens.radiusMedium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
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
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LayoutTokens.radiusMedium),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
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
