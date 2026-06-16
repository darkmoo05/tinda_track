// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin $SyncStateTableToColumns implements Insertable<SyncStateRow> {
  String get moduleKey;
  int get lastPulledAtMs;
  int get lastPushedAtMs;
  int get lastPushAttemptAtMs;
  String? get lastPushError;
  int get pendingPushCount;
  int get updatedAtMs;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['module_key'] = Variable<String>(moduleKey);
    map['last_pulled_at_ms'] = Variable<int>(lastPulledAtMs);
    map['last_pushed_at_ms'] = Variable<int>(lastPushedAtMs);
    map['last_push_attempt_at_ms'] = Variable<int>(lastPushAttemptAtMs);
    if (!nullToAbsent || lastPushError != null) {
      map['last_push_error'] = Variable<String>(lastPushError);
    }
    map['pending_push_count'] = Variable<int>(pendingPushCount);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _moduleKeyMeta = const VerificationMeta(
    'moduleKey',
  );
  @override
  late final GeneratedColumn<String> moduleKey = GeneratedColumn<String>(
    'module_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPulledAtMsMeta = const VerificationMeta(
    'lastPulledAtMs',
  );
  @override
  late final GeneratedColumn<int> lastPulledAtMs = GeneratedColumn<int>(
    'last_pulled_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPushedAtMsMeta = const VerificationMeta(
    'lastPushedAtMs',
  );
  @override
  late final GeneratedColumn<int> lastPushedAtMs = GeneratedColumn<int>(
    'last_pushed_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPushAttemptAtMsMeta =
      const VerificationMeta('lastPushAttemptAtMs');
  @override
  late final GeneratedColumn<int> lastPushAttemptAtMs = GeneratedColumn<int>(
    'last_push_attempt_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPushErrorMeta = const VerificationMeta(
    'lastPushError',
  );
  @override
  late final GeneratedColumn<String> lastPushError = GeneratedColumn<String>(
    'last_push_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingPushCountMeta = const VerificationMeta(
    'pendingPushCount',
  );
  @override
  late final GeneratedColumn<int> pendingPushCount = GeneratedColumn<int>(
    'pending_push_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    moduleKey,
    lastPulledAtMs,
    lastPushedAtMs,
    lastPushAttemptAtMs,
    lastPushError,
    pendingPushCount,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('module_key')) {
      context.handle(
        _moduleKeyMeta,
        moduleKey.isAcceptableOrUnknown(data['module_key']!, _moduleKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleKeyMeta);
    }
    if (data.containsKey('last_pulled_at_ms')) {
      context.handle(
        _lastPulledAtMsMeta,
        lastPulledAtMs.isAcceptableOrUnknown(
          data['last_pulled_at_ms']!,
          _lastPulledAtMsMeta,
        ),
      );
    }
    if (data.containsKey('last_pushed_at_ms')) {
      context.handle(
        _lastPushedAtMsMeta,
        lastPushedAtMs.isAcceptableOrUnknown(
          data['last_pushed_at_ms']!,
          _lastPushedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('last_push_attempt_at_ms')) {
      context.handle(
        _lastPushAttemptAtMsMeta,
        lastPushAttemptAtMs.isAcceptableOrUnknown(
          data['last_push_attempt_at_ms']!,
          _lastPushAttemptAtMsMeta,
        ),
      );
    }
    if (data.containsKey('last_push_error')) {
      context.handle(
        _lastPushErrorMeta,
        lastPushError.isAcceptableOrUnknown(
          data['last_push_error']!,
          _lastPushErrorMeta,
        ),
      );
    }
    if (data.containsKey('pending_push_count')) {
      context.handle(
        _pendingPushCountMeta,
        pendingPushCount.isAcceptableOrUnknown(
          data['pending_push_count']!,
          _pendingPushCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {moduleKey};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      moduleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_key'],
      )!,
      lastPulledAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_pulled_at_ms'],
      )!,
      lastPushedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_pushed_at_ms'],
      )!,
      lastPushAttemptAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_push_attempt_at_ms'],
      )!,
      lastPushError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_push_error'],
      ),
      pendingPushCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_push_count'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass with $SyncStateTableToColumns {
  @override
  final String moduleKey;
  @override
  final int lastPulledAtMs;
  @override
  final int lastPushedAtMs;
  @override
  final int lastPushAttemptAtMs;
  @override
  final String? lastPushError;
  @override
  final int pendingPushCount;
  @override
  final int updatedAtMs;
  const SyncStateRow({
    required this.moduleKey,
    required this.lastPulledAtMs,
    required this.lastPushedAtMs,
    required this.lastPushAttemptAtMs,
    this.lastPushError,
    required this.pendingPushCount,
    required this.updatedAtMs,
  });
  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      moduleKey: Value(moduleKey),
      lastPulledAtMs: Value(lastPulledAtMs),
      lastPushedAtMs: Value(lastPushedAtMs),
      lastPushAttemptAtMs: Value(lastPushAttemptAtMs),
      lastPushError: lastPushError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushError),
      pendingPushCount: Value(pendingPushCount),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      moduleKey: serializer.fromJson<String>(json['moduleKey']),
      lastPulledAtMs: serializer.fromJson<int>(json['lastPulledAtMs']),
      lastPushedAtMs: serializer.fromJson<int>(json['lastPushedAtMs']),
      lastPushAttemptAtMs: serializer.fromJson<int>(
        json['lastPushAttemptAtMs'],
      ),
      lastPushError: serializer.fromJson<String?>(json['lastPushError']),
      pendingPushCount: serializer.fromJson<int>(json['pendingPushCount']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'moduleKey': serializer.toJson<String>(moduleKey),
      'lastPulledAtMs': serializer.toJson<int>(lastPulledAtMs),
      'lastPushedAtMs': serializer.toJson<int>(lastPushedAtMs),
      'lastPushAttemptAtMs': serializer.toJson<int>(lastPushAttemptAtMs),
      'lastPushError': serializer.toJson<String?>(lastPushError),
      'pendingPushCount': serializer.toJson<int>(pendingPushCount),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  SyncStateRow copyWith({
    String? moduleKey,
    int? lastPulledAtMs,
    int? lastPushedAtMs,
    int? lastPushAttemptAtMs,
    Value<String?> lastPushError = const Value.absent(),
    int? pendingPushCount,
    int? updatedAtMs,
  }) => SyncStateRow(
    moduleKey: moduleKey ?? this.moduleKey,
    lastPulledAtMs: lastPulledAtMs ?? this.lastPulledAtMs,
    lastPushedAtMs: lastPushedAtMs ?? this.lastPushedAtMs,
    lastPushAttemptAtMs: lastPushAttemptAtMs ?? this.lastPushAttemptAtMs,
    lastPushError: lastPushError.present
        ? lastPushError.value
        : this.lastPushError,
    pendingPushCount: pendingPushCount ?? this.pendingPushCount,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  SyncStateRow copyWithCompanion(SyncStateCompanion data) {
    return SyncStateRow(
      moduleKey: data.moduleKey.present ? data.moduleKey.value : this.moduleKey,
      lastPulledAtMs: data.lastPulledAtMs.present
          ? data.lastPulledAtMs.value
          : this.lastPulledAtMs,
      lastPushedAtMs: data.lastPushedAtMs.present
          ? data.lastPushedAtMs.value
          : this.lastPushedAtMs,
      lastPushAttemptAtMs: data.lastPushAttemptAtMs.present
          ? data.lastPushAttemptAtMs.value
          : this.lastPushAttemptAtMs,
      lastPushError: data.lastPushError.present
          ? data.lastPushError.value
          : this.lastPushError,
      pendingPushCount: data.pendingPushCount.present
          ? data.pendingPushCount.value
          : this.pendingPushCount,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('moduleKey: $moduleKey, ')
          ..write('lastPulledAtMs: $lastPulledAtMs, ')
          ..write('lastPushedAtMs: $lastPushedAtMs, ')
          ..write('lastPushAttemptAtMs: $lastPushAttemptAtMs, ')
          ..write('lastPushError: $lastPushError, ')
          ..write('pendingPushCount: $pendingPushCount, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    moduleKey,
    lastPulledAtMs,
    lastPushedAtMs,
    lastPushAttemptAtMs,
    lastPushError,
    pendingPushCount,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.moduleKey == this.moduleKey &&
          other.lastPulledAtMs == this.lastPulledAtMs &&
          other.lastPushedAtMs == this.lastPushedAtMs &&
          other.lastPushAttemptAtMs == this.lastPushAttemptAtMs &&
          other.lastPushError == this.lastPushError &&
          other.pendingPushCount == this.pendingPushCount &&
          other.updatedAtMs == this.updatedAtMs);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> moduleKey;
  final Value<int> lastPulledAtMs;
  final Value<int> lastPushedAtMs;
  final Value<int> lastPushAttemptAtMs;
  final Value<String?> lastPushError;
  final Value<int> pendingPushCount;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.moduleKey = const Value.absent(),
    this.lastPulledAtMs = const Value.absent(),
    this.lastPushedAtMs = const Value.absent(),
    this.lastPushAttemptAtMs = const Value.absent(),
    this.lastPushError = const Value.absent(),
    this.pendingPushCount = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String moduleKey,
    this.lastPulledAtMs = const Value.absent(),
    this.lastPushedAtMs = const Value.absent(),
    this.lastPushAttemptAtMs = const Value.absent(),
    this.lastPushError = const Value.absent(),
    this.pendingPushCount = const Value.absent(),
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : moduleKey = Value(moduleKey),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<SyncStateRow> custom({
    Expression<String>? moduleKey,
    Expression<int>? lastPulledAtMs,
    Expression<int>? lastPushedAtMs,
    Expression<int>? lastPushAttemptAtMs,
    Expression<String>? lastPushError,
    Expression<int>? pendingPushCount,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (moduleKey != null) 'module_key': moduleKey,
      if (lastPulledAtMs != null) 'last_pulled_at_ms': lastPulledAtMs,
      if (lastPushedAtMs != null) 'last_pushed_at_ms': lastPushedAtMs,
      if (lastPushAttemptAtMs != null)
        'last_push_attempt_at_ms': lastPushAttemptAtMs,
      if (lastPushError != null) 'last_push_error': lastPushError,
      if (pendingPushCount != null) 'pending_push_count': pendingPushCount,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? moduleKey,
    Value<int>? lastPulledAtMs,
    Value<int>? lastPushedAtMs,
    Value<int>? lastPushAttemptAtMs,
    Value<String?>? lastPushError,
    Value<int>? pendingPushCount,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      moduleKey: moduleKey ?? this.moduleKey,
      lastPulledAtMs: lastPulledAtMs ?? this.lastPulledAtMs,
      lastPushedAtMs: lastPushedAtMs ?? this.lastPushedAtMs,
      lastPushAttemptAtMs: lastPushAttemptAtMs ?? this.lastPushAttemptAtMs,
      lastPushError: lastPushError ?? this.lastPushError,
      pendingPushCount: pendingPushCount ?? this.pendingPushCount,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (moduleKey.present) {
      map['module_key'] = Variable<String>(moduleKey.value);
    }
    if (lastPulledAtMs.present) {
      map['last_pulled_at_ms'] = Variable<int>(lastPulledAtMs.value);
    }
    if (lastPushedAtMs.present) {
      map['last_pushed_at_ms'] = Variable<int>(lastPushedAtMs.value);
    }
    if (lastPushAttemptAtMs.present) {
      map['last_push_attempt_at_ms'] = Variable<int>(lastPushAttemptAtMs.value);
    }
    if (lastPushError.present) {
      map['last_push_error'] = Variable<String>(lastPushError.value);
    }
    if (pendingPushCount.present) {
      map['pending_push_count'] = Variable<int>(pendingPushCount.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('moduleKey: $moduleKey, ')
          ..write('lastPulledAtMs: $lastPulledAtMs, ')
          ..write('lastPushedAtMs: $lastPushedAtMs, ')
          ..write('lastPushAttemptAtMs: $lastPushAttemptAtMs, ')
          ..write('lastPushError: $lastPushError, ')
          ..write('pendingPushCount: $pendingPushCount, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $AppMetaTableToColumns implements Insertable<AppMetaRow> {
  String get key;
  String get value;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaRow extends DataClass with $AppMetaTableToColumns {
  @override
  final String key;
  @override
  final String value;
  const AppMetaRow({required this.key, required this.value});
  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaRow copyWith({String? key, String? value}) =>
      AppMetaRow(key: key ?? this.key, value: value ?? this.value);
  AppMetaRow copyWithCompanion(AppMetaCompanion data) {
    return AppMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $ChargesTableToColumns implements Insertable<ChargeRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  double get lowerBound;
  double get upperBound;
  double get chargeAmount;
  String get transactionTypeKey;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['lower_bound'] = Variable<double>(lowerBound);
    map['upper_bound'] = Variable<double>(upperBound);
    map['charge_amount'] = Variable<double>(chargeAmount);
    map['transaction_type_key'] = Variable<String>(transactionTypeKey);
    return map;
  }
}

class $ChargesTable extends Charges with TableInfo<$ChargesTable, ChargeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChargesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lowerBoundMeta = const VerificationMeta(
    'lowerBound',
  );
  @override
  late final GeneratedColumn<double> lowerBound = GeneratedColumn<double>(
    'lower_bound',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _upperBoundMeta = const VerificationMeta(
    'upperBound',
  );
  @override
  late final GeneratedColumn<double> upperBound = GeneratedColumn<double>(
    'upper_bound',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chargeAmountMeta = const VerificationMeta(
    'chargeAmount',
  );
  @override
  late final GeneratedColumn<double> chargeAmount = GeneratedColumn<double>(
    'charge_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionTypeKeyMeta =
      const VerificationMeta('transactionTypeKey');
  @override
  late final GeneratedColumn<String> transactionTypeKey =
      GeneratedColumn<String>(
        'transaction_type_key',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('gcash_cashin'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    lowerBound,
    upperBound,
    chargeAmount,
    transactionTypeKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'charges';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChargeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lower_bound')) {
      context.handle(
        _lowerBoundMeta,
        lowerBound.isAcceptableOrUnknown(data['lower_bound']!, _lowerBoundMeta),
      );
    } else if (isInserting) {
      context.missing(_lowerBoundMeta);
    }
    if (data.containsKey('upper_bound')) {
      context.handle(
        _upperBoundMeta,
        upperBound.isAcceptableOrUnknown(data['upper_bound']!, _upperBoundMeta),
      );
    } else if (isInserting) {
      context.missing(_upperBoundMeta);
    }
    if (data.containsKey('charge_amount')) {
      context.handle(
        _chargeAmountMeta,
        chargeAmount.isAcceptableOrUnknown(
          data['charge_amount']!,
          _chargeAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chargeAmountMeta);
    }
    if (data.containsKey('transaction_type_key')) {
      context.handle(
        _transactionTypeKeyMeta,
        transactionTypeKey.isAcceptableOrUnknown(
          data['transaction_type_key']!,
          _transactionTypeKeyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChargeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChargeRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lowerBound: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lower_bound'],
      )!,
      upperBound: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}upper_bound'],
      )!,
      chargeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}charge_amount'],
      )!,
      transactionTypeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type_key'],
      )!,
    );
  }

  @override
  $ChargesTable createAlias(String alias) {
    return $ChargesTable(attachedDatabase, alias);
  }
}

class ChargeRow extends DataClass with $ChargesTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final double lowerBound;
  @override
  final double upperBound;
  @override
  final double chargeAmount;
  @override
  final String transactionTypeKey;
  const ChargeRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.lowerBound,
    required this.upperBound,
    required this.chargeAmount,
    required this.transactionTypeKey,
  });
  ChargesCompanion toCompanion(bool nullToAbsent) {
    return ChargesCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      lowerBound: Value(lowerBound),
      upperBound: Value(upperBound),
      chargeAmount: Value(chargeAmount),
      transactionTypeKey: Value(transactionTypeKey),
    );
  }

  factory ChargeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChargeRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      lowerBound: serializer.fromJson<double>(json['lowerBound']),
      upperBound: serializer.fromJson<double>(json['upperBound']),
      chargeAmount: serializer.fromJson<double>(json['chargeAmount']),
      transactionTypeKey: serializer.fromJson<String>(
        json['transactionTypeKey'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'lowerBound': serializer.toJson<double>(lowerBound),
      'upperBound': serializer.toJson<double>(upperBound),
      'chargeAmount': serializer.toJson<double>(chargeAmount),
      'transactionTypeKey': serializer.toJson<String>(transactionTypeKey),
    };
  }

  ChargeRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    double? lowerBound,
    double? upperBound,
    double? chargeAmount,
    String? transactionTypeKey,
  }) => ChargeRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    lowerBound: lowerBound ?? this.lowerBound,
    upperBound: upperBound ?? this.upperBound,
    chargeAmount: chargeAmount ?? this.chargeAmount,
    transactionTypeKey: transactionTypeKey ?? this.transactionTypeKey,
  );
  ChargeRow copyWithCompanion(ChargesCompanion data) {
    return ChargeRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      lowerBound: data.lowerBound.present
          ? data.lowerBound.value
          : this.lowerBound,
      upperBound: data.upperBound.present
          ? data.upperBound.value
          : this.upperBound,
      chargeAmount: data.chargeAmount.present
          ? data.chargeAmount.value
          : this.chargeAmount,
      transactionTypeKey: data.transactionTypeKey.present
          ? data.transactionTypeKey.value
          : this.transactionTypeKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChargeRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('lowerBound: $lowerBound, ')
          ..write('upperBound: $upperBound, ')
          ..write('chargeAmount: $chargeAmount, ')
          ..write('transactionTypeKey: $transactionTypeKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    lowerBound,
    upperBound,
    chargeAmount,
    transactionTypeKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChargeRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.lowerBound == this.lowerBound &&
          other.upperBound == this.upperBound &&
          other.chargeAmount == this.chargeAmount &&
          other.transactionTypeKey == this.transactionTypeKey);
}

class ChargesCompanion extends UpdateCompanion<ChargeRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<double> lowerBound;
  final Value<double> upperBound;
  final Value<double> chargeAmount;
  final Value<String> transactionTypeKey;
  final Value<int> rowid;
  const ChargesCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.lowerBound = const Value.absent(),
    this.upperBound = const Value.absent(),
    this.chargeAmount = const Value.absent(),
    this.transactionTypeKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChargesCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required double lowerBound,
    required double upperBound,
    required double chargeAmount,
    this.transactionTypeKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       lowerBound = Value(lowerBound),
       upperBound = Value(upperBound),
       chargeAmount = Value(chargeAmount);
  static Insertable<ChargeRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<double>? lowerBound,
    Expression<double>? upperBound,
    Expression<double>? chargeAmount,
    Expression<String>? transactionTypeKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (lowerBound != null) 'lower_bound': lowerBound,
      if (upperBound != null) 'upper_bound': upperBound,
      if (chargeAmount != null) 'charge_amount': chargeAmount,
      if (transactionTypeKey != null)
        'transaction_type_key': transactionTypeKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChargesCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<double>? lowerBound,
    Value<double>? upperBound,
    Value<double>? chargeAmount,
    Value<String>? transactionTypeKey,
    Value<int>? rowid,
  }) {
    return ChargesCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      lowerBound: lowerBound ?? this.lowerBound,
      upperBound: upperBound ?? this.upperBound,
      chargeAmount: chargeAmount ?? this.chargeAmount,
      transactionTypeKey: transactionTypeKey ?? this.transactionTypeKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lowerBound.present) {
      map['lower_bound'] = Variable<double>(lowerBound.value);
    }
    if (upperBound.present) {
      map['upper_bound'] = Variable<double>(upperBound.value);
    }
    if (chargeAmount.present) {
      map['charge_amount'] = Variable<double>(chargeAmount.value);
    }
    if (transactionTypeKey.present) {
      map['transaction_type_key'] = Variable<String>(transactionTypeKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChargesCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('lowerBound: $lowerBound, ')
          ..write('upperBound: $upperBound, ')
          ..write('chargeAmount: $chargeAmount, ')
          ..write('transactionTypeKey: $transactionTypeKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $PartiesTableToColumns implements Insertable<PartyRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get name;
  String get accountNumber;
  String get entityId;
  String get description;
  String get joinDate;
  bool get isVerified;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['account_number'] = Variable<String>(accountNumber);
    map['entity_id'] = Variable<String>(entityId);
    map['description'] = Variable<String>(description);
    map['join_date'] = Variable<String>(joinDate);
    map['is_verified'] = Variable<bool>(isVerified);
    return map;
  }
}

class $PartiesTable extends Parties with TableInfo<$PartiesTable, PartyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountNumberMeta = const VerificationMeta(
    'accountNumber',
  );
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
    'account_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _joinDateMeta = const VerificationMeta(
    'joinDate',
  );
  @override
  late final GeneratedColumn<String> joinDate = GeneratedColumn<String>(
    'join_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isVerifiedMeta = const VerificationMeta(
    'isVerified',
  );
  @override
  late final GeneratedColumn<bool> isVerified = GeneratedColumn<bool>(
    'is_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    accountNumber,
    entityId,
    description,
    joinDate,
    isVerified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('account_number')) {
      context.handle(
        _accountNumberMeta,
        accountNumber.isAcceptableOrUnknown(
          data['account_number']!,
          _accountNumberMeta,
        ),
      );
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
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
    if (data.containsKey('join_date')) {
      context.handle(
        _joinDateMeta,
        joinDate.isAcceptableOrUnknown(data['join_date']!, _joinDateMeta),
      );
    } else if (isInserting) {
      context.missing(_joinDateMeta);
    }
    if (data.containsKey('is_verified')) {
      context.handle(
        _isVerifiedMeta,
        isVerified.isAcceptableOrUnknown(data['is_verified']!, _isVerifiedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartyRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      accountNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_number'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      joinDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}join_date'],
      )!,
      isVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_verified'],
      )!,
    );
  }

  @override
  $PartiesTable createAlias(String alias) {
    return $PartiesTable(attachedDatabase, alias);
  }
}

class PartyRow extends DataClass with $PartiesTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String name;
  @override
  final String accountNumber;
  @override
  final String entityId;
  @override
  final String description;
  @override
  final String joinDate;
  @override
  final bool isVerified;
  const PartyRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.entityId,
    required this.description,
    required this.joinDate,
    required this.isVerified,
  });
  PartiesCompanion toCompanion(bool nullToAbsent) {
    return PartiesCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      name: Value(name),
      accountNumber: Value(accountNumber),
      entityId: Value(entityId),
      description: Value(description),
      joinDate: Value(joinDate),
      isVerified: Value(isVerified),
    );
  }

  factory PartyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartyRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      accountNumber: serializer.fromJson<String>(json['accountNumber']),
      entityId: serializer.fromJson<String>(json['entityId']),
      description: serializer.fromJson<String>(json['description']),
      joinDate: serializer.fromJson<String>(json['joinDate']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'accountNumber': serializer.toJson<String>(accountNumber),
      'entityId': serializer.toJson<String>(entityId),
      'description': serializer.toJson<String>(description),
      'joinDate': serializer.toJson<String>(joinDate),
      'isVerified': serializer.toJson<bool>(isVerified),
    };
  }

  PartyRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? name,
    String? accountNumber,
    String? entityId,
    String? description,
    String? joinDate,
    bool? isVerified,
  }) => PartyRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    name: name ?? this.name,
    accountNumber: accountNumber ?? this.accountNumber,
    entityId: entityId ?? this.entityId,
    description: description ?? this.description,
    joinDate: joinDate ?? this.joinDate,
    isVerified: isVerified ?? this.isVerified,
  );
  PartyRow copyWithCompanion(PartiesCompanion data) {
    return PartyRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      description: data.description.present
          ? data.description.value
          : this.description,
      joinDate: data.joinDate.present ? data.joinDate.value : this.joinDate,
      isVerified: data.isVerified.present
          ? data.isVerified.value
          : this.isVerified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartyRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('entityId: $entityId, ')
          ..write('description: $description, ')
          ..write('joinDate: $joinDate, ')
          ..write('isVerified: $isVerified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    accountNumber,
    entityId,
    description,
    joinDate,
    isVerified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.name == this.name &&
          other.accountNumber == this.accountNumber &&
          other.entityId == this.entityId &&
          other.description == this.description &&
          other.joinDate == this.joinDate &&
          other.isVerified == this.isVerified);
}

class PartiesCompanion extends UpdateCompanion<PartyRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> name;
  final Value<String> accountNumber;
  final Value<String> entityId;
  final Value<String> description;
  final Value<String> joinDate;
  final Value<bool> isVerified;
  final Value<int> rowid;
  const PartiesCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.entityId = const Value.absent(),
    this.description = const Value.absent(),
    this.joinDate = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartiesCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String name,
    this.accountNumber = const Value.absent(),
    this.entityId = const Value.absent(),
    this.description = const Value.absent(),
    required String joinDate,
    this.isVerified = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       name = Value(name),
       joinDate = Value(joinDate);
  static Insertable<PartyRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? accountNumber,
    Expression<String>? entityId,
    Expression<String>? description,
    Expression<String>? joinDate,
    Expression<bool>? isVerified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (accountNumber != null) 'account_number': accountNumber,
      if (entityId != null) 'entity_id': entityId,
      if (description != null) 'description': description,
      if (joinDate != null) 'join_date': joinDate,
      if (isVerified != null) 'is_verified': isVerified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartiesCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? name,
    Value<String>? accountNumber,
    Value<String>? entityId,
    Value<String>? description,
    Value<String>? joinDate,
    Value<bool>? isVerified,
    Value<int>? rowid,
  }) {
    return PartiesCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      entityId: entityId ?? this.entityId,
      description: description ?? this.description,
      joinDate: joinDate ?? this.joinDate,
      isVerified: isVerified ?? this.isVerified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (joinDate.present) {
      map['join_date'] = Variable<String>(joinDate.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<bool>(isVerified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartiesCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('entityId: $entityId, ')
          ..write('description: $description, ')
          ..write('joinDate: $joinDate, ')
          ..write('isVerified: $isVerified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $TransactionTypesTableToColumns
    implements Insertable<TransactionTypeRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get name;
  bool get isOutflow;
  String get walletAccount;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_outflow'] = Variable<bool>(isOutflow);
    map['wallet_account'] = Variable<String>(walletAccount);
    return map;
  }
}

class $TransactionTypesTable extends TransactionTypes
    with TableInfo<$TransactionTypesTable, TransactionTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOutflowMeta = const VerificationMeta(
    'isOutflow',
  );
  @override
  late final GeneratedColumn<bool> isOutflow = GeneratedColumn<bool>(
    'is_outflow',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_outflow" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _walletAccountMeta = const VerificationMeta(
    'walletAccount',
  );
  @override
  late final GeneratedColumn<String> walletAccount = GeneratedColumn<String>(
    'wallet_account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GCash'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    isOutflow,
    walletAccount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionTypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_outflow')) {
      context.handle(
        _isOutflowMeta,
        isOutflow.isAcceptableOrUnknown(data['is_outflow']!, _isOutflowMeta),
      );
    }
    if (data.containsKey('wallet_account')) {
      context.handle(
        _walletAccountMeta,
        walletAccount.isAcceptableOrUnknown(
          data['wallet_account']!,
          _walletAccountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionTypeRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isOutflow: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_outflow'],
      )!,
      walletAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_account'],
      )!,
    );
  }

  @override
  $TransactionTypesTable createAlias(String alias) {
    return $TransactionTypesTable(attachedDatabase, alias);
  }
}

class TransactionTypeRow extends DataClass
    with $TransactionTypesTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String name;
  @override
  final bool isOutflow;
  @override
  final String walletAccount;
  const TransactionTypeRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.name,
    required this.isOutflow,
    required this.walletAccount,
  });
  TransactionTypesCompanion toCompanion(bool nullToAbsent) {
    return TransactionTypesCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      name: Value(name),
      isOutflow: Value(isOutflow),
      walletAccount: Value(walletAccount),
    );
  }

  factory TransactionTypeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionTypeRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isOutflow: serializer.fromJson<bool>(json['isOutflow']),
      walletAccount: serializer.fromJson<String>(json['walletAccount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isOutflow': serializer.toJson<bool>(isOutflow),
      'walletAccount': serializer.toJson<String>(walletAccount),
    };
  }

  TransactionTypeRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? name,
    bool? isOutflow,
    String? walletAccount,
  }) => TransactionTypeRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    name: name ?? this.name,
    isOutflow: isOutflow ?? this.isOutflow,
    walletAccount: walletAccount ?? this.walletAccount,
  );
  TransactionTypeRow copyWithCompanion(TransactionTypesCompanion data) {
    return TransactionTypeRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isOutflow: data.isOutflow.present ? data.isOutflow.value : this.isOutflow,
      walletAccount: data.walletAccount.present
          ? data.walletAccount.value
          : this.walletAccount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTypeRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isOutflow: $isOutflow, ')
          ..write('walletAccount: $walletAccount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    isOutflow,
    walletAccount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionTypeRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.name == this.name &&
          other.isOutflow == this.isOutflow &&
          other.walletAccount == this.walletAccount);
}

class TransactionTypesCompanion extends UpdateCompanion<TransactionTypeRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isOutflow;
  final Value<String> walletAccount;
  final Value<int> rowid;
  const TransactionTypesCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isOutflow = const Value.absent(),
    this.walletAccount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionTypesCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String name,
    this.isOutflow = const Value.absent(),
    this.walletAccount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       name = Value(name);
  static Insertable<TransactionTypeRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isOutflow,
    Expression<String>? walletAccount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isOutflow != null) 'is_outflow': isOutflow,
      if (walletAccount != null) 'wallet_account': walletAccount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionTypesCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isOutflow,
    Value<String>? walletAccount,
    Value<int>? rowid,
  }) {
    return TransactionTypesCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      name: name ?? this.name,
      isOutflow: isOutflow ?? this.isOutflow,
      walletAccount: walletAccount ?? this.walletAccount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isOutflow.present) {
      map['is_outflow'] = Variable<bool>(isOutflow.value);
    }
    if (walletAccount.present) {
      map['wallet_account'] = Variable<String>(walletAccount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTypesCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isOutflow: $isOutflow, ')
          ..write('walletAccount: $walletAccount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $MovementCategoriesTableToColumns
    implements Insertable<MovementCategoryRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get name;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }
}

class $MovementCategoriesTable extends MovementCategories
    with TableInfo<$MovementCategoriesTable, MovementCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movement_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovementCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovementCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovementCategoryRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $MovementCategoriesTable createAlias(String alias) {
    return $MovementCategoriesTable(attachedDatabase, alias);
  }
}

class MovementCategoryRow extends DataClass
    with $MovementCategoriesTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String name;
  const MovementCategoryRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.name,
  });
  MovementCategoriesCompanion toCompanion(bool nullToAbsent) {
    return MovementCategoriesCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      name: Value(name),
    );
  }

  factory MovementCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovementCategoryRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  MovementCategoryRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? name,
  }) => MovementCategoryRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    name: name ?? this.name,
  );
  MovementCategoryRow copyWithCompanion(MovementCategoriesCompanion data) {
    return MovementCategoryRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovementCategoryRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovementCategoryRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.name == this.name);
}

