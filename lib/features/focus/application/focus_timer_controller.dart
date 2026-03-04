import 'dart:async';

import 'package:aimgo/features/focus/application/focus_evaluation_draft_controller.dart';
import 'package:aimgo/features/focus/application/focus_models.dart';
import 'package:aimgo/features/goals/application/selected_goal_provider.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final focusTimerControllerProvider =
    NotifierProvider<FocusTimerController, FocusTimerState>(
      FocusTimerController.new,
    );

final class FocusTimerController extends Notifier<FocusTimerState> {
  Timer? _timer;

  @override
  FocusTimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
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
      _buildDraftAndTriggerCompletion(
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

    if (state.mode == FocusMode.pomodoro &&
        elapsed >= state.pomodoroMinutes * 60 &&
        state.sessionStartedAt != null) {
      _buildDraftAndTriggerCompletion(
        elapsedSeconds: state.pomodoroMinutes * 60,
        startedAt: state.sessionStartedAt!,
        endedAt: now,
        isAbandoned: false,
      );
    }
  }

  void _buildDraftAndTriggerCompletion({
    required int elapsedSeconds,
    required DateTime startedAt,
    required DateTime endedAt,
    required bool isAbandoned,
  }) {
    _timer?.cancel();
    _timer = null;

    final draft = FocusEvaluationDraft(
      goalId: state.selectedGoalId,
      milestoneId: state.selectedMilestoneId,
      taskId: state.selectedTaskId,
      durationMinutes: (elapsedSeconds / 60).ceil(),
      startedAt: startedAt,
      endedAt: endedAt,
      focusTargetLevel: _resolveTargetLevel(),
      focusMode: state.mode,
      isAbandoned: isAbandoned,
    );
    ref.read(focusEvaluationDraftProvider.notifier).setDraft(draft);

    state = FocusTimerState.initial(
      selectedGoalId: state.selectedGoalId,
    ).copyWith(
      mode: state.mode,
      pomodoroMinutes: state.pomodoroMinutes,
      selectedMilestoneId: state.selectedMilestoneId,
      selectedTaskId: state.selectedTaskId,
      completionEventId: state.completionEventId + 1,
    );
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

  void _resetTimerState() {
    _timer?.cancel();
    _timer = null;
    state = FocusTimerState.initial(
      selectedGoalId: state.selectedGoalId,
    ).copyWith(
      mode: state.mode,
      pomodoroMinutes: state.pomodoroMinutes,
      selectedMilestoneId: state.selectedMilestoneId,
      selectedTaskId: state.selectedTaskId,
    );
  }
}
