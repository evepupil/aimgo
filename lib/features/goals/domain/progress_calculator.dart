final class ProgressCalculator {
  static const int defaultEfficiencyPercent = 60;

  static double calculateEffectiveMinutes({
    required int durationMinutes,
    int? efficiencyPercent,
  }) {
    if (durationMinutes < 0) {
      throw ArgumentError.value(
        durationMinutes,
        'durationMinutes',
        'durationMinutes must be >= 0',
      );
    }

    final resolvedEfficiency = efficiencyPercent ?? defaultEfficiencyPercent;
    if (resolvedEfficiency < 0 || resolvedEfficiency > 100) {
      throw ArgumentError.value(
        resolvedEfficiency,
        'efficiencyPercent',
        'efficiencyPercent must be between 0 and 100',
      );
    }

    return durationMinutes * (resolvedEfficiency / 100);
  }

  static double calculateProgressRatio({
    required double effectiveMinutes,
    required int estimateMinutes,
  }) {
    if (effectiveMinutes < 0) {
      throw ArgumentError.value(
        effectiveMinutes,
        'effectiveMinutes',
        'effectiveMinutes must be >= 0',
      );
    }
    if (estimateMinutes <= 0) {
      return 0;
    }
    return effectiveMinutes / estimateMinutes;
  }

  static bool areAllChildrenCompleted(Iterable<bool> states) {
    final values = states.toList(growable: false);
    if (values.isEmpty) {
      return false;
    }
    return values.every((value) => value);
  }
}
