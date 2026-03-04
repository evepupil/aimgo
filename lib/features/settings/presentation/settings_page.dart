import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/l10n/locale_controller.dart';
import 'package:aimgo/app/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localePreference = ref.watch(localePreferenceProvider);
    final themePreference = ref.watch(themePreferenceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsLanguage),
            subtitle: const SizedBox(height: 12),
          ),
          SegmentedButton<AppLocalePreference>(
            segments: [
              ButtonSegment(
                value: AppLocalePreference.system,
                label: Text(l10n.langSystem),
              ),
              ButtonSegment(
                value: AppLocalePreference.zh,
                label: Text(l10n.langZh),
              ),
              ButtonSegment(
                value: AppLocalePreference.en,
                label: Text(l10n.langEn),
              ),
            ],
            selected: {localePreference},
            onSelectionChanged: (selection) {
              final selectedPreference = selection.first;
              ref
                  .read(localeControllerProvider.notifier)
                  .setPreference(selectedPreference);
            },
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsTheme),
            subtitle: const SizedBox(height: 12),
          ),
          SegmentedButton<AppThemePreference>(
            segments: [
              ButtonSegment(
                value: AppThemePreference.system,
                label: Text(l10n.themeSystem),
              ),
              ButtonSegment(
                value: AppThemePreference.light,
                label: Text(l10n.themeLight),
              ),
              ButtonSegment(
                value: AppThemePreference.dark,
                label: Text(l10n.themeDark),
              ),
            ],
            selected: {themePreference},
            onSelectionChanged: (selection) {
              final selectedPreference = selection.first;
              ref
                  .read(themeModeControllerProvider.notifier)
                  .setPreference(selectedPreference);
            },
          ),
        ],
      ),
    );
  }
}
