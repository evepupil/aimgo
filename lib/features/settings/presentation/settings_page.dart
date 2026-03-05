import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/l10n/locale_controller.dart';
import 'package:aimgo/app/theme/theme_mode_controller.dart';
import 'package:aimgo/features/settings/application/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localePreference = ref.watch(localePreferenceProvider);
    final themePreference = ref.watch(themePreferenceProvider);
    final settingsState = ref.watch(settingsControllerProvider);
    final settingsController = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.settingsLanguage,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<AppLocalePreference>(
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
                ref
                    .read(localeControllerProvider.notifier)
                    .setPreference(selection.first);
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.settingsTheme,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<AppThemePreference>(
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
                ref
                    .read(themeModeControllerProvider.notifier)
                    .setPreference(selection.first);
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.settingsOtherSection,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: settingsState.notificationsEnabled,
            title: Text(l10n.settingsNotification),
            onChanged: settingsController.setNotificationEnabled,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: settingsState.soundEnabled,
            title: Text(l10n.settingsSound),
            onChanged: settingsController.setSoundEnabled,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.settingsBackupRestore),
            subtitle: Text(l10n.settingsBackupRestoreHint),
            onTap: () {
              _showMessage(context, l10n.settingsActionPlaceholder);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(l10n.settingsClearCache),
            onTap: () async {
              await settingsController.clearCache();
              if (context.mounted) {
                _showMessage(context, l10n.settingsCacheCleared);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
