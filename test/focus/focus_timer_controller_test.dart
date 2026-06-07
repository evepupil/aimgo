import 'package:aimgo/core/services/database/app_database.dart';
import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:aimgo/features/focus/application/focus_evaluation_draft_controller.dart';
import 'package:aimgo/features/focus/application/focus_models.dart';
import 'package:aimgo/features/focus/application/focus_timer_controller.dart';
import 'package:aimgo/features/goals/application/selected_goal_provider.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> makeContainer({int? selectedGoalId}) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final storage = await LocalStorageService.create();
    final database = AppDatabase(executor: NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storage),
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    if (selectedGoalId != null) {
      container.read(selectedGoalIdProvider.notifier).state = selectedGoalId;
    }
    return container;
  }

  test(
    'initial state is idle pomodoro 25min and inherits the selected goal',
    () async {
      final container = await makeContainer(selectedGoalId: 42);
      final state = container.read(focusTimerControllerProvider);

      expect(state.status, FocusTimerStatus.idle);
      expect(state.mode, FocusMode.pomodoro);
      expect(state.pomodoroMinutes, 25);
      expect(state.selectedGoalId, 42);
      expect(state.displayElapsedSeconds, 0);
    },
  );

  test('mode/preset/selection changes are rejected while running', () async {
    final container = await makeContainer();
    final controller = container.read(focusTimerControllerProvider.notifier);

    controller.setPomodoroMinutes(45);
    controller.selectGoal(7);
    expect(container.read(focusTimerControllerProvider).pomodoroMinutes, 45);
    expect(container.read(focusTimerControllerProvider).selectedGoalId, 7);

    controller.startOrResume();
    expect(
      container.read(focusTimerControllerProvider).status,
      FocusTimerStatus.running,
    );

    // Every mutation is a no-op while running.
    controller.setMode(FocusMode.free);
    controller.setPomodoroMinutes(60);
    controller.selectGoal(9);
    controller.selectMilestone(3);

    final state = container.read(focusTimerControllerProvider);
    expect(state.mode, FocusMode.pomodoro);
    expect(state.pomodoroMinutes, 45);
    expect(state.selectedGoalId, 7);
    expect(state.selectedMilestoneId, isNull);

    // Cleanup: elapsed is still 0 => plain reset, nothing persisted.
    controller.terminate(isAbandoned: true);
  });

  test('pause is a no-op when idle and toggles status when running', () async {
    final container = await makeContainer();
    final controller = container.read(focusTimerControllerProvider.notifier);

    controller.pause();
    expect(
      container.read(focusTimerControllerProvider).status,
      FocusTimerStatus.idle,
    );

    controller.startOrResume();
    expect(
      container.read(focusTimerControllerProvider).status,
      FocusTimerStatus.running,
    );

    controller.pause();
    expect(
      container.read(focusTimerControllerProvider).status,
      FocusTimerStatus.paused,
    );

    controller.startOrResume();
    expect(
      container.read(focusTimerControllerProvider).status,
      FocusTimerStatus.running,
    );

    controller.terminate(isAbandoned: true);
  });

  test(
    'terminate with no elapsed time resets without persisting a session',
    () async {
      final container = await makeContainer();
      final controller = container.read(focusTimerControllerProvider.notifier);
      final repository = container.read(aimGoRepositoryProvider);

      controller.startOrResume();
      controller.terminate(isAbandoned: false);

      // Give any (unexpected) async persistence a chance to run.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(
        container.read(focusTimerControllerProvider).status,
        FocusTimerStatus.idle,
      );
      expect(await repository.listFocusSessions(), isEmpty);
      expect(container.read(focusEvaluationDraftProvider), isNull);
    },
  );

  test(
    'terminating a real session persists it and stages an evaluation draft',
    () async {
      final container = await makeContainer();
      final controller = container.read(focusTimerControllerProvider.notifier);
      final repository = container.read(aimGoRepositoryProvider);

      controller.setMode(FocusMode.free);
      controller.startOrResume();
      // Let real wall-clock time advance so elapsed seconds > 0.
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      controller.syncFromLifecycle();
      expect(
        container.read(focusTimerControllerProvider).displayElapsedSeconds,
        greaterThan(0),
      );

      controller.terminate(isAbandoned: false);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final sessions = await repository.listFocusSessions();
      expect(sessions, hasLength(1));
      expect(sessions.single.isAbandoned, isFalse);
      expect(sessions.single.durationMinutes, 1); // ceil(~1s / 60)

      final draft = container.read(focusEvaluationDraftProvider);
      expect(draft, isNotNull);
      expect(draft!.sessionId, sessions.single.id);
      expect(draft.isAbandoned, isFalse);

      // Timer returns to idle once the session is persisted.
      expect(
        container.read(focusTimerControllerProvider).status,
        FocusTimerStatus.idle,
      );
    },
  );

  test(
    'abandoning a real session persists it without an evaluation draft',
    () async {
      final container = await makeContainer();
      final controller = container.read(focusTimerControllerProvider.notifier);
      final repository = container.read(aimGoRepositoryProvider);

      controller.setMode(FocusMode.free);
      controller.startOrResume();
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      controller.syncFromLifecycle();

      controller.terminate(isAbandoned: true);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final sessions = await repository.listFocusSessions();
      expect(sessions, hasLength(1));
      expect(sessions.single.isAbandoned, isTrue);
      expect(container.read(focusEvaluationDraftProvider), isNull);
    },
  );

  test('restoreFromSession restores the full pomodoro context', () async {
    final container = await makeContainer();
    final controller = container.read(focusTimerControllerProvider.notifier);

    controller.restoreFromSession(
      _focusSession(
        goalId: 5,
        milestoneId: 6,
        taskId: 7,
        focusMode: FocusSessionMode.pomodoro,
        durationMinutes: 45,
      ),
    );

    final state = container.read(focusTimerControllerProvider);
    expect(state.mode, FocusMode.pomodoro);
    expect(state.pomodoroMinutes, 45);
    expect(state.selectedGoalId, 5);
    expect(state.selectedMilestoneId, 6);
    expect(state.selectedTaskId, 7);
    expect(state.status, FocusTimerStatus.idle);
  });

  test('restoreFromSession restores free mode without treating elapsed minutes '
      'as a pomodoro length', () async {
    final container = await makeContainer();
    final controller = container.read(focusTimerControllerProvider.notifier);

    controller.restoreFromSession(
      _focusSession(
        goalId: 1,
        focusMode: FocusSessionMode.free,
        durationMinutes: 33,
      ),
    );

    final state = container.read(focusTimerControllerProvider);
    expect(state.mode, FocusMode.free);
    expect(state.pomodoroMinutes, 25); // default preserved, not 33
    expect(state.selectedGoalId, 1);
    expect(state.selectedMilestoneId, isNull);
    expect(state.selectedTaskId, isNull);
  });

  test('restoreFromSession is a no-op while a session is running', () async {
    final container = await makeContainer();
    final controller = container.read(focusTimerControllerProvider.notifier);

    controller.selectGoal(1);
    controller.startOrResume();

    controller.restoreFromSession(
      _focusSession(
        goalId: 9,
        milestoneId: 8,
        taskId: 7,
        focusMode: FocusSessionMode.free,
        durationMinutes: 50,
      ),
    );

    final state = container.read(focusTimerControllerProvider);
    expect(state.status, FocusTimerStatus.running);
    expect(state.selectedGoalId, 1);
    expect(state.selectedMilestoneId, isNull);
    expect(state.mode, FocusMode.pomodoro);

    controller.terminate(isAbandoned: true);
  });

  test(
    'restoreFromSession applies the fallback goal without wiping the restored '
    'milestone/task',
    () async {
      final container = await makeContainer();
      final controller = container.read(focusTimerControllerProvider.notifier);

      // A goalless session that still targets a milestone/task: the fallback
      // goal must be applied first so its clear-cascade does not erase them.
      controller.restoreFromSession(
        _focusSession(
          goalId: null,
          milestoneId: 8,
          taskId: 9,
          focusMode: FocusSessionMode.free,
          durationMinutes: 20,
        ),
        fallbackGoalId: 3,
      );

      final state = container.read(focusTimerControllerProvider);
      expect(state.selectedGoalId, 3);
      expect(state.selectedMilestoneId, 8);
      expect(state.selectedTaskId, 9);
      expect(state.mode, FocusMode.free);
    },
  );
}

FocusSessionModel _focusSession({
  required FocusSessionMode focusMode,
  required int durationMinutes,
  int? goalId,
  int? milestoneId,
  int? taskId,
}) {
  return FocusSessionModel(
    id: 1,
    goalId: goalId,
    milestoneId: milestoneId,
    taskId: taskId,
    durationMinutes: durationMinutes,
    efficiencyPercent: 60,
    effectiveMinutes: durationMinutes * 0.6,
    focusTargetLevel: FocusTargetLevel.task,
    focusMode: focusMode,
    startedAt: DateTime(2026, 3, 4, 20, 0),
    endedAt: DateTime(2026, 3, 4, 20, 45),
    isAbandoned: false,
    createdAt: DateTime(2026, 3, 4, 20, 45),
  );
}
