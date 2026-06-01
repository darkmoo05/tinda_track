// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get baseUnit => throw _privateConstructorUsedError;
  double get costPrice => throw _privateConstructorUsedError;
  double get sellingPrice => throw _privateConstructorUsedError;
  double get stockInBaseUnit => throw _privateConstructorUsedError;
  int get reorderPoint => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get imageLocalPath => throw _privateConstructorUsedError;
  String? get shelfLocation => throw _privateConstructorUsedError;
  DateTime? get expirationDate => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String? get shelfLocationId => throw _privateConstructorUsedError;
  SyncMetadata get sync => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call({
    String id,
    String name,
    String sku,
    String description,
    String category,
    String baseUnit,
    double costPrice,
    double sellingPrice,
    double stockInBaseUnit,
    int reorderPoint,
    bool isActive,
    String? imageUrl,
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? imageLocalPath,
    String? shelfLocation,
    DateTime? expirationDate,
    String? categoryId,
    String? shelfLocationId,
    SyncMetadata sync,
  });

  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sku = null,
    Object? description = null,
    Object? category = null,
    Object? baseUnit = null,
    Object? costPrice = null,
    Object? sellingPrice = null,
    Object? stockInBaseUnit = null,
    Object? reorderPoint = null,
    Object? isActive = null,
    Object? imageUrl = freezed,
    Object? imageLocalPath = freezed,
    Object? shelfLocation = freezed,
    Object? expirationDate = freezed,
    Object? categoryId = freezed,
    Object? shelfLocationId = freezed,
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
            sku: null == sku
                ? _value.sku
                : sku // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            baseUnit: null == baseUnit
                ? _value.baseUnit
                : baseUnit // ignore: cast_nullable_to_non_nullable
                      as String,
            costPrice: null == costPrice
                ? _value.costPrice
                : costPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            sellingPrice: null == sellingPrice
                ? _value.sellingPrice
                : sellingPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            stockInBaseUnit: null == stockInBaseUnit
                ? _value.stockInBaseUnit
                : stockInBaseUnit // ignore: cast_nullable_to_non_nullable
                      as double,
            reorderPoint: null == reorderPoint
                ? _value.reorderPoint
                : reorderPoint // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageLocalPath: freezed == imageLocalPath
                ? _value.imageLocalPath
                : imageLocalPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            shelfLocation: freezed == shelfLocation
                ? _value.shelfLocation
                : shelfLocation // ignore: cast_nullable_to_non_nullable
                      as String?,
            expirationDate: freezed == expirationDate
                ? _value.expirationDate
                : expirationDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            shelfLocationId: freezed == shelfLocationId
                ? _value.shelfLocationId
                : shelfLocationId // ignore: cast_nullable_to_non_nullable
                      as String?,
            sync: null == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as SyncMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of Product
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
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
    _$ProductImpl value,
    $Res Function(_$ProductImpl) then,
  ) = __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String sku,
    String description,
    String category,
    String baseUnit,
    double costPrice,
    double sellingPrice,
    double stockInBaseUnit,
    int reorderPoint,
    bool isActive,
    String? imageUrl,
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? imageLocalPath,
    String? shelfLocation,
    DateTime? expirationDate,
    String? categoryId,
    String? shelfLocationId,
    SyncMetadata sync,
  });

  @override
  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
    _$ProductImpl _value,
    $Res Function(_$ProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sku = null,
    Object? description = null,
    Object? category = null,
    Object? baseUnit = null,
    Object? costPrice = null,
    Object? sellingPrice = null,
    Object? stockInBaseUnit = null,
    Object? reorderPoint = null,
    Object? isActive = null,
    Object? imageUrl = freezed,
    Object? imageLocalPath = freezed,
    Object? shelfLocation = freezed,
    Object? expirationDate = freezed,
    Object? categoryId = freezed,
    Object? shelfLocationId = freezed,
    Object? sync = null,
  }) {
    return _then(
      _$ProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sku: null == sku
            ? _value.sku
            : sku // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        baseUnit: null == baseUnit
            ? _value.baseUnit
            : baseUnit // ignore: cast_nullable_to_non_nullable
                  as String,
        costPrice: null == costPrice
            ? _value.costPrice
            : costPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        sellingPrice: null == sellingPrice
            ? _value.sellingPrice
            : sellingPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        stockInBaseUnit: null == stockInBaseUnit
            ? _value.stockInBaseUnit
            : stockInBaseUnit // ignore: cast_nullable_to_non_nullable
                  as double,
        reorderPoint: null == reorderPoint
            ? _value.reorderPoint
            : reorderPoint // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageLocalPath: freezed == imageLocalPath
            ? _value.imageLocalPath
            : imageLocalPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        shelfLocation: freezed == shelfLocation
            ? _value.shelfLocation
            : shelfLocation // ignore: cast_nullable_to_non_nullable
                  as String?,
        expirationDate: freezed == expirationDate
            ? _value.expirationDate
            : expirationDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        shelfLocationId: freezed == shelfLocationId
            ? _value.shelfLocationId
            : shelfLocationId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$ProductImpl implements _Product {
  const _$ProductImpl({
    required this.id,
    required this.name,
    required this.sku,
    this.description = '',
    this.category = 'General',
    this.baseUnit = 'pcs',
    this.costPrice = 0,
    required this.sellingPrice,
    this.stockInBaseUnit = 0,
    this.reorderPoint = 0,
    this.isActive = true,
    this.imageUrl,
    @JsonKey(includeFromJson: false, includeToJson: false) this.imageLocalPath,
    this.shelfLocation = 'Counter',
    this.expirationDate,
    this.categoryId,
    this.shelfLocationId,
    required this.sync,
  });

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String sku;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final String baseUnit;
  @override
  @JsonKey()
  final double costPrice;
  @override
  final double sellingPrice;
  @override
  @JsonKey()
  final double stockInBaseUnit;
  @override
  @JsonKey()
  final int reorderPoint;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? imageUrl;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? imageLocalPath;
  @override
  @JsonKey()
  final String? shelfLocation;
  @override
  final DateTime? expirationDate;
  @override
  final String? categoryId;
  @override
  final String? shelfLocationId;
  @override
  final SyncMetadata sync;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, sku: $sku, description: $description, category: $category, baseUnit: $baseUnit, costPrice: $costPrice, sellingPrice: $sellingPrice, stockInBaseUnit: $stockInBaseUnit, reorderPoint: $reorderPoint, isActive: $isActive, imageUrl: $imageUrl, imageLocalPath: $imageLocalPath, shelfLocation: $shelfLocation, expirationDate: $expirationDate, categoryId: $categoryId, shelfLocationId: $shelfLocationId, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.baseUnit, baseUnit) ||
                other.baseUnit == baseUnit) &&
            (identical(other.costPrice, costPrice) ||
                other.costPrice == costPrice) &&
            (identical(other.sellingPrice, sellingPrice) ||
                other.sellingPrice == sellingPrice) &&
            (identical(other.stockInBaseUnit, stockInBaseUnit) ||
                other.stockInBaseUnit == stockInBaseUnit) &&
            (identical(other.reorderPoint, reorderPoint) ||
                other.reorderPoint == reorderPoint) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.imageLocalPath, imageLocalPath) ||
                other.imageLocalPath == imageLocalPath) &&
            (identical(other.shelfLocation, shelfLocation) ||
                other.shelfLocation == shelfLocation) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.shelfLocationId, shelfLocationId) ||
                other.shelfLocationId == shelfLocationId) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
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
    expirationDate,
    categoryId,
    shelfLocationId,
    sync,
  );

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(this);
  }
}

abstract class _Product implements Product {
  const factory _Product({
    required final String id,
    required final String name,
    required final String sku,
    final String description,
    final String category,
    final String baseUnit,
    final double costPrice,
    required final double sellingPrice,
    final double stockInBaseUnit,
    final int reorderPoint,
    final bool isActive,
    final String? imageUrl,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final String? imageLocalPath,
    final String? shelfLocation,
    final DateTime? expirationDate,
    final String? categoryId,
    final String? shelfLocationId,
    required final SyncMetadata sync,
  }) = _$ProductImpl;

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get sku;
  @override
  String get description;
  @override
  String get category;
  @override
  String get baseUnit;
  @override
  double get costPrice;
  @override
  double get sellingPrice;
  @override
  double get stockInBaseUnit;
  @override
  int get reorderPoint;
  @override
  bool get isActive;
  @override
  String? get imageUrl;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get imageLocalPath;
  @override
  String? get shelfLocation;
  @override
  DateTime? get expirationDate;
  @override
  String? get categoryId;
  @override
  String? get shelfLocationId;
  @override
  SyncMetadata get sync;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
