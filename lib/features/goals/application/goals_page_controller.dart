import 'package:aimgo/features/goals/application/progress_sync_service.dart';
import 'package:aimgo/features/goals/application/selected_goal_provider.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goalsPageControllerProvider =
    AsyncNotifierProvider<GoalsPageController, GoalsPageState>(
      GoalsPageController.new,
    );

enum GoalCompletionFilter { all, completed, inProgress }

enum GoalProgressFilter { all, below50, between50And100, over100 }

enum GoalUpdatedFilter { all, today, thisWeek, thisMonth }

enum GoalSortMode { manual, updatedDesc, progressDesc, progressAsc }

final class GoalWithMilestones {
  const GoalWithMilestones({required this.goal, required this.milestones});

  final GoalModel goal;
  final List<MilestoneWithTasks> milestones;
}

final class MilestoneWithTasks {
  const MilestoneWithTasks({required this.milestone, required this.tasks});

  final MilestoneModel milestone;
  final List<TaskModel> tasks;
}

final class GoalsPageState {
  const GoalsPageState({
    required this.goalTree,
    required this.selectedGoalId,
    required this.searchQuery,
    required this.expandedMilestoneIds,
    required this.completionFilter,
    required this.progressFilter,
    required this.updatedFilter,
    required this.sortMode,
  });

  final List<GoalWithMilestones> goalTree;
  final int? selectedGoalId;
  final String searchQuery;
  final Set<int> expandedMilestoneIds;
  final GoalCompletionFilter completionFilter;
  final GoalProgressFilter progressFilter;
  final GoalUpdatedFilter updatedFilter;
  final GoalSortMode sortMode;

  GoalWithMilestones? get selectedGoalTree {
    final selectedGoalIdValue = selectedGoalId;
    if (selectedGoalIdValue == null) {
      return null;
    }
    for (final node in goalTree) {
      if (node.goal.id == selectedGoalIdValue) {
        return node;
      }
    }
    return null;
  }

  List<MilestoneWithTasks> get visibleMilestones {
    final selected = selectedGoalTree;
    if (selected == null) {
      return const [];
    }
    return _visibleMilestonesForGoal(selected, query: searchQuery);
  }

  List<GoalWithMilestones> get visibleSearchResults {
    final query = searchQuery.trim();
    if (query.isEmpty) {
      return const [];
    }

    final normalizedQuery = query.toLowerCase();
    final results = <GoalWithMilestones>[];
    for (final goalNode in goalTree) {
      final goalMatched =
          _contains(goalNode.goal.title, normalizedQuery) ||
          _contains(goalNode.goal.description, normalizedQuery);
      final milestones =
          goalMatched
              ? _visibleMilestonesForGoal(goalNode, query: '')
              : _visibleMilestonesForGoal(goalNode, query: query);
      if (milestones.isEmpty) {
        continue;
      }
      results.add(
        GoalWithMilestones(goal: goalNode.goal, milestones: milestones),
      );
    }
    return results;
  }

  List<MilestoneWithTasks> _visibleMilestonesForGoal(
    GoalWithMilestones goalNode, {
    required String query,
  }) {
    final now = DateTime.now();
    final filteredByBrowseState = goalNode.milestones
        .where(_matchesCompletionFilter)
        .where(_matchesProgressFilter)
        .where((item) => _matchesUpdatedFilter(item, now))
        .toList(growable: false);

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return _sortMilestones(filteredByBrowseState);
    }

    final searchFiltered = <MilestoneWithTasks>[];
    for (final milestoneNode in filteredByBrowseState) {
      final milestoneMatched =
          _contains(milestoneNode.milestone.title, normalizedQuery) ||
          _contains(milestoneNode.milestone.description, normalizedQuery);

      if (milestoneMatched) {
        searchFiltered.add(milestoneNode);
        continue;
      }

      final matchedTasks = milestoneNode.tasks
          .where(
            (task) =>
                _contains(task.title, normalizedQuery) ||
                _contains(task.description, normalizedQuery),
          )
          .toList(growable: false);
      if (matchedTasks.isNotEmpty) {
        searchFiltered.add(
          MilestoneWithTasks(
            milestone: milestoneNode.milestone,
            tasks: matchedTasks,
          ),
        );
      }
    }