class MovementCategoriesCompanion extends UpdateCompanion<MovementCategoryRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const MovementCategoriesCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovementCategoriesCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       name = Value(name);
  static Insertable<MovementCategoryRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovementCategoriesCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return MovementCategoriesCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementCategoriesCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $LedgerEntriesTableToColumns implements Insertable<LedgerEntryRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String? get transactionId;
  String get entryType;
  String get title;
  String get note;
  String get reference;
  double get amount;
  double get walletDelta;
  double get mayaWalletDelta;
  double get onHandDelta;
  double get recordedFlow;
  String get tag;
  String get iconKey;
  String get walletAccount;
  String get ownerScope;
  String? get ownerMovementType;
  String? get ownerCategory;
  String? get ownerPartyName;
  String? get ownerPartyAccount;
  String get entryDate;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    map['entry_type'] = Variable<String>(entryType);
    map['title'] = Variable<String>(title);
    map['note'] = Variable<String>(note);
    map['reference'] = Variable<String>(reference);
    map['amount'] = Variable<double>(amount);
    map['wallet_delta'] = Variable<double>(walletDelta);
    map['maya_wallet_delta'] = Variable<double>(mayaWalletDelta);
    map['on_hand_delta'] = Variable<double>(onHandDelta);
    map['recorded_flow'] = Variable<double>(recordedFlow);
    map['tag'] = Variable<String>(tag);
    map['icon_key'] = Variable<String>(iconKey);
    map['wallet_account'] = Variable<String>(walletAccount);
    map['owner_scope'] = Variable<String>(ownerScope);
    if (!nullToAbsent || ownerMovementType != null) {
      map['owner_movement_type'] = Variable<String>(ownerMovementType);
    }
    if (!nullToAbsent || ownerCategory != null) {
      map['owner_category'] = Variable<String>(ownerCategory);
    }
    if (!nullToAbsent || ownerPartyName != null) {
      map['owner_party_name'] = Variable<String>(ownerPartyName);
    }
    if (!nullToAbsent || ownerPartyAccount != null) {
      map['owner_party_account'] = Variable<String>(ownerPartyAccount);
    }
    map['entry_date'] = Variable<String>(entryDate);
    return map;
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletDeltaMeta = const VerificationMeta(
    'walletDelta',
  );
  @override
  late final GeneratedColumn<double> walletDelta = GeneratedColumn<double>(
    'wallet_delta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mayaWalletDeltaMeta = const VerificationMeta(
    'mayaWalletDelta',
  );
  @override
  late final GeneratedColumn<double> mayaWalletDelta = GeneratedColumn<double>(
    'maya_wallet_delta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _onHandDeltaMeta = const VerificationMeta(
    'onHandDelta',
  );
  @override
  late final GeneratedColumn<double> onHandDelta = GeneratedColumn<double>(
    'on_hand_delta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recordedFlowMeta = const VerificationMeta(
    'recordedFlow',
  );
  @override
  late final GeneratedColumn<double> recordedFlow = GeneratedColumn<double>(
    'recorded_flow',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _walletAccountMeta = const VerificationMeta(
    'walletAccount',
  );
  @override
  late final GeneratedColumn<String> walletAccount = GeneratedColumn<String>(
    'wallet_account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Business'),
  );
  static const VerificationMeta _ownerMovementTypeMeta = const VerificationMeta(
    'ownerMovementType',
  );
  @override
  late final GeneratedColumn<String> ownerMovementType =
      GeneratedColumn<String>(
        'owner_movement_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ownerCategoryMeta = const VerificationMeta(
    'ownerCategory',
  );
  @override
  late final GeneratedColumn<String> ownerCategory = GeneratedColumn<String>(
    'owner_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerPartyNameMeta = const VerificationMeta(
    'ownerPartyName',
  );
  @override
  late final GeneratedColumn<String> ownerPartyName = GeneratedColumn<String>(
    'owner_party_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerPartyAccountMeta = const VerificationMeta(
    'ownerPartyAccount',
  );
  @override
  late final GeneratedColumn<String> ownerPartyAccount =
      GeneratedColumn<String>(
        'owner_party_account',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    transactionId,
    entryType,
    title,
    note,
    reference,
    amount,
    walletDelta,
    mayaWalletDelta,
    onHandDelta,
    recordedFlow,
    tag,
    iconKey,
    walletAccount,
    ownerScope,
    ownerMovementType,
    ownerCategory,
    ownerPartyName,
    ownerPartyAccount,
    entryDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('wallet_delta')) {
      context.handle(
        _walletDeltaMeta,
        walletDelta.isAcceptableOrUnknown(
          data['wallet_delta']!,
          _walletDeltaMeta,
        ),
      );
    }
    if (data.containsKey('maya_wallet_delta')) {
      context.handle(
        _mayaWalletDeltaMeta,
        mayaWalletDelta.isAcceptableOrUnknown(
          data['maya_wallet_delta']!,
          _mayaWalletDeltaMeta,
        ),
      );
    }
    if (data.containsKey('on_hand_delta')) {
      context.handle(
        _onHandDeltaMeta,
        onHandDelta.isAcceptableOrUnknown(
          data['on_hand_delta']!,
          _onHandDeltaMeta,
        ),
      );
    }
    if (data.containsKey('recorded_flow')) {
      context.handle(
        _recordedFlowMeta,
        recordedFlow.isAcceptableOrUnknown(
          data['recorded_flow']!,
          _recordedFlowMeta,
        ),
      );
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('wallet_account')) {
      context.handle(
        _walletAccountMeta,
        walletAccount.isAcceptableOrUnknown(
          data['wallet_account']!,
          _walletAccountMeta,
        ),
      );
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    }
    if (data.containsKey('owner_movement_type')) {
      context.handle(
        _ownerMovementTypeMeta,
        ownerMovementType.isAcceptableOrUnknown(
          data['owner_movement_type']!,
          _ownerMovementTypeMeta,
        ),
      );
    }
    if (data.containsKey('owner_category')) {
      context.handle(
        _ownerCategoryMeta,
        ownerCategory.isAcceptableOrUnknown(
          data['owner_category']!,
          _ownerCategoryMeta,
        ),
      );
    }
    if (data.containsKey('owner_party_name')) {
      context.handle(
        _ownerPartyNameMeta,
        ownerPartyName.isAcceptableOrUnknown(
          data['owner_party_name']!,
          _ownerPartyNameMeta,
        ),
      );
    }
    if (data.containsKey('owner_party_account')) {
      context.handle(
        _ownerPartyAccountMeta,
        ownerPartyAccount.isAcceptableOrUnknown(
          data['owner_party_account']!,
          _ownerPartyAccountMeta,
        ),
      );
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntryRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      ),
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      walletDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}wallet_delta'],
      )!,
      mayaWalletDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}maya_wallet_delta'],
      )!,
      onHandDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}on_hand_delta'],
      )!,
      recordedFlow: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recorded_flow'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      walletAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_account'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      ownerMovementType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_movement_type'],
      ),
      ownerCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_category'],
      ),
      ownerPartyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_party_name'],
      ),
      ownerPartyAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_party_account'],
      ),
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntryRow extends DataClass with $LedgerEntriesTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String? transactionId;
  @override
  final String entryType;
  @override
  final String title;
  @override
  final String note;
  @override
  final String reference;
  @override
  final double amount;
  @override
  final double walletDelta;
  @override
  final double mayaWalletDelta;
  @override
  final double onHandDelta;
  @override
  final double recordedFlow;
  @override
  final String tag;
  @override
  final String iconKey;
  @override
  final String walletAccount;
  @override
  final String ownerScope;
  @override
  final String? ownerMovementType;
  @override
  final String? ownerCategory;
  @override
  final String? ownerPartyName;
  @override
  final String? ownerPartyAccount;
  @override
  final String entryDate;
  const LedgerEntryRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    this.transactionId,
    required this.entryType,
    required this.title,
    required this.note,
    required this.reference,
    required this.amount,
    required this.walletDelta,
    required this.mayaWalletDelta,
    required this.onHandDelta,
    required this.recordedFlow,
    required this.tag,
    required this.iconKey,
    required this.walletAccount,
    required this.ownerScope,
    this.ownerMovementType,
    this.ownerCategory,
    this.ownerPartyName,
    this.ownerPartyAccount,
    required this.entryDate,
  });
  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      entryType: Value(entryType),
      title: Value(title),
      note: Value(note),
      reference: Value(reference),
      amount: Value(amount),
      walletDelta: Value(walletDelta),
      mayaWalletDelta: Value(mayaWalletDelta),
      onHandDelta: Value(onHandDelta),
      recordedFlow: Value(recordedFlow),
      tag: Value(tag),
      iconKey: Value(iconKey),
      walletAccount: Value(walletAccount),
      ownerScope: Value(ownerScope),
      ownerMovementType: ownerMovementType == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerMovementType),
      ownerCategory: ownerCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerCategory),
      ownerPartyName: ownerPartyName == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerPartyName),
      ownerPartyAccount: ownerPartyAccount == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerPartyAccount),
      entryDate: Value(entryDate),
    );
  }

  factory LedgerEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntryRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
      entryType: serializer.fromJson<String>(json['entryType']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String>(json['note']),
      reference: serializer.fromJson<String>(json['reference']),
      amount: serializer.fromJson<double>(json['amount']),
      walletDelta: serializer.fromJson<double>(json['walletDelta']),
      mayaWalletDelta: serializer.fromJson<double>(json['mayaWalletDelta']),
      onHandDelta: serializer.fromJson<double>(json['onHandDelta']),
      recordedFlow: serializer.fromJson<double>(json['recordedFlow']),
      tag: serializer.fromJson<String>(json['tag']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      walletAccount: serializer.fromJson<String>(json['walletAccount']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      ownerMovementType: serializer.fromJson<String?>(
        json['ownerMovementType'],
      ),
      ownerCategory: serializer.fromJson<String?>(json['ownerCategory']),
      ownerPartyName: serializer.fromJson<String?>(json['ownerPartyName']),
      ownerPartyAccount: serializer.fromJson<String?>(
        json['ownerPartyAccount'],
      ),
      entryDate: serializer.fromJson<String>(json['entryDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String?>(transactionId),
      'entryType': serializer.toJson<String>(entryType),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String>(note),
      'reference': serializer.toJson<String>(reference),
      'amount': serializer.toJson<double>(amount),
      'walletDelta': serializer.toJson<double>(walletDelta),
      'mayaWalletDelta': serializer.toJson<double>(mayaWalletDelta),
      'onHandDelta': serializer.toJson<double>(onHandDelta),
      'recordedFlow': serializer.toJson<double>(recordedFlow),
      'tag': serializer.toJson<String>(tag),
      'iconKey': serializer.toJson<String>(iconKey),
      'walletAccount': serializer.toJson<String>(walletAccount),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'ownerMovementType': serializer.toJson<String?>(ownerMovementType),
      'ownerCategory': serializer.toJson<String?>(ownerCategory),
      'ownerPartyName': serializer.toJson<String?>(ownerPartyName),
      'ownerPartyAccount': serializer.toJson<String?>(ownerPartyAccount),
      'entryDate': serializer.toJson<String>(entryDate),
    };
  }

  LedgerEntryRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    Value<String?> transactionId = const Value.absent(),
    String? entryType,
    String? title,
    String? note,
    String? reference,
    double? amount,
    double? walletDelta,
    double? mayaWalletDelta,
    double? onHandDelta,
    double? recordedFlow,
    String? tag,
    String? iconKey,
    String? walletAccount,
    String? ownerScope,
    Value<String?> ownerMovementType = const Value.absent(),
    Value<String?> ownerCategory = const Value.absent(),
    Value<String?> ownerPartyName = const Value.absent(),
    Value<String?> ownerPartyAccount = const Value.absent(),
    String? entryDate,
  }) => LedgerEntryRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    transactionId: transactionId.present
        ? transactionId.value
        : this.transactionId,
    entryType: entryType ?? this.entryType,
    title: title ?? this.title,
    note: note ?? this.note,
    reference: reference ?? this.reference,
    amount: amount ?? this.amount,
    walletDelta: walletDelta ?? this.walletDelta,
    mayaWalletDelta: mayaWalletDelta ?? this.mayaWalletDelta,
    onHandDelta: onHandDelta ?? this.onHandDelta,
    recordedFlow: recordedFlow ?? this.recordedFlow,
    tag: tag ?? this.tag,
    iconKey: iconKey ?? this.iconKey,
    walletAccount: walletAccount ?? this.walletAccount,
    ownerScope: ownerScope ?? this.ownerScope,
    ownerMovementType: ownerMovementType.present
        ? ownerMovementType.value
        : this.ownerMovementType,
    ownerCategory: ownerCategory.present
        ? ownerCategory.value
        : this.ownerCategory,
    ownerPartyName: ownerPartyName.present
        ? ownerPartyName.value
        : this.ownerPartyName,
    ownerPartyAccount: ownerPartyAccount.present
        ? ownerPartyAccount.value
        : this.ownerPartyAccount,
    entryDate: entryDate ?? this.entryDate,
  );
  LedgerEntryRow copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntryRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      reference: data.reference.present ? data.reference.value : this.reference,
      amount: data.amount.present ? data.amount.value : this.amount,
      walletDelta: data.walletDelta.present
          ? data.walletDelta.value
          : this.walletDelta,
      mayaWalletDelta: data.mayaWalletDelta.present
          ? data.mayaWalletDelta.value
          : this.mayaWalletDelta,
      onHandDelta: data.onHandDelta.present
          ? data.onHandDelta.value
          : this.onHandDelta,
      recordedFlow: data.recordedFlow.present
          ? data.recordedFlow.value
          : this.recordedFlow,
      tag: data.tag.present ? data.tag.value : this.tag,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      walletAccount: data.walletAccount.present
          ? data.walletAccount.value
          : this.walletAccount,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      ownerMovementType: data.ownerMovementType.present
          ? data.ownerMovementType.value
          : this.ownerMovementType,
      ownerCategory: data.ownerCategory.present
          ? data.ownerCategory.value
          : this.ownerCategory,
      ownerPartyName: data.ownerPartyName.present
          ? data.ownerPartyName.value
          : this.ownerPartyName,
      ownerPartyAccount: data.ownerPartyAccount.present
          ? data.ownerPartyAccount.value
          : this.ownerPartyAccount,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntryRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('entryType: $entryType, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('reference: $reference, ')
          ..write('amount: $amount, ')
          ..write('walletDelta: $walletDelta, ')
          ..write('mayaWalletDelta: $mayaWalletDelta, ')
          ..write('onHandDelta: $onHandDelta, ')
          ..write('recordedFlow: $recordedFlow, ')
          ..write('tag: $tag, ')
          ..write('iconKey: $iconKey, ')
          ..write('walletAccount: $walletAccount, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('ownerMovementType: $ownerMovementType, ')
          ..write('ownerCategory: $ownerCategory, ')
          ..write('ownerPartyName: $ownerPartyName, ')
          ..write('ownerPartyAccount: $ownerPartyAccount, ')
          ..write('entryDate: $entryDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    transactionId,
    entryType,
    title,
    note,
    reference,
    amount,
    walletDelta,
    mayaWalletDelta,
    onHandDelta,
    recordedFlow,
    tag,
    iconKey,
    walletAccount,
    ownerScope,
    ownerMovementType,
    ownerCategory,
    ownerPartyName,
    ownerPartyAccount,
    entryDate,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntryRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.entryType == this.entryType &&
          other.title == this.title &&
          other.note == this.note &&
          other.reference == this.reference &&
          other.amount == this.amount &&
          other.walletDelta == this.walletDelta &&
          other.mayaWalletDelta == this.mayaWalletDelta &&
          other.onHandDelta == this.onHandDelta &&
          other.recordedFlow == this.recordedFlow &&
          other.tag == this.tag &&
          other.iconKey == this.iconKey &&
          other.walletAccount == this.walletAccount &&
          other.ownerScope == this.ownerScope &&
          other.ownerMovementType == this.ownerMovementType &&
          other.ownerCategory == this.ownerCategory &&
          other.ownerPartyName == this.ownerPartyName &&
          other.ownerPartyAccount == this.ownerPartyAccount &&
          other.entryDate == this.entryDate);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntryRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String?> transactionId;
  final Value<String> entryType;
  final Value<String> title;
  final Value<String> note;
  final Value<String> reference;
  final Value<double> amount;
  final Value<double> walletDelta;
  final Value<double> mayaWalletDelta;
  final Value<double> onHandDelta;
  final Value<double> recordedFlow;
  final Value<String> tag;
  final Value<String> iconKey;
  final Value<String> walletAccount;
  final Value<String> ownerScope;
  final Value<String?> ownerMovementType;
  final Value<String?> ownerCategory;
  final Value<String?> ownerPartyName;
  final Value<String?> ownerPartyAccount;
  final Value<String> entryDate;
  final Value<int> rowid;
  const LedgerEntriesCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.reference = const Value.absent(),
    this.amount = const Value.absent(),
    this.walletDelta = const Value.absent(),
    this.mayaWalletDelta = const Value.absent(),
    this.onHandDelta = const Value.absent(),
    this.recordedFlow = const Value.absent(),
    this.tag = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.walletAccount = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.ownerMovementType = const Value.absent(),
    this.ownerCategory = const Value.absent(),
    this.ownerPartyName = const Value.absent(),
    this.ownerPartyAccount = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    this.transactionId = const Value.absent(),
    required String entryType,
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.reference = const Value.absent(),
    required double amount,
    this.walletDelta = const Value.absent(),
    this.mayaWalletDelta = const Value.absent(),
    this.onHandDelta = const Value.absent(),
    this.recordedFlow = const Value.absent(),
    this.tag = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.walletAccount = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.ownerMovementType = const Value.absent(),
    this.ownerCategory = const Value.absent(),
    this.ownerPartyName = const Value.absent(),
    this.ownerPartyAccount = const Value.absent(),
    required String entryDate,
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       entryType = Value(entryType),
       amount = Value(amount),
       entryDate = Value(entryDate);
  static Insertable<LedgerEntryRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? entryType,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? reference,
    Expression<double>? amount,
    Expression<double>? walletDelta,
    Expression<double>? mayaWalletDelta,
    Expression<double>? onHandDelta,
    Expression<double>? recordedFlow,
    Expression<String>? tag,
    Expression<String>? iconKey,
    Expression<String>? walletAccount,
    Expression<String>? ownerScope,
    Expression<String>? ownerMovementType,
    Expression<String>? ownerCategory,
    Expression<String>? ownerPartyName,
    Expression<String>? ownerPartyAccount,
    Expression<String>? entryDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (entryType != null) 'entry_type': entryType,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (reference != null) 'reference': reference,
      if (amount != null) 'amount': amount,
      if (walletDelta != null) 'wallet_delta': walletDelta,
      if (mayaWalletDelta != null) 'maya_wallet_delta': mayaWalletDelta,
      if (onHandDelta != null) 'on_hand_delta': onHandDelta,
      if (recordedFlow != null) 'recorded_flow': recordedFlow,
      if (tag != null) 'tag': tag,
      if (iconKey != null) 'icon_key': iconKey,
      if (walletAccount != null) 'wallet_account': walletAccount,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (ownerMovementType != null) 'owner_movement_type': ownerMovementType,
      if (ownerCategory != null) 'owner_category': ownerCategory,
      if (ownerPartyName != null) 'owner_party_name': ownerPartyName,
      if (ownerPartyAccount != null) 'owner_party_account': ownerPartyAccount,
      if (entryDate != null) 'entry_date': entryDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEntriesCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String?>? transactionId,
    Value<String>? entryType,
    Value<String>? title,
    Value<String>? note,
    Value<String>? reference,
    Value<double>? amount,
    Value<double>? walletDelta,
    Value<double>? mayaWalletDelta,
    Value<double>? onHandDelta,
    Value<double>? recordedFlow,
    Value<String>? tag,
    Value<String>? iconKey,
    Value<String>? walletAccount,
    Value<String>? ownerScope,
    Value<String?>? ownerMovementType,
    Value<String?>? ownerCategory,
    Value<String?>? ownerPartyName,
    Value<String?>? ownerPartyAccount,
    Value<String>? entryDate,
    Value<int>? rowid,
  }) {
    return LedgerEntriesCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      entryType: entryType ?? this.entryType,
      title: title ?? this.title,
      note: note ?? this.note,
      reference: reference ?? this.reference,
      amount: amount ?? this.amount,
      walletDelta: walletDelta ?? this.walletDelta,
      mayaWalletDelta: mayaWalletDelta ?? this.mayaWalletDelta,
      onHandDelta: onHandDelta ?? this.onHandDelta,
      recordedFlow: recordedFlow ?? this.recordedFlow,
      tag: tag ?? this.tag,
      iconKey: iconKey ?? this.iconKey,
      walletAccount: walletAccount ?? this.walletAccount,
      ownerScope: ownerScope ?? this.ownerScope,
      ownerMovementType: ownerMovementType ?? this.ownerMovementType,
      ownerCategory: ownerCategory ?? this.ownerCategory,
      ownerPartyName: ownerPartyName ?? this.ownerPartyName,
      ownerPartyAccount: ownerPartyAccount ?? this.ownerPartyAccount,
      entryDate: entryDate ?? this.entryDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (walletDelta.present) {
      map['wallet_delta'] = Variable<double>(walletDelta.value);
    }
    if (mayaWalletDelta.present) {
      map['maya_wallet_delta'] = Variable<double>(mayaWalletDelta.value);
    }
    if (onHandDelta.present) {
      map['on_hand_delta'] = Variable<double>(onHandDelta.value);
    }
    if (recordedFlow.present) {
      map['recorded_flow'] = Variable<double>(recordedFlow.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (walletAccount.present) {
      map['wallet_account'] = Variable<String>(walletAccount.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (ownerMovementType.present) {
      map['owner_movement_type'] = Variable<String>(ownerMovementType.value);
    }
    if (ownerCategory.present) {
      map['owner_category'] = Variable<String>(ownerCategory.value);
    }
    if (ownerPartyName.present) {
      map['owner_party_name'] = Variable<String>(ownerPartyName.value);
    }
    if (ownerPartyAccount.present) {
      map['owner_party_account'] = Variable<String>(ownerPartyAccount.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('entryType: $entryType, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('reference: $reference, ')
          ..write('amount: $amount, ')
          ..write('walletDelta: $walletDelta, ')
          ..write('mayaWalletDelta: $mayaWalletDelta, ')
          ..write('onHandDelta: $onHandDelta, ')
          ..write('recordedFlow: $recordedFlow, ')
          ..write('tag: $tag, ')
          ..write('iconKey: $iconKey, ')
          ..write('walletAccount: $walletAccount, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('ownerMovementType: $ownerMovementType, ')
          ..write('ownerCategory: $ownerCategory, ')
          ..write('ownerPartyName: $ownerPartyName, ')
          ..write('ownerPartyAccount: $ownerPartyAccount, ')
          ..write('entryDate: $entryDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $TransactionsTableToColumns implements Insertable<TransactionRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get walletProvider;
  String get direction;
  double get amount;
  double get chargeAmount;
  double get totalAmount;
  double get balanceBefore;
  double get balanceAfter;
  double? get chargeLowerBound;
  double? get chargeUpperBound;
  String get chargeHandling;
  String? get receiptImagePath;
  String? get receiptOriginalName;
  String? get receiptMimeType;
  int? get receiptUploadedAtMs;
  String get ocrStatus;
  double? get ocrExtractedAmount;
  String? get ocrRawText;
  int? get ocrProcessedAtMs;
  String? get externalProvider;
  String? get externalTransactionId;
  String get note;
  String get reference;
  String get entryDate;
  String get status;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['wallet_provider'] = Variable<String>(walletProvider);
    map['direction'] = Variable<String>(direction);
    map['amount'] = Variable<double>(amount);
    map['charge_amount'] = Variable<double>(chargeAmount);
    map['total_amount'] = Variable<double>(totalAmount);
    map['balance_before'] = Variable<double>(balanceBefore);
    map['balance_after'] = Variable<double>(balanceAfter);
    if (!nullToAbsent || chargeLowerBound != null) {
      map['charge_lower_bound'] = Variable<double>(chargeLowerBound);
    }
    if (!nullToAbsent || chargeUpperBound != null) {
      map['charge_upper_bound'] = Variable<double>(chargeUpperBound);
    }
    map['charge_handling'] = Variable<String>(chargeHandling);
    if (!nullToAbsent || receiptImagePath != null) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath);
    }
    if (!nullToAbsent || receiptOriginalName != null) {
      map['receipt_original_name'] = Variable<String>(receiptOriginalName);
    }
    if (!nullToAbsent || receiptMimeType != null) {
      map['receipt_mime_type'] = Variable<String>(receiptMimeType);
    }
    if (!nullToAbsent || receiptUploadedAtMs != null) {
      map['receipt_uploaded_at_ms'] = Variable<int>(receiptUploadedAtMs);
    }
    map['ocr_status'] = Variable<String>(ocrStatus);
    if (!nullToAbsent || ocrExtractedAmount != null) {
      map['ocr_extracted_amount'] = Variable<double>(ocrExtractedAmount);
    }
    if (!nullToAbsent || ocrRawText != null) {
      map['ocr_raw_text'] = Variable<String>(ocrRawText);
    }
    if (!nullToAbsent || ocrProcessedAtMs != null) {
      map['ocr_processed_at_ms'] = Variable<int>(ocrProcessedAtMs);
    }
    if (!nullToAbsent || externalProvider != null) {
      map['external_provider'] = Variable<String>(externalProvider);
    }
    if (!nullToAbsent || externalTransactionId != null) {
      map['external_transaction_id'] = Variable<String>(externalTransactionId);
    }
    map['note'] = Variable<String>(note);
    map['reference'] = Variable<String>(reference);
    map['entry_date'] = Variable<String>(entryDate);
    map['status'] = Variable<String>(status);
    return map;
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletProviderMeta = const VerificationMeta(
    'walletProvider',
  );
  @override
  late final GeneratedColumn<String> walletProvider = GeneratedColumn<String>(
    'wallet_provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chargeAmountMeta = const VerificationMeta(
    'chargeAmount',
  );
  @override
  late final GeneratedColumn<double> chargeAmount = GeneratedColumn<double>(
    'charge_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceBeforeMeta = const VerificationMeta(
    'balanceBefore',
  );
  @override
  late final GeneratedColumn<double> balanceBefore = GeneratedColumn<double>(
    'balance_before',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceAfterMeta = const VerificationMeta(
    'balanceAfter',
  );
  @override
  late final GeneratedColumn<double> balanceAfter = GeneratedColumn<double>(
    'balance_after',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chargeLowerBoundMeta = const VerificationMeta(
    'chargeLowerBound',
  );
  @override
  late final GeneratedColumn<double> chargeLowerBound = GeneratedColumn<double>(
    'charge_lower_bound',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chargeUpperBoundMeta = const VerificationMeta(
    'chargeUpperBound',
  );
  @override
  late final GeneratedColumn<double> chargeUpperBound = GeneratedColumn<double>(
    'charge_upper_bound',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chargeHandlingMeta = const VerificationMeta(
    'chargeHandling',
  );
  @override
  late final GeneratedColumn<String> chargeHandling = GeneratedColumn<String>(
    'charge_handling',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('addOnTop'),
  );
  static const VerificationMeta _receiptImagePathMeta = const VerificationMeta(
    'receiptImagePath',
  );
  @override
  late final GeneratedColumn<String> receiptImagePath = GeneratedColumn<String>(
    'receipt_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptOriginalNameMeta =
      const VerificationMeta('receiptOriginalName');
  @override
  late final GeneratedColumn<String> receiptOriginalName =
      GeneratedColumn<String>(
        'receipt_original_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _receiptMimeTypeMeta = const VerificationMeta(
    'receiptMimeType',
  );
  @override
  late final GeneratedColumn<String> receiptMimeType = GeneratedColumn<String>(
    'receipt_mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptUploadedAtMsMeta =
      const VerificationMeta('receiptUploadedAtMs');
  @override
  late final GeneratedColumn<int> receiptUploadedAtMs = GeneratedColumn<int>(
    'receipt_uploaded_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrStatusMeta = const VerificationMeta(
    'ocrStatus',
  );
  @override
  late final GeneratedColumn<String> ocrStatus = GeneratedColumn<String>(
    'ocr_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _ocrExtractedAmountMeta =
      const VerificationMeta('ocrExtractedAmount');
  @override
  late final GeneratedColumn<double> ocrExtractedAmount =
      GeneratedColumn<double>(
        'ocr_extracted_amount',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ocrRawTextMeta = const VerificationMeta(
    'ocrRawText',
  );
  @override
  late final GeneratedColumn<String> ocrRawText = GeneratedColumn<String>(
    'ocr_raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrProcessedAtMsMeta = const VerificationMeta(
    'ocrProcessedAtMs',
  );
  @override
  late final GeneratedColumn<int> ocrProcessedAtMs = GeneratedColumn<int>(
    'ocr_processed_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalProviderMeta = const VerificationMeta(
    'externalProvider',
  );
  @override
  late final GeneratedColumn<String> externalProvider = GeneratedColumn<String>(
    'external_provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalTransactionIdMeta =
      const VerificationMeta('externalTransactionId');
  @override
  late final GeneratedColumn<String> externalTransactionId =
      GeneratedColumn<String>(
        'external_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('COMPLETED'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    walletProvider,
    direction,
    amount,
    chargeAmount,
    totalAmount,
    balanceBefore,
    balanceAfter,
    chargeLowerBound,
    chargeUpperBound,
    chargeHandling,
    receiptImagePath,
    receiptOriginalName,
    receiptMimeType,
    receiptUploadedAtMs,
    ocrStatus,
    ocrExtractedAmount,
    ocrRawText,
    ocrProcessedAtMs,
    externalProvider,
    externalTransactionId,
    note,
    reference,
    entryDate,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('wallet_provider')) {
      context.handle(
        _walletProviderMeta,
        walletProvider.isAcceptableOrUnknown(
          data['wallet_provider']!,
          _walletProviderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_walletProviderMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('charge_amount')) {
      context.handle(
        _chargeAmountMeta,
        chargeAmount.isAcceptableOrUnknown(
          data['charge_amount']!,
          _chargeAmountMeta,
        ),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('balance_before')) {
      context.handle(
        _balanceBeforeMeta,
        balanceBefore.isAcceptableOrUnknown(
          data['balance_before']!,
          _balanceBeforeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceBeforeMeta);
    }
    if (data.containsKey('balance_after')) {
      context.handle(
        _balanceAfterMeta,
        balanceAfter.isAcceptableOrUnknown(
          data['balance_after']!,
          _balanceAfterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceAfterMeta);
    }
    if (data.containsKey('charge_lower_bound')) {
      context.handle(
        _chargeLowerBoundMeta,
        chargeLowerBound.isAcceptableOrUnknown(
          data['charge_lower_bound']!,
          _chargeLowerBoundMeta,
        ),
      );
    }
    if (data.containsKey('charge_upper_bound')) {
      context.handle(
        _chargeUpperBoundMeta,
        chargeUpperBound.isAcceptableOrUnknown(
          data['charge_upper_bound']!,
          _chargeUpperBoundMeta,
        ),
      );
    }
    if (data.containsKey('charge_handling')) {
      context.handle(
        _chargeHandlingMeta,
        chargeHandling.isAcceptableOrUnknown(
          data['charge_handling']!,
          _chargeHandlingMeta,
        ),
      );
    }
    if (data.containsKey('receipt_image_path')) {
      context.handle(
        _receiptImagePathMeta,
        receiptImagePath.isAcceptableOrUnknown(
          data['receipt_image_path']!,
          _receiptImagePathMeta,
        ),
      );
    }
    if (data.containsKey('receipt_original_name')) {
      context.handle(
        _receiptOriginalNameMeta,
        receiptOriginalName.isAcceptableOrUnknown(
          data['receipt_original_name']!,
          _receiptOriginalNameMeta,
        ),
      );
    }
    if (data.containsKey('receipt_mime_type')) {
      context.handle(
        _receiptMimeTypeMeta,
        receiptMimeType.isAcceptableOrUnknown(
          data['receipt_mime_type']!,
          _receiptMimeTypeMeta,
        ),
      );
    }
    if (data.containsKey('receipt_uploaded_at_ms')) {
      context.handle(
        _receiptUploadedAtMsMeta,
        receiptUploadedAtMs.isAcceptableOrUnknown(
          data['receipt_uploaded_at_ms']!,
          _receiptUploadedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('ocr_status')) {
      context.handle(
        _ocrStatusMeta,
        ocrStatus.isAcceptableOrUnknown(data['ocr_status']!, _ocrStatusMeta),
      );
    }
    if (data.containsKey('ocr_extracted_amount')) {
      context.handle(
        _ocrExtractedAmountMeta,
        ocrExtractedAmount.isAcceptableOrUnknown(
          data['ocr_extracted_amount']!,
          _ocrExtractedAmountMeta,
        ),
      );
    }
    if (data.containsKey('ocr_raw_text')) {
      context.handle(
        _ocrRawTextMeta,
        ocrRawText.isAcceptableOrUnknown(
          data['ocr_raw_text']!,
          _ocrRawTextMeta,
        ),
      );
    }
    if (data.containsKey('ocr_processed_at_ms')) {
      context.handle(
        _ocrProcessedAtMsMeta,
        ocrProcessedAtMs.isAcceptableOrUnknown(
          data['ocr_processed_at_ms']!,
          _ocrProcessedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('external_provider')) {
      context.handle(
        _externalProviderMeta,
        externalProvider.isAcceptableOrUnknown(
          data['external_provider']!,
          _externalProviderMeta,
        ),
      );
    }
    if (data.containsKey('external_transaction_id')) {
      context.handle(
        _externalTransactionIdMeta,
        externalTransactionId.isAcceptableOrUnknown(
          data['external_transaction_id']!,
          _externalTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      walletProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_provider'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      chargeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}charge_amount'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      balanceBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_before'],
      )!,
      balanceAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_after'],
      )!,
      chargeLowerBound: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}charge_lower_bound'],
      ),
      chargeUpperBound: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}charge_upper_bound'],
      ),
      chargeHandling: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}charge_handling'],
      )!,
      receiptImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_image_path'],
      ),
      receiptOriginalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_original_name'],
      ),
      receiptMimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_mime_type'],
      ),
      receiptUploadedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receipt_uploaded_at_ms'],
      ),
      ocrStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_status'],
      )!,
      ocrExtractedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ocr_extracted_amount'],
      ),
      ocrRawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_raw_text'],
      ),
      ocrProcessedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ocr_processed_at_ms'],
      ),
      externalProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_provider'],
      ),
      externalTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_transaction_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass with $TransactionsTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String walletProvider;
  @override
  final String direction;
  @override
  final double amount;
  @override
  final double chargeAmount;
  @override
  final double totalAmount;
  @override
  final double balanceBefore;
  @override
  final double balanceAfter;
  @override
  final double? chargeLowerBound;
  @override
  final double? chargeUpperBound;
  @override
  final String chargeHandling;
  @override
  final String? receiptImagePath;
  @override
  final String? receiptOriginalName;
  @override
  final String? receiptMimeType;
  @override
  final int? receiptUploadedAtMs;
  @override
  final String ocrStatus;
  @override
  final double? ocrExtractedAmount;
  @override
  final String? ocrRawText;
  @override
  final int? ocrProcessedAtMs;
  @override
  final String? externalProvider;
  @override
  final String? externalTransactionId;
  @override
  final String note;
  @override
  final String reference;
  @override
  final String entryDate;
  @override
  final String status;
  const TransactionRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.walletProvider,
    required this.direction,
    required this.amount,
    required this.chargeAmount,
    required this.totalAmount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.chargeLowerBound,
    this.chargeUpperBound,
    required this.chargeHandling,
    this.receiptImagePath,
    this.receiptOriginalName,
    this.receiptMimeType,
    this.receiptUploadedAtMs,
    required this.ocrStatus,
    this.ocrExtractedAmount,
    this.ocrRawText,
    this.ocrProcessedAtMs,
    this.externalProvider,
    this.externalTransactionId,
    required this.note,
    required this.reference,
    required this.entryDate,
    required this.status,
  });
  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      walletProvider: Value(walletProvider),
      direction: Value(direction),
      amount: Value(amount),
      chargeAmount: Value(chargeAmount),
      totalAmount: Value(totalAmount),
      balanceBefore: Value(balanceBefore),
      balanceAfter: Value(balanceAfter),
      chargeLowerBound: chargeLowerBound == null && nullToAbsent
          ? const Value.absent()
          : Value(chargeLowerBound),
      chargeUpperBound: chargeUpperBound == null && nullToAbsent
          ? const Value.absent()
          : Value(chargeUpperBound),
      chargeHandling: Value(chargeHandling),
      receiptImagePath: receiptImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptImagePath),
      receiptOriginalName: receiptOriginalName == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptOriginalName),
      receiptMimeType: receiptMimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptMimeType),
      receiptUploadedAtMs: receiptUploadedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptUploadedAtMs),
      ocrStatus: Value(ocrStatus),
      ocrExtractedAmount: ocrExtractedAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrExtractedAmount),
      ocrRawText: ocrRawText == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrRawText),
      ocrProcessedAtMs: ocrProcessedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrProcessedAtMs),
      externalProvider: externalProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(externalProvider),
      externalTransactionId: externalTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalTransactionId),
      note: Value(note),
      reference: Value(reference),
      entryDate: Value(entryDate),
      status: Value(status),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      walletProvider: serializer.fromJson<String>(json['walletProvider']),
      direction: serializer.fromJson<String>(json['direction']),
      amount: serializer.fromJson<double>(json['amount']),
      chargeAmount: serializer.fromJson<double>(json['chargeAmount']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      balanceBefore: serializer.fromJson<double>(json['balanceBefore']),
      balanceAfter: serializer.fromJson<double>(json['balanceAfter']),
      chargeLowerBound: serializer.fromJson<double?>(json['chargeLowerBound']),
      chargeUpperBound: serializer.fromJson<double?>(json['chargeUpperBound']),
      chargeHandling: serializer.fromJson<String>(json['chargeHandling']),
      receiptImagePath: serializer.fromJson<String?>(json['receiptImagePath']),
      receiptOriginalName: serializer.fromJson<String?>(
        json['receiptOriginalName'],
      ),
      receiptMimeType: serializer.fromJson<String?>(json['receiptMimeType']),
      receiptUploadedAtMs: serializer.fromJson<int?>(
        json['receiptUploadedAtMs'],
      ),
      ocrStatus: serializer.fromJson<String>(json['ocrStatus']),
      ocrExtractedAmount: serializer.fromJson<double?>(
        json['ocrExtractedAmount'],
      ),
      ocrRawText: serializer.fromJson<String?>(json['ocrRawText']),
      ocrProcessedAtMs: serializer.fromJson<int?>(json['ocrProcessedAtMs']),
      externalProvider: serializer.fromJson<String?>(json['externalProvider']),
      externalTransactionId: serializer.fromJson<String?>(
        json['externalTransactionId'],
      ),
      note: serializer.fromJson<String>(json['note']),
      reference: serializer.fromJson<String>(json['reference']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'walletProvider': serializer.toJson<String>(walletProvider),
      'direction': serializer.toJson<String>(direction),
      'amount': serializer.toJson<double>(amount),
      'chargeAmount': serializer.toJson<double>(chargeAmount),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'balanceBefore': serializer.toJson<double>(balanceBefore),
      'balanceAfter': serializer.toJson<double>(balanceAfter),
      'chargeLowerBound': serializer.toJson<double?>(chargeLowerBound),
      'chargeUpperBound': serializer.toJson<double?>(chargeUpperBound),
      'chargeHandling': serializer.toJson<String>(chargeHandling),
      'receiptImagePath': serializer.toJson<String?>(receiptImagePath),
      'receiptOriginalName': serializer.toJson<String?>(receiptOriginalName),
      'receiptMimeType': serializer.toJson<String?>(receiptMimeType),
      'receiptUploadedAtMs': serializer.toJson<int?>(receiptUploadedAtMs),
      'ocrStatus': serializer.toJson<String>(ocrStatus),
      'ocrExtractedAmount': serializer.toJson<double?>(ocrExtractedAmount),
      'ocrRawText': serializer.toJson<String?>(ocrRawText),
      'ocrProcessedAtMs': serializer.toJson<int?>(ocrProcessedAtMs),
      'externalProvider': serializer.toJson<String?>(externalProvider),
      'externalTransactionId': serializer.toJson<String?>(
        externalTransactionId,
      ),
      'note': serializer.toJson<String>(note),
      'reference': serializer.toJson<String>(reference),
      'entryDate': serializer.toJson<String>(entryDate),
      'status': serializer.toJson<String>(status),
    };
  }

  TransactionRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? walletProvider,
    String? direction,
    double? amount,
    double? chargeAmount,
    double? totalAmount,
    double? balanceBefore,
    double? balanceAfter,
    Value<double?> chargeLowerBound = const Value.absent(),
    Value<double?> chargeUpperBound = const Value.absent(),
    String? chargeHandling,
    Value<String?> receiptImagePath = const Value.absent(),
    Value<String?> receiptOriginalName = const Value.absent(),
    Value<String?> receiptMimeType = const Value.absent(),
    Value<int?> receiptUploadedAtMs = const Value.absent(),
    String? ocrStatus,
    Value<double?> ocrExtractedAmount = const Value.absent(),
    Value<String?> ocrRawText = const Value.absent(),
    Value<int?> ocrProcessedAtMs = const Value.absent(),
    Value<String?> externalProvider = const Value.absent(),
    Value<String?> externalTransactionId = const Value.absent(),
    String? note,
    String? reference,
    String? entryDate,
    String? status,
  }) => TransactionRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    walletProvider: walletProvider ?? this.walletProvider,
    direction: direction ?? this.direction,
    amount: amount ?? this.amount,
    chargeAmount: chargeAmount ?? this.chargeAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    balanceBefore: balanceBefore ?? this.balanceBefore,
    balanceAfter: balanceAfter ?? this.balanceAfter,
    chargeLowerBound: chargeLowerBound.present
        ? chargeLowerBound.value
        : this.chargeLowerBound,
    chargeUpperBound: chargeUpperBound.present
        ? chargeUpperBound.value
        : this.chargeUpperBound,
    chargeHandling: chargeHandling ?? this.chargeHandling,
    receiptImagePath: receiptImagePath.present
        ? receiptImagePath.value
        : this.receiptImagePath,
    receiptOriginalName: receiptOriginalName.present
        ? receiptOriginalName.value
        : this.receiptOriginalName,
    receiptMimeType: receiptMimeType.present
        ? receiptMimeType.value
        : this.receiptMimeType,
    receiptUploadedAtMs: receiptUploadedAtMs.present
        ? receiptUploadedAtMs.value
        : this.receiptUploadedAtMs,
    ocrStatus: ocrStatus ?? this.ocrStatus,
    ocrExtractedAmount: ocrExtractedAmount.present
        ? ocrExtractedAmount.value
        : this.ocrExtractedAmount,
    ocrRawText: ocrRawText.present ? ocrRawText.value : this.ocrRawText,
    ocrProcessedAtMs: ocrProcessedAtMs.present
        ? ocrProcessedAtMs.value
        : this.ocrProcessedAtMs,
    externalProvider: externalProvider.present
        ? externalProvider.value
        : this.externalProvider,
    externalTransactionId: externalTransactionId.present
        ? externalTransactionId.value
        : this.externalTransactionId,
    note: note ?? this.note,
    reference: reference ?? this.reference,
    entryDate: entryDate ?? this.entryDate,
    status: status ?? this.status,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      walletProvider: data.walletProvider.present
          ? data.walletProvider.value
          : this.walletProvider,
      direction: data.direction.present ? data.direction.value : this.direction,
      amount: data.amount.present ? data.amount.value : this.amount,
      chargeAmount: data.chargeAmount.present
          ? data.chargeAmount.value
          : this.chargeAmount,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      balanceBefore: data.balanceBefore.present
          ? data.balanceBefore.value
          : this.balanceBefore,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      chargeLowerBound: data.chargeLowerBound.present
          ? data.chargeLowerBound.value
          : this.chargeLowerBound,
      chargeUpperBound: data.chargeUpperBound.present
          ? data.chargeUpperBound.value
          : this.chargeUpperBound,
      chargeHandling: data.chargeHandling.present
          ? data.chargeHandling.value
          : this.chargeHandling,
      receiptImagePath: data.receiptImagePath.present
          ? data.receiptImagePath.value
          : this.receiptImagePath,
      receiptOriginalName: data.receiptOriginalName.present
          ? data.receiptOriginalName.value
          : this.receiptOriginalName,
      receiptMimeType: data.receiptMimeType.present
          ? data.receiptMimeType.value
          : this.receiptMimeType,
      receiptUploadedAtMs: data.receiptUploadedAtMs.present
          ? data.receiptUploadedAtMs.value
          : this.receiptUploadedAtMs,
      ocrStatus: data.ocrStatus.present ? data.ocrStatus.value : this.ocrStatus,
      ocrExtractedAmount: data.ocrExtractedAmount.present
          ? data.ocrExtractedAmount.value
          : this.ocrExtractedAmount,
      ocrRawText: data.ocrRawText.present
          ? data.ocrRawText.value
          : this.ocrRawText,
      ocrProcessedAtMs: data.ocrProcessedAtMs.present
          ? data.ocrProcessedAtMs.value
          : this.ocrProcessedAtMs,
      externalProvider: data.externalProvider.present
          ? data.externalProvider.value
          : this.externalProvider,
      externalTransactionId: data.externalTransactionId.present
          ? data.externalTransactionId.value
          : this.externalTransactionId,
      note: data.note.present ? data.note.value : this.note,
      reference: data.reference.present ? data.reference.value : this.reference,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('walletProvider: $walletProvider, ')
          ..write('direction: $direction, ')
          ..write('amount: $amount, ')
          ..write('chargeAmount: $chargeAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('balanceBefore: $balanceBefore, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('chargeLowerBound: $chargeLowerBound, ')
          ..write('chargeUpperBound: $chargeUpperBound, ')
          ..write('chargeHandling: $chargeHandling, ')
          ..write('receiptImagePath: $receiptImagePath, ')
          ..write('receiptOriginalName: $receiptOriginalName, ')
          ..write('receiptMimeType: $receiptMimeType, ')
          ..write('receiptUploadedAtMs: $receiptUploadedAtMs, ')
          ..write('ocrStatus: $ocrStatus, ')
          ..write('ocrExtractedAmount: $ocrExtractedAmount, ')
          ..write('ocrRawText: $ocrRawText, ')
          ..write('ocrProcessedAtMs: $ocrProcessedAtMs, ')
          ..write('externalProvider: $externalProvider, ')
          ..write('externalTransactionId: $externalTransactionId, ')
          ..write('note: $note, ')
          ..write('reference: $reference, ')
          ..write('entryDate: $entryDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    walletProvider,
    direction,
    amount,
    chargeAmount,
    totalAmount,
    balanceBefore,
    balanceAfter,
    chargeLowerBound,
    chargeUpperBound,
    chargeHandling,
    receiptImagePath,
    receiptOriginalName,
    receiptMimeType,
    receiptUploadedAtMs,
    ocrStatus,
    ocrExtractedAmount,
    ocrRawText,
    ocrProcessedAtMs,
    externalProvider,
    externalTransactionId,
    note,
    reference,
    entryDate,
    status,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.walletProvider == this.walletProvider &&
          other.direction == this.direction &&
          other.amount == this.amount &&
          other.chargeAmount == this.chargeAmount &&
          other.totalAmount == this.totalAmount &&
          other.balanceBefore == this.balanceBefore &&
          other.balanceAfter == this.balanceAfter &&
          other.chargeLowerBound == this.chargeLowerBound &&
          other.chargeUpperBound == this.chargeUpperBound &&
          other.chargeHandling == this.chargeHandling &&
          other.receiptImagePath == this.receiptImagePath &&
          other.receiptOriginalName == this.receiptOriginalName &&
          other.receiptMimeType == this.receiptMimeType &&
          other.receiptUploadedAtMs == this.receiptUploadedAtMs &&
          other.ocrStatus == this.ocrStatus &&
          other.ocrExtractedAmount == this.ocrExtractedAmount &&
          other.ocrRawText == this.ocrRawText &&
          other.ocrProcessedAtMs == this.ocrProcessedAtMs &&
          other.externalProvider == this.externalProvider &&
          other.externalTransactionId == this.externalTransactionId &&
          other.note == this.note &&
          other.reference == this.reference &&
          other.entryDate == this.entryDate &&
          other.status == this.status);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> walletProvider;
  final Value<String> direction;
  final Value<double> amount;
  final Value<double> chargeAmount;
  final Value<double> totalAmount;
  final Value<double> balanceBefore;
  final Value<double> balanceAfter;
  final Value<double?> chargeLowerBound;
  final Value<double?> chargeUpperBound;
  final Value<String> chargeHandling;
  final Value<String?> receiptImagePath;
  final Value<String?> receiptOriginalName;
  final Value<String?> receiptMimeType;
  final Value<int?> receiptUploadedAtMs;
  final Value<String> ocrStatus;
  final Value<double?> ocrExtractedAmount;
  final Value<String?> ocrRawText;
  final Value<int?> ocrProcessedAtMs;
  final Value<String?> externalProvider;
  final Value<String?> externalTransactionId;
  final Value<String> note;
  final Value<String> reference;
  final Value<String> entryDate;
  final Value<String> status;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.walletProvider = const Value.absent(),
    this.direction = const Value.absent(),
    this.amount = const Value.absent(),
    this.chargeAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.balanceBefore = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.chargeLowerBound = const Value.absent(),
    this.chargeUpperBound = const Value.absent(),
    this.chargeHandling = const Value.absent(),
    this.receiptImagePath = const Value.absent(),
    this.receiptOriginalName = const Value.absent(),
    this.receiptMimeType = const Value.absent(),
    this.receiptUploadedAtMs = const Value.absent(),
    this.ocrStatus = const Value.absent(),
    this.ocrExtractedAmount = const Value.absent(),
    this.ocrRawText = const Value.absent(),
    this.ocrProcessedAtMs = const Value.absent(),
    this.externalProvider = const Value.absent(),
    this.externalTransactionId = const Value.absent(),
    this.note = const Value.absent(),
    this.reference = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String walletProvider,
    required String direction,
    required double amount,
    this.chargeAmount = const Value.absent(),
    required double totalAmount,
    required double balanceBefore,
    required double balanceAfter,
    this.chargeLowerBound = const Value.absent(),
    this.chargeUpperBound = const Value.absent(),
    this.chargeHandling = const Value.absent(),
    this.receiptImagePath = const Value.absent(),
    this.receiptOriginalName = const Value.absent(),
    this.receiptMimeType = const Value.absent(),
    this.receiptUploadedAtMs = const Value.absent(),
    this.ocrStatus = const Value.absent(),
    this.ocrExtractedAmount = const Value.absent(),
    this.ocrRawText = const Value.absent(),
    this.ocrProcessedAtMs = const Value.absent(),
    this.externalProvider = const Value.absent(),
    this.externalTransactionId = const Value.absent(),
    this.note = const Value.absent(),
    this.reference = const Value.absent(),
    required String entryDate,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       walletProvider = Value(walletProvider),
       direction = Value(direction),
       amount = Value(amount),
       totalAmount = Value(totalAmount),
       balanceBefore = Value(balanceBefore),
       balanceAfter = Value(balanceAfter),
       entryDate = Value(entryDate);
  static Insertable<TransactionRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? walletProvider,
    Expression<String>? direction,
    Expression<double>? amount,
    Expression<double>? chargeAmount,
    Expression<double>? totalAmount,
    Expression<double>? balanceBefore,
    Expression<double>? balanceAfter,
    Expression<double>? chargeLowerBound,
    Expression<double>? chargeUpperBound,
    Expression<String>? chargeHandling,
    Expression<String>? receiptImagePath,
    Expression<String>? receiptOriginalName,
    Expression<String>? receiptMimeType,
    Expression<int>? receiptUploadedAtMs,
    Expression<String>? ocrStatus,
    Expression<double>? ocrExtractedAmount,
    Expression<String>? ocrRawText,
    Expression<int>? ocrProcessedAtMs,
    Expression<String>? externalProvider,
    Expression<String>? externalTransactionId,
    Expression<String>? note,
    Expression<String>? reference,
    Expression<String>? entryDate,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (walletProvider != null) 'wallet_provider': walletProvider,
      if (direction != null) 'direction': direction,
      if (amount != null) 'amount': amount,
      if (chargeAmount != null) 'charge_amount': chargeAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (balanceBefore != null) 'balance_before': balanceBefore,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (chargeLowerBound != null) 'charge_lower_bound': chargeLowerBound,
      if (chargeUpperBound != null) 'charge_upper_bound': chargeUpperBound,
      if (chargeHandling != null) 'charge_handling': chargeHandling,
      if (receiptImagePath != null) 'receipt_image_path': receiptImagePath,
      if (receiptOriginalName != null)
        'receipt_original_name': receiptOriginalName,
      if (receiptMimeType != null) 'receipt_mime_type': receiptMimeType,
      if (receiptUploadedAtMs != null)
        'receipt_uploaded_at_ms': receiptUploadedAtMs,
      if (ocrStatus != null) 'ocr_status': ocrStatus,
      if (ocrExtractedAmount != null)
        'ocr_extracted_amount': ocrExtractedAmount,
      if (ocrRawText != null) 'ocr_raw_text': ocrRawText,
      if (ocrProcessedAtMs != null) 'ocr_processed_at_ms': ocrProcessedAtMs,
      if (externalProvider != null) 'external_provider': externalProvider,
      if (externalTransactionId != null)
        'external_transaction_id': externalTransactionId,
      if (note != null) 'note': note,
      if (reference != null) 'reference': reference,
      if (entryDate != null) 'entry_date': entryDate,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? walletProvider,
    Value<String>? direction,
    Value<double>? amount,
    Value<double>? chargeAmount,
    Value<double>? totalAmount,
    Value<double>? balanceBefore,
    Value<double>? balanceAfter,
    Value<double?>? chargeLowerBound,
    Value<double?>? chargeUpperBound,
    Value<String>? chargeHandling,
    Value<String?>? receiptImagePath,
    Value<String?>? receiptOriginalName,
    Value<String?>? receiptMimeType,
    Value<int?>? receiptUploadedAtMs,
    Value<String>? ocrStatus,
    Value<double?>? ocrExtractedAmount,
    Value<String?>? ocrRawText,
    Value<int?>? ocrProcessedAtMs,
    Value<String?>? externalProvider,
    Value<String?>? externalTransactionId,
    Value<String>? note,
    Value<String>? reference,
    Value<String>? entryDate,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      walletProvider: walletProvider ?? this.walletProvider,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      chargeAmount: chargeAmount ?? this.chargeAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      balanceBefore: balanceBefore ?? this.balanceBefore,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      chargeLowerBound: chargeLowerBound ?? this.chargeLowerBound,
      chargeUpperBound: chargeUpperBound ?? this.chargeUpperBound,
      chargeHandling: chargeHandling ?? this.chargeHandling,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      receiptOriginalName: receiptOriginalName ?? this.receiptOriginalName,
      receiptMimeType: receiptMimeType ?? this.receiptMimeType,
      receiptUploadedAtMs: receiptUploadedAtMs ?? this.receiptUploadedAtMs,
      ocrStatus: ocrStatus ?? this.ocrStatus,
      ocrExtractedAmount: ocrExtractedAmount ?? this.ocrExtractedAmount,
      ocrRawText: ocrRawText ?? this.ocrRawText,
      ocrProcessedAtMs: ocrProcessedAtMs ?? this.ocrProcessedAtMs,
      externalProvider: externalProvider ?? this.externalProvider,
      externalTransactionId:
          externalTransactionId ?? this.externalTransactionId,
      note: note ?? this.note,
      reference: reference ?? this.reference,
      entryDate: entryDate ?? this.entryDate,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (walletProvider.present) {
      map['wallet_provider'] = Variable<String>(walletProvider.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (chargeAmount.present) {
      map['charge_amount'] = Variable<double>(chargeAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (balanceBefore.present) {
      map['balance_before'] = Variable<double>(balanceBefore.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<double>(balanceAfter.value);
    }
    if (chargeLowerBound.present) {
      map['charge_lower_bound'] = Variable<double>(chargeLowerBound.value);
    }
    if (chargeUpperBound.present) {
      map['charge_upper_bound'] = Variable<double>(chargeUpperBound.value);
    }
    if (chargeHandling.present) {
      map['charge_handling'] = Variable<String>(chargeHandling.value);
    }
    if (receiptImagePath.present) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath.value);
    }
    if (receiptOriginalName.present) {
      map['receipt_original_name'] = Variable<String>(
        receiptOriginalName.value,
      );
    }
    if (receiptMimeType.present) {
      map['receipt_mime_type'] = Variable<String>(receiptMimeType.value);
    }
    if (receiptUploadedAtMs.present) {
      map['receipt_uploaded_at_ms'] = Variable<int>(receiptUploadedAtMs.value);
    }
    if (ocrStatus.present) {
      map['ocr_status'] = Variable<String>(ocrStatus.value);
    }
    if (ocrExtractedAmount.present) {
      map['ocr_extracted_amount'] = Variable<double>(ocrExtractedAmount.value);
    }
    if (ocrRawText.present) {
      map['ocr_raw_text'] = Variable<String>(ocrRawText.value);
    }
    if (ocrProcessedAtMs.present) {
      map['ocr_processed_at_ms'] = Variable<int>(ocrProcessedAtMs.value);
    }
    if (externalProvider.present) {
      map['external_provider'] = Variable<String>(externalProvider.value);
    }
    if (externalTransactionId.present) {
      map['external_transaction_id'] = Variable<String>(
        externalTransactionId.value,
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('walletProvider: $walletProvider, ')
          ..write('direction: $direction, ')
          ..write('amount: $amount, ')
          ..write('chargeAmount: $chargeAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('balanceBefore: $balanceBefore, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('chargeLowerBound: $chargeLowerBound, ')
          ..write('chargeUpperBound: $chargeUpperBound, ')
          ..write('chargeHandling: $chargeHandling, ')
          ..write('receiptImagePath: $receiptImagePath, ')
          ..write('receiptOriginalName: $receiptOriginalName, ')
          ..write('receiptMimeType: $receiptMimeType, ')
          ..write('receiptUploadedAtMs: $receiptUploadedAtMs, ')
          ..write('ocrStatus: $ocrStatus, ')
          ..write('ocrExtractedAmount: $ocrExtractedAmount, ')
          ..write('ocrRawText: $ocrRawText, ')
          ..write('ocrProcessedAtMs: $ocrProcessedAtMs, ')
          ..write('externalProvider: $externalProvider, ')
          ..write('externalTransactionId: $externalTransactionId, ')
          ..write('note: $note, ')
          ..write('reference: $reference, ')
          ..write('entryDate: $entryDate, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $FeeTransactionsTableToColumns implements Insertable<FeeTransactionRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String? get relatedTransactionSyncId;
  double get feeAmount;
  String get feeType;
  String get chargeDestination;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || relatedTransactionSyncId != null) {
      map['related_transaction_sync_id'] = Variable<String>(
        relatedTransactionSyncId,
      );
    }
    map['fee_amount'] = Variable<double>(feeAmount);
    map['fee_type'] = Variable<String>(feeType);
    map['charge_destination'] = Variable<String>(chargeDestination);
    return map;
  }
}

class $FeeTransactionsTable extends FeeTransactions
    with TableInfo<$FeeTransactionsTable, FeeTransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeeTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relatedTransactionSyncIdMeta =
      const VerificationMeta('relatedTransactionSyncId');
  @override
  late final GeneratedColumn<String> relatedTransactionSyncId =
      GeneratedColumn<String>(
        'related_transaction_sync_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _feeAmountMeta = const VerificationMeta(
    'feeAmount',
  );
  @override
  late final GeneratedColumn<double> feeAmount = GeneratedColumn<double>(
    'fee_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feeTypeMeta = const VerificationMeta(
    'feeType',
  );
  @override
  late final GeneratedColumn<String> feeType = GeneratedColumn<String>(
    'fee_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chargeDestinationMeta = const VerificationMeta(
    'chargeDestination',
  );
  @override
  late final GeneratedColumn<String> chargeDestination =
      GeneratedColumn<String>(
        'charge_destination',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    relatedTransactionSyncId,
    feeAmount,
    feeType,
    chargeDestination,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fee_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeeTransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('related_transaction_sync_id')) {
      context.handle(
        _relatedTransactionSyncIdMeta,
        relatedTransactionSyncId.isAcceptableOrUnknown(
          data['related_transaction_sync_id']!,
          _relatedTransactionSyncIdMeta,
        ),
      );
    }
    if (data.containsKey('fee_amount')) {
      context.handle(
        _feeAmountMeta,
        feeAmount.isAcceptableOrUnknown(data['fee_amount']!, _feeAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_feeAmountMeta);
    }
    if (data.containsKey('fee_type')) {
      context.handle(
        _feeTypeMeta,
        feeType.isAcceptableOrUnknown(data['fee_type']!, _feeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_feeTypeMeta);
    }
    if (data.containsKey('charge_destination')) {
      context.handle(
        _chargeDestinationMeta,
        chargeDestination.isAcceptableOrUnknown(
          data['charge_destination']!,
          _chargeDestinationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chargeDestinationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeeTransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeeTransactionRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      relatedTransactionSyncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_transaction_sync_id'],
      ),
      feeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fee_amount'],
      )!,
      feeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fee_type'],
      )!,
      chargeDestination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}charge_destination'],
      )!,
    );
  }

  @override
  $FeeTransactionsTable createAlias(String alias) {
    return $FeeTransactionsTable(attachedDatabase, alias);
  }
}

class FeeTransactionRow extends DataClass with $FeeTransactionsTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String? relatedTransactionSyncId;
  @override
  final double feeAmount;
  @override
  final String feeType;
  @override
  final String chargeDestination;
  const FeeTransactionRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    this.relatedTransactionSyncId,
    required this.feeAmount,
    required this.feeType,
    required this.chargeDestination,
  });
  FeeTransactionsCompanion toCompanion(bool nullToAbsent) {
    return FeeTransactionsCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      relatedTransactionSyncId: relatedTransactionSyncId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedTransactionSyncId),
      feeAmount: Value(feeAmount),
      feeType: Value(feeType),
      chargeDestination: Value(chargeDestination),
    );
  }

  factory FeeTransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeeTransactionRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      relatedTransactionSyncId: serializer.fromJson<String?>(
        json['relatedTransactionSyncId'],
      ),
      feeAmount: serializer.fromJson<double>(json['feeAmount']),
      feeType: serializer.fromJson<String>(json['feeType']),
      chargeDestination: serializer.fromJson<String>(json['chargeDestination']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'relatedTransactionSyncId': serializer.toJson<String?>(
        relatedTransactionSyncId,
      ),
      'feeAmount': serializer.toJson<double>(feeAmount),
      'feeType': serializer.toJson<String>(feeType),
      'chargeDestination': serializer.toJson<String>(chargeDestination),
    };
  }

  FeeTransactionRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    Value<String?> relatedTransactionSyncId = const Value.absent(),
    double? feeAmount,
    String? feeType,
    String? chargeDestination,
  }) => FeeTransactionRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    relatedTransactionSyncId: relatedTransactionSyncId.present
        ? relatedTransactionSyncId.value
        : this.relatedTransactionSyncId,
    feeAmount: feeAmount ?? this.feeAmount,
    feeType: feeType ?? this.feeType,
    chargeDestination: chargeDestination ?? this.chargeDestination,
  );
  FeeTransactionRow copyWithCompanion(FeeTransactionsCompanion data) {
    return FeeTransactionRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      relatedTransactionSyncId: data.relatedTransactionSyncId.present
          ? data.relatedTransactionSyncId.value
          : this.relatedTransactionSyncId,
      feeAmount: data.feeAmount.present ? data.feeAmount.value : this.feeAmount,
      feeType: data.feeType.present ? data.feeType.value : this.feeType,
      chargeDestination: data.chargeDestination.present
          ? data.chargeDestination.value
          : this.chargeDestination,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeeTransactionRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('relatedTransactionSyncId: $relatedTransactionSyncId, ')
          ..write('feeAmount: $feeAmount, ')
          ..write('feeType: $feeType, ')
          ..write('chargeDestination: $chargeDestination')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    relatedTransactionSyncId,
    feeAmount,
    feeType,
    chargeDestination,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeeTransactionRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.relatedTransactionSyncId == this.relatedTransactionSyncId &&
          other.feeAmount == this.feeAmount &&
          other.feeType == this.feeType &&
          other.chargeDestination == this.chargeDestination);
}

