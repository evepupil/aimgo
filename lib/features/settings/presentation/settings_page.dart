import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/l10n/locale_controller.dart';
import 'package:aimgo/app/theme/theme_mode_controller.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
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
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(l10n.settingsTitle),
              ),
            ],
        body: ListView(
          padding: LayoutTokens.listPagePadding,
          children: [
            Text(
              l10n.settingsLanguage,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: LayoutTokens.compactGap),
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
            const SizedBox(height: LayoutTokens.sectionGap * 2),
            Text(
              l10n.settingsTheme,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: LayoutTokens.compactGap),
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
            const SizedBox(height: LayoutTokens.sectionGap * 2),
            Text(
              l10n.settingsOtherSection,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: LayoutTokens.compactGap),
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: settingsState.autoOpenEvaluationEnabled,
              title: Text(l10n.settingsAutoOpenEvaluation),
              onChanged: settingsController.setAutoOpenEvaluationEnabled,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.backup_outlined),
              title: Text(l10n.settingsBackupRestore),
              subtitle: Text(l10n.settingsBackupRestoreHint),
              onTap:
                  () => _onTapBackupRestore(
                    context: context,
                    ref: ref,
                    controller: settingsController,
                  ),
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
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onTapBackupRestore({
    required BuildContext context,
    required WidgetRef ref,
    required SettingsController controller,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final hasBackup = await controller.hasBackupFile();
    if (!context.mounted) {
      return;
    }

    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                title: Text(l10n.settingsBackupActionSheetTitle),
                enabled: false,
              ),
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: Text(l10n.settingsBackupExport),
                onTap: () => Navigator.of(sheetContext).pop('export'),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: Text(l10n.settingsBackupImportLatest),
                subtitle: hasBackup ? null : Text(l10n.settingsBackupNoFile),
                enabled: hasBackup,
                onTap: () => Navigator.of(sheetContext).pop('import'),
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted || action == null) {
      return;
    }

    try {
      if (action == 'export') {
        final path = await controller.exportBackup();
        if (context.mounted) {
          _showMessage(context, l10n.settingsBackupExportSuccess(path));
        }
        return;
      }

      final restoredPath = await controller.importLatestBackup();
      if (!context.mounted) {
        return;
      }
      if (restoredPath == null) {
        _showMessage(context, l10n.settingsBackupNoFile);
      } else {
        _showMessage(context, l10n.settingsBackupImportSuccess(restoredPath));
      }
    } catch (error) {
      if (context.mounted) {
        _showMessage(
          context,
          l10n.settingsBackupOperationFailed(error.toString()),
        );
      }
    }
  }
}