    return _sortMilestones(searchFiltered);
  }

  bool _matchesCompletionFilter(MilestoneWithTasks milestoneNode) {
    switch (completionFilter) {
      case GoalCompletionFilter.all:
        return true;
      case GoalCompletionFilter.completed:
        return milestoneNode.milestone.isCompleted;
      case GoalCompletionFilter.inProgress:
        return !milestoneNode.milestone.isCompleted;
    }
  }

  bool _matchesProgressFilter(MilestoneWithTasks milestoneNode) {
    final progress = milestoneNode.milestone.progressRatio;
    switch (progressFilter) {
      case GoalProgressFilter.all:
        return true;
      case GoalProgressFilter.below50:
        return progress < 0.5;
      case GoalProgressFilter.between50And100:
        return progress >= 0.5 && progress <= 1.0;
      case GoalProgressFilter.over100:
        return progress > 1.0;
    }
  }

  bool _matchesUpdatedFilter(MilestoneWithTasks milestoneNode, DateTime now) {
    switch (updatedFilter) {
      case GoalUpdatedFilter.all:
        return true;
      case GoalUpdatedFilter.today:
        return _isSameDay(milestoneNode.milestone.updatedAt, now);
      case GoalUpdatedFilter.thisWeek:
        final start = _startOfWeek(now);
        final end = start.add(const Duration(days: 7));
        return !milestoneNode.milestone.updatedAt.isBefore(start) &&
            milestoneNode.milestone.updatedAt.isBefore(end);
      case GoalUpdatedFilter.thisMonth:
        return milestoneNode.milestone.updatedAt.year == now.year &&
            milestoneNode.milestone.updatedAt.month == now.month;
    }
  }

  List<MilestoneWithTasks> _sortMilestones(List<MilestoneWithTasks> source) {
    final sorted = [...source];
    switch (sortMode) {
      case GoalSortMode.manual:
        sorted.sort((a, b) {
          final sortCompare = a.milestone.sortOrder.compareTo(
            b.milestone.sortOrder,
          );
          if (sortCompare != 0) {
            return sortCompare;
          }
          return a.milestone.id.compareTo(b.milestone.id);
        });
        return sorted;
      case GoalSortMode.updatedDesc:
        sorted.sort(
          (a, b) => b.milestone.updatedAt.compareTo(a.milestone.updatedAt),
        );
        return sorted;
      case GoalSortMode.progressDesc:
        sorted.sort(
          (a, b) =>
              b.milestone.progressRatio.compareTo(a.milestone.progressRatio),
        );
        return sorted;
      case GoalSortMode.progressAsc:
        sorted.sort(
          (a, b) =>
              a.milestone.progressRatio.compareTo(b.milestone.progressRatio),
        );
        return sorted;
    }
  }

  static DateTime _startOfWeek(DateTime value) {
    final dayStart = DateTime(value.year, value.month, value.day);
    return dayStart.subtract(Duration(days: dayStart.weekday - 1));
  }

  static bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  bool isMilestoneExpanded(int milestoneId) {
    return expandedMilestoneIds.contains(milestoneId);
  }

  GoalsPageState copyWith({
    List<GoalWithMilestones>? goalTree,
    int? selectedGoalId,
    bool clearSelectedGoal = false,
    String? searchQuery,
    Set<int>? expandedMilestoneIds,
    GoalCompletionFilter? completionFilter,
    GoalProgressFilter? progressFilter,
    GoalUpdatedFilter? updatedFilter,
    GoalSortMode? sortMode,
  }) {
    return GoalsPageState(
      goalTree: goalTree ?? this.goalTree,
      selectedGoalId:
          clearSelectedGoal ? null : (selectedGoalId ?? this.selectedGoalId),
      searchQuery: searchQuery ?? this.searchQuery,
      expandedMilestoneIds: expandedMilestoneIds ?? this.expandedMilestoneIds,
      completionFilter: completionFilter ?? this.completionFilter,
      progressFilter: progressFilter ?? this.progressFilter,
      updatedFilter: updatedFilter ?? this.updatedFilter,
      sortMode: sortMode ?? this.sortMode,
    );
  }

  static bool _contains(String? source, String query) {
    if (source == null) {
      return false;
    }
    return source.toLowerCase().contains(query);
  }
}

