import 'package:aimgo/core/services/database/app_database.dart';
import 'package:aimgo/features/goals/application/progress_sync_service.dart';
import 'package:aimgo/features/goals/application/selected_goal_provider.dart';
import 'package:aimgo/features/home/application/home_dashboard_controller.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftAimGoRepository repository;
  late ProgressSyncService sync;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    repository = DriftAimGoRepository(database);
    sync = ProgressSyncService(repository);
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<HomeDashboardState> readState() {
    return container.read(homeDashboardStateProvider.future);
  }

  test('current goal honors the explicitly selected goal', () async {
    final goalA = await repository.createGoal(
      const CreateGoalInput(title: 'A'),
    );
    final goalB = await repository.createGoal(
      const CreateGoalInput(title: 'B'),
    );

    container.read(selectedGoalIdProvider.notifier).state = goalB.id;

    final state = await readState();
    expect(state.currentGoal?.goal.id, goalB.id);
    expect(goalA.id, isNot(goalB.id));
  });

  test('current goal falls back to the first active goal', () async {
    final goalA = await repository.createGoal(
      const CreateGoalInput(title: 'A'),
    );
    final goalB = await repository.createGoal(
      const CreateGoalInput(title: 'B'),
    );
    // Mark the first goal completed so it is no longer "active".
    await repository.updateGoalAggregate(
      GoalProgressAggregate(
        goalId: goalA.id,
        estimateMinutes: 0,
        effectiveMinutes: 0,
        progressRatio: 0,
        isCompleted: true,
      ),
    );

    final state = await readState();
    expect(state.currentGoal?.goal.id, goalB.id);
  });

  test(
    'current goal falls back to the first goal when none are active',
    () async {
      final goalA = await repository.createGoal(
        const CreateGoalInput(title: 'A'),
      );
      final goalB = await repository.createGoal(
        const CreateGoalInput(title: 'B'),
      );
      for (final goal in [goalA, goalB]) {
        await repository.updateGoalAggregate(
          GoalProgressAggregate(
            goalId: goal.id,
            estimateMinutes: 0,
            effectiveMinutes: 0,
            progressRatio: 0,
            isCompleted: true,
          ),
        );
      }

      final state = await readState();
      expect(state.currentGoal?.goal.id, goalA.id);
    },
  );

  test(
    'current goal summary highlights the first incomplete milestone',
    () async {
      final goal = await repository.createGoal(
        const CreateGoalInput(title: 'G'),
      );
      final m1 = await repository.createMilestone(
        CreateMilestoneInput(goalId: goal.id, title: 'M1', sortOrder: 0),
      );
      final m2 = await repository.createMilestone(
        CreateMilestoneInput(goalId: goal.id, title: 'M2', sortOrder: 1),
      );
      await repository.createMilestone(
        CreateMilestoneInput(goalId: goal.id, title: 'M3', sortOrder: 2),
      );
      final t1 = await repository.createTask(
        CreateTaskInput(milestoneId: m1.id, title: 'T1', estimateMinutes: 10),
      );
      await repository.createTask(
        CreateTaskInput(milestoneId: m2.id, title: 'T2', estimateMinutes: 10),
      );

      // Complete M1's only task and recalc so M1.isCompleted is derived true.
      await repository.setTaskCompletion(taskId: t1.id, isCompleted: true);
      await sync.recalculateGoalProgress(goal.id);

      final state = await readState();
      expect(state.currentGoal?.goal.id, goal.id);
      expect(state.currentGoal?.highlightMilestoneTitle, 'M2');
      expect(state.currentGoal?.completedMilestones, 1);
      expect(state.currentGoal?.totalMilestones, 3);
    },
  );

  test('last session is the most recently started one', () async {
    final goal = await repository.createGoal(const CreateGoalInput(title: 'G'));
    await repository.createFocusSession(
      CreateFocusSessionInput(
        goalId: goal.id,
        durationMinutes: 25,
        efficiencyPercent: 60,
        focusTargetLevel: FocusTargetLevel.goal,
        startedAt: DateTime(2026, 3, 1, 9),
        endedAt: DateTime(2026, 3, 1, 9, 25),
      ),
    );
    await repository.createFocusSession(
      CreateFocusSessionInput(
        goalId: goal.id,
        durationMinutes: 25,
        efficiencyPercent: 60,
        focusTargetLevel: FocusTargetLevel.goal,
        startedAt: DateTime(2026, 3, 5, 9),
        endedAt: DateTime(2026, 3, 5, 9, 25),
      ),
    );

    final state = await readState();
    expect(state.lastSession?.session.startedAt, DateTime(2026, 3, 5, 9));
  });

  test('today effective minutes only sums sessions started today', () async {
    final goal = await repository.createGoal(const CreateGoalInput(title: 'G'));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await repository.createFocusSession(
      CreateFocusSessionInput(
        goalId: goal.id,
        durationMinutes: 100,
        efficiencyPercent: 50, // effective = 50
        focusTargetLevel: FocusTargetLevel.goal,
        startedAt: today.add(const Duration(hours: 12)),
        endedAt: today.add(const Duration(hours: 13)),
      ),
    );
    await repository.createFocusSession(
      CreateFocusSessionInput(
        goalId: goal.id,
        durationMinutes: 100,
        efficiencyPercent: 80, // effective = 80, but five days ago
        focusTargetLevel: FocusTargetLevel.goal,
        startedAt: today.subtract(const Duration(days: 5)),
        endedAt: today.subtract(const Duration(days: 5)),
      ),
    );

    final state = await readState();
    expect(state.todayEffectiveMinutes, closeTo(50, 0.0001));
  });
}
