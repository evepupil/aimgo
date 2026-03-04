import 'package:aimgo/features/goals/domain/progress_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgressCalculator.calculateEffectiveMinutes', () {
    test('uses default 60% when efficiency missing', () {
      final effective = ProgressCalculator.calculateEffectiveMinutes(
        durationMinutes: 50,
      );
      expect(effective, 30);
    });

    test('supports explicit efficiency range', () {
      expect(
        ProgressCalculator.calculateEffectiveMinutes(
          durationMinutes: 25,
          efficiencyPercent: 0,
        ),
        0,
      );
      expect(
        ProgressCalculator.calculateEffectiveMinutes(
          durationMinutes: 25,
          efficiencyPercent: 100,
        ),
        25,
      );
    });
  });

  group('ProgressCalculator.calculateProgressRatio', () {
    test('does not clamp values over 100%', () {
      final ratio = ProgressCalculator.calculateProgressRatio(
        effectiveMinutes: 150,
        estimateMinutes: 100,
      );
      expect(ratio, 1.5);
    });

    test('returns zero when estimate is zero', () {
      final ratio = ProgressCalculator.calculateProgressRatio(
        effectiveMinutes: 10,
        estimateMinutes: 0,
      );
      expect(ratio, 0);
    });
  });

  group('ProgressCalculator.areAllChildrenCompleted', () {
    test('returns false for empty children', () {
      expect(ProgressCalculator.areAllChildrenCompleted(const []), isFalse);
    });

    test('returns true only when all are true', () {
      expect(
        ProgressCalculator.areAllChildrenCompleted(const [true, true]),
        isTrue,
      );
      expect(
        ProgressCalculator.areAllChildrenCompleted(const [true, false]),
        isFalse,
      );
    });
  });
}
