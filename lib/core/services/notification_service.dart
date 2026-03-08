import 'dart:ui';
import 'dart:async';

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

  Stream<FocusNotificationAction> get focusActionStream;

  Future<void> showOrUpdateFocusOngoingNotification({
    required bool paused,
    required int elapsedSeconds,
    required String? localePreference,
  });

  Future<void> cancelFocusOngoingNotification();

  Future<void> showFocusCompletedNotification({
    required int durationMinutes,
    required bool soundEnabled,
    required String? localePreference,
  });
}

enum FocusNotificationAction { pause, resume }

final class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> cancelAll() async {}

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

final class LocalNotificationService implements NotificationService {
  LocalNotificationService(this._plugin);

  static const _channelId = 'focus_session_channel';
  static const _channelName = 'Focus Session';
  static const _channelDescription = 'Focus completion reminders';
  static const _focusNotificationId = 10;
  static const _focusActionPause = 'focus_action_pause';
  static const _focusActionResume = 'focus_action_resume';
  static const _darwinFocusCategory = 'focus_controls';

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<FocusNotificationAction> _focusActionController =
      StreamController<FocusNotificationAction>.broadcast();
  var _initialized = false;
  var _nextNotificationId = 1;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final l10n = lookupAppLocalizations(_resolveLocale(null));
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final darwinSettings = DarwinInitializationSettings(
      notificationCategories: <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          _darwinFocusCategory,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(_focusActionPause, l10n.focusPause),
            DarwinNotificationAction.plain(
              _focusActionResume,
              l10n.focusResume,
            ),
          ],
        ),
      ],
    );
    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );
    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
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
  Stream<FocusNotificationAction> get focusActionStream =>
      _focusActionController.stream;

  @override
  Future<void> showOrUpdateFocusOngoingNotification({
    required bool paused,
    required int elapsedSeconds,
    required String? localePreference,
  }) async {
    await initialize();
    final locale = _resolveLocale(localePreference);
    final l10n = lookupAppLocalizations(locale);
    final title =
        paused
            ? l10n.focusNotificationPausedTitle
            : l10n.focusNotificationOngoingTitle;
    final body = l10n.focusNotificationElapsed(
      _formatElapsedDuration(elapsedSeconds),
    );

    final androidActions = <AndroidNotificationAction>[
      if (paused)
        AndroidNotificationAction(
          _focusActionResume,
          l10n.focusResume,
          showsUserInterface: true,
          cancelNotification: false,
        )
      else
        AndroidNotificationAction(
          _focusActionPause,
          l10n.focusPause,
          showsUserInterface: true,
          cancelNotification: false,
        ),
    ];
    final whenMilliseconds =
        DateTime.now().millisecondsSinceEpoch - (elapsedSeconds * 1000);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        playSound: false,
        enableVibration: false,
        showWhen: !paused,
        when: paused ? null : whenMilliseconds,
        usesChronometer: !paused,
        chronometerCountDown: false,
        actions: androidActions,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
        categoryIdentifier: _darwinFocusCategory,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
        categoryIdentifier: _darwinFocusCategory,
      ),
    );

    await _plugin.show(_focusNotificationId, title, body, details);
  }

  @override
  Future<void> cancelFocusOngoingNotification() async {
    await initialize();
    await _plugin.cancel(_focusNotificationId);
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

  void _onNotificationResponse(NotificationResponse response) {
    if (response.actionId == _focusActionPause) {
      _focusActionController.add(FocusNotificationAction.pause);
      return;
    }
    if (response.actionId == _focusActionResume) {
      _focusActionController.add(FocusNotificationAction.resume);
      return;
    }
  }

  String _formatElapsedDuration(int elapsedSeconds) {
    if (elapsedSeconds < 0) {
      return '00:00';
    }
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
