import 'dart:io';

import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:aimgo/core/services/notification_service.dart';
import 'package:aimgo/features/settings/data/local_backup_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

final class SettingsState {
  const SettingsState({
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.autoOpenEvaluationEnabled,
  });

  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool autoOpenEvaluationEnabled;

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? autoOpenEvaluationEnabled,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoOpenEvaluationEnabled:
          autoOpenEvaluationEnabled ?? this.autoOpenEvaluationEnabled,
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
      autoOpenEvaluationEnabled: storage.getAutoOpenEvaluationEnabled(),
    );
  }

  Future<void> setNotificationEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await ref.read(localStorageServiceProvider).setNotificationEnabled(value);
    final notificationService = ref.read(notificationServiceProvider);
    if (value) {
      await notificationService.requestPermissions();
    } else {
      await notificationService.cancelAll();
    }
  }

  Future<void> setSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await ref.read(localStorageServiceProvider).setSoundEnabled(value);
  }

  Future<void> setAutoOpenEvaluationEnabled(bool value) async {
    state = state.copyWith(autoOpenEvaluationEnabled: value);
    await ref
        .read(localStorageServiceProvider)
        .setAutoOpenEvaluationEnabled(value);
  }

  Future<void> clearCache() async {
    await ref.read(localStorageServiceProvider).clearTransientCache();
    _reloadSettingsState();
  }

  Future<File> exportBackup() {
    return ref.read(localBackupServiceProvider).exportBackup();
  }

  Future<String?> importLatestBackup() async {
    final restoredPath =
        await ref.read(localBackupServiceProvider).restoreLatestBackup();
    _reloadSettingsState();
    return restoredPath;
  }

  Future<void> restoreFromFile(String path) async {
    await ref.read(localBackupServiceProvider).restoreFromFile(path);
    _reloadSettingsState();
  }

  Future<bool> hasBackupFile() {
    return ref.read(localBackupServiceProvider).hasBackupFile();
  }

  void _reloadSettingsState() {
    final storage = ref.read(localStorageServiceProvider);
    state = state.copyWith(
      notificationsEnabled: storage.getNotificationEnabled(),
      soundEnabled: storage.getSoundEnabled(),
      autoOpenEvaluationEnabled: storage.getAutoOpenEvaluationEnabled(),
    );
  }
}
