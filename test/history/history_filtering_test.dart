import 'package:aimgo/features/history/application/history_page_controller.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter_test/flutter_test.dart';

FocusSessionModel _session({
  required DateTime startedAt,
  int? goalId,
  String? note,
}) {
  return FocusSessionModel(
    id: 0,
    goalId: goalId,
    milestoneId: null,
    taskId: null,
    durationMinutes: 0,
    efficiencyPercent: 0,
    effectiveMinutes: 0,
    focusTargetLevel: FocusTargetLevel.goal,
    focusMode: FocusSessionMode.pomodoro,
    startedAt: startedAt,
    endedAt: startedAt,
    isAbandoned: false,
    createdAt: startedAt,
    note: note,
  );
}

HistorySessionEntry _entry({
  required DateTime startedAt,
  int? goalId,
  String? goalTitle,
  String? milestoneTitle,
  String? taskTitle,
  String? note,
}) {
  return HistorySessionEntry(
    session: _session(startedAt: startedAt, goalId: goalId, note: note),
    goalTitle: goalTitle,
    milestoneTitle: milestoneTitle,
    taskTitle: taskTitle,
  );
}

// Builds a state and forces the (private) filter/timeline recomputation via copyWith().
HistoryPageState _state({
  required List<HistorySessionEntry> sessions,
  int? goalFilterId,
  String searchQuery = '',
  HistoryRangeFilter rangeFilter = HistoryRangeFilter.all,
  DateTime? customStart,
  DateTime? customEnd,
  DateTime? selectedDate,
}) {
  final base = HistoryPageState(
    allSessions: sessions,
    goalOptions: const [],
    viewMode: HistoryViewMode.timeline,
    searchQuery: searchQuery,
    goalFilterId: goalFilterId,
    rangeFilter: rangeFilter,
    customRangeStart: customStart,
    customRangeEnd: customEnd,
    selectedCalendarDate: selectedDate ?? DateTime(2026, 3, 2),
    filteredSessions: const <HistorySessionEntry>[],
    timelineSections: const <TimelineSection>[],
  );
  return base.copyWith();
}

void main() {
  group('HistoryPageState filtering', () {
    test('goal filter keeps only sessions for the selected goal', () {
      final state = _state(
        sessions: [
          _entry(startedAt: DateTime(2026, 3, 2), goalId: 1),
          _entry(startedAt: DateTime(2026, 3, 2), goalId: 2),
          _entry(startedAt: DateTime(2026, 3, 2), goalId: 1),
        ],
        goalFilterId: 1,
      );
      expect(state.filteredSessions, hasLength(2));
      expect(
        state.filteredSessions.every((e) => e.session.goalId == 1),
        isTrue,
      );
    });

    test('search matches goal/milestone/task/note, case-insensitively', () {
      final sessions = [
        _entry(startedAt: DateTime(2026, 3, 2), note: 'Deep Work block'),
        _entry(startedAt: DateTime(2026, 3, 2), milestoneTitle: 'Algebra'),
        _entry(startedAt: DateTime(2026, 3, 2), goalTitle: 'Math'),
      ];
      expect(
        _state(sessions: sessions, searchQuery: 'deep').filteredSessions,
        hasLength(1),
      );
      expect(
        _state(sessions: sessions, searchQuery: 'algebra').filteredSessions,
        hasLength(1),
      );
      expect(
        _state(sessions: sessions, searchQuery: 'MATH').filteredSessions,
        hasLength(1),
      );
      expect(
        _state(sessions: sessions, searchQuery: 'zzz').filteredSessions,
        isEmpty,
      );
    });

    test('custom range filters on an inclusive day window', () {
      final state = _state(
        sessions: [
          _entry(startedAt: DateTime(2026, 2, 28, 9)),
          _entry(startedAt: DateTime(2026, 3, 1, 9)),
          _entry(startedAt: DateTime(2026, 3, 3, 23)),
          _entry(startedAt: DateTime(2026, 3, 4, 1)),
        ],
        rangeFilter: HistoryRangeFilter.custom,
        customStart: DateTime(2026, 3, 1),
        customEnd: DateTime(2026, 3, 3),
      );
      // 03-01 and 03-03 are inside [03-01, 03-04); 02-28 and 03-04 are out.
      expect(state.filteredSessions, hasLength(2));
    });

    test('range filter "all" keeps every session', () {
      final state = _state(
        sessions: [
          _entry(startedAt: DateTime(2020, 1, 1)),
          _entry(startedAt: DateTime(2026, 3, 2)),
        ],
      );
      expect(state.filteredSessions, hasLength(2));
    });

    test('today filter keeps only sessions started today', () {
      final now = DateTime.now();
      final state = _state(
        sessions: [
          _entry(startedAt: now),
          _entry(startedAt: now.subtract(const Duration(days: 30))),
        ],
        rangeFilter: HistoryRangeFilter.today,
      );
      expect(state.filteredSessions, hasLength(1));
    });
  });

  group('HistoryPageState grouping & selected date', () {
    test('sessionsOfSelectedDate returns entries on the selected day', () {
      final state = _state(
        sessions: [
          _entry(startedAt: DateTime(2026, 3, 2, 9)),
          _entry(startedAt: DateTime(2026, 3, 2, 20)),
          _entry(startedAt: DateTime(2026, 3, 3, 9)),
        ],
        selectedDate: DateTime(2026, 3, 2),
      );
      expect(state.sessionsOfSelectedDate(), hasLength(2));
    });

    test('timeline buckets far-past days into descending date sections', () {
      final state = _state(
        sessions: [
          _entry(startedAt: DateTime(2020, 1, 1, 9)),
          _entry(startedAt: DateTime(2020, 1, 2, 9)),
        ],
      );
      final keys = state.timelineSections.map((s) => s.groupKey).toList();
      expect(keys, ['date:2020-01-02', 'date:2020-01-01']);
    });
  });
}
