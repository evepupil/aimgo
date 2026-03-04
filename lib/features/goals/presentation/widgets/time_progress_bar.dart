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
        final overflowWidth = maxWidth * overflowPart.clamp(0, 0.35);

        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.6,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Container(
                width: normalWidth,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              if (overflowWidth > 0)
                Positioned(
                  left: normalWidth - 1,
                  child: Container(
                    width: overflowWidth + 1,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFFF57C00)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
