// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'charge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Charge _$ChargeFromJson(Map<String, dynamic> json) {
  return _Charge.fromJson(json);
}

/// @nodoc
mixin _$Charge {
  String get id => throw _privateConstructorUsedError;
  double get lowerBound => throw _privateConstructorUsedError;
  double get upperBound => throw _privateConstructorUsedError;
  double get chargeAmount => throw _privateConstructorUsedError;
  String get transactionTypeKey => throw _privateConstructorUsedError;
  SyncMetadata get sync => throw _privateConstructorUsedError;

  /// Serializes this Charge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Charge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChargeCopyWith<Charge> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChargeCopyWith<$Res> {
  factory $ChargeCopyWith(Charge value, $Res Function(Charge) then) =
      _$ChargeCopyWithImpl<$Res, Charge>;
  @useResult
  $Res call({
    String id,
    double lowerBound,
    double upperBound,
    double chargeAmount,
    String transactionTypeKey,
    SyncMetadata sync,
  });

  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class _$ChargeCopyWithImpl<$Res, $Val extends Charge>
    implements $ChargeCopyWith<$Res> {
  _$ChargeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Charge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lowerBound = null,
    Object? upperBound = null,
    Object? chargeAmount = null,
    Object? transactionTypeKey = null,
    Object? sync = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            lowerBound: null == lowerBound
                ? _value.lowerBound
                : lowerBound // ignore: cast_nullable_to_non_nullable
                      as double,
            upperBound: null == upperBound
                ? _value.upperBound
                : upperBound // ignore: cast_nullable_to_non_nullable
                      as double,
            chargeAmount: null == chargeAmount
                ? _value.chargeAmount
                : chargeAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            transactionTypeKey: null == transactionTypeKey
                ? _value.transactionTypeKey
                : transactionTypeKey // ignore: cast_nullable_to_non_nullable
                      as String,
            sync: null == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as SyncMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of Charge
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
abstract class _$$ChargeImplCopyWith<$Res> implements $ChargeCopyWith<$Res> {
  factory _$$ChargeImplCopyWith(
    _$ChargeImpl value,
    $Res Function(_$ChargeImpl) then,
  ) = __$$ChargeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    double lowerBound,
    double upperBound,
    double chargeAmount,
    String transactionTypeKey,
    SyncMetadata sync,
  });

  @override
  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class __$$ChargeImplCopyWithImpl<$Res>
    extends _$ChargeCopyWithImpl<$Res, _$ChargeImpl>
    implements _$$ChargeImplCopyWith<$Res> {
  __$$ChargeImplCopyWithImpl(
    _$ChargeImpl _value,
    $Res Function(_$ChargeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Charge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lowerBound = null,
    Object? upperBound = null,
    Object? chargeAmount = null,
    Object? transactionTypeKey = null,
    Object? sync = null,
  }) {
    return _then(
      _$ChargeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        lowerBound: null == lowerBound
            ? _value.lowerBound
            : lowerBound // ignore: cast_nullable_to_non_nullable
                  as double,
        upperBound: null == upperBound
            ? _value.upperBound
            : upperBound // ignore: cast_nullable_to_non_nullable
                  as double,
        chargeAmount: null == chargeAmount
            ? _value.chargeAmount
            : chargeAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        transactionTypeKey: null == transactionTypeKey
            ? _value.transactionTypeKey
            : transactionTypeKey // ignore: cast_nullable_to_non_nullable
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
class _$ChargeImpl implements _Charge {
  const _$ChargeImpl({
    required this.id,
    required this.lowerBound,
    required this.upperBound,
    required this.chargeAmount,
    this.transactionTypeKey = 'gcash_cashin',
    required this.sync,
  });

  factory _$ChargeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChargeImplFromJson(json);

  @override
  final String id;
  @override
  final double lowerBound;
  @override
  final double upperBound;
  @override
  final double chargeAmount;
  @override
  @JsonKey()
  final String transactionTypeKey;
  @override
  final SyncMetadata sync;

  @override
  String toString() {
    return 'Charge(id: $id, lowerBound: $lowerBound, upperBound: $upperBound, chargeAmount: $chargeAmount, transactionTypeKey: $transactionTypeKey, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChargeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lowerBound, lowerBound) ||
                other.lowerBound == lowerBound) &&
            (identical(other.upperBound, upperBound) ||
                other.upperBound == upperBound) &&
            (identical(other.chargeAmount, chargeAmount) ||
                other.chargeAmount == chargeAmount) &&
            (identical(other.transactionTypeKey, transactionTypeKey) ||
                other.transactionTypeKey == transactionTypeKey) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    lowerBound,
    upperBound,
    chargeAmount,
    transactionTypeKey,
    sync,
  );

  /// Create a copy of Charge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChargeImplCopyWith<_$ChargeImpl> get copyWith =>
      __$$ChargeImplCopyWithImpl<_$ChargeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChargeImplToJson(this);
  }
}

abstract class _Charge implements Charge {
  const factory _Charge({
    required final String id,
    required final double lowerBound,
    required final double upperBound,
    required final double chargeAmount,
    final String transactionTypeKey,
    required final SyncMetadata sync,
  }) = _$ChargeImpl;

  factory _Charge.fromJson(Map<String, dynamic> json) = _$ChargeImpl.fromJson;

  @override
  String get id;
  @override
  double get lowerBound;
  @override
  double get upperBound;
  @override
  double get chargeAmount;
  @override
  String get transactionTypeKey;
  @override
  SyncMetadata get sync;

  /// Create a copy of Charge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChargeImplCopyWith<_$ChargeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
