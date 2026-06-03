// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_movement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StockMovement _$StockMovementFromJson(Map<String, dynamic> json) {
  return _StockMovement.fromJson(json);
}

/// @nodoc
mixin _$StockMovement {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  @_StockMovementTypeConverter()
  StockMovementType get movementType => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  double get previousQuantity => throw _privateConstructorUsedError;
  double get newQuantity => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  String get reference => throw _privateConstructorUsedError;
  DateTime? get expirationDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isDirty => throw _privateConstructorUsedError;

  /// Serializes this StockMovement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockMovementCopyWith<StockMovement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockMovementCopyWith<$Res> {
  factory $StockMovementCopyWith(
    StockMovement value,
    $Res Function(StockMovement) then,
  ) = _$StockMovementCopyWithImpl<$Res, StockMovement>;
  @useResult
  $Res call({
    String id,
    String productId,
    @_StockMovementTypeConverter() StockMovementType movementType,
    double quantity,
    double previousQuantity,
    double newQuantity,
    String note,
    String reference,
    DateTime? expirationDate,
    DateTime createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false) bool isDirty,
  });
}

/// @nodoc
class _$StockMovementCopyWithImpl<$Res, $Val extends StockMovement>
    implements $StockMovementCopyWith<$Res> {
  _$StockMovementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? movementType = null,
    Object? quantity = null,
    Object? previousQuantity = null,
    Object? newQuantity = null,
    Object? note = null,
    Object? reference = null,
    Object? expirationDate = freezed,
    Object? createdAt = null,
    Object? isDirty = null,
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
            movementType: null == movementType
                ? _value.movementType
                : movementType // ignore: cast_nullable_to_non_nullable
                      as StockMovementType,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            previousQuantity: null == previousQuantity
                ? _value.previousQuantity
                : previousQuantity // ignore: cast_nullable_to_non_nullable
                      as double,
            newQuantity: null == newQuantity
                ? _value.newQuantity
                : newQuantity // ignore: cast_nullable_to_non_nullable
                      as double,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
            reference: null == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as String,
            expirationDate: freezed == expirationDate
                ? _value.expirationDate
                : expirationDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isDirty: null == isDirty
                ? _value.isDirty
                : isDirty // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StockMovementImplCopyWith<$Res>
    implements $StockMovementCopyWith<$Res> {
  factory _$$StockMovementImplCopyWith(
    _$StockMovementImpl value,
    $Res Function(_$StockMovementImpl) then,
  ) = __$$StockMovementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String productId,
    @_StockMovementTypeConverter() StockMovementType movementType,
    double quantity,
    double previousQuantity,
    double newQuantity,
    String note,
    String reference,
    DateTime? expirationDate,
    DateTime createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false) bool isDirty,
  });
}

/// @nodoc
class __$$StockMovementImplCopyWithImpl<$Res>
    extends _$StockMovementCopyWithImpl<$Res, _$StockMovementImpl>
    implements _$$StockMovementImplCopyWith<$Res> {
  __$$StockMovementImplCopyWithImpl(
    _$StockMovementImpl _value,
    $Res Function(_$StockMovementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? movementType = null,
    Object? quantity = null,
    Object? previousQuantity = null,
    Object? newQuantity = null,
    Object? note = null,
    Object? reference = null,
    Object? expirationDate = freezed,
    Object? createdAt = null,
    Object? isDirty = null,
  }) {
    return _then(
      _$StockMovementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        movementType: null == movementType
            ? _value.movementType
            : movementType // ignore: cast_nullable_to_non_nullable
                  as StockMovementType,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        previousQuantity: null == previousQuantity
            ? _value.previousQuantity
            : previousQuantity // ignore: cast_nullable_to_non_nullable
                  as double,
        newQuantity: null == newQuantity
            ? _value.newQuantity
            : newQuantity // ignore: cast_nullable_to_non_nullable
                  as double,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
        reference: null == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String,
        expirationDate: freezed == expirationDate
            ? _value.expirationDate
            : expirationDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isDirty: null == isDirty
            ? _value.isDirty
            : isDirty // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StockMovementImpl implements _StockMovement {
  const _$StockMovementImpl({
    required this.id,
    required this.productId,
    @_StockMovementTypeConverter() required this.movementType,
    required this.quantity,
    required this.previousQuantity,
    required this.newQuantity,
    this.note = '',
    this.reference = '',
    this.expirationDate,
    required this.createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false) this.isDirty = false,
  });

  factory _$StockMovementImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockMovementImplFromJson(json);

  @override
  final String id;
  @override
  final String productId;
  @override
  @_StockMovementTypeConverter()
  final StockMovementType movementType;
  @override
  final double quantity;
  @override
  final double previousQuantity;
  @override
  final double newQuantity;
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey()
  final String reference;
  @override
  final DateTime? expirationDate;
  @override
  final DateTime createdAt;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isDirty;

  @override
  String toString() {
    return 'StockMovement(id: $id, productId: $productId, movementType: $movementType, quantity: $quantity, previousQuantity: $previousQuantity, newQuantity: $newQuantity, note: $note, reference: $reference, expirationDate: $expirationDate, createdAt: $createdAt, isDirty: $isDirty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockMovementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.movementType, movementType) ||
                other.movementType == movementType) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.previousQuantity, previousQuantity) ||
                other.previousQuantity == previousQuantity) &&
            (identical(other.newQuantity, newQuantity) ||
                other.newQuantity == newQuantity) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isDirty, isDirty) || other.isDirty == isDirty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    productId,
    movementType,
    quantity,
    previousQuantity,
    newQuantity,
    note,
    reference,
    expirationDate,
    createdAt,
    isDirty,
  );

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockMovementImplCopyWith<_$StockMovementImpl> get copyWith =>
      __$$StockMovementImplCopyWithImpl<_$StockMovementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StockMovementImplToJson(this);
  }
}

abstract class _StockMovement implements StockMovement {
  const factory _StockMovement({
    required final String id,
    required final String productId,
    @_StockMovementTypeConverter()
    required final StockMovementType movementType,
    required final double quantity,
    required final double previousQuantity,
    required final double newQuantity,
    final String note,
    final String reference,
    final DateTime? expirationDate,
    required final DateTime createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false) final bool isDirty,
  }) = _$StockMovementImpl;

  factory _StockMovement.fromJson(Map<String, dynamic> json) =
      _$StockMovementImpl.fromJson;

  @override
  String get id;
  @override
  String get productId;
  @override
  @_StockMovementTypeConverter()
  StockMovementType get movementType;
  @override
  double get quantity;
  @override
  double get previousQuantity;
  @override
  double get newQuantity;
  @override
  String get note;
  @override
  String get reference;
  @override
  DateTime? get expirationDate;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isDirty;

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockMovementImplCopyWith<_$StockMovementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
