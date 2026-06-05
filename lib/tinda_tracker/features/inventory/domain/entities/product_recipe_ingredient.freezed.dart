// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_recipe_ingredient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductRecipeIngredient _$ProductRecipeIngredientFromJson(
  Map<String, dynamic> json,
) {
  return _ProductRecipeIngredient.fromJson(json);
}

/// @nodoc
mixin _$ProductRecipeIngredient {
  String get id => throw _privateConstructorUsedError;
  String get recipeProductId => throw _privateConstructorUsedError;
  String get ingredientProductId => throw _privateConstructorUsedError;
  double get quantityNeeded => throw _privateConstructorUsedError;
  SyncMetadata get sync => throw _privateConstructorUsedError;

  /// Serializes this ProductRecipeIngredient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductRecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductRecipeIngredientCopyWith<ProductRecipeIngredient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductRecipeIngredientCopyWith<$Res> {
  factory $ProductRecipeIngredientCopyWith(
    ProductRecipeIngredient value,
    $Res Function(ProductRecipeIngredient) then,
  ) = _$ProductRecipeIngredientCopyWithImpl<$Res, ProductRecipeIngredient>;
  @useResult
  $Res call({
    String id,
    String recipeProductId,
    String ingredientProductId,
    double quantityNeeded,
    SyncMetadata sync,
  });

  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class _$ProductRecipeIngredientCopyWithImpl<
  $Res,
  $Val extends ProductRecipeIngredient
>
    implements $ProductRecipeIngredientCopyWith<$Res> {
  _$ProductRecipeIngredientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductRecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipeProductId = null,
    Object? ingredientProductId = null,
    Object? quantityNeeded = null,
    Object? sync = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            recipeProductId: null == recipeProductId
                ? _value.recipeProductId
                : recipeProductId // ignore: cast_nullable_to_non_nullable
                      as String,
            ingredientProductId: null == ingredientProductId
                ? _value.ingredientProductId
                : ingredientProductId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantityNeeded: null == quantityNeeded
                ? _value.quantityNeeded
                : quantityNeeded // ignore: cast_nullable_to_non_nullable
                      as double,
            sync: null == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as SyncMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of ProductRecipeIngredient
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
abstract class _$$ProductRecipeIngredientImplCopyWith<$Res>
    implements $ProductRecipeIngredientCopyWith<$Res> {
  factory _$$ProductRecipeIngredientImplCopyWith(
    _$ProductRecipeIngredientImpl value,
    $Res Function(_$ProductRecipeIngredientImpl) then,
  ) = __$$ProductRecipeIngredientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String recipeProductId,
    String ingredientProductId,
    double quantityNeeded,
    SyncMetadata sync,
  });

  @override
  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class __$$ProductRecipeIngredientImplCopyWithImpl<$Res>
    extends
        _$ProductRecipeIngredientCopyWithImpl<
          $Res,
          _$ProductRecipeIngredientImpl
        >
    implements _$$ProductRecipeIngredientImplCopyWith<$Res> {
  __$$ProductRecipeIngredientImplCopyWithImpl(
    _$ProductRecipeIngredientImpl _value,
    $Res Function(_$ProductRecipeIngredientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductRecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipeProductId = null,
    Object? ingredientProductId = null,
    Object? quantityNeeded = null,
    Object? sync = null,
  }) {
    return _then(
      _$ProductRecipeIngredientImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        recipeProductId: null == recipeProductId
            ? _value.recipeProductId
            : recipeProductId // ignore: cast_nullable_to_non_nullable
                  as String,
        ingredientProductId: null == ingredientProductId
            ? _value.ingredientProductId
            : ingredientProductId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantityNeeded: null == quantityNeeded
            ? _value.quantityNeeded
            : quantityNeeded // ignore: cast_nullable_to_non_nullable
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
class _$ProductRecipeIngredientImpl implements _ProductRecipeIngredient {
  const _$ProductRecipeIngredientImpl({
    required this.id,
    required this.recipeProductId,
    required this.ingredientProductId,
    required this.quantityNeeded,
    required this.sync,
  });

  factory _$ProductRecipeIngredientImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductRecipeIngredientImplFromJson(json);

  @override
  final String id;
  @override
  final String recipeProductId;
  @override
  final String ingredientProductId;
  @override
  final double quantityNeeded;
  @override
  final SyncMetadata sync;

  @override
  String toString() {
    return 'ProductRecipeIngredient(id: $id, recipeProductId: $recipeProductId, ingredientProductId: $ingredientProductId, quantityNeeded: $quantityNeeded, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductRecipeIngredientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.recipeProductId, recipeProductId) ||
                other.recipeProductId == recipeProductId) &&
            (identical(other.ingredientProductId, ingredientProductId) ||
                other.ingredientProductId == ingredientProductId) &&
            (identical(other.quantityNeeded, quantityNeeded) ||
                other.quantityNeeded == quantityNeeded) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    recipeProductId,
    ingredientProductId,
    quantityNeeded,
    sync,
  );

  /// Create a copy of ProductRecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductRecipeIngredientImplCopyWith<_$ProductRecipeIngredientImpl>
  get copyWith =>
      __$$ProductRecipeIngredientImplCopyWithImpl<
        _$ProductRecipeIngredientImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductRecipeIngredientImplToJson(this);
  }
}

abstract class _ProductRecipeIngredient implements ProductRecipeIngredient {
  const factory _ProductRecipeIngredient({
    required final String id,
    required final String recipeProductId,
    required final String ingredientProductId,
    required final double quantityNeeded,
    required final SyncMetadata sync,
  }) = _$ProductRecipeIngredientImpl;

  factory _ProductRecipeIngredient.fromJson(Map<String, dynamic> json) =
      _$ProductRecipeIngredientImpl.fromJson;

  @override
  String get id;
  @override
  String get recipeProductId;
  @override
  String get ingredientProductId;
  @override
  double get quantityNeeded;
  @override
  SyncMetadata get sync;

  /// Create a copy of ProductRecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductRecipeIngredientImplCopyWith<_$ProductRecipeIngredientImpl>
  get copyWith => throw _privateConstructorUsedError;
}
