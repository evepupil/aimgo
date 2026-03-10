import 'dart:convert';
import 'dart:io';

import 'package:aimgo/core/services/database/app_database.dart';
import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final localBackupServiceProvider = Provider<LocalBackupService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return LocalBackupService(database: database, storage: storage);
});

final class LocalBackupService {
  LocalBackupService({
    required AppDatabase database,
    required LocalStorageService storage,
  }) : _database = database,
       _storage = storage;

  static const _schemaVersion = 1;
  static const _backupDirectoryName = 'backups';

  final AppDatabase _database;
  final LocalStorageService _storage;

  Future<String> exportBackup() async {
    final goals = await _database.select(_database.goals).get();
    final milestones = await _database.select(_database.milestones).get();
    final tasks = await _database.select(_database.tasks).get();
    final focusSessions = await _database.select(_database.focusSessions).get();

    final payload = <String, Object?>{
      'schemaVersion': _schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': <String, Object?>{
        'themePreference': _storage.getThemePreference(),
        'localePreference': _storage.getLocalePreference(),
        'notificationEnabled': _storage.getNotificationEnabled(),
        'soundEnabled': _storage.getSoundEnabled(),
      },
      'goals': goals.map((item) => item.toJson()).toList(growable: false),
      'milestones': milestones
          .map((item) => item.toJson())
          .toList(growable: false),
      'tasks': tasks.map((item) => item.toJson()).toList(growable: false),
      'focusSessions': focusSessions
          .map((item) => item.toJson())
          .toList(growable: false),
    };

    final backupDirectory = await _ensureBackupDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final file = File(
      p.join(backupDirectory.path, 'aimgo_backup_$timestamp.json'),
    );
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );
    return file.path;
  }

  Future<String?> restoreLatestBackup() async {
    final file = await _findLatestBackupFile();
    if (file == null) {
      return null;
    }

    final content = await file.readAsString();
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup payload.');
    }

    final schemaVersion = decoded['schemaVersion'];
    if (schemaVersion != _schemaVersion) {
      throw const FormatException('Unsupported backup schema version.');
    }

    final goals = _decodeRows<Goal>(decoded['goals'], Goal.fromJson);
    final milestones = _decodeRows<Milestone>(
      decoded['milestones'],
      Milestone.fromJson,
    );
    final tasks = _decodeRows<Task>(decoded['tasks'], Task.fromJson);
    final focusSessions = _decodeFocusSessions(decoded['focusSessions']);

    await _database.transaction(() async {
      await _database.delete(_database.focusSessions).go();
      await _database.delete(_database.goals).go();

      if (goals.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAll(
            _database.goals,
            goals.map((row) => row.toCompanion(true)).toList(growable: false),
          );
        });
      }

      if (milestones.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAll(
            _database.milestones,
            milestones
                .map((row) => row.toCompanion(true))
                .toList(growable: false),
          );
        });
      }

      if (tasks.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAll(
            _database.tasks,
            tasks.map((row) => row.toCompanion(true)).toList(growable: false),
          );
        });
      }

      if (focusSessions.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAll(
            _database.focusSessions,
            focusSessions
                .map((row) => row.toCompanion(true))
                .toList(growable: false),
          );
        });
      }
    });

    final settings = decoded['settings'];
    if (settings is Map<String, dynamic>) {
      await _restoreSettings(settings);
    }

    return file.path;
  }

  Future<bool> hasBackupFile() async {
    final file = await _findLatestBackupFile();
    return file != null;
  }

  Future<void> _restoreSettings(Map<String, dynamic> settings) async {
    final themePreference = settings['themePreference'];
    final localePreference = settings['localePreference'];
    final notificationEnabled = settings['notificationEnabled'];
    final soundEnabled = settings['soundEnabled'];

    if (themePreference is String && themePreference.isNotEmpty) {
      await _storage.setThemePreference(themePreference);
    }
    if (localePreference is String && localePreference.isNotEmpty) {
      await _storage.setLocalePreference(localePreference);
    }
    if (notificationEnabled is bool) {
      await _storage.setNotificationEnabled(notificationEnabled);
    }
    if (soundEnabled is bool) {
      await _storage.setSoundEnabled(soundEnabled);
    }
  }

  List<T> _decodeRows<T>(
    Object? rawValue,
    T Function(Map<String, dynamic> map) decode,
  ) {
    if (rawValue is! List) {
      throw const FormatException('Invalid backup data section.');
    }
    return rawValue
        .map((item) {
          if (item is! Map) {
            throw const FormatException('Invalid backup row.');
          }
          return decode(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }

  List<FocusSession> _decodeFocusSessions(Object? rawValue) {
    if (rawValue is! List) {
      throw const FormatException('Invalid backup data section.');
    }
    return rawValue
        .map((item) {
          if (item is! Map) {
            throw const FormatException('Invalid backup row.');
          }
          final map = Map<String, dynamic>.from(item);
          map.putIfAbsent('focusMode', () => 'pomodoro');
          return FocusSession.fromJson(map);
        })
        .toList(growable: false);
  }

  Future<Directory> _ensureBackupDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final backupDirectory = Directory(
      p.join(documentsDirectory.path, _backupDirectoryName),
    );
    if (!await backupDirectory.exists()) {
      await backupDirectory.create(recursive: true);
    }
    return backupDirectory;
  }

  Future<File?> _findLatestBackupFile() async {
    final backupDirectory = await _ensureBackupDirectory();
    final entries = backupDirectory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList(growable: false);
    if (entries.isEmpty) {
      return null;
    }
    entries.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );
    return entries.first;
  }
}
