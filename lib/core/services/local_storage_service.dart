import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be overridden.');
});

final class LocalStorageService {
  LocalStorageService(this._sharedPreferences);

  static const _themePreferenceKey = 'theme.preference';
  static const _localePreferenceKey = 'locale.preference';

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
}
