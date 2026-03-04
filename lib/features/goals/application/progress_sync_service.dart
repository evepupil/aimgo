import 'package:aimgo/features/goals/domain/progress_calculator.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/aimgo_repository.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final progressSyncServiceProvider = Provider<ProgressSyncService>((ref) {
  final repository = ref.watch(aimGoRepositoryProvider);
  return ProgressSyncService(repository);
});

final class ProgressSyncService {
  ProgressSyncService(this._repository);

  final AimGoRepository _repository;

  Future<FocusSessionModel> createSessionAndSync(
    CreateFocusSessionInput input,
  ) async {
    return _repository.transaction(() async {
      final session = await _repository.createFocusSession(input);
      final resolvedGoalId = await _resolveGoalIdFromInput(input);
      if (resolvedGoalId != null) {
        await _recalculateGoalProgressInternal(resolvedGoalId);
      }
      return session;
    });
  }

  Future<void> recalculateGoalProgress(int goalId) async {
    await _repository.transaction(
      () => _recalculateGoalProgressInternal(goalId),
    );
  }

  Future<void> _recalculateGoalProgressInternal(int goalId) async {
    final milestones = await _repository.listMilestonesByGoalId(goalId);
    var goalEstimateMinutes = 0;
    var goalEffectiveMinutes = 0.0;
    final milestoneCompletionStates = <bool>[];

    for (final milestone in milestones) {
      final tasks = await _repository.listTasksByMilestoneId(milestone.id);
      var milestoneEstimateMinutes = 0;
      var milestoneEffectiveMinutes = 0.0;
      final taskCompletionStates = <bool>[];

      for (final task in tasks) {
        final sessions = await _repository.listFocusSessionsByTaskId(task.id);
        final taskEffectiveMinutes = sessions.fold<double>(
          0,
          (sum, session) => sum + session.effectiveMinutes,
        );
        final taskProgress = ProgressCalculator.calculateProgressRatio(
          effectiveMinutes: taskEffectiveMinutes,
          estimateMinutes: task.estimateMinutes,
        );
        await _repository.updateTaskAggregate(
          TaskProgressAggregate(
            taskId: task.id,
            effectiveMinutes: taskEffectiveMinutes,
            progressRatio: taskProgress,
          ),
        );

        milestoneEstimateMinutes += task.estimateMinutes;
        milestoneEffectiveMinutes += taskEffectiveMinutes;
        taskCompletionStates.add(task.isCompleted);
      }

      final milestoneProgress = ProgressCalculator.calculateProgressRatio(
        effectiveMinutes: milestoneEffectiveMinutes,
        estimateMinutes: milestoneEstimateMinutes,
      );
      final milestoneCompleted = ProgressCalculator.areAllChildrenCompleted(
        taskCompletionStates,
      );

      await _repository.updateMilestoneAggregate(
        MilestoneProgressAggregate(
          milestoneId: milestone.id,
          estimateMinutes: milestoneEstimateMinutes,
          effectiveMinutes: milestoneEffectiveMinutes,
          progressRatio: milestoneProgress,
          isCompleted: milestoneCompleted,
        ),
      );

      goalEstimateMinutes += milestoneEstimateMinutes;
      goalEffectiveMinutes += milestoneEffectiveMinutes;
      milestoneCompletionStates.add(milestoneCompleted);
    }

    final goalProgress = ProgressCalculator.calculateProgressRatio(
      effectiveMinutes: goalEffectiveMinutes,
      estimateMinutes: goalEstimateMinutes,
    );
    final goalCompleted = ProgressCalculator.areAllChildrenCompleted(
      milestoneCompletionStates,
    );

    await _repository.updateGoalAggregate(
      GoalProgressAggregate(
        goalId: goalId,
        estimateMinutes: goalEstimateMinutes,
        effectiveMinutes: goalEffectiveMinutes,
        progressRatio: goalProgress,
        isCompleted: goalCompleted,
      ),
    );
  }

  Future<int?> _resolveGoalIdFromInput(CreateFocusSessionInput input) async {
    if (input.goalId != null) {
      return input.goalId;
    }
    if (input.milestoneId != null) {
      final milestone = await _repository.getMilestoneById(input.milestoneId!);
      return milestone?.goalId;
    }
    if (input.taskId != null) {
      final task = await _repository.getTaskById(input.taskId!);
      if (task == null) {
        return null;
      }
      final milestone = await _repository.getMilestoneById(task.milestoneId);
      return milestone?.goalId;
    }
    return null;
  }
}
