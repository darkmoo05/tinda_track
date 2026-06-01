// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SyncMetadata _$SyncMetadataFromJson(Map<String, dynamic> json) {
  return _SyncMetadata.fromJson(json);
}

/// @nodoc
mixin _$SyncMetadata {
  String get syncId => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isDirty => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SyncMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncMetadataCopyWith<SyncMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncMetadataCopyWith<$Res> {
  factory $SyncMetadataCopyWith(
    SyncMetadata value,
    $Res Function(SyncMetadata) then,
  ) = _$SyncMetadataCopyWithImpl<$Res, SyncMetadata>;
  @useResult
  $Res call({
    String syncId,
    String deviceId,
    bool isDeleted,
    @JsonKey(includeFromJson: false, includeToJson: false) bool isDirty,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SyncMetadataCopyWithImpl<$Res, $Val extends SyncMetadata>
    implements $SyncMetadataCopyWith<$Res> {
  _$SyncMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? syncId = null,
    Object? deviceId = null,
    Object? isDeleted = null,
    Object? isDirty = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            syncId: null == syncId
                ? _value.syncId
                : syncId // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceId: null == deviceId
                ? _value.deviceId
                : deviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            isDeleted: null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            isDirty: null == isDirty
                ? _value.isDirty
                : isDirty // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SyncMetadataImplCopyWith<$Res>
    implements $SyncMetadataCopyWith<$Res> {
  factory _$$SyncMetadataImplCopyWith(
    _$SyncMetadataImpl value,
    $Res Function(_$SyncMetadataImpl) then,
  ) = __$$SyncMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String syncId,
    String deviceId,
    bool isDeleted,
    @JsonKey(includeFromJson: false, includeToJson: false) bool isDirty,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SyncMetadataImplCopyWithImpl<$Res>
    extends _$SyncMetadataCopyWithImpl<$Res, _$SyncMetadataImpl>
    implements _$$SyncMetadataImplCopyWith<$Res> {
  __$$SyncMetadataImplCopyWithImpl(
    _$SyncMetadataImpl _value,
    $Res Function(_$SyncMetadataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? syncId = null,
    Object? deviceId = null,
    Object? isDeleted = null,
    Object? isDirty = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SyncMetadataImpl(
        syncId: null == syncId
            ? _value.syncId
            : syncId // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceId: null == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        isDeleted: null == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDirty: null == isDirty
            ? _value.isDirty
            : isDirty // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncMetadataImpl implements _SyncMetadata {
  const _$SyncMetadataImpl({
    required this.syncId,
    this.deviceId = '',
    this.isDeleted = false,
    @JsonKey(includeFromJson: false, includeToJson: false) this.isDirty = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$SyncMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncMetadataImplFromJson(json);

  @override
  final String syncId;
  @override
  @JsonKey()
  final String deviceId;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isDirty;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SyncMetadata(syncId: $syncId, deviceId: $deviceId, isDeleted: $isDeleted, isDirty: $isDirty, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncMetadataImpl &&
            (identical(other.syncId, syncId) || other.syncId == syncId) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.isDirty, isDirty) || other.isDirty == isDirty) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    syncId,
    deviceId,
    isDeleted,
    isDirty,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SyncMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncMetadataImplCopyWith<_$SyncMetadataImpl> get copyWith =>
      __$$SyncMetadataImplCopyWithImpl<_$SyncMetadataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncMetadataImplToJson(this);
  }
}

abstract class _SyncMetadata implements SyncMetadata {
  const factory _SyncMetadata({
    required final String syncId,
    final String deviceId,
    final bool isDeleted,
    @JsonKey(includeFromJson: false, includeToJson: false) final bool isDirty,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$SyncMetadataImpl;

  factory _SyncMetadata.fromJson(Map<String, dynamic> json) =
      _$SyncMetadataImpl.fromJson;

  @override
  String get syncId;
  @override
  String get deviceId;
  @override
  bool get isDeleted;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isDirty;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SyncMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncMetadataImplCopyWith<_$SyncMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
