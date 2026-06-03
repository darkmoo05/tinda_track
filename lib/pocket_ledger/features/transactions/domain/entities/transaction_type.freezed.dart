// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TransactionType _$TransactionTypeFromJson(Map<String, dynamic> json) {
  return _TransactionType.fromJson(json);
}

/// @nodoc
mixin _$TransactionType {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get isOutflow => throw _privateConstructorUsedError;
  String get walletAccount => throw _privateConstructorUsedError;
  SyncMetadata get sync => throw _privateConstructorUsedError;

  /// Serializes this TransactionType to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransactionType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionTypeCopyWith<TransactionType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionTypeCopyWith<$Res> {
  factory $TransactionTypeCopyWith(
    TransactionType value,
    $Res Function(TransactionType) then,
  ) = _$TransactionTypeCopyWithImpl<$Res, TransactionType>;
  @useResult
  $Res call({
    String id,
    String name,
    bool isOutflow,
    String walletAccount,
    SyncMetadata sync,
  });

  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class _$TransactionTypeCopyWithImpl<$Res, $Val extends TransactionType>
    implements $TransactionTypeCopyWith<$Res> {
  _$TransactionTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isOutflow = null,
    Object? walletAccount = null,
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
            isOutflow: null == isOutflow
                ? _value.isOutflow
                : isOutflow // ignore: cast_nullable_to_non_nullable
                      as bool,
            walletAccount: null == walletAccount
                ? _value.walletAccount
                : walletAccount // ignore: cast_nullable_to_non_nullable
                      as String,
            sync: null == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as SyncMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of TransactionType
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
abstract class _$$TransactionTypeImplCopyWith<$Res>
    implements $TransactionTypeCopyWith<$Res> {
  factory _$$TransactionTypeImplCopyWith(
    _$TransactionTypeImpl value,
    $Res Function(_$TransactionTypeImpl) then,
  ) = __$$TransactionTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    bool isOutflow,
    String walletAccount,
    SyncMetadata sync,
  });

  @override
  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class __$$TransactionTypeImplCopyWithImpl<$Res>
    extends _$TransactionTypeCopyWithImpl<$Res, _$TransactionTypeImpl>
    implements _$$TransactionTypeImplCopyWith<$Res> {
  __$$TransactionTypeImplCopyWithImpl(
    _$TransactionTypeImpl _value,
    $Res Function(_$TransactionTypeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransactionType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isOutflow = null,
    Object? walletAccount = null,
    Object? sync = null,
  }) {
    return _then(
      _$TransactionTypeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        isOutflow: null == isOutflow
            ? _value.isOutflow
            : isOutflow // ignore: cast_nullable_to_non_nullable
                  as bool,
        walletAccount: null == walletAccount
            ? _value.walletAccount
            : walletAccount // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$TransactionTypeImpl implements _TransactionType {
  const _$TransactionTypeImpl({
    required this.id,
    required this.name,
    this.isOutflow = false,
    this.walletAccount = 'GCash',
    required this.sync,
  });

  factory _$TransactionTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionTypeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final bool isOutflow;
  @override
  @JsonKey()
  final String walletAccount;
  @override
  final SyncMetadata sync;

  @override
  String toString() {
    return 'TransactionType(id: $id, name: $name, isOutflow: $isOutflow, walletAccount: $walletAccount, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionTypeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isOutflow, isOutflow) ||
                other.isOutflow == isOutflow) &&
            (identical(other.walletAccount, walletAccount) ||
                other.walletAccount == walletAccount) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, isOutflow, walletAccount, sync);

  /// Create a copy of TransactionType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionTypeImplCopyWith<_$TransactionTypeImpl> get copyWith =>
      __$$TransactionTypeImplCopyWithImpl<_$TransactionTypeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionTypeImplToJson(this);
  }
}

abstract class _TransactionType implements TransactionType {
  const factory _TransactionType({
    required final String id,
    required final String name,
    final bool isOutflow,
    final String walletAccount,
    required final SyncMetadata sync,
  }) = _$TransactionTypeImpl;

  factory _TransactionType.fromJson(Map<String, dynamic> json) =
      _$TransactionTypeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  bool get isOutflow;
  @override
  String get walletAccount;
  @override
  SyncMetadata get sync;

  /// Create a copy of TransactionType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionTypeImplCopyWith<_$TransactionTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
