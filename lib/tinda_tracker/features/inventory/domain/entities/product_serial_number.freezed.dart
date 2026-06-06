// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_serial_number.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductSerialNumber _$ProductSerialNumberFromJson(Map<String, dynamic> json) {
  return _ProductSerialNumber.fromJson(json);
}

/// @nodoc
mixin _$ProductSerialNumber {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get serialNumber => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // AVAILABLE, SOLD, WASTE, RETURNED
  SyncMetadata get sync => throw _privateConstructorUsedError;

  /// Serializes this ProductSerialNumber to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductSerialNumber
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductSerialNumberCopyWith<ProductSerialNumber> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductSerialNumberCopyWith<$Res> {
  factory $ProductSerialNumberCopyWith(
    ProductSerialNumber value,
    $Res Function(ProductSerialNumber) then,
  ) = _$ProductSerialNumberCopyWithImpl<$Res, ProductSerialNumber>;
  @useResult
  $Res call({
    String id,
    String productId,
    String serialNumber,
    String status,
    SyncMetadata sync,
  });

  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class _$ProductSerialNumberCopyWithImpl<$Res, $Val extends ProductSerialNumber>
    implements $ProductSerialNumberCopyWith<$Res> {
  _$ProductSerialNumberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductSerialNumber
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? serialNumber = null,
    Object? status = null,
    Object? sync = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            serialNumber: null == serialNumber
                ? _value.serialNumber
                : serialNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            sync: null == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as SyncMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of ProductSerialNumber
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
abstract class _$$ProductSerialNumberImplCopyWith<$Res>
    implements $ProductSerialNumberCopyWith<$Res> {
  factory _$$ProductSerialNumberImplCopyWith(
    _$ProductSerialNumberImpl value,
    $Res Function(_$ProductSerialNumberImpl) then,
  ) = __$$ProductSerialNumberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String productId,
    String serialNumber,
    String status,
    SyncMetadata sync,
  });

  @override
  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class __$$ProductSerialNumberImplCopyWithImpl<$Res>
    extends _$ProductSerialNumberCopyWithImpl<$Res, _$ProductSerialNumberImpl>
    implements _$$ProductSerialNumberImplCopyWith<$Res> {
  __$$ProductSerialNumberImplCopyWithImpl(
    _$ProductSerialNumberImpl _value,
    $Res Function(_$ProductSerialNumberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductSerialNumber
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? serialNumber = null,
    Object? status = null,
    Object? sync = null,
  }) {
    return _then(
      _$ProductSerialNumberImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        serialNumber: null == serialNumber
            ? _value.serialNumber
            : serialNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
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
class _$ProductSerialNumberImpl implements _ProductSerialNumber {
  const _$ProductSerialNumberImpl({
    required this.id,
    required this.productId,
    required this.serialNumber,
    this.status = 'AVAILABLE',
    required this.sync,
  });

  factory _$ProductSerialNumberImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductSerialNumberImplFromJson(json);

  @override
  final String id;
  @override
  final String productId;
  @override
  final String serialNumber;
  @override
  @JsonKey()
  final String status;
  // AVAILABLE, SOLD, WASTE, RETURNED
  @override
  final SyncMetadata sync;

  @override
  String toString() {
    return 'ProductSerialNumber(id: $id, productId: $productId, serialNumber: $serialNumber, status: $status, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductSerialNumberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, productId, serialNumber, status, sync);

  /// Create a copy of ProductSerialNumber
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductSerialNumberImplCopyWith<_$ProductSerialNumberImpl> get copyWith =>
      __$$ProductSerialNumberImplCopyWithImpl<_$ProductSerialNumberImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductSerialNumberImplToJson(this);
  }
}

abstract class _ProductSerialNumber implements ProductSerialNumber {
  const factory _ProductSerialNumber({
    required final String id,
    required final String productId,
    required final String serialNumber,
    final String status,
    required final SyncMetadata sync,
  }) = _$ProductSerialNumberImpl;

  factory _ProductSerialNumber.fromJson(Map<String, dynamic> json) =
      _$ProductSerialNumberImpl.fromJson;

  @override
  String get id;
  @override
  String get productId;
  @override
  String get serialNumber;
  @override
  String get status; // AVAILABLE, SOLD, WASTE, RETURNED
  @override
  SyncMetadata get sync;

  /// Create a copy of ProductSerialNumber
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductSerialNumberImplCopyWith<_$ProductSerialNumberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
