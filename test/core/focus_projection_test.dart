import 'package:aimgo/core/utils/focus_projection.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('estimateRemainingDaysFromRecentFocus', () {
    test('returns null when there are no sessions', () {
      final days = estimateRemainingDaysFromRecentFocus(
        sessions: const [],
        remainingEffectiveMinutes: 120,
        now: DateTime(2026, 5, 8),
      );

      expect(days, isNull);
    });

    test('returns null when recent sessions have no effective minutes', () {
      final now = DateTime(2026, 5, 8, 12);
      final days = estimateRemainingDaysFromRecentFocus(
        sessions: [
          _session(
            id: 1,
            startedAt: DateTime(2026, 5, 8, 9),
            effectiveMinutes: 0,
          ),
        ],
        remainingEffectiveMinutes: 120,
        now: now,
      );

      expect(days, isNull);
    });

    test('returns zero when no effective minutes remain', () {
      final now = DateTime(2026, 5, 8, 12);
      final days = estimateRemainingDaysFromRecentFocus(
        sessions: [
          _session(
            id: 1,
            startedAt: DateTime(2026, 5, 8, 9),
            effectiveMinutes: 30,
          ),
        ],
        remainingEffectiveMinutes: 0,
        now: now,
      );

      expect(days, 0);
    });

    test('uses average effective minutes from active days only', () {
      final now = DateTime(2026, 5, 8, 12);
      final days = estimateRemainingDaysFromRecentFocus(
        sessions: [
          _session(
            id: 1,
            startedAt: DateTime(2026, 5, 8, 9),
            effectiveMinutes: 30,
          ),
          _session(
            id: 2,
            startedAt: DateTime(2026, 5, 8, 10),
            effectiveMinutes: 30,
          ),
          _session(
            id: 3,
            startedAt: DateTime(2026, 5, 6, 9),
            effectiveMinutes: 20,
          ),
        ],
        remainingEffectiveMinutes: 100,
        now: now,
      );

      expect(days, 3);
    });

    test('ignores sessions outside the recent seven-day window', () {
      final now = DateTime(2026, 5, 8, 12);
      final days = estimateRemainingDaysFromRecentFocus(
        sessions: [
          _session(
            id: 1,
            startedAt: DateTime(2026, 5, 8, 9),
            effectiveMinutes: 20,
          ),
          _session(
            id: 2,
            startedAt: DateTime(2026, 5, 2, 9),
            effectiveMinutes: 20,
          ),
          _session(
            id: 3,
            startedAt: DateTime(2026, 5, 1, 9),
            effectiveMinutes: 1000,
          ),
        ],
        remainingEffectiveMinutes: 100,
        now: now,
      );

      expect(days, 5);
    });

    test('ignores sessions after the current day', () {
      final now = DateTime(2026, 5, 8, 12);
      final days = estimateRemainingDaysFromRecentFocus(
        sessions: [
          _session(
            id: 1,
            startedAt: DateTime(2026, 5, 8, 9),
            effectiveMinutes: 20,
          ),
          _session(
            id: 2,
            startedAt: DateTime(2026, 5, 9, 9),
            effectiveMinutes: 1000,
          ),
        ],
        remainingEffectiveMinutes: 100,
        now: now,
      );

      expect(days, 5);
    });
  });
}

FocusSessionModel _session({
  required int id,
  required DateTime startedAt,
  required double effectiveMinutes,
}) {
  return FocusSessionModel(
    id: id,
    durationMinutes: effectiveMinutes.round(),
    efficiencyPercent: 100,
    effectiveMinutes: effectiveMinutes,
    focusTargetLevel: FocusTargetLevel.goal,
    focusMode: FocusSessionMode.free,
    startedAt: startedAt,
    endedAt: startedAt.add(Duration(minutes: effectiveMinutes.round())),
    isAbandoned: false,
    createdAt: startedAt,
  );
}
