import 'package:aimgo/features/goals/application/selected_goal_provider.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeDashboardStateProvider =
    AsyncNotifierProvider<HomeDashboardController, HomeDashboardState>(
      HomeDashboardController.new,
    );

final class HeatmapDayPoint {
  const HeatmapDayPoint({required this.date, required this.effectiveMinutes});

  final DateTime date;
  final double effectiveMinutes;
}

final class RecentSessionEntry {
  const RecentSessionEntry({
    required this.session,
    required this.title,
    required this.path,
  });

  final FocusSessionModel session;
  final String title;
  final String path;
}

final class CurrentGoalSummary {
  const CurrentGoalSummary({
    required this.goal,
    required this.highlightMilestoneTitle,
    required this.completedMilestones,
    required this.totalMilestones,
  });

  final GoalModel goal;
  final String? highlightMilestoneTitle;
  final int completedMilestones;
  final int totalMilestones;
}

final class HomeDashboardState {
  const HomeDashboardState({
    required this.todayEffectiveMinutes,
    required this.currentGoal,
    required this.lastSession,
    required this.heatmapDays,
  });

  final double todayEffectiveMinutes;
  final CurrentGoalSummary? currentGoal;
  final RecentSessionEntry? lastSession;
  final List<HeatmapDayPoint> heatmapDays;
}

final class HomeDashboardController extends AsyncNotifier<HomeDashboardState> {
  @override
  Future<HomeDashboardState> build() async {
    ref.watch(selectedGoalIdProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<HomeDashboardState> _load() async {
    final repository = ref.read(aimGoRepositoryProvider);
    final selectedGoalId = ref.read(selectedGoalIdProvider);
    final goals = await repository.listGoals();
    final sessions = await repository.listFocusSessions();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayEffectiveMinutes = sessions
        .where((session) => _normalizeDate(session.startedAt) == today)
        .fold<double>(0, (sum, session) => sum + session.effectiveMinutes);

    final goalsById = {for (final goal in goals) goal.id: goal};
    final activeGoals = goals.where((goal) => !goal.isCompleted).toList();

    GoalModel? currentGoalModel;
    if (selectedGoalId != null) {
      currentGoalModel = goalsById[selectedGoalId];
    }
    currentGoalModel ??=
        activeGoals.isNotEmpty
            ? activeGoals.first
            : (goals.isNotEmpty ? goals.first : null);

    CurrentGoalSummary? currentGoal;
    final milestonesById = <int, MilestoneModel>{};
    final tasksById = <int, TaskModel>{};

    for (final goal in goals) {
      final milestones = await repository.listMilestonesByGoalId(goal.id);
      for (final milestone in milestones) {
        milestonesById[milestone.id] = milestone;
        final tasks = await repository.listTasksByMilestoneId(milestone.id);
        for (final task in tasks) {
          tasksById[task.id] = task;
        }
      }

      if (currentGoalModel != null && goal.id == currentGoalModel.id) {
        final highlightMilestone = milestones
            .cast<MilestoneModel?>()
            .firstWhere(
              (milestone) => milestone != null && !milestone.isCompleted,
              orElse: () => milestones.isNotEmpty ? milestones.first : null,
            );
        final completedMilestones =
            milestones.where((milestone) => milestone.isCompleted).length;
        currentGoal = CurrentGoalSummary(
          goal: goal,
          highlightMilestoneTitle: highlightMilestone?.title,
          completedMilestones: completedMilestones,
          totalMilestones: milestones.length,
        );
      }
    }

    final sortedSessions = [...sessions]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    final lastSession =
        sortedSessions.isEmpty
            ? null
            : _mapSessionEntry(
              session: sortedSessions.first,
              goalsById: goalsById,
              milestonesById: milestonesById,
              tasksById: tasksById,
            );

    final startDate = DateTime(today.year, today.month - 2, 1);
    final endDate = DateTime(today.year, today.month + 1, 0);
    final effectiveMinutesByDay = <DateTime, double>{};
    for (final session in sessions) {
      final day = _normalizeDate(session.startedAt);
      effectiveMinutesByDay.update(
        day,
        (value) => value + session.effectiveMinutes,
        ifAbsent: () => session.effectiveMinutes,
      );
    }

    final heatmapDays = <HeatmapDayPoint>[];
    for (
      var day = startDate;
      !day.isAfter(endDate);
      day = day.add(const Duration(days: 1))
    ) {
      heatmapDays.add(
        HeatmapDayPoint(
          date: day,
          effectiveMinutes: effectiveMinutesByDay[day] ?? 0,
        ),
      );
    }

    return HomeDashboardState(
      todayEffectiveMinutes: todayEffectiveMinutes,
      currentGoal: currentGoal,
      lastSession: lastSession,
      heatmapDays: heatmapDays,
    );
  }

  RecentSessionEntry _mapSessionEntry({
    required FocusSessionModel session,
    required Map<int, GoalModel> goalsById,
    required Map<int, MilestoneModel> milestonesById,
    required Map<int, TaskModel> tasksById,
  }) {
    final goal = session.goalId == null ? null : goalsById[session.goalId];
    final milestone =
        session.milestoneId == null
            ? null
            : milestonesById[session.milestoneId];
    final task = session.taskId == null ? null : tasksById[session.taskId];
    final title = task?.title ?? milestone?.title ?? goal?.title ?? '-';
    final path = [
      if (goal != null) goal.title,
      if (milestone != null) milestone.title,
      if (task != null) task.title,
    ].join(' > ');
    return RecentSessionEntry(session: session, title: title, path: path);
  }

  DateTime _normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
