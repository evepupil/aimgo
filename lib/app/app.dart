import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/l10n/locale_controller.dart';
import 'package:aimgo/app/router/app_router.dart';
import 'package:aimgo/app/theme/app_theme.dart';
import 'package:aimgo/app/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AimGoApp extends ConsumerWidget {
  const AimGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
