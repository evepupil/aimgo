import 'dart:async';

import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:aimgo/core/services/notification_service.dart';
import 'package:aimgo/features/focus/application/focus_evaluation_draft_controller.dart';
import 'package:aimgo/features/focus/application/focus_models.dart';
import 'package:aimgo/features/goals/application/progress_sync_service.dart';
import 'package:aimgo/features/goals/application/selected_goal_provider.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final focusTimerControllerProvider =
    NotifierProvider<FocusTimerController, FocusTimerState>(
      FocusTimerController.new,
    );

final class FocusTimerController extends Notifier<FocusTimerState> {
  Timer? _timer;
  StreamSubscription<FocusNotificationAction>? _notificationActionSubscription;
  var _notificationPermissionEnsured = false;

  @override
  FocusTimerState build() {
    _notificationActionSubscription ??= ref
        .read(notificationServiceProvider)
        .focusActionStream
        .listen(_handleNotificationAction);

    ref.onDispose(() {
      _timer?.cancel();
      _notificationActionSubscription?.cancel();
      _notificationActionSubscription = null;
      unawaited(
        ref.read(notificationServiceProvider).cancelFocusOngoingNotification(),
      );
    });

    final selectedGoalId = ref.read(selectedGoalIdProvider);
    return FocusTimerState.initial(selectedGoalId: selectedGoalId);
  }

  void setMode(FocusMode mode) {
    if (state.status == FocusTimerStatus.running) {
      return;
    }
    state = state.copyWith(
      mode: mode,
      accumulatedElapsedSeconds: 0,
      displayElapsedSeconds: 0,
      clearSessionStart: true,
      clearRunningStart: true,
      status: FocusTimerStatus.idle,
    );
  }

  void setPomodoroMinutes(int minutes) {
    if (minutes <= 0 || state.status == FocusTimerStatus.running) {
      return;
    }
    state = state.copyWith(
      pomodoroMinutes: minutes,
      accumulatedElapsedSeconds: 0,
      displayElapsedSeconds: 0,
      clearSessionStart: true,
      clearRunningStart: true,
      status: FocusTimerStatus.idle,
    );
  }

  void selectGoal(int? goalId) {
    if (state.status == FocusTimerStatus.running) {
      return;
    }
    state = state.copyWith(
      selectedGoalId: goalId,
      clearMilestone: true,
      clearTask: true,
    );
  }

  void selectMilestone(int? milestoneId) {
    if (state.status == FocusTimerStatus.running) {
      return;
    }
    state = state.copyWith(selectedMilestoneId: milestoneId, clearTask: true);
  }

  void selectTask(int? taskId) {
    if (state.status == FocusTimerStatus.running) {
      return;
    }
    state = state.copyWith(selectedTaskId: taskId);
  }

  void startOrResume() {
    if (state.status == FocusTimerStatus.running) {
      return;
    }
    final now = DateTime.now();
    final isFreshSession = state.status == FocusTimerStatus.idle;
    state = state.copyWith(
      status: FocusTimerStatus.running,
      sessionStartedAt: isFreshSession ? now : state.sessionStartedAt,
      runningStartedAt: now,
    );
    _ensureTicker();
    _syncFocusOngoingNotification();
  }

  void pause() {
    if (state.status != FocusTimerStatus.running) {
      return;
    }
    _syncElapsed();
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(
      status: FocusTimerStatus.paused,
      accumulatedElapsedSeconds: state.displayElapsedSeconds,
      clearRunningStart: true,
    );
    _syncFocusOngoingNotification();
  }

  void setNoteDraft(String note) {
    state = state.copyWith(noteDraft: note);
  }

  void syncFromLifecycle() {
    if (state.status != FocusTimerStatus.running) {
      return;
    }
    _syncElapsed();
  }

  void terminate({required bool isAbandoned}) {
    final elapsedSeconds = state.displayElapsedSeconds;
    if (elapsedSeconds > 0 && state.sessionStartedAt != null) {
      _persistSessionAndReset(
        elapsedSeconds: elapsedSeconds,
        startedAt: state.sessionStartedAt!,
        endedAt: DateTime.now(),
        isAbandoned: isAbandoned,
      );
    } else {
      _resetTimerState();
    }
  }

