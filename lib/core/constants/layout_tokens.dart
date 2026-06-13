import 'package:flutter/material.dart';

final class LayoutTokens {
  static const double pageHorizontal = 16;
  static const double pageTop = 12;
  static const double pageBottom = 28;
  static const double sectionGap = 14;
  static const double sectionGapLarge = 20;
  static const double compactGap = 10;
  static const double cardPadding = 16;
  static const double radiusSmall = 8;
  static const double radiusMedium = 10;
  static const double radiusLarge = 12;
  static const double radiusCard = 16;

  static const EdgeInsets listPagePadding = EdgeInsets.fromLTRB(
    pageHorizontal,
    pageTop,
    pageHorizontal,
    pageBottom,
  );

  static BoxDecoration tainCardDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(radiusCard),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(
          alpha: isDark ? 0.7 : 1,
        ),
      ),
      boxShadow:
          isDark
              ? null
              : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
    );
  }
}
