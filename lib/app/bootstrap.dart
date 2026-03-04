import 'package:aimgo/app/app.dart';
import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localStorageService = await LocalStorageService.create();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorageService),
      ],
      child: const AimGoApp(),
    ),
  );
}