  void _ensureTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncElapsed();
    });
  }

  void _syncElapsed() {
    if (state.status != FocusTimerStatus.running ||
        state.runningStartedAt == null) {
      return;
    }

    final now = DateTime.now();
    final passedSeconds = now.difference(state.runningStartedAt!).inSeconds;
    final elapsed = state.accumulatedElapsedSeconds + passedSeconds;
    state = state.copyWith(displayElapsedSeconds: elapsed);
    _syncFocusOngoingNotification();

    if (state.mode == FocusMode.pomodoro &&
        elapsed >= state.pomodoroMinutes * 60 &&
        state.sessionStartedAt != null) {
      _persistSessionAndReset(
        elapsedSeconds: state.pomodoroMinutes * 60,
        startedAt: state.sessionStartedAt!,
        endedAt: now,
        isAbandoned: false,
      );
    }
  }

  void _persistSessionAndReset({
    required int elapsedSeconds,
    required DateTime startedAt,
    required DateTime endedAt,
    required bool isAbandoned,
  }) {
    _timer?.cancel();
    _timer = null;
    unawaited(
      ref.read(notificationServiceProvider).cancelFocusOngoingNotification(),
    );
    final resolvedTargetLevel = _resolveTargetLevel();
    final resolvedDurationMinutes = (elapsedSeconds / 60).ceil();
    final selectedGoalId = state.selectedGoalId;
    final selectedMilestoneId = state.selectedMilestoneId;
    final selectedTaskId = state.selectedTaskId;
    final mode = state.mode;
    final pomodoroMinutes = state.pomodoroMinutes;
    final noteDraft = state.noteDraft?.trim();

    final input = CreateFocusSessionInput(
      goalId: selectedGoalId,
      milestoneId: selectedMilestoneId,
      taskId: selectedTaskId,
      durationMinutes: resolvedDurationMinutes,
      efficiencyPercent: null,
      focusTargetLevel: resolvedTargetLevel,
      focusMode: _toSessionMode(mode),
      startedAt: startedAt,
      endedAt: endedAt,
      note: noteDraft == null || noteDraft.isEmpty ? null : noteDraft,
      isAbandoned: isAbandoned,
    );
    state = FocusTimerState.initial(selectedGoalId: selectedGoalId).copyWith(
      mode: mode,
      pomodoroMinutes: pomodoroMinutes,
      selectedMilestoneId: selectedMilestoneId,
      selectedTaskId: selectedTaskId,
      clearNoteDraft: true,
    );
    unawaited(
      _createSessionAndHandleCompletion(
        input: input,
        mode: mode,
        isAbandoned: isAbandoned,
      ),
    );
  }

  Future<void> _createSessionAndHandleCompletion({
    required CreateFocusSessionInput input,
    required FocusMode mode,
    required bool isAbandoned,
  }) async {
    try {
      final session = await ref
          .read(progressSyncServiceProvider)
          .createSessionAndSync(input);
      _notifyIfNeeded(
        durationMinutes: input.durationMinutes,
        isAbandoned: isAbandoned,
      );
      if (!isAbandoned) {
        ref
            .read(focusEvaluationDraftProvider.notifier)
            .setDraft(
              FocusEvaluationDraft(
                sessionId: session.id,
                goalId: input.goalId,
                milestoneId: input.milestoneId,
                taskId: input.taskId,
                durationMinutes: input.durationMinutes,
                startedAt: input.startedAt,
                endedAt: input.endedAt,
                focusTargetLevel: input.focusTargetLevel,
                focusMode: mode,
                note: input.note,
                isAbandoned: false,
              ),
            );
        state = state.copyWith(completionEventId: state.completionEventId + 1);
      }
    } catch (_) {
      // Session persistence failed; keep timer reset state and skip completion flow.
    }
  }

  FocusTargetLevel _resolveTargetLevel() {
    if (state.selectedTaskId != null) {
      return FocusTargetLevel.task;
    }
    if (state.selectedMilestoneId != null) {
      return FocusTargetLevel.milestone;
    }
    return FocusTargetLevel.goal;
  }

  FocusSessionMode _toSessionMode(FocusMode mode) {
    return switch (mode) {
      FocusMode.pomodoro => FocusSessionMode.pomodoro,
      FocusMode.free => FocusSessionMode.free,
    };
  }

  void _notifyIfNeeded({
    required int durationMinutes,
    required bool isAbandoned,
  }) {
    if (isAbandoned) {
      return;
    }
    final storage = ref.read(localStorageServiceProvider);
    final notificationsEnabled = storage.getNotificationEnabled();
    if (!notificationsEnabled) {
      return;
    }
    unawaited(
      ref
          .read(notificationServiceProvider)
          .showFocusCompletedNotification(
            durationMinutes: durationMinutes,
            soundEnabled: storage.getSoundEnabled(),
            localePreference: storage.getLocalePreference(),
          ),
    );
  }

  void _resetTimerState() {
    _timer?.cancel();
    _timer = null;
    unawaited(
      ref.read(notificationServiceProvider).cancelFocusOngoingNotification(),
    );
    state = FocusTimerState.initial(
      selectedGoalId: state.selectedGoalId,
    ).copyWith(
      mode: state.mode,
      pomodoroMinutes: state.pomodoroMinutes,
      selectedMilestoneId: state.selectedMilestoneId,
      selectedTaskId: state.selectedTaskId,
    );
  }

  void _handleNotificationAction(FocusNotificationAction action) {
    if (action == FocusNotificationAction.pause &&
        state.status == FocusTimerStatus.running) {
      pause();
      return;
    }
    if (action == FocusNotificationAction.resume &&
        state.status == FocusTimerStatus.paused) {
      startOrResume();
    }
  }

  void _syncFocusOngoingNotification() {
    final storage = ref.read(localStorageServiceProvider);
    final notificationsEnabled = storage.getNotificationEnabled();
    if (!notificationsEnabled || state.status == FocusTimerStatus.idle) {
      unawaited(
        ref.read(notificationServiceProvider).cancelFocusOngoingNotification(),
      );
      return;
    }
    if (!_notificationPermissionEnsured) {
      _notificationPermissionEnsured = true;
      unawaited(ref.read(notificationServiceProvider).requestPermissions());
    }
    unawaited(
      ref
          .read(notificationServiceProvider)
          .showOrUpdateFocusOngoingNotification(
            paused: state.status == FocusTimerStatus.paused,
            elapsedSeconds: state.displayElapsedSeconds,
            localePreference: storage.getLocalePreference(),
          ),
    );
  }
}