class FeeTransactionsCompanion extends UpdateCompanion<FeeTransactionRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String?> relatedTransactionSyncId;
  final Value<double> feeAmount;
  final Value<String> feeType;
  final Value<String> chargeDestination;
  final Value<int> rowid;
  const FeeTransactionsCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.relatedTransactionSyncId = const Value.absent(),
    this.feeAmount = const Value.absent(),
    this.feeType = const Value.absent(),
    this.chargeDestination = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeeTransactionsCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    this.relatedTransactionSyncId = const Value.absent(),
    required double feeAmount,
    required String feeType,
    required String chargeDestination,
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       feeAmount = Value(feeAmount),
       feeType = Value(feeType),
       chargeDestination = Value(chargeDestination);
  static Insertable<FeeTransactionRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? relatedTransactionSyncId,
    Expression<double>? feeAmount,
    Expression<String>? feeType,
    Expression<String>? chargeDestination,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (relatedTransactionSyncId != null)
        'related_transaction_sync_id': relatedTransactionSyncId,
      if (feeAmount != null) 'fee_amount': feeAmount,
      if (feeType != null) 'fee_type': feeType,
      if (chargeDestination != null) 'charge_destination': chargeDestination,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeeTransactionsCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String?>? relatedTransactionSyncId,
    Value<double>? feeAmount,
    Value<String>? feeType,
    Value<String>? chargeDestination,
    Value<int>? rowid,
  }) {
    return FeeTransactionsCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      relatedTransactionSyncId:
          relatedTransactionSyncId ?? this.relatedTransactionSyncId,
      feeAmount: feeAmount ?? this.feeAmount,
      feeType: feeType ?? this.feeType,
      chargeDestination: chargeDestination ?? this.chargeDestination,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (relatedTransactionSyncId.present) {
      map['related_transaction_sync_id'] = Variable<String>(
        relatedTransactionSyncId.value,
      );
    }
    if (feeAmount.present) {
      map['fee_amount'] = Variable<double>(feeAmount.value);
    }
    if (feeType.present) {
      map['fee_type'] = Variable<String>(feeType.value);
    }
    if (chargeDestination.present) {
      map['charge_destination'] = Variable<String>(chargeDestination.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeeTransactionsCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('relatedTransactionSyncId: $relatedTransactionSyncId, ')
          ..write('feeAmount: $feeAmount, ')
          ..write('feeType: $feeType, ')
          ..write('chargeDestination: $chargeDestination, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $MonitoringSessionsTableToColumns
    implements Insertable<MonitoringSessionRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get name;
  String get status;
  int get startDateMs;
  int? get endDateMs;
  double get startGcash;
  double get startMaya;
  double get startOnHand;
  double? get endGcash;
  double? get endMaya;
  double? get endOnHand;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['status'] = Variable<String>(status);
    map['start_date_ms'] = Variable<int>(startDateMs);
    if (!nullToAbsent || endDateMs != null) {
      map['end_date_ms'] = Variable<int>(endDateMs);
    }
    map['start_gcash'] = Variable<double>(startGcash);
    map['start_maya'] = Variable<double>(startMaya);
    map['start_on_hand'] = Variable<double>(startOnHand);
    if (!nullToAbsent || endGcash != null) {
      map['end_gcash'] = Variable<double>(endGcash);
    }
    if (!nullToAbsent || endMaya != null) {
      map['end_maya'] = Variable<double>(endMaya);
    }
    if (!nullToAbsent || endOnHand != null) {
      map['end_on_hand'] = Variable<double>(endOnHand);
    }
    return map;
  }
}

class $MonitoringSessionsTable extends MonitoringSessions
    with TableInfo<$MonitoringSessionsTable, MonitoringSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonitoringSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVE'),
  );
  static const VerificationMeta _startDateMsMeta = const VerificationMeta(
    'startDateMs',
  );
  @override
  late final GeneratedColumn<int> startDateMs = GeneratedColumn<int>(
    'start_date_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMsMeta = const VerificationMeta(
    'endDateMs',
  );
  @override
  late final GeneratedColumn<int> endDateMs = GeneratedColumn<int>(
    'end_date_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startGcashMeta = const VerificationMeta(
    'startGcash',
  );
  @override
  late final GeneratedColumn<double> startGcash = GeneratedColumn<double>(
    'start_gcash',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startMayaMeta = const VerificationMeta(
    'startMaya',
  );
  @override
  late final GeneratedColumn<double> startMaya = GeneratedColumn<double>(
    'start_maya',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startOnHandMeta = const VerificationMeta(
    'startOnHand',
  );
  @override
  late final GeneratedColumn<double> startOnHand = GeneratedColumn<double>(
    'start_on_hand',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _endGcashMeta = const VerificationMeta(
    'endGcash',
  );
  @override
  late final GeneratedColumn<double> endGcash = GeneratedColumn<double>(
    'end_gcash',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMayaMeta = const VerificationMeta(
    'endMaya',
  );
  @override
  late final GeneratedColumn<double> endMaya = GeneratedColumn<double>(
    'end_maya',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endOnHandMeta = const VerificationMeta(
    'endOnHand',
  );
  @override
  late final GeneratedColumn<double> endOnHand = GeneratedColumn<double>(
    'end_on_hand',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    status,
    startDateMs,
    endDateMs,
    startGcash,
    startMaya,
    startOnHand,
    endGcash,
    endMaya,
    endOnHand,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monitoring_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonitoringSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('start_date_ms')) {
      context.handle(
        _startDateMsMeta,
        startDateMs.isAcceptableOrUnknown(
          data['start_date_ms']!,
          _startDateMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startDateMsMeta);
    }
    if (data.containsKey('end_date_ms')) {
      context.handle(
        _endDateMsMeta,
        endDateMs.isAcceptableOrUnknown(data['end_date_ms']!, _endDateMsMeta),
      );
    }
    if (data.containsKey('start_gcash')) {
      context.handle(
        _startGcashMeta,
        startGcash.isAcceptableOrUnknown(data['start_gcash']!, _startGcashMeta),
      );
    }
    if (data.containsKey('start_maya')) {
      context.handle(
        _startMayaMeta,
        startMaya.isAcceptableOrUnknown(data['start_maya']!, _startMayaMeta),
      );
    }
    if (data.containsKey('start_on_hand')) {
      context.handle(
        _startOnHandMeta,
        startOnHand.isAcceptableOrUnknown(
          data['start_on_hand']!,
          _startOnHandMeta,
        ),
      );
    }
    if (data.containsKey('end_gcash')) {
      context.handle(
        _endGcashMeta,
        endGcash.isAcceptableOrUnknown(data['end_gcash']!, _endGcashMeta),
      );
    }
    if (data.containsKey('end_maya')) {
      context.handle(
        _endMayaMeta,
        endMaya.isAcceptableOrUnknown(data['end_maya']!, _endMayaMeta),
      );
    }
    if (data.containsKey('end_on_hand')) {
      context.handle(
        _endOnHandMeta,
        endOnHand.isAcceptableOrUnknown(data['end_on_hand']!, _endOnHandMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MonitoringSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonitoringSessionRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startDateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_date_ms'],
      )!,
      endDateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_date_ms'],
      ),
      startGcash: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_gcash'],
      )!,
      startMaya: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_maya'],
      )!,
      startOnHand: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_on_hand'],
      )!,
      endGcash: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_gcash'],
      ),
      endMaya: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_maya'],
      ),
      endOnHand: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_on_hand'],
      ),
    );
  }

  @override
  $MonitoringSessionsTable createAlias(String alias) {
    return $MonitoringSessionsTable(attachedDatabase, alias);
  }
}

class MonitoringSessionRow extends DataClass
    with $MonitoringSessionsTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String name;
  @override
  final String status;
  @override
  final int startDateMs;
  @override
  final int? endDateMs;
  @override
  final double startGcash;
  @override
  final double startMaya;
  @override
  final double startOnHand;
  @override
  final double? endGcash;
  @override
  final double? endMaya;
  @override
  final double? endOnHand;
  const MonitoringSessionRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.name,
    required this.status,
    required this.startDateMs,
    this.endDateMs,
    required this.startGcash,
    required this.startMaya,
    required this.startOnHand,
    this.endGcash,
    this.endMaya,
    this.endOnHand,
  });
  MonitoringSessionsCompanion toCompanion(bool nullToAbsent) {
    return MonitoringSessionsCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      name: Value(name),
      status: Value(status),
      startDateMs: Value(startDateMs),
      endDateMs: endDateMs == null && nullToAbsent
          ? const Value.absent()
          : Value(endDateMs),
      startGcash: Value(startGcash),
      startMaya: Value(startMaya),
      startOnHand: Value(startOnHand),
      endGcash: endGcash == null && nullToAbsent
          ? const Value.absent()
          : Value(endGcash),
      endMaya: endMaya == null && nullToAbsent
          ? const Value.absent()
          : Value(endMaya),
      endOnHand: endOnHand == null && nullToAbsent
          ? const Value.absent()
          : Value(endOnHand),
    );
  }

  factory MonitoringSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonitoringSessionRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      status: serializer.fromJson<String>(json['status']),
      startDateMs: serializer.fromJson<int>(json['startDateMs']),
      endDateMs: serializer.fromJson<int?>(json['endDateMs']),
      startGcash: serializer.fromJson<double>(json['startGcash']),
      startMaya: serializer.fromJson<double>(json['startMaya']),
      startOnHand: serializer.fromJson<double>(json['startOnHand']),
      endGcash: serializer.fromJson<double?>(json['endGcash']),
      endMaya: serializer.fromJson<double?>(json['endMaya']),
      endOnHand: serializer.fromJson<double?>(json['endOnHand']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(status),
      'startDateMs': serializer.toJson<int>(startDateMs),
      'endDateMs': serializer.toJson<int?>(endDateMs),
      'startGcash': serializer.toJson<double>(startGcash),
      'startMaya': serializer.toJson<double>(startMaya),
      'startOnHand': serializer.toJson<double>(startOnHand),
      'endGcash': serializer.toJson<double?>(endGcash),
      'endMaya': serializer.toJson<double?>(endMaya),
      'endOnHand': serializer.toJson<double?>(endOnHand),
    };
  }

  MonitoringSessionRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? name,
    String? status,
    int? startDateMs,
    Value<int?> endDateMs = const Value.absent(),
    double? startGcash,
    double? startMaya,
    double? startOnHand,
    Value<double?> endGcash = const Value.absent(),
    Value<double?> endMaya = const Value.absent(),
    Value<double?> endOnHand = const Value.absent(),
  }) => MonitoringSessionRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    name: name ?? this.name,
    status: status ?? this.status,
    startDateMs: startDateMs ?? this.startDateMs,
    endDateMs: endDateMs.present ? endDateMs.value : this.endDateMs,
    startGcash: startGcash ?? this.startGcash,
    startMaya: startMaya ?? this.startMaya,
    startOnHand: startOnHand ?? this.startOnHand,
    endGcash: endGcash.present ? endGcash.value : this.endGcash,
    endMaya: endMaya.present ? endMaya.value : this.endMaya,
    endOnHand: endOnHand.present ? endOnHand.value : this.endOnHand,
  );
  MonitoringSessionRow copyWithCompanion(MonitoringSessionsCompanion data) {
    return MonitoringSessionRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      startDateMs: data.startDateMs.present
          ? data.startDateMs.value
          : this.startDateMs,
      endDateMs: data.endDateMs.present ? data.endDateMs.value : this.endDateMs,
      startGcash: data.startGcash.present
          ? data.startGcash.value
          : this.startGcash,
      startMaya: data.startMaya.present ? data.startMaya.value : this.startMaya,
      startOnHand: data.startOnHand.present
          ? data.startOnHand.value
          : this.startOnHand,
      endGcash: data.endGcash.present ? data.endGcash.value : this.endGcash,
      endMaya: data.endMaya.present ? data.endMaya.value : this.endMaya,
      endOnHand: data.endOnHand.present ? data.endOnHand.value : this.endOnHand,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonitoringSessionRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('startDateMs: $startDateMs, ')
          ..write('endDateMs: $endDateMs, ')
          ..write('startGcash: $startGcash, ')
          ..write('startMaya: $startMaya, ')
          ..write('startOnHand: $startOnHand, ')
          ..write('endGcash: $endGcash, ')
          ..write('endMaya: $endMaya, ')
          ..write('endOnHand: $endOnHand')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    status,
    startDateMs,
    endDateMs,
    startGcash,
    startMaya,
    startOnHand,
    endGcash,
    endMaya,
    endOnHand,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitoringSessionRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.name == this.name &&
          other.status == this.status &&
          other.startDateMs == this.startDateMs &&
          other.endDateMs == this.endDateMs &&
          other.startGcash == this.startGcash &&
          other.startMaya == this.startMaya &&
          other.startOnHand == this.startOnHand &&
          other.endGcash == this.endGcash &&
          other.endMaya == this.endMaya &&
          other.endOnHand == this.endOnHand);
}

