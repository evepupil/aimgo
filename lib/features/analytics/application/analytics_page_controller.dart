import 'dart:math' as math;

import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum AnalyticsRange { day, week, month, year }

final analyticsPageControllerProvider =
    AsyncNotifierProvider<AnalyticsPageController, AnalyticsPageState>(
      AnalyticsPageController.new,
    );

final class AnalyticsPageState {
  const AnalyticsPageState({
    required this.range,
    required this.currentSessions,
    required this.previousSessions,
    required this.goalTitleById,
  });

  final AnalyticsRange range;
  final List<FocusSessionModel> currentSessions;
  final List<FocusSessionModel> previousSessions;
  final Map<int, String> goalTitleById;

  double get totalEffectiveMinutes {
    return currentSessions.fold<double>(
      0,
      (sum, session) => sum + session.effectiveMinutes,
    );
  }

  double get previousEffectiveMinutes {
    return previousSessions.fold<double>(
      0,
      (sum, session) => sum + session.effectiveMinutes,
    );
  }

  double get changeRatio {
    if (previousEffectiveMinutes <= 0) {
      return totalEffectiveMinutes > 0 ? 1 : 0;
    }
    return (totalEffectiveMinutes - previousEffectiveMinutes) /
        previousEffectiveMinutes;
  }

  Map<DateTime, double> dailyEffectiveMinutes() {
    final map = <DateTime, double>{};
    for (final session in currentSessions) {
      final day = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );
      map.update(
        day,
        (value) => value + session.effectiveMinutes,
        ifAbsent: () => session.effectiveMinutes,
      );
    }
    return map;
  }

  Map<int, double> hourlyEfficiency() {
    final grouped = <int, List<int>>{};
    for (final session in currentSessions) {
      final hour = session.startedAt.hour;
      grouped.putIfAbsent(hour, () => []).add(session.efficiencyPercent);
    }
    final result = <int, double>{};
    for (var hour = 0; hour < 24; hour++) {
      final values = grouped[hour];
      if (values == null || values.isEmpty) {
        result[hour] = 0;
      } else {
        final avg =
            values.fold<int>(0, (sum, value) => sum + value) / values.length;
        result[hour] = avg;
      }
    }
    return result;
  }

  Map<String, double> periodEfficiencyDistribution() {
    final groups = <String, List<int>>{
      'morning': [],
      'afternoon': [],
      'evening': [],
    };

    for (final session in currentSessions) {
      final hour = session.startedAt.hour;
      if (hour >= 5 && hour < 12) {
        groups['morning']!.add(session.efficiencyPercent);
      } else if (hour >= 12 && hour < 18) {
        groups['afternoon']!.add(session.efficiencyPercent);
      } else {
        groups['evening']!.add(session.efficiencyPercent);
      }
    }

    return {
      for (final entry in groups.entries)
        entry.key:
            entry.value.isEmpty
                ? 0
                : entry.value.reduce((a, b) => a + b) / entry.value.length,
    };
  }

  Map<int, double> goalContribution() {
    final map = <int, double>{};
    for (final session in currentSessions) {
      final goalId = session.goalId;
      if (goalId == null) {
        continue;
      }
      map.update(
        goalId,
        (value) => value + session.effectiveMinutes,
        ifAbsent: () => session.effectiveMinutes,
      );
    }
    return map;
  }

  String labelForGoal(int goalId) {
    return goalTitleById[goalId] ?? 'Goal #$goalId';
  }
}

final class AnalyticsPageController extends AsyncNotifier<AnalyticsPageState> {
  @override
  Future<AnalyticsPageState> build() {
    return _load(AnalyticsRange.week);
  }

  Future<void> setRange(AnalyticsRange range) async {
    state = const AsyncLoading();
    state = AsyncData(await _load(range));
  }

  Future<void> refresh() async {
    final range = state.valueOrNull?.range ?? AnalyticsRange.week;
    state = const AsyncLoading();
    state = AsyncData(await _load(range));
  }

  Future<AnalyticsPageState> _load(AnalyticsRange range) async {
    final repository = ref.read(aimGoRepositoryProvider);
    final allSessions = await repository.listFocusSessions();
    final goals = await repository.listGoals();
    final goalTitleById = {for (final goal in goals) goal.id: goal.title};

    final now = DateTime.now();
    final currentRange = _resolveRange(range, now);
    final previousRange = _previousRange(currentRange);

    final current = allSessions
        .where(
          (session) =>
              !session.startedAt.isBefore(currentRange.start) &&
              session.startedAt.isBefore(currentRange.end),
        )
        .toList(growable: false);
    final previous = allSessions
        .where(
          (session) =>
              !session.startedAt.isBefore(previousRange.start) &&
              session.startedAt.isBefore(previousRange.end),
        )
        .toList(growable: false);

    return AnalyticsPageState(
      range: range,
      currentSessions: current,
      previousSessions: previous,
      goalTitleById: goalTitleById,
    );
  }

  _TimeRange _resolveRange(AnalyticsRange range, DateTime now) {
    switch (range) {
      case AnalyticsRange.day:
        final start = DateTime(now.year, now.month, now.day);
        return _TimeRange(
          start: start,
          end: start.add(const Duration(days: 1)),
        );
      case AnalyticsRange.week:
        final day = DateTime(now.year, now.month, now.day);
        final weekStart = day.subtract(Duration(days: day.weekday - 1));
        return _TimeRange(
          start: weekStart,
          end: weekStart.add(const Duration(days: 7)),
        );
      case AnalyticsRange.month:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return _TimeRange(start: start, end: end);
      case AnalyticsRange.year:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year + 1, 1, 1);
        return _TimeRange(start: start, end: end);
    }
  }

  _TimeRange _previousRange(_TimeRange range) {
    final delta = range.end.difference(range.start);
    return _TimeRange(start: range.start.subtract(delta), end: range.start);
  }
}

final class _TimeRange {
  const _TimeRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

String analyticsChangeLabel(double ratio) {
  final value = (ratio * 100).abs();
  final formatted = NumberFormat('0.0').format(value);
  if (ratio > 0) {
    return '+$formatted%';
  }
  if (ratio < 0) {
    return '-$formatted%';
  }
  return '0%';
}

double normalizeHeat(double value) {
  if (value <= 0) {
    return 0;
  }
  return math.min(1, value / 100);
}
