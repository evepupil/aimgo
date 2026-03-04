import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemePreference { system, light, dark }

extension AppThemePreferenceX on AppThemePreference {
  ThemeMode get themeMode {
    return switch (this) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };
  }

  String get value {
    return switch (this) {
      AppThemePreference.system => 'system',
      AppThemePreference.light => 'light',
      AppThemePreference.dark => 'dark',
    };
  }

  static AppThemePreference fromValue(String? value) {
    return switch (value) {
      'light' => AppThemePreference.light,
      'dark' => AppThemePreference.dark,
      _ => AppThemePreference.system,
    };
  }

  static AppThemePreference fromThemeMode(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => AppThemePreference.light,
      ThemeMode.dark => AppThemePreference.dark,
      ThemeMode.system => AppThemePreference.system,
    };
  }
}

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

final themePreferenceProvider = Provider<AppThemePreference>((ref) {
  final themeMode = ref.watch(themeModeControllerProvider);
  return AppThemePreferenceX.fromThemeMode(themeMode);
});

final class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final localStorageService = ref.read(localStorageServiceProvider);
    final preferenceValue = localStorageService.getThemePreference();
    final preference = AppThemePreferenceX.fromValue(preferenceValue);
    return preference.themeMode;
  }

  Future<void> setPreference(AppThemePreference preference) async {
    state = preference.themeMode;
    await ref
        .read(localStorageServiceProvider)
        .setThemePreference(preference.value);
  }
}
