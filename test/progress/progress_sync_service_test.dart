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

  test('uses 60% default efficiency when self-evaluation is skipped', () async {
    final goal = await repository.createGoal(
      const CreateGoalInput(title: 'Learn Flutter'),
    );
    final milestone = await repository.createMilestone(
      CreateMilestoneInput(goalId: goal.id, title: 'Phase 1'),
    );
    final task = await repository.createTask(
      CreateTaskInput(
        milestoneId: milestone.id,
        title: 'Drift setup',
        estimateMinutes: 50,
      ),
    );

    final session = await service.createSessionAndSync(
      CreateFocusSessionInput(
        goalId: goal.id,
        milestoneId: milestone.id,
        taskId: task.id,
        durationMinutes: 50,
        efficiencyPercent: null,
        focusTargetLevel: FocusTargetLevel.task,
        startedAt: DateTime(2026, 3, 4, 20, 0),
        endedAt: DateTime(2026, 3, 4, 20, 50),
      ),
    );

    final updatedTask = await repository.getTaskById(task.id);

    expect(session.efficiencyPercent, 60);
    expect(session.effectiveMinutes, 30);
    expect(updatedTask, isNotNull);
    expect(updatedTask!.effectiveMinutes, 30);
    expect(updatedTask.progressRatio, closeTo(0.6, 0.0001));
  });

  test('supports >100% progress and auto-completion propagation', () async {
    final goal = await repository.createGoal(
      const CreateGoalInput(title: 'Ship AimGo'),
    );
    final milestone = await repository.createMilestone(
      CreateMilestoneInput(goalId: goal.id, title: 'Core'),
    );
    final task = await repository.createTask(
      CreateTaskInput(
        milestoneId: milestone.id,
        title: 'Implement timer',
        estimateMinutes: 100,
      ),
    );

    await service.createSessionAndSync(
      CreateFocusSessionInput(
        goalId: goal.id,
        milestoneId: milestone.id,
        taskId: task.id,
        durationMinutes: 150,
        efficiencyPercent: 100,
        focusTargetLevel: FocusTargetLevel.task,
        startedAt: DateTime(2026, 3, 4, 21, 0),
        endedAt: DateTime(2026, 3, 4, 23, 30),
      ),
    );

    final updatedTask = await repository.getTaskById(task.id);
    final updatedMilestone = await repository.getMilestoneById(milestone.id);
    final updatedGoal = await repository.getGoalById(goal.id);

    expect(updatedTask, isNotNull);
    expect(updatedMilestone, isNotNull);
    expect(updatedGoal, isNotNull);
    expect(updatedTask!.progressRatio, closeTo(1.5, 0.0001));
    expect(updatedMilestone!.progressRatio, closeTo(1.5, 0.0001));
    expect(updatedGoal!.progressRatio, closeTo(1.5, 0.0001));
    expect(updatedMilestone.isCompleted, isFalse);
    expect(updatedGoal.isCompleted, isFalse);

    await repository.setTaskCompletion(taskId: task.id, isCompleted: true);
    await service.recalculateGoalProgress(goal.id);

    final completedMilestone = await repository.getMilestoneById(milestone.id);
    final completedGoal = await repository.getGoalById(goal.id);

    expect(completedMilestone, isNotNull);
    expect(completedGoal, isNotNull);
    expect(completedMilestone!.isCompleted, isTrue);
    expect(completedGoal!.isCompleted, isTrue);
  });
}