class MonitoringSessionsCompanion
    extends UpdateCompanion<MonitoringSessionRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> name;
  final Value<String> status;
  final Value<int> startDateMs;
  final Value<int?> endDateMs;
  final Value<double> startGcash;
  final Value<double> startMaya;
  final Value<double> startOnHand;
  final Value<double?> endGcash;
  final Value<double?> endMaya;
  final Value<double?> endOnHand;
  final Value<int> rowid;
  const MonitoringSessionsCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.startDateMs = const Value.absent(),
    this.endDateMs = const Value.absent(),
    this.startGcash = const Value.absent(),
    this.startMaya = const Value.absent(),
    this.startOnHand = const Value.absent(),
    this.endGcash = const Value.absent(),
    this.endMaya = const Value.absent(),
    this.endOnHand = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonitoringSessionsCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String name,
    this.status = const Value.absent(),
    required int startDateMs,
    this.endDateMs = const Value.absent(),
    this.startGcash = const Value.absent(),
    this.startMaya = const Value.absent(),
    this.startOnHand = const Value.absent(),
    this.endGcash = const Value.absent(),
    this.endMaya = const Value.absent(),
    this.endOnHand = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       name = Value(name),
       startDateMs = Value(startDateMs);
  static Insertable<MonitoringSessionRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? status,
    Expression<int>? startDateMs,
    Expression<int>? endDateMs,
    Expression<double>? startGcash,
    Expression<double>? startMaya,
    Expression<double>? startOnHand,
    Expression<double>? endGcash,
    Expression<double>? endMaya,
    Expression<double>? endOnHand,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (startDateMs != null) 'start_date_ms': startDateMs,
      if (endDateMs != null) 'end_date_ms': endDateMs,
      if (startGcash != null) 'start_gcash': startGcash,
      if (startMaya != null) 'start_maya': startMaya,
      if (startOnHand != null) 'start_on_hand': startOnHand,
      if (endGcash != null) 'end_gcash': endGcash,
      if (endMaya != null) 'end_maya': endMaya,
      if (endOnHand != null) 'end_on_hand': endOnHand,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonitoringSessionsCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? name,
    Value<String>? status,
    Value<int>? startDateMs,
    Value<int?>? endDateMs,
    Value<double>? startGcash,
    Value<double>? startMaya,
    Value<double>? startOnHand,
    Value<double?>? endGcash,
    Value<double?>? endMaya,
    Value<double?>? endOnHand,
    Value<int>? rowid,
  }) {
    return MonitoringSessionsCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      startDateMs: startDateMs ?? this.startDateMs,
      endDateMs: endDateMs ?? this.endDateMs,
      startGcash: startGcash ?? this.startGcash,
      startMaya: startMaya ?? this.startMaya,
      startOnHand: startOnHand ?? this.startOnHand,
      endGcash: endGcash ?? this.endGcash,
      endMaya: endMaya ?? this.endMaya,
      endOnHand: endOnHand ?? this.endOnHand,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startDateMs.present) {
      map['start_date_ms'] = Variable<int>(startDateMs.value);
    }
    if (endDateMs.present) {
      map['end_date_ms'] = Variable<int>(endDateMs.value);
    }
    if (startGcash.present) {
      map['start_gcash'] = Variable<double>(startGcash.value);
    }
    if (startMaya.present) {
      map['start_maya'] = Variable<double>(startMaya.value);
    }
    if (startOnHand.present) {
      map['start_on_hand'] = Variable<double>(startOnHand.value);
    }
    if (endGcash.present) {
      map['end_gcash'] = Variable<double>(endGcash.value);
    }
    if (endMaya.present) {
      map['end_maya'] = Variable<double>(endMaya.value);
    }
    if (endOnHand.present) {
      map['end_on_hand'] = Variable<double>(endOnHand.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonitoringSessionsCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('startDateMs: $startDateMs, ')
          ..write('endDateMs: $endDateMs, ')
          ..write('startGcash: $startGcash, ')
          ..write('startMaya: $startMaya, ')
          ..write('startOnHand: $startOnHand, ')
          ..write('endGcash: $endGcash, ')
          ..write('endMaya: $endMaya, ')
          ..write('endOnHand: $endOnHand, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $ProductCategoriesTableToColumns
    implements Insertable<ProductCategoryRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get name;
  String get description;
  String get examples;
  bool get isQuickAccess;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['examples'] = Variable<String>(examples);
    map['is_quick_access'] = Variable<bool>(isQuickAccess);
    return map;
  }
}

class $ProductCategoriesTable extends ProductCategories
    with TableInfo<$ProductCategoriesTable, ProductCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _examplesMeta = const VerificationMeta(
    'examples',
  );
  @override
  late final GeneratedColumn<String> examples = GeneratedColumn<String>(
    'examples',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isQuickAccessMeta = const VerificationMeta(
    'isQuickAccess',
  );
  @override
  late final GeneratedColumn<bool> isQuickAccess = GeneratedColumn<bool>(
    'is_quick_access',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_quick_access" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    description,
    examples,
    isQuickAccess,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('examples')) {
      context.handle(
        _examplesMeta,
        examples.isAcceptableOrUnknown(data['examples']!, _examplesMeta),
      );
    }
    if (data.containsKey('is_quick_access')) {
      context.handle(
        _isQuickAccessMeta,
        isQuickAccess.isAcceptableOrUnknown(
          data['is_quick_access']!,
          _isQuickAccessMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name},
  ];
  @override
  ProductCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductCategoryRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      examples: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examples'],
      )!,
      isQuickAccess: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_quick_access'],
      )!,
    );
  }

  @override
  $ProductCategoriesTable createAlias(String alias) {
    return $ProductCategoriesTable(attachedDatabase, alias);
  }
}

class ProductCategoryRow extends DataClass
    with $ProductCategoriesTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String examples;
  @override
  final bool isQuickAccess;
  const ProductCategoryRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.name,
    required this.description,
    required this.examples,
    required this.isQuickAccess,
  });
  ProductCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ProductCategoriesCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      name: Value(name),
      description: Value(description),
      examples: Value(examples),
      isQuickAccess: Value(isQuickAccess),
    );
  }

  factory ProductCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductCategoryRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      examples: serializer.fromJson<String>(json['examples']),
      isQuickAccess: serializer.fromJson<bool>(json['isQuickAccess']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'examples': serializer.toJson<String>(examples),
      'isQuickAccess': serializer.toJson<bool>(isQuickAccess),
    };
  }

  ProductCategoryRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? name,
    String? description,
    String? examples,
    bool? isQuickAccess,
  }) => ProductCategoryRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    examples: examples ?? this.examples,
    isQuickAccess: isQuickAccess ?? this.isQuickAccess,
  );
  ProductCategoryRow copyWithCompanion(ProductCategoriesCompanion data) {
    return ProductCategoryRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      examples: data.examples.present ? data.examples.value : this.examples,
      isQuickAccess: data.isQuickAccess.present
          ? data.isQuickAccess.value
          : this.isQuickAccess,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductCategoryRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('examples: $examples, ')
          ..write('isQuickAccess: $isQuickAccess')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    description,
    examples,
    isQuickAccess,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductCategoryRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.examples == this.examples &&
          other.isQuickAccess == this.isQuickAccess);
}

class ProductCategoriesCompanion extends UpdateCompanion<ProductCategoryRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> examples;
  final Value<bool> isQuickAccess;
  final Value<int> rowid;
  const ProductCategoriesCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.examples = const Value.absent(),
    this.isQuickAccess = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductCategoriesCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.examples = const Value.absent(),
    this.isQuickAccess = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       name = Value(name);
  static Insertable<ProductCategoryRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? examples,
    Expression<bool>? isQuickAccess,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (examples != null) 'examples': examples,
      if (isQuickAccess != null) 'is_quick_access': isQuickAccess,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductCategoriesCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? examples,
    Value<bool>? isQuickAccess,
    Value<int>? rowid,
  }) {
    return ProductCategoriesCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      examples: examples ?? this.examples,
      isQuickAccess: isQuickAccess ?? this.isQuickAccess,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (examples.present) {
      map['examples'] = Variable<String>(examples.value);
    }
    if (isQuickAccess.present) {
      map['is_quick_access'] = Variable<bool>(isQuickAccess.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductCategoriesCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('examples: $examples, ')
          ..write('isQuickAccess: $isQuickAccess, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $ShelfLocationsTableToColumns implements Insertable<ShelfLocationRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get name;
  String get description;
  String get examples;
  String? get imageUrl;
  String? get imageLocalPath;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['examples'] = Variable<String>(examples);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || imageLocalPath != null) {
      map['image_local_path'] = Variable<String>(imageLocalPath);
    }
    return map;
  }
}

class $ShelfLocationsTable extends ShelfLocations
    with TableInfo<$ShelfLocationsTable, ShelfLocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelfLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _examplesMeta = const VerificationMeta(
    'examples',
  );
  @override
  late final GeneratedColumn<String> examples = GeneratedColumn<String>(
    'examples',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageLocalPathMeta = const VerificationMeta(
    'imageLocalPath',
  );
  @override
  late final GeneratedColumn<String> imageLocalPath = GeneratedColumn<String>(
    'image_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    description,
    examples,
    imageUrl,
    imageLocalPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelf_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShelfLocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('examples')) {
      context.handle(
        _examplesMeta,
        examples.isAcceptableOrUnknown(data['examples']!, _examplesMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('image_local_path')) {
      context.handle(
        _imageLocalPathMeta,
        imageLocalPath.isAcceptableOrUnknown(
          data['image_local_path']!,
          _imageLocalPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name},
  ];
  @override
  ShelfLocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShelfLocationRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      examples: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examples'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      imageLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_local_path'],
      ),
    );
  }

  @override
  $ShelfLocationsTable createAlias(String alias) {
    return $ShelfLocationsTable(attachedDatabase, alias);
  }
}

class ShelfLocationRow extends DataClass with $ShelfLocationsTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String examples;
  @override
  final String? imageUrl;
  @override
  final String? imageLocalPath;
  const ShelfLocationRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.name,
    required this.description,
    required this.examples,
    this.imageUrl,
    this.imageLocalPath,
  });
  ShelfLocationsCompanion toCompanion(bool nullToAbsent) {
    return ShelfLocationsCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      name: Value(name),
      description: Value(description),
      examples: Value(examples),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      imageLocalPath: imageLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(imageLocalPath),
    );
  }

  factory ShelfLocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShelfLocationRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      examples: serializer.fromJson<String>(json['examples']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      imageLocalPath: serializer.fromJson<String?>(json['imageLocalPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'examples': serializer.toJson<String>(examples),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'imageLocalPath': serializer.toJson<String?>(imageLocalPath),
    };
  }

  ShelfLocationRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? name,
    String? description,
    String? examples,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> imageLocalPath = const Value.absent(),
  }) => ShelfLocationRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    examples: examples ?? this.examples,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    imageLocalPath: imageLocalPath.present
        ? imageLocalPath.value
        : this.imageLocalPath,
  );
  ShelfLocationRow copyWithCompanion(ShelfLocationsCompanion data) {
    return ShelfLocationRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      examples: data.examples.present ? data.examples.value : this.examples,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      imageLocalPath: data.imageLocalPath.present
          ? data.imageLocalPath.value
          : this.imageLocalPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShelfLocationRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('examples: $examples, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('imageLocalPath: $imageLocalPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    description,
    examples,
    imageUrl,
    imageLocalPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShelfLocationRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.examples == this.examples &&
          other.imageUrl == this.imageUrl &&
          other.imageLocalPath == this.imageLocalPath);
}

class ShelfLocationsCompanion extends UpdateCompanion<ShelfLocationRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> examples;
  final Value<String?> imageUrl;
  final Value<String?> imageLocalPath;
  final Value<int> rowid;
  const ShelfLocationsCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.examples = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.imageLocalPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShelfLocationsCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.examples = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.imageLocalPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       name = Value(name);
  static Insertable<ShelfLocationRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? examples,
    Expression<String>? imageUrl,
    Expression<String>? imageLocalPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (examples != null) 'examples': examples,
      if (imageUrl != null) 'image_url': imageUrl,
      if (imageLocalPath != null) 'image_local_path': imageLocalPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShelfLocationsCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? examples,
    Value<String?>? imageUrl,
    Value<String?>? imageLocalPath,
    Value<int>? rowid,
  }) {
    return ShelfLocationsCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      examples: examples ?? this.examples,
      imageUrl: imageUrl ?? this.imageUrl,
      imageLocalPath: imageLocalPath ?? this.imageLocalPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (examples.present) {
      map['examples'] = Variable<String>(examples.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (imageLocalPath.present) {
      map['image_local_path'] = Variable<String>(imageLocalPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelfLocationsCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('examples: $examples, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('imageLocalPath: $imageLocalPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $ProductsTableToColumns implements Insertable<ProductRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get name;
  String get sku;
  String get description;
  String get category;
  String get baseUnit;
  double get costPrice;
  double get sellingPrice;
  double get stockInBaseUnit;
  int get reorderPoint;
  bool get isActive;
  String? get imageUrl;
  String? get imageLocalPath;
  String? get shelfLocation;
  int? get expirationDateMs;
  String? get categoryId;
  String? get shelfLocationId;
  String get itemType;
  String get customAttributesJson;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sku'] = Variable<String>(sku);
    map['description'] = Variable<String>(description);
    map['category'] = Variable<String>(category);
    map['base_unit'] = Variable<String>(baseUnit);
    map['cost_price'] = Variable<double>(costPrice);
    map['selling_price'] = Variable<double>(sellingPrice);
    map['stock_in_base_unit'] = Variable<double>(stockInBaseUnit);
    map['reorder_point'] = Variable<int>(reorderPoint);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || imageLocalPath != null) {
      map['image_local_path'] = Variable<String>(imageLocalPath);
    }
    if (!nullToAbsent || shelfLocation != null) {
      map['shelf_location'] = Variable<String>(shelfLocation);
    }
    if (!nullToAbsent || expirationDateMs != null) {
      map['expiration_date_ms'] = Variable<int>(expirationDateMs);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || shelfLocationId != null) {
      map['shelf_location_id'] = Variable<String>(shelfLocationId);
    }
    map['item_type'] = Variable<String>(itemType);
    map['custom_attributes_json'] = Variable<String>(customAttributesJson);
    return map;
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    false,
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('General'),
  );
  static const VerificationMeta _baseUnitMeta = const VerificationMeta(
    'baseUnit',
  );
  @override
  late final GeneratedColumn<String> baseUnit = GeneratedColumn<String>(
    'base_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pcs'),
  );
  static const VerificationMeta _costPriceMeta = const VerificationMeta(
    'costPrice',
  );
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
    'cost_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sellingPriceMeta = const VerificationMeta(
    'sellingPrice',
  );
  @override
  late final GeneratedColumn<double> sellingPrice = GeneratedColumn<double>(
    'selling_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockInBaseUnitMeta = const VerificationMeta(
    'stockInBaseUnit',
  );
  @override
  late final GeneratedColumn<double> stockInBaseUnit = GeneratedColumn<double>(
    'stock_in_base_unit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reorderPointMeta = const VerificationMeta(
    'reorderPoint',
  );
  @override
  late final GeneratedColumn<int> reorderPoint = GeneratedColumn<int>(
    'reorder_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageLocalPathMeta = const VerificationMeta(
    'imageLocalPath',
  );
  @override
  late final GeneratedColumn<String> imageLocalPath = GeneratedColumn<String>(
    'image_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shelfLocationMeta = const VerificationMeta(
    'shelfLocation',
  );
  @override
  late final GeneratedColumn<String> shelfLocation = GeneratedColumn<String>(
    'shelf_location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Counter'),
  );
  static const VerificationMeta _expirationDateMsMeta = const VerificationMeta(
    'expirationDateMs',
  );
  @override
  late final GeneratedColumn<int> expirationDateMs = GeneratedColumn<int>(
    'expiration_date_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES product_categories (id)',
    ),
  );
  static const VerificationMeta _shelfLocationIdMeta = const VerificationMeta(
    'shelfLocationId',
  );
  @override
  late final GeneratedColumn<String> shelfLocationId = GeneratedColumn<String>(
    'shelf_location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shelf_locations (id)',
    ),
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('standard'),
  );
  static const VerificationMeta _customAttributesJsonMeta =
      const VerificationMeta('customAttributesJson');
  @override
  late final GeneratedColumn<String> customAttributesJson =
      GeneratedColumn<String>(
        'custom_attributes_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    sku,
    description,
    category,
    baseUnit,
    costPrice,
    sellingPrice,
    stockInBaseUnit,
    reorderPoint,
    isActive,
    imageUrl,
    imageLocalPath,
    shelfLocation,
    expirationDateMs,
    categoryId,
    shelfLocationId,
    itemType,
    customAttributesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    } else if (isInserting) {
      context.missing(_skuMeta);
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('base_unit')) {
      context.handle(
        _baseUnitMeta,
        baseUnit.isAcceptableOrUnknown(data['base_unit']!, _baseUnitMeta),
      );
    }
    if (data.containsKey('cost_price')) {
      context.handle(
        _costPriceMeta,
        costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta),
      );
    }
    if (data.containsKey('selling_price')) {
      context.handle(
        _sellingPriceMeta,
        sellingPrice.isAcceptableOrUnknown(
          data['selling_price']!,
          _sellingPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellingPriceMeta);
    }
    if (data.containsKey('stock_in_base_unit')) {
      context.handle(
        _stockInBaseUnitMeta,
        stockInBaseUnit.isAcceptableOrUnknown(
          data['stock_in_base_unit']!,
          _stockInBaseUnitMeta,
        ),
      );
    }
    if (data.containsKey('reorder_point')) {
      context.handle(
        _reorderPointMeta,
        reorderPoint.isAcceptableOrUnknown(
          data['reorder_point']!,
          _reorderPointMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('image_local_path')) {
      context.handle(
        _imageLocalPathMeta,
        imageLocalPath.isAcceptableOrUnknown(
          data['image_local_path']!,
          _imageLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('shelf_location')) {
      context.handle(
        _shelfLocationMeta,
        shelfLocation.isAcceptableOrUnknown(
          data['shelf_location']!,
          _shelfLocationMeta,
        ),
      );
    }
    if (data.containsKey('expiration_date_ms')) {
      context.handle(
        _expirationDateMsMeta,
        expirationDateMs.isAcceptableOrUnknown(
          data['expiration_date_ms']!,
          _expirationDateMsMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('shelf_location_id')) {
      context.handle(
        _shelfLocationIdMeta,
        shelfLocationId.isAcceptableOrUnknown(
          data['shelf_location_id']!,
          _shelfLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    }
    if (data.containsKey('custom_attributes_json')) {
      context.handle(
        _customAttributesJsonMeta,
        customAttributesJson.isAcceptableOrUnknown(
          data['custom_attributes_json']!,
          _customAttributesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sku},
  ];
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      baseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_unit'],
      )!,
      costPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price'],
      )!,
      sellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selling_price'],
      )!,
      stockInBaseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_in_base_unit'],
      )!,
      reorderPoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reorder_point'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      imageLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_local_path'],
      ),
      shelfLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shelf_location'],
      ),
      expirationDateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expiration_date_ms'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      shelfLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shelf_location_id'],
      ),
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      customAttributesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_attributes_json'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass with $ProductsTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String name;
  @override
  final String sku;
  @override
  final String description;
  @override
  final String category;
  @override
  final String baseUnit;
  @override
  final double costPrice;
  @override
  final double sellingPrice;
  @override
  final double stockInBaseUnit;
  @override
  final int reorderPoint;
  @override
  final bool isActive;
  @override
  final String? imageUrl;
  @override
  final String? imageLocalPath;
  @override
  final String? shelfLocation;
  @override
  final int? expirationDateMs;
  @override
  final String? categoryId;
  @override
  final String? shelfLocationId;
  @override
  final String itemType;
  @override
  final String customAttributesJson;
  const ProductRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.category,
    required this.baseUnit,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockInBaseUnit,
    required this.reorderPoint,
    required this.isActive,
    this.imageUrl,
    this.imageLocalPath,
    this.shelfLocation,
    this.expirationDateMs,
    this.categoryId,
    this.shelfLocationId,
    required this.itemType,
    required this.customAttributesJson,
  });
  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      name: Value(name),
      sku: Value(sku),
      description: Value(description),
      category: Value(category),
      baseUnit: Value(baseUnit),
      costPrice: Value(costPrice),
      sellingPrice: Value(sellingPrice),
      stockInBaseUnit: Value(stockInBaseUnit),
      reorderPoint: Value(reorderPoint),
      isActive: Value(isActive),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      imageLocalPath: imageLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(imageLocalPath),
      shelfLocation: shelfLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfLocation),
      expirationDateMs: expirationDateMs == null && nullToAbsent
          ? const Value.absent()
          : Value(expirationDateMs),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      shelfLocationId: shelfLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfLocationId),
      itemType: Value(itemType),
      customAttributesJson: Value(customAttributesJson),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String>(json['sku']),
      description: serializer.fromJson<String>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      baseUnit: serializer.fromJson<String>(json['baseUnit']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
      sellingPrice: serializer.fromJson<double>(json['sellingPrice']),
      stockInBaseUnit: serializer.fromJson<double>(json['stockInBaseUnit']),
      reorderPoint: serializer.fromJson<int>(json['reorderPoint']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      imageLocalPath: serializer.fromJson<String?>(json['imageLocalPath']),
      shelfLocation: serializer.fromJson<String?>(json['shelfLocation']),
      expirationDateMs: serializer.fromJson<int?>(json['expirationDateMs']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      shelfLocationId: serializer.fromJson<String?>(json['shelfLocationId']),
      itemType: serializer.fromJson<String>(json['itemType']),
      customAttributesJson: serializer.fromJson<String>(
        json['customAttributesJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String>(sku),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String>(category),
      'baseUnit': serializer.toJson<String>(baseUnit),
      'costPrice': serializer.toJson<double>(costPrice),
      'sellingPrice': serializer.toJson<double>(sellingPrice),
      'stockInBaseUnit': serializer.toJson<double>(stockInBaseUnit),
      'reorderPoint': serializer.toJson<int>(reorderPoint),
      'isActive': serializer.toJson<bool>(isActive),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'imageLocalPath': serializer.toJson<String?>(imageLocalPath),
      'shelfLocation': serializer.toJson<String?>(shelfLocation),
      'expirationDateMs': serializer.toJson<int?>(expirationDateMs),
      'categoryId': serializer.toJson<String?>(categoryId),
      'shelfLocationId': serializer.toJson<String?>(shelfLocationId),
      'itemType': serializer.toJson<String>(itemType),
      'customAttributesJson': serializer.toJson<String>(customAttributesJson),
    };
  }

  ProductRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? name,
    String? sku,
    String? description,
    String? category,
    String? baseUnit,
    double? costPrice,
    double? sellingPrice,
    double? stockInBaseUnit,
    int? reorderPoint,
    bool? isActive,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> imageLocalPath = const Value.absent(),
    Value<String?> shelfLocation = const Value.absent(),
    Value<int?> expirationDateMs = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<String?> shelfLocationId = const Value.absent(),
    String? itemType,
    String? customAttributesJson,
  }) => ProductRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    name: name ?? this.name,
    sku: sku ?? this.sku,
    description: description ?? this.description,
    category: category ?? this.category,
    baseUnit: baseUnit ?? this.baseUnit,
    costPrice: costPrice ?? this.costPrice,
    sellingPrice: sellingPrice ?? this.sellingPrice,
    stockInBaseUnit: stockInBaseUnit ?? this.stockInBaseUnit,
    reorderPoint: reorderPoint ?? this.reorderPoint,
    isActive: isActive ?? this.isActive,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    imageLocalPath: imageLocalPath.present
        ? imageLocalPath.value
        : this.imageLocalPath,
    shelfLocation: shelfLocation.present
        ? shelfLocation.value
        : this.shelfLocation,
    expirationDateMs: expirationDateMs.present
        ? expirationDateMs.value
        : this.expirationDateMs,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    shelfLocationId: shelfLocationId.present
        ? shelfLocationId.value
        : this.shelfLocationId,
    itemType: itemType ?? this.itemType,
    customAttributesJson: customAttributesJson ?? this.customAttributesJson,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      baseUnit: data.baseUnit.present ? data.baseUnit.value : this.baseUnit,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      sellingPrice: data.sellingPrice.present
          ? data.sellingPrice.value
          : this.sellingPrice,
      stockInBaseUnit: data.stockInBaseUnit.present
          ? data.stockInBaseUnit.value
          : this.stockInBaseUnit,
      reorderPoint: data.reorderPoint.present
          ? data.reorderPoint.value
          : this.reorderPoint,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      imageLocalPath: data.imageLocalPath.present
          ? data.imageLocalPath.value
          : this.imageLocalPath,
      shelfLocation: data.shelfLocation.present
          ? data.shelfLocation.value
          : this.shelfLocation,
      expirationDateMs: data.expirationDateMs.present
          ? data.expirationDateMs.value
          : this.expirationDateMs,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      shelfLocationId: data.shelfLocationId.present
          ? data.shelfLocationId.value
          : this.shelfLocationId,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      customAttributesJson: data.customAttributesJson.present
          ? data.customAttributesJson.value
          : this.customAttributesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('costPrice: $costPrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('stockInBaseUnit: $stockInBaseUnit, ')
          ..write('reorderPoint: $reorderPoint, ')
          ..write('isActive: $isActive, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('imageLocalPath: $imageLocalPath, ')
          ..write('shelfLocation: $shelfLocation, ')
          ..write('expirationDateMs: $expirationDateMs, ')
          ..write('categoryId: $categoryId, ')
          ..write('shelfLocationId: $shelfLocationId, ')
          ..write('itemType: $itemType, ')
          ..write('customAttributesJson: $customAttributesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    sku,
    description,
    category,
    baseUnit,
    costPrice,
    sellingPrice,
    stockInBaseUnit,
    reorderPoint,
    isActive,
    imageUrl,
    imageLocalPath,
    shelfLocation,
    expirationDateMs,
    categoryId,
    shelfLocationId,
    itemType,
    customAttributesJson,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.description == this.description &&
          other.category == this.category &&
          other.baseUnit == this.baseUnit &&
          other.costPrice == this.costPrice &&
          other.sellingPrice == this.sellingPrice &&
          other.stockInBaseUnit == this.stockInBaseUnit &&
          other.reorderPoint == this.reorderPoint &&
          other.isActive == this.isActive &&
          other.imageUrl == this.imageUrl &&
          other.imageLocalPath == this.imageLocalPath &&
          other.shelfLocation == this.shelfLocation &&
          other.expirationDateMs == this.expirationDateMs &&
          other.categoryId == this.categoryId &&
          other.shelfLocationId == this.shelfLocationId &&
          other.itemType == this.itemType &&
          other.customAttributesJson == this.customAttributesJson);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> name;
  final Value<String> sku;
  final Value<String> description;
  final Value<String> category;
  final Value<String> baseUnit;
  final Value<double> costPrice;
  final Value<double> sellingPrice;
  final Value<double> stockInBaseUnit;
  final Value<int> reorderPoint;
  final Value<bool> isActive;
  final Value<String?> imageUrl;
  final Value<String?> imageLocalPath;
  final Value<String?> shelfLocation;
  final Value<int?> expirationDateMs;
  final Value<String?> categoryId;
  final Value<String?> shelfLocationId;
  final Value<String> itemType;
  final Value<String> customAttributesJson;
  final Value<int> rowid;
  const ProductsCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.stockInBaseUnit = const Value.absent(),
    this.reorderPoint = const Value.absent(),
    this.isActive = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.imageLocalPath = const Value.absent(),
    this.shelfLocation = const Value.absent(),
    this.expirationDateMs = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.shelfLocationId = const Value.absent(),
    this.itemType = const Value.absent(),
    this.customAttributesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String name,
    required String sku,
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.costPrice = const Value.absent(),
    required double sellingPrice,
    this.stockInBaseUnit = const Value.absent(),
    this.reorderPoint = const Value.absent(),
    this.isActive = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.imageLocalPath = const Value.absent(),
    this.shelfLocation = const Value.absent(),
    this.expirationDateMs = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.shelfLocationId = const Value.absent(),
    this.itemType = const Value.absent(),
    this.customAttributesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       name = Value(name),
       sku = Value(sku),
       sellingPrice = Value(sellingPrice);
  static Insertable<ProductRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? baseUnit,
    Expression<double>? costPrice,
    Expression<double>? sellingPrice,
    Expression<double>? stockInBaseUnit,
    Expression<int>? reorderPoint,
    Expression<bool>? isActive,
    Expression<String>? imageUrl,
    Expression<String>? imageLocalPath,
    Expression<String>? shelfLocation,
    Expression<int>? expirationDateMs,
    Expression<String>? categoryId,
    Expression<String>? shelfLocationId,
    Expression<String>? itemType,
    Expression<String>? customAttributesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (baseUnit != null) 'base_unit': baseUnit,
      if (costPrice != null) 'cost_price': costPrice,
      if (sellingPrice != null) 'selling_price': sellingPrice,
      if (stockInBaseUnit != null) 'stock_in_base_unit': stockInBaseUnit,
      if (reorderPoint != null) 'reorder_point': reorderPoint,
      if (isActive != null) 'is_active': isActive,
      if (imageUrl != null) 'image_url': imageUrl,
      if (imageLocalPath != null) 'image_local_path': imageLocalPath,
      if (shelfLocation != null) 'shelf_location': shelfLocation,
      if (expirationDateMs != null) 'expiration_date_ms': expirationDateMs,
      if (categoryId != null) 'category_id': categoryId,
      if (shelfLocationId != null) 'shelf_location_id': shelfLocationId,
      if (itemType != null) 'item_type': itemType,
      if (customAttributesJson != null)
        'custom_attributes_json': customAttributesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? name,
    Value<String>? sku,
    Value<String>? description,
    Value<String>? category,
    Value<String>? baseUnit,
    Value<double>? costPrice,
    Value<double>? sellingPrice,
    Value<double>? stockInBaseUnit,
    Value<int>? reorderPoint,
    Value<bool>? isActive,
    Value<String?>? imageUrl,
    Value<String?>? imageLocalPath,
    Value<String?>? shelfLocation,
    Value<int?>? expirationDateMs,
    Value<String?>? categoryId,
    Value<String?>? shelfLocationId,
    Value<String>? itemType,
    Value<String>? customAttributesJson,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      category: category ?? this.category,
      baseUnit: baseUnit ?? this.baseUnit,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockInBaseUnit: stockInBaseUnit ?? this.stockInBaseUnit,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      imageLocalPath: imageLocalPath ?? this.imageLocalPath,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      expirationDateMs: expirationDateMs ?? this.expirationDateMs,
      categoryId: categoryId ?? this.categoryId,
      shelfLocationId: shelfLocationId ?? this.shelfLocationId,
      itemType: itemType ?? this.itemType,
      customAttributesJson: customAttributesJson ?? this.customAttributesJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (baseUnit.present) {
      map['base_unit'] = Variable<String>(baseUnit.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (sellingPrice.present) {
      map['selling_price'] = Variable<double>(sellingPrice.value);
    }
    if (stockInBaseUnit.present) {
      map['stock_in_base_unit'] = Variable<double>(stockInBaseUnit.value);
    }
    if (reorderPoint.present) {
      map['reorder_point'] = Variable<int>(reorderPoint.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (imageLocalPath.present) {
      map['image_local_path'] = Variable<String>(imageLocalPath.value);
    }
    if (shelfLocation.present) {
      map['shelf_location'] = Variable<String>(shelfLocation.value);
    }
    if (expirationDateMs.present) {
      map['expiration_date_ms'] = Variable<int>(expirationDateMs.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (shelfLocationId.present) {
      map['shelf_location_id'] = Variable<String>(shelfLocationId.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (customAttributesJson.present) {
      map['custom_attributes_json'] = Variable<String>(
        customAttributesJson.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('costPrice: $costPrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('stockInBaseUnit: $stockInBaseUnit, ')
          ..write('reorderPoint: $reorderPoint, ')
          ..write('isActive: $isActive, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('imageLocalPath: $imageLocalPath, ')
          ..write('shelfLocation: $shelfLocation, ')
          ..write('expirationDateMs: $expirationDateMs, ')
          ..write('categoryId: $categoryId, ')
          ..write('shelfLocationId: $shelfLocationId, ')
          ..write('itemType: $itemType, ')
          ..write('customAttributesJson: $customAttributesJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $ProductUnitConversionsTableToColumns
    implements Insertable<ProductUnitConversionRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get productId;
  String get unitName;
  double get conversionFactor;
  double get costPrice;
  double get sellingPrice;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['unit_name'] = Variable<String>(unitName);
    map['conversion_factor'] = Variable<double>(conversionFactor);
    map['cost_price'] = Variable<double>(costPrice);
    map['selling_price'] = Variable<double>(sellingPrice);
    return map;
  }
}

class $ProductUnitConversionsTable extends ProductUnitConversions
    with TableInfo<$ProductUnitConversionsTable, ProductUnitConversionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductUnitConversionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _unitNameMeta = const VerificationMeta(
    'unitName',
  );
  @override
  late final GeneratedColumn<String> unitName = GeneratedColumn<String>(
    'unit_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversionFactorMeta = const VerificationMeta(
    'conversionFactor',
  );
  @override
  late final GeneratedColumn<double> conversionFactor = GeneratedColumn<double>(
    'conversion_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPriceMeta = const VerificationMeta(
    'costPrice',
  );
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
    'cost_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellingPriceMeta = const VerificationMeta(
    'sellingPrice',
  );
  @override
  late final GeneratedColumn<double> sellingPrice = GeneratedColumn<double>(
    'selling_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    productId,
    unitName,
    conversionFactor,
    costPrice,
    sellingPrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_unit_conversions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductUnitConversionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('unit_name')) {
      context.handle(
        _unitNameMeta,
        unitName.isAcceptableOrUnknown(data['unit_name']!, _unitNameMeta),
      );
    } else if (isInserting) {
      context.missing(_unitNameMeta);
    }
    if (data.containsKey('conversion_factor')) {
      context.handle(
        _conversionFactorMeta,
        conversionFactor.isAcceptableOrUnknown(
          data['conversion_factor']!,
          _conversionFactorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversionFactorMeta);
    }
    if (data.containsKey('cost_price')) {
      context.handle(
        _costPriceMeta,
        costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_costPriceMeta);
    }
    if (data.containsKey('selling_price')) {
      context.handle(
        _sellingPriceMeta,
        sellingPrice.isAcceptableOrUnknown(
          data['selling_price']!,
          _sellingPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellingPriceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductUnitConversionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductUnitConversionRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      unitName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_name'],
      )!,
      conversionFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}conversion_factor'],
      )!,
      costPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price'],
      )!,
      sellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selling_price'],
      )!,
    );
  }

  @override
  $ProductUnitConversionsTable createAlias(String alias) {
    return $ProductUnitConversionsTable(attachedDatabase, alias);
  }
}

class ProductUnitConversionRow extends DataClass
    with $ProductUnitConversionsTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String productId;
  @override
  final String unitName;
  @override
  final double conversionFactor;
  @override
  final double costPrice;
  @override
  final double sellingPrice;
  const ProductUnitConversionRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.productId,
    required this.unitName,
    required this.conversionFactor,
    required this.costPrice,
    required this.sellingPrice,
  });
  ProductUnitConversionsCompanion toCompanion(bool nullToAbsent) {
    return ProductUnitConversionsCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      productId: Value(productId),
      unitName: Value(unitName),
      conversionFactor: Value(conversionFactor),
      costPrice: Value(costPrice),
      sellingPrice: Value(sellingPrice),
    );
  }

  factory ProductUnitConversionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductUnitConversionRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      unitName: serializer.fromJson<String>(json['unitName']),
      conversionFactor: serializer.fromJson<double>(json['conversionFactor']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
      sellingPrice: serializer.fromJson<double>(json['sellingPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'unitName': serializer.toJson<String>(unitName),
      'conversionFactor': serializer.toJson<double>(conversionFactor),
      'costPrice': serializer.toJson<double>(costPrice),
      'sellingPrice': serializer.toJson<double>(sellingPrice),
    };
  }

  ProductUnitConversionRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? productId,
    String? unitName,
    double? conversionFactor,
    double? costPrice,
    double? sellingPrice,
  }) => ProductUnitConversionRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    productId: productId ?? this.productId,
    unitName: unitName ?? this.unitName,
    conversionFactor: conversionFactor ?? this.conversionFactor,
    costPrice: costPrice ?? this.costPrice,
    sellingPrice: sellingPrice ?? this.sellingPrice,
  );
  ProductUnitConversionRow copyWithCompanion(
    ProductUnitConversionsCompanion data,
  ) {
    return ProductUnitConversionRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      unitName: data.unitName.present ? data.unitName.value : this.unitName,
      conversionFactor: data.conversionFactor.present
          ? data.conversionFactor.value
          : this.conversionFactor,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      sellingPrice: data.sellingPrice.present
          ? data.sellingPrice.value
          : this.sellingPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductUnitConversionRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('unitName: $unitName, ')
          ..write('conversionFactor: $conversionFactor, ')
          ..write('costPrice: $costPrice, ')
          ..write('sellingPrice: $sellingPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    productId,
    unitName,
    conversionFactor,
    costPrice,
    sellingPrice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductUnitConversionRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.unitName == this.unitName &&
          other.conversionFactor == this.conversionFactor &&
          other.costPrice == this.costPrice &&
          other.sellingPrice == this.sellingPrice);
}

class ProductUnitConversionsCompanion
    extends UpdateCompanion<ProductUnitConversionRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> productId;
  final Value<String> unitName;
  final Value<double> conversionFactor;
  final Value<double> costPrice;
  final Value<double> sellingPrice;
  final Value<int> rowid;
  const ProductUnitConversionsCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.unitName = const Value.absent(),
    this.conversionFactor = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductUnitConversionsCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String productId,
    required String unitName,
    required double conversionFactor,
    required double costPrice,
    required double sellingPrice,
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       productId = Value(productId),
       unitName = Value(unitName),
       conversionFactor = Value(conversionFactor),
       costPrice = Value(costPrice),
       sellingPrice = Value(sellingPrice);
  static Insertable<ProductUnitConversionRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? unitName,
    Expression<double>? conversionFactor,
    Expression<double>? costPrice,
    Expression<double>? sellingPrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (unitName != null) 'unit_name': unitName,
      if (conversionFactor != null) 'conversion_factor': conversionFactor,
      if (costPrice != null) 'cost_price': costPrice,
      if (sellingPrice != null) 'selling_price': sellingPrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductUnitConversionsCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? productId,
    Value<String>? unitName,
    Value<double>? conversionFactor,
    Value<double>? costPrice,
    Value<double>? sellingPrice,
    Value<int>? rowid,
  }) {
    return ProductUnitConversionsCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      productId: productId ?? this.productId,
      unitName: unitName ?? this.unitName,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (unitName.present) {
      map['unit_name'] = Variable<String>(unitName.value);
    }
    if (conversionFactor.present) {
      map['conversion_factor'] = Variable<double>(conversionFactor.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (sellingPrice.present) {
      map['selling_price'] = Variable<double>(sellingPrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductUnitConversionsCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('unitName: $unitName, ')
          ..write('conversionFactor: $conversionFactor, ')
          ..write('costPrice: $costPrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $StockMovementsTableToColumns implements Insertable<StockMovementRow> {
  String get id;
  String get productId;
  String get movementType;
  double get quantity;
  double get previousQuantity;
  double get newQuantity;
  String get note;
  String get reference;
  int? get expirationDateMs;
  int get createdAtMs;
  bool get isDirty;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['movement_type'] = Variable<String>(movementType);
    map['quantity'] = Variable<double>(quantity);
    map['previous_quantity'] = Variable<double>(previousQuantity);
    map['new_quantity'] = Variable<double>(newQuantity);
    map['note'] = Variable<String>(note);
    map['reference'] = Variable<String>(reference);
    if (!nullToAbsent || expirationDateMs != null) {
      map['expiration_date_ms'] = Variable<int>(expirationDateMs);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _movementTypeMeta = const VerificationMeta(
    'movementType',
  );
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
    'movement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousQuantityMeta = const VerificationMeta(
    'previousQuantity',
  );
  @override
  late final GeneratedColumn<double> previousQuantity = GeneratedColumn<double>(
    'previous_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newQuantityMeta = const VerificationMeta(
    'newQuantity',
  );
  @override
  late final GeneratedColumn<double> newQuantity = GeneratedColumn<double>(
    'new_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _expirationDateMsMeta = const VerificationMeta(
    'expirationDateMs',
  );
  @override
  late final GeneratedColumn<int> expirationDateMs = GeneratedColumn<int>(
    'expiration_date_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    movementType,
    quantity,
    previousQuantity,
    newQuantity,
    note,
    reference,
    expirationDateMs,
    createdAtMs,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('movement_type')) {
      context.handle(
        _movementTypeMeta,
        movementType.isAcceptableOrUnknown(
          data['movement_type']!,
          _movementTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('previous_quantity')) {
      context.handle(
        _previousQuantityMeta,
        previousQuantity.isAcceptableOrUnknown(
          data['previous_quantity']!,
          _previousQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousQuantityMeta);
    }
    if (data.containsKey('new_quantity')) {
      context.handle(
        _newQuantityMeta,
        newQuantity.isAcceptableOrUnknown(
          data['new_quantity']!,
          _newQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_newQuantityMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('expiration_date_ms')) {
      context.handle(
        _expirationDateMsMeta,
        expirationDateMs.isAcceptableOrUnknown(
          data['expiration_date_ms']!,
          _expirationDateMsMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      movementType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      previousQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}previous_quantity'],
      )!,
      newQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}new_quantity'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
      expirationDateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expiration_date_ms'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovementRow extends DataClass with $StockMovementsTableToColumns {
  @override
  final String id;
  @override
  final String productId;
  @override
  final String movementType;
  @override
  final double quantity;
  @override
  final double previousQuantity;
  @override
  final double newQuantity;
  @override
  final String note;
  @override
  final String reference;
  @override
  final int? expirationDateMs;
  @override
  final int createdAtMs;
  @override
  final bool isDirty;
  const StockMovementRow({
    required this.id,
    required this.productId,
    required this.movementType,
    required this.quantity,
    required this.previousQuantity,
    required this.newQuantity,
    required this.note,
    required this.reference,
    this.expirationDateMs,
    required this.createdAtMs,
    required this.isDirty,
  });
  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      movementType: Value(movementType),
      quantity: Value(quantity),
      previousQuantity: Value(previousQuantity),
      newQuantity: Value(newQuantity),
      note: Value(note),
      reference: Value(reference),
      expirationDateMs: expirationDateMs == null && nullToAbsent
          ? const Value.absent()
          : Value(expirationDateMs),
      createdAtMs: Value(createdAtMs),
      isDirty: Value(isDirty),
    );
  }

  factory StockMovementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovementRow(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      movementType: serializer.fromJson<String>(json['movementType']),
      quantity: serializer.fromJson<double>(json['quantity']),
      previousQuantity: serializer.fromJson<double>(json['previousQuantity']),
      newQuantity: serializer.fromJson<double>(json['newQuantity']),
      note: serializer.fromJson<String>(json['note']),
      reference: serializer.fromJson<String>(json['reference']),
      expirationDateMs: serializer.fromJson<int?>(json['expirationDateMs']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'movementType': serializer.toJson<String>(movementType),
      'quantity': serializer.toJson<double>(quantity),
      'previousQuantity': serializer.toJson<double>(previousQuantity),
      'newQuantity': serializer.toJson<double>(newQuantity),
      'note': serializer.toJson<String>(note),
      'reference': serializer.toJson<String>(reference),
      'expirationDateMs': serializer.toJson<int?>(expirationDateMs),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  StockMovementRow copyWith({
    String? id,
    String? productId,
    String? movementType,
    double? quantity,
    double? previousQuantity,
    double? newQuantity,
    String? note,
    String? reference,
    Value<int?> expirationDateMs = const Value.absent(),
    int? createdAtMs,
    bool? isDirty,
  }) => StockMovementRow(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    movementType: movementType ?? this.movementType,
    quantity: quantity ?? this.quantity,
    previousQuantity: previousQuantity ?? this.previousQuantity,
    newQuantity: newQuantity ?? this.newQuantity,
    note: note ?? this.note,
    reference: reference ?? this.reference,
    expirationDateMs: expirationDateMs.present
        ? expirationDateMs.value
        : this.expirationDateMs,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    isDirty: isDirty ?? this.isDirty,
  );
  StockMovementRow copyWithCompanion(StockMovementsCompanion data) {
    return StockMovementRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      previousQuantity: data.previousQuantity.present
          ? data.previousQuantity.value
          : this.previousQuantity,
      newQuantity: data.newQuantity.present
          ? data.newQuantity.value
          : this.newQuantity,
      note: data.note.present ? data.note.value : this.note,
      reference: data.reference.present ? data.reference.value : this.reference,
      expirationDateMs: data.expirationDateMs.present
          ? data.expirationDateMs.value
          : this.expirationDateMs,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('movementType: $movementType, ')
          ..write('quantity: $quantity, ')
          ..write('previousQuantity: $previousQuantity, ')
          ..write('newQuantity: $newQuantity, ')
          ..write('note: $note, ')
          ..write('reference: $reference, ')
          ..write('expirationDateMs: $expirationDateMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    movementType,
    quantity,
    previousQuantity,
    newQuantity,
    note,
    reference,
    expirationDateMs,
    createdAtMs,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovementRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.movementType == this.movementType &&
          other.quantity == this.quantity &&
          other.previousQuantity == this.previousQuantity &&
          other.newQuantity == this.newQuantity &&
          other.note == this.note &&
          other.reference == this.reference &&
          other.expirationDateMs == this.expirationDateMs &&
          other.createdAtMs == this.createdAtMs &&
          other.isDirty == this.isDirty);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovementRow> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> movementType;
  final Value<double> quantity;
  final Value<double> previousQuantity;
  final Value<double> newQuantity;
  final Value<String> note;
  final Value<String> reference;
  final Value<int?> expirationDateMs;
  final Value<int> createdAtMs;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.movementType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.previousQuantity = const Value.absent(),
    this.newQuantity = const Value.absent(),
    this.note = const Value.absent(),
    this.reference = const Value.absent(),
    this.expirationDateMs = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    required String productId,
    required String movementType,
    required double quantity,
    required double previousQuantity,
    required double newQuantity,
    this.note = const Value.absent(),
    this.reference = const Value.absent(),
    this.expirationDateMs = const Value.absent(),
    required int createdAtMs,
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       movementType = Value(movementType),
       quantity = Value(quantity),
       previousQuantity = Value(previousQuantity),
       newQuantity = Value(newQuantity),
       createdAtMs = Value(createdAtMs);
  static Insertable<StockMovementRow> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? movementType,
    Expression<double>? quantity,
    Expression<double>? previousQuantity,
    Expression<double>? newQuantity,
    Expression<String>? note,
    Expression<String>? reference,
    Expression<int>? expirationDateMs,
    Expression<int>? createdAtMs,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (movementType != null) 'movement_type': movementType,
      if (quantity != null) 'quantity': quantity,
      if (previousQuantity != null) 'previous_quantity': previousQuantity,
      if (newQuantity != null) 'new_quantity': newQuantity,
      if (note != null) 'note': note,
      if (reference != null) 'reference': reference,
      if (expirationDateMs != null) 'expiration_date_ms': expirationDateMs,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? movementType,
    Value<double>? quantity,
    Value<double>? previousQuantity,
    Value<double>? newQuantity,
    Value<String>? note,
    Value<String>? reference,
    Value<int?>? expirationDateMs,
    Value<int>? createdAtMs,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      movementType: movementType ?? this.movementType,
      quantity: quantity ?? this.quantity,
      previousQuantity: previousQuantity ?? this.previousQuantity,
      newQuantity: newQuantity ?? this.newQuantity,
      note: note ?? this.note,
      reference: reference ?? this.reference,
      expirationDateMs: expirationDateMs ?? this.expirationDateMs,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (previousQuantity.present) {
      map['previous_quantity'] = Variable<double>(previousQuantity.value);
    }
    if (newQuantity.present) {
      map['new_quantity'] = Variable<double>(newQuantity.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (expirationDateMs.present) {
      map['expiration_date_ms'] = Variable<int>(expirationDateMs.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('movementType: $movementType, ')
          ..write('quantity: $quantity, ')
          ..write('previousQuantity: $previousQuantity, ')
          ..write('newQuantity: $newQuantity, ')
          ..write('note: $note, ')
          ..write('reference: $reference, ')
          ..write('expirationDateMs: $expirationDateMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $CustomersTableToColumns implements Insertable<CustomerRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get name;
  String get phone;
  String get address;
  String get notes;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['address'] = Variable<String>(address);
    map['notes'] = Variable<String>(notes);
    return map;
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    phone,
    address,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass with $CustomersTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String name;
  @override
  final String phone;
  @override
  final String address;
  @override
  final String notes;
  const CustomerRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.notes,
  });
  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      address: Value(address),
      notes: Value(notes),
    );
  }

  factory CustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      address: serializer.fromJson<String>(json['address']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'address': serializer.toJson<String>(address),
      'notes': serializer.toJson<String>(notes),
    };
  }

  CustomerRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? name,
    String? phone,
    String? address,
    String? notes,
  }) => CustomerRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    notes: notes ?? this.notes,
  );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    name,
    phone,
    address,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.notes == this.notes);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String> address;
  final Value<String> notes;
  final Value<int> rowid;
  const CustomersCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       name = Value(name);
  static Insertable<CustomerRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String>? address,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $UtangRecordsTableToColumns implements Insertable<UtangRecordRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get customerId;
  String get description;
  double get amount;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    return map;
  }
}

class $UtangRecordsTable extends UtangRecords
    with TableInfo<$UtangRecordsTable, UtangRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UtangRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    customerId,
    description,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'utang_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<UtangRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
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
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UtangRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UtangRecordRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $UtangRecordsTable createAlias(String alias) {
    return $UtangRecordsTable(attachedDatabase, alias);
  }
}

class UtangRecordRow extends DataClass with $UtangRecordsTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String customerId;
  @override
  final String description;
  @override
  final double amount;
  const UtangRecordRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.customerId,
    required this.description,
    required this.amount,
  });
  UtangRecordsCompanion toCompanion(bool nullToAbsent) {
    return UtangRecordsCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      customerId: Value(customerId),
      description: Value(description),
      amount: Value(amount),
    );
  }

  factory UtangRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UtangRecordRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
    };
  }

  UtangRecordRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? customerId,
    String? description,
    double? amount,
  }) => UtangRecordRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    description: description ?? this.description,
    amount: amount ?? this.amount,
  );
  UtangRecordRow copyWithCompanion(UtangRecordsCompanion data) {
    return UtangRecordRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UtangRecordRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('description: $description, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    customerId,
    description,
    amount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UtangRecordRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.description == this.description &&
          other.amount == this.amount);
}

