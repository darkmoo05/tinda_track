// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'party.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Party _$PartyFromJson(Map<String, dynamic> json) {
  return _Party.fromJson(json);
}

/// @nodoc
mixin _$Party {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get accountNumber => throw _privateConstructorUsedError;
  String get entityId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get joinDate => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  SyncMetadata get sync => throw _privateConstructorUsedError;

  /// Serializes this Party to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Party
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartyCopyWith<Party> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartyCopyWith<$Res> {
  factory $PartyCopyWith(Party value, $Res Function(Party) then) =
      _$PartyCopyWithImpl<$Res, Party>;
  @useResult
  $Res call({
    String id,
    String name,
    String accountNumber,
    String entityId,
    String description,
    String joinDate,
    bool isVerified,
    SyncMetadata sync,
  });

  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class _$PartyCopyWithImpl<$Res, $Val extends Party>
    implements $PartyCopyWith<$Res> {
  _$PartyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Party
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? accountNumber = null,
    Object? entityId = null,
    Object? description = null,
    Object? joinDate = null,
    Object? isVerified = null,
    Object? sync = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            accountNumber: null == accountNumber
                ? _value.accountNumber
                : accountNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            entityId: null == entityId
                ? _value.entityId
                : entityId // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            joinDate: null == joinDate
                ? _value.joinDate
                : joinDate // ignore: cast_nullable_to_non_nullable
                      as String,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            sync: null == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as SyncMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of Party
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
abstract class _$$PartyImplCopyWith<$Res> implements $PartyCopyWith<$Res> {
  factory _$$PartyImplCopyWith(
    _$PartyImpl value,
    $Res Function(_$PartyImpl) then,
  ) = __$$PartyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String accountNumber,
    String entityId,
    String description,
    String joinDate,
    bool isVerified,
    SyncMetadata sync,
  });

  @override
  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class __$$PartyImplCopyWithImpl<$Res>
    extends _$PartyCopyWithImpl<$Res, _$PartyImpl>
    implements _$$PartyImplCopyWith<$Res> {
  __$$PartyImplCopyWithImpl(
    _$PartyImpl _value,
    $Res Function(_$PartyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Party
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? accountNumber = null,
    Object? entityId = null,
    Object? description = null,
    Object? joinDate = null,
    Object? isVerified = null,
    Object? sync = null,
  }) {
    return _then(
      _$PartyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        accountNumber: null == accountNumber
            ? _value.accountNumber
            : accountNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        entityId: null == entityId
            ? _value.entityId
            : entityId // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        joinDate: null == joinDate
            ? _value.joinDate
            : joinDate // ignore: cast_nullable_to_non_nullable
                  as String,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$PartyImpl implements _Party {
  const _$PartyImpl({
    required this.id,
    required this.name,
    this.accountNumber = '',
    this.entityId = '',
    this.description = '',
    required this.joinDate,
    this.isVerified = false,
    required this.sync,
  });

  factory _$PartyImpl.fromJson(Map<String, dynamic> json) =>
      _$$PartyImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String accountNumber;
  @override
  @JsonKey()
  final String entityId;
  @override
  @JsonKey()
  final String description;
  @override
  final String joinDate;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  final SyncMetadata sync;

  @override
  String toString() {
    return 'Party(id: $id, name: $name, accountNumber: $accountNumber, entityId: $entityId, description: $description, joinDate: $joinDate, isVerified: $isVerified, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.joinDate, joinDate) ||
                other.joinDate == joinDate) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    accountNumber,
    entityId,
    description,
    joinDate,
    isVerified,
    sync,
  );

  /// Create a copy of Party
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartyImplCopyWith<_$PartyImpl> get copyWith =>
      __$$PartyImplCopyWithImpl<_$PartyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PartyImplToJson(this);
  }
}

abstract class _Party implements Party {
  const factory _Party({
    required final String id,
    required final String name,
    final String accountNumber,
    final String entityId,
    final String description,
    required final String joinDate,
    final bool isVerified,
    required final SyncMetadata sync,
  }) = _$PartyImpl;

  factory _Party.fromJson(Map<String, dynamic> json) = _$PartyImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get accountNumber;
  @override
  String get entityId;
  @override
  String get description;
  @override
  String get joinDate;
  @override
  bool get isVerified;
  @override
  SyncMetadata get sync;

  /// Create a copy of Party
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartyImplCopyWith<_$PartyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
