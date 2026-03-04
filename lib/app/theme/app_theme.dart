import 'package:flutter/material.dart';

final class AppTheme {
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1E1E1E),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF4A4A4A),
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFB00020),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF111111),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF111111)),
        bodyMedium: TextStyle(color: Color(0xFF111111)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF111111),
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFFF8F8F8),
      ),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFFFFFFF),
      onPrimary: Color(0xFF101010),
      secondary: Color(0xFFBEBEBE),
      onSecondary: Color(0xFF101010),
      error: Color(0xFFCF6679),
      onError: Color(0xFF101010),
      surface: Color(0xFF141414),
      onSurface: Color(0xFFF5F5F5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF101010),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFF5F5F5)),
        bodyMedium: TextStyle(color: Color(0xFFF5F5F5)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF141414),
        foregroundColor: Color(0xFFF5F5F5),
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF161616),
      ),
    );
  }
}
