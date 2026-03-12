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
              child: _SettingsCard(
                children: [
                  _SettingsNavRow(
                    icon: Icons.language_outlined,
                    title: l10n.settingsLanguage,
                    value: _localeLabel(l10n, localePreference),
                    onTap:
                        () => _showLocalePicker(
                          context: context,
                          ref: ref,
                          current: localePreference,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: LayoutTokens.sectionGapLarge),
            _SettingsSection(
              title: l10n.settingsTheme,
              child: _SettingsCard(
                children: [
                  _SettingsNavRow(
                    icon: Icons.palette_outlined,
                    title: l10n.settingsTheme,
                    value: _themeLabel(l10n, themePreference),
                    onTap:
                        () => _showThemePicker(
                          context: context,
                          ref: ref,
                          current: themePreference,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: LayoutTokens.sectionGapLarge),
            _SettingsSection(
              title: l10n.settingsOtherSection,
              child: _SettingsCard(
                children: [
                  _SettingsSwitchRow(
                    icon: Icons.notifications_outlined,
                    title: l10n.settingsNotification,
                    value: settingsState.notificationsEnabled,
                    onChanged: settingsController.setNotificationEnabled,
                  ),
                  _SettingsSwitchRow(
                    icon: Icons.volume_up_outlined,
                    title: l10n.settingsSound,
                    value: settingsState.soundEnabled,
                    onChanged: settingsController.setSoundEnabled,
                  ),
                  _SettingsSwitchRow(
                    icon: Icons.rate_review_outlined,
                    title: l10n.settingsAutoOpenEvaluation,
                    value: settingsState.autoOpenEvaluationEnabled,
                    onChanged: settingsController.setAutoOpenEvaluationEnabled,
                  ),
                  _SettingsNavRow(
                    icon: Icons.backup_outlined,
                    title: l10n.settingsBackupRestore,
                    onTap:
                        () => _onTapBackupRestore(
                          context: context,
                          ref: ref,
                          controller: settingsController,
                        ),
                  ),
                  _SettingsNavRow(
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
          ],
        ),
      ),
    );
  }

  String _localeLabel(AppLocalizations l10n, AppLocalePreference pref) {
    return switch (pref) {
      AppLocalePreference.system => l10n.langSystem,
      AppLocalePreference.zh => l10n.langZh,
      AppLocalePreference.en => l10n.langEn,
    };
  }

  String _themeLabel(AppLocalizations l10n, AppThemePreference pref) {
    return switch (pref) {
      AppThemePreference.system => l10n.themeSystem,
      AppThemePreference.light => l10n.themeLight,
      AppThemePreference.dark => l10n.themeDark,
    };
  }

  void _showLocalePicker({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalePreference current,
  }) {
    final l10n = AppLocalizations.of(context)!;
    _showOptionSheet<AppLocalePreference>(
      context: context,
      title: l10n.settingsLanguage,
      options: AppLocalePreference.values,
      current: current,
      labelBuilder:
          (option) => switch (option) {
            AppLocalePreference.system => l10n.langSystem,
            AppLocalePreference.zh => l10n.langZh,
            AppLocalePreference.en => l10n.langEn,
          },
      onSelect: (option) {
        ref.read(localeControllerProvider.notifier).setPreference(option);
      },
    );
  }

  void _showThemePicker({
    required BuildContext context,
    required WidgetRef ref,
    required AppThemePreference current,
  }) {
    final l10n = AppLocalizations.of(context)!;
    _showOptionSheet<AppThemePreference>(
      context: context,
      title: l10n.settingsTheme,
      options: AppThemePreference.values,
      current: current,
      labelBuilder:
          (option) => switch (option) {
            AppThemePreference.system => l10n.themeSystem,
            AppThemePreference.light => l10n.themeLight,
            AppThemePreference.dark => l10n.themeDark,
          },
      onSelect: (option) {
        ref.read(themeModeControllerProvider.notifier).setPreference(option);
      },
    );
  }

  void _showOptionSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> options,
    required T current,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onSelect,
  }) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(title, style: theme.textTheme.titleSmall),
                  ),
                ),
                for (final option in options)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(labelBuilder(option)),
                    trailing:
                        option == current
                            ? Icon(
                              Icons.check,
                              color: theme.colorScheme.primary,
                              size: 20,
                            )
                            : null,
                    onTap: () {
                      onSelect(option);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.settingsBackupActionSheetTitle,
                      style: Theme.of(sheetContext).textTheme.titleSmall,
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: const Icon(Icons.upload_file_outlined, size: 22),
                  title: Text(l10n.settingsBackupExport),
                  onTap: () => Navigator.of(sheetContext).pop('export'),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: const Icon(Icons.download_outlined, size: 22),
                  title: Text(l10n.settingsBackupImportLatest),
                  subtitle: hasBackup ? null : Text(l10n.settingsBackupNoFile),
                  enabled: hasBackup,
                  onTap: () => Navigator.of(sheetContext).pop('import'),
                ),
              ],
            ),
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

// ---------------------------------------------------------------------------
// Section title
// ---------------------------------------------------------------------------

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
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// White card group (like Tain's grouped list)
// ---------------------------------------------------------------------------

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.28),
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nav row: icon + label + value text + chevron
// ---------------------------------------------------------------------------

class _SettingsNavRow extends StatelessWidget {
  const _SettingsNavRow({
    required this.icon,
    required this.title,
    this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(
                value!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Switch row: icon + label + switch (like Tain's toggle rows)
// ---------------------------------------------------------------------------

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
            SizedBox(
              width: 44,
              height: 24,
              child: Align(
                alignment: Alignment.centerRight,
                child: Transform.scale(
                  scale: 0.82,
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
