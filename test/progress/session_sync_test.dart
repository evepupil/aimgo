import 'package:aimgo/core/services/database/app_database.dart';
import 'package:aimgo/features/goals/application/progress_sync_service.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftAimGoRepository repository;
  late ProgressSyncService service;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    repository = DriftAimGoRepository(database);
    service = ProgressSyncService(repository);
  });

  tearDown(() async {
    await database.close();
  });

  Future<({GoalModel goal, MilestoneModel milestone, TaskModel task})> seedGoal(
    String title, {
    int estimateMinutes = 100,
  }) async {
    final goal = await repository.createGoal(CreateGoalInput(title: title));
    final milestone = await repository.createMilestone(
      CreateMilestoneInput(goalId: goal.id, title: '$title-M'),
    );
    final task = await repository.createTask(
      CreateTaskInput(
        milestoneId: milestone.id,
        title: '$title-T',
        estimateMinutes: estimateMinutes,
      ),
    );
    return (goal: goal, milestone: milestone, task: task);
  }

  CreateFocusSessionInput taskSession({
    required int goalId,
    required int milestoneId,
    required int taskId,
    int durationMinutes = 100,
    int? efficiencyPercent = 100,
  }) {
    return CreateFocusSessionInput(
      goalId: goalId,
      milestoneId: milestoneId,
      taskId: taskId,
      durationMinutes: durationMinutes,
      efficiencyPercent: efficiencyPercent,
      focusTargetLevel: FocusTargetLevel.task,
      startedAt: DateTime(2026, 3, 4, 20, 0),
      endedAt: DateTime(2026, 3, 4, 21, 40),
    );
  }

  test('updateSessionAndSync re-aggregates both the previous and the new goal '
      'when a session is moved across goals', () async {
    final a = await seedGoal('GoalA');
    final b = await seedGoal('GoalB');

    final session = await service.createSessionAndSync(
      taskSession(
        goalId: a.goal.id,
        milestoneId: a.milestone.id,
        taskId: a.task.id,
      ),
    );

    // GoalA picked up the full 100 effective minutes.
    expect(
      (await repository.getGoalById(a.goal.id))!.effectiveMinutes,
      closeTo(100, 0.0001),
    );

    // Re-target the session onto GoalB's task (goal/milestone resolved from task).
    await service.updateSessionAndSync(
      UpdateFocusSessionInput(
        id: session.id,
        taskId: b.task.id,
        durationMinutes: 100,
        efficiencyPercent: 100,
        focusTargetLevel: FocusTargetLevel.task,
      ),
    );

    final taskA = await repository.getTaskById(a.task.id);
    final goalA = await repository.getGoalById(a.goal.id);
    final taskB = await repository.getTaskById(b.task.id);
    final goalB = await repository.getGoalById(b.goal.id);

    // Previous goal drops back to zero.
    expect(taskA!.effectiveMinutes, closeTo(0, 0.0001));
    expect(taskA.progressRatio, closeTo(0, 0.0001));
    expect(goalA!.effectiveMinutes, closeTo(0, 0.0001));

    // New goal gains the contribution.
    expect(taskB!.effectiveMinutes, closeTo(100, 0.0001));
    expect(taskB.progressRatio, closeTo(1.0, 0.0001));
    expect(goalB!.effectiveMinutes, closeTo(100, 0.0001));
  });

  test(
    'deleteSessionAndSync removes the session and drops progress back to zero',
    () async {
      final a = await seedGoal('Goal');

      final session = await service.createSessionAndSync(
        taskSession(
          goalId: a.goal.id,
          milestoneId: a.milestone.id,
          taskId: a.task.id,
        ),
      );
      expect(
        (await repository.getTaskById(a.task.id))!.progressRatio,
        closeTo(1.0, 0.0001),
      );

      await service.deleteSessionAndSync(session.id);

      expect(await repository.getFocusSessionById(session.id), isNull);
      expect(
        (await repository.getTaskById(a.task.id))!.effectiveMinutes,
        closeTo(0, 0.0001),
      );
      expect(
        (await repository.getTaskById(a.task.id))!.progressRatio,
        closeTo(0, 0.0001),
      );
      expect(
        (await repository.getMilestoneById(a.milestone.id))!.effectiveMinutes,
        closeTo(0, 0.0001),
      );
      expect(
        (await repository.getGoalById(a.goal.id))!.effectiveMinutes,
        closeTo(0, 0.0001),
      );
    },
  );

  test(
    'un-completing a task flips milestone and goal completion back to false',
    () async {
      final a = await seedGoal('Goal');

      await service.createSessionAndSync(
        taskSession(
          goalId: a.goal.id,
          milestoneId: a.milestone.id,
          taskId: a.task.id,
        ),
      );

      await repository.setTaskCompletion(taskId: a.task.id, isCompleted: true);
      await service.recalculateGoalProgress(a.goal.id);

      expect(
        (await repository.getMilestoneById(a.milestone.id))!.isCompleted,
        isTrue,
      );
      expect((await repository.getGoalById(a.goal.id))!.isCompleted, isTrue);

      await repository.setTaskCompletion(taskId: a.task.id, isCompleted: false);
      await service.recalculateGoalProgress(a.goal.id);

      expect(
        (await repository.getMilestoneById(a.milestone.id))!.isCompleted,
        isFalse,
      );
      expect((await repository.getGoalById(a.goal.id))!.isCompleted, isFalse);
    },
  );

  test('self-evaluation submit updates efficiency/effective minutes; '
      'skip keeps the 60% default', () async {
    final a = await seedGoal('Goal');

    // The focus timer auto-saves with a null efficiency => default 60%.
    final session = await service.createSessionAndSync(
      taskSession(
        goalId: a.goal.id,
        milestoneId: a.milestone.id,
        taskId: a.task.id,
        efficiencyPercent: null,
      ),
    );
    expect(session.efficiencyPercent, 60);
    expect(session.effectiveMinutes, closeTo(60, 0.0001));

    // Submitting an explicit 80% (mirrors EvaluationPage submit path).
    final submitted = await service.updateSessionAndSync(
      UpdateFocusSessionInput(
        id: session.id,
        goalId: a.goal.id,
        milestoneId: a.milestone.id,
        taskId: a.task.id,
        durationMinutes: 100,
        efficiencyPercent: 80,
        focusTargetLevel: FocusTargetLevel.task,
      ),
    );
    expect(submitted.efficiencyPercent, 80);
    expect(submitted.effectiveMinutes, closeTo(80, 0.0001));
    expect(
      (await repository.getTaskById(a.task.id))!.effectiveMinutes,
      closeTo(80, 0.0001),
    );

    // Skipping self-eval persists the 60% default (mirrors skip path).
    final skipped = await service.updateSessionAndSync(
      UpdateFocusSessionInput(
        id: session.id,
        goalId: a.goal.id,
        milestoneId: a.milestone.id,
        taskId: a.task.id,
        durationMinutes: 100,
        efficiencyPercent: 60,
        focusTargetLevel: FocusTargetLevel.task,
      ),
    );
    expect(skipped.efficiencyPercent, 60);
    expect(skipped.effectiveMinutes, closeTo(60, 0.0001));
  });
}
