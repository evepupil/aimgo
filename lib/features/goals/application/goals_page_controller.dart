import 'package:aimgo/features/goals/application/progress_sync_service.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goalsPageControllerProvider =
    AsyncNotifierProvider<GoalsPageController, GoalsPageState>(
      GoalsPageController.new,
    );

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
  });

  final List<GoalWithMilestones> goalTree;
  final int? selectedGoalId;
  final String searchQuery;
  final Set<int> expandedMilestoneIds;

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

    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return selected.milestones;
    }

    final goalMatched =
        _contains(selected.goal.title, query) ||
        _contains(selected.goal.description, query);

    final filtered = <MilestoneWithTasks>[];
    for (final milestoneNode in selected.milestones) {
      final milestoneMatched =
          _contains(milestoneNode.milestone.title, query) ||
          _contains(milestoneNode.milestone.description, query);

      if (goalMatched || milestoneMatched) {
        filtered.add(milestoneNode);
        continue;
      }

      final matchedTasks = milestoneNode.tasks
          .where(
            (task) =>
                _contains(task.title, query) ||
                _contains(task.description, query),
          )
          .toList(growable: false);
      if (matchedTasks.isNotEmpty) {
        filtered.add(
          MilestoneWithTasks(
            milestone: milestoneNode.milestone,
            tasks: matchedTasks,
          ),
        );
      }
    }
    return filtered;
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
  }) {
    return GoalsPageState(
      goalTree: goalTree ?? this.goalTree,
      selectedGoalId:
          clearSelectedGoal ? null : (selectedGoalId ?? this.selectedGoalId),
      searchQuery: searchQuery ?? this.searchQuery,
      expandedMilestoneIds: expandedMilestoneIds ?? this.expandedMilestoneIds,
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
      ),
    );
  }

  Future<void> selectGoal(int goalId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
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
    await ref.read(progressSyncServiceProvider).recalculateGoalProgress(goalId);
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
    await ref.read(progressSyncServiceProvider).recalculateGoalProgress(goalId);
    await _reloadAndPreserve(selectedGoalId: goalId);
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
      ),
    );
  }

  Future<GoalsPageState> _loadState({
    int? preferredGoalId,
    String? query,
    Set<int>? expandedMilestoneIds,
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
    );
  }
}
