import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:aimgo/core/services/notification_service.dart';
import 'package:aimgo/features/settings/application/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingNotificationService implements NotificationService {
  int requestPermissionsCount = 0;
  int cancelAllCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {
    requestPermissionsCount++;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
  }

  @override
  Stream<FocusNotificationAction> get focusActionStream =>
      const Stream<FocusNotificationAction>.empty();

  @override
  Future<void> showOrUpdateFocusOngoingNotification({
    required bool paused,
    required int elapsedSeconds,
    required String? localePreference,
  }) async {}

  @override
  Future<void> cancelFocusOngoingNotification() async {}

  @override
  Future<void> showFocusCompletedNotification({
    required int durationMinutes,
    required bool soundEnabled,
    required String? localePreference,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late _RecordingNotificationService notifications;
  late ProviderContainer container;

  Future<void> setUpContainer() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    storage = await LocalStorageService.create();
    notifications = _RecordingNotificationService();
    container = ProviderContainer(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storage),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );
    addTearDown(container.dispose);
  }

  test('initial state mirrors stored defaults (all enabled)', () async {
    await setUpContainer();
    final state = container.read(settingsControllerProvider);
    expect(state.notificationsEnabled, isTrue);
    expect(state.soundEnabled, isTrue);
    expect(state.autoOpenEvaluationEnabled, isTrue);
  });

  test(
    'toggling notifications updates state, persists, and drives the service',
    () async {
      await setUpContainer();
      final controller = container.read(settingsControllerProvider.notifier);

      await controller.setNotificationEnabled(false);
      expect(
        container.read(settingsControllerProvider).notificationsEnabled,
        isFalse,
      );
      expect(storage.getNotificationEnabled(), isFalse);
      expect(notifications.cancelAllCount, 1);
      expect(notifications.requestPermissionsCount, 0);

      await controller.setNotificationEnabled(true);
      expect(
        container.read(settingsControllerProvider).notificationsEnabled,
        isTrue,
      );
      expect(storage.getNotificationEnabled(), isTrue);
      expect(notifications.requestPermissionsCount, 1);
    },
  );

  test(
    'toggling sound and auto-open persists without touching notifications',
    () async {
      await setUpContainer();
      final controller = container.read(settingsControllerProvider.notifier);

      await controller.setSoundEnabled(false);
      await controller.setAutoOpenEvaluationEnabled(false);

      final state = container.read(settingsControllerProvider);
      expect(state.soundEnabled, isFalse);
      expect(state.autoOpenEvaluationEnabled, isFalse);
      expect(storage.getSoundEnabled(), isFalse);
      expect(storage.getAutoOpenEvaluationEnabled(), isFalse);
      expect(notifications.cancelAllCount, 0);
      expect(notifications.requestPermissionsCount, 0);
    },
  );

  test('clearCache resets only the transient notification/sound flags', () async {
    await setUpContainer();
    final controller = container.read(settingsControllerProvider.notifier);

    await controller.setNotificationEnabled(false);
    await controller.setSoundEnabled(false);
    await controller.setAutoOpenEvaluationEnabled(false);

    await controller.clearCache();

    final state = container.read(settingsControllerProvider);
    // clearTransientCache removes the notification + sound keys => defaults (true).
    expect(state.notificationsEnabled, isTrue);
    expect(state.soundEnabled, isTrue);
    // auto-open is not transient and stays as the user left it.
    expect(state.autoOpenEvaluationEnabled, isFalse);
    expect(storage.getNotificationEnabled(), isTrue);
    expect(storage.getSoundEnabled(), isTrue);
    expect(storage.getAutoOpenEvaluationEnabled(), isFalse);
  });
}
