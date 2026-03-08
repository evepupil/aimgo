import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be overridden.');
});

final class LocalStorageService {
  LocalStorageService(this._sharedPreferences);

  static const _themePreferenceKey = 'theme.preference';
  static const _localePreferenceKey = 'locale.preference';
  static const _notificationEnabledKey = 'settings.notification.enabled';
  static const _soundEnabledKey = 'settings.sound.enabled';
  static const _autoOpenEvaluationKey = 'settings.evaluation.auto_open';

  final SharedPreferences _sharedPreferences;

  static Future<LocalStorageService> create() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return LocalStorageService(sharedPreferences);
  }

  String? getThemePreference() {
    return _sharedPreferences.getString(_themePreferenceKey);
  }

  Future<bool> setThemePreference(String value) {
    return _sharedPreferences.setString(_themePreferenceKey, value);
  }

  String? getLocalePreference() {
    return _sharedPreferences.getString(_localePreferenceKey);
  }

  Future<bool> setLocalePreference(String value) {
    return _sharedPreferences.setString(_localePreferenceKey, value);
  }

  bool getNotificationEnabled() {
    return _sharedPreferences.getBool(_notificationEnabledKey) ?? true;
  }

  Future<bool> setNotificationEnabled(bool value) {
    return _sharedPreferences.setBool(_notificationEnabledKey, value);
  }

  bool getSoundEnabled() {
    return _sharedPreferences.getBool(_soundEnabledKey) ?? true;
  }

  Future<bool> setSoundEnabled(bool value) {
    return _sharedPreferences.setBool(_soundEnabledKey, value);
  }

  bool getAutoOpenEvaluationEnabled() {
    return _sharedPreferences.getBool(_autoOpenEvaluationKey) ?? true;
  }

  Future<bool> setAutoOpenEvaluationEnabled(bool value) {
    return _sharedPreferences.setBool(_autoOpenEvaluationKey, value);
  }

  Future<void> clearTransientCache() async {
    await _sharedPreferences.remove(_notificationEnabledKey);
    await _sharedPreferences.remove(_soundEnabledKey);
  }
}
