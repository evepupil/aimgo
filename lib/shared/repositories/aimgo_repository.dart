import 'package:aimgo/shared/models/planning_models.dart';

abstract interface class AimGoRepository {
  Future<GoalModel> createGoal(CreateGoalInput input);

  Future<MilestoneModel> createMilestone(CreateMilestoneInput input);

  Future<TaskModel> createTask(CreateTaskInput input);

  Future<void> setTaskCompletion({
    required int taskId,
    required bool isCompleted,
  });

  Future<FocusSessionModel> createFocusSession(CreateFocusSessionInput input);

  Future<GoalModel?> getGoalById(int goalId);

  Future<MilestoneModel?> getMilestoneById(int milestoneId);

  Future<TaskModel?> getTaskById(int taskId);

  Future<List<MilestoneModel>> listMilestonesByGoalId(int goalId);

  Future<List<TaskModel>> listTasksByMilestoneId(int milestoneId);

  Future<List<FocusSessionModel>> listFocusSessionsByTaskId(int taskId);

  Future<void> updateTaskAggregate(TaskProgressAggregate aggregate);

  Future<void> updateMilestoneAggregate(MilestoneProgressAggregate aggregate);

  Future<void> updateGoalAggregate(GoalProgressAggregate aggregate);

  Future<T> transaction<T>(Future<T> Function() action);
}
