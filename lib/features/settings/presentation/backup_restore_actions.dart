import 'dart:io';

import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/features/settings/application/settings_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showBackupRestoreActions({
  required BuildContext context,
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
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: const Icon(Icons.folder_open_outlined, size: 22),
                title: Text(l10n.settingsBackupRestoreFromFile),
                subtitle: Text(l10n.settingsBackupRestoreFromFileHint),
                onTap: () => Navigator.of(sheetContext).pop('restore_file'),
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
      final sharePositionOrigin = _sharePositionOrigin(context);
      final file = await controller.exportBackup();
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'AimGo Backup',
        sharePositionOrigin: sharePositionOrigin,
      );
      if (context.mounted) {
        _showMessage(
          context,
          Platform.isIOS
              ? l10n.settingsBackupExportSuccess(file.path)
              : l10n.settingsBackupExportShareSuccess,
        );
      }
      return;
    }

    if (action == 'restore_file') {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      final path =
          result == null || result.files.isEmpty ? null : result.files.first.path;
      if (path == null || path.isEmpty) {
        return;
      }
      await controller.restoreFromFile(path);
      if (context.mounted) {
        _showMessage(context, l10n.settingsBackupImportSuccess(path));
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

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Rect? _sharePositionOrigin(BuildContext context) {
  final renderObject = context.findRenderObject();
  if (renderObject is! RenderBox) {
    return null;
  }
  return renderObject.localToGlobal(Offset.zero) & renderObject.size;
}