final class GoalsPageController extends AsyncNotifier<GoalsPageState> {
  @override
  Future<GoalsPageState> build() {
    return _loadState();
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    state = const AsyncLoading();
    state = AsyncData(
      await _loadState(
        preferredGoalId: current?.selectedGoalId,
        query: current?.searchQuery,
        expandedMilestoneIds: current?.expandedMilestoneIds,
        completionFilter: current?.completionFilter,
        progressFilter: current?.progressFilter,
        updatedFilter: current?.updatedFilter,
        sortMode: current?.sortMode,
      ),
    );
  }

  Future<void> selectGoal(int goalId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    ref.read(selectedGoalIdProvider.notifier).state = goalId;
    state = AsyncData(current.copyWith(selectedGoalId: goalId));
  }

  Future<void> updateSearchQuery(String query) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(searchQuery: query));
  }

  Future<void> clearSearch() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(searchQuery: ''));
  }

  Future<void> toggleMilestoneExpanded(int milestoneId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final updated = current.expandedMilestoneIds.toSet();
    if (updated.contains(milestoneId)) {
      updated.remove(milestoneId);
    } else {
      updated.add(milestoneId);
    }
    state = AsyncData(current.copyWith(expandedMilestoneIds: updated));
  }

  Future<void> setFilters({
    GoalCompletionFilter? completionFilter,
    GoalProgressFilter? progressFilter,
    GoalUpdatedFilter? updatedFilter,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        completionFilter: completionFilter,
        progressFilter: progressFilter,
        updatedFilter: updatedFilter,
      ),
    );
  }

  Future<void> clearFilters() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        completionFilter: GoalCompletionFilter.all,
        progressFilter: GoalProgressFilter.all,
        updatedFilter: GoalUpdatedFilter.all,
      ),
    );
  }

  Future<void> setSortMode(GoalSortMode sortMode) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(sortMode: sortMode));
  }

  Future<int> bulkSetVisibleTasksCompletion({required bool completed}) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 0;
    }
    final selectedGoal = current.selectedGoalTree;
    if (selectedGoal == null) {
      return 0;
    }

    final repository = ref.read(aimGoRepositoryProvider);
    final visibleTasks = current.visibleMilestones
        .expand((milestone) => milestone.tasks)
        .where((task) => task.isCompleted != completed)
        .toList(growable: false);
    if (visibleTasks.isEmpty) {
      return 0;
    }

    await repository.transaction(() async {
      for (final task in visibleTasks) {
        await repository.setTaskCompletion(
          taskId: task.id,
          isCompleted: completed,
        );
      }
    });
    await ref
        .read(progressSyncServiceProvider)
        .recalculateGoalProgress(selectedGoal.goal.id);
    await _reloadAndPreserve(selectedGoalId: selectedGoal.goal.id);
    return visibleTasks.length;
  }

  Future<void> createGoal({required String title, String? description}) async {
    final repository = ref.read(aimGoRepositoryProvider);
    final goals = await repository.listGoals();
    final created = await repository.createGoal(
      CreateGoalInput(
        title: title,
        description: description,
        sortOrder: goals.length,
      ),
    );

    await _reloadAndPreserve(selectedGoalId: created.id);
  }

  Future<void> updateGoal({
    required int goalId,
    required String title,
    String? description,
    required int sortOrder,
    String? colorHex,
    DateTime? dueAt,
  }) async {
    final repository = ref.read(aimGoRepositoryProvider);
    await repository.updateGoal(
      UpdateGoalInput(
        id: goalId,
        title: title,
        description: description,
        sortOrder: sortOrder,
        colorHex: colorHex,
        dueAt: dueAt,
      ),
    );
    await _reloadAndPreserve(selectedGoalId: goalId);
  }

  Future<void> deleteGoal(int goalId) async {
    final repository = ref.read(aimGoRepositoryProvider);
    await repository.deleteGoal(goalId);
    await _reloadAndPreserve();
  }

  Future<void> createMilestone({
    required int goalId,
    required String title,
    String? description,
  }) async {
    final repository = ref.read(aimGoRepositoryProvider);
    final milestones = await repository.listMilestonesByGoalId(goalId);
    await repository.createMilestone(
      CreateMilestoneInput(
        goalId: goalId,
        title: title,
        description: description,
        sortOrder: milestones.length,
      ),
    );
    await ref.read(progressSyncServiceProvider).recalculateGoalProgress(goalId);
    await _reloadAndPreserve(selectedGoalId: goalId);
  }

  Future<void> updateMilestone({
    required int goalId,
    required int milestoneId,
    required String title,
    String? description,
    required int sortOrder,
    DateTime? dueAt,
  }) async {
    final repository = ref.read(aimGoRepositoryProvider);
    final previousMilestone = await repository.getMilestoneById(milestoneId);
    await repository.updateMilestone(
      UpdateMilestoneInput(
        id: milestoneId,
        goalId: goalId,
        title: title,
        description: description,
        sortOrder: sortOrder,
        dueAt: dueAt,
      ),
    );
    await _recalculateGoalProgresses({
      goalId,
      if (previousMilestone != null) previousMilestone.goalId,
    });
    await _reloadAndPreserve(selectedGoalId: goalId);
  }

  Future<void> deleteMilestone({
    required int goalId,
    required int milestoneId,
  }) async {
    final repository = ref.read(aimGoRepositoryProvider);
    await repository.deleteMilestone(milestoneId);
    await ref.read(progressSyncServiceProvider).recalculateGoalProgress(goalId);
    await _reloadAndPreserve(selectedGoalId: goalId);
  }

  Future<void> createTask({
    required int goalId,
    required int milestoneId,
    required String title,
    String? description,
    required int estimateMinutes,
  }) async {
    final repository = ref.read(aimGoRepositoryProvider);
    final tasks = await repository.listTasksByMilestoneId(milestoneId);
    await repository.createTask(
      CreateTaskInput(
        milestoneId: milestoneId,
        title: title,
        description: description,
        estimateMinutes: estimateMinutes,
        sortOrder: tasks.length,
      ),
    );
    await ref.read(progressSyncServiceProvider).recalculateGoalProgress(goalId);
    await _reloadAndPreserve(selectedGoalId: goalId);
  }

  Future<void> updateTask({
    required int goalId,
    required int taskId,
    required int milestoneId,
    required String title,
    String? description,
    required int estimateMinutes,
    required int sortOrder,
    DateTime? dueAt,
  }) async {
    final repository = ref.read(aimGoRepositoryProvider);
    final previousTask = await repository.getTaskById(taskId);
    final previousMilestone =
        previousTask == null
            ? null
            : await repository.getMilestoneById(previousTask.milestoneId);
    final nextMilestone = await repository.getMilestoneById(milestoneId);
    await repository.updateTask(
      UpdateTaskInput(
        id: taskId,
        milestoneId: milestoneId,
        title: title,
        description: description,
        estimateMinutes: estimateMinutes,
        sortOrder: sortOrder,
        dueAt: dueAt,
      ),
    );
    await _recalculateGoalProgresses({
      goalId,
      if (previousMilestone != null) previousMilestone.goalId,
      if (nextMilestone != null) nextMilestone.goalId,
    });
    await _reloadAndPreserve(selectedGoalId: goalId);
  }

  Future<void> _recalculateGoalProgresses(Set<int> goalIds) async {
    final progressSyncService = ref.read(progressSyncServiceProvider);
    for (final id in goalIds) {
      await progressSyncService.recalculateGoalProgress(id);
    }
  }

  Future<void> deleteTask({required int goalId, required int taskId}) async {
    final repository = ref.read(aimGoRepositoryProvider);
    await repository.deleteTask(taskId);
    await ref.read(progressSyncServiceProvider).recalculateGoalProgress(goalId);
    await _reloadAndPreserve(selectedGoalId: goalId);
  }

  Future<void> toggleTaskCompletion({
    required int goalId,
    required int taskId,
    required bool completed,
  }) async {
    final repository = ref.read(aimGoRepositoryProvider);
    await repository.setTaskCompletion(taskId: taskId, isCompleted: completed);
    await ref.read(progressSyncServiceProvider).recalculateGoalProgress(goalId);
    await _reloadAndPreserve(selectedGoalId: goalId);
  }

  Future<void> _reloadAndPreserve({int? selectedGoalId}) async {
    final current = state.valueOrNull;
    state = AsyncData(
      await _loadState(
        preferredGoalId: selectedGoalId ?? current?.selectedGoalId,
        query: current?.searchQuery,
        expandedMilestoneIds: current?.expandedMilestoneIds,
        completionFilter: current?.completionFilter,
        progressFilter: current?.progressFilter,
        updatedFilter: current?.updatedFilter,
        sortMode: current?.sortMode,
      ),
    );
  }

  Future<GoalsPageState> _loadState({
    int? preferredGoalId,
    String? query,
    Set<int>? expandedMilestoneIds,
    GoalCompletionFilter? completionFilter,
    GoalProgressFilter? progressFilter,
    GoalUpdatedFilter? updatedFilter,
    GoalSortMode? sortMode,
  }) async {
    final repository = ref.read(aimGoRepositoryProvider);
    final goals = await repository.listGoals();
    final tree = <GoalWithMilestones>[];

    for (final goal in goals) {
      final milestones = await repository.listMilestonesByGoalId(goal.id);
      final milestoneNodes = <MilestoneWithTasks>[];
      for (final milestone in milestones) {
        final tasks = await repository.listTasksByMilestoneId(milestone.id);
        milestoneNodes.add(
          MilestoneWithTasks(milestone: milestone, tasks: tasks),
        );
      }
      tree.add(GoalWithMilestones(goal: goal, milestones: milestoneNodes));
    }

    int? selectedGoalId = preferredGoalId;
    if (selectedGoalId != null &&
        !tree.any((node) => node.goal.id == selectedGoalId)) {
      selectedGoalId = null;
    }
    selectedGoalId ??= tree.isNotEmpty ? tree.first.goal.id : null;
    ref.read(selectedGoalIdProvider.notifier).state = selectedGoalId;

    final normalizedExpanded = <int>{};
    final availableMilestoneIds =
        tree
            .expand((goalNode) => goalNode.milestones)
            .map((milestoneNode) => milestoneNode.milestone.id)
            .toSet();
    for (final milestoneId in expandedMilestoneIds ?? const <int>{}) {
      if (availableMilestoneIds.contains(milestoneId)) {
        normalizedExpanded.add(milestoneId);
      }
    }

    return GoalsPageState(
      goalTree: tree,
      selectedGoalId: selectedGoalId,
      searchQuery: query ?? '',
      expandedMilestoneIds: normalizedExpanded,
      completionFilter: completionFilter ?? GoalCompletionFilter.all,
      progressFilter: progressFilter ?? GoalProgressFilter.all,
      updatedFilter: updatedFilter ?? GoalUpdatedFilter.all,
      sortMode: sortMode ?? GoalSortMode.manual,
    );
  }
}
