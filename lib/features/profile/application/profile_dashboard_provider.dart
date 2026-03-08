import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileDashboardProvider =
    FutureProvider.autoDispose<ProfileDashboardData>((ref) async {
      final repository = ref.watch(aimGoRepositoryProvider);
      final now = DateTime.now();
      final today = _normalizeDate(now);

      final goals = await repository.listGoals();
      final sessions = await repository.listFocusSessions();

      var completedTaskCount = 0;
      var pendingTaskCount = 0;
      var completedMilestoneCount = 0;
      var overdueTaskCount = 0;
      var totalEstimateMinutes = 0;

      for (final goal in goals) {
        final milestones = await repository.listMilestonesByGoalId(goal.id);
        for (final milestone in milestones) {
          final tasks = await repository.listTasksByMilestoneId(milestone.id);
          if (tasks.isNotEmpty && tasks.every((task) => task.isCompleted)) {
            completedMilestoneCount += 1;
          }
          for (final task in tasks) {
            totalEstimateMinutes += task.estimateMinutes;
            if (task.isCompleted) {
              completedTaskCount += 1;
            } else {
              pendingTaskCount += 1;
              if (task.dueAt != null && task.dueAt!.isBefore(now)) {
                overdueTaskCount += 1;
              }
            }
          }
        }
      }

      final focusSessionCount = sessions.length;
      final focusDurationMinutes = sessions.fold<int>(
        0,
        (sum, session) => sum + session.durationMinutes,
      );

      final sessionDays =
          sessions.map((session) => _normalizeDate(session.startedAt)).toSet();
      var streakDays = 0;
      for (var i = 0; ; i++) {
        final day = today.subtract(Duration(days: i));
        if (!sessionDays.contains(day)) {
          break;
        }
        streakDays += 1;
      }

      return ProfileDashboardData(
        totalEstimateMinutes: totalEstimateMinutes,
        focusSessionCount: focusSessionCount,
        focusDurationMinutes: focusDurationMinutes,
        completedTaskCount: completedTaskCount,
        completedMilestoneCount: completedMilestoneCount,
        pendingTaskCount: pendingTaskCount,
        overdueTaskCount: overdueTaskCount,
        activeGoalCount: goals.where((goal) => !goal.isCompleted).length,
        streakDays: streakDays,
      );
    });

DateTime _normalizeDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

final class ProfileDashboardData {
  const ProfileDashboardData({
    required this.totalEstimateMinutes,
    required this.focusSessionCount,
    required this.focusDurationMinutes,
    required this.completedTaskCount,
    required this.completedMilestoneCount,
    required this.pendingTaskCount,
    required this.overdueTaskCount,
    required this.activeGoalCount,
    required this.streakDays,
  });

  final int totalEstimateMinutes;
  final int focusSessionCount;
  final int focusDurationMinutes;
  final int completedTaskCount;
  final int completedMilestoneCount;
  final int pendingTaskCount;
  final int overdueTaskCount;
  final int activeGoalCount;
  final int streakDays;
}
