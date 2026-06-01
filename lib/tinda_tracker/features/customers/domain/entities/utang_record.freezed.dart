// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'utang_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UtangRecord _$UtangRecordFromJson(Map<String, dynamic> json) {
  return _UtangRecord.fromJson(json);
}

/// @nodoc
mixin _$UtangRecord {
  String get id => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  SyncMetadata get sync => throw _privateConstructorUsedError;

  /// Serializes this UtangRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UtangRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UtangRecordCopyWith<UtangRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UtangRecordCopyWith<$Res> {
  factory $UtangRecordCopyWith(
    UtangRecord value,
    $Res Function(UtangRecord) then,
  ) = _$UtangRecordCopyWithImpl<$Res, UtangRecord>;
  @useResult
  $Res call({
    String id,
    String customerId,
    String description,
    double amount,
    SyncMetadata sync,
  });

  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class _$UtangRecordCopyWithImpl<$Res, $Val extends UtangRecord>
    implements $UtangRecordCopyWith<$Res> {
  _$UtangRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UtangRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? description = null,
    Object? amount = null,
    Object? sync = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            sync: null == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as SyncMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of UtangRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SyncMetadataCopyWith<$Res> get sync {
    return $SyncMetadataCopyWith<$Res>(_value.sync, (value) {
      return _then(_value.copyWith(sync: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UtangRecordImplCopyWith<$Res>
    implements $UtangRecordCopyWith<$Res> {
  factory _$$UtangRecordImplCopyWith(
    _$UtangRecordImpl value,
    $Res Function(_$UtangRecordImpl) then,
  ) = __$$UtangRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String customerId,
    String description,
    double amount,
    SyncMetadata sync,
  });

  @override
  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class __$$UtangRecordImplCopyWithImpl<$Res>
    extends _$UtangRecordCopyWithImpl<$Res, _$UtangRecordImpl>
    implements _$$UtangRecordImplCopyWith<$Res> {
  __$$UtangRecordImplCopyWithImpl(
    _$UtangRecordImpl _value,
    $Res Function(_$UtangRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UtangRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? description = null,
    Object? amount = null,
    Object? sync = null,
  }) {
    return _then(
      _$UtangRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        sync: null == sync
            ? _value.sync
            : sync // ignore: cast_nullable_to_non_nullable
                  as SyncMetadata,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UtangRecordImpl implements _UtangRecord {
  const _$UtangRecordImpl({
    required this.id,
    required this.customerId,
    this.description = '',
    required this.amount,
    required this.sync,
  });

  factory _$UtangRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$UtangRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String customerId;
  @override
  @JsonKey()
  final String description;
  @override
  final double amount;
  @override
  final SyncMetadata sync;

  @override
  String toString() {
    return 'UtangRecord(id: $id, customerId: $customerId, description: $description, amount: $amount, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UtangRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, customerId, description, amount, sync);

  /// Create a copy of UtangRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UtangRecordImplCopyWith<_$UtangRecordImpl> get copyWith =>
      __$$UtangRecordImplCopyWithImpl<_$UtangRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UtangRecordImplToJson(this);
  }
}

abstract class _UtangRecord implements UtangRecord {
  const factory _UtangRecord({
    required final String id,
    required final String customerId,
    final String description,
    required final double amount,
    required final SyncMetadata sync,
  }) = _$UtangRecordImpl;

  factory _UtangRecord.fromJson(Map<String, dynamic> json) =
      _$UtangRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get customerId;
  @override
  String get description;
  @override
  double get amount;
  @override
  SyncMetadata get sync;

  /// Create a copy of UtangRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UtangRecordImplCopyWith<_$UtangRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
