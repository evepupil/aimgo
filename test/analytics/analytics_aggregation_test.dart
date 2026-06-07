import 'package:aimgo/features/analytics/application/analytics_page_controller.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter_test/flutter_test.dart';

FocusSessionModel _session({
  required DateTime startedAt,
  double effectiveMinutes = 0,
  int efficiencyPercent = 0,
  int? goalId,
  FocusSessionMode mode = FocusSessionMode.pomodoro,
}) {
  return FocusSessionModel(
    id: 0,
    goalId: goalId,
    milestoneId: null,
    taskId: null,
    durationMinutes: 0,
    efficiencyPercent: efficiencyPercent,
    effectiveMinutes: effectiveMinutes,
    focusTargetLevel: FocusTargetLevel.goal,
    focusMode: mode,
    startedAt: startedAt,
    endedAt: startedAt,
    isAbandoned: false,
    createdAt: startedAt,
  );
}

AnalyticsPageState _state({
  List<FocusSessionModel> current = const [],
  List<FocusSessionModel> previous = const [],
  Map<int, String> goals = const {},
}) {
  return AnalyticsPageState(
    range: AnalyticsRange.week,
    currentSessions: current,
    previousSessions: previous,
    goalTitleById: goals,
  );
}

void main() {
  group('AnalyticsPageState totals & changeRatio', () {
    test('sums effective minutes for current and previous windows', () {
      final state = _state(
        current: [
          _session(startedAt: DateTime(2026, 3, 2, 9), effectiveMinutes: 30),
          _session(startedAt: DateTime(2026, 3, 2, 10), effectiveMinutes: 20),
        ],
        previous: [
          _session(startedAt: DateTime(2026, 2, 23, 9), effectiveMinutes: 40),
        ],
      );
      expect(state.totalEffectiveMinutes, closeTo(50, 0.0001));
      expect(state.previousEffectiveMinutes, closeTo(40, 0.0001));
    });

    test(
      'changeRatio returns 1 when previous is empty but current has data',
      () {
        final state = _state(
          current: [
            _session(startedAt: DateTime(2026, 3, 2, 9), effectiveMinutes: 10),
          ],
        );
        expect(state.changeRatio, 1);
      },
    );

    test('changeRatio returns 0 when both windows are empty', () {
      expect(_state().changeRatio, 0);
    });

    test('changeRatio is the relative delta when previous is positive', () {
      final up = _state(
        current: [
          _session(startedAt: DateTime(2026, 3, 2), effectiveMinutes: 150),
        ],
        previous: [
          _session(startedAt: DateTime(2026, 2, 23), effectiveMinutes: 100),
        ],
      );
      expect(up.changeRatio, closeTo(0.5, 0.0001));

      final down = _state(
        current: [
          _session(startedAt: DateTime(2026, 3, 2), effectiveMinutes: 50),
        ],
        previous: [
          _session(startedAt: DateTime(2026, 2, 23), effectiveMinutes: 100),
        ],
      );
      expect(down.changeRatio, closeTo(-0.5, 0.0001));
    });
  });

  group('AnalyticsPageState bucketing', () {
    test('dailyEffectiveMinutes groups by calendar day, ignoring time', () {
      final state = _state(
        current: [
          _session(startedAt: DateTime(2026, 3, 2, 9), effectiveMinutes: 30),
          _session(startedAt: DateTime(2026, 3, 2, 21), effectiveMinutes: 15),
          _session(startedAt: DateTime(2026, 3, 3, 8), effectiveMinutes: 10),
        ],
      );
      final daily = state.dailyEffectiveMinutes();
      expect(daily[DateTime(2026, 3, 2)], closeTo(45, 0.0001));
      expect(daily[DateTime(2026, 3, 3)], closeTo(10, 0.0001));
      expect(daily.length, 2);
    });

    test('hourlyEfficiency averages per hour and fills all 24 hours', () {
      final state = _state(
        current: [
          _session(startedAt: DateTime(2026, 3, 2, 9), efficiencyPercent: 80),
          _session(startedAt: DateTime(2026, 3, 2, 9), efficiencyPercent: 60),
          _session(startedAt: DateTime(2026, 3, 2, 14), efficiencyPercent: 100),
        ],
      );
      final hourly = state.hourlyEfficiency();
      expect(hourly.length, 24);
      expect(hourly[9], closeTo(70, 0.0001));
      expect(hourly[14], closeTo(100, 0.0001));
      expect(hourly[0], 0);
    });

    test('periodEfficiencyDistribution honors 5/12/18 hour boundaries', () {
      final state = _state(
        current: [
          // morning is [5, 12)
          _session(startedAt: DateTime(2026, 3, 2, 5), efficiencyPercent: 60),
          _session(startedAt: DateTime(2026, 3, 2, 11), efficiencyPercent: 80),
          // afternoon is [12, 18)
          _session(startedAt: DateTime(2026, 3, 2, 12), efficiencyPercent: 40),
          // evening is everything else
          _session(startedAt: DateTime(2026, 3, 2, 18), efficiencyPercent: 100),
          _session(startedAt: DateTime(2026, 3, 2, 4), efficiencyPercent: 20),
        ],
      );
      final dist = state.periodEfficiencyDistribution();
      expect(dist.keys, containsAll(['morning', 'afternoon', 'evening']));
      expect(dist['morning'], closeTo(70, 0.0001));
      expect(dist['afternoon'], closeTo(40, 0.0001));
      expect(dist['evening'], closeTo(60, 0.0001));
    });

    test('periodEfficiencyDistribution returns 0 for empty buckets', () {
      final dist = _state().periodEfficiencyDistribution();
      expect(dist['morning'], 0);
      expect(dist['afternoon'], 0);
      expect(dist['evening'], 0);
    });
  });

  group('AnalyticsPageState goal & mode breakdowns', () {
    test('goalContribution sums per goal and skips null goals', () {
      final state = _state(
        current: [
          _session(
            startedAt: DateTime(2026, 3, 2),
            effectiveMinutes: 30,
            goalId: 1,
          ),
          _session(
            startedAt: DateTime(2026, 3, 2),
            effectiveMinutes: 20,
            goalId: 1,
          ),
          _session(
            startedAt: DateTime(2026, 3, 2),
            effectiveMinutes: 50,
            goalId: 2,
          ),
          _session(startedAt: DateTime(2026, 3, 2), effectiveMinutes: 99),
        ],
      );
      final contribution = state.goalContribution();
      expect(contribution[1], closeTo(50, 0.0001));
      expect(contribution[2], closeTo(50, 0.0001));
      expect(contribution.containsKey(null), isFalse);
      expect(contribution.length, 2);
    });

    test('mode counts and minutes are pre-seeded with both modes', () {
      final state = _state(
        current: [
          _session(startedAt: DateTime(2026, 3, 2), effectiveMinutes: 10),
          _session(startedAt: DateTime(2026, 3, 2), effectiveMinutes: 20),
          _session(
            startedAt: DateTime(2026, 3, 2),
            effectiveMinutes: 5,
            mode: FocusSessionMode.free,
          ),
        ],
      );
      expect(state.modeSessionCount()[FocusSessionMode.pomodoro], 2);
      expect(state.modeSessionCount()[FocusSessionMode.free], 1);
      expect(
        state.modeEffectiveMinutes()[FocusSessionMode.pomodoro],
        closeTo(30, 0.0001),
      );
      expect(
        state.modeEffectiveMinutes()[FocusSessionMode.free],
        closeTo(5, 0.0001),
      );

      final empty = _state();
      expect(empty.modeSessionCount()[FocusSessionMode.pomodoro], 0);
      expect(empty.modeSessionCount()[FocusSessionMode.free], 0);
    });

    test('labelForGoal falls back to a synthetic label', () {
      final state = _state(goals: {1: 'Alpha'});
      expect(state.labelForGoal(1), 'Alpha');
      expect(state.labelForGoal(2), 'Goal #2');
    });
  });

  group('analytics helpers', () {
    test('analyticsChangeLabel signs and formats the percentage', () {
      expect(analyticsChangeLabel(0.5), '+50.0%');
      expect(analyticsChangeLabel(-0.25), '-25.0%');
      expect(analyticsChangeLabel(0), '0%');
    });

    test('normalizeHeat clamps to the 0..1 range', () {
      expect(normalizeHeat(-5), 0);
      expect(normalizeHeat(0), 0);
      expect(normalizeHeat(50), closeTo(0.5, 0.0001));
      expect(normalizeHeat(100), 1);
      expect(normalizeHeat(150), 1);
    });
  });
}
