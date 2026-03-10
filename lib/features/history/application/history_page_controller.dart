import 'package:aimgo/features/goals/application/progress_sync_service.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum HistoryViewMode { timeline, calendar }

enum HistoryRangeFilter { all, today, thisWeek, thisMonth, custom }

final historyPageControllerProvider =
    AsyncNotifierProvider<HistoryPageController, HistoryPageState>(
      HistoryPageController.new,
    );

final class HistorySessionEntry {
  const HistorySessionEntry({
    required this.session,
    required this.goalTitle,
    required this.milestoneTitle,
    required this.taskTitle,
  });

  final FocusSessionModel session;
  final String? goalTitle;
  final String? milestoneTitle;
  final String? taskTitle;

  String get pathLabel {
    final segments = <String>[];
    if (goalTitle != null) {
      segments.add(goalTitle!);
    }
    if (milestoneTitle != null) {
      segments.add(milestoneTitle!);
    }
    if (taskTitle != null) {
      segments.add(taskTitle!);
    }
    return segments.join(' > ');
  }
}

final class TimelineSection {
  const TimelineSection({required this.groupKey, required this.sessions});

  final String groupKey;
  final List<HistorySessionEntry> sessions;
}

final class HistoryPageState {
  const HistoryPageState({
    required this.allSessions,
    required this.goalOptions,
    required this.viewMode,
    required this.searchQuery,
    required this.goalFilterId,
    required this.rangeFilter,
    required this.customRangeStart,
    required this.customRangeEnd,
    required this.selectedCalendarDate,
  });

  final List<HistorySessionEntry> allSessions;
  final List<GoalModel> goalOptions;
  final HistoryViewMode viewMode;
  final String searchQuery;
  final int? goalFilterId;
  final HistoryRangeFilter rangeFilter;
  final DateTime? customRangeStart;
  final DateTime? customRangeEnd;
  final DateTime selectedCalendarDate;

  List<HistorySessionEntry> get filteredSessions {
    final now = DateTime.now();
    final query = searchQuery.trim().toLowerCase();

    return allSessions
        .where((entry) {
          if (goalFilterId != null && entry.session.goalId != goalFilterId) {
            return false;
          }

          final sessionStart = _atStartOfDay(entry.session.startedAt);
          final today = _atStartOfDay(now);

          switch (rangeFilter) {
            case HistoryRangeFilter.all:
              break;
            case HistoryRangeFilter.today:
              if (sessionStart != today) {
                return false;
              }
              break;
            case HistoryRangeFilter.thisWeek:
              final weekStart = _weekStart(today);
              final weekEnd = weekStart.add(const Duration(days: 7));
              if (sessionStart.isBefore(weekStart) ||
                  !sessionStart.isBefore(weekEnd)) {
                return false;
              }
              break;
            case HistoryRangeFilter.thisMonth:
              if (entry.session.startedAt.year != now.year ||
                  entry.session.startedAt.month != now.month) {
                return false;
              }
              break;
            case HistoryRangeFilter.custom:
              if (customRangeStart == null || customRangeEnd == null) {
                break;
              }
              final start = _atStartOfDay(customRangeStart!);
              final endExclusive = _atStartOfDay(
                customRangeEnd!,
              ).add(const Duration(days: 1));
              if (entry.session.startedAt.isBefore(start) ||
                  !entry.session.startedAt.isBefore(endExclusive)) {
                return false;
              }
              break;
          }

          if (query.isEmpty) {
            return true;
          }
          final searchTarget =
              '${entry.goalTitle ?? ''} ${entry.milestoneTitle ?? ''} ${entry.taskTitle ?? ''} ${entry.session.note ?? ''}'
                  .toLowerCase();
          return searchTarget.contains(query);
        })
        .toList(growable: false);
  }

  List<HistorySessionEntry> sessionsOfSelectedDate() {
    final selected = _atStartOfDay(selectedCalendarDate);
    return filteredSessions
        .where((entry) {
          return _atStartOfDay(entry.session.startedAt) == selected;
        })
        .toList(growable: false);
  }

