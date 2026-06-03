// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShelfLocation _$ShelfLocationFromJson(Map<String, dynamic> json) {
  return _ShelfLocation.fromJson(json);
}

/// @nodoc
mixin _$ShelfLocation {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get examples => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get imageLocalPath => throw _privateConstructorUsedError;
  SyncMetadata get sync => throw _privateConstructorUsedError;

  /// Serializes this ShelfLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShelfLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShelfLocationCopyWith<ShelfLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShelfLocationCopyWith<$Res> {
  factory $ShelfLocationCopyWith(
    ShelfLocation value,
    $Res Function(ShelfLocation) then,
  ) = _$ShelfLocationCopyWithImpl<$Res, ShelfLocation>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String examples,
    String? imageUrl,
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? imageLocalPath,
    SyncMetadata sync,
  });

  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class _$ShelfLocationCopyWithImpl<$Res, $Val extends ShelfLocation>
    implements $ShelfLocationCopyWith<$Res> {
  _$ShelfLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShelfLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? examples = null,
    Object? imageUrl = freezed,
    Object? imageLocalPath = freezed,
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
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            examples: null == examples
                ? _value.examples
                : examples // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageLocalPath: freezed == imageLocalPath
                ? _value.imageLocalPath
                : imageLocalPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            sync: null == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as SyncMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of ShelfLocation
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
abstract class _$$ShelfLocationImplCopyWith<$Res>
    implements $ShelfLocationCopyWith<$Res> {
  factory _$$ShelfLocationImplCopyWith(
    _$ShelfLocationImpl value,
    $Res Function(_$ShelfLocationImpl) then,
  ) = __$$ShelfLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String examples,
    String? imageUrl,
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? imageLocalPath,
    SyncMetadata sync,
  });

  @override
  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class __$$ShelfLocationImplCopyWithImpl<$Res>
    extends _$ShelfLocationCopyWithImpl<$Res, _$ShelfLocationImpl>
    implements _$$ShelfLocationImplCopyWith<$Res> {
  __$$ShelfLocationImplCopyWithImpl(
    _$ShelfLocationImpl _value,
    $Res Function(_$ShelfLocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShelfLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? examples = null,
    Object? imageUrl = freezed,
    Object? imageLocalPath = freezed,
    Object? sync = null,
  }) {
    return _then(
      _$ShelfLocationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        examples: null == examples
            ? _value.examples
            : examples // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageLocalPath: freezed == imageLocalPath
            ? _value.imageLocalPath
            : imageLocalPath // ignore: cast_nullable_to_non_nullable
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
class _$ShelfLocationImpl implements _ShelfLocation {
  const _$ShelfLocationImpl({
    required this.id,
    required this.name,
    this.description = '',
    this.examples = '',
    this.imageUrl,
    @JsonKey(includeFromJson: false, includeToJson: false) this.imageLocalPath,
    required this.sync,
  });

  factory _$ShelfLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShelfLocationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String examples;
  @override
  final String? imageUrl;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? imageLocalPath;
  @override
  final SyncMetadata sync;

  @override
  String toString() {
    return 'ShelfLocation(id: $id, name: $name, description: $description, examples: $examples, imageUrl: $imageUrl, imageLocalPath: $imageLocalPath, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShelfLocationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.examples, examples) ||
                other.examples == examples) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.imageLocalPath, imageLocalPath) ||
                other.imageLocalPath == imageLocalPath) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    examples,
    imageUrl,
    imageLocalPath,
    sync,
  );

  /// Create a copy of ShelfLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShelfLocationImplCopyWith<_$ShelfLocationImpl> get copyWith =>
      __$$ShelfLocationImplCopyWithImpl<_$ShelfLocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShelfLocationImplToJson(this);
  }
}

abstract class _ShelfLocation implements ShelfLocation {
  const factory _ShelfLocation({
    required final String id,
    required final String name,
    final String description,
    final String examples,
    final String? imageUrl,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final String? imageLocalPath,
    required final SyncMetadata sync,
  }) = _$ShelfLocationImpl;

  factory _ShelfLocation.fromJson(Map<String, dynamic> json) =
      _$ShelfLocationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get examples;
  @override
  String? get imageUrl;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get imageLocalPath;
  @override
  SyncMetadata get sync;

  /// Create a copy of ShelfLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShelfLocationImplCopyWith<_$ShelfLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
