import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 200)();

  TextColumn get description => text().nullable()();

  IntColumn get estimateMinutes => integer().withDefault(const Constant(0))();

  RealColumn get effectiveMinutes => real().withDefault(const Constant(0))();

  RealColumn get progressRatio => real().withDefault(const Constant(0))();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  TextColumn get colorHex => text().nullable()();

  DateTimeColumn get dueAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Milestones extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get goalId =>
      integer().references(Goals, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text().withLength(min: 1, max: 200)();

  TextColumn get description => text().nullable()();

  IntColumn get estimateMinutes => integer().withDefault(const Constant(0))();

  RealColumn get effectiveMinutes => real().withDefault(const Constant(0))();

  RealColumn get progressRatio => real().withDefault(const Constant(0))();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get dueAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get milestoneId =>
      integer().references(Milestones, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text().withLength(min: 1, max: 200)();

  TextColumn get description => text().nullable()();

  IntColumn get estimateMinutes => integer().withDefault(const Constant(0))();

  RealColumn get effectiveMinutes => real().withDefault(const Constant(0))();

  RealColumn get progressRatio => real().withDefault(const Constant(0))();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get dueAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get goalId =>
      integer().nullable().references(
        Goals,
        #id,
        onDelete: KeyAction.setNull,
      )();

  IntColumn get milestoneId =>
      integer().nullable().references(
        Milestones,
        #id,
        onDelete: KeyAction.setNull,
      )();

  IntColumn get taskId =>
      integer().nullable().references(
        Tasks,
        #id,
        onDelete: KeyAction.setNull,
      )();

  TextColumn get focusTargetLevel => text()();

  IntColumn get durationMinutes => integer().withDefault(const Constant(0))();

  IntColumn get efficiencyPercent =>
      integer().withDefault(const Constant(60))();

  RealColumn get effectiveMinutes => real().withDefault(const Constant(0))();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get endedAt => dateTime()();

  BoolColumn get isAbandoned => boolean().withDefault(const Constant(false))();

  TextColumn get note => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

@DriftDatabase(tables: [Goals, Milestones, Tasks, FocusSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databaseFile = File(
      path.join(documentsDirectory.path, 'aimgo.sqlite'),
    );
    return NativeDatabase.createInBackground(databaseFile);
  });
}
