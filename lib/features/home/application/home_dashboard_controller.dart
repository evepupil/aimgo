import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeDashboardControllerProvider =
    AsyncNotifierProvider<HomeDashboardController, HomeDashboardState>(
      HomeDashboardController.new,
    );

final class WeekTrendPoint {
  const WeekTrendPoint({required this.date, required this.minutes});

  final DateTime date;
  final double minutes;
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

final class HomeDashboardState {
  const HomeDashboardState({
    required this.todayEffectiveMinutes,
    required this.weekTrend,
    required this.activeGoals,
    required this.recentSessions,
  });

  final double todayEffectiveMinutes;
  final List<WeekTrendPoint> weekTrend;
  final List<GoalModel> activeGoals;
  final List<RecentSessionEntry> recentSessions;
}

final class HomeDashboardController extends AsyncNotifier<HomeDashboardState> {
  @override
  Future<HomeDashboardState> build() {
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<HomeDashboardState> _load() async {
    final repository = ref.read(aimGoRepositoryProvider);
    final goals = await repository.listGoals();
    final sessions = await repository.listFocusSessions();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayEffective = sessions
        .where((session) {
          final date = DateTime(
            session.startedAt.year,
            session.startedAt.month,
            session.startedAt.day,
          );
          return date == today;
        })
        .fold<double>(0, (sum, session) => sum + session.effectiveMinutes);

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekTrend = <WeekTrendPoint>[];
    for (var i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final next = day.add(const Duration(days: 1));
      final value = sessions
          .where(
            (session) =>
                !session.startedAt.isBefore(day) &&
                session.startedAt.isBefore(next),
          )
          .fold<double>(0, (sum, session) => sum + session.effectiveMinutes);
      weekTrend.add(WeekTrendPoint(date: day, minutes: value));
    }

    final milestoneById = <int, MilestoneModel>{};
    final taskById = <int, TaskModel>{};
    for (final goal in goals) {
      final milestones = await repository.listMilestonesByGoalId(goal.id);
      for (final milestone in milestones) {
        milestoneById[milestone.id] = milestone;
        final tasks = await repository.listTasksByMilestoneId(milestone.id);
        for (final task in tasks) {
          taskById[task.id] = task;
        }
      }
    }

    final goalById = {for (final goal in goals) goal.id: goal};
    final sortedSessions = [...sessions]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final recent = sortedSessions
        .take(8)
        .map((session) {
          final goal = session.goalId == null ? null : goalById[session.goalId];
          final milestone =
              session.milestoneId == null
                  ? null
                  : milestoneById[session.milestoneId];
          final task = session.taskId == null ? null : taskById[session.taskId];
          final title = task?.title ?? milestone?.title ?? goal?.title ?? '-';
          final path = [
            if (goal != null) goal.title,
            if (milestone != null) milestone.title,
            if (task != null) task.title,
          ].join(' > ');
          return RecentSessionEntry(session: session, title: title, path: path);
        })
        .toList(growable: false);

    final activeGoals = goals
        .where((goal) => !goal.isCompleted)
        .toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return HomeDashboardState(
      todayEffectiveMinutes: todayEffective,
      weekTrend: weekTrend,
      activeGoals: activeGoals,
      recentSessions: recent,
    );
  }
}
