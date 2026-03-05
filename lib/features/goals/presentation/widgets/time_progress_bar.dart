import 'dart:math' as math;

import 'package:flutter/material.dart';

class TimeProgressBar extends StatelessWidget {
  const TimeProgressBar({required this.progressRatio, super.key});

  final double progressRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = progressRatio.isNaN ? 0.0 : progressRatio;
    final normalPart = clamped.clamp(0, 1).toDouble();
    final overflowPart = math.max(0, clamped - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final normalWidth = maxWidth * normalPart;
        final overflowWidth = maxWidth * overflowPart.clamp(0, 0.5);
        final borderRadius = BorderRadius.circular(2);

        return ClipRRect(
          borderRadius: borderRadius,
          child: Container(
            height: 6,
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.6,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: normalWidth,
                  child: const ColoredBox(color: Color(0xFF2E7D32)),
                ),
                if (overflowWidth > 0)
                  Positioned(
                    left: math.max(0, normalWidth - 1),
                    top: 0,
                    bottom: 0,
                    width: overflowWidth + 1,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFFF57C00)],
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
}
