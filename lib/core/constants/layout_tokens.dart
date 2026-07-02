import 'package:aimgo/app/theme/daybook_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Daybook 布局 token：统一的留白、圆角、以及「同一张纸」的表面语汇。
///
/// 核心母题：所有卡片不再是浮在灰底上的孤立白板，而是同一张暖纸上的区块——
/// 靠 1px 发丝规则线 [DaybookColors.rule] 勾边、区块之间用 [daybookRule] 分隔，
/// 不再用看不见的 0.03 透明度阴影去制造假层次。
final class LayoutTokens {
  static const double pageHorizontal = 18;
  static const double pageTop = 14;
  static const double pageBottom = 32;
  static const double sectionGap = 14;
  static const double sectionGapLarge = 22;
  static const double compactGap = 10;
  static const double cardPadding = 18;

  // 圆角与 AppTheme 对齐。
  static const double radiusSmall = 6;
  static const double radiusMedium = 10;
  static const double radiusLarge = 14;
  static const double radiusCard = 18;
  static const double radiusPill = 999;

  static const EdgeInsets listPagePadding = EdgeInsets.fromLTRB(
    pageHorizontal,
    pageTop,
    pageHorizontal,
    pageBottom,
  );

  /// Daybook 标准表面：暖纸 + 1px 发丝规则线。这是全场卡片的统一语汇，
  /// 替代以前散落各处的「白板 + 幽灵阴影」。旧调用点 [tainCardDecoration]
  /// 仍可用（等价别名），新代码请直接用本方法。
  static BoxDecoration daybookSurface(ThemeData theme) {
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(radiusCard),
      border: Border.all(color: DaybookColors.ofTheme(theme).rule),
    );
  }

  /// 内嵌「纸井」：比表面更深一档的凹槽（热力图底盘、强调区块背景）。
  static BoxDecoration daybookWell(ThemeData theme) {
    final daybook = DaybookColors.ofTheme(theme);
    return BoxDecoration(
      color: daybook.paperWell,
      borderRadius: BorderRadius.circular(radiusLarge),
    );
  }

  /// 区块之间的发丝分隔线（用于同一张纸上的分块，比 Divider 更可控）。
  static Border daybookRule(
    ThemeData theme, {
    bool top = true,
    bool bottom = false,
  }) {
    final color = DaybookColors.ofTheme(theme).rule;
    return Border(
      top: top ? BorderSide(color: color) : BorderSide.none,
      bottom: bottom ? BorderSide(color: color) : BorderSide.none,
    );
  }

  /// eyebrow：章节小标样式（字距拉开的小型大写感），可叠加基底样式。
  static TextStyle daybookEyebrow(BuildContext context, {TextStyle? base}) {
    final daybook = DaybookColors.of(context);
    return GoogleFonts.hankenGrotesk(
      textStyle: TextStyle(
        color: daybook.eyebrow,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        height: 1.2,
      ),
    ).merge(base);
  }

  /// 旧名兼容别名（历史调用点较多，保留以免大面积改动）。
  static BoxDecoration tainCardDecoration(ThemeData theme) =>
      daybookSurface(theme);
}