class UtangRecordsCompanion extends UpdateCompanion<UtangRecordRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> customerId;
  final Value<String> description;
  final Value<double> amount;
  final Value<int> rowid;
  const UtangRecordsCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UtangRecordsCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String customerId,
    this.description = const Value.absent(),
    required double amount,
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       customerId = Value(customerId),
       amount = Value(amount);
  static Insertable<UtangRecordRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UtangRecordsCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? customerId,
    Value<String>? description,
    Value<double>? amount,
    Value<int>? rowid,
  }) {
    return UtangRecordsCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UtangRecordsCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $SalesTableToColumns implements Insertable<SaleRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get reference;
  String get note;
  double get subtotal;
  double get totalAmount;
  double get paidAmount;
  double get changeAmount;
  int get totalItems;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['reference'] = Variable<String>(reference);
    map['note'] = Variable<String>(note);
    map['subtotal'] = Variable<double>(subtotal);
    map['total_amount'] = Variable<double>(totalAmount);
    map['paid_amount'] = Variable<double>(paidAmount);
    map['change_amount'] = Variable<double>(changeAmount);
    map['total_items'] = Variable<int>(totalItems);
    return map;
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, SaleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAmountMeta = const VerificationMeta(
    'paidAmount',
  );
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
    'paid_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeAmountMeta = const VerificationMeta(
    'changeAmount',
  );
  @override
  late final GeneratedColumn<double> changeAmount = GeneratedColumn<double>(
    'change_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalItemsMeta = const VerificationMeta(
    'totalItems',
  );
  @override
  late final GeneratedColumn<int> totalItems = GeneratedColumn<int>(
    'total_items',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    reference,
    note,
    subtotal,
    totalAmount,
    paidAmount,
    changeAmount,
    totalItems,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    } else if (isInserting) {
      context.missing(_referenceMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
        _paidAmountMeta,
        paidAmount.isAcceptableOrUnknown(data['paid_amount']!, _paidAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAmountMeta);
    }
    if (data.containsKey('change_amount')) {
      context.handle(
        _changeAmountMeta,
        changeAmount.isAcceptableOrUnknown(
          data['change_amount']!,
          _changeAmountMeta,
        ),
      );
    }
    if (data.containsKey('total_items')) {
      context.handle(
        _totalItemsMeta,
        totalItems.isAcceptableOrUnknown(data['total_items']!, _totalItemsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalItemsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {reference},
  ];
  @override
  SaleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      paidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}paid_amount'],
      )!,
      changeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}change_amount'],
      )!,
      totalItems: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_items'],
      )!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class SaleRow extends DataClass with $SalesTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String reference;
  @override
  final String note;
  @override
  final double subtotal;
  @override
  final double totalAmount;
  @override
  final double paidAmount;
  @override
  final double changeAmount;
  @override
  final int totalItems;
  const SaleRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.reference,
    required this.note,
    required this.subtotal,
    required this.totalAmount,
    required this.paidAmount,
    required this.changeAmount,
    required this.totalItems,
  });
  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      reference: Value(reference),
      note: Value(note),
      subtotal: Value(subtotal),
      totalAmount: Value(totalAmount),
      paidAmount: Value(paidAmount),
      changeAmount: Value(changeAmount),
      totalItems: Value(totalItems),
    );
  }

  factory SaleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      reference: serializer.fromJson<String>(json['reference']),
      note: serializer.fromJson<String>(json['note']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      changeAmount: serializer.fromJson<double>(json['changeAmount']),
      totalItems: serializer.fromJson<int>(json['totalItems']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'reference': serializer.toJson<String>(reference),
      'note': serializer.toJson<String>(note),
      'subtotal': serializer.toJson<double>(subtotal),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'changeAmount': serializer.toJson<double>(changeAmount),
      'totalItems': serializer.toJson<int>(totalItems),
    };
  }

  SaleRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? reference,
    String? note,
    double? subtotal,
    double? totalAmount,
    double? paidAmount,
    double? changeAmount,
    int? totalItems,
  }) => SaleRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    reference: reference ?? this.reference,
    note: note ?? this.note,
    subtotal: subtotal ?? this.subtotal,
    totalAmount: totalAmount ?? this.totalAmount,
    paidAmount: paidAmount ?? this.paidAmount,
    changeAmount: changeAmount ?? this.changeAmount,
    totalItems: totalItems ?? this.totalItems,
  );
  SaleRow copyWithCompanion(SalesCompanion data) {
    return SaleRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      reference: data.reference.present ? data.reference.value : this.reference,
      note: data.note.present ? data.note.value : this.note,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      paidAmount: data.paidAmount.present
          ? data.paidAmount.value
          : this.paidAmount,
      changeAmount: data.changeAmount.present
          ? data.changeAmount.value
          : this.changeAmount,
      totalItems: data.totalItems.present
          ? data.totalItems.value
          : this.totalItems,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('reference: $reference, ')
          ..write('note: $note, ')
          ..write('subtotal: $subtotal, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('totalItems: $totalItems')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    reference,
    note,
    subtotal,
    totalAmount,
    paidAmount,
    changeAmount,
    totalItems,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.reference == this.reference &&
          other.note == this.note &&
          other.subtotal == this.subtotal &&
          other.totalAmount == this.totalAmount &&
          other.paidAmount == this.paidAmount &&
          other.changeAmount == this.changeAmount &&
          other.totalItems == this.totalItems);
}

class SalesCompanion extends UpdateCompanion<SaleRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> reference;
  final Value<String> note;
  final Value<double> subtotal;
  final Value<double> totalAmount;
  final Value<double> paidAmount;
  final Value<double> changeAmount;
  final Value<int> totalItems;
  final Value<int> rowid;
  const SalesCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.reference = const Value.absent(),
    this.note = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.changeAmount = const Value.absent(),
    this.totalItems = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String reference,
    this.note = const Value.absent(),
    required double subtotal,
    required double totalAmount,
    required double paidAmount,
    this.changeAmount = const Value.absent(),
    required int totalItems,
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       reference = Value(reference),
       subtotal = Value(subtotal),
       totalAmount = Value(totalAmount),
       paidAmount = Value(paidAmount),
       totalItems = Value(totalItems);
  static Insertable<SaleRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? reference,
    Expression<String>? note,
    Expression<double>? subtotal,
    Expression<double>? totalAmount,
    Expression<double>? paidAmount,
    Expression<double>? changeAmount,
    Expression<int>? totalItems,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (reference != null) 'reference': reference,
      if (note != null) 'note': note,
      if (subtotal != null) 'subtotal': subtotal,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (changeAmount != null) 'change_amount': changeAmount,
      if (totalItems != null) 'total_items': totalItems,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? reference,
    Value<String>? note,
    Value<double>? subtotal,
    Value<double>? totalAmount,
    Value<double>? paidAmount,
    Value<double>? changeAmount,
    Value<int>? totalItems,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      reference: reference ?? this.reference,
      note: note ?? this.note,
      subtotal: subtotal ?? this.subtotal,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      totalItems: totalItems ?? this.totalItems,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (changeAmount.present) {
      map['change_amount'] = Variable<double>(changeAmount.value);
    }
    if (totalItems.present) {
      map['total_items'] = Variable<int>(totalItems.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('reference: $reference, ')
          ..write('note: $note, ')
          ..write('subtotal: $subtotal, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('totalItems: $totalItems, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $SaleItemsTableToColumns implements Insertable<SaleItemRow> {
  String get id;
  String get saleId;
  String get productId;
  String get selectedUnit;
  double get quantity;
  double get unitPrice;
  double get computedBaseQuantity;
  double get lineTotal;
  int get createdAtMs;
  bool get isDirty;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['product_id'] = Variable<String>(productId);
    map['selected_unit'] = Variable<String>(selectedUnit);
    map['quantity'] = Variable<double>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['computed_base_quantity'] = Variable<double>(computedBaseQuantity);
    map['line_total'] = Variable<double>(lineTotal);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }
}

class $SaleItemsTable extends SaleItems
    with TableInfo<$SaleItemsTable, SaleItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _selectedUnitMeta = const VerificationMeta(
    'selectedUnit',
  );
  @override
  late final GeneratedColumn<String> selectedUnit = GeneratedColumn<String>(
    'selected_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _computedBaseQuantityMeta =
      const VerificationMeta('computedBaseQuantity');
  @override
  late final GeneratedColumn<double> computedBaseQuantity =
      GeneratedColumn<double>(
        'computed_base_quantity',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lineTotalMeta = const VerificationMeta(
    'lineTotal',
  );
  @override
  late final GeneratedColumn<double> lineTotal = GeneratedColumn<double>(
    'line_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    productId,
    selectedUnit,
    quantity,
    unitPrice,
    computedBaseQuantity,
    lineTotal,
    createdAtMs,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('selected_unit')) {
      context.handle(
        _selectedUnitMeta,
        selectedUnit.isAcceptableOrUnknown(
          data['selected_unit']!,
          _selectedUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedUnitMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('computed_base_quantity')) {
      context.handle(
        _computedBaseQuantityMeta,
        computedBaseQuantity.isAcceptableOrUnknown(
          data['computed_base_quantity']!,
          _computedBaseQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_computedBaseQuantityMeta);
    }
    if (data.containsKey('line_total')) {
      context.handle(
        _lineTotalMeta,
        lineTotal.isAcceptableOrUnknown(data['line_total']!, _lineTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_lineTotalMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      selectedUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_unit'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      computedBaseQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}computed_base_quantity'],
      )!,
      lineTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}line_total'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $SaleItemsTable createAlias(String alias) {
    return $SaleItemsTable(attachedDatabase, alias);
  }
}

class SaleItemRow extends DataClass with $SaleItemsTableToColumns {
  @override
  final String id;
  @override
  final String saleId;
  @override
  final String productId;
  @override
  final String selectedUnit;
  @override
  final double quantity;
  @override
  final double unitPrice;
  @override
  final double computedBaseQuantity;
  @override
  final double lineTotal;
  @override
  final int createdAtMs;
  @override
  final bool isDirty;
  const SaleItemRow({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.selectedUnit,
    required this.quantity,
    required this.unitPrice,
    required this.computedBaseQuantity,
    required this.lineTotal,
    required this.createdAtMs,
    required this.isDirty,
  });
  SaleItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      productId: Value(productId),
      selectedUnit: Value(selectedUnit),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      computedBaseQuantity: Value(computedBaseQuantity),
      lineTotal: Value(lineTotal),
      createdAtMs: Value(createdAtMs),
      isDirty: Value(isDirty),
    );
  }

  factory SaleItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItemRow(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String>(json['productId']),
      selectedUnit: serializer.fromJson<String>(json['selectedUnit']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      computedBaseQuantity: serializer.fromJson<double>(
        json['computedBaseQuantity'],
      ),
      lineTotal: serializer.fromJson<double>(json['lineTotal']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String>(productId),
      'selectedUnit': serializer.toJson<String>(selectedUnit),
      'quantity': serializer.toJson<double>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'computedBaseQuantity': serializer.toJson<double>(computedBaseQuantity),
      'lineTotal': serializer.toJson<double>(lineTotal),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  SaleItemRow copyWith({
    String? id,
    String? saleId,
    String? productId,
    String? selectedUnit,
    double? quantity,
    double? unitPrice,
    double? computedBaseQuantity,
    double? lineTotal,
    int? createdAtMs,
    bool? isDirty,
  }) => SaleItemRow(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    selectedUnit: selectedUnit ?? this.selectedUnit,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    computedBaseQuantity: computedBaseQuantity ?? this.computedBaseQuantity,
    lineTotal: lineTotal ?? this.lineTotal,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    isDirty: isDirty ?? this.isDirty,
  );
  SaleItemRow copyWithCompanion(SaleItemsCompanion data) {
    return SaleItemRow(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      selectedUnit: data.selectedUnit.present
          ? data.selectedUnit.value
          : this.selectedUnit,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      computedBaseQuantity: data.computedBaseQuantity.present
          ? data.computedBaseQuantity.value
          : this.computedBaseQuantity,
      lineTotal: data.lineTotal.present ? data.lineTotal.value : this.lineTotal,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemRow(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('selectedUnit: $selectedUnit, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('computedBaseQuantity: $computedBaseQuantity, ')
          ..write('lineTotal: $lineTotal, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleId,
    productId,
    selectedUnit,
    quantity,
    unitPrice,
    computedBaseQuantity,
    lineTotal,
    createdAtMs,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItemRow &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.selectedUnit == this.selectedUnit &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.computedBaseQuantity == this.computedBaseQuantity &&
          other.lineTotal == this.lineTotal &&
          other.createdAtMs == this.createdAtMs &&
          other.isDirty == this.isDirty);
}

class SaleItemsCompanion extends UpdateCompanion<SaleItemRow> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String> productId;
  final Value<String> selectedUnit;
  final Value<double> quantity;
  final Value<double> unitPrice;
  final Value<double> computedBaseQuantity;
  final Value<double> lineTotal;
  final Value<int> createdAtMs;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const SaleItemsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.selectedUnit = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.computedBaseQuantity = const Value.absent(),
    this.lineTotal = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleItemsCompanion.insert({
    required String id,
    required String saleId,
    required String productId,
    required String selectedUnit,
    required double quantity,
    required double unitPrice,
    required double computedBaseQuantity,
    required double lineTotal,
    required int createdAtMs,
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       productId = Value(productId),
       selectedUnit = Value(selectedUnit),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice),
       computedBaseQuantity = Value(computedBaseQuantity),
       lineTotal = Value(lineTotal),
       createdAtMs = Value(createdAtMs);
  static Insertable<SaleItemRow> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<String>? selectedUnit,
    Expression<double>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? computedBaseQuantity,
    Expression<double>? lineTotal,
    Expression<int>? createdAtMs,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (selectedUnit != null) 'selected_unit': selectedUnit,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (computedBaseQuantity != null)
        'computed_base_quantity': computedBaseQuantity,
      if (lineTotal != null) 'line_total': lineTotal,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? saleId,
    Value<String>? productId,
    Value<String>? selectedUnit,
    Value<double>? quantity,
    Value<double>? unitPrice,
    Value<double>? computedBaseQuantity,
    Value<double>? lineTotal,
    Value<int>? createdAtMs,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return SaleItemsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      computedBaseQuantity: computedBaseQuantity ?? this.computedBaseQuantity,
      lineTotal: lineTotal ?? this.lineTotal,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (selectedUnit.present) {
      map['selected_unit'] = Variable<String>(selectedUnit.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (computedBaseQuantity.present) {
      map['computed_base_quantity'] = Variable<double>(
        computedBaseQuantity.value,
      );
    }
    if (lineTotal.present) {
      map['line_total'] = Variable<double>(lineTotal.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('selectedUnit: $selectedUnit, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('computedBaseQuantity: $computedBaseQuantity, ')
          ..write('lineTotal: $lineTotal, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $BusinessProfilesTableToColumns
    implements Insertable<BusinessProfileRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get businessType;
  String get businessName;
  String get defaultCurrency;
  String get preferencesJson;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['business_type'] = Variable<String>(businessType);
    map['business_name'] = Variable<String>(businessName);
    map['default_currency'] = Variable<String>(defaultCurrency);
    map['preferences_json'] = Variable<String>(preferencesJson);
    return map;
  }
}

class $BusinessProfilesTable extends BusinessProfiles
    with TableInfo<$BusinessProfilesTable, BusinessProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessTypeMeta = const VerificationMeta(
    'businessType',
  );
  @override
  late final GeneratedColumn<String> businessType = GeneratedColumn<String>(
    'business_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessNameMeta = const VerificationMeta(
    'businessName',
  );
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
    'business_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultCurrencyMeta = const VerificationMeta(
    'defaultCurrency',
  );
  @override
  late final GeneratedColumn<String> defaultCurrency = GeneratedColumn<String>(
    'default_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PHP'),
  );
  static const VerificationMeta _preferencesJsonMeta = const VerificationMeta(
    'preferencesJson',
  );
  @override
  late final GeneratedColumn<String> preferencesJson = GeneratedColumn<String>(
    'preferences_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    businessType,
    businessName,
    defaultCurrency,
    preferencesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'business_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<BusinessProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_type')) {
      context.handle(
        _businessTypeMeta,
        businessType.isAcceptableOrUnknown(
          data['business_type']!,
          _businessTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessTypeMeta);
    }
    if (data.containsKey('business_name')) {
      context.handle(
        _businessNameMeta,
        businessName.isAcceptableOrUnknown(
          data['business_name']!,
          _businessNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessNameMeta);
    }
    if (data.containsKey('default_currency')) {
      context.handle(
        _defaultCurrencyMeta,
        defaultCurrency.isAcceptableOrUnknown(
          data['default_currency']!,
          _defaultCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('preferences_json')) {
      context.handle(
        _preferencesJsonMeta,
        preferencesJson.isAcceptableOrUnknown(
          data['preferences_json']!,
          _preferencesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BusinessProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BusinessProfileRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_type'],
      )!,
      businessName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_name'],
      )!,
      defaultCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_currency'],
      )!,
      preferencesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferences_json'],
      )!,
    );
  }

  @override
  $BusinessProfilesTable createAlias(String alias) {
    return $BusinessProfilesTable(attachedDatabase, alias);
  }
}

class BusinessProfileRow extends DataClass
    with $BusinessProfilesTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String businessType;
  @override
  final String businessName;
  @override
  final String defaultCurrency;
  @override
  final String preferencesJson;
  const BusinessProfileRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.businessType,
    required this.businessName,
    required this.defaultCurrency,
    required this.preferencesJson,
  });
  BusinessProfilesCompanion toCompanion(bool nullToAbsent) {
    return BusinessProfilesCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      businessType: Value(businessType),
      businessName: Value(businessName),
      defaultCurrency: Value(defaultCurrency),
      preferencesJson: Value(preferencesJson),
    );
  }

  factory BusinessProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BusinessProfileRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      businessType: serializer.fromJson<String>(json['businessType']),
      businessName: serializer.fromJson<String>(json['businessName']),
      defaultCurrency: serializer.fromJson<String>(json['defaultCurrency']),
      preferencesJson: serializer.fromJson<String>(json['preferencesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'businessType': serializer.toJson<String>(businessType),
      'businessName': serializer.toJson<String>(businessName),
      'defaultCurrency': serializer.toJson<String>(defaultCurrency),
      'preferencesJson': serializer.toJson<String>(preferencesJson),
    };
  }

  BusinessProfileRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? businessType,
    String? businessName,
    String? defaultCurrency,
    String? preferencesJson,
  }) => BusinessProfileRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    businessType: businessType ?? this.businessType,
    businessName: businessName ?? this.businessName,
    defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    preferencesJson: preferencesJson ?? this.preferencesJson,
  );
  BusinessProfileRow copyWithCompanion(BusinessProfilesCompanion data) {
    return BusinessProfileRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      businessType: data.businessType.present
          ? data.businessType.value
          : this.businessType,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      defaultCurrency: data.defaultCurrency.present
          ? data.defaultCurrency.value
          : this.defaultCurrency,
      preferencesJson: data.preferencesJson.present
          ? data.preferencesJson.value
          : this.preferencesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BusinessProfileRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('businessType: $businessType, ')
          ..write('businessName: $businessName, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('preferencesJson: $preferencesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    businessType,
    businessName,
    defaultCurrency,
    preferencesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessProfileRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.businessType == this.businessType &&
          other.businessName == this.businessName &&
          other.defaultCurrency == this.defaultCurrency &&
          other.preferencesJson == this.preferencesJson);
}

class BusinessProfilesCompanion extends UpdateCompanion<BusinessProfileRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> businessType;
  final Value<String> businessName;
  final Value<String> defaultCurrency;
  final Value<String> preferencesJson;
  final Value<int> rowid;
  const BusinessProfilesCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.businessType = const Value.absent(),
    this.businessName = const Value.absent(),
    this.defaultCurrency = const Value.absent(),
    this.preferencesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BusinessProfilesCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String businessType,
    required String businessName,
    this.defaultCurrency = const Value.absent(),
    this.preferencesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       businessType = Value(businessType),
       businessName = Value(businessName);
  static Insertable<BusinessProfileRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? businessType,
    Expression<String>? businessName,
    Expression<String>? defaultCurrency,
    Expression<String>? preferencesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (businessType != null) 'business_type': businessType,
      if (businessName != null) 'business_name': businessName,
      if (defaultCurrency != null) 'default_currency': defaultCurrency,
      if (preferencesJson != null) 'preferences_json': preferencesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BusinessProfilesCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? businessType,
    Value<String>? businessName,
    Value<String>? defaultCurrency,
    Value<String>? preferencesJson,
    Value<int>? rowid,
  }) {
    return BusinessProfilesCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      businessType: businessType ?? this.businessType,
      businessName: businessName ?? this.businessName,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      preferencesJson: preferencesJson ?? this.preferencesJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessType.present) {
      map['business_type'] = Variable<String>(businessType.value);
    }
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (defaultCurrency.present) {
      map['default_currency'] = Variable<String>(defaultCurrency.value);
    }
    if (preferencesJson.present) {
      map['preferences_json'] = Variable<String>(preferencesJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessProfilesCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('businessType: $businessType, ')
          ..write('businessName: $businessName, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('preferencesJson: $preferencesJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $ProductSerialNumbersTableToColumns
    implements Insertable<ProductSerialNumberRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get productId;
  String get serialNumber;
  String get status;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['serial_number'] = Variable<String>(serialNumber);
    map['status'] = Variable<String>(status);
    return map;
  }
}

class $ProductSerialNumbersTable extends ProductSerialNumbers
    with TableInfo<$ProductSerialNumbersTable, ProductSerialNumberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductSerialNumbersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _serialNumberMeta = const VerificationMeta(
    'serialNumber',
  );
  @override
  late final GeneratedColumn<String> serialNumber = GeneratedColumn<String>(
    'serial_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('AVAILABLE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    productId,
    serialNumber,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_serial_numbers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductSerialNumberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('serial_number')) {
      context.handle(
        _serialNumberMeta,
        serialNumber.isAcceptableOrUnknown(
          data['serial_number']!,
          _serialNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serialNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {productId, serialNumber},
  ];
  @override
  ProductSerialNumberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductSerialNumberRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      serialNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $ProductSerialNumbersTable createAlias(String alias) {
    return $ProductSerialNumbersTable(attachedDatabase, alias);
  }
}

class ProductSerialNumberRow extends DataClass
    with $ProductSerialNumbersTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String productId;
  @override
  final String serialNumber;
  @override
  final String status;
  const ProductSerialNumberRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.productId,
    required this.serialNumber,
    required this.status,
  });
  ProductSerialNumbersCompanion toCompanion(bool nullToAbsent) {
    return ProductSerialNumbersCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      productId: Value(productId),
      serialNumber: Value(serialNumber),
      status: Value(status),
    );
  }

  factory ProductSerialNumberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductSerialNumberRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      serialNumber: serializer.fromJson<String>(json['serialNumber']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'serialNumber': serializer.toJson<String>(serialNumber),
      'status': serializer.toJson<String>(status),
    };
  }

  ProductSerialNumberRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? productId,
    String? serialNumber,
    String? status,
  }) => ProductSerialNumberRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    productId: productId ?? this.productId,
    serialNumber: serialNumber ?? this.serialNumber,
    status: status ?? this.status,
  );
  ProductSerialNumberRow copyWithCompanion(ProductSerialNumbersCompanion data) {
    return ProductSerialNumberRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      serialNumber: data.serialNumber.present
          ? data.serialNumber.value
          : this.serialNumber,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductSerialNumberRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    productId,
    serialNumber,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductSerialNumberRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.serialNumber == this.serialNumber &&
          other.status == this.status);
}

