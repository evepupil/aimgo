import 'package:flutter/material.dart';

final class AppTheme {
  static const _radiusSmall = 6.0;
  static const _radiusMedium = 8.0;
  static const _radiusLarge = 10.0;

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF3478F6),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF5B9BF8),
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFB00020),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF111111),
      surfaceContainerLowest: Color(0xFFF6F9FF),
      surfaceContainerLow: Color(0xFFF0F5FF),
      surfaceContainer: Color(0xFFE8F0FE),
      surfaceContainerHigh: Color(0xFFDDE6F9),
      surfaceContainerHighest: Color(0xFFD0DDEF),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF4F7FC),
      appBarBackground: const Color(0xFFF4F7FC),
      appBarForeground: const Color(0xFF111111),
      navigationBarBackground: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF111111),
      secondaryTextColor: const Color(0xFF6B7280),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF6EA8FE),
      onPrimary: Color(0xFF101010),
      secondary: Color(0xFF93C0FF),
      onSecondary: Color(0xFF101010),
      error: Color(0xFFCF6679),
      onError: Color(0xFF101010),
      surface: Color(0xFF141414),
      onSurface: Color(0xFFF5F5F5),
      surfaceContainerLowest: Color(0xFF1A1A1A),
      surfaceContainerLow: Color(0xFF1E1E1E),
      surfaceContainer: Color(0xFF222222),
      surfaceContainerHigh: Color(0xFF282828),
      surfaceContainerHighest: Color(0xFF303030),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF101010),
      appBarBackground: const Color(0xFF141414),
      appBarForeground: const Color(0xFFF5F5F5),
      navigationBarBackground: const Color(0xFF161616),
      textColor: const Color(0xFFF5F5F5),
      secondaryTextColor: const Color(0xFFCFCFCF),
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
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      titleSmall: TextStyle(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      bodyLarge: TextStyle(color: textColor, fontSize: 15, height: 1.3),
      bodyMedium: TextStyle(color: textColor, fontSize: 14, height: 1.3),
      bodySmall: TextStyle(
        color: secondaryTextColor,
        fontSize: 12,
        height: 1.25,
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
        titleTextStyle: textTheme.titleMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navigationBarBackground,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusMedium),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMedium),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMedium),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMedium),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusLarge),
        ),
      ),
    );
  }
}
