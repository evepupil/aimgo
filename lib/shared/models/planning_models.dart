enum FocusTargetLevel { goal, milestone, task }

final class GoalModel {
  const GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.estimateMinutes,
    required this.effectiveMinutes,
    required this.progressRatio,
    required this.isCompleted,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.colorHex,
    this.dueAt,
  });

  final int id;
  final String title;
  final String? description;
  final int estimateMinutes;
  final double effectiveMinutes;
  final double progressRatio;
  final bool isCompleted;
  final int sortOrder;
  final String? colorHex;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class MilestoneModel {
  const MilestoneModel({
    required this.id,
    required this.goalId,
    required this.title,
    required this.description,
    required this.estimateMinutes,
    required this.effectiveMinutes,
    required this.progressRatio,
    required this.isCompleted,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.dueAt,
  });

  final int id;
  final int goalId;
  final String title;
  final String? description;
  final int estimateMinutes;
  final double effectiveMinutes;
  final double progressRatio;
  final bool isCompleted;
  final int sortOrder;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
}

final class TaskModel {
  const TaskModel({
    required this.id,
    required this.milestoneId,
    required this.title,
    required this.description,
    required this.estimateMinutes,
    required this.effectiveMinutes,
    required this.progressRatio,
    required this.isCompleted,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.dueAt,
  });

  final int id;
  final int milestoneId;
  final String title;
  final String? description;
  final int estimateMinutes;
  final double effectiveMinutes;
  final double progressRatio;
  final bool isCompleted;
  final int sortOrder;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class FocusSessionModel {
  const FocusSessionModel({
    required this.id,
    required this.durationMinutes,
    required this.efficiencyPercent,
    required this.effectiveMinutes,
    required this.focusTargetLevel,
    required this.startedAt,
    required this.endedAt,
    required this.isAbandoned,
    required this.createdAt,
    this.goalId,
    this.milestoneId,
    this.taskId,
    this.note,
  });

  final int id;
  final int? goalId;
  final int? milestoneId;
  final int? taskId;
  final int durationMinutes;
  final int efficiencyPercent;
  final double effectiveMinutes;
  final FocusTargetLevel focusTargetLevel;
  final DateTime startedAt;
  final DateTime endedAt;
  final bool isAbandoned;
  final DateTime createdAt;
  final String? note;
}

final class CreateGoalInput {
  const CreateGoalInput({
    required this.title,
    this.description,
    this.sortOrder = 0,
    this.colorHex,
    this.dueAt,
  });

  final String title;
  final String? description;
  final int sortOrder;
  final String? colorHex;
  final DateTime? dueAt;
}

final class UpdateGoalInput {
  const UpdateGoalInput({
    required this.id,
    required this.title,
    this.description,
    this.sortOrder = 0,
    this.colorHex,
    this.dueAt,
  });

  final int id;
  final String title;
  final String? description;
  final int sortOrder;
  final String? colorHex;
  final DateTime? dueAt;
}

final class CreateMilestoneInput {
  const CreateMilestoneInput({
    required this.goalId,
    required this.title,
    this.description,
    this.sortOrder = 0,
    this.dueAt,
  });

  final int goalId;
  final String title;
  final String? description;
  final int sortOrder;
  final DateTime? dueAt;
}

final class UpdateMilestoneInput {
  const UpdateMilestoneInput({
    required this.id,
    required this.goalId,
    required this.title,
    this.description,
    this.sortOrder = 0,
    this.dueAt,
  });

  final int id;
  final int goalId;
  final String title;
  final String? description;
  final int sortOrder;
  final DateTime? dueAt;
}

final class CreateTaskInput {
  const CreateTaskInput({
    required this.milestoneId,
    required this.title,
    required this.estimateMinutes,
    this.description,
    this.sortOrder = 0,
    this.dueAt,
  });

  final int milestoneId;
  final String title;
  final String? description;
  final int estimateMinutes;
  final int sortOrder;
  final DateTime? dueAt;
}

final class UpdateTaskInput {
  const UpdateTaskInput({
    required this.id,
    required this.milestoneId,
    required this.title,
    required this.estimateMinutes,
    this.description,
    this.sortOrder = 0,
    this.dueAt,
  });

  final int id;
  final int milestoneId;
  final String title;
  final String? description;
  final int estimateMinutes;
  final int sortOrder;
  final DateTime? dueAt;
}

final class CreateFocusSessionInput {
  const CreateFocusSessionInput({
    required this.durationMinutes,
    required this.focusTargetLevel,
    required this.startedAt,
    required this.endedAt,
    this.goalId,
    this.milestoneId,
    this.taskId,
    this.efficiencyPercent,
    this.note,
    this.isAbandoned = false,
  });

  final int? goalId;
  final int? milestoneId;
  final int? taskId;
  final int durationMinutes;
  final int? efficiencyPercent;
  final FocusTargetLevel focusTargetLevel;
  final DateTime startedAt;
  final DateTime endedAt;
  final String? note;
  final bool isAbandoned;
}

final class UpdateFocusSessionInput {
  const UpdateFocusSessionInput({
    required this.id,
    required this.durationMinutes,
    required this.efficiencyPercent,
    required this.focusTargetLevel,
    this.goalId,
    this.milestoneId,
    this.taskId,
    this.note,
  });

  final int id;
  final int? goalId;
  final int? milestoneId;
  final int? taskId;
  final int durationMinutes;
  final int efficiencyPercent;
  final FocusTargetLevel focusTargetLevel;
  final String? note;
}

final class GoalProgressAggregate {
  const GoalProgressAggregate({
    required this.goalId,
    required this.estimateMinutes,
    required this.effectiveMinutes,
    required this.progressRatio,
    required this.isCompleted,
  });

  final int goalId;
  final int estimateMinutes;
  final double effectiveMinutes;
  final double progressRatio;
  final bool isCompleted;
}

final class MilestoneProgressAggregate {
  const MilestoneProgressAggregate({
    required this.milestoneId,
    required this.estimateMinutes,
    required this.effectiveMinutes,
    required this.progressRatio,
    required this.isCompleted,
  });

  final int milestoneId;
  final int estimateMinutes;
  final double effectiveMinutes;
  final double progressRatio;
  final bool isCompleted;
}

final class TaskProgressAggregate {
  const TaskProgressAggregate({
    required this.taskId,
    required this.effectiveMinutes,
    required this.progressRatio,
  });

  final int taskId;
  final double effectiveMinutes;
  final double progressRatio;
}
