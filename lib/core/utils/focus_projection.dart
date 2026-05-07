import 'dart:math' as math;

import 'package:aimgo/shared/models/planning_models.dart';

int? estimateRemainingDaysFromRecentFocus({
  required Iterable<FocusSessionModel> sessions,
  required double remainingEffectiveMinutes,
  DateTime? now,
}) {
  final today = _normalizeDate(now ?? DateTime.now());
  final windowStart = today.subtract(const Duration(days: 6));
  final effectiveMinutesByDay = <DateTime, double>{};

  for (final session in sessions) {
    final day = _normalizeDate(session.startedAt);
    if (day.isBefore(windowStart) || day.isAfter(today)) {
      continue;
    }
    effectiveMinutesByDay.update(
      day,
      (value) => value + session.effectiveMinutes,
      ifAbsent: () => session.effectiveMinutes,
    );
  }

  if (effectiveMinutesByDay.isEmpty) {
    return null;
  }

  final totalEffectiveMinutes = effectiveMinutesByDay.values.fold<double>(
    0,
    (sum, value) => sum + value,
  );
  if (totalEffectiveMinutes <= 0) {
    return null;
  }

  final averageDailyEffectiveMinutes =
      totalEffectiveMinutes / effectiveMinutesByDay.length;
  final remainingMinutes = math.max(remainingEffectiveMinutes, 0);
  if (remainingMinutes <= 0) {
    return 0;
  }

  return (remainingMinutes / averageDailyEffectiveMinutes).ceil();
}

DateTime _normalizeDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
