import 'package:flutter/material.dart';

final class AppTheme {
  static const _radiusSmall = 6.0;
  static const _radiusMedium = 8.0;
  static const _radiusLarge = 10.0;

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF4F46E5),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF6366F1),
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFDC2626),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF18181B),
      onSurfaceVariant: Color(0xFF71717A),
      outline: Color(0xFFD4D4D8),
      outlineVariant: Color(0xFFE4E4E7),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFFAFAFA),
      surfaceContainer: Color(0xFFF4F4F5),
      surfaceContainerHigh: Color(0xFFECECEE),
      surfaceContainerHighest: Color(0xFFE4E4E7),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF5F5F4),
      appBarBackground: const Color(0xFFF5F5F4),
      appBarForeground: const Color(0xFF18181B),
      navigationBarBackground: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF18181B),
      secondaryTextColor: const Color(0xFF71717A),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF818CF8),
      onPrimary: Color(0xFF1B1B20),
      secondary: Color(0xFFA5B4FC),
      onSecondary: Color(0xFF1B1B20),
      error: Color(0xFFF87171),
      onError: Color(0xFF1B1B20),
      surface: Color(0xFF18181B),
      onSurface: Color(0xFFFAFAFA),
      onSurfaceVariant: Color(0xFFA1A1AA),
      outline: Color(0xFF3F3F46),
      outlineVariant: Color(0xFF27272A),
      surfaceContainerLowest: Color(0xFF131316),
      surfaceContainerLow: Color(0xFF1C1C1F),
      surfaceContainer: Color(0xFF202023),
      surfaceContainerHigh: Color(0xFF27272A),
      surfaceContainerHighest: Color(0xFF3F3F46),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F0F11),
      appBarBackground: const Color(0xFF0F0F11),
      appBarForeground: const Color(0xFFFAFAFA),
      navigationBarBackground: const Color(0xFF161619),
      textColor: const Color(0xFFFAFAFA),
      secondaryTextColor: const Color(0xFFA1A1AA),
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
    required Color appBarBackground,
    required Color appBarForeground,
    required Color navigationBarBackground,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final textTheme = TextTheme(
      displaySmall: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.4,
      ),
      headlineSmall: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 21,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      titleSmall: TextStyle(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodyLarge: TextStyle(color: textColor, fontSize: 15, height: 1.4),
      bodyMedium: TextStyle(color: textColor, fontSize: 14, height: 1.4),
      bodySmall: TextStyle(
        color: secondaryTextColor,
        fontSize: 12.5,
        height: 1.35,
      ),
      labelLarge: TextStyle(
        color: textColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(color: textColor, fontSize: 12),
      labelSmall: TextStyle(color: secondaryTextColor, fontSize: 11),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navigationBarBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusLarge),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMedium),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMedium),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 38),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusSmall),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
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
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusMedium),
        ),
        side: BorderSide(color: colorScheme.outlineVariant),
        labelStyle: textTheme.labelLarge,
        selectedColor: colorScheme.primary.withValues(alpha: 0.12),
        showCheckmark: false,
      ),
      listTileTheme: ListTileThemeData(
        dense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusMedium),
        ),
      ),
    );
  }
}
