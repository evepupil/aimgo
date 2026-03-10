// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimateMinutesMeta = const VerificationMeta(
    'estimateMinutes',
  );
  @override
  late final GeneratedColumn<int> estimateMinutes = GeneratedColumn<int>(
    'estimate_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _effectiveMinutesMeta = const VerificationMeta(
    'effectiveMinutes',
  );
  @override
  late final GeneratedColumn<double> effectiveMinutes = GeneratedColumn<double>(
    'effective_minutes',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressRatioMeta = const VerificationMeta(
    'progressRatio',
  );
  @override
  late final GeneratedColumn<double> progressRatio = GeneratedColumn<double>(
    'progress_ratio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    estimateMinutes,
    effectiveMinutes,
    progressRatio,
    isCompleted,
    sortOrder,
    colorHex,
    dueAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('estimate_minutes')) {
      context.handle(
        _estimateMinutesMeta,
        estimateMinutes.isAcceptableOrUnknown(
          data['estimate_minutes']!,
          _estimateMinutesMeta,
        ),
      );
    }
    if (data.containsKey('effective_minutes')) {
      context.handle(
        _effectiveMinutesMeta,
        effectiveMinutes.isAcceptableOrUnknown(
          data['effective_minutes']!,
          _effectiveMinutesMeta,
        ),
      );
    }
    if (data.containsKey('progress_ratio')) {
      context.handle(
        _progressRatioMeta,
        progressRatio.isAcceptableOrUnknown(
          data['progress_ratio']!,
          _progressRatioMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      estimateMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}estimate_minutes'],
          )!,
      effectiveMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}effective_minutes'],
          )!,
      progressRatio:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}progress_ratio'],
          )!,
      isCompleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_completed'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      ),
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final String title;
  final String? description;
  final int estimateMinutes;
  final double effectiveMinutes;
  final double progressRatio;
  final bool isCompleted;
  final int sortOrder;
  final String? colorHex;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Goal({
    required this.id,
    required this.title,
    this.description,
    required this.estimateMinutes,
    required this.effectiveMinutes,
    required this.progressRatio,
    required this.isCompleted,
    required this.sortOrder,
    this.colorHex,
    this.dueAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['estimate_minutes'] = Variable<int>(estimateMinutes);
    map['effective_minutes'] = Variable<double>(effectiveMinutes);
    map['progress_ratio'] = Variable<double>(progressRatio);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      title: Value(title),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      estimateMinutes: Value(estimateMinutes),
      effectiveMinutes: Value(effectiveMinutes),
      progressRatio: Value(progressRatio),
      isCompleted: Value(isCompleted),
      sortOrder: Value(sortOrder),
      colorHex:
          colorHex == null && nullToAbsent
              ? const Value.absent()
              : Value(colorHex),
      dueAt:
          dueAt == null && nullToAbsent ? const Value.absent() : Value(dueAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      estimateMinutes: serializer.fromJson<int>(json['estimateMinutes']),
      effectiveMinutes: serializer.fromJson<double>(json['effectiveMinutes']),
      progressRatio: serializer.fromJson<double>(json['progressRatio']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'estimateMinutes': serializer.toJson<int>(estimateMinutes),
      'effectiveMinutes': serializer.toJson<double>(effectiveMinutes),
      'progressRatio': serializer.toJson<double>(progressRatio),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'colorHex': serializer.toJson<String?>(colorHex),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Goal copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    int? estimateMinutes,
    double? effectiveMinutes,
    double? progressRatio,
    bool? isCompleted,
    int? sortOrder,
    Value<String?> colorHex = const Value.absent(),
    Value<DateTime?> dueAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Goal(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    estimateMinutes: estimateMinutes ?? this.estimateMinutes,
    effectiveMinutes: effectiveMinutes ?? this.effectiveMinutes,
    progressRatio: progressRatio ?? this.progressRatio,
    isCompleted: isCompleted ?? this.isCompleted,
    sortOrder: sortOrder ?? this.sortOrder,
    colorHex: colorHex.present ? colorHex.value : this.colorHex,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      estimateMinutes:
          data.estimateMinutes.present
              ? data.estimateMinutes.value
              : this.estimateMinutes,
      effectiveMinutes:
          data.effectiveMinutes.present
              ? data.effectiveMinutes.value
              : this.effectiveMinutes,
      progressRatio:
          data.progressRatio.present
              ? data.progressRatio.value
              : this.progressRatio,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('estimateMinutes: $estimateMinutes, ')
          ..write('effectiveMinutes: $effectiveMinutes, ')
          ..write('progressRatio: $progressRatio, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('colorHex: $colorHex, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    estimateMinutes,
    effectiveMinutes,
    progressRatio,
    isCompleted,
    sortOrder,
    colorHex,
    dueAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.estimateMinutes == this.estimateMinutes &&
          other.effectiveMinutes == this.effectiveMinutes &&
          other.progressRatio == this.progressRatio &&
          other.isCompleted == this.isCompleted &&
          other.sortOrder == this.sortOrder &&
          other.colorHex == this.colorHex &&
          other.dueAt == this.dueAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> estimateMinutes;
  final Value<double> effectiveMinutes;
  final Value<double> progressRatio;
  final Value<bool> isCompleted;
  final Value<int> sortOrder;
  final Value<String?> colorHex;
  final Value<DateTime?> dueAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.estimateMinutes = const Value.absent(),
    this.effectiveMinutes = const Value.absent(),
    this.progressRatio = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.estimateMinutes = const Value.absent(),
    this.effectiveMinutes = const Value.absent(),
    this.progressRatio = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? estimateMinutes,
    Expression<double>? effectiveMinutes,
    Expression<double>? progressRatio,
    Expression<bool>? isCompleted,
    Expression<int>? sortOrder,
    Expression<String>? colorHex,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (estimateMinutes != null) 'estimate_minutes': estimateMinutes,
      if (effectiveMinutes != null) 'effective_minutes': effectiveMinutes,
      if (progressRatio != null) 'progress_ratio': progressRatio,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (colorHex != null) 'color_hex': colorHex,
      if (dueAt != null) 'due_at': dueAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? estimateMinutes,
    Value<double>? effectiveMinutes,
    Value<double>? progressRatio,
    Value<bool>? isCompleted,
    Value<int>? sortOrder,
    Value<String?>? colorHex,
    Value<DateTime?>? dueAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      effectiveMinutes: effectiveMinutes ?? this.effectiveMinutes,
      progressRatio: progressRatio ?? this.progressRatio,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
      colorHex: colorHex ?? this.colorHex,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (estimateMinutes.present) {
      map['estimate_minutes'] = Variable<int>(estimateMinutes.value);
    }
    if (effectiveMinutes.present) {
      map['effective_minutes'] = Variable<double>(effectiveMinutes.value);
    }
    if (progressRatio.present) {
      map['progress_ratio'] = Variable<double>(progressRatio.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('estimateMinutes: $estimateMinutes, ')
          ..write('effectiveMinutes: $effectiveMinutes, ')
          ..write('progressRatio: $progressRatio, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('colorHex: $colorHex, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MilestonesTable extends Milestones
    with TableInfo<$MilestonesTable, Milestone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimateMinutesMeta = const VerificationMeta(
    'estimateMinutes',
  );
  @override
  late final GeneratedColumn<int> estimateMinutes = GeneratedColumn<int>(
    'estimate_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _effectiveMinutesMeta = const VerificationMeta(
    'effectiveMinutes',
  );
  @override
  late final GeneratedColumn<double> effectiveMinutes = GeneratedColumn<double>(
    'effective_minutes',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressRatioMeta = const VerificationMeta(
    'progressRatio',
  );
  @override
  late final GeneratedColumn<double> progressRatio = GeneratedColumn<double>(
    'progress_ratio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goalId,
    title,
    description,
    estimateMinutes,
    effectiveMinutes,
    progressRatio,
    isCompleted,
    sortOrder,
    dueAt,
    createdAt,
    updatedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milestones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Milestone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('estimate_minutes')) {
      context.handle(
        _estimateMinutesMeta,
        estimateMinutes.isAcceptableOrUnknown(
          data['estimate_minutes']!,
          _estimateMinutesMeta,
        ),
      );
    }
    if (data.containsKey('effective_minutes')) {
      context.handle(
        _effectiveMinutesMeta,
        effectiveMinutes.isAcceptableOrUnknown(
          data['effective_minutes']!,
          _effectiveMinutesMeta,
        ),
      );
    }
    if (data.containsKey('progress_ratio')) {
      context.handle(
        _progressRatioMeta,
        progressRatio.isAcceptableOrUnknown(
          data['progress_ratio']!,
          _progressRatioMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Milestone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Milestone(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      goalId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}goal_id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      estimateMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}estimate_minutes'],
          )!,
      effectiveMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}effective_minutes'],
          )!,
      progressRatio:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}progress_ratio'],
          )!,
      isCompleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_completed'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $MilestonesTable createAlias(String alias) {
    return $MilestonesTable(attachedDatabase, alias);
  }
}

class Milestone extends DataClass implements Insertable<Milestone> {
  final int id;
  final int goalId;
  final String title;
  final String? description;
  final int estimateMinutes;
  final double effectiveMinutes;
  final double progressRatio;
  final bool isCompleted;
  final int sortOrder;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  const Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    this.description,
    required this.estimateMinutes,
    required this.effectiveMinutes,
    required this.progressRatio,
    required this.isCompleted,
    required this.sortOrder,
    this.dueAt,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal_id'] = Variable<int>(goalId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['estimate_minutes'] = Variable<int>(estimateMinutes);
    map['effective_minutes'] = Variable<double>(effectiveMinutes);
    map['progress_ratio'] = Variable<double>(progressRatio);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  MilestonesCompanion toCompanion(bool nullToAbsent) {
    return MilestonesCompanion(
      id: Value(id),
      goalId: Value(goalId),
      title: Value(title),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      estimateMinutes: Value(estimateMinutes),
      effectiveMinutes: Value(effectiveMinutes),
      progressRatio: Value(progressRatio),
      isCompleted: Value(isCompleted),
      sortOrder: Value(sortOrder),
      dueAt:
          dueAt == null && nullToAbsent ? const Value.absent() : Value(dueAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt:
          completedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(completedAt),
    );
  }

  factory Milestone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Milestone(
      id: serializer.fromJson<int>(json['id']),
      goalId: serializer.fromJson<int>(json['goalId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      estimateMinutes: serializer.fromJson<int>(json['estimateMinutes']),
      effectiveMinutes: serializer.fromJson<double>(json['effectiveMinutes']),
      progressRatio: serializer.fromJson<double>(json['progressRatio']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalId': serializer.toJson<int>(goalId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'estimateMinutes': serializer.toJson<int>(estimateMinutes),
      'effectiveMinutes': serializer.toJson<double>(effectiveMinutes),
      'progressRatio': serializer.toJson<double>(progressRatio),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  Milestone copyWith({
    int? id,
    int? goalId,
    String? title,
    Value<String?> description = const Value.absent(),
    int? estimateMinutes,
    double? effectiveMinutes,
    double? progressRatio,
    bool? isCompleted,
    int? sortOrder,
    Value<DateTime?> dueAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => Milestone(
    id: id ?? this.id,
    goalId: goalId ?? this.goalId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    estimateMinutes: estimateMinutes ?? this.estimateMinutes,
    effectiveMinutes: effectiveMinutes ?? this.effectiveMinutes,
    progressRatio: progressRatio ?? this.progressRatio,
    isCompleted: isCompleted ?? this.isCompleted,
    sortOrder: sortOrder ?? this.sortOrder,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  Milestone copyWithCompanion(MilestonesCompanion data) {
    return Milestone(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      estimateMinutes:
          data.estimateMinutes.present
              ? data.estimateMinutes.value
              : this.estimateMinutes,
      effectiveMinutes:
          data.effectiveMinutes.present
              ? data.effectiveMinutes.value
              : this.effectiveMinutes,
      progressRatio:
          data.progressRatio.present
              ? data.progressRatio.value
              : this.progressRatio,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Milestone(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('estimateMinutes: $estimateMinutes, ')
          ..write('effectiveMinutes: $effectiveMinutes, ')
          ..write('progressRatio: $progressRatio, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    goalId,
    title,
    description,
    estimateMinutes,
    effectiveMinutes,
    progressRatio,
    isCompleted,
    sortOrder,
    dueAt,
    createdAt,
    updatedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Milestone &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.title == this.title &&
          other.description == this.description &&
          other.estimateMinutes == this.estimateMinutes &&
          other.effectiveMinutes == this.effectiveMinutes &&
          other.progressRatio == this.progressRatio &&
          other.isCompleted == this.isCompleted &&
          other.sortOrder == this.sortOrder &&
          other.dueAt == this.dueAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt);
}

class MilestonesCompanion extends UpdateCompanion<Milestone> {
  final Value<int> id;
  final Value<int> goalId;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> estimateMinutes;
  final Value<double> effectiveMinutes;
  final Value<double> progressRatio;
  final Value<bool> isCompleted;
  final Value<int> sortOrder;
  final Value<DateTime?> dueAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  const MilestonesCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.estimateMinutes = const Value.absent(),
    this.effectiveMinutes = const Value.absent(),
    this.progressRatio = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  MilestonesCompanion.insert({
    this.id = const Value.absent(),
    required int goalId,
    required String title,
    this.description = const Value.absent(),
    this.estimateMinutes = const Value.absent(),
    this.effectiveMinutes = const Value.absent(),
    this.progressRatio = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : goalId = Value(goalId),
       title = Value(title);
  static Insertable<Milestone> custom({
    Expression<int>? id,
    Expression<int>? goalId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? estimateMinutes,
    Expression<double>? effectiveMinutes,
    Expression<double>? progressRatio,
    Expression<bool>? isCompleted,
    Expression<int>? sortOrder,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (estimateMinutes != null) 'estimate_minutes': estimateMinutes,
      if (effectiveMinutes != null) 'effective_minutes': effectiveMinutes,
      if (progressRatio != null) 'progress_ratio': progressRatio,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (dueAt != null) 'due_at': dueAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  MilestonesCompanion copyWith({
    Value<int>? id,
    Value<int>? goalId,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? estimateMinutes,
    Value<double>? effectiveMinutes,
    Value<double>? progressRatio,
    Value<bool>? isCompleted,
    Value<int>? sortOrder,
    Value<DateTime?>? dueAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? completedAt,
  }) {
    return MilestonesCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      effectiveMinutes: effectiveMinutes ?? this.effectiveMinutes,
      progressRatio: progressRatio ?? this.progressRatio,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (estimateMinutes.present) {
      map['estimate_minutes'] = Variable<int>(estimateMinutes.value);
    }
    if (effectiveMinutes.present) {
      map['effective_minutes'] = Variable<double>(effectiveMinutes.value);
    }
    if (progressRatio.present) {
      map['progress_ratio'] = Variable<double>(progressRatio.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilestonesCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('estimateMinutes: $estimateMinutes, ')
          ..write('effectiveMinutes: $effectiveMinutes, ')
          ..write('progressRatio: $progressRatio, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _milestoneIdMeta = const VerificationMeta(
    'milestoneId',
  );
  @override
  late final GeneratedColumn<int> milestoneId = GeneratedColumn<int>(
    'milestone_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES milestones (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimateMinutesMeta = const VerificationMeta(
    'estimateMinutes',
  );
  @override
  late final GeneratedColumn<int> estimateMinutes = GeneratedColumn<int>(
    'estimate_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _effectiveMinutesMeta = const VerificationMeta(
    'effectiveMinutes',
  );
  @override
  late final GeneratedColumn<double> effectiveMinutes = GeneratedColumn<double>(
    'effective_minutes',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressRatioMeta = const VerificationMeta(
    'progressRatio',
  );
  @override
  late final GeneratedColumn<double> progressRatio = GeneratedColumn<double>(
    'progress_ratio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    milestoneId,
    title,
    description,
    estimateMinutes,
    effectiveMinutes,
    progressRatio,
    isCompleted,
    sortOrder,
    dueAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('milestone_id')) {
      context.handle(
        _milestoneIdMeta,
        milestoneId.isAcceptableOrUnknown(
          data['milestone_id']!,
          _milestoneIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_milestoneIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('estimate_minutes')) {
      context.handle(
        _estimateMinutesMeta,
        estimateMinutes.isAcceptableOrUnknown(
          data['estimate_minutes']!,
          _estimateMinutesMeta,
        ),
      );
    }
    if (data.containsKey('effective_minutes')) {
      context.handle(
        _effectiveMinutesMeta,
        effectiveMinutes.isAcceptableOrUnknown(
          data['effective_minutes']!,
          _effectiveMinutesMeta,
        ),
      );
    }
    if (data.containsKey('progress_ratio')) {
      context.handle(
        _progressRatioMeta,
        progressRatio.isAcceptableOrUnknown(
          data['progress_ratio']!,
          _progressRatioMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      milestoneId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}milestone_id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      estimateMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}estimate_minutes'],
          )!,
      effectiveMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}effective_minutes'],
          )!,
      progressRatio:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}progress_ratio'],
          )!,
      isCompleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_completed'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final int milestoneId;
  final String title;
  final String? description;
  final int estimateMinutes;
  final double effectiveMinutes;
  final double progressRatio;
  final bool isCompleted;
  final int sortOrder;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Task({
    required this.id,
    required this.milestoneId,
    required this.title,
    this.description,
    required this.estimateMinutes,
    required this.effectiveMinutes,
    required this.progressRatio,
    required this.isCompleted,
    required this.sortOrder,
    this.dueAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['milestone_id'] = Variable<int>(milestoneId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['estimate_minutes'] = Variable<int>(estimateMinutes);
    map['effective_minutes'] = Variable<double>(effectiveMinutes);
    map['progress_ratio'] = Variable<double>(progressRatio);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      milestoneId: Value(milestoneId),
      title: Value(title),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      estimateMinutes: Value(estimateMinutes),
      effectiveMinutes: Value(effectiveMinutes),
      progressRatio: Value(progressRatio),
      isCompleted: Value(isCompleted),
      sortOrder: Value(sortOrder),
      dueAt:
          dueAt == null && nullToAbsent ? const Value.absent() : Value(dueAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      milestoneId: serializer.fromJson<int>(json['milestoneId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      estimateMinutes: serializer.fromJson<int>(json['estimateMinutes']),
      effectiveMinutes: serializer.fromJson<double>(json['effectiveMinutes']),
      progressRatio: serializer.fromJson<double>(json['progressRatio']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'milestoneId': serializer.toJson<int>(milestoneId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'estimateMinutes': serializer.toJson<int>(estimateMinutes),
      'effectiveMinutes': serializer.toJson<double>(effectiveMinutes),
      'progressRatio': serializer.toJson<double>(progressRatio),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Task copyWith({
    int? id,
    int? milestoneId,
    String? title,
    Value<String?> description = const Value.absent(),
    int? estimateMinutes,
    double? effectiveMinutes,
    double? progressRatio,
    bool? isCompleted,
    int? sortOrder,
    Value<DateTime?> dueAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Task(
    id: id ?? this.id,
    milestoneId: milestoneId ?? this.milestoneId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    estimateMinutes: estimateMinutes ?? this.estimateMinutes,
    effectiveMinutes: effectiveMinutes ?? this.effectiveMinutes,
    progressRatio: progressRatio ?? this.progressRatio,
    isCompleted: isCompleted ?? this.isCompleted,
    sortOrder: sortOrder ?? this.sortOrder,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      milestoneId:
          data.milestoneId.present ? data.milestoneId.value : this.milestoneId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      estimateMinutes:
          data.estimateMinutes.present
              ? data.estimateMinutes.value
              : this.estimateMinutes,
      effectiveMinutes:
          data.effectiveMinutes.present
              ? data.effectiveMinutes.value
              : this.effectiveMinutes,
      progressRatio:
          data.progressRatio.present
              ? data.progressRatio.value
              : this.progressRatio,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('milestoneId: $milestoneId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('estimateMinutes: $estimateMinutes, ')
          ..write('effectiveMinutes: $effectiveMinutes, ')
          ..write('progressRatio: $progressRatio, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    milestoneId,
    title,
    description,
    estimateMinutes,
    effectiveMinutes,
    progressRatio,
    isCompleted,
    sortOrder,
    dueAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.milestoneId == this.milestoneId &&
          other.title == this.title &&
          other.description == this.description &&
          other.estimateMinutes == this.estimateMinutes &&
          other.effectiveMinutes == this.effectiveMinutes &&
          other.progressRatio == this.progressRatio &&
          other.isCompleted == this.isCompleted &&
          other.sortOrder == this.sortOrder &&
          other.dueAt == this.dueAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<int> milestoneId;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> estimateMinutes;
  final Value<double> effectiveMinutes;
  final Value<double> progressRatio;
  final Value<bool> isCompleted;
  final Value<int> sortOrder;
  final Value<DateTime?> dueAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.milestoneId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.estimateMinutes = const Value.absent(),
    this.effectiveMinutes = const Value.absent(),
    this.progressRatio = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required int milestoneId,
    required String title,
    this.description = const Value.absent(),
    this.estimateMinutes = const Value.absent(),
    this.effectiveMinutes = const Value.absent(),
    this.progressRatio = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : milestoneId = Value(milestoneId),
       title = Value(title);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<int>? milestoneId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? estimateMinutes,
    Expression<double>? effectiveMinutes,
    Expression<double>? progressRatio,
    Expression<bool>? isCompleted,
    Expression<int>? sortOrder,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (milestoneId != null) 'milestone_id': milestoneId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (estimateMinutes != null) 'estimate_minutes': estimateMinutes,
      if (effectiveMinutes != null) 'effective_minutes': effectiveMinutes,
      if (progressRatio != null) 'progress_ratio': progressRatio,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (dueAt != null) 'due_at': dueAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<int>? milestoneId,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? estimateMinutes,
    Value<double>? effectiveMinutes,
    Value<double>? progressRatio,
    Value<bool>? isCompleted,
    Value<int>? sortOrder,
    Value<DateTime?>? dueAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      milestoneId: milestoneId ?? this.milestoneId,
      title: title ?? this.title,
      description: description ?? this.description,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      effectiveMinutes: effectiveMinutes ?? this.effectiveMinutes,
      progressRatio: progressRatio ?? this.progressRatio,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (milestoneId.present) {
      map['milestone_id'] = Variable<int>(milestoneId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (estimateMinutes.present) {
      map['estimate_minutes'] = Variable<int>(estimateMinutes.value);
    }
    if (effectiveMinutes.present) {
      map['effective_minutes'] = Variable<double>(effectiveMinutes.value);
    }
    if (progressRatio.present) {
      map['progress_ratio'] = Variable<double>(progressRatio.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('milestoneId: $milestoneId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('estimateMinutes: $estimateMinutes, ')
          ..write('effectiveMinutes: $effectiveMinutes, ')
          ..write('progressRatio: $progressRatio, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _milestoneIdMeta = const VerificationMeta(
    'milestoneId',
  );
  @override
  late final GeneratedColumn<int> milestoneId = GeneratedColumn<int>(
    'milestone_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES milestones (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _focusTargetLevelMeta = const VerificationMeta(
    'focusTargetLevel',
  );
  @override
  late final GeneratedColumn<String> focusTargetLevel = GeneratedColumn<String>(
    'focus_target_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _focusModeMeta = const VerificationMeta(
    'focusMode',
  );
  @override
  late final GeneratedColumn<String> focusMode = GeneratedColumn<String>(
    'focus_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pomodoro'),
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _efficiencyPercentMeta = const VerificationMeta(
    'efficiencyPercent',
  );
  @override
  late final GeneratedColumn<int> efficiencyPercent = GeneratedColumn<int>(
    'efficiency_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _effectiveMinutesMeta = const VerificationMeta(
    'effectiveMinutes',
  );
  @override
  late final GeneratedColumn<double> effectiveMinutes = GeneratedColumn<double>(
    'effective_minutes',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAbandonedMeta = const VerificationMeta(
    'isAbandoned',
  );
  @override
  late final GeneratedColumn<bool> isAbandoned = GeneratedColumn<bool>(
    'is_abandoned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_abandoned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goalId,
    milestoneId,
    taskId,
    focusTargetLevel,
    focusMode,
    durationMinutes,
    efficiencyPercent,
    effectiveMinutes,
    startedAt,
    endedAt,
    isAbandoned,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    }
    if (data.containsKey('milestone_id')) {
      context.handle(
        _milestoneIdMeta,
        milestoneId.isAcceptableOrUnknown(
          data['milestone_id']!,
          _milestoneIdMeta,
        ),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('focus_target_level')) {
      context.handle(
        _focusTargetLevelMeta,
        focusTargetLevel.isAcceptableOrUnknown(
          data['focus_target_level']!,
          _focusTargetLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_focusTargetLevelMeta);
    }
    if (data.containsKey('focus_mode')) {
      context.handle(
        _focusModeMeta,
        focusMode.isAcceptableOrUnknown(data['focus_mode']!, _focusModeMeta),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('efficiency_percent')) {
      context.handle(
        _efficiencyPercentMeta,
        efficiencyPercent.isAcceptableOrUnknown(
          data['efficiency_percent']!,
          _efficiencyPercentMeta,
        ),
      );
    }
    if (data.containsKey('effective_minutes')) {
      context.handle(
        _effectiveMinutesMeta,
        effectiveMinutes.isAcceptableOrUnknown(
          data['effective_minutes']!,
          _effectiveMinutesMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('is_abandoned')) {
      context.handle(
        _isAbandonedMeta,
        isAbandoned.isAcceptableOrUnknown(
          data['is_abandoned']!,
          _isAbandonedMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSession(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_id'],
      ),
      milestoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}milestone_id'],
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      ),
      focusTargetLevel:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}focus_target_level'],
          )!,
      focusMode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}focus_mode'],
          )!,
      durationMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}duration_minutes'],
          )!,
      efficiencyPercent:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}efficiency_percent'],
          )!,
      effectiveMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}effective_minutes'],
          )!,
      startedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}started_at'],
          )!,
      endedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}ended_at'],
          )!,
      isAbandoned:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_abandoned'],
          )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }
}

class FocusSession extends DataClass implements Insertable<FocusSession> {
  final int id;
  final int? goalId;
  final int? milestoneId;
  final int? taskId;
  final String focusTargetLevel;
  final String focusMode;
  final int durationMinutes;
  final int efficiencyPercent;
  final double effectiveMinutes;
  final DateTime startedAt;
  final DateTime endedAt;
  final bool isAbandoned;
  final String? note;
  final DateTime createdAt;
  const FocusSession({
    required this.id,
    this.goalId,
    this.milestoneId,
    this.taskId,
    required this.focusTargetLevel,
    required this.focusMode,
    required this.durationMinutes,
    required this.efficiencyPercent,
    required this.effectiveMinutes,
    required this.startedAt,
    required this.endedAt,
    required this.isAbandoned,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || goalId != null) {
      map['goal_id'] = Variable<int>(goalId);
    }
    if (!nullToAbsent || milestoneId != null) {
      map['milestone_id'] = Variable<int>(milestoneId);
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    map['focus_target_level'] = Variable<String>(focusTargetLevel);
    map['focus_mode'] = Variable<String>(focusMode);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['efficiency_percent'] = Variable<int>(efficiencyPercent);
    map['effective_minutes'] = Variable<double>(effectiveMinutes);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['is_abandoned'] = Variable<bool>(isAbandoned);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      goalId:
          goalId == null && nullToAbsent ? const Value.absent() : Value(goalId),
      milestoneId:
          milestoneId == null && nullToAbsent
              ? const Value.absent()
              : Value(milestoneId),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      focusTargetLevel: Value(focusTargetLevel),
      focusMode: Value(focusMode),
      durationMinutes: Value(durationMinutes),
      efficiencyPercent: Value(efficiencyPercent),
      effectiveMinutes: Value(effectiveMinutes),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      isAbandoned: Value(isAbandoned),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory FocusSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSession(
      id: serializer.fromJson<int>(json['id']),
      goalId: serializer.fromJson<int?>(json['goalId']),
      milestoneId: serializer.fromJson<int?>(json['milestoneId']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      focusTargetLevel: serializer.fromJson<String>(json['focusTargetLevel']),
      focusMode: serializer.fromJson<String>(json['focusMode']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      efficiencyPercent: serializer.fromJson<int>(json['efficiencyPercent']),
      effectiveMinutes: serializer.fromJson<double>(json['effectiveMinutes']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      isAbandoned: serializer.fromJson<bool>(json['isAbandoned']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalId': serializer.toJson<int?>(goalId),
      'milestoneId': serializer.toJson<int?>(milestoneId),
      'taskId': serializer.toJson<int?>(taskId),
      'focusTargetLevel': serializer.toJson<String>(focusTargetLevel),
      'focusMode': serializer.toJson<String>(focusMode),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'efficiencyPercent': serializer.toJson<int>(efficiencyPercent),
      'effectiveMinutes': serializer.toJson<double>(effectiveMinutes),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'isAbandoned': serializer.toJson<bool>(isAbandoned),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FocusSession copyWith({
    int? id,
    Value<int?> goalId = const Value.absent(),
    Value<int?> milestoneId = const Value.absent(),
    Value<int?> taskId = const Value.absent(),
    String? focusTargetLevel,
    String? focusMode,
    int? durationMinutes,
    int? efficiencyPercent,
    double? effectiveMinutes,
    DateTime? startedAt,
    DateTime? endedAt,
    bool? isAbandoned,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => FocusSession(
    id: id ?? this.id,
    goalId: goalId.present ? goalId.value : this.goalId,
    milestoneId: milestoneId.present ? milestoneId.value : this.milestoneId,
    taskId: taskId.present ? taskId.value : this.taskId,
    focusTargetLevel: focusTargetLevel ?? this.focusTargetLevel,
    focusMode: focusMode ?? this.focusMode,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    efficiencyPercent: efficiencyPercent ?? this.efficiencyPercent,
    effectiveMinutes: effectiveMinutes ?? this.effectiveMinutes,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    isAbandoned: isAbandoned ?? this.isAbandoned,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  FocusSession copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSession(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      milestoneId:
          data.milestoneId.present ? data.milestoneId.value : this.milestoneId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      focusTargetLevel:
          data.focusTargetLevel.present
              ? data.focusTargetLevel.value
              : this.focusTargetLevel,
      focusMode: data.focusMode.present ? data.focusMode.value : this.focusMode,
      durationMinutes:
          data.durationMinutes.present
              ? data.durationMinutes.value
              : this.durationMinutes,
      efficiencyPercent:
          data.efficiencyPercent.present
              ? data.efficiencyPercent.value
              : this.efficiencyPercent,
      effectiveMinutes:
          data.effectiveMinutes.present
              ? data.effectiveMinutes.value
              : this.effectiveMinutes,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      isAbandoned:
          data.isAbandoned.present ? data.isAbandoned.value : this.isAbandoned,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSession(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('milestoneId: $milestoneId, ')
          ..write('taskId: $taskId, ')
          ..write('focusTargetLevel: $focusTargetLevel, ')
          ..write('focusMode: $focusMode, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('efficiencyPercent: $efficiencyPercent, ')
          ..write('effectiveMinutes: $effectiveMinutes, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('isAbandoned: $isAbandoned, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    goalId,
    milestoneId,
    taskId,
    focusTargetLevel,
    focusMode,
    durationMinutes,
    efficiencyPercent,
    effectiveMinutes,
    startedAt,
    endedAt,
    isAbandoned,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSession &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.milestoneId == this.milestoneId &&
          other.taskId == this.taskId &&
          other.focusTargetLevel == this.focusTargetLevel &&
          other.focusMode == this.focusMode &&
          other.durationMinutes == this.durationMinutes &&
          other.efficiencyPercent == this.efficiencyPercent &&
          other.effectiveMinutes == this.effectiveMinutes &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.isAbandoned == this.isAbandoned &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSession> {
  final Value<int> id;
  final Value<int?> goalId;
  final Value<int?> milestoneId;
  final Value<int?> taskId;
  final Value<String> focusTargetLevel;
  final Value<String> focusMode;
  final Value<int> durationMinutes;
  final Value<int> efficiencyPercent;
  final Value<double> effectiveMinutes;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<bool> isAbandoned;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.milestoneId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.focusTargetLevel = const Value.absent(),
    this.focusMode = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.efficiencyPercent = const Value.absent(),
    this.effectiveMinutes = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.isAbandoned = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.milestoneId = const Value.absent(),
    this.taskId = const Value.absent(),
    required String focusTargetLevel,
    this.focusMode = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.efficiencyPercent = const Value.absent(),
    this.effectiveMinutes = const Value.absent(),
    required DateTime startedAt,
    required DateTime endedAt,
    this.isAbandoned = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : focusTargetLevel = Value(focusTargetLevel),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt);
  static Insertable<FocusSession> custom({
    Expression<int>? id,
    Expression<int>? goalId,
    Expression<int>? milestoneId,
    Expression<int>? taskId,
    Expression<String>? focusTargetLevel,
    Expression<String>? focusMode,
    Expression<int>? durationMinutes,
    Expression<int>? efficiencyPercent,
    Expression<double>? effectiveMinutes,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<bool>? isAbandoned,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (milestoneId != null) 'milestone_id': milestoneId,
      if (taskId != null) 'task_id': taskId,
      if (focusTargetLevel != null) 'focus_target_level': focusTargetLevel,
      if (focusMode != null) 'focus_mode': focusMode,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (efficiencyPercent != null) 'efficiency_percent': efficiencyPercent,
      if (effectiveMinutes != null) 'effective_minutes': effectiveMinutes,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (isAbandoned != null) 'is_abandoned': isAbandoned,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? goalId,
    Value<int?>? milestoneId,
    Value<int?>? taskId,
    Value<String>? focusTargetLevel,
    Value<String>? focusMode,
    Value<int>? durationMinutes,
    Value<int>? efficiencyPercent,
    Value<double>? effectiveMinutes,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<bool>? isAbandoned,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      milestoneId: milestoneId ?? this.milestoneId,
      taskId: taskId ?? this.taskId,
      focusTargetLevel: focusTargetLevel ?? this.focusTargetLevel,
      focusMode: focusMode ?? this.focusMode,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      efficiencyPercent: efficiencyPercent ?? this.efficiencyPercent,
      effectiveMinutes: effectiveMinutes ?? this.effectiveMinutes,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      isAbandoned: isAbandoned ?? this.isAbandoned,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (milestoneId.present) {
      map['milestone_id'] = Variable<int>(milestoneId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (focusTargetLevel.present) {
      map['focus_target_level'] = Variable<String>(focusTargetLevel.value);
    }
    if (focusMode.present) {
      map['focus_mode'] = Variable<String>(focusMode.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (efficiencyPercent.present) {
      map['efficiency_percent'] = Variable<int>(efficiencyPercent.value);
    }
    if (effectiveMinutes.present) {
      map['effective_minutes'] = Variable<double>(effectiveMinutes.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (isAbandoned.present) {
      map['is_abandoned'] = Variable<bool>(isAbandoned.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('milestoneId: $milestoneId, ')
          ..write('taskId: $taskId, ')
          ..write('focusTargetLevel: $focusTargetLevel, ')
          ..write('focusMode: $focusMode, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('efficiencyPercent: $efficiencyPercent, ')
          ..write('effectiveMinutes: $effectiveMinutes, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('isAbandoned: $isAbandoned, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $MilestonesTable milestones = $MilestonesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    goals,
    milestones,
    tasks,
    focusSessions,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'goals',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('milestones', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'milestones',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'goals',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('focus_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'milestones',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('focus_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('focus_sessions', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      Value<int> estimateMinutes,
      Value<double> effectiveMinutes,
      Value<double> progressRatio,
      Value<bool> isCompleted,
      Value<int> sortOrder,
      Value<String?> colorHex,
      Value<DateTime?> dueAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<int> estimateMinutes,
      Value<double> effectiveMinutes,
      Value<double> progressRatio,
      Value<bool> isCompleted,
      Value<int> sortOrder,
      Value<String?> colorHex,
      Value<DateTime?> dueAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$GoalsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalsTable, Goal> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MilestonesTable, List<Milestone>>
  _milestonesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.milestones,
    aliasName: $_aliasNameGenerator(db.goals.id, db.milestones.goalId),
  );

  $$MilestonesTableProcessedTableManager get milestonesRefs {
    final manager = $$MilestonesTableTableManager(
      $_db,
      $_db.milestones,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_milestonesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSession>>
  _focusSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusSessions,
    aliasName: $_aliasNameGenerator(db.goals.id, db.focusSessions.goalId),
  );

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimateMinutes => $composableBuilder(
    column: $table.estimateMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get effectiveMinutes => $composableBuilder(
    column: $table.effectiveMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progressRatio => $composableBuilder(
    column: $table.progressRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> milestonesRefs(
    Expression<bool> Function($$MilestonesTableFilterComposer f) f,
  ) {
    final $$MilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableFilterComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> focusSessionsRefs(
    Expression<bool> Function($$FocusSessionsTableFilterComposer f) f,
  ) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimateMinutes => $composableBuilder(
    column: $table.estimateMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get effectiveMinutes => $composableBuilder(
    column: $table.effectiveMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progressRatio => $composableBuilder(
    column: $table.progressRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimateMinutes => $composableBuilder(
    column: $table.estimateMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get effectiveMinutes => $composableBuilder(
    column: $table.effectiveMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get progressRatio => $composableBuilder(
    column: $table.progressRatio,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> milestonesRefs<T extends Object>(
    Expression<T> Function($$MilestonesTableAnnotationComposer a) f,
  ) {
    final $$MilestonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableAnnotationComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, $$GoalsTableReferences),
          Goal,
          PrefetchHooks Function({bool milestonesRefs, bool focusSessionsRefs})
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> estimateMinutes = const Value.absent(),
                Value<double> effectiveMinutes = const Value.absent(),
                Value<double> progressRatio = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                title: title,
                description: description,
                estimateMinutes: estimateMinutes,
                effectiveMinutes: effectiveMinutes,
                progressRatio: progressRatio,
                isCompleted: isCompleted,
                sortOrder: sortOrder,
                colorHex: colorHex,
                dueAt: dueAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<int> estimateMinutes = const Value.absent(),
                Value<double> effectiveMinutes = const Value.absent(),
                Value<double> progressRatio = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                title: title,
                description: description,
                estimateMinutes: estimateMinutes,
                effectiveMinutes: effectiveMinutes,
                progressRatio: progressRatio,
                isCompleted: isCompleted,
                sortOrder: sortOrder,
                colorHex: colorHex,
                dueAt: dueAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$GoalsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            milestonesRefs = false,
            focusSessionsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (milestonesRefs) db.milestones,
                if (focusSessionsRefs) db.focusSessions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (milestonesRefs)
                    await $_getPrefetchedData<Goal, $GoalsTable, Milestone>(
                      currentTable: table,
                      referencedTable: $$GoalsTableReferences
                          ._milestonesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$GoalsTableReferences(
                                db,
                                table,
                                p0,
                              ).milestonesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.goalId == item.id),
                      typedResults: items,
                    ),
                  if (focusSessionsRefs)
                    await $_getPrefetchedData<Goal, $GoalsTable, FocusSession>(
                      currentTable: table,
                      referencedTable: $$GoalsTableReferences
                          ._focusSessionsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$GoalsTableReferences(
                                db,
                                table,
                                p0,
                              ).focusSessionsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.goalId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, $$GoalsTableReferences),
      Goal,
      PrefetchHooks Function({bool milestonesRefs, bool focusSessionsRefs})
    >;
typedef $$MilestonesTableCreateCompanionBuilder =
    MilestonesCompanion Function({
      Value<int> id,
      required int goalId,
      required String title,
      Value<String?> description,
      Value<int> estimateMinutes,
      Value<double> effectiveMinutes,
      Value<double> progressRatio,
      Value<bool> isCompleted,
      Value<int> sortOrder,
      Value<DateTime?> dueAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
    });
typedef $$MilestonesTableUpdateCompanionBuilder =
    MilestonesCompanion Function({
      Value<int> id,
      Value<int> goalId,
      Value<String> title,
      Value<String?> description,
      Value<int> estimateMinutes,
      Value<double> effectiveMinutes,
      Value<double> progressRatio,
      Value<bool> isCompleted,
      Value<int> sortOrder,
      Value<DateTime?> dueAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
    });

final class $$MilestonesTableReferences
    extends BaseReferences<_$AppDatabase, $MilestonesTable, Milestone> {
  $$MilestonesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GoalsTable _goalIdTable(_$AppDatabase db) => db.goals.createAlias(
    $_aliasNameGenerator(db.milestones.goalId, db.goals.id),
  );

  $$GoalsTableProcessedTableManager get goalId {
    final $_column = $_itemColumn<int>('goal_id')!;

    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: $_aliasNameGenerator(db.milestones.id, db.tasks.milestoneId),
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.milestoneId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSession>>
  _focusSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusSessions,
    aliasName: $_aliasNameGenerator(
      db.milestones.id,
      db.focusSessions.milestoneId,
    ),
  );

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.milestoneId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MilestonesTableFilterComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimateMinutes => $composableBuilder(
    column: $table.estimateMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get effectiveMinutes => $composableBuilder(
    column: $table.effectiveMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progressRatio => $composableBuilder(
    column: $table.progressRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.milestoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> focusSessionsRefs(
    Expression<bool> Function($$FocusSessionsTableFilterComposer f) f,
  ) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.milestoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MilestonesTableOrderingComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimateMinutes => $composableBuilder(
    column: $table.estimateMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get effectiveMinutes => $composableBuilder(
    column: $table.effectiveMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progressRatio => $composableBuilder(
    column: $table.progressRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimateMinutes => $composableBuilder(
    column: $table.estimateMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get effectiveMinutes => $composableBuilder(
    column: $table.effectiveMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get progressRatio => $composableBuilder(
    column: $table.progressRatio,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.milestoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.milestoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MilestonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MilestonesTable,
          Milestone,
          $$MilestonesTableFilterComposer,
          $$MilestonesTableOrderingComposer,
          $$MilestonesTableAnnotationComposer,
          $$MilestonesTableCreateCompanionBuilder,
          $$MilestonesTableUpdateCompanionBuilder,
          (Milestone, $$MilestonesTableReferences),
          Milestone,
          PrefetchHooks Function({
            bool goalId,
            bool tasksRefs,
            bool focusSessionsRefs,
          })
        > {
  $$MilestonesTableTableManager(_$AppDatabase db, $MilestonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MilestonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MilestonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MilestonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> goalId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> estimateMinutes = const Value.absent(),
                Value<double> effectiveMinutes = const Value.absent(),
                Value<double> progressRatio = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => MilestonesCompanion(
                id: id,
                goalId: goalId,
                title: title,
                description: description,
                estimateMinutes: estimateMinutes,
                effectiveMinutes: effectiveMinutes,
                progressRatio: progressRatio,
                isCompleted: isCompleted,
                sortOrder: sortOrder,
                dueAt: dueAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int goalId,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<int> estimateMinutes = const Value.absent(),
                Value<double> effectiveMinutes = const Value.absent(),
                Value<double> progressRatio = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => MilestonesCompanion.insert(
                id: id,
                goalId: goalId,
                title: title,
                description: description,
                estimateMinutes: estimateMinutes,
                effectiveMinutes: effectiveMinutes,
                progressRatio: progressRatio,
                isCompleted: isCompleted,
                sortOrder: sortOrder,
                dueAt: dueAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$MilestonesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            goalId = false,
            tasksRefs = false,
            focusSessionsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tasksRefs) db.tasks,
                if (focusSessionsRefs) db.focusSessions,
              ],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (goalId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.goalId,
                            referencedTable: $$MilestonesTableReferences
                                ._goalIdTable(db),
                            referencedColumn:
                                $$MilestonesTableReferences._goalIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<
                      Milestone,
                      $MilestonesTable,
                      Task
                    >(
                      currentTable: table,
                      referencedTable: $$MilestonesTableReferences
                          ._tasksRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$MilestonesTableReferences(
                                db,
                                table,
                                p0,
                              ).tasksRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.milestoneId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (focusSessionsRefs)
                    await $_getPrefetchedData<
                      Milestone,
                      $MilestonesTable,
                      FocusSession
                    >(
                      currentTable: table,
                      referencedTable: $$MilestonesTableReferences
                          ._focusSessionsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$MilestonesTableReferences(
                                db,
                                table,
                                p0,
                              ).focusSessionsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.milestoneId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MilestonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MilestonesTable,
      Milestone,
      $$MilestonesTableFilterComposer,
      $$MilestonesTableOrderingComposer,
      $$MilestonesTableAnnotationComposer,
      $$MilestonesTableCreateCompanionBuilder,
      $$MilestonesTableUpdateCompanionBuilder,
      (Milestone, $$MilestonesTableReferences),
      Milestone,
      PrefetchHooks Function({
        bool goalId,
        bool tasksRefs,
        bool focusSessionsRefs,
      })
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required int milestoneId,
      required String title,
      Value<String?> description,
      Value<int> estimateMinutes,
      Value<double> effectiveMinutes,
      Value<double> progressRatio,
      Value<bool> isCompleted,
      Value<int> sortOrder,
      Value<DateTime?> dueAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<int> milestoneId,
      Value<String> title,
      Value<String?> description,
      Value<int> estimateMinutes,
      Value<double> effectiveMinutes,
      Value<double> progressRatio,
      Value<bool> isCompleted,
      Value<int> sortOrder,
      Value<DateTime?> dueAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MilestonesTable _milestoneIdTable(_$AppDatabase db) =>
      db.milestones.createAlias(
        $_aliasNameGenerator(db.tasks.milestoneId, db.milestones.id),
      );

  $$MilestonesTableProcessedTableManager get milestoneId {
    final $_column = $_itemColumn<int>('milestone_id')!;

    final manager = $$MilestonesTableTableManager(
      $_db,
      $_db.milestones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_milestoneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSession>>
  _focusSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusSessions,
    aliasName: $_aliasNameGenerator(db.tasks.id, db.focusSessions.taskId),
  );

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimateMinutes => $composableBuilder(
    column: $table.estimateMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get effectiveMinutes => $composableBuilder(
    column: $table.effectiveMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progressRatio => $composableBuilder(
    column: $table.progressRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MilestonesTableFilterComposer get milestoneId {
    final $$MilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableFilterComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> focusSessionsRefs(
    Expression<bool> Function($$FocusSessionsTableFilterComposer f) f,
  ) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimateMinutes => $composableBuilder(
    column: $table.estimateMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get effectiveMinutes => $composableBuilder(
    column: $table.effectiveMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progressRatio => $composableBuilder(
    column: $table.progressRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MilestonesTableOrderingComposer get milestoneId {
    final $$MilestonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableOrderingComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimateMinutes => $composableBuilder(
    column: $table.estimateMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get effectiveMinutes => $composableBuilder(
    column: $table.effectiveMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get progressRatio => $composableBuilder(
    column: $table.progressRatio,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MilestonesTableAnnotationComposer get milestoneId {
    final $$MilestonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableAnnotationComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool milestoneId, bool focusSessionsRefs})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> milestoneId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> estimateMinutes = const Value.absent(),
                Value<double> effectiveMinutes = const Value.absent(),
                Value<double> progressRatio = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                milestoneId: milestoneId,
                title: title,
                description: description,
                estimateMinutes: estimateMinutes,
                effectiveMinutes: effectiveMinutes,
                progressRatio: progressRatio,
                isCompleted: isCompleted,
                sortOrder: sortOrder,
                dueAt: dueAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int milestoneId,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<int> estimateMinutes = const Value.absent(),
                Value<double> effectiveMinutes = const Value.absent(),
                Value<double> progressRatio = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                milestoneId: milestoneId,
                title: title,
                description: description,
                estimateMinutes: estimateMinutes,
                effectiveMinutes: effectiveMinutes,
                progressRatio: progressRatio,
                isCompleted: isCompleted,
                sortOrder: sortOrder,
                dueAt: dueAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$TasksTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            milestoneId = false,
            focusSessionsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (focusSessionsRefs) db.focusSessions,
              ],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (milestoneId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.milestoneId,
                            referencedTable: $$TasksTableReferences
                                ._milestoneIdTable(db),
                            referencedColumn:
                                $$TasksTableReferences._milestoneIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (focusSessionsRefs)
                    await $_getPrefetchedData<Task, $TasksTable, FocusSession>(
                      currentTable: table,
                      referencedTable: $$TasksTableReferences
                          ._focusSessionsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).focusSessionsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.taskId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool milestoneId, bool focusSessionsRefs})
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      Value<int?> goalId,
      Value<int?> milestoneId,
      Value<int?> taskId,
      required String focusTargetLevel,
      Value<String> focusMode,
      Value<int> durationMinutes,
      Value<int> efficiencyPercent,
      Value<double> effectiveMinutes,
      required DateTime startedAt,
      required DateTime endedAt,
      Value<bool> isAbandoned,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      Value<int?> goalId,
      Value<int?> milestoneId,
      Value<int?> taskId,
      Value<String> focusTargetLevel,
      Value<String> focusMode,
      Value<int> durationMinutes,
      Value<int> efficiencyPercent,
      Value<double> effectiveMinutes,
      Value<DateTime> startedAt,
      Value<DateTime> endedAt,
      Value<bool> isAbandoned,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$FocusSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSession> {
  $$FocusSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GoalsTable _goalIdTable(_$AppDatabase db) => db.goals.createAlias(
    $_aliasNameGenerator(db.focusSessions.goalId, db.goals.id),
  );

  $$GoalsTableProcessedTableManager? get goalId {
    final $_column = $_itemColumn<int>('goal_id');
    if ($_column == null) return null;
    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MilestonesTable _milestoneIdTable(_$AppDatabase db) =>
      db.milestones.createAlias(
        $_aliasNameGenerator(db.focusSessions.milestoneId, db.milestones.id),
      );

  $$MilestonesTableProcessedTableManager? get milestoneId {
    final $_column = $_itemColumn<int>('milestone_id');
    if ($_column == null) return null;
    final manager = $$MilestonesTableTableManager(
      $_db,
      $_db.milestones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_milestoneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks.createAlias(
    $_aliasNameGenerator(db.focusSessions.taskId, db.tasks.id),
  );

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<int>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FocusSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focusTargetLevel => $composableBuilder(
    column: $table.focusTargetLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focusMode => $composableBuilder(
    column: $table.focusMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get efficiencyPercent => $composableBuilder(
    column: $table.efficiencyPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get effectiveMinutes => $composableBuilder(
    column: $table.effectiveMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAbandoned => $composableBuilder(
    column: $table.isAbandoned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MilestonesTableFilterComposer get milestoneId {
    final $$MilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableFilterComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focusTargetLevel => $composableBuilder(
    column: $table.focusTargetLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focusMode => $composableBuilder(
    column: $table.focusMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get efficiencyPercent => $composableBuilder(
    column: $table.efficiencyPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get effectiveMinutes => $composableBuilder(
    column: $table.effectiveMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAbandoned => $composableBuilder(
    column: $table.isAbandoned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MilestonesTableOrderingComposer get milestoneId {
    final $$MilestonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableOrderingComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get focusTargetLevel => $composableBuilder(
    column: $table.focusTargetLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get focusMode =>
      $composableBuilder(column: $table.focusMode, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get efficiencyPercent => $composableBuilder(
    column: $table.efficiencyPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get effectiveMinutes => $composableBuilder(
    column: $table.effectiveMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<bool> get isAbandoned => $composableBuilder(
    column: $table.isAbandoned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MilestonesTableAnnotationComposer get milestoneId {
    final $$MilestonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableAnnotationComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusSessionsTable,
          FocusSession,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (FocusSession, $$FocusSessionsTableReferences),
          FocusSession,
          PrefetchHooks Function({bool goalId, bool milestoneId, bool taskId})
        > {
  $$FocusSessionsTableTableManager(_$AppDatabase db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$FocusSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> goalId = const Value.absent(),
                Value<int?> milestoneId = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<String> focusTargetLevel = const Value.absent(),
                Value<String> focusMode = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> efficiencyPercent = const Value.absent(),
                Value<double> effectiveMinutes = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<bool> isAbandoned = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                goalId: goalId,
                milestoneId: milestoneId,
                taskId: taskId,
                focusTargetLevel: focusTargetLevel,
                focusMode: focusMode,
                durationMinutes: durationMinutes,
                efficiencyPercent: efficiencyPercent,
                effectiveMinutes: effectiveMinutes,
                startedAt: startedAt,
                endedAt: endedAt,
                isAbandoned: isAbandoned,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> goalId = const Value.absent(),
                Value<int?> milestoneId = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                required String focusTargetLevel,
                Value<String> focusMode = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> efficiencyPercent = const Value.absent(),
                Value<double> effectiveMinutes = const Value.absent(),
                required DateTime startedAt,
                required DateTime endedAt,
                Value<bool> isAbandoned = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                id: id,
                goalId: goalId,
                milestoneId: milestoneId,
                taskId: taskId,
                focusTargetLevel: focusTargetLevel,
                focusMode: focusMode,
                durationMinutes: durationMinutes,
                efficiencyPercent: efficiencyPercent,
                effectiveMinutes: effectiveMinutes,
                startedAt: startedAt,
                endedAt: endedAt,
                isAbandoned: isAbandoned,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$FocusSessionsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            goalId = false,
            milestoneId = false,
            taskId = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (goalId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.goalId,
                            referencedTable: $$FocusSessionsTableReferences
                                ._goalIdTable(db),
                            referencedColumn:
                                $$FocusSessionsTableReferences
                                    ._goalIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (milestoneId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.milestoneId,
                            referencedTable: $$FocusSessionsTableReferences
                                ._milestoneIdTable(db),
                            referencedColumn:
                                $$FocusSessionsTableReferences
                                    ._milestoneIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (taskId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.taskId,
                            referencedTable: $$FocusSessionsTableReferences
                                ._taskIdTable(db),
                            referencedColumn:
                                $$FocusSessionsTableReferences
                                    ._taskIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusSessionsTable,
      FocusSession,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (FocusSession, $$FocusSessionsTableReferences),
      FocusSession,
      PrefetchHooks Function({bool goalId, bool milestoneId, bool taskId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$MilestonesTableTableManager get milestones =>
      $$MilestonesTableTableManager(_db, _db.milestones);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
}
