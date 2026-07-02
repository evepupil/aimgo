import 'package:aimgo/app/theme/daybook_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AimGo 视觉系统 —— 「The Daybook / 奶油纸 × 古铜」。
///
/// 暖纸底 + 墨色字 + 单一古铜强调色 + Fraunces 展示字 + Hanken Grotesk 正文。
/// 详见 docs/模块设计/ui-design-daybook.md。
final class AppTheme {
  static const _radiusSmall = 6.0;
  static const _radiusMedium = 10.0;
  static const _radiusLarge = 14.0;
  static const _radiusCard = 18.0;

  // ────────────────────────── Light · 奶油纸 ──────────────────────────
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF8E5A1A),
      onPrimary: Color(0xFFFBF7EE),
      secondary: Color(0xFF6E7A3F),
      onSecondary: Color(0xFFFBF7EE),
      error: Color(0xFFB23A2E),
      onError: Color(0xFFFBF7EE),
      surface: Color(0xFFFBF7EE),
      onSurface: Color(0xFF241F18),
      onSurfaceVariant: Color(0xFF756A57),
      outline: Color(0xFFD8CCB4),
      outlineVariant: Color(0xFFEADFCB),
      surfaceContainerLowest: Color(0xFFFFFCF5),
      surfaceContainerLow: Color(0xFFF7F1E3),
      surfaceContainer: Color(0xFFF2EBDA),
      surfaceContainerHigh: Color(0xFFEBE2CD),
      surfaceContainerHighest: Color(0xFFE2D7BE),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      daybook: DaybookColors.light,
      scaffoldBackgroundColor: const Color(0xFFF4EEDF),
      appBarBackground: const Color(0xFFF4EEDF),
      appBarForeground: const Color(0xFF241F18),
      navigationBarBackground: const Color(0xFFFBF7EE),
      textColor: const Color(0xFF241F18),
      secondaryTextColor: const Color(0xFF756A57),
    );
  }

  // ────────────────────────── Dark · 暖黑曜 ──────────────────────────
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFD9A85F),
      onPrimary: Color(0xFF231A09),
      secondary: Color(0xFF9DB070),
      onSecondary: Color(0xFF15200C),
      error: Color(0xFFE07A6A),
      onError: Color(0xFF2A120E),
      surface: Color(0xFF1F1B14),
      onSurface: Color(0xFFF1E9D8),
      onSurfaceVariant: Color(0xFFB3A488),
      outline: Color(0xFF4A4234),
      outlineVariant: Color(0xFF2F291F),
      surfaceContainerLowest: Color(0xFF131009),
      surfaceContainerLow: Color(0xFF1A1610),
      surfaceContainer: Color(0xFF221D15),
      surfaceContainerHigh: Color(0xFF2B2519),
      surfaceContainerHighest: Color(0xFF382F1F),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      daybook: DaybookColors.dark,
      scaffoldBackgroundColor: const Color(0xFF15120D),
      appBarBackground: const Color(0xFF15120D),
      appBarForeground: const Color(0xFFF1E9D8),
      navigationBarBackground: const Color(0xFF1F1B14),
      textColor: const Color(0xFFF1E9D8),
      secondaryTextColor: const Color(0xFFB3A488),
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required DaybookColors daybook,
    required Color scaffoldBackgroundColor,
    required Color appBarBackground,
    required Color appBarForeground,
    required Color navigationBarBackground,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    // 数字 / 大标题用 Fraunces（带等宽数字，专注时长、百分比不会左右跳动）。
    const tabular = <FontFeature>[FontFeature.tabularFigures()];
    final displayColor = textColor;
    final bodyColor = textColor;

    final textTheme = TextTheme(
      // ── 展示字：Fraunces ──
      displaySmall: GoogleFonts.fraunces(
        textStyle: TextStyle(
          color: displayColor,
          fontSize: 34,
          fontWeight: FontWeight.w600,
          height: 1.04,
          letterSpacing: -0.6,
          fontFeatures: tabular,
        ),
      ),
      displayMedium: GoogleFonts.fraunces(
        textStyle: TextStyle(
          color: displayColor,
          fontSize: 40,
          fontWeight: FontWeight.w600,
          height: 1.02,
          letterSpacing: -0.8,
          fontFeatures: tabular,
        ),
      ),
      headlineMedium: GoogleFonts.fraunces(
        textStyle: TextStyle(
          color: displayColor,
          fontSize: 30,
          fontWeight: FontWeight.w600,
          height: 1.08,
          letterSpacing: -0.5,
          fontFeatures: tabular,
        ),
      ),
      headlineSmall: GoogleFonts.fraunces(
        textStyle: TextStyle(
          color: displayColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.12,
          letterSpacing: -0.3,
          fontFeatures: tabular,
        ),
      ),
      titleLarge: GoogleFonts.fraunces(
        textStyle: TextStyle(
          color: displayColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.18,
          letterSpacing: -0.2,
          fontFeatures: tabular,
        ),
      ),
      // ── 正文 / UI：Hanken Grotesk ──
      titleMedium: GoogleFonts.hankenGrotesk(
        textStyle: TextStyle(
          color: bodyColor,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: -0.1,
        ),
      ),
      titleSmall: GoogleFonts.hankenGrotesk(
        textStyle: TextStyle(
          color: bodyColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: 0.02,
        ),
      ),
      bodyLarge: GoogleFonts.hankenGrotesk(
        textStyle: TextStyle(color: bodyColor, fontSize: 15.5, height: 1.45),
      ),
      bodyMedium: GoogleFonts.hankenGrotesk(
        textStyle: TextStyle(color: bodyColor, fontSize: 14, height: 1.45),
      ),
      bodySmall: GoogleFonts.hankenGrotesk(
        textStyle: TextStyle(
          color: secondaryTextColor,
          fontSize: 12.5,
          height: 1.4,
        ),
      ),
      labelLarge: GoogleFonts.hankenGrotesk(
        textStyle: TextStyle(
          color: bodyColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      labelMedium: GoogleFonts.hankenGrotesk(
        textStyle: TextStyle(
          color: bodyColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.12,
        ),
      ),
      labelSmall: GoogleFonts.hankenGrotesk(
        textStyle: TextStyle(
          color: secondaryTextColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.16,
        ),
      ),
    );

    // eyebrow（章节小标）样式见 LayoutTokens.daybookEyebrow，供布局层统一取用。

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: textTheme,
      extensions: [daybook],
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          textStyle: TextStyle(
            color: appBarForeground,
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navigationBarBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        height: 68,
        indicatorColor: daybook.accentSoft,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.hankenGrotesk(
            textStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color:
                  states.contains(WidgetState.selected)
                      ? colorScheme.primary
                      : secondaryTextColor,
            ),
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? colorScheme.primary : secondaryTextColor,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: daybook.rule,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusCard),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMedium),
          ),
          textStyle: GoogleFonts.hankenGrotesk(
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          side: BorderSide(color: colorScheme.outline, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMedium),
          ),
          textStyle: GoogleFonts.hankenGrotesk(
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusSmall),
          ),
          textStyle: GoogleFonts.hankenGrotesk(
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMedium),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMedium),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMedium),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.hankenGrotesk(
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radiusMedium),
            ),
          ),
          visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: colorScheme.outlineVariant),
        labelStyle: GoogleFonts.hankenGrotesk(
          textStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        selectedColor: daybook.accentSoft,
        showCheckmark: false,
      ),
      listTileTheme: ListTileThemeData(
        dense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusMedium),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colorScheme.surface,
        modalBarrierColor: daybook.scrim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.onSurface,
        contentTextStyle: GoogleFonts.hankenGrotesk(
          textStyle: TextStyle(
            color: colorScheme.surface,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusMedium),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusLarge),
        ),
        titleTextStyle: GoogleFonts.fraunces(
          textStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        contentTextStyle: GoogleFonts.hankenGrotesk(
          textStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: daybook.accentSoft,
        circularTrackColor: daybook.accentSoft,
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: GoogleFonts.hankenGrotesk(
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
