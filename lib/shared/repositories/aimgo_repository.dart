import 'package:aimgo/shared/models/planning_models.dart';

abstract interface class AimGoRepository {
  Future<List<GoalModel>> listGoals();

  Future<GoalModel> createGoal(CreateGoalInput input);

  Future<GoalModel> updateGoal(UpdateGoalInput input);

  Future<void> deleteGoal(int goalId);

  Future<MilestoneModel> createMilestone(CreateMilestoneInput input);

  Future<MilestoneModel> updateMilestone(UpdateMilestoneInput input);

  Future<void> deleteMilestone(int milestoneId);

  Future<TaskModel> createTask(CreateTaskInput input);

  Future<TaskModel> updateTask(UpdateTaskInput input);

  Future<void> deleteTask(int taskId);

  Future<void> setTaskCompletion({
    required int taskId,
    required bool isCompleted,
  });

  Future<FocusSessionModel> createFocusSession(CreateFocusSessionInput input);

  Future<FocusSessionModel> updateFocusSession(UpdateFocusSessionInput input);

  Future<FocusSessionModel?> getFocusSessionById(int sessionId);

  Future<void> deleteFocusSession(int sessionId);

  Future<GoalModel?> getGoalById(int goalId);

  Future<MilestoneModel?> getMilestoneById(int milestoneId);

  Future<TaskModel?> getTaskById(int taskId);

  Future<List<MilestoneModel>> listMilestonesByGoalId(int goalId);

  Future<List<TaskModel>> listTasksByMilestoneId(int milestoneId);

  Future<List<FocusSessionModel>> listFocusSessionsByTaskId(int taskId);

  Future<List<FocusSessionModel>> listFocusSessions();

  Future<void> updateTaskAggregate(TaskProgressAggregate aggregate);

  Future<void> updateMilestoneAggregate(MilestoneProgressAggregate aggregate);

  Future<void> updateGoalAggregate(GoalProgressAggregate aggregate);

  Future<T> transaction<T>(Future<T> Function() action);
}
