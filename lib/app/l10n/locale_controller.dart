import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLocalePreference { system, zh, en }

extension AppLocalePreferenceX on AppLocalePreference {
  Locale? get locale {
    return switch (this) {
      AppLocalePreference.system => null,
      AppLocalePreference.zh => const Locale('zh'),
      AppLocalePreference.en => const Locale('en'),
    };
  }

  String get value {
    return switch (this) {
      AppLocalePreference.system => 'system',
      AppLocalePreference.zh => 'zh',
      AppLocalePreference.en => 'en',
    };
  }

  static AppLocalePreference fromValue(String? value) {
    return switch (value) {
      'zh' => AppLocalePreference.zh,
      'en' => AppLocalePreference.en,
      _ => AppLocalePreference.system,
    };
  }

  static AppLocalePreference fromLocale(Locale? locale) {
    if (locale == null) {
      return AppLocalePreference.system;
    }
    return switch (locale.languageCode) {
      'zh' => AppLocalePreference.zh,
      'en' => AppLocalePreference.en,
      _ => AppLocalePreference.system,
    };
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

final localePreferenceProvider = Provider<AppLocalePreference>((ref) {
  final locale = ref.watch(localeControllerProvider);
  return AppLocalePreferenceX.fromLocale(locale);
});

final class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final localStorageService = ref.read(localStorageServiceProvider);
    final preferenceValue = localStorageService.getLocalePreference();
    final preference = AppLocalePreferenceX.fromValue(preferenceValue);
    return preference.locale;
  }

  Future<void> setPreference(AppLocalePreference preference) async {
    state = preference.locale;
    await ref
        .read(localStorageServiceProvider)
        .setLocalePreference(preference.value);
  }
}
