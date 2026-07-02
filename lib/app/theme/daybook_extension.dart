import 'package:flutter/material.dart';

/// Daybook 主题扩展：把「奶油纸 × 古铜」这套设计系统里、ColorScheme 表达不了
/// 的语义颜色集中到一处，供所有页面取用。
///
/// 设计原则：全场只有一种强调色（古铜），用一个 [accentSoft] / [accentSofter]
/// 统一替代以前散落各处、十几种透明度的「靛蓝糊糊」。溢出（进度 >100%）用
/// 同色系更深的 [overflow] 锈红，跟主色既区分又同源。
@immutable
class DaybookColors extends ThemeExtension<DaybookColors> {
  const DaybookColors({
    required this.overflow,
    required this.overflowSoft,
    required this.rule,
    required this.eyebrow,
    required this.accentSoft,
    required this.accentSofter,
    required this.paperTint,
    required this.paperWell,
    required this.heatmapEmpty,
    required this.heatmapRamp,
    required this.scrim,
    required this.positive,
  });

  /// 进度 >100% 时的「溢出」锈红（填满 + 溢出渐变）。
  final Color overflow;

  /// 溢出在轨道上的柔和底色。
  final Color overflowSoft;

  /// 区块之间的发丝规则线（比 outline 略柔，专门用来在「同一张纸」上分块）。
  final Color rule;

  /// 章节小标（eyebrow）、统计标签这类次要文字的暖灰。
  final Color eyebrow;

  /// 强调色的柔和底色（约 8%），用于 chip / 选中底纹等。
  final Color accentSoft;

  /// 更柔的强调底色（约 5%），用于大面积的极淡铺底。
  final Color accentSofter;

  /// 热力图、强调区块背后的「纸面」暖底。
  final Color paperTint;

  /// 比表面更深一档的「纸井」，用于内嵌凹槽（如热力图底盘）。
  final Color paperWell;

  /// 热力图空格底色。
  final Color heatmapEmpty;

  /// 热力图 5 级暖阶（从淡到浓）。
  final List<Color> heatmapRamp;

  /// sheet 蒙层颜色。
  final Color scrim;

  /// 正向状态（连续打卡等）的克制剂色，避免抢主色。
  final Color positive;

  static const light = DaybookColors(
    overflow: Color(0xFFB5471B),
    overflowSoft: Color(0x1AB5471B),
    rule: Color(0xFFE0D6C2),
    eyebrow: Color(0xFF8A7C66),
    accentSoft: Color(0x148E5A1A),
    accentSofter: Color(0x0D8E5A1A),
    paperTint: Color(0x0F8E5A1A),
    paperWell: Color(0x14000000),
    heatmapEmpty: Color(0xFFE6DCC6),
    heatmapRamp: [
      Color(0xFFE8D9A8),
      Color(0xFFE0C582),
      Color(0xFFC99332),
      Color(0xFFA06A1E),
      Color(0xFF8E5A1A),
    ],
    scrim: Color(0x5C211C16),
    positive: Color(0xFF5E7A3A),
  );

  static const dark = DaybookColors(
    overflow: Color(0xFFE08A2B),
    overflowSoft: Color(0x24E08A2B),
    rule: Color(0xFF332C22),
    eyebrow: Color(0xFFB3A488),
    accentSoft: Color(0x24D9A85F),
    accentSofter: Color(0x14D9A85F),
    paperTint: Color(0x1AD9A85F),
    paperWell: Color(0x2C000000),
    heatmapEmpty: Color(0xFF2A251F),
    heatmapRamp: [
      Color(0xFF4A3D24),
      Color(0xFF6E5328),
      Color(0xFF9A7230),
      Color(0xFFC2913B),
      Color(0xFFD9A85F),
    ],
    scrim: Color(0x99F1E9D8),
    positive: Color(0xFF8FAE63),
  );

  static DaybookColors of(BuildContext context) => ofTheme(Theme.of(context));

  static DaybookColors ofTheme(ThemeData theme) {
    final colors = theme.extension<DaybookColors>();
    assert(colors != null, 'DaybookColors 未注册到主题，请检查 AppTheme');
    return colors!;
  }

  @override
  DaybookColors copyWith({
    Color? overflow,
    Color? overflowSoft,
    Color? rule,
    Color? eyebrow,
    Color? accentSoft,
    Color? accentSofter,
    Color? paperTint,
    Color? paperWell,
    Color? heatmapEmpty,
    List<Color>? heatmapRamp,
    Color? scrim,
    Color? positive,
  }) {
    return DaybookColors(
      overflow: overflow ?? this.overflow,
      overflowSoft: overflowSoft ?? this.overflowSoft,
      rule: rule ?? this.rule,
      eyebrow: eyebrow ?? this.eyebrow,
      accentSoft: accentSoft ?? this.accentSoft,
      accentSofter: accentSofter ?? this.accentSofter,
      paperTint: paperTint ?? this.paperTint,
      paperWell: paperWell ?? this.paperWell,
      heatmapEmpty: heatmapEmpty ?? this.heatmapEmpty,
      heatmapRamp: heatmapRamp ?? this.heatmapRamp,
      scrim: scrim ?? this.scrim,
      positive: positive ?? this.positive,
    );
  }

  @override
  DaybookColors lerp(ThemeExtension<DaybookColors>? other, double t) {
    if (other is! DaybookColors) {
      return this;
    }
    return DaybookColors(
      overflow: Color.lerp(overflow, other.overflow, t)!,
      overflowSoft: Color.lerp(overflowSoft, other.overflowSoft, t)!,
      rule: Color.lerp(rule, other.rule, t)!,
      eyebrow: Color.lerp(eyebrow, other.eyebrow, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentSofter: Color.lerp(accentSofter, other.accentSofter, t)!,
      paperTint: Color.lerp(paperTint, other.paperTint, t)!,
      paperWell: Color.lerp(paperWell, other.paperWell, t)!,
      heatmapEmpty: Color.lerp(heatmapEmpty, other.heatmapEmpty, t)!,
      heatmapRamp: List.generate(
        heatmapRamp.length,
        (i) => Color.lerp(heatmapRamp[i], other.heatmapRamp[i], t)!,
      ),
      scrim: Color.lerp(scrim, other.scrim, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
    );
  }
}
