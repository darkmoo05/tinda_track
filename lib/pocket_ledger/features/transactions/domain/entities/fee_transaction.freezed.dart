// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fee_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FeeTransaction _$FeeTransactionFromJson(Map<String, dynamic> json) {
  return _FeeTransaction.fromJson(json);
}

/// @nodoc
mixin _$FeeTransaction {
  String get id => throw _privateConstructorUsedError;
  String? get relatedTransactionSyncId => throw _privateConstructorUsedError;
  double get feeAmount => throw _privateConstructorUsedError;
  String get feeType => throw _privateConstructorUsedError;
  String get chargeDestination => throw _privateConstructorUsedError;
  SyncMetadata get sync => throw _privateConstructorUsedError;

  /// Serializes this FeeTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeeTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeeTransactionCopyWith<FeeTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeeTransactionCopyWith<$Res> {
  factory $FeeTransactionCopyWith(
    FeeTransaction value,
    $Res Function(FeeTransaction) then,
  ) = _$FeeTransactionCopyWithImpl<$Res, FeeTransaction>;
  @useResult
  $Res call({
    String id,
    String? relatedTransactionSyncId,
    double feeAmount,
    String feeType,
    String chargeDestination,
    SyncMetadata sync,
  });

  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class _$FeeTransactionCopyWithImpl<$Res, $Val extends FeeTransaction>
    implements $FeeTransactionCopyWith<$Res> {
  _$FeeTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeeTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? relatedTransactionSyncId = freezed,
    Object? feeAmount = null,
    Object? feeType = null,
    Object? chargeDestination = null,
    Object? sync = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            relatedTransactionSyncId: freezed == relatedTransactionSyncId
                ? _value.relatedTransactionSyncId
                : relatedTransactionSyncId // ignore: cast_nullable_to_non_nullable
                      as String?,
            feeAmount: null == feeAmount
                ? _value.feeAmount
                : feeAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            feeType: null == feeType
                ? _value.feeType
                : feeType // ignore: cast_nullable_to_non_nullable
                      as String,
            chargeDestination: null == chargeDestination
                ? _value.chargeDestination
                : chargeDestination // ignore: cast_nullable_to_non_nullable
                      as String,
            sync: null == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as SyncMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of FeeTransaction
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
abstract class _$$FeeTransactionImplCopyWith<$Res>
    implements $FeeTransactionCopyWith<$Res> {
  factory _$$FeeTransactionImplCopyWith(
    _$FeeTransactionImpl value,
    $Res Function(_$FeeTransactionImpl) then,
  ) = __$$FeeTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? relatedTransactionSyncId,
    double feeAmount,
    String feeType,
    String chargeDestination,
    SyncMetadata sync,
  });

  @override
  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class __$$FeeTransactionImplCopyWithImpl<$Res>
    extends _$FeeTransactionCopyWithImpl<$Res, _$FeeTransactionImpl>
    implements _$$FeeTransactionImplCopyWith<$Res> {
  __$$FeeTransactionImplCopyWithImpl(
    _$FeeTransactionImpl _value,
    $Res Function(_$FeeTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeeTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? relatedTransactionSyncId = freezed,
    Object? feeAmount = null,
    Object? feeType = null,
    Object? chargeDestination = null,
    Object? sync = null,
  }) {
    return _then(
      _$FeeTransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        relatedTransactionSyncId: freezed == relatedTransactionSyncId
            ? _value.relatedTransactionSyncId
            : relatedTransactionSyncId // ignore: cast_nullable_to_non_nullable
                  as String?,
        feeAmount: null == feeAmount
            ? _value.feeAmount
            : feeAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        feeType: null == feeType
            ? _value.feeType
            : feeType // ignore: cast_nullable_to_non_nullable
                  as String,
        chargeDestination: null == chargeDestination
            ? _value.chargeDestination
            : chargeDestination // ignore: cast_nullable_to_non_nullable
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
class _$FeeTransactionImpl implements _FeeTransaction {
  const _$FeeTransactionImpl({
    required this.id,
    this.relatedTransactionSyncId,
    required this.feeAmount,
    required this.feeType,
    required this.chargeDestination,
    required this.sync,
  });

  factory _$FeeTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeeTransactionImplFromJson(json);

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
  @override
  final SyncMetadata sync;

  @override
  String toString() {
    return 'FeeTransaction(id: $id, relatedTransactionSyncId: $relatedTransactionSyncId, feeAmount: $feeAmount, feeType: $feeType, chargeDestination: $chargeDestination, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(
                  other.relatedTransactionSyncId,
                  relatedTransactionSyncId,
                ) ||
                other.relatedTransactionSyncId == relatedTransactionSyncId) &&
            (identical(other.feeAmount, feeAmount) ||
                other.feeAmount == feeAmount) &&
            (identical(other.feeType, feeType) || other.feeType == feeType) &&
            (identical(other.chargeDestination, chargeDestination) ||
                other.chargeDestination == chargeDestination) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    relatedTransactionSyncId,
    feeAmount,
    feeType,
    chargeDestination,
    sync,
  );

  /// Create a copy of FeeTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeTransactionImplCopyWith<_$FeeTransactionImpl> get copyWith =>
      __$$FeeTransactionImplCopyWithImpl<_$FeeTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FeeTransactionImplToJson(this);
  }
}

abstract class _FeeTransaction implements FeeTransaction {
  const factory _FeeTransaction({
    required final String id,
    final String? relatedTransactionSyncId,
    required final double feeAmount,
    required final String feeType,
    required final String chargeDestination,
    required final SyncMetadata sync,
  }) = _$FeeTransactionImpl;

  factory _FeeTransaction.fromJson(Map<String, dynamic> json) =
      _$FeeTransactionImpl.fromJson;

  @override
  String get id;
  @override
  String? get relatedTransactionSyncId;
  @override
  double get feeAmount;
  @override
  String get feeType;
  @override
  String get chargeDestination;
  @override
  SyncMetadata get sync;

  /// Create a copy of FeeTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeTransactionImplCopyWith<_$FeeTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
