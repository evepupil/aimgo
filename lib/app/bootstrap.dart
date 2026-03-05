import 'package:aimgo/app/app.dart';
import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:aimgo/core/services/notification_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localStorageService = await LocalStorageService.create();
  final notificationService = LocalNotificationService(
    FlutterLocalNotificationsPlugin(),
  );
  await notificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorageService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const AimGoApp(),
    ),
  );
}
