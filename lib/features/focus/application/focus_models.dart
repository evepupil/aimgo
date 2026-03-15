import 'package:aimgo/shared/models/planning_models.dart';

enum FocusMode { pomodoro, free }

enum FocusTimerStatus { idle, running, paused }

final class FocusHierarchyItem {
  const FocusHierarchyItem({required this.goal, required this.milestones});

  final GoalModel goal;
  final List<FocusMilestoneItem> milestones;
}

final class FocusMilestoneItem {
  const FocusMilestoneItem({required this.milestone, required this.tasks});

  final MilestoneModel milestone;
  final List<TaskModel> tasks;
}

final class FocusEvaluationDraft {
  const FocusEvaluationDraft({
    required this.durationMinutes,
    required this.startedAt,
    required this.endedAt,
    required this.focusTargetLevel,
    required this.focusMode,
    required this.sessionId,
    this.goalId,
    this.milestoneId,
    this.taskId,
    this.note,
    this.isAbandoned = false,
  });

  final int sessionId;
  final int? goalId;
  final int? milestoneId;
  final int? taskId;
  final int durationMinutes;
  final DateTime startedAt;
  final DateTime endedAt;
  final FocusTargetLevel focusTargetLevel;
  final FocusMode focusMode;
  final String? note;
  final bool isAbandoned;
}

final class FocusTimerState {
  const FocusTimerState({
    required this.mode,
    required this.status,
    required this.selectedGoalId,
    required this.selectedMilestoneId,
    required this.selectedTaskId,
    required this.pomodoroMinutes,
    required this.accumulatedElapsedSeconds,
    required this.displayElapsedSeconds,
    required this.completionEventId,
    this.sessionStartedAt,
    this.runningStartedAt,
    this.noteDraft,
  });

  final FocusMode mode;
  final FocusTimerStatus status;
  final int? selectedGoalId;
  final int? selectedMilestoneId;
  final int? selectedTaskId;
  final int pomodoroMinutes;
  final int accumulatedElapsedSeconds;
  final int displayElapsedSeconds;
  final DateTime? sessionStartedAt;
  final DateTime? runningStartedAt;
  final String? noteDraft;
  final int completionEventId;

  int get durationSeconds {
    if (mode == FocusMode.free) {
      return displayElapsedSeconds;
    }
    return pomodoroMinutes * 60;
  }

  int get remainingSeconds {
    if (mode == FocusMode.free) {
      return 0;
    }
    final remaining = durationSeconds - displayElapsedSeconds;
    if (remaining <= 0) {
      return 0;
    }
    return remaining;
  }

  double get progressRatio {
    if (mode == FocusMode.free) {
      return 1;
    }
    if (durationSeconds <= 0) {
      return 0;
    }
    final ratio = displayElapsedSeconds / durationSeconds;
    return ratio.clamp(0, 1).toDouble();
  }

  bool get hasSelection {
    return selectedTaskId != null ||
        selectedMilestoneId != null ||
        selectedGoalId != null;
  }

  FocusTimerState copyWith({
    FocusMode? mode,
    FocusTimerStatus? status,
    int? selectedGoalId,
    bool clearGoal = false,
    int? selectedMilestoneId,
    bool clearMilestone = false,
    int? selectedTaskId,
    bool clearTask = false,
    int? pomodoroMinutes,
    int? accumulatedElapsedSeconds,
    int? displayElapsedSeconds,
    DateTime? sessionStartedAt,
    bool clearSessionStart = false,
    DateTime? runningStartedAt,
    bool clearRunningStart = false,
    String? noteDraft,
    bool clearNoteDraft = false,
    int? completionEventId,
  }) {
    return FocusTimerState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      selectedGoalId:
          clearGoal ? null : (selectedGoalId ?? this.selectedGoalId),
      selectedMilestoneId:
          clearMilestone
              ? null
              : (selectedMilestoneId ?? this.selectedMilestoneId),
      selectedTaskId:
          clearTask ? null : (selectedTaskId ?? this.selectedTaskId),
      pomodoroMinutes: pomodoroMinutes ?? this.pomodoroMinutes,
      accumulatedElapsedSeconds:
          accumulatedElapsedSeconds ?? this.accumulatedElapsedSeconds,
      displayElapsedSeconds:
          displayElapsedSeconds ?? this.displayElapsedSeconds,
      sessionStartedAt:
          clearSessionStart
              ? null
              : (sessionStartedAt ?? this.sessionStartedAt),
      runningStartedAt:
          clearRunningStart
              ? null
              : (runningStartedAt ?? this.runningStartedAt),
      noteDraft: clearNoteDraft ? null : (noteDraft ?? this.noteDraft),
      completionEventId: completionEventId ?? this.completionEventId,
    );
  }

  static FocusTimerState initial({required int? selectedGoalId}) {
    return FocusTimerState(
      mode: FocusMode.pomodoro,
      status: FocusTimerStatus.idle,
      selectedGoalId: selectedGoalId,
      selectedMilestoneId: null,
      selectedTaskId: null,
      pomodoroMinutes: 25,
      accumulatedElapsedSeconds: 0,
      displayElapsedSeconds: 0,
      completionEventId: 0,
      sessionStartedAt: null,
      runningStartedAt: null,
      noteDraft: null,
    );
  }
}
