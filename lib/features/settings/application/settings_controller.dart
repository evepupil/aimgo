import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

final class SettingsState {
  const SettingsState({
    required this.notificationsEnabled,
    required this.soundEnabled,
  });

  final bool notificationsEnabled;
  final bool soundEnabled;

  SettingsState copyWith({bool? notificationsEnabled, bool? soundEnabled}) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}

final class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final storage = ref.read(localStorageServiceProvider);
    return SettingsState(
      notificationsEnabled: storage.getNotificationEnabled(),
      soundEnabled: storage.getSoundEnabled(),
    );
  }

  Future<void> setNotificationEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await ref.read(localStorageServiceProvider).setNotificationEnabled(value);
  }

  Future<void> setSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await ref.read(localStorageServiceProvider).setSoundEnabled(value);
  }

  Future<void> clearCache() async {
    await ref.read(localStorageServiceProvider).clearTransientCache();
    final storage = ref.read(localStorageServiceProvider);
    state = state.copyWith(
      notificationsEnabled: storage.getNotificationEnabled(),
      soundEnabled: storage.getSoundEnabled(),
    );
  }
}
