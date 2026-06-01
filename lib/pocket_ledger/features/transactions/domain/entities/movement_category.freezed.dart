// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movement_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MovementCategory _$MovementCategoryFromJson(Map<String, dynamic> json) {
  return _MovementCategory.fromJson(json);
}

/// @nodoc
mixin _$MovementCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  SyncMetadata get sync => throw _privateConstructorUsedError;

  /// Serializes this MovementCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MovementCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MovementCategoryCopyWith<MovementCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovementCategoryCopyWith<$Res> {
  factory $MovementCategoryCopyWith(
    MovementCategory value,
    $Res Function(MovementCategory) then,
  ) = _$MovementCategoryCopyWithImpl<$Res, MovementCategory>;
  @useResult
  $Res call({String id, String name, SyncMetadata sync});

  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class _$MovementCategoryCopyWithImpl<$Res, $Val extends MovementCategory>
    implements $MovementCategoryCopyWith<$Res> {
  _$MovementCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MovementCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? sync = null}) {
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
            sync: null == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as SyncMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of MovementCategory
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
abstract class _$$MovementCategoryImplCopyWith<$Res>
    implements $MovementCategoryCopyWith<$Res> {
  factory _$$MovementCategoryImplCopyWith(
    _$MovementCategoryImpl value,
    $Res Function(_$MovementCategoryImpl) then,
  ) = __$$MovementCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, SyncMetadata sync});

  @override
  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class __$$MovementCategoryImplCopyWithImpl<$Res>
    extends _$MovementCategoryCopyWithImpl<$Res, _$MovementCategoryImpl>
    implements _$$MovementCategoryImplCopyWith<$Res> {
  __$$MovementCategoryImplCopyWithImpl(
    _$MovementCategoryImpl _value,
    $Res Function(_$MovementCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MovementCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? sync = null}) {
    return _then(
      _$MovementCategoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
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
class _$MovementCategoryImpl implements _MovementCategory {
  const _$MovementCategoryImpl({
    required this.id,
    required this.name,
    required this.sync,
  });

  factory _$MovementCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MovementCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final SyncMetadata sync;

  @override
  String toString() {
    return 'MovementCategory(id: $id, name: $name, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MovementCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, sync);

  /// Create a copy of MovementCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MovementCategoryImplCopyWith<_$MovementCategoryImpl> get copyWith =>
      __$$MovementCategoryImplCopyWithImpl<_$MovementCategoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MovementCategoryImplToJson(this);
  }
}

abstract class _MovementCategory implements MovementCategory {
  const factory _MovementCategory({
    required final String id,
    required final String name,
    required final SyncMetadata sync,
  }) = _$MovementCategoryImpl;

  factory _MovementCategory.fromJson(Map<String, dynamic> json) =
      _$MovementCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  SyncMetadata get sync;

  /// Create a copy of MovementCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MovementCategoryImplCopyWith<_$MovementCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