class ProductSerialNumbersCompanion
    extends UpdateCompanion<ProductSerialNumberRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> productId;
  final Value<String> serialNumber;
  final Value<String> status;
  final Value<int> rowid;
  const ProductSerialNumbersCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductSerialNumbersCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String productId,
    required String serialNumber,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       productId = Value(productId),
       serialNumber = Value(serialNumber);
  static Insertable<ProductSerialNumberRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? serialNumber,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductSerialNumbersCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? productId,
    Value<String>? serialNumber,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return ProductSerialNumbersCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      productId: productId ?? this.productId,
      serialNumber: serialNumber ?? this.serialNumber,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (serialNumber.present) {
      map['serial_number'] = Variable<String>(serialNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductSerialNumbersCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

mixin $ProductRecipeIngredientsTableToColumns
    implements Insertable<ProductRecipeIngredientRow> {
  String get syncId;
  String get deviceId;
  bool get isDeleted;
  bool get isDirty;
  int get createdAtMs;
  int get updatedAtMs;
  String get id;
  String get recipeProductId;
  String get ingredientProductId;
  double get quantityNeeded;
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['device_id'] = Variable<String>(deviceId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    map['id'] = Variable<String>(id);
    map['recipe_product_id'] = Variable<String>(recipeProductId);
    map['ingredient_product_id'] = Variable<String>(ingredientProductId);
    map['quantity_needed'] = Variable<double>(quantityNeeded);
    return map;
  }
}

class $ProductRecipeIngredientsTable extends ProductRecipeIngredients
    with TableInfo<$ProductRecipeIngredientsTable, ProductRecipeIngredientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductRecipeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeProductIdMeta = const VerificationMeta(
    'recipeProductId',
  );
  @override
  late final GeneratedColumn<String> recipeProductId = GeneratedColumn<String>(
    'recipe_product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _ingredientProductIdMeta =
      const VerificationMeta('ingredientProductId');
  @override
  late final GeneratedColumn<String> ingredientProductId =
      GeneratedColumn<String>(
        'ingredient_product_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES products (id)',
        ),
      );
  static const VerificationMeta _quantityNeededMeta = const VerificationMeta(
    'quantityNeeded',
  );
  @override
  late final GeneratedColumn<double> quantityNeeded = GeneratedColumn<double>(
    'quantity_needed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    recipeProductId,
    ingredientProductId,
    quantityNeeded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRecipeIngredientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_product_id')) {
      context.handle(
        _recipeProductIdMeta,
        recipeProductId.isAcceptableOrUnknown(
          data['recipe_product_id']!,
          _recipeProductIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recipeProductIdMeta);
    }
    if (data.containsKey('ingredient_product_id')) {
      context.handle(
        _ingredientProductIdMeta,
        ingredientProductId.isAcceptableOrUnknown(
          data['ingredient_product_id']!,
          _ingredientProductIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientProductIdMeta);
    }
    if (data.containsKey('quantity_needed')) {
      context.handle(
        _quantityNeededMeta,
        quantityNeeded.isAcceptableOrUnknown(
          data['quantity_needed']!,
          _quantityNeededMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityNeededMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {recipeProductId, ingredientProductId},
  ];
  @override
  ProductRecipeIngredientRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRecipeIngredientRow(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_product_id'],
      )!,
      ingredientProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_product_id'],
      )!,
      quantityNeeded: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_needed'],
      )!,
    );
  }

  @override
  $ProductRecipeIngredientsTable createAlias(String alias) {
    return $ProductRecipeIngredientsTable(attachedDatabase, alias);
  }
}

class ProductRecipeIngredientRow extends DataClass
    with $ProductRecipeIngredientsTableToColumns {
  @override
  final String syncId;
  @override
  final String deviceId;
  @override
  final bool isDeleted;
  @override
  final bool isDirty;
  @override
  final int createdAtMs;
  @override
  final int updatedAtMs;
  @override
  final String id;
  @override
  final String recipeProductId;
  @override
  final String ingredientProductId;
  @override
  final double quantityNeeded;
  const ProductRecipeIngredientRow({
    required this.syncId,
    required this.deviceId,
    required this.isDeleted,
    required this.isDirty,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.id,
    required this.recipeProductId,
    required this.ingredientProductId,
    required this.quantityNeeded,
  });
  ProductRecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return ProductRecipeIngredientsCompanion(
      syncId: Value(syncId),
      deviceId: Value(deviceId),
      isDeleted: Value(isDeleted),
      isDirty: Value(isDirty),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      id: Value(id),
      recipeProductId: Value(recipeProductId),
      ingredientProductId: Value(ingredientProductId),
      quantityNeeded: Value(quantityNeeded),
    );
  }

  factory ProductRecipeIngredientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRecipeIngredientRow(
      syncId: serializer.fromJson<String>(json['syncId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      recipeProductId: serializer.fromJson<String>(json['recipeProductId']),
      ingredientProductId: serializer.fromJson<String>(
        json['ingredientProductId'],
      ),
      quantityNeeded: serializer.fromJson<double>(json['quantityNeeded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'deviceId': serializer.toJson<String>(deviceId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'id': serializer.toJson<String>(id),
      'recipeProductId': serializer.toJson<String>(recipeProductId),
      'ingredientProductId': serializer.toJson<String>(ingredientProductId),
      'quantityNeeded': serializer.toJson<double>(quantityNeeded),
    };
  }

  ProductRecipeIngredientRow copyWith({
    String? syncId,
    String? deviceId,
    bool? isDeleted,
    bool? isDirty,
    int? createdAtMs,
    int? updatedAtMs,
    String? id,
    String? recipeProductId,
    String? ingredientProductId,
    double? quantityNeeded,
  }) => ProductRecipeIngredientRow(
    syncId: syncId ?? this.syncId,
    deviceId: deviceId ?? this.deviceId,
    isDeleted: isDeleted ?? this.isDeleted,
    isDirty: isDirty ?? this.isDirty,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    id: id ?? this.id,
    recipeProductId: recipeProductId ?? this.recipeProductId,
    ingredientProductId: ingredientProductId ?? this.ingredientProductId,
    quantityNeeded: quantityNeeded ?? this.quantityNeeded,
  );
  ProductRecipeIngredientRow copyWithCompanion(
    ProductRecipeIngredientsCompanion data,
  ) {
    return ProductRecipeIngredientRow(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      id: data.id.present ? data.id.value : this.id,
      recipeProductId: data.recipeProductId.present
          ? data.recipeProductId.value
          : this.recipeProductId,
      ingredientProductId: data.ingredientProductId.present
          ? data.ingredientProductId.value
          : this.ingredientProductId,
      quantityNeeded: data.quantityNeeded.present
          ? data.quantityNeeded.value
          : this.quantityNeeded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRecipeIngredientRow(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('recipeProductId: $recipeProductId, ')
          ..write('ingredientProductId: $ingredientProductId, ')
          ..write('quantityNeeded: $quantityNeeded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAtMs,
    updatedAtMs,
    id,
    recipeProductId,
    ingredientProductId,
    quantityNeeded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRecipeIngredientRow &&
          other.syncId == this.syncId &&
          other.deviceId == this.deviceId &&
          other.isDeleted == this.isDeleted &&
          other.isDirty == this.isDirty &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.id == this.id &&
          other.recipeProductId == this.recipeProductId &&
          other.ingredientProductId == this.ingredientProductId &&
          other.quantityNeeded == this.quantityNeeded);
}

class ProductRecipeIngredientsCompanion
    extends UpdateCompanion<ProductRecipeIngredientRow> {
  final Value<String> syncId;
  final Value<String> deviceId;
  final Value<bool> isDeleted;
  final Value<bool> isDirty;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<String> id;
  final Value<String> recipeProductId;
  final Value<String> ingredientProductId;
  final Value<double> quantityNeeded;
  final Value<int> rowid;
  const ProductRecipeIngredientsCompanion({
    this.syncId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.recipeProductId = const Value.absent(),
    this.ingredientProductId = const Value.absent(),
    this.quantityNeeded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductRecipeIngredientsCompanion.insert({
    required String syncId,
    this.deviceId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    required String id,
    required String recipeProductId,
    required String ingredientProductId,
    required double quantityNeeded,
    this.rowid = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs),
       id = Value(id),
       recipeProductId = Value(recipeProductId),
       ingredientProductId = Value(ingredientProductId),
       quantityNeeded = Value(quantityNeeded);
  static Insertable<ProductRecipeIngredientRow> custom({
    Expression<String>? syncId,
    Expression<String>? deviceId,
    Expression<bool>? isDeleted,
    Expression<bool>? isDirty,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<String>? id,
    Expression<String>? recipeProductId,
    Expression<String>? ingredientProductId,
    Expression<double>? quantityNeeded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (deviceId != null) 'device_id': deviceId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (id != null) 'id': id,
      if (recipeProductId != null) 'recipe_product_id': recipeProductId,
      if (ingredientProductId != null)
        'ingredient_product_id': ingredientProductId,
      if (quantityNeeded != null) 'quantity_needed': quantityNeeded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductRecipeIngredientsCompanion copyWith({
    Value<String>? syncId,
    Value<String>? deviceId,
    Value<bool>? isDeleted,
    Value<bool>? isDirty,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<String>? id,
    Value<String>? recipeProductId,
    Value<String>? ingredientProductId,
    Value<double>? quantityNeeded,
    Value<int>? rowid,
  }) {
    return ProductRecipeIngredientsCompanion(
      syncId: syncId ?? this.syncId,
      deviceId: deviceId ?? this.deviceId,
      isDeleted: isDeleted ?? this.isDeleted,
      isDirty: isDirty ?? this.isDirty,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      id: id ?? this.id,
      recipeProductId: recipeProductId ?? this.recipeProductId,
      ingredientProductId: ingredientProductId ?? this.ingredientProductId,
      quantityNeeded: quantityNeeded ?? this.quantityNeeded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeProductId.present) {
      map['recipe_product_id'] = Variable<String>(recipeProductId.value);
    }
    if (ingredientProductId.present) {
      map['ingredient_product_id'] = Variable<String>(
        ingredientProductId.value,
      );
    }
    if (quantityNeeded.present) {
      map['quantity_needed'] = Variable<double>(quantityNeeded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductRecipeIngredientsCompanion(')
          ..write('syncId: $syncId, ')
          ..write('deviceId: $deviceId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('id: $id, ')
          ..write('recipeProductId: $recipeProductId, ')
          ..write('ingredientProductId: $ingredientProductId, ')
          ..write('quantityNeeded: $quantityNeeded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  _$AppDatabase.connect(DatabaseConnection c) : super.connect(c);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $ChargesTable charges = $ChargesTable(this);
  late final $PartiesTable parties = $PartiesTable(this);
  late final $TransactionTypesTable transactionTypes = $TransactionTypesTable(
    this,
  );
  late final $MovementCategoriesTable movementCategories =
      $MovementCategoriesTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $FeeTransactionsTable feeTransactions = $FeeTransactionsTable(
    this,
  );
  late final $MonitoringSessionsTable monitoringSessions =
      $MonitoringSessionsTable(this);
  late final $ProductCategoriesTable productCategories =
      $ProductCategoriesTable(this);
  late final $ShelfLocationsTable shelfLocations = $ShelfLocationsTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ProductUnitConversionsTable productUnitConversions =
      $ProductUnitConversionsTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $UtangRecordsTable utangRecords = $UtangRecordsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleItemsTable saleItems = $SaleItemsTable(this);
  late final $BusinessProfilesTable businessProfiles = $BusinessProfilesTable(
    this,
  );
  late final $ProductSerialNumbersTable productSerialNumbers =
      $ProductSerialNumbersTable(this);
  late final $ProductRecipeIngredientsTable productRecipeIngredients =
      $ProductRecipeIngredientsTable(this);
  late final Index chargesIsDirtyIdx = Index(
    'charges_is_dirty_idx',
    'CREATE INDEX charges_is_dirty_idx ON charges (is_dirty)',
  );
  late final Index chargesTransactionTypeKeyIdx = Index(
    'charges_transaction_type_key_idx',
    'CREATE INDEX charges_transaction_type_key_idx ON charges (transaction_type_key)',
  );
  late final Index partiesIsDirtyIdx = Index(
    'parties_is_dirty_idx',
    'CREATE INDEX parties_is_dirty_idx ON parties (is_dirty)',
  );
  late final Index partiesNameIdx = Index(
    'parties_name_idx',
    'CREATE INDEX parties_name_idx ON parties (name)',
  );
  late final Index transactionTypesIsDirtyIdx = Index(
    'transaction_types_is_dirty_idx',
    'CREATE INDEX transaction_types_is_dirty_idx ON transaction_types (is_dirty)',
  );
  late final Index movementCategoriesIsDirtyIdx = Index(
    'movement_categories_is_dirty_idx',
    'CREATE INDEX movement_categories_is_dirty_idx ON movement_categories (is_dirty)',
  );
  late final Index ledgerEntriesTransactionIdIdx = Index(
    'ledger_entries_transaction_id_idx',
    'CREATE INDEX ledger_entries_transaction_id_idx ON ledger_entries (transaction_id)',
  );
  late final Index ledgerEntriesEntryDateIdx = Index(
    'ledger_entries_entry_date_idx',
    'CREATE INDEX ledger_entries_entry_date_idx ON ledger_entries (entry_date)',
  );
  late final Index ledgerEntriesIsDirtyIdx = Index(
    'ledger_entries_is_dirty_idx',
    'CREATE INDEX ledger_entries_is_dirty_idx ON ledger_entries (is_dirty)',
  );
  late final Index ledgerEntriesUpdatedAtMsIdx = Index(
    'ledger_entries_updated_at_ms_idx',
    'CREATE INDEX ledger_entries_updated_at_ms_idx ON ledger_entries (updated_at_ms)',
  );
  late final Index transactionsEntryDateIdx = Index(
    'transactions_entry_date_idx',
    'CREATE INDEX transactions_entry_date_idx ON transactions (entry_date)',
  );
  late final Index transactionsIsDirtyIdx = Index(
    'transactions_is_dirty_idx',
    'CREATE INDEX transactions_is_dirty_idx ON transactions (is_dirty)',
  );
  late final Index transactionsUpdatedAtMsIdx = Index(
    'transactions_updated_at_ms_idx',
    'CREATE INDEX transactions_updated_at_ms_idx ON transactions (updated_at_ms)',
  );
  late final Index feeTransactionsRelatedTransactionSyncIdIdx = Index(
    'fee_transactions_related_transaction_sync_id_idx',
    'CREATE INDEX fee_transactions_related_transaction_sync_id_idx ON fee_transactions (related_transaction_sync_id)',
  );
  late final Index feeTransactionsIsDirtyIdx = Index(
    'fee_transactions_is_dirty_idx',
    'CREATE INDEX fee_transactions_is_dirty_idx ON fee_transactions (is_dirty)',
  );
  late final Index productCategoriesIsDirtyIdx = Index(
    'product_categories_is_dirty_idx',
    'CREATE INDEX product_categories_is_dirty_idx ON product_categories (is_dirty)',
  );
  late final Index shelfLocationsIsDirtyIdx = Index(
    'shelf_locations_is_dirty_idx',
    'CREATE INDEX shelf_locations_is_dirty_idx ON shelf_locations (is_dirty)',
  );
  late final Index productsCategoryIdIdx = Index(
    'products_category_id_idx',
    'CREATE INDEX products_category_id_idx ON products (category_id)',
  );
  late final Index productsShelfLocationIdIdx = Index(
    'products_shelf_location_id_idx',
    'CREATE INDEX products_shelf_location_id_idx ON products (shelf_location_id)',
  );
  late final Index productsIsDirtyIdx = Index(
    'products_is_dirty_idx',
    'CREATE INDEX products_is_dirty_idx ON products (is_dirty)',
  );
  late final Index productsNameIdx = Index(
    'products_name_idx',
    'CREATE INDEX products_name_idx ON products (name)',
  );
  late final Index productUnitConversionsProductIdIdx = Index(
    'product_unit_conversions_product_id_idx',
    'CREATE INDEX product_unit_conversions_product_id_idx ON product_unit_conversions (product_id)',
  );
  late final Index productUnitConversionsIsDirtyIdx = Index(
    'product_unit_conversions_is_dirty_idx',
    'CREATE INDEX product_unit_conversions_is_dirty_idx ON product_unit_conversions (is_dirty)',
  );
  late final Index stockMovementsProductIdIdx = Index(
    'stock_movements_product_id_idx',
    'CREATE INDEX stock_movements_product_id_idx ON stock_movements (product_id)',
  );
  late final Index stockMovementsIsDirtyIdx = Index(
    'stock_movements_is_dirty_idx',
    'CREATE INDEX stock_movements_is_dirty_idx ON stock_movements (is_dirty)',
  );
  late final Index stockMovementsCreatedAtMsIdx = Index(
    'stock_movements_created_at_ms_idx',
    'CREATE INDEX stock_movements_created_at_ms_idx ON stock_movements (created_at_ms)',
  );
  late final Index customersIsDirtyIdx = Index(
    'customers_is_dirty_idx',
    'CREATE INDEX customers_is_dirty_idx ON customers (is_dirty)',
  );
  late final Index customersNameIdx = Index(
    'customers_name_idx',
    'CREATE INDEX customers_name_idx ON customers (name)',
  );
  late final Index utangRecordsCustomerIdIdx = Index(
    'utang_records_customer_id_idx',
    'CREATE INDEX utang_records_customer_id_idx ON utang_records (customer_id)',
  );
  late final Index utangRecordsIsDirtyIdx = Index(
    'utang_records_is_dirty_idx',
    'CREATE INDEX utang_records_is_dirty_idx ON utang_records (is_dirty)',
  );
  late final Index salesIsDirtyIdx = Index(
    'sales_is_dirty_idx',
    'CREATE INDEX sales_is_dirty_idx ON sales (is_dirty)',
  );
  late final Index salesCreatedAtMsIdx = Index(
    'sales_created_at_ms_idx',
    'CREATE INDEX sales_created_at_ms_idx ON sales (created_at_ms)',
  );
  late final Index saleItemsSaleIdIdx = Index(
    'sale_items_sale_id_idx',
    'CREATE INDEX sale_items_sale_id_idx ON sale_items (sale_id)',
  );
  late final Index saleItemsProductIdIdx = Index(
    'sale_items_product_id_idx',
    'CREATE INDEX sale_items_product_id_idx ON sale_items (product_id)',
  );
  late final Index saleItemsIsDirtyIdx = Index(
    'sale_items_is_dirty_idx',
    'CREATE INDEX sale_items_is_dirty_idx ON sale_items (is_dirty)',
  );
  late final Index businessProfilesIsDirtyIdx = Index(
    'business_profiles_is_dirty_idx',
    'CREATE INDEX business_profiles_is_dirty_idx ON business_profiles (is_dirty)',
  );
  late final Index productSerialNumbersProductIdx = Index(
    'product_serial_numbers_product_idx',
    'CREATE INDEX product_serial_numbers_product_idx ON product_serial_numbers (product_id)',
  );
  late final Index productSerialNumbersIsDirtyIdx = Index(
    'product_serial_numbers_is_dirty_idx',
    'CREATE INDEX product_serial_numbers_is_dirty_idx ON product_serial_numbers (is_dirty)',
  );
  late final Index productRecipeIngredientsRecipeIdx = Index(
    'product_recipe_ingredients_recipe_idx',
    'CREATE INDEX product_recipe_ingredients_recipe_idx ON product_recipe_ingredients (recipe_product_id)',
  );
  late final Index productRecipeIngredientsIsDirtyIdx = Index(
    'product_recipe_ingredients_is_dirty_idx',
    'CREATE INDEX product_recipe_ingredients_is_dirty_idx ON product_recipe_ingredients (is_dirty)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    syncState,
    appMeta,
    charges,
    parties,
    transactionTypes,
    movementCategories,
    ledgerEntries,
    transactions,
    feeTransactions,
    monitoringSessions,
    productCategories,
    shelfLocations,
    products,
    productUnitConversions,
    stockMovements,
    customers,
    utangRecords,
    sales,
    saleItems,
    businessProfiles,
    productSerialNumbers,
    productRecipeIngredients,
    chargesIsDirtyIdx,
    chargesTransactionTypeKeyIdx,
    partiesIsDirtyIdx,
    partiesNameIdx,
    transactionTypesIsDirtyIdx,
    movementCategoriesIsDirtyIdx,
    ledgerEntriesTransactionIdIdx,
    ledgerEntriesEntryDateIdx,
    ledgerEntriesIsDirtyIdx,
    ledgerEntriesUpdatedAtMsIdx,
    transactionsEntryDateIdx,
    transactionsIsDirtyIdx,
    transactionsUpdatedAtMsIdx,
    feeTransactionsRelatedTransactionSyncIdIdx,
    feeTransactionsIsDirtyIdx,
    productCategoriesIsDirtyIdx,
    shelfLocationsIsDirtyIdx,
    productsCategoryIdIdx,
    productsShelfLocationIdIdx,
    productsIsDirtyIdx,
    productsNameIdx,
    productUnitConversionsProductIdIdx,
    productUnitConversionsIsDirtyIdx,
    stockMovementsProductIdIdx,
    stockMovementsIsDirtyIdx,
    stockMovementsCreatedAtMsIdx,
    customersIsDirtyIdx,
    customersNameIdx,
    utangRecordsCustomerIdIdx,
    utangRecordsIsDirtyIdx,
    salesIsDirtyIdx,
    salesCreatedAtMsIdx,
    saleItemsSaleIdIdx,
    saleItemsProductIdIdx,
    saleItemsIsDirtyIdx,
    businessProfilesIsDirtyIdx,
    productSerialNumbersProductIdx,
    productSerialNumbersIsDirtyIdx,
    productRecipeIngredientsRecipeIdx,
    productRecipeIngredientsIsDirtyIdx,
  ];
}

typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String moduleKey,
      Value<int> lastPulledAtMs,
      Value<int> lastPushedAtMs,
      Value<int> lastPushAttemptAtMs,
      Value<String?> lastPushError,
      Value<int> pendingPushCount,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> moduleKey,
      Value<int> lastPulledAtMs,
      Value<int> lastPushedAtMs,
      Value<int> lastPushAttemptAtMs,
      Value<String?> lastPushError,
      Value<int> pendingPushCount,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get moduleKey => $composableBuilder(
    column: $table.moduleKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPulledAtMs => $composableBuilder(
    column: $table.lastPulledAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPushedAtMs => $composableBuilder(
    column: $table.lastPushedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPushAttemptAtMs => $composableBuilder(
    column: $table.lastPushAttemptAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastPushError => $composableBuilder(
    column: $table.lastPushError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingPushCount => $composableBuilder(
    column: $table.pendingPushCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get moduleKey => $composableBuilder(
    column: $table.moduleKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPulledAtMs => $composableBuilder(
    column: $table.lastPulledAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPushedAtMs => $composableBuilder(
    column: $table.lastPushedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPushAttemptAtMs => $composableBuilder(
    column: $table.lastPushAttemptAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPushError => $composableBuilder(
    column: $table.lastPushError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingPushCount => $composableBuilder(
    column: $table.pendingPushCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get moduleKey =>
      $composableBuilder(column: $table.moduleKey, builder: (column) => column);

  GeneratedColumn<int> get lastPulledAtMs => $composableBuilder(
    column: $table.lastPulledAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPushedAtMs => $composableBuilder(
    column: $table.lastPushedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPushAttemptAtMs => $composableBuilder(
    column: $table.lastPushAttemptAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastPushError => $composableBuilder(
    column: $table.lastPushError,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pendingPushCount => $composableBuilder(
    column: $table.pendingPushCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateRow,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> moduleKey = const Value.absent(),
                Value<int> lastPulledAtMs = const Value.absent(),
                Value<int> lastPushedAtMs = const Value.absent(),
                Value<int> lastPushAttemptAtMs = const Value.absent(),
                Value<String?> lastPushError = const Value.absent(),
                Value<int> pendingPushCount = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                moduleKey: moduleKey,
                lastPulledAtMs: lastPulledAtMs,
                lastPushedAtMs: lastPushedAtMs,
                lastPushAttemptAtMs: lastPushAttemptAtMs,
                lastPushError: lastPushError,
                pendingPushCount: pendingPushCount,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String moduleKey,
                Value<int> lastPulledAtMs = const Value.absent(),
                Value<int> lastPushedAtMs = const Value.absent(),
                Value<int> lastPushAttemptAtMs = const Value.absent(),
                Value<String?> lastPushError = const Value.absent(),
                Value<int> pendingPushCount = const Value.absent(),
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                moduleKey: moduleKey,
                lastPulledAtMs: lastPulledAtMs,
                lastPushedAtMs: lastPushedAtMs,
                lastPushAttemptAtMs: lastPushAttemptAtMs,
                lastPushError: lastPushError,
                pendingPushCount: pendingPushCount,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateRow,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateRow,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>,
      ),
      SyncStateRow,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaRow,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaRow,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>,
          ),
          AppMetaRow,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaRow,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaRow, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>),
      AppMetaRow,
      PrefetchHooks Function()
    >;
typedef $$ChargesTableCreateCompanionBuilder =
    ChargesCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required double lowerBound,
      required double upperBound,
      required double chargeAmount,
      Value<String> transactionTypeKey,
      Value<int> rowid,
    });
typedef $$ChargesTableUpdateCompanionBuilder =
    ChargesCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<double> lowerBound,
      Value<double> upperBound,
      Value<double> chargeAmount,
      Value<String> transactionTypeKey,
      Value<int> rowid,
    });

class $$ChargesTableFilterComposer
    extends Composer<_$AppDatabase, $ChargesTable> {
  $$ChargesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lowerBound => $composableBuilder(
    column: $table.lowerBound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get upperBound => $composableBuilder(
    column: $table.upperBound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chargeAmount => $composableBuilder(
    column: $table.chargeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionTypeKey => $composableBuilder(
    column: $table.transactionTypeKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChargesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChargesTable> {
  $$ChargesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lowerBound => $composableBuilder(
    column: $table.lowerBound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get upperBound => $composableBuilder(
    column: $table.upperBound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chargeAmount => $composableBuilder(
    column: $table.chargeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionTypeKey => $composableBuilder(
    column: $table.transactionTypeKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChargesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChargesTable> {
  $$ChargesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get lowerBound => $composableBuilder(
    column: $table.lowerBound,
    builder: (column) => column,
  );

  GeneratedColumn<double> get upperBound => $composableBuilder(
    column: $table.upperBound,
    builder: (column) => column,
  );

  GeneratedColumn<double> get chargeAmount => $composableBuilder(
    column: $table.chargeAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionTypeKey => $composableBuilder(
    column: $table.transactionTypeKey,
    builder: (column) => column,
  );
}

class $$ChargesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChargesTable,
          ChargeRow,
          $$ChargesTableFilterComposer,
          $$ChargesTableOrderingComposer,
          $$ChargesTableAnnotationComposer,
          $$ChargesTableCreateCompanionBuilder,
          $$ChargesTableUpdateCompanionBuilder,
          (ChargeRow, BaseReferences<_$AppDatabase, $ChargesTable, ChargeRow>),
          ChargeRow,
          PrefetchHooks Function()
        > {
  $$ChargesTableTableManager(_$AppDatabase db, $ChargesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChargesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChargesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChargesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<double> lowerBound = const Value.absent(),
                Value<double> upperBound = const Value.absent(),
                Value<double> chargeAmount = const Value.absent(),
                Value<String> transactionTypeKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChargesCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                lowerBound: lowerBound,
                upperBound: upperBound,
                chargeAmount: chargeAmount,
                transactionTypeKey: transactionTypeKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required double lowerBound,
                required double upperBound,
                required double chargeAmount,
                Value<String> transactionTypeKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChargesCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                lowerBound: lowerBound,
                upperBound: upperBound,
                chargeAmount: chargeAmount,
                transactionTypeKey: transactionTypeKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChargesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChargesTable,
      ChargeRow,
      $$ChargesTableFilterComposer,
      $$ChargesTableOrderingComposer,
      $$ChargesTableAnnotationComposer,
      $$ChargesTableCreateCompanionBuilder,
      $$ChargesTableUpdateCompanionBuilder,
      (ChargeRow, BaseReferences<_$AppDatabase, $ChargesTable, ChargeRow>),
      ChargeRow,
      PrefetchHooks Function()
    >;
typedef $$PartiesTableCreateCompanionBuilder =
    PartiesCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String name,
      Value<String> accountNumber,
      Value<String> entityId,
      Value<String> description,
      required String joinDate,
      Value<bool> isVerified,
      Value<int> rowid,
    });
typedef $$PartiesTableUpdateCompanionBuilder =
    PartiesCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> name,
      Value<String> accountNumber,
      Value<String> entityId,
      Value<String> description,
      Value<String> joinDate,
      Value<bool> isVerified,
      Value<int> rowid,
    });

class $$PartiesTableFilterComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get joinDate => $composableBuilder(
    column: $table.joinDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get joinDate => $composableBuilder(
    column: $table.joinDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get joinDate =>
      $composableBuilder(column: $table.joinDate, builder: (column) => column);

  GeneratedColumn<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => column,
  );
}

class $$PartiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartiesTable,
          PartyRow,
          $$PartiesTableFilterComposer,
          $$PartiesTableOrderingComposer,
          $$PartiesTableAnnotationComposer,
          $$PartiesTableCreateCompanionBuilder,
          $$PartiesTableUpdateCompanionBuilder,
          (PartyRow, BaseReferences<_$AppDatabase, $PartiesTable, PartyRow>),
          PartyRow,
          PrefetchHooks Function()
        > {
  $$PartiesTableTableManager(_$AppDatabase db, $PartiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> accountNumber = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> joinDate = const Value.absent(),
                Value<bool> isVerified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                accountNumber: accountNumber,
                entityId: entityId,
                description: description,
                joinDate: joinDate,
                isVerified: isVerified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String name,
                Value<String> accountNumber = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> description = const Value.absent(),
                required String joinDate,
                Value<bool> isVerified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                accountNumber: accountNumber,
                entityId: entityId,
                description: description,
                joinDate: joinDate,
                isVerified: isVerified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartiesTable,
      PartyRow,
      $$PartiesTableFilterComposer,
      $$PartiesTableOrderingComposer,
      $$PartiesTableAnnotationComposer,
      $$PartiesTableCreateCompanionBuilder,
      $$PartiesTableUpdateCompanionBuilder,
      (PartyRow, BaseReferences<_$AppDatabase, $PartiesTable, PartyRow>),
      PartyRow,
      PrefetchHooks Function()
    >;
typedef $$TransactionTypesTableCreateCompanionBuilder =
    TransactionTypesCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String name,
      Value<bool> isOutflow,
      Value<String> walletAccount,
      Value<int> rowid,
    });
typedef $$TransactionTypesTableUpdateCompanionBuilder =
    TransactionTypesCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> name,
      Value<bool> isOutflow,
      Value<String> walletAccount,
      Value<int> rowid,
    });

class $$TransactionTypesTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionTypesTable> {
  $$TransactionTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOutflow => $composableBuilder(
    column: $table.isOutflow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletAccount => $composableBuilder(
    column: $table.walletAccount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionTypesTable> {
  $$TransactionTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOutflow => $composableBuilder(
    column: $table.isOutflow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletAccount => $composableBuilder(
    column: $table.walletAccount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionTypesTable> {
  $$TransactionTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isOutflow =>
      $composableBuilder(column: $table.isOutflow, builder: (column) => column);

  GeneratedColumn<String> get walletAccount => $composableBuilder(
    column: $table.walletAccount,
    builder: (column) => column,
  );
}

class $$TransactionTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionTypesTable,
          TransactionTypeRow,
          $$TransactionTypesTableFilterComposer,
          $$TransactionTypesTableOrderingComposer,
          $$TransactionTypesTableAnnotationComposer,
          $$TransactionTypesTableCreateCompanionBuilder,
          $$TransactionTypesTableUpdateCompanionBuilder,
          (
            TransactionTypeRow,
            BaseReferences<
              _$AppDatabase,
              $TransactionTypesTable,
              TransactionTypeRow
            >,
          ),
          TransactionTypeRow,
          PrefetchHooks Function()
        > {
  $$TransactionTypesTableTableManager(
    _$AppDatabase db,
    $TransactionTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isOutflow = const Value.absent(),
                Value<String> walletAccount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionTypesCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                isOutflow: isOutflow,
                walletAccount: walletAccount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String name,
                Value<bool> isOutflow = const Value.absent(),
                Value<String> walletAccount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionTypesCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                isOutflow: isOutflow,
                walletAccount: walletAccount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionTypesTable,
      TransactionTypeRow,
      $$TransactionTypesTableFilterComposer,
      $$TransactionTypesTableOrderingComposer,
      $$TransactionTypesTableAnnotationComposer,
      $$TransactionTypesTableCreateCompanionBuilder,
      $$TransactionTypesTableUpdateCompanionBuilder,
      (
        TransactionTypeRow,
        BaseReferences<
          _$AppDatabase,
          $TransactionTypesTable,
          TransactionTypeRow
        >,
      ),
      TransactionTypeRow,
      PrefetchHooks Function()
    >;
typedef $$MovementCategoriesTableCreateCompanionBuilder =
    MovementCategoriesCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$MovementCategoriesTableUpdateCompanionBuilder =
    MovementCategoriesCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$MovementCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MovementCategoriesTable> {
  $$MovementCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MovementCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MovementCategoriesTable> {
  $$MovementCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovementCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovementCategoriesTable> {
  $$MovementCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$MovementCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovementCategoriesTable,
          MovementCategoryRow,
          $$MovementCategoriesTableFilterComposer,
          $$MovementCategoriesTableOrderingComposer,
          $$MovementCategoriesTableAnnotationComposer,
          $$MovementCategoriesTableCreateCompanionBuilder,
          $$MovementCategoriesTableUpdateCompanionBuilder,
          (
            MovementCategoryRow,
            BaseReferences<
              _$AppDatabase,
              $MovementCategoriesTable,
              MovementCategoryRow
            >,
          ),
          MovementCategoryRow,
          PrefetchHooks Function()
        > {
  $$MovementCategoriesTableTableManager(
    _$AppDatabase db,
    $MovementCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovementCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovementCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovementCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementCategoriesCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => MovementCategoriesCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MovementCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovementCategoriesTable,
      MovementCategoryRow,
      $$MovementCategoriesTableFilterComposer,
      $$MovementCategoriesTableOrderingComposer,
      $$MovementCategoriesTableAnnotationComposer,
      $$MovementCategoriesTableCreateCompanionBuilder,
      $$MovementCategoriesTableUpdateCompanionBuilder,
      (
        MovementCategoryRow,
        BaseReferences<
          _$AppDatabase,
          $MovementCategoriesTable,
          MovementCategoryRow
        >,
      ),
      MovementCategoryRow,
      PrefetchHooks Function()
    >;
typedef $$LedgerEntriesTableCreateCompanionBuilder =
    LedgerEntriesCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      Value<String?> transactionId,
      required String entryType,
      Value<String> title,
      Value<String> note,
      Value<String> reference,
      required double amount,
      Value<double> walletDelta,
      Value<double> mayaWalletDelta,
      Value<double> onHandDelta,
      Value<double> recordedFlow,
      Value<String> tag,
      Value<String> iconKey,
      Value<String> walletAccount,
      Value<String> ownerScope,
      Value<String?> ownerMovementType,
      Value<String?> ownerCategory,
      Value<String?> ownerPartyName,
      Value<String?> ownerPartyAccount,
      required String entryDate,
      Value<int> rowid,
    });
typedef $$LedgerEntriesTableUpdateCompanionBuilder =
    LedgerEntriesCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String?> transactionId,
      Value<String> entryType,
      Value<String> title,
      Value<String> note,
      Value<String> reference,
      Value<double> amount,
      Value<double> walletDelta,
      Value<double> mayaWalletDelta,
      Value<double> onHandDelta,
      Value<double> recordedFlow,
      Value<String> tag,
      Value<String> iconKey,
      Value<String> walletAccount,
      Value<String> ownerScope,
      Value<String?> ownerMovementType,
      Value<String?> ownerCategory,
      Value<String?> ownerPartyName,
      Value<String?> ownerPartyAccount,
      Value<String> entryDate,
      Value<int> rowid,
    });

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get walletDelta => $composableBuilder(
    column: $table.walletDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mayaWalletDelta => $composableBuilder(
    column: $table.mayaWalletDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get onHandDelta => $composableBuilder(
    column: $table.onHandDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recordedFlow => $composableBuilder(
    column: $table.recordedFlow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletAccount => $composableBuilder(
    column: $table.walletAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerMovementType => $composableBuilder(
    column: $table.ownerMovementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerCategory => $composableBuilder(
    column: $table.ownerCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerPartyName => $composableBuilder(
    column: $table.ownerPartyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerPartyAccount => $composableBuilder(
    column: $table.ownerPartyAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get walletDelta => $composableBuilder(
    column: $table.walletDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mayaWalletDelta => $composableBuilder(
    column: $table.mayaWalletDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get onHandDelta => $composableBuilder(
    column: $table.onHandDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recordedFlow => $composableBuilder(
    column: $table.recordedFlow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletAccount => $composableBuilder(
    column: $table.walletAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerMovementType => $composableBuilder(
    column: $table.ownerMovementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerCategory => $composableBuilder(
    column: $table.ownerCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerPartyName => $composableBuilder(
    column: $table.ownerPartyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerPartyAccount => $composableBuilder(
    column: $table.ownerPartyAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get walletDelta => $composableBuilder(
    column: $table.walletDelta,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mayaWalletDelta => $composableBuilder(
    column: $table.mayaWalletDelta,
    builder: (column) => column,
  );

  GeneratedColumn<double> get onHandDelta => $composableBuilder(
    column: $table.onHandDelta,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recordedFlow => $composableBuilder(
    column: $table.recordedFlow,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get walletAccount => $composableBuilder(
    column: $table.walletAccount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerMovementType => $composableBuilder(
    column: $table.ownerMovementType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerCategory => $composableBuilder(
    column: $table.ownerCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerPartyName => $composableBuilder(
    column: $table.ownerPartyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerPartyAccount => $composableBuilder(
    column: $table.ownerPartyAccount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);
}

class $$LedgerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerEntriesTable,
          LedgerEntryRow,
          $$LedgerEntriesTableFilterComposer,
          $$LedgerEntriesTableOrderingComposer,
          $$LedgerEntriesTableAnnotationComposer,
          $$LedgerEntriesTableCreateCompanionBuilder,
          $$LedgerEntriesTableUpdateCompanionBuilder,
          (
            LedgerEntryRow,
            BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntryRow>,
          ),
          LedgerEntryRow,
          PrefetchHooks Function()
        > {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> transactionId = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> walletDelta = const Value.absent(),
                Value<double> mayaWalletDelta = const Value.absent(),
                Value<double> onHandDelta = const Value.absent(),
                Value<double> recordedFlow = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String> walletAccount = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<String?> ownerMovementType = const Value.absent(),
                Value<String?> ownerCategory = const Value.absent(),
                Value<String?> ownerPartyName = const Value.absent(),
                Value<String?> ownerPartyAccount = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                transactionId: transactionId,
                entryType: entryType,
                title: title,
                note: note,
                reference: reference,
                amount: amount,
                walletDelta: walletDelta,
                mayaWalletDelta: mayaWalletDelta,
                onHandDelta: onHandDelta,
                recordedFlow: recordedFlow,
                tag: tag,
                iconKey: iconKey,
                walletAccount: walletAccount,
                ownerScope: ownerScope,
                ownerMovementType: ownerMovementType,
                ownerCategory: ownerCategory,
                ownerPartyName: ownerPartyName,
                ownerPartyAccount: ownerPartyAccount,
                entryDate: entryDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                Value<String?> transactionId = const Value.absent(),
                required String entryType,
                Value<String> title = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> reference = const Value.absent(),
                required double amount,
                Value<double> walletDelta = const Value.absent(),
                Value<double> mayaWalletDelta = const Value.absent(),
                Value<double> onHandDelta = const Value.absent(),
                Value<double> recordedFlow = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String> walletAccount = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<String?> ownerMovementType = const Value.absent(),
                Value<String?> ownerCategory = const Value.absent(),
                Value<String?> ownerPartyName = const Value.absent(),
                Value<String?> ownerPartyAccount = const Value.absent(),
                required String entryDate,
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                transactionId: transactionId,
                entryType: entryType,
                title: title,
                note: note,
                reference: reference,
                amount: amount,
                walletDelta: walletDelta,
                mayaWalletDelta: mayaWalletDelta,
                onHandDelta: onHandDelta,
                recordedFlow: recordedFlow,
                tag: tag,
                iconKey: iconKey,
                walletAccount: walletAccount,
                ownerScope: ownerScope,
                ownerMovementType: ownerMovementType,
                ownerCategory: ownerCategory,
                ownerPartyName: ownerPartyName,
                ownerPartyAccount: ownerPartyAccount,
                entryDate: entryDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LedgerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerEntriesTable,
      LedgerEntryRow,
      $$LedgerEntriesTableFilterComposer,
      $$LedgerEntriesTableOrderingComposer,
      $$LedgerEntriesTableAnnotationComposer,
      $$LedgerEntriesTableCreateCompanionBuilder,
      $$LedgerEntriesTableUpdateCompanionBuilder,
      (
        LedgerEntryRow,
        BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntryRow>,
      ),
      LedgerEntryRow,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String walletProvider,
      required String direction,
      required double amount,
      Value<double> chargeAmount,
      required double totalAmount,
      required double balanceBefore,
      required double balanceAfter,
      Value<double?> chargeLowerBound,
      Value<double?> chargeUpperBound,
      Value<String> chargeHandling,
      Value<String?> receiptImagePath,
      Value<String?> receiptOriginalName,
      Value<String?> receiptMimeType,
      Value<int?> receiptUploadedAtMs,
      Value<String> ocrStatus,
      Value<double?> ocrExtractedAmount,
      Value<String?> ocrRawText,
      Value<int?> ocrProcessedAtMs,
      Value<String?> externalProvider,
      Value<String?> externalTransactionId,
      Value<String> note,
      Value<String> reference,
      required String entryDate,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> walletProvider,
      Value<String> direction,
      Value<double> amount,
      Value<double> chargeAmount,
      Value<double> totalAmount,
      Value<double> balanceBefore,
      Value<double> balanceAfter,
      Value<double?> chargeLowerBound,
      Value<double?> chargeUpperBound,
      Value<String> chargeHandling,
      Value<String?> receiptImagePath,
      Value<String?> receiptOriginalName,
      Value<String?> receiptMimeType,
      Value<int?> receiptUploadedAtMs,
      Value<String> ocrStatus,
      Value<double?> ocrExtractedAmount,
      Value<String?> ocrRawText,
      Value<int?> ocrProcessedAtMs,
      Value<String?> externalProvider,
      Value<String?> externalTransactionId,
      Value<String> note,
      Value<String> reference,
      Value<String> entryDate,
      Value<String> status,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletProvider => $composableBuilder(
    column: $table.walletProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chargeAmount => $composableBuilder(
    column: $table.chargeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceBefore => $composableBuilder(
    column: $table.balanceBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chargeLowerBound => $composableBuilder(
    column: $table.chargeLowerBound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chargeUpperBound => $composableBuilder(
    column: $table.chargeUpperBound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chargeHandling => $composableBuilder(
    column: $table.chargeHandling,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptOriginalName => $composableBuilder(
    column: $table.receiptOriginalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptMimeType => $composableBuilder(
    column: $table.receiptMimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receiptUploadedAtMs => $composableBuilder(
    column: $table.receiptUploadedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrStatus => $composableBuilder(
    column: $table.ocrStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ocrExtractedAmount => $composableBuilder(
    column: $table.ocrExtractedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrRawText => $composableBuilder(
    column: $table.ocrRawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ocrProcessedAtMs => $composableBuilder(
    column: $table.ocrProcessedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalProvider => $composableBuilder(
    column: $table.externalProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalTransactionId => $composableBuilder(
    column: $table.externalTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletProvider => $composableBuilder(
    column: $table.walletProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chargeAmount => $composableBuilder(
    column: $table.chargeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceBefore => $composableBuilder(
    column: $table.balanceBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chargeLowerBound => $composableBuilder(
    column: $table.chargeLowerBound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chargeUpperBound => $composableBuilder(
    column: $table.chargeUpperBound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chargeHandling => $composableBuilder(
    column: $table.chargeHandling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptOriginalName => $composableBuilder(
    column: $table.receiptOriginalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptMimeType => $composableBuilder(
    column: $table.receiptMimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receiptUploadedAtMs => $composableBuilder(
    column: $table.receiptUploadedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrStatus => $composableBuilder(
    column: $table.ocrStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ocrExtractedAmount => $composableBuilder(
    column: $table.ocrExtractedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrRawText => $composableBuilder(
    column: $table.ocrRawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ocrProcessedAtMs => $composableBuilder(
    column: $table.ocrProcessedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalProvider => $composableBuilder(
    column: $table.externalProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalTransactionId => $composableBuilder(
    column: $table.externalTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get walletProvider => $composableBuilder(
    column: $table.walletProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get chargeAmount => $composableBuilder(
    column: $table.chargeAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get balanceBefore => $composableBuilder(
    column: $table.balanceBefore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => column,
  );

  GeneratedColumn<double> get chargeLowerBound => $composableBuilder(
    column: $table.chargeLowerBound,
    builder: (column) => column,
  );

  GeneratedColumn<double> get chargeUpperBound => $composableBuilder(
    column: $table.chargeUpperBound,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chargeHandling => $composableBuilder(
    column: $table.chargeHandling,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptOriginalName => $composableBuilder(
    column: $table.receiptOriginalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptMimeType => $composableBuilder(
    column: $table.receiptMimeType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get receiptUploadedAtMs => $composableBuilder(
    column: $table.receiptUploadedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrStatus =>
      $composableBuilder(column: $table.ocrStatus, builder: (column) => column);

  GeneratedColumn<double> get ocrExtractedAmount => $composableBuilder(
    column: $table.ocrExtractedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrRawText => $composableBuilder(
    column: $table.ocrRawText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ocrProcessedAtMs => $composableBuilder(
    column: $table.ocrProcessedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalProvider => $composableBuilder(
    column: $table.externalProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalTransactionId => $composableBuilder(
    column: $table.externalTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            TransactionRow,
            BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
          ),
          TransactionRow,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> walletProvider = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> chargeAmount = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> balanceBefore = const Value.absent(),
                Value<double> balanceAfter = const Value.absent(),
                Value<double?> chargeLowerBound = const Value.absent(),
                Value<double?> chargeUpperBound = const Value.absent(),
                Value<String> chargeHandling = const Value.absent(),
                Value<String?> receiptImagePath = const Value.absent(),
                Value<String?> receiptOriginalName = const Value.absent(),
                Value<String?> receiptMimeType = const Value.absent(),
                Value<int?> receiptUploadedAtMs = const Value.absent(),
                Value<String> ocrStatus = const Value.absent(),
                Value<double?> ocrExtractedAmount = const Value.absent(),
                Value<String?> ocrRawText = const Value.absent(),
                Value<int?> ocrProcessedAtMs = const Value.absent(),
                Value<String?> externalProvider = const Value.absent(),
                Value<String?> externalTransactionId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                walletProvider: walletProvider,
                direction: direction,
                amount: amount,
                chargeAmount: chargeAmount,
                totalAmount: totalAmount,
                balanceBefore: balanceBefore,
                balanceAfter: balanceAfter,
                chargeLowerBound: chargeLowerBound,
                chargeUpperBound: chargeUpperBound,
                chargeHandling: chargeHandling,
                receiptImagePath: receiptImagePath,
                receiptOriginalName: receiptOriginalName,
                receiptMimeType: receiptMimeType,
                receiptUploadedAtMs: receiptUploadedAtMs,
                ocrStatus: ocrStatus,
                ocrExtractedAmount: ocrExtractedAmount,
                ocrRawText: ocrRawText,
                ocrProcessedAtMs: ocrProcessedAtMs,
                externalProvider: externalProvider,
                externalTransactionId: externalTransactionId,
                note: note,
                reference: reference,
                entryDate: entryDate,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String walletProvider,
                required String direction,
                required double amount,
                Value<double> chargeAmount = const Value.absent(),
                required double totalAmount,
                required double balanceBefore,
                required double balanceAfter,
                Value<double?> chargeLowerBound = const Value.absent(),
                Value<double?> chargeUpperBound = const Value.absent(),
                Value<String> chargeHandling = const Value.absent(),
                Value<String?> receiptImagePath = const Value.absent(),
                Value<String?> receiptOriginalName = const Value.absent(),
                Value<String?> receiptMimeType = const Value.absent(),
                Value<int?> receiptUploadedAtMs = const Value.absent(),
                Value<String> ocrStatus = const Value.absent(),
                Value<double?> ocrExtractedAmount = const Value.absent(),
                Value<String?> ocrRawText = const Value.absent(),
                Value<int?> ocrProcessedAtMs = const Value.absent(),
                Value<String?> externalProvider = const Value.absent(),
                Value<String?> externalTransactionId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> reference = const Value.absent(),
                required String entryDate,
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                walletProvider: walletProvider,
                direction: direction,
                amount: amount,
                chargeAmount: chargeAmount,
                totalAmount: totalAmount,
                balanceBefore: balanceBefore,
                balanceAfter: balanceAfter,
                chargeLowerBound: chargeLowerBound,
                chargeUpperBound: chargeUpperBound,
                chargeHandling: chargeHandling,
                receiptImagePath: receiptImagePath,
                receiptOriginalName: receiptOriginalName,
                receiptMimeType: receiptMimeType,
                receiptUploadedAtMs: receiptUploadedAtMs,
                ocrStatus: ocrStatus,
                ocrExtractedAmount: ocrExtractedAmount,
                ocrRawText: ocrRawText,
                ocrProcessedAtMs: ocrProcessedAtMs,
                externalProvider: externalProvider,
                externalTransactionId: externalTransactionId,
                note: note,
                reference: reference,
                entryDate: entryDate,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        TransactionRow,
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
      ),
      TransactionRow,
      PrefetchHooks Function()
    >;
typedef $$FeeTransactionsTableCreateCompanionBuilder =
    FeeTransactionsCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      Value<String?> relatedTransactionSyncId,
      required double feeAmount,
      required String feeType,
      required String chargeDestination,
      Value<int> rowid,
    });
typedef $$FeeTransactionsTableUpdateCompanionBuilder =
    FeeTransactionsCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String?> relatedTransactionSyncId,
      Value<double> feeAmount,
      Value<String> feeType,
      Value<String> chargeDestination,
      Value<int> rowid,
    });

class $$FeeTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $FeeTransactionsTable> {
  $$FeeTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedTransactionSyncId => $composableBuilder(
    column: $table.relatedTransactionSyncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get feeAmount => $composableBuilder(
    column: $table.feeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feeType => $composableBuilder(
    column: $table.feeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chargeDestination => $composableBuilder(
    column: $table.chargeDestination,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeeTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeeTransactionsTable> {
  $$FeeTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedTransactionSyncId => $composableBuilder(
    column: $table.relatedTransactionSyncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get feeAmount => $composableBuilder(
    column: $table.feeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feeType => $composableBuilder(
    column: $table.feeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chargeDestination => $composableBuilder(
    column: $table.chargeDestination,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeeTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeeTransactionsTable> {
  $$FeeTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relatedTransactionSyncId => $composableBuilder(
    column: $table.relatedTransactionSyncId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get feeAmount =>
      $composableBuilder(column: $table.feeAmount, builder: (column) => column);

  GeneratedColumn<String> get feeType =>
      $composableBuilder(column: $table.feeType, builder: (column) => column);

  GeneratedColumn<String> get chargeDestination => $composableBuilder(
    column: $table.chargeDestination,
    builder: (column) => column,
  );
}

class $$FeeTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeeTransactionsTable,
          FeeTransactionRow,
          $$FeeTransactionsTableFilterComposer,
          $$FeeTransactionsTableOrderingComposer,
          $$FeeTransactionsTableAnnotationComposer,
          $$FeeTransactionsTableCreateCompanionBuilder,
          $$FeeTransactionsTableUpdateCompanionBuilder,
          (
            FeeTransactionRow,
            BaseReferences<
              _$AppDatabase,
              $FeeTransactionsTable,
              FeeTransactionRow
            >,
          ),
          FeeTransactionRow,
          PrefetchHooks Function()
        > {
  $$FeeTransactionsTableTableManager(
    _$AppDatabase db,
    $FeeTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeeTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeeTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeeTransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> relatedTransactionSyncId = const Value.absent(),
                Value<double> feeAmount = const Value.absent(),
                Value<String> feeType = const Value.absent(),
                Value<String> chargeDestination = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeeTransactionsCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                relatedTransactionSyncId: relatedTransactionSyncId,
                feeAmount: feeAmount,
                feeType: feeType,
                chargeDestination: chargeDestination,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                Value<String?> relatedTransactionSyncId = const Value.absent(),
                required double feeAmount,
                required String feeType,
                required String chargeDestination,
                Value<int> rowid = const Value.absent(),
              }) => FeeTransactionsCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                relatedTransactionSyncId: relatedTransactionSyncId,
                feeAmount: feeAmount,
                feeType: feeType,
                chargeDestination: chargeDestination,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeeTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeeTransactionsTable,
      FeeTransactionRow,
      $$FeeTransactionsTableFilterComposer,
      $$FeeTransactionsTableOrderingComposer,
      $$FeeTransactionsTableAnnotationComposer,
      $$FeeTransactionsTableCreateCompanionBuilder,
      $$FeeTransactionsTableUpdateCompanionBuilder,
      (
        FeeTransactionRow,
        BaseReferences<_$AppDatabase, $FeeTransactionsTable, FeeTransactionRow>,
      ),
      FeeTransactionRow,
      PrefetchHooks Function()
    >;
typedef $$MonitoringSessionsTableCreateCompanionBuilder =
    MonitoringSessionsCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String name,
      Value<String> status,
      required int startDateMs,
      Value<int?> endDateMs,
      Value<double> startGcash,
      Value<double> startMaya,
      Value<double> startOnHand,
      Value<double?> endGcash,
      Value<double?> endMaya,
      Value<double?> endOnHand,
      Value<int> rowid,
    });
typedef $$MonitoringSessionsTableUpdateCompanionBuilder =
    MonitoringSessionsCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> name,
      Value<String> status,
      Value<int> startDateMs,
      Value<int?> endDateMs,
      Value<double> startGcash,
      Value<double> startMaya,
      Value<double> startOnHand,
      Value<double?> endGcash,
      Value<double?> endMaya,
      Value<double?> endOnHand,
      Value<int> rowid,
    });

class $$MonitoringSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $MonitoringSessionsTable> {
  $$MonitoringSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDateMs => $composableBuilder(
    column: $table.startDateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endDateMs => $composableBuilder(
    column: $table.endDateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startGcash => $composableBuilder(
    column: $table.startGcash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startMaya => $composableBuilder(
    column: $table.startMaya,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startOnHand => $composableBuilder(
    column: $table.startOnHand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endGcash => $composableBuilder(
    column: $table.endGcash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endMaya => $composableBuilder(
    column: $table.endMaya,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endOnHand => $composableBuilder(
    column: $table.endOnHand,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonitoringSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MonitoringSessionsTable> {
  $$MonitoringSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDateMs => $composableBuilder(
    column: $table.startDateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endDateMs => $composableBuilder(
    column: $table.endDateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startGcash => $composableBuilder(
    column: $table.startGcash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startMaya => $composableBuilder(
    column: $table.startMaya,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startOnHand => $composableBuilder(
    column: $table.startOnHand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endGcash => $composableBuilder(
    column: $table.endGcash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endMaya => $composableBuilder(
    column: $table.endMaya,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endOnHand => $composableBuilder(
    column: $table.endOnHand,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonitoringSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonitoringSessionsTable> {
  $$MonitoringSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startDateMs => $composableBuilder(
    column: $table.startDateMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endDateMs =>
      $composableBuilder(column: $table.endDateMs, builder: (column) => column);

  GeneratedColumn<double> get startGcash => $composableBuilder(
    column: $table.startGcash,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startMaya =>
      $composableBuilder(column: $table.startMaya, builder: (column) => column);

  GeneratedColumn<double> get startOnHand => $composableBuilder(
    column: $table.startOnHand,
    builder: (column) => column,
  );

  GeneratedColumn<double> get endGcash =>
      $composableBuilder(column: $table.endGcash, builder: (column) => column);

  GeneratedColumn<double> get endMaya =>
      $composableBuilder(column: $table.endMaya, builder: (column) => column);

  GeneratedColumn<double> get endOnHand =>
      $composableBuilder(column: $table.endOnHand, builder: (column) => column);
}

class $$MonitoringSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonitoringSessionsTable,
          MonitoringSessionRow,
          $$MonitoringSessionsTableFilterComposer,
          $$MonitoringSessionsTableOrderingComposer,
          $$MonitoringSessionsTableAnnotationComposer,
          $$MonitoringSessionsTableCreateCompanionBuilder,
          $$MonitoringSessionsTableUpdateCompanionBuilder,
          (
            MonitoringSessionRow,
            BaseReferences<
              _$AppDatabase,
              $MonitoringSessionsTable,
              MonitoringSessionRow
            >,
          ),
          MonitoringSessionRow,
          PrefetchHooks Function()
        > {
  $$MonitoringSessionsTableTableManager(
    _$AppDatabase db,
    $MonitoringSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonitoringSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonitoringSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonitoringSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startDateMs = const Value.absent(),
                Value<int?> endDateMs = const Value.absent(),
                Value<double> startGcash = const Value.absent(),
                Value<double> startMaya = const Value.absent(),
                Value<double> startOnHand = const Value.absent(),
                Value<double?> endGcash = const Value.absent(),
                Value<double?> endMaya = const Value.absent(),
                Value<double?> endOnHand = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonitoringSessionsCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                status: status,
                startDateMs: startDateMs,
                endDateMs: endDateMs,
                startGcash: startGcash,
                startMaya: startMaya,
                startOnHand: startOnHand,
                endGcash: endGcash,
                endMaya: endMaya,
                endOnHand: endOnHand,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String name,
                Value<String> status = const Value.absent(),
                required int startDateMs,
                Value<int?> endDateMs = const Value.absent(),
                Value<double> startGcash = const Value.absent(),
                Value<double> startMaya = const Value.absent(),
                Value<double> startOnHand = const Value.absent(),
                Value<double?> endGcash = const Value.absent(),
                Value<double?> endMaya = const Value.absent(),
                Value<double?> endOnHand = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonitoringSessionsCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                status: status,
                startDateMs: startDateMs,
                endDateMs: endDateMs,
                startGcash: startGcash,
                startMaya: startMaya,
                startOnHand: startOnHand,
                endGcash: endGcash,
                endMaya: endMaya,
                endOnHand: endOnHand,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonitoringSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonitoringSessionsTable,
      MonitoringSessionRow,
      $$MonitoringSessionsTableFilterComposer,
      $$MonitoringSessionsTableOrderingComposer,
      $$MonitoringSessionsTableAnnotationComposer,
      $$MonitoringSessionsTableCreateCompanionBuilder,
      $$MonitoringSessionsTableUpdateCompanionBuilder,
      (
        MonitoringSessionRow,
        BaseReferences<
          _$AppDatabase,
          $MonitoringSessionsTable,
          MonitoringSessionRow
        >,
      ),
      MonitoringSessionRow,
      PrefetchHooks Function()
    >;
typedef $$ProductCategoriesTableCreateCompanionBuilder =
    ProductCategoriesCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String name,
      Value<String> description,
      Value<String> examples,
      Value<bool> isQuickAccess,
      Value<int> rowid,
    });
typedef $$ProductCategoriesTableUpdateCompanionBuilder =
    ProductCategoriesCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> examples,
      Value<bool> isQuickAccess,
      Value<int> rowid,
    });

final class $$ProductCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProductCategoriesTable,
          ProductCategoryRow
        > {
  $$ProductCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ProductsTable, List<ProductRow>>
  _productsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName: $_aliasNameGenerator(
      db.productCategories.id,
      db.products.categoryId,
    ),
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductCategoriesTable> {
  $$ProductCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isQuickAccess => $composableBuilder(
    column: $table.isQuickAccess,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductCategoriesTable> {
  $$ProductCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isQuickAccess => $composableBuilder(
    column: $table.isQuickAccess,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductCategoriesTable> {
  $$ProductCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examples =>
      $composableBuilder(column: $table.examples, builder: (column) => column);

  GeneratedColumn<bool> get isQuickAccess => $composableBuilder(
    column: $table.isQuickAccess,
    builder: (column) => column,
  );

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductCategoriesTable,
          ProductCategoryRow,
          $$ProductCategoriesTableFilterComposer,
          $$ProductCategoriesTableOrderingComposer,
          $$ProductCategoriesTableAnnotationComposer,
          $$ProductCategoriesTableCreateCompanionBuilder,
          $$ProductCategoriesTableUpdateCompanionBuilder,
          (ProductCategoryRow, $$ProductCategoriesTableReferences),
          ProductCategoryRow,
          PrefetchHooks Function({bool productsRefs})
        > {
  $$ProductCategoriesTableTableManager(
    _$AppDatabase db,
    $ProductCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> examples = const Value.absent(),
                Value<bool> isQuickAccess = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductCategoriesCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                description: description,
                examples: examples,
                isQuickAccess: isQuickAccess,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                Value<String> examples = const Value.absent(),
                Value<bool> isQuickAccess = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductCategoriesCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                description: description,
                examples: examples,
                isQuickAccess: isQuickAccess,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData<
                      ProductCategoryRow,
                      $ProductCategoriesTable,
                      ProductRow
                    >(
                      currentTable: table,
                      referencedTable: $$ProductCategoriesTableReferences
                          ._productsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProductCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).productsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProductCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductCategoriesTable,
      ProductCategoryRow,
      $$ProductCategoriesTableFilterComposer,
      $$ProductCategoriesTableOrderingComposer,
      $$ProductCategoriesTableAnnotationComposer,
      $$ProductCategoriesTableCreateCompanionBuilder,
      $$ProductCategoriesTableUpdateCompanionBuilder,
      (ProductCategoryRow, $$ProductCategoriesTableReferences),
      ProductCategoryRow,
      PrefetchHooks Function({bool productsRefs})
    >;
typedef $$ShelfLocationsTableCreateCompanionBuilder =
    ShelfLocationsCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String name,
      Value<String> description,
      Value<String> examples,
      Value<String?> imageUrl,
      Value<String?> imageLocalPath,
      Value<int> rowid,
    });
typedef $$ShelfLocationsTableUpdateCompanionBuilder =
    ShelfLocationsCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> examples,
      Value<String?> imageUrl,
      Value<String?> imageLocalPath,
      Value<int> rowid,
    });

final class $$ShelfLocationsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ShelfLocationsTable, ShelfLocationRow> {
  $$ShelfLocationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ProductsTable, List<ProductRow>>
  _productsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName: $_aliasNameGenerator(
      db.shelfLocations.id,
      db.products.shelfLocationId,
    ),
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager($_db, $_db.products).filter(
      (f) => f.shelfLocationId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShelfLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $ShelfLocationsTable> {
  $$ShelfLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageLocalPath => $composableBuilder(
    column: $table.imageLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.shelfLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelfLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShelfLocationsTable> {
  $$ShelfLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageLocalPath => $composableBuilder(
    column: $table.imageLocalPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShelfLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShelfLocationsTable> {
  $$ShelfLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examples =>
      $composableBuilder(column: $table.examples, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get imageLocalPath => $composableBuilder(
    column: $table.imageLocalPath,
    builder: (column) => column,
  );

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.shelfLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelfLocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShelfLocationsTable,
          ShelfLocationRow,
          $$ShelfLocationsTableFilterComposer,
          $$ShelfLocationsTableOrderingComposer,
          $$ShelfLocationsTableAnnotationComposer,
          $$ShelfLocationsTableCreateCompanionBuilder,
          $$ShelfLocationsTableUpdateCompanionBuilder,
          (ShelfLocationRow, $$ShelfLocationsTableReferences),
          ShelfLocationRow,
          PrefetchHooks Function({bool productsRefs})
        > {
  $$ShelfLocationsTableTableManager(
    _$AppDatabase db,
    $ShelfLocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelfLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelfLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelfLocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> examples = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> imageLocalPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShelfLocationsCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                description: description,
                examples: examples,
                imageUrl: imageUrl,
                imageLocalPath: imageLocalPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                Value<String> examples = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> imageLocalPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShelfLocationsCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                description: description,
                examples: examples,
                imageUrl: imageUrl,
                imageLocalPath: imageLocalPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShelfLocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData<
                      ShelfLocationRow,
                      $ShelfLocationsTable,
                      ProductRow
                    >(
                      currentTable: table,
                      referencedTable: $$ShelfLocationsTableReferences
                          ._productsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ShelfLocationsTableReferences(
                            db,
                            table,
                            p0,
                          ).productsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.shelfLocationId == item.id,
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

typedef $$ShelfLocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShelfLocationsTable,
      ShelfLocationRow,
      $$ShelfLocationsTableFilterComposer,
      $$ShelfLocationsTableOrderingComposer,
      $$ShelfLocationsTableAnnotationComposer,
      $$ShelfLocationsTableCreateCompanionBuilder,
      $$ShelfLocationsTableUpdateCompanionBuilder,
      (ShelfLocationRow, $$ShelfLocationsTableReferences),
      ShelfLocationRow,
      PrefetchHooks Function({bool productsRefs})
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String name,
      required String sku,
      Value<String> description,
      Value<String> category,
      Value<String> baseUnit,
      Value<double> costPrice,
      required double sellingPrice,
      Value<double> stockInBaseUnit,
      Value<int> reorderPoint,
      Value<bool> isActive,
      Value<String?> imageUrl,
      Value<String?> imageLocalPath,
      Value<String?> shelfLocation,
      Value<int?> expirationDateMs,
      Value<String?> categoryId,
      Value<String?> shelfLocationId,
      Value<String> itemType,
      Value<String> customAttributesJson,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> name,
      Value<String> sku,
      Value<String> description,
      Value<String> category,
      Value<String> baseUnit,
      Value<double> costPrice,
      Value<double> sellingPrice,
      Value<double> stockInBaseUnit,
      Value<int> reorderPoint,
      Value<bool> isActive,
      Value<String?> imageUrl,
      Value<String?> imageLocalPath,
      Value<String?> shelfLocation,
      Value<int?> expirationDateMs,
      Value<String?> categoryId,
      Value<String?> shelfLocationId,
      Value<String> itemType,
      Value<String> customAttributesJson,
      Value<int> rowid,
    });

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, ProductRow> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.productCategories.createAlias(
        $_aliasNameGenerator(db.products.categoryId, db.productCategories.id),
      );

  $$ProductCategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$ProductCategoriesTableTableManager(
      $_db,
      $_db.productCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ShelfLocationsTable _shelfLocationIdTable(_$AppDatabase db) =>
      db.shelfLocations.createAlias(
        $_aliasNameGenerator(db.products.shelfLocationId, db.shelfLocations.id),
      );

  $$ShelfLocationsTableProcessedTableManager? get shelfLocationId {
    final $_column = $_itemColumn<String>('shelf_location_id');
    if ($_column == null) return null;
    final manager = $$ShelfLocationsTableTableManager(
      $_db,
      $_db.shelfLocations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shelfLocationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ProductUnitConversionsTable,
    List<ProductUnitConversionRow>
  >
  _productUnitConversionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.productUnitConversions,
        aliasName: $_aliasNameGenerator(
          db.products.id,
          db.productUnitConversions.productId,
        ),
      );

  $$ProductUnitConversionsTableProcessedTableManager
  get productUnitConversionsRefs {
    final manager = $$ProductUnitConversionsTableTableManager(
      $_db,
      $_db.productUnitConversions,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _productUnitConversionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovementRow>>
  _stockMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: $_aliasNameGenerator(
      db.products.id,
      db.stockMovements.productId,
    ),
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaleItemsTable, List<SaleItemRow>>
  _saleItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItems,
    aliasName: $_aliasNameGenerator(db.products.id, db.saleItems.productId),
  );

  $$SaleItemsTableProcessedTableManager get saleItemsRefs {
    final manager = $$SaleItemsTableTableManager(
      $_db,
      $_db.saleItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProductSerialNumbersTable,
    List<ProductSerialNumberRow>
  >
  _productSerialNumbersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.productSerialNumbers,
        aliasName: $_aliasNameGenerator(
          db.products.id,
          db.productSerialNumbers.productId,
        ),
      );

  $$ProductSerialNumbersTableProcessedTableManager
  get productSerialNumbersRefs {
    final manager = $$ProductSerialNumbersTableTableManager(
      $_db,
      $_db.productSerialNumbers,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _productSerialNumbersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProductRecipeIngredientsTable,
    List<ProductRecipeIngredientRow>
  >
  _recipeProductRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.productRecipeIngredients,
    aliasName: $_aliasNameGenerator(
      db.products.id,
      db.productRecipeIngredients.recipeProductId,
    ),
  );

  $$ProductRecipeIngredientsTableProcessedTableManager get recipeProductRefs {
    final manager =
        $$ProductRecipeIngredientsTableTableManager(
          $_db,
          $_db.productRecipeIngredients,
        ).filter(
          (f) => f.recipeProductId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_recipeProductRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProductRecipeIngredientsTable,
    List<ProductRecipeIngredientRow>
  >
  _ingredientProductRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.productRecipeIngredients,
        aliasName: $_aliasNameGenerator(
          db.products.id,
          db.productRecipeIngredients.ingredientProductId,
        ),
      );

  $$ProductRecipeIngredientsTableProcessedTableManager
  get ingredientProductRefs {
    final manager =
        $$ProductRecipeIngredientsTableTableManager(
          $_db,
          $_db.productRecipeIngredients,
        ).filter(
          (f) =>
              f.ingredientProductId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _ingredientProductRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUnit => $composableBuilder(
    column: $table.baseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockInBaseUnit => $composableBuilder(
    column: $table.stockInBaseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reorderPoint => $composableBuilder(
    column: $table.reorderPoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageLocalPath => $composableBuilder(
    column: $table.imageLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shelfLocation => $composableBuilder(
    column: $table.shelfLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expirationDateMs => $composableBuilder(
    column: $table.expirationDateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customAttributesJson => $composableBuilder(
    column: $table.customAttributesJson,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductCategoriesTableFilterComposer get categoryId {
    final $$ProductCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.productCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.productCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelfLocationsTableFilterComposer get shelfLocationId {
    final $$ShelfLocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfLocationId,
      referencedTable: $db.shelfLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfLocationsTableFilterComposer(
            $db: $db,
            $table: $db.shelfLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> productUnitConversionsRefs(
    Expression<bool> Function($$ProductUnitConversionsTableFilterComposer f) f,
  ) {
    final $$ProductUnitConversionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productUnitConversions,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductUnitConversionsTableFilterComposer(
                $db: $db,
                $table: $db.productUnitConversions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saleItemsRefs(
    Expression<bool> Function($$SaleItemsTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> productSerialNumbersRefs(
    Expression<bool> Function($$ProductSerialNumbersTableFilterComposer f) f,
  ) {
    final $$ProductSerialNumbersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productSerialNumbers,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductSerialNumbersTableFilterComposer(
            $db: $db,
            $table: $db.productSerialNumbers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recipeProductRefs(
    Expression<bool> Function($$ProductRecipeIngredientsTableFilterComposer f)
    f,
  ) {
    final $$ProductRecipeIngredientsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productRecipeIngredients,
          getReferencedColumn: (t) => t.recipeProductId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductRecipeIngredientsTableFilterComposer(
                $db: $db,
                $table: $db.productRecipeIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> ingredientProductRefs(
    Expression<bool> Function($$ProductRecipeIngredientsTableFilterComposer f)
    f,
  ) {
    final $$ProductRecipeIngredientsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productRecipeIngredients,
          getReferencedColumn: (t) => t.ingredientProductId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductRecipeIngredientsTableFilterComposer(
                $db: $db,
                $table: $db.productRecipeIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUnit => $composableBuilder(
    column: $table.baseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockInBaseUnit => $composableBuilder(
    column: $table.stockInBaseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reorderPoint => $composableBuilder(
    column: $table.reorderPoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageLocalPath => $composableBuilder(
    column: $table.imageLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shelfLocation => $composableBuilder(
    column: $table.shelfLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expirationDateMs => $composableBuilder(
    column: $table.expirationDateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customAttributesJson => $composableBuilder(
    column: $table.customAttributesJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductCategoriesTableOrderingComposer get categoryId {
    final $$ProductCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.productCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.productCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelfLocationsTableOrderingComposer get shelfLocationId {
    final $$ShelfLocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfLocationId,
      referencedTable: $db.shelfLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfLocationsTableOrderingComposer(
            $db: $db,
            $table: $db.shelfLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get baseUnit =>
      $composableBuilder(column: $table.baseUnit, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stockInBaseUnit => $composableBuilder(
    column: $table.stockInBaseUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reorderPoint => $composableBuilder(
    column: $table.reorderPoint,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get imageLocalPath => $composableBuilder(
    column: $table.imageLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shelfLocation => $composableBuilder(
    column: $table.shelfLocation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expirationDateMs => $composableBuilder(
    column: $table.expirationDateMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<String> get customAttributesJson => $composableBuilder(
    column: $table.customAttributesJson,
    builder: (column) => column,
  );

  $$ProductCategoriesTableAnnotationComposer get categoryId {
    final $$ProductCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.productCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.productCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ShelfLocationsTableAnnotationComposer get shelfLocationId {
    final $$ShelfLocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfLocationId,
      referencedTable: $db.shelfLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfLocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.shelfLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> productUnitConversionsRefs<T extends Object>(
    Expression<T> Function($$ProductUnitConversionsTableAnnotationComposer a) f,
  ) {
    final $$ProductUnitConversionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productUnitConversions,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductUnitConversionsTableAnnotationComposer(
                $db: $db,
                $table: $db.productUnitConversions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> saleItemsRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> productSerialNumbersRefs<T extends Object>(
    Expression<T> Function($$ProductSerialNumbersTableAnnotationComposer a) f,
  ) {
    final $$ProductSerialNumbersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productSerialNumbers,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductSerialNumbersTableAnnotationComposer(
                $db: $db,
                $table: $db.productSerialNumbers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recipeProductRefs<T extends Object>(
    Expression<T> Function($$ProductRecipeIngredientsTableAnnotationComposer a)
    f,
  ) {
    final $$ProductRecipeIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productRecipeIngredients,
          getReferencedColumn: (t) => t.recipeProductId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductRecipeIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.productRecipeIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ingredientProductRefs<T extends Object>(
    Expression<T> Function($$ProductRecipeIngredientsTableAnnotationComposer a)
    f,
  ) {
    final $$ProductRecipeIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productRecipeIngredients,
          getReferencedColumn: (t) => t.ingredientProductId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductRecipeIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.productRecipeIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (ProductRow, $$ProductsTableReferences),
          ProductRow,
          PrefetchHooks Function({
            bool categoryId,
            bool shelfLocationId,
            bool productUnitConversionsRefs,
            bool stockMovementsRefs,
            bool saleItemsRefs,
            bool productSerialNumbersRefs,
            bool recipeProductRefs,
            bool ingredientProductRefs,
          })
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sku = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> baseUnit = const Value.absent(),
                Value<double> costPrice = const Value.absent(),
                Value<double> sellingPrice = const Value.absent(),
                Value<double> stockInBaseUnit = const Value.absent(),
                Value<int> reorderPoint = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> imageLocalPath = const Value.absent(),
                Value<String?> shelfLocation = const Value.absent(),
                Value<int?> expirationDateMs = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> shelfLocationId = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<String> customAttributesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                sku: sku,
                description: description,
                category: category,
                baseUnit: baseUnit,
                costPrice: costPrice,
                sellingPrice: sellingPrice,
                stockInBaseUnit: stockInBaseUnit,
                reorderPoint: reorderPoint,
                isActive: isActive,
                imageUrl: imageUrl,
                imageLocalPath: imageLocalPath,
                shelfLocation: shelfLocation,
                expirationDateMs: expirationDateMs,
                categoryId: categoryId,
                shelfLocationId: shelfLocationId,
                itemType: itemType,
                customAttributesJson: customAttributesJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String name,
                required String sku,
                Value<String> description = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> baseUnit = const Value.absent(),
                Value<double> costPrice = const Value.absent(),
                required double sellingPrice,
                Value<double> stockInBaseUnit = const Value.absent(),
                Value<int> reorderPoint = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> imageLocalPath = const Value.absent(),
                Value<String?> shelfLocation = const Value.absent(),
                Value<int?> expirationDateMs = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> shelfLocationId = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<String> customAttributesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                sku: sku,
                description: description,
                category: category,
                baseUnit: baseUnit,
                costPrice: costPrice,
                sellingPrice: sellingPrice,
                stockInBaseUnit: stockInBaseUnit,
                reorderPoint: reorderPoint,
                isActive: isActive,
                imageUrl: imageUrl,
                imageLocalPath: imageLocalPath,
                shelfLocation: shelfLocation,
                expirationDateMs: expirationDateMs,
                categoryId: categoryId,
                shelfLocationId: shelfLocationId,
                itemType: itemType,
                customAttributesJson: customAttributesJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                shelfLocationId = false,
                productUnitConversionsRefs = false,
                stockMovementsRefs = false,
                saleItemsRefs = false,
                productSerialNumbersRefs = false,
                recipeProductRefs = false,
                ingredientProductRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (productUnitConversionsRefs) db.productUnitConversions,
                    if (stockMovementsRefs) db.stockMovements,
                    if (saleItemsRefs) db.saleItems,
                    if (productSerialNumbersRefs) db.productSerialNumbers,
                    if (recipeProductRefs) db.productRecipeIngredients,
                    if (ingredientProductRefs) db.productRecipeIngredients,
                  ],
                  addJoins:
                      <
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
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$ProductsTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$ProductsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (shelfLocationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shelfLocationId,
                                    referencedTable: $$ProductsTableReferences
                                        ._shelfLocationIdTable(db),
                                    referencedColumn: $$ProductsTableReferences
                                        ._shelfLocationIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (productUnitConversionsRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          ProductUnitConversionRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._productUnitConversionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).productUnitConversionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockMovementsRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          StockMovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._stockMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (saleItemsRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          SaleItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._saleItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).saleItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (productSerialNumbersRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          ProductSerialNumberRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._productSerialNumbersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).productSerialNumbersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recipeProductRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          ProductRecipeIngredientRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._recipeProductRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeProductRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeProductId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ingredientProductRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          ProductRecipeIngredientRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._ingredientProductRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).ingredientProductRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientProductId == item.id,
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

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, $$ProductsTableReferences),
      ProductRow,
      PrefetchHooks Function({
        bool categoryId,
        bool shelfLocationId,
        bool productUnitConversionsRefs,
        bool stockMovementsRefs,
        bool saleItemsRefs,
        bool productSerialNumbersRefs,
        bool recipeProductRefs,
        bool ingredientProductRefs,
      })
    >;
typedef $$ProductUnitConversionsTableCreateCompanionBuilder =
    ProductUnitConversionsCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String productId,
      required String unitName,
      required double conversionFactor,
      required double costPrice,
      required double sellingPrice,
      Value<int> rowid,
    });
typedef $$ProductUnitConversionsTableUpdateCompanionBuilder =
    ProductUnitConversionsCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> productId,
      Value<String> unitName,
      Value<double> conversionFactor,
      Value<double> costPrice,
      Value<double> sellingPrice,
      Value<int> rowid,
    });

final class $$ProductUnitConversionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProductUnitConversionsTable,
          ProductUnitConversionRow
        > {
  $$ProductUnitConversionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(
          db.productUnitConversions.productId,
          db.products.id,
        ),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductUnitConversionsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductUnitConversionsTable> {
  $$ProductUnitConversionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get conversionFactor => $composableBuilder(
    column: $table.conversionFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductUnitConversionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductUnitConversionsTable> {
  $$ProductUnitConversionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get conversionFactor => $composableBuilder(
    column: $table.conversionFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductUnitConversionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductUnitConversionsTable> {
  $$ProductUnitConversionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitName =>
      $composableBuilder(column: $table.unitName, builder: (column) => column);

  GeneratedColumn<double> get conversionFactor => $composableBuilder(
    column: $table.conversionFactor,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => column,
  );

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductUnitConversionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductUnitConversionsTable,
          ProductUnitConversionRow,
          $$ProductUnitConversionsTableFilterComposer,
          $$ProductUnitConversionsTableOrderingComposer,
          $$ProductUnitConversionsTableAnnotationComposer,
          $$ProductUnitConversionsTableCreateCompanionBuilder,
          $$ProductUnitConversionsTableUpdateCompanionBuilder,
          (ProductUnitConversionRow, $$ProductUnitConversionsTableReferences),
          ProductUnitConversionRow,
          PrefetchHooks Function({bool productId})
        > {
  $$ProductUnitConversionsTableTableManager(
    _$AppDatabase db,
    $ProductUnitConversionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductUnitConversionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProductUnitConversionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProductUnitConversionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> unitName = const Value.absent(),
                Value<double> conversionFactor = const Value.absent(),
                Value<double> costPrice = const Value.absent(),
                Value<double> sellingPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductUnitConversionsCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                productId: productId,
                unitName: unitName,
                conversionFactor: conversionFactor,
                costPrice: costPrice,
                sellingPrice: sellingPrice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String productId,
                required String unitName,
                required double conversionFactor,
                required double costPrice,
                required double sellingPrice,
                Value<int> rowid = const Value.absent(),
              }) => ProductUnitConversionsCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                productId: productId,
                unitName: unitName,
                conversionFactor: conversionFactor,
                costPrice: costPrice,
                sellingPrice: sellingPrice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductUnitConversionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable:
                                    $$ProductUnitConversionsTableReferences
                                        ._productIdTable(db),
                                referencedColumn:
                                    $$ProductUnitConversionsTableReferences
                                        ._productIdTable(db)
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

typedef $$ProductUnitConversionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductUnitConversionsTable,
      ProductUnitConversionRow,
      $$ProductUnitConversionsTableFilterComposer,
      $$ProductUnitConversionsTableOrderingComposer,
      $$ProductUnitConversionsTableAnnotationComposer,
      $$ProductUnitConversionsTableCreateCompanionBuilder,
      $$ProductUnitConversionsTableUpdateCompanionBuilder,
      (ProductUnitConversionRow, $$ProductUnitConversionsTableReferences),
      ProductUnitConversionRow,
      PrefetchHooks Function({bool productId})
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      required String id,
      required String productId,
      required String movementType,
      required double quantity,
      required double previousQuantity,
      required double newQuantity,
      Value<String> note,
      Value<String> reference,
      Value<int?> expirationDateMs,
      required int createdAtMs,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> movementType,
      Value<double> quantity,
      Value<double> previousQuantity,
      Value<double> newQuantity,
      Value<String> note,
      Value<String> reference,
      Value<int?> expirationDateMs,
      Value<int> createdAtMs,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$StockMovementsTableReferences
    extends
        BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovementRow> {
  $$StockMovementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.stockMovements.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get previousQuantity => $composableBuilder(
    column: $table.previousQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get newQuantity => $composableBuilder(
    column: $table.newQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expirationDateMs => $composableBuilder(
    column: $table.expirationDateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get previousQuantity => $composableBuilder(
    column: $table.previousQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get newQuantity => $composableBuilder(
    column: $table.newQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expirationDateMs => $composableBuilder(
    column: $table.expirationDateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get previousQuantity => $composableBuilder(
    column: $table.previousQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get newQuantity => $composableBuilder(
    column: $table.newQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<int> get expirationDateMs => $composableBuilder(
    column: $table.expirationDateMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTable,
          StockMovementRow,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (StockMovementRow, $$StockMovementsTableReferences),
          StockMovementRow,
          PrefetchHooks Function({bool productId})
        > {
  $$StockMovementsTableTableManager(
    _$AppDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> movementType = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> previousQuantity = const Value.absent(),
                Value<double> newQuantity = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<int?> expirationDateMs = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion(
                id: id,
                productId: productId,
                movementType: movementType,
                quantity: quantity,
                previousQuantity: previousQuantity,
                newQuantity: newQuantity,
                note: note,
                reference: reference,
                expirationDateMs: expirationDateMs,
                createdAtMs: createdAtMs,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String movementType,
                required double quantity,
                required double previousQuantity,
                required double newQuantity,
                Value<String> note = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<int?> expirationDateMs = const Value.absent(),
                required int createdAtMs,
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion.insert(
                id: id,
                productId: productId,
                movementType: movementType,
                quantity: quantity,
                previousQuantity: previousQuantity,
                newQuantity: newQuantity,
                note: note,
                reference: reference,
                expirationDateMs: expirationDateMs,
                createdAtMs: createdAtMs,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockMovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$StockMovementsTableReferences
                                    ._productIdTable(db),
                                referencedColumn:
                                    $$StockMovementsTableReferences
                                        ._productIdTable(db)
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

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTable,
      StockMovementRow,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (StockMovementRow, $$StockMovementsTableReferences),
      StockMovementRow,
      PrefetchHooks Function({bool productId})
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String name,
      Value<String> phone,
      Value<String> address,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> name,
      Value<String> phone,
      Value<String> address,
      Value<String> notes,
      Value<int> rowid,
    });

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UtangRecordsTable, List<UtangRecordRow>>
  _utangRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.utangRecords,
    aliasName: $_aliasNameGenerator(
      db.customers.id,
      db.utangRecords.customerId,
    ),
  );

  $$UtangRecordsTableProcessedTableManager get utangRecordsRefs {
    final manager = $$UtangRecordsTableTableManager(
      $_db,
      $_db.utangRecords,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_utangRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> utangRecordsRefs(
    Expression<bool> Function($$UtangRecordsTableFilterComposer f) f,
  ) {
    final $$UtangRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.utangRecords,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtangRecordsTableFilterComposer(
            $db: $db,
            $table: $db.utangRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> utangRecordsRefs<T extends Object>(
    Expression<T> Function($$UtangRecordsTableAnnotationComposer a) f,
  ) {
    final $$UtangRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.utangRecords,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UtangRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.utangRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerRow,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (CustomerRow, $$CustomersTableReferences),
          CustomerRow,
          PrefetchHooks Function({bool utangRecordsRefs})
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                phone: phone,
                address: address,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String name,
                Value<String> phone = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                name: name,
                phone: phone,
                address: address,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({utangRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (utangRecordsRefs) db.utangRecords],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (utangRecordsRefs)
                    await $_getPrefetchedData<
                      CustomerRow,
                      $CustomersTable,
                      UtangRecordRow
                    >(
                      currentTable: table,
                      referencedTable: $$CustomersTableReferences
                          ._utangRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomersTableReferences(
                            db,
                            table,
                            p0,
                          ).utangRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.customerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerRow,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (CustomerRow, $$CustomersTableReferences),
      CustomerRow,
      PrefetchHooks Function({bool utangRecordsRefs})
    >;
typedef $$UtangRecordsTableCreateCompanionBuilder =
    UtangRecordsCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String customerId,
      Value<String> description,
      required double amount,
      Value<int> rowid,
    });
typedef $$UtangRecordsTableUpdateCompanionBuilder =
    UtangRecordsCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> customerId,
      Value<String> description,
      Value<double> amount,
      Value<int> rowid,
    });

final class $$UtangRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $UtangRecordsTable, UtangRecordRow> {
  $$UtangRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias(
        $_aliasNameGenerator(db.utangRecords.customerId, db.customers.id),
      );

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UtangRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $UtangRecordsTable> {
  $$UtangRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UtangRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $UtangRecordsTable> {
  $$UtangRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UtangRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UtangRecordsTable> {
  $$UtangRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UtangRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UtangRecordsTable,
          UtangRecordRow,
          $$UtangRecordsTableFilterComposer,
          $$UtangRecordsTableOrderingComposer,
          $$UtangRecordsTableAnnotationComposer,
          $$UtangRecordsTableCreateCompanionBuilder,
          $$UtangRecordsTableUpdateCompanionBuilder,
          (UtangRecordRow, $$UtangRecordsTableReferences),
          UtangRecordRow,
          PrefetchHooks Function({bool customerId})
        > {
  $$UtangRecordsTableTableManager(_$AppDatabase db, $UtangRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UtangRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UtangRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UtangRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UtangRecordsCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                customerId: customerId,
                description: description,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String customerId,
                Value<String> description = const Value.absent(),
                required double amount,
                Value<int> rowid = const Value.absent(),
              }) => UtangRecordsCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                customerId: customerId,
                description: description,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UtangRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable: $$UtangRecordsTableReferences
                                    ._customerIdTable(db),
                                referencedColumn: $$UtangRecordsTableReferences
                                    ._customerIdTable(db)
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

typedef $$UtangRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UtangRecordsTable,
      UtangRecordRow,
      $$UtangRecordsTableFilterComposer,
      $$UtangRecordsTableOrderingComposer,
      $$UtangRecordsTableAnnotationComposer,
      $$UtangRecordsTableCreateCompanionBuilder,
      $$UtangRecordsTableUpdateCompanionBuilder,
      (UtangRecordRow, $$UtangRecordsTableReferences),
      UtangRecordRow,
      PrefetchHooks Function({bool customerId})
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String reference,
      Value<String> note,
      required double subtotal,
      required double totalAmount,
      required double paidAmount,
      Value<double> changeAmount,
      required int totalItems,
      Value<int> rowid,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> reference,
      Value<String> note,
      Value<double> subtotal,
      Value<double> totalAmount,
      Value<double> paidAmount,
      Value<double> changeAmount,
      Value<int> totalItems,
      Value<int> rowid,
    });

final class $$SalesTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTable, SaleRow> {
  $$SalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SaleItemsTable, List<SaleItemRow>>
  _saleItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItems,
    aliasName: $_aliasNameGenerator(db.sales.id, db.saleItems.saleId),
  );

  $$SaleItemsTableProcessedTableManager get saleItemsRefs {
    final manager = $$SaleItemsTableTableManager(
      $_db,
      $_db.saleItems,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalItems => $composableBuilder(
    column: $table.totalItems,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> saleItemsRefs(
    Expression<bool> Function($$SaleItemsTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalItems => $composableBuilder(
    column: $table.totalItems,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalItems => $composableBuilder(
    column: $table.totalItems,
    builder: (column) => column,
  );

  Expression<T> saleItemsRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          SaleRow,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (SaleRow, $$SalesTableReferences),
          SaleRow,
          PrefetchHooks Function({bool saleItemsRefs})
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> paidAmount = const Value.absent(),
                Value<double> changeAmount = const Value.absent(),
                Value<int> totalItems = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                reference: reference,
                note: note,
                subtotal: subtotal,
                totalAmount: totalAmount,
                paidAmount: paidAmount,
                changeAmount: changeAmount,
                totalItems: totalItems,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String reference,
                Value<String> note = const Value.absent(),
                required double subtotal,
                required double totalAmount,
                required double paidAmount,
                Value<double> changeAmount = const Value.absent(),
                required int totalItems,
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                reference: reference,
                note: note,
                subtotal: subtotal,
                totalAmount: totalAmount,
                paidAmount: paidAmount,
                changeAmount: changeAmount,
                totalItems: totalItems,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SalesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({saleItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (saleItemsRefs) db.saleItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saleItemsRefs)
                    await $_getPrefetchedData<
                      SaleRow,
                      $SalesTable,
                      SaleItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$SalesTableReferences
                          ._saleItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SalesTableReferences(db, table, p0).saleItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.saleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      SaleRow,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (SaleRow, $$SalesTableReferences),
      SaleRow,
      PrefetchHooks Function({bool saleItemsRefs})
    >;
typedef $$SaleItemsTableCreateCompanionBuilder =
    SaleItemsCompanion Function({
      required String id,
      required String saleId,
      required String productId,
      required String selectedUnit,
      required double quantity,
      required double unitPrice,
      required double computedBaseQuantity,
      required double lineTotal,
      required int createdAtMs,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$SaleItemsTableUpdateCompanionBuilder =
    SaleItemsCompanion Function({
      Value<String> id,
      Value<String> saleId,
      Value<String> productId,
      Value<String> selectedUnit,
      Value<double> quantity,
      Value<double> unitPrice,
      Value<double> computedBaseQuantity,
      Value<double> lineTotal,
      Value<int> createdAtMs,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$SaleItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItemRow> {
  $$SaleItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesTable _saleIdTable(_$AppDatabase db) => db.sales.createAlias(
    $_aliasNameGenerator(db.saleItems.saleId, db.sales.id),
  );

  $$SalesTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<String>('sale_id')!;

    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.saleItems.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedUnit => $composableBuilder(
    column: $table.selectedUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get computedBaseQuantity => $composableBuilder(
    column: $table.computedBaseQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lineTotal => $composableBuilder(
    column: $table.lineTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedUnit => $composableBuilder(
    column: $table.selectedUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get computedBaseQuantity => $composableBuilder(
    column: $table.computedBaseQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lineTotal => $composableBuilder(
    column: $table.lineTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableOrderingComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get selectedUnit => $composableBuilder(
    column: $table.selectedUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get computedBaseQuantity => $composableBuilder(
    column: $table.computedBaseQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lineTotal =>
      $composableBuilder(column: $table.lineTotal, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleItemsTable,
          SaleItemRow,
          $$SaleItemsTableFilterComposer,
          $$SaleItemsTableOrderingComposer,
          $$SaleItemsTableAnnotationComposer,
          $$SaleItemsTableCreateCompanionBuilder,
          $$SaleItemsTableUpdateCompanionBuilder,
          (SaleItemRow, $$SaleItemsTableReferences),
          SaleItemRow,
          PrefetchHooks Function({bool saleId, bool productId})
        > {
  $$SaleItemsTableTableManager(_$AppDatabase db, $SaleItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> selectedUnit = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> computedBaseQuantity = const Value.absent(),
                Value<double> lineTotal = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleItemsCompanion(
                id: id,
                saleId: saleId,
                productId: productId,
                selectedUnit: selectedUnit,
                quantity: quantity,
                unitPrice: unitPrice,
                computedBaseQuantity: computedBaseQuantity,
                lineTotal: lineTotal,
                createdAtMs: createdAtMs,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleId,
                required String productId,
                required String selectedUnit,
                required double quantity,
                required double unitPrice,
                required double computedBaseQuantity,
                required double lineTotal,
                required int createdAtMs,
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleItemsCompanion.insert(
                id: id,
                saleId: saleId,
                productId: productId,
                selectedUnit: selectedUnit,
                quantity: quantity,
                unitPrice: unitPrice,
                computedBaseQuantity: computedBaseQuantity,
                lineTotal: lineTotal,
                createdAtMs: createdAtMs,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SaleItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (saleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.saleId,
                                referencedTable: $$SaleItemsTableReferences
                                    ._saleIdTable(db),
                                referencedColumn: $$SaleItemsTableReferences
                                    ._saleIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$SaleItemsTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$SaleItemsTableReferences
                                    ._productIdTable(db)
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

typedef $$SaleItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleItemsTable,
      SaleItemRow,
      $$SaleItemsTableFilterComposer,
      $$SaleItemsTableOrderingComposer,
      $$SaleItemsTableAnnotationComposer,
      $$SaleItemsTableCreateCompanionBuilder,
      $$SaleItemsTableUpdateCompanionBuilder,
      (SaleItemRow, $$SaleItemsTableReferences),
      SaleItemRow,
      PrefetchHooks Function({bool saleId, bool productId})
    >;
typedef $$BusinessProfilesTableCreateCompanionBuilder =
    BusinessProfilesCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String businessType,
      required String businessName,
      Value<String> defaultCurrency,
      Value<String> preferencesJson,
      Value<int> rowid,
    });
typedef $$BusinessProfilesTableUpdateCompanionBuilder =
    BusinessProfilesCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> businessType,
      Value<String> businessName,
      Value<String> defaultCurrency,
      Value<String> preferencesJson,
      Value<int> rowid,
    });

class $$BusinessProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessProfilesTable> {
  $$BusinessProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessType => $composableBuilder(
    column: $table.businessType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferencesJson => $composableBuilder(
    column: $table.preferencesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BusinessProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessProfilesTable> {
  $$BusinessProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessType => $composableBuilder(
    column: $table.businessType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferencesJson => $composableBuilder(
    column: $table.preferencesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BusinessProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessProfilesTable> {
  $$BusinessProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessType => $composableBuilder(
    column: $table.businessType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferencesJson => $composableBuilder(
    column: $table.preferencesJson,
    builder: (column) => column,
  );
}

class $$BusinessProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BusinessProfilesTable,
          BusinessProfileRow,
          $$BusinessProfilesTableFilterComposer,
          $$BusinessProfilesTableOrderingComposer,
          $$BusinessProfilesTableAnnotationComposer,
          $$BusinessProfilesTableCreateCompanionBuilder,
          $$BusinessProfilesTableUpdateCompanionBuilder,
          (
            BusinessProfileRow,
            BaseReferences<
              _$AppDatabase,
              $BusinessProfilesTable,
              BusinessProfileRow
            >,
          ),
          BusinessProfileRow,
          PrefetchHooks Function()
        > {
  $$BusinessProfilesTableTableManager(
    _$AppDatabase db,
    $BusinessProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BusinessProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BusinessProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> businessType = const Value.absent(),
                Value<String> businessName = const Value.absent(),
                Value<String> defaultCurrency = const Value.absent(),
                Value<String> preferencesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BusinessProfilesCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                businessType: businessType,
                businessName: businessName,
                defaultCurrency: defaultCurrency,
                preferencesJson: preferencesJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String businessType,
                required String businessName,
                Value<String> defaultCurrency = const Value.absent(),
                Value<String> preferencesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BusinessProfilesCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                businessType: businessType,
                businessName: businessName,
                defaultCurrency: defaultCurrency,
                preferencesJson: preferencesJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BusinessProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BusinessProfilesTable,
      BusinessProfileRow,
      $$BusinessProfilesTableFilterComposer,
      $$BusinessProfilesTableOrderingComposer,
      $$BusinessProfilesTableAnnotationComposer,
      $$BusinessProfilesTableCreateCompanionBuilder,
      $$BusinessProfilesTableUpdateCompanionBuilder,
      (
        BusinessProfileRow,
        BaseReferences<
          _$AppDatabase,
          $BusinessProfilesTable,
          BusinessProfileRow
        >,
      ),
      BusinessProfileRow,
      PrefetchHooks Function()
    >;
typedef $$ProductSerialNumbersTableCreateCompanionBuilder =
    ProductSerialNumbersCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String productId,
      required String serialNumber,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$ProductSerialNumbersTableUpdateCompanionBuilder =
    ProductSerialNumbersCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> productId,
      Value<String> serialNumber,
      Value<String> status,
      Value<int> rowid,
    });

final class $$ProductSerialNumbersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProductSerialNumbersTable,
          ProductSerialNumberRow
        > {
  $$ProductSerialNumbersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.productSerialNumbers.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductSerialNumbersTableFilterComposer
    extends Composer<_$AppDatabase, $ProductSerialNumbersTable> {
  $$ProductSerialNumbersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductSerialNumbersTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductSerialNumbersTable> {
  $$ProductSerialNumbersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductSerialNumbersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductSerialNumbersTable> {
  $$ProductSerialNumbersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductSerialNumbersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductSerialNumbersTable,
          ProductSerialNumberRow,
          $$ProductSerialNumbersTableFilterComposer,
          $$ProductSerialNumbersTableOrderingComposer,
          $$ProductSerialNumbersTableAnnotationComposer,
          $$ProductSerialNumbersTableCreateCompanionBuilder,
          $$ProductSerialNumbersTableUpdateCompanionBuilder,
          (ProductSerialNumberRow, $$ProductSerialNumbersTableReferences),
          ProductSerialNumberRow,
          PrefetchHooks Function({bool productId})
        > {
  $$ProductSerialNumbersTableTableManager(
    _$AppDatabase db,
    $ProductSerialNumbersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductSerialNumbersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductSerialNumbersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProductSerialNumbersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> serialNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductSerialNumbersCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                productId: productId,
                serialNumber: serialNumber,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String productId,
                required String serialNumber,
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductSerialNumbersCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                productId: productId,
                serialNumber: serialNumber,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductSerialNumbersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable:
                                    $$ProductSerialNumbersTableReferences
                                        ._productIdTable(db),
                                referencedColumn:
                                    $$ProductSerialNumbersTableReferences
                                        ._productIdTable(db)
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

typedef $$ProductSerialNumbersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductSerialNumbersTable,
      ProductSerialNumberRow,
      $$ProductSerialNumbersTableFilterComposer,
      $$ProductSerialNumbersTableOrderingComposer,
      $$ProductSerialNumbersTableAnnotationComposer,
      $$ProductSerialNumbersTableCreateCompanionBuilder,
      $$ProductSerialNumbersTableUpdateCompanionBuilder,
      (ProductSerialNumberRow, $$ProductSerialNumbersTableReferences),
      ProductSerialNumberRow,
      PrefetchHooks Function({bool productId})
    >;
typedef $$ProductRecipeIngredientsTableCreateCompanionBuilder =
    ProductRecipeIngredientsCompanion Function({
      required String syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      required int createdAtMs,
      required int updatedAtMs,
      required String id,
      required String recipeProductId,
      required String ingredientProductId,
      required double quantityNeeded,
      Value<int> rowid,
    });
typedef $$ProductRecipeIngredientsTableUpdateCompanionBuilder =
    ProductRecipeIngredientsCompanion Function({
      Value<String> syncId,
      Value<String> deviceId,
      Value<bool> isDeleted,
      Value<bool> isDirty,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<String> id,
      Value<String> recipeProductId,
      Value<String> ingredientProductId,
      Value<double> quantityNeeded,
      Value<int> rowid,
    });

final class $$ProductRecipeIngredientsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProductRecipeIngredientsTable,
          ProductRecipeIngredientRow
        > {
  $$ProductRecipeIngredientsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _recipeProductIdTable(_$AppDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(
          db.productRecipeIngredients.recipeProductId,
          db.products.id,
        ),
      );

  $$ProductsTableProcessedTableManager get recipeProductId {
    final $_column = $_itemColumn<String>('recipe_product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeProductIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _ingredientProductIdTable(_$AppDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(
          db.productRecipeIngredients.ingredientProductId,
          db.products.id,
        ),
      );

  $$ProductsTableProcessedTableManager get ingredientProductId {
    final $_column = $_itemColumn<String>('ingredient_product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientProductIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductRecipeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductRecipeIngredientsTable> {
  $$ProductRecipeIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityNeeded => $composableBuilder(
    column: $table.quantityNeeded,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get recipeProductId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeProductId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get ingredientProductId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientProductId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductRecipeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductRecipeIngredientsTable> {
  $$ProductRecipeIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityNeeded => $composableBuilder(
    column: $table.quantityNeeded,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get recipeProductId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeProductId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get ingredientProductId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientProductId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductRecipeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductRecipeIngredientsTable> {
  $$ProductRecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get quantityNeeded => $composableBuilder(
    column: $table.quantityNeeded,
    builder: (column) => column,
  );

  $$ProductsTableAnnotationComposer get recipeProductId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeProductId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get ingredientProductId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientProductId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductRecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductRecipeIngredientsTable,
          ProductRecipeIngredientRow,
          $$ProductRecipeIngredientsTableFilterComposer,
          $$ProductRecipeIngredientsTableOrderingComposer,
          $$ProductRecipeIngredientsTableAnnotationComposer,
          $$ProductRecipeIngredientsTableCreateCompanionBuilder,
          $$ProductRecipeIngredientsTableUpdateCompanionBuilder,
          (
            ProductRecipeIngredientRow,
            $$ProductRecipeIngredientsTableReferences,
          ),
          ProductRecipeIngredientRow,
          PrefetchHooks Function({
            bool recipeProductId,
            bool ingredientProductId,
          })
        > {
  $$ProductRecipeIngredientsTableTableManager(
    _$AppDatabase db,
    $ProductRecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductRecipeIngredientsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProductRecipeIngredientsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProductRecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> recipeProductId = const Value.absent(),
                Value<String> ingredientProductId = const Value.absent(),
                Value<double> quantityNeeded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductRecipeIngredientsCompanion(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                recipeProductId: recipeProductId,
                ingredientProductId: ingredientProductId,
                quantityNeeded: quantityNeeded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncId,
                Value<String> deviceId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                required String id,
                required String recipeProductId,
                required String ingredientProductId,
                required double quantityNeeded,
                Value<int> rowid = const Value.absent(),
              }) => ProductRecipeIngredientsCompanion.insert(
                syncId: syncId,
                deviceId: deviceId,
                isDeleted: isDeleted,
                isDirty: isDirty,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                id: id,
                recipeProductId: recipeProductId,
                ingredientProductId: ingredientProductId,
                quantityNeeded: quantityNeeded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductRecipeIngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({recipeProductId = false, ingredientProductId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                        if (recipeProductId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.recipeProductId,
                                    referencedTable:
                                        $$ProductRecipeIngredientsTableReferences
                                            ._recipeProductIdTable(db),
                                    referencedColumn:
                                        $$ProductRecipeIngredientsTableReferences
                                            ._recipeProductIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (ingredientProductId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ingredientProductId,
                                    referencedTable:
                                        $$ProductRecipeIngredientsTableReferences
                                            ._ingredientProductIdTable(db),
                                    referencedColumn:
                                        $$ProductRecipeIngredientsTableReferences
                                            ._ingredientProductIdTable(db)
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

typedef $$ProductRecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductRecipeIngredientsTable,
      ProductRecipeIngredientRow,
      $$ProductRecipeIngredientsTableFilterComposer,
      $$ProductRecipeIngredientsTableOrderingComposer,
      $$ProductRecipeIngredientsTableAnnotationComposer,
      $$ProductRecipeIngredientsTableCreateCompanionBuilder,
      $$ProductRecipeIngredientsTableUpdateCompanionBuilder,
      (ProductRecipeIngredientRow, $$ProductRecipeIngredientsTableReferences),
      ProductRecipeIngredientRow,
      PrefetchHooks Function({bool recipeProductId, bool ingredientProductId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$ChargesTableTableManager get charges =>
      $$ChargesTableTableManager(_db, _db.charges);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db, _db.parties);
  $$TransactionTypesTableTableManager get transactionTypes =>
      $$TransactionTypesTableTableManager(_db, _db.transactionTypes);
  $$MovementCategoriesTableTableManager get movementCategories =>
      $$MovementCategoriesTableTableManager(_db, _db.movementCategories);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$FeeTransactionsTableTableManager get feeTransactions =>
      $$FeeTransactionsTableTableManager(_db, _db.feeTransactions);
  $$MonitoringSessionsTableTableManager get monitoringSessions =>
      $$MonitoringSessionsTableTableManager(_db, _db.monitoringSessions);
  $$ProductCategoriesTableTableManager get productCategories =>
      $$ProductCategoriesTableTableManager(_db, _db.productCategories);
  $$ShelfLocationsTableTableManager get shelfLocations =>
      $$ShelfLocationsTableTableManager(_db, _db.shelfLocations);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$ProductUnitConversionsTableTableManager get productUnitConversions =>
      $$ProductUnitConversionsTableTableManager(
        _db,
        _db.productUnitConversions,
      );
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$UtangRecordsTableTableManager get utangRecords =>
      $$UtangRecordsTableTableManager(_db, _db.utangRecords);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleItemsTableTableManager get saleItems =>
      $$SaleItemsTableTableManager(_db, _db.saleItems);
  $$BusinessProfilesTableTableManager get businessProfiles =>
      $$BusinessProfilesTableTableManager(_db, _db.businessProfiles);
  $$ProductSerialNumbersTableTableManager get productSerialNumbers =>
      $$ProductSerialNumbersTableTableManager(_db, _db.productSerialNumbers);
  $$ProductRecipeIngredientsTableTableManager get productRecipeIngredients =>
      $$ProductRecipeIngredientsTableTableManager(
        _db,
        _db.productRecipeIngredients,
      );
}
