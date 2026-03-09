import 'package:aimgo/core/services/database/app_database.dart';
import 'package:aimgo/shared/models/planning_models.dart' as model;
import 'package:aimgo/shared/repositories/aimgo_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aimGoRepositoryProvider = Provider<AimGoRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftAimGoRepository(database);
});

final class DriftAimGoRepository implements AimGoRepository {
  DriftAimGoRepository(this._database);

  static const int _defaultEfficiencyPercent = 60;

  final AppDatabase _database;

  @override
  Future<List<model.GoalModel>> listGoals() async {
    final rows =
        await (_database.select(_database.goals)..orderBy([
          (table) => OrderingTerm(expression: table.sortOrder),
          (table) => OrderingTerm(expression: table.id),
        ])).get();
    return rows.map(_mapGoal).toList(growable: false);
  }

  @override
  Future<model.GoalModel> createGoal(model.CreateGoalInput input) async {
    final now = DateTime.now();
    final row = await _database
        .into(_database.goals)
        .insertReturning(
          GoalsCompanion.insert(
            title: input.title,
            description: Value(input.description),
            sortOrder: Value(input.sortOrder),
            colorHex: Value(input.colorHex),
            dueAt: Value(input.dueAt),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    return _mapGoal(row);
  }

  @override
  Future<model.GoalModel> updateGoal(model.UpdateGoalInput input) async {
    await (_database.update(_database.goals)
      ..where((table) => table.id.equals(input.id))).write(
      GoalsCompanion(
        title: Value(input.title),
        description: Value(input.description),
        sortOrder: Value(input.sortOrder),
        colorHex: Value(input.colorHex),
        dueAt: Value(input.dueAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final updated = await getGoalById(input.id);
    if (updated == null) {
      throw StateError('Goal not found after update: ${input.id}');
    }
    return updated;
  }

  @override
  Future<void> deleteGoal(int goalId) async {
    await (_database.delete(_database.goals)
      ..where((table) => table.id.equals(goalId))).go();
  }

  @override
  Future<model.MilestoneModel> createMilestone(
    model.CreateMilestoneInput input,
  ) async {
    final now = DateTime.now();
    final row = await _database
        .into(_database.milestones)
        .insertReturning(
          MilestonesCompanion.insert(
            goalId: input.goalId,
            title: input.title,
            description: Value(input.description),
            sortOrder: Value(input.sortOrder),
            dueAt: Value(input.dueAt),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    return _mapMilestone(row);
  }

  @override
  Future<model.MilestoneModel> updateMilestone(
    model.UpdateMilestoneInput input,
  ) async {
    await (_database.update(_database.milestones)
      ..where((table) => table.id.equals(input.id))).write(
      MilestonesCompanion(
        goalId: Value(input.goalId),
        title: Value(input.title),
        description: Value(input.description),
        sortOrder: Value(input.sortOrder),
        dueAt: Value(input.dueAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final updated = await getMilestoneById(input.id);
    if (updated == null) {
      throw StateError('Milestone not found after update: ${input.id}');
    }
    return updated;
  }

  @override
  Future<void> deleteMilestone(int milestoneId) async {
    await (_database.delete(_database.milestones)
      ..where((table) => table.id.equals(milestoneId))).go();
  }

  @override
  Future<model.TaskModel> createTask(model.CreateTaskInput input) async {
    final now = DateTime.now();
    final row = await _database
        .into(_database.tasks)
        .insertReturning(
          TasksCompanion.insert(
            milestoneId: input.milestoneId,
            title: input.title,
            description: Value(input.description),
            estimateMinutes: Value(input.estimateMinutes),
            sortOrder: Value(input.sortOrder),
            dueAt: Value(input.dueAt),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    return _mapTask(row);
  }

  @override
  Future<model.TaskModel> updateTask(model.UpdateTaskInput input) async {
    await (_database.update(_database.tasks)
      ..where((table) => table.id.equals(input.id))).write(
      TasksCompanion(
        milestoneId: Value(input.milestoneId),
        title: Value(input.title),
        description: Value(input.description),
        estimateMinutes: Value(input.estimateMinutes),
        sortOrder: Value(input.sortOrder),
        dueAt: Value(input.dueAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final updated = await getTaskById(input.id);
    if (updated == null) {
      throw StateError('Task not found after update: ${input.id}');
    }
    return updated;
  }

  @override
  Future<void> deleteTask(int taskId) async {
    await (_database.delete(_database.tasks)
      ..where((table) => table.id.equals(taskId))).go();
  }

  @override
  Future<void> setTaskCompletion({
    required int taskId,
    required bool isCompleted,
  }) async {
    await (_database.update(_database.tasks)
      ..where((table) => table.id.equals(taskId))).write(
      TasksCompanion(
        isCompleted: Value(isCompleted),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<model.FocusSessionModel> createFocusSession(
    model.CreateFocusSessionInput input,
  ) async {
    final resolvedEfficiency =
        input.efficiencyPercent ?? _defaultEfficiencyPercent;
    if (resolvedEfficiency < 0 || resolvedEfficiency > 100) {
      throw ArgumentError.value(
        resolvedEfficiency,
        'efficiencyPercent',
        'efficiencyPercent must be between 0 and 100',
      );
    }

    final effectiveMinutes = input.durationMinutes * (resolvedEfficiency / 100);
    final now = DateTime.now();

    final row = await _database
        .into(_database.focusSessions)
        .insertReturning(
          FocusSessionsCompanion.insert(
            goalId: Value(input.goalId),
            milestoneId: Value(input.milestoneId),
            taskId: Value(input.taskId),
            durationMinutes: Value(input.durationMinutes),
            efficiencyPercent: Value(resolvedEfficiency),
            effectiveMinutes: Value(effectiveMinutes),
            focusTargetLevel: _focusTargetLevelToDb(input.focusTargetLevel),
            startedAt: input.startedAt,
            endedAt: input.endedAt,
            note: Value(input.note),
            isAbandoned: Value(input.isAbandoned),
            createdAt: Value(now),
          ),
        );

    return _mapFocusSession(row);
  }

  @override
  Future<model.FocusSessionModel> updateFocusSession(
    model.UpdateFocusSessionInput input,
  ) async {
    if (input.efficiencyPercent < 0 || input.efficiencyPercent > 100) {
      throw ArgumentError.value(
        input.efficiencyPercent,
        'efficiencyPercent',
        'efficiencyPercent must be between 0 and 100',
      );
    }
    final effectiveMinutes =
        input.durationMinutes * (input.efficiencyPercent / 100);
    await (_database.update(_database.focusSessions)
      ..where((table) => table.id.equals(input.id))).write(
      FocusSessionsCompanion(
        goalId: Value(input.goalId),
        milestoneId: Value(input.milestoneId),
        taskId: Value(input.taskId),
        durationMinutes: Value(input.durationMinutes),
        efficiencyPercent: Value(input.efficiencyPercent),
        effectiveMinutes: Value(effectiveMinutes),
        focusTargetLevel: Value(_focusTargetLevelToDb(input.focusTargetLevel)),
        note: Value(input.note),
      ),
    );
    final updated = await getFocusSessionById(input.id);
    if (updated == null) {
      throw StateError('Focus session not found after update: ${input.id}');
    }
    return updated;
  }

  @override
  Future<model.GoalModel?> getGoalById(int goalId) async {
    final query = _database.select(_database.goals)
      ..where((table) => table.id.equals(goalId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapGoal(row);
  }

  @override
  Future<model.MilestoneModel?> getMilestoneById(int milestoneId) async {
    final query = _database.select(_database.milestones)
      ..where((table) => table.id.equals(milestoneId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapMilestone(row);
  }

  @override
  Future<model.TaskModel?> getTaskById(int taskId) async {
    final query = _database.select(_database.tasks)
      ..where((table) => table.id.equals(taskId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapTask(row);
  }

  @override
  Future<model.FocusSessionModel?> getFocusSessionById(int sessionId) async {
    final query = _database.select(_database.focusSessions)
      ..where((table) => table.id.equals(sessionId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapFocusSession(row);
  }

  @override
  Future<List<model.MilestoneModel>> listMilestonesByGoalId(int goalId) async {
    final rows =
        await (_database.select(_database.milestones)
              ..where((table) => table.goalId.equals(goalId))
              ..orderBy([
                (table) => OrderingTerm(expression: table.sortOrder),
                (table) => OrderingTerm(expression: table.id),
              ]))
            .get();
    return rows.map(_mapMilestone).toList(growable: false);
  }

  @override
  Future<List<model.TaskModel>> listTasksByMilestoneId(int milestoneId) async {
    final rows =
        await (_database.select(_database.tasks)
              ..where((table) => table.milestoneId.equals(milestoneId))
              ..orderBy([
                (table) => OrderingTerm(expression: table.sortOrder),
                (table) => OrderingTerm(expression: table.id),
              ]))
            .get();
    return rows.map(_mapTask).toList(growable: false);
  }

  @override
  Future<List<model.FocusSessionModel>> listFocusSessionsByTaskId(
    int taskId,
  ) async {
    final rows =
        await (_database.select(_database.focusSessions)
              ..where((table) => table.taskId.equals(taskId))
              ..orderBy([(table) => OrderingTerm(expression: table.startedAt)]))
            .get();
    return rows.map(_mapFocusSession).toList(growable: false);
  }

  @override
  Future<List<model.FocusSessionModel>> listFocusSessions() async {
    final rows =
        await (_database.select(_database.focusSessions)..orderBy([
          (table) => OrderingTerm(expression: table.startedAt),
        ])).get();
    return rows.map(_mapFocusSession).toList(growable: false);
  }

  @override
  Future<void> updateTaskAggregate(
    model.TaskProgressAggregate aggregate,
  ) async {
    await (_database.update(_database.tasks)
      ..where((table) => table.id.equals(aggregate.taskId))).write(
      TasksCompanion(
        effectiveMinutes: Value(aggregate.effectiveMinutes),
        progressRatio: Value(aggregate.progressRatio),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> updateMilestoneAggregate(
    model.MilestoneProgressAggregate aggregate,
  ) async {
    final currentMilestone =
        await (_database.select(_database.milestones)..where(
          (table) => table.id.equals(aggregate.milestoneId),
        )).getSingleOrNull();
    final now = DateTime.now();
    final completedAtValue =
        aggregate.isCompleted
            ? (currentMilestone?.isCompleted == true &&
                    currentMilestone?.completedAt != null
                ? currentMilestone!.completedAt
                : now)
            : null;

    await (_database.update(_database.milestones)
      ..where((table) => table.id.equals(aggregate.milestoneId))).write(
      MilestonesCompanion(
        estimateMinutes: Value(aggregate.estimateMinutes),
        effectiveMinutes: Value(aggregate.effectiveMinutes),
        progressRatio: Value(aggregate.progressRatio),
        isCompleted: Value(aggregate.isCompleted),
        completedAt: Value(completedAtValue),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> updateGoalAggregate(
    model.GoalProgressAggregate aggregate,
  ) async {
    await (_database.update(_database.goals)
      ..where((table) => table.id.equals(aggregate.goalId))).write(
      GoalsCompanion(
        estimateMinutes: Value(aggregate.estimateMinutes),
        effectiveMinutes: Value(aggregate.effectiveMinutes),
        progressRatio: Value(aggregate.progressRatio),
        isCompleted: Value(aggregate.isCompleted),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) {
    return _database.transaction(action);
  }

  model.GoalModel _mapGoal(Goal row) {
    return model.GoalModel(
      id: row.id,
      title: row.title,
      description: row.description,
      estimateMinutes: row.estimateMinutes,
      effectiveMinutes: row.effectiveMinutes,
      progressRatio: row.progressRatio,
      isCompleted: row.isCompleted,
      sortOrder: row.sortOrder,
      colorHex: row.colorHex,
      dueAt: row.dueAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  model.MilestoneModel _mapMilestone(Milestone row) {
    return model.MilestoneModel(
      id: row.id,
      goalId: row.goalId,
      title: row.title,
      description: row.description,
      estimateMinutes: row.estimateMinutes,
      effectiveMinutes: row.effectiveMinutes,
      progressRatio: row.progressRatio,
      isCompleted: row.isCompleted,
      sortOrder: row.sortOrder,
      dueAt: row.dueAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      completedAt: row.completedAt,
    );
  }

  model.TaskModel _mapTask(Task row) {
    return model.TaskModel(
      id: row.id,
      milestoneId: row.milestoneId,
      title: row.title,
      description: row.description,
      estimateMinutes: row.estimateMinutes,
      effectiveMinutes: row.effectiveMinutes,
      progressRatio: row.progressRatio,
      isCompleted: row.isCompleted,
      sortOrder: row.sortOrder,
      dueAt: row.dueAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  model.FocusSessionModel _mapFocusSession(FocusSession row) {
    return model.FocusSessionModel(
      id: row.id,
      goalId: row.goalId,
      milestoneId: row.milestoneId,
      taskId: row.taskId,
      durationMinutes: row.durationMinutes,
      efficiencyPercent: row.efficiencyPercent,
      effectiveMinutes: row.effectiveMinutes,
      focusTargetLevel: _focusTargetLevelFromDb(row.focusTargetLevel),
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      isAbandoned: row.isAbandoned,
      createdAt: row.createdAt,
      note: row.note,
    );
  }

  String _focusTargetLevelToDb(model.FocusTargetLevel level) {
    return switch (level) {
      model.FocusTargetLevel.goal => 'goal',
      model.FocusTargetLevel.milestone => 'milestone',
      model.FocusTargetLevel.task => 'task',
    };
  }

  model.FocusTargetLevel _focusTargetLevelFromDb(String value) {
    return switch (value) {
      'goal' => model.FocusTargetLevel.goal,
      'milestone' => model.FocusTargetLevel.milestone,
      'task' => model.FocusTargetLevel.task,
      _ => model.FocusTargetLevel.goal,
    };
  }
}
