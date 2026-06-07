import 'package:aimgo/core/services/database/app_database.dart';
import 'package:aimgo/features/profile/application/profile_dashboard_provider.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftAimGoRepository repository;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    repository = DriftAimGoRepository(database);
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<ProfileDashboardData> readData() {
    return container.read(profileDashboardProvider.future);
  }

  test(
    'aggregates task counts, estimates, focus totals and active goals',
    () async {
      final goal = await repository.createGoal(
        const CreateGoalInput(title: 'G'),
      );
      final milestone = await repository.createMilestone(
        CreateMilestoneInput(goalId: goal.id, title: 'M'),
      );
      final t1 = await repository.createTask(
        CreateTaskInput(
          milestoneId: milestone.id,
          title: 'T1',
          estimateMinutes: 10,
        ),
      );
      await repository.createTask(
        CreateTaskInput(
          milestoneId: milestone.id,
          title: 'T2',
          estimateMinutes: 20,
        ),
      );
      await repository.createTask(
        CreateTaskInput(
          milestoneId: milestone.id,
          title: 'T3',
          estimateMinutes: 30,
        ),
      );
      await repository.setTaskCompletion(taskId: t1.id, isCompleted: true);

      await repository.createFocusSession(
        CreateFocusSessionInput(
          goalId: goal.id,
          durationMinutes: 25,
          efficiencyPercent: 80, // effective 20
          focusTargetLevel: FocusTargetLevel.goal,
          startedAt: DateTime(2026, 3, 1, 9),
          endedAt: DateTime(2026, 3, 1, 9, 25),
        ),
      );
      await repository.createFocusSession(
        CreateFocusSessionInput(
          goalId: goal.id,
          durationMinutes: 50,
          efficiencyPercent: 60, // effective 30
          focusTargetLevel: FocusTargetLevel.goal,
          startedAt: DateTime(2026, 3, 2, 9),
          endedAt: DateTime(2026, 3, 2, 9, 50),
        ),
      );

      final data = await readData();
      expect(data.completedTaskCount, 1);
      expect(data.pendingTaskCount, 2);
      expect(data.totalEstimateMinutes, 60);
      expect(data.focusSessionCount, 2);
      expect(data.focusDurationMinutes, 75);
      expect(data.focusEffectiveMinutes, closeTo(50, 0.0001));
      expect(data.activeGoalCount, 1);
    },
  );

  test('completed milestone count ignores milestones with no tasks', () async {
    final goal = await repository.createGoal(const CreateGoalInput(title: 'G'));

    // M-A: single completed task => counted.
    final mA = await repository.createMilestone(
      CreateMilestoneInput(goalId: goal.id, title: 'A'),
    );
    final tA = await repository.createTask(
      CreateTaskInput(milestoneId: mA.id, title: 'TA', estimateMinutes: 10),
    );
    await repository.setTaskCompletion(taskId: tA.id, isCompleted: true);

    // M-B: single incomplete task => not counted.
    final mB = await repository.createMilestone(
      CreateMilestoneInput(goalId: goal.id, title: 'B'),
    );
    await repository.createTask(
      CreateTaskInput(milestoneId: mB.id, title: 'TB', estimateMinutes: 10),
    );

    // M-C: no tasks => not counted (empty milestone stays incomplete).
    await repository.createMilestone(
      CreateMilestoneInput(goalId: goal.id, title: 'C'),
    );

    final data = await readData();
    expect(data.completedMilestoneCount, 1);
  });

  test(
    'overdue count is pending tasks whose due date is in the past',
    () async {
      final goal = await repository.createGoal(
        const CreateGoalInput(title: 'G'),
      );
      final milestone = await repository.createMilestone(
        CreateMilestoneInput(goalId: goal.id, title: 'M'),
      );

      // Pending + past due => overdue.
      await repository.createTask(
        CreateTaskInput(
          milestoneId: milestone.id,
          title: 'OverduePending',
          estimateMinutes: 10,
          dueAt: DateTime(2020, 1, 1),
        ),
      );
      // Completed + past due => not overdue (only pending tasks count).
      final completed = await repository.createTask(
        CreateTaskInput(
          milestoneId: milestone.id,
          title: 'CompletedPastDue',
          estimateMinutes: 10,
          dueAt: DateTime(2020, 1, 1),
        ),
      );
      await repository.setTaskCompletion(
        taskId: completed.id,
        isCompleted: true,
      );
      // Pending + far-future due => not overdue.
      await repository.createTask(
        CreateTaskInput(
          milestoneId: milestone.id,
          title: 'FutureDue',
          estimateMinutes: 10,
          dueAt: DateTime(2030, 1, 1),
        ),
      );
      // Pending + no due date => not overdue.
      await repository.createTask(
        CreateTaskInput(
          milestoneId: milestone.id,
          title: 'NoDue',
          estimateMinutes: 10,
        ),
      );

      final data = await readData();
      expect(data.overdueTaskCount, 1);
    },
  );

  test(
    'streak counts consecutive days ending today until the first gap',
    () async {
      final goal = await repository.createGoal(
        const CreateGoalInput(title: 'G'),
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      Future<void> sessionOn(DateTime day) {
        final start = day.add(const Duration(hours: 12));
        return repository.createFocusSession(
          CreateFocusSessionInput(
            goalId: goal.id,
            durationMinutes: 25,
            efficiencyPercent: 60,
            focusTargetLevel: FocusTargetLevel.goal,
            startedAt: start,
            endedAt: start.add(const Duration(minutes: 25)),
          ),
        );
      }

      await sessionOn(today);
      await sessionOn(today.subtract(const Duration(days: 1)));
      // Gap on day-2; a session on day-3 must not extend the streak.
      await sessionOn(today.subtract(const Duration(days: 3)));

      final data = await readData();
      expect(data.streakDays, 2);
    },
  );
}
