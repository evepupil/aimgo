import 'dart:math' as math;

import 'package:aimgo/app/theme/daybook_extension.dart';
import 'package:flutter/material.dart';

class TimeProgressBar extends StatelessWidget {
  const TimeProgressBar({required this.progressRatio, super.key});

  final double progressRatio;
  static const _maxVisualOverflowRatio = 0.82;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daybook = DaybookColors.of(context);
    final primaryColor = theme.colorScheme.primary;
    final clamped = progressRatio.isNaN ? 0.0 : progressRatio;
    final normalPart = clamped.clamp(0, 1).toDouble();
    final overflowPart = math.max(0, clamped - 1).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final normalWidth = maxWidth * normalPart;
        final overflowVisualRatio = _resolveOverflowVisualRatio(overflowPart);
        final overflowWidth = maxWidth * overflowVisualRatio;
        final borderRadius = BorderRadius.circular(2);

        return ClipRRect(
          borderRadius: borderRadius,
          child: Container(
            height: 6,
            color: daybook.accentSoft,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: normalWidth,
                  child: ColoredBox(color: primaryColor),
                ),
                if (overflowWidth > 0)
                  Positioned(
                    left: math.max(0, normalWidth - 1),
                    top: 0,
                    bottom: 0,
                    width: overflowWidth + 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, daybook.overflow],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _resolveOverflowVisualRatio(double overflowPart) {
    if (overflowPart <= 0) {
      return 0;
    }
    return _maxVisualOverflowRatio * (1 - math.exp(-overflowPart * 1.4));
  }
}
