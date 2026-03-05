import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/features/goals/application/goals_page_controller.dart';
import 'package:aimgo/features/goals/presentation/widgets/goal_switcher_sheet.dart';
import 'package:aimgo/features/goals/presentation/widgets/milestone_card.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final isCompactHeader = MediaQuery.sizeOf(context).width < 390;
    final asyncState = ref.watch(goalsPageControllerProvider);
    final controller = ref.read(goalsPageControllerProvider.notifier);
    final data = asyncState.valueOrNull;

    if (asyncState.isLoading && data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedGoal = data?.selectedGoalTree?.goal;

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
              : AppBar(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.goalsMyGoalsTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed:
                          data == null ? null : () => _openGoalSwitcher(data),
                      icon: const Icon(Icons.swap_vert),
                      label: Text(
                        isCompactHeader
                            ? l10n.goalsSwitchTooltip
                            : (selectedGoal?.title ?? l10n.goalsSwitchTooltip),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                        _searchController.text = data?.searchQuery ?? '';
                      });
                    },
                    icon: const Icon(Icons.search),
                    tooltip: l10n.goalsSearchHint,
                  ),
                  IconButton(
                    onPressed:
                        data == null ? null : () => _openFilterSheet(data),
                    icon: const Icon(Icons.filter_list),
                    tooltip: l10n.goalsFilterTooltip,
                  ),
                  IconButton(
                    onPressed: data == null ? null : () => _openMenuSheet(data),
                    icon: const Icon(Icons.more_vert),
                    tooltip: l10n.goalsMenuTooltip,
                  ),
                ],
              ),
      body: Stack(
        children: [
          if (data != null) _buildBody(data),
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

    if (state.goalTree.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(l10n.goalsNoGoal, textAlign: TextAlign.center),
        ),
      );
    }

    if (selectedGoal == null) {
      return const SizedBox.shrink();
    }

    final milestones = state.visibleMilestones;
    final hasSearchQuery = state.searchQuery.trim().isNotEmpty;
    if (milestones.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            hasSearchQuery ? l10n.goalsNoSearchResult : l10n.goalsNoMilestone,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final controller = ref.read(goalsPageControllerProvider.notifier);

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 84),
        itemCount: milestones.length,
        itemBuilder: (context, index) {
          final node = milestones[index];
          final milestoneId = node.milestone.id;
          return MilestoneCard(
            milestoneNode: node,
            searchQuery: state.searchQuery,
            expanded: state.isMilestoneExpanded(milestoneId),
            editLabel: l10n.commonEdit,
            deleteLabel: l10n.commonDelete,
            addTaskLabel: l10n.goalsAddTask,
            onToggleExpanded: () {
              controller.toggleMilestoneExpanded(milestoneId);
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
                () => _showTaskDialog(
                  goalId: selectedGoal.goal.id,
                  selectedMilestoneId: milestoneId,
                  availableMilestones:
                      selectedGoal.milestones
                          .map((item) => item.milestone)
                          .toList(),
                ),
            onToggleTask:
                (taskId, targetCompleted) => controller.toggleTaskCompletion(
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
                (taskId) =>
                    _deleteTask(goalId: selectedGoal.goal.id, taskId: taskId),
          );
        },
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
            _showGoalDialog();
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
    final l10n = AppLocalizations.of(context)!;
    final selectedGoal = state?.selectedGoalTree;

    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                title: Text(l10n.goalsCreateTypeGoal),
                leading: const Icon(Icons.flag_outlined),
                onTap: () => Navigator.of(context).pop('goal'),
              ),
              ListTile(
                title: Text(l10n.goalsCreateTypeMilestone),
                leading: const Icon(Icons.layers_outlined),
                onTap: () => Navigator.of(context).pop('milestone'),
              ),
              ListTile(
                title: Text(l10n.goalsCreateTypeTask),
                leading: const Icon(Icons.task_alt_outlined),
                onTap: () => Navigator.of(context).pop('task'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    switch (result) {
      case 'goal':
        await _showGoalDialog();
        break;
      case 'milestone':
        if (selectedGoal == null) {
          _showInfoToast(l10n.goalsSelectGoalFirst);
          return;
        }
        await _showMilestoneDialog(goalId: selectedGoal.goal.id);
        break;
      case 'task':
        if (selectedGoal == null) {
          _showInfoToast(l10n.goalsSelectGoalFirst);
          return;
        }
        if (selectedGoal.milestones.isEmpty) {
          _showInfoToast(l10n.goalsSelectMilestoneFirst);
          return;
        }
        final defaultMilestoneId =
            selectedGoal.milestones
                .firstWhere(
                  (node) =>
                      state!.expandedMilestoneIds.contains(node.milestone.id),
                  orElse: () => selectedGoal.milestones.first,
                )
                .milestone
                .id;
        await _showTaskDialog(
          goalId: selectedGoal.goal.id,
          selectedMilestoneId: defaultMilestoneId,
          availableMilestones:
              selectedGoal.milestones.map((item) => item.milestone).toList(),
        );
        break;
    }
  }

  Future<void> _showGoalDialog({GoalModel? existingGoal}) async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController(
      text: existingGoal?.title ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingGoal?.description ?? '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existingGoal == null
                ? l10n.goalsCreateGoalDialogTitle
                : l10n.goalsEditGoalDialogTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: l10n.goalsEntryTitle),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.goalsEntryDescription,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                existingGoal == null ? l10n.goalsCreateEntry : l10n.commonSave,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final title = titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    final controller = ref.read(goalsPageControllerProvider.notifier);
    if (existingGoal == null) {
      await controller.createGoal(
        title: title,
        description: _normalizeNullable(descriptionController.text),
      );
    } else {
      await controller.updateGoal(
        goalId: existingGoal.id,
        title: title,
        description: _normalizeNullable(descriptionController.text),
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
    final titleController = TextEditingController(
      text: existingMilestone?.title ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingMilestone?.description ?? '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existingMilestone == null
                ? l10n.goalsCreateMilestoneDialogTitle
                : l10n.goalsEditMilestoneDialogTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: l10n.goalsEntryTitle),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.goalsEntryDescription,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                existingMilestone == null
                    ? l10n.goalsCreateEntry
                    : l10n.commonSave,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final title = titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    final controller = ref.read(goalsPageControllerProvider.notifier);
    if (existingMilestone == null) {
      await controller.createMilestone(
        goalId: goalId,
        title: title,
        description: _normalizeNullable(descriptionController.text),
      );
    } else {
      await controller.updateMilestone(
        goalId: goalId,
        milestoneId: existingMilestone.id,
        title: title,
        description: _normalizeNullable(descriptionController.text),
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
    final titleController = TextEditingController(
      text: existingTask?.title ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingTask?.description ?? '',
    );
    final estimateController = TextEditingController(
      text: existingTask?.estimateMinutes.toString() ?? '25',
    );
    var milestoneId = existingTask?.milestoneId ?? selectedMilestoneId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                existingTask == null
                    ? l10n.goalsCreateTaskDialogTitle
                    : l10n.goalsEditTaskDialogTitle,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: milestoneId,
                    decoration: InputDecoration(
                      labelText: l10n.goalsAddMilestone,
                    ),
                    items: availableMilestones
                        .map(
                          (milestone) => DropdownMenuItem(
                            value: milestone.id,
                            child: Text(
                              milestone.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        milestoneId = value;
                      });
                    },
                  ),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: l10n.goalsEntryTitle,
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.goalsEntryDescription,
                    ),
                  ),
                  TextField(
                    controller: estimateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.goalsEntryEstimateMinutes,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    existingTask == null
                        ? l10n.goalsCreateEntry
                        : l10n.commonSave,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final title = titleController.text.trim();
    final estimateMinutes = int.tryParse(estimateController.text.trim());
    if (title.isEmpty || estimateMinutes == null || estimateMinutes <= 0) {
      return;
    }

    final controller = ref.read(goalsPageControllerProvider.notifier);
    if (existingTask == null) {
      await controller.createTask(
        goalId: goalId,
        milestoneId: milestoneId,
        title: title,
        description: _normalizeNullable(descriptionController.text),
        estimateMinutes: estimateMinutes,
      );
    } else {
      await controller.updateTask(
        goalId: goalId,
        taskId: existingTask.id,
        milestoneId: milestoneId,
        title: title,
        description: _normalizeNullable(descriptionController.text),
        estimateMinutes: estimateMinutes,
        sortOrder: existingTask.sortOrder,
        dueAt: existingTask.dueAt,
      );
    }
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

  String? _normalizeNullable(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _showInfoToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
