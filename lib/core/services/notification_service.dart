import 'dart:ui';

import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return const NoopNotificationService();
});

abstract interface class NotificationService {
  Future<void> initialize();

  Future<void> requestPermissions();

  Future<void> cancelAll();

  Future<void> showFocusCompletedNotification({
    required int durationMinutes,
    required bool soundEnabled,
    required String? localePreference,
  });
}

final class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> showFocusCompletedNotification({
    required int durationMinutes,
    required bool soundEnabled,
    required String? localePreference,
  }) async {}
}

final class LocalNotificationService implements NotificationService {
  LocalNotificationService(this._plugin);

  static const _channelId = 'focus_session_channel';
  static const _channelName = 'Focus Session';
  static const _channelDescription = 'Focus completion reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  var _initialized = false;
  var _nextNotificationId = 1;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );
    await _plugin.initialize(initializationSettings);
    _initialized = true;
  }

  @override
  Future<void> requestPermissions() async {
    await initialize();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: false, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: false, sound: true);
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  @override
  Future<void> showFocusCompletedNotification({
    required int durationMinutes,
    required bool soundEnabled,
    required String? localePreference,
  }) async {
    await initialize();

    final resolvedMinutes = durationMinutes <= 0 ? 1 : durationMinutes;
    final locale = _resolveLocale(localePreference);
    final l10n = lookupAppLocalizations(locale);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: soundEnabled,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: soundEnabled,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: soundEnabled,
      ),
    );

    await _plugin.show(
      _nextNotificationId++,
      l10n.notificationFocusDoneTitle,
      l10n.notificationFocusDoneBody(resolvedMinutes.toString()),
      details,
    );
  }

  Locale _resolveLocale(String? localePreference) {
    if (localePreference == 'zh') {
      return const Locale('zh');
    }
    if (localePreference == 'en') {
      return const Locale('en');
    }
    final systemLocale = PlatformDispatcher.instance.locale;
    if (systemLocale.languageCode == 'zh') {
      return const Locale('zh');
    }
    return const Locale('en');
  }
}
