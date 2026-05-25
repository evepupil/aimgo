import 'dart:convert';
import 'dart:io';

import 'package:aimgo/core/services/database/app_database.dart';
import 'package:aimgo/core/services/local_storage_service.dart';
import 'package:aimgo/features/settings/data/local_backup_service.dart';
import 'package:aimgo/shared/models/planning_models.dart';
import 'package:aimgo/shared/repositories/drift_aimgo_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;
  late DriftAimGoRepository repository;
  late LocalBackupService service;
  late Directory tempDirectory;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    database = AppDatabase(executor: NativeDatabase.memory());
    repository = DriftAimGoRepository(database);
    service = LocalBackupService(database: database, storage: storage);
    tempDirectory = await Directory.systemTemp.createTemp('aimgo_backup_test_');
  });

  tearDown(() async {
    await database.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'restoreFromFile replaces existing rows before inserting backup ids',
    () async {
      await _seedExistingData(repository);
      final backupFile = await _writeBackupFile(
        tempDirectory,
        goalTitle: 'Restored goal',
        milestoneTitle: 'Restored milestone',
        taskTitle: 'Restored task',
      );

      await service.restoreFromFile(backupFile.path);

      final goals = await database.select(database.goals).get();
      final milestones = await database.select(database.milestones).get();
      final tasks = await database.select(database.tasks).get();
      final focusSessions = await database.select(database.focusSessions).get();

      expect(goals, hasLength(1));
      expect(goals.single.id, 1);
      expect(goals.single.title, 'Restored goal');
      expect(milestones, hasLength(1));
      expect(milestones.single.id, 1);
      expect(milestones.single.title, 'Restored milestone');
      expect(tasks, hasLength(1));
      expect(tasks.single.id, 1);
      expect(tasks.single.title, 'Restored task');
      expect(focusSessions, hasLength(1));
      expect(focusSessions.single.id, 1);
      expect(focusSessions.single.taskId, 1);
    },
  );
}

Future<void> _seedExistingData(DriftAimGoRepository repository) async {
  final goal = await repository.createGoal(
    const CreateGoalInput(title: 'Existing goal'),
  );
  final milestone = await repository.createMilestone(
    CreateMilestoneInput(goalId: goal.id, title: 'Existing milestone'),
  );
  final task = await repository.createTask(
    CreateTaskInput(
      milestoneId: milestone.id,
      title: 'Existing task',
      estimateMinutes: 30,
    ),
  );
  await repository.createFocusSession(
    CreateFocusSessionInput(
      goalId: goal.id,
      milestoneId: milestone.id,
      taskId: task.id,
      durationMinutes: 25,
      efficiencyPercent: 80,
      focusTargetLevel: FocusTargetLevel.task,
      startedAt: DateTime(2026, 3, 5, 10),
      endedAt: DateTime(2026, 3, 5, 10, 25),
    ),
  );
}

Future<File> _writeBackupFile(
  Directory directory, {
  required String goalTitle,
  required String milestoneTitle,
  required String taskTitle,
}) async {
  final now = DateTime(2026, 3, 6, 12).toIso8601String();
  final file = File('${directory.path}/aimgo_backup_test.json');
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': 1,
      'exportedAt': now,
      'settings': {
        'themePreference': 'system',
        'localePreference': 'system',
        'notificationEnabled': true,
        'soundEnabled': true,
        'autoOpenEvaluationEnabled': true,
      },
      'goals': [
        {
          'id': 1,
          'title': goalTitle,
          'description': null,
          'estimateMinutes': 0,
          'effectiveMinutes': 0.0,
          'progressRatio': 0.0,
          'isCompleted': false,
          'sortOrder': 0,
          'colorHex': null,
          'dueAt': null,
          'createdAt': now,
          'updatedAt': now,
        },
      ],
      'milestones': [
        {
          'id': 1,
          'goalId': 1,
          'title': milestoneTitle,
          'description': null,
          'estimateMinutes': 0,
          'effectiveMinutes': 0.0,
          'progressRatio': 0.0,
          'isCompleted': false,
          'sortOrder': 0,
          'dueAt': null,
          'createdAt': now,
          'updatedAt': now,
          'completedAt': null,
        },
      ],
      'tasks': [
        {
          'id': 1,
          'milestoneId': 1,
          'title': taskTitle,
          'description': null,
          'estimateMinutes': 30,
          'effectiveMinutes': 0.0,
          'progressRatio': 0.0,
          'isCompleted': false,
          'sortOrder': 0,
          'dueAt': null,
          'createdAt': now,
          'updatedAt': now,
        },
      ],
      'focusSessions': [
        {
          'id': 1,
          'goalId': 1,
          'milestoneId': 1,
          'taskId': 1,
          'focusTargetLevel': 'task',
          'focusMode': 'pomodoro',
          'durationMinutes': 25,
          'efficiencyPercent': 80,
          'effectiveMinutes': 20.0,
          'startedAt': DateTime(2026, 3, 6, 10).toIso8601String(),
          'endedAt': DateTime(2026, 3, 6, 10, 25).toIso8601String(),
          'isAbandoned': false,
          'note': null,
          'createdAt': now,
        },
      ],
    }),
    flush: true,
  );
  return file;
}