  List<TimelineSection> buildTimelineSections() {
    final sorted = [...filteredSessions]
      ..sort((a, b) => b.session.startedAt.compareTo(a.session.startedAt));
    final grouped = <String, List<HistorySessionEntry>>{};
    for (final entry in sorted) {
      final key = _groupKey(entry.session.startedAt);
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    return grouped.entries
        .map(
          (entry) =>
              TimelineSection(groupKey: entry.key, sessions: entry.value),
        )
        .toList(growable: false);
  }

  HistoryPageState copyWith({
    List<HistorySessionEntry>? allSessions,
    List<GoalModel>? goalOptions,
    HistoryViewMode? viewMode,
    String? searchQuery,
    int? goalFilterId,
    bool clearGoalFilter = false,
    HistoryRangeFilter? rangeFilter,
    DateTime? customRangeStart,
    DateTime? customRangeEnd,
    bool clearCustomRange = false,
    DateTime? selectedCalendarDate,
  }) {
    return HistoryPageState(
      allSessions: allSessions ?? this.allSessions,
      goalOptions: goalOptions ?? this.goalOptions,
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
      goalFilterId:
          clearGoalFilter ? null : (goalFilterId ?? this.goalFilterId),
      rangeFilter: rangeFilter ?? this.rangeFilter,
      customRangeStart:
          clearCustomRange ? null : (customRangeStart ?? this.customRangeStart),
      customRangeEnd:
          clearCustomRange ? null : (customRangeEnd ?? this.customRangeEnd),
      selectedCalendarDate: selectedCalendarDate ?? this.selectedCalendarDate,
    );
  }

  String _groupKey(DateTime value) {
    final now = DateTime.now();
    final date = _atStartOfDay(value);
    final today = _atStartOfDay(now);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) {
      return 'today';
    }
    if (date == yesterday) {
      return 'yesterday';
    }
    final thisWeekStart = _weekStart(today);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    if (!date.isBefore(thisWeekStart)) {
      return 'this_week';
    }
    if (!date.isBefore(lastWeekStart) && date.isBefore(thisWeekStart)) {
      return 'last_week';
    }
    return 'date:${DateFormat('yyyy-MM-dd').format(date)}';
  }

  static DateTime _atStartOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static DateTime _weekStart(DateTime value) {
    final weekday = value.weekday;
    return _atStartOfDay(value.subtract(Duration(days: weekday - 1)));
  }
}

final class HistoryPageController extends AsyncNotifier<HistoryPageState> {
  @override
  Future<HistoryPageState> build() {
    return _loadState();
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    state = const AsyncLoading();
    state = AsyncData(await _loadState(current: current));
  }

  Future<void> setViewMode(HistoryViewMode mode) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(viewMode: mode));
  }

  Future<void> setSearchQuery(String query) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(searchQuery: query));
  }

  Future<void> setGoalFilter(int? goalId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(goalFilterId: goalId, clearGoalFilter: goalId == null),
    );
  }

  Future<void> setRangeFilter(HistoryRangeFilter filter) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    if (filter != HistoryRangeFilter.custom) {
      state = AsyncData(
        current.copyWith(rangeFilter: filter, clearCustomRange: true),
      );
      return;
    }
    state = AsyncData(current.copyWith(rangeFilter: filter));
  }

  Future<void> setCustomDateRange(DateTime start, DateTime end) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        rangeFilter: HistoryRangeFilter.custom,
        customRangeStart: start,
        customRangeEnd: end,
      ),
    );
  }

  Future<void> setSelectedCalendarDate(DateTime date) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(selectedCalendarDate: date));
  }

  Future<void> updateSession({
    required int sessionId,
    required int? goalId,
    required int? milestoneId,
    required int? taskId,
    required FocusTargetLevel focusTargetLevel,
    required int efficiencyPercent,
    required String? note,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final repository = ref.read(aimGoRepositoryProvider);
    final progressSyncService = ref.read(progressSyncServiceProvider);

    final previousSession = await repository.getFocusSessionById(sessionId);
    if (previousSession == null) {
      return;
    }
    await progressSyncService.updateSessionAndSync(
      UpdateFocusSessionInput(
        id: sessionId,
        goalId: goalId,
        milestoneId: milestoneId,
        taskId: taskId,
        durationMinutes: previousSession.durationMinutes,
        efficiencyPercent: efficiencyPercent,
        focusTargetLevel: focusTargetLevel,
        note: note,
      ),
    );
    await refresh();
  }

  Future<void> deleteSession(int sessionId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final progressSyncService = ref.read(progressSyncServiceProvider);
    await progressSyncService.deleteSessionAndSync(sessionId);

    await refresh();
  }

  Future<HistoryPageState> _loadState({HistoryPageState? current}) async {
    final repository = ref.read(aimGoRepositoryProvider);
    final goals = await repository.listGoals();
    final sessions = await repository.listFocusSessions();

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
    final entries = sessions
        .map((session) {
          final milestone =
              session.milestoneId == null
                  ? null
                  : milestoneById[session.milestoneId];
          final task = session.taskId == null ? null : taskById[session.taskId];
          return HistorySessionEntry(
            session: session,
            goalTitle:
                session.goalId == null ? null : goalById[session.goalId]?.title,
            milestoneTitle: milestone?.title,
            taskTitle: task?.title,
          );
        })
        .toList(growable: false);

    return HistoryPageState(
      allSessions: entries,
      goalOptions: goals,
      viewMode: current?.viewMode ?? HistoryViewMode.timeline,
      searchQuery: current?.searchQuery ?? '',
      goalFilterId: current?.goalFilterId,
      rangeFilter: current?.rangeFilter ?? HistoryRangeFilter.all,
      customRangeStart: current?.customRangeStart,
      customRangeEnd: current?.customRangeEnd,
      selectedCalendarDate: current?.selectedCalendarDate ?? DateTime.now(),
    );
  }
}
