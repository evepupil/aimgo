import 'package:flutter/widgets.dart';

final class LayoutTokens {
  static const double pageHorizontal = 12;
  static const double pageTop = 8;
  static const double pageBottom = 24;
  static const double sectionGap = 10;
  static const double sectionGapLarge = 14;
  static const double compactGap = 8;
  static const double cardPadding = 12;
  static const double radiusSmall = 8;
  static const double radiusMedium = 10;
  static const double radiusLarge = 12;

  static const EdgeInsets listPagePadding = EdgeInsets.fromLTRB(
    pageHorizontal,
    pageTop,
    pageHorizontal,
    pageBottom,
  );
}
