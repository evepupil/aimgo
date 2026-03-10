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
            _SettingsSection(
              title: l10n.settingsLanguage,
              child: _SettingsSurface(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LayoutTokens.cardPadding,
                    vertical: 10,
                  ),
                  child: SingleChildScrollView(
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
                ),
              ),
            ),
            const SizedBox(height: LayoutTokens.sectionGapLarge),
            _SettingsSection(
              title: l10n.settingsTheme,
              child: _SettingsSurface(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LayoutTokens.cardPadding,
                    vertical: 10,
                  ),
                  child: SingleChildScrollView(
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
                ),
              ),
            ),
            const SizedBox(height: LayoutTokens.sectionGapLarge),
            _SettingsSection(
              title: l10n.settingsOtherSection,
              child: _SettingsSurface(
                child: Column(
                  children: [
                    _SettingsSwitchRow(
                      title: l10n.settingsNotification,
                      value: settingsState.notificationsEnabled,
                      onChanged: settingsController.setNotificationEnabled,
                    ),
                    _SettingsDivider(),
                    _SettingsSwitchRow(
                      title: l10n.settingsSound,
                      value: settingsState.soundEnabled,
                      onChanged: settingsController.setSoundEnabled,
                    ),
                    _SettingsDivider(),
                    _SettingsSwitchRow(
                      title: l10n.settingsAutoOpenEvaluation,
                      value: settingsState.autoOpenEvaluationEnabled,
                      onChanged:
                          settingsController.setAutoOpenEvaluationEnabled,
                    ),
                    _SettingsDivider(),
                    _SettingsActionRow(
                      icon: Icons.backup_outlined,
                      title: l10n.settingsBackupRestore,
                      subtitle: l10n.settingsBackupRestoreHint,
                      onTap:
                          () => _onTapBackupRestore(
                            context: context,
                            ref: ref,
                            controller: settingsController,
                          ),
                    ),
                    _SettingsDivider(),
                    _SettingsActionRow(
                      icon: Icons.cleaning_services_outlined,
                      title: l10n.settingsClearCache,
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.88),
            ),
          ),
        ),
        const SizedBox(height: LayoutTokens.compactGap),
        child,
      ],
    );
  }
}

class _SettingsSurface extends StatelessWidget {
  const _SettingsSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(LayoutTokens.radiusMedium),
      ),
      child: child,
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: LayoutTokens.cardPadding,
      endIndent: LayoutTokens.cardPadding,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.45),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.cardPadding,
        vertical: 2,
      ),
      title: Text(title),
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.cardPadding,
      ),
      leading: Icon(icon, size: 20),
      title: Text(title),
      subtitle:
          subtitle == null
              ? null
              : Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
