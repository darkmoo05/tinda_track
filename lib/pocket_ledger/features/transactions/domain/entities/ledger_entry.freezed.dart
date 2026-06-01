// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ledger_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LedgerEntry _$LedgerEntryFromJson(Map<String, dynamic> json) {
  return _LedgerEntry.fromJson(json);
}

/// @nodoc
mixin _$LedgerEntry {
  String get id => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  String get entryType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  String get reference => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get walletDelta => throw _privateConstructorUsedError;
  double get mayaWalletDelta => throw _privateConstructorUsedError;
  double get onHandDelta => throw _privateConstructorUsedError;
  double get recordedFlow => throw _privateConstructorUsedError;
  String get tag => throw _privateConstructorUsedError;
  String get iconKey => throw _privateConstructorUsedError;
  String get walletAccount => throw _privateConstructorUsedError;
  String get ownerScope => throw _privateConstructorUsedError;
  String? get ownerMovementType => throw _privateConstructorUsedError;
  String? get ownerCategory => throw _privateConstructorUsedError;
  String? get ownerPartyName => throw _privateConstructorUsedError;
  String? get ownerPartyAccount => throw _privateConstructorUsedError;
  String get entryDate => throw _privateConstructorUsedError;
  SyncMetadata get sync => throw _privateConstructorUsedError;

  /// Serializes this LedgerEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LedgerEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LedgerEntryCopyWith<LedgerEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LedgerEntryCopyWith<$Res> {
  factory $LedgerEntryCopyWith(
    LedgerEntry value,
    $Res Function(LedgerEntry) then,
  ) = _$LedgerEntryCopyWithImpl<$Res, LedgerEntry>;
  @useResult
  $Res call({
    String id,
    String? transactionId,
    String entryType,
    String title,
    String note,
    String reference,
    double amount,
    double walletDelta,
    double mayaWalletDelta,
    double onHandDelta,
    double recordedFlow,
    String tag,
    String iconKey,
    String walletAccount,
    String ownerScope,
    String? ownerMovementType,
    String? ownerCategory,
    String? ownerPartyName,
    String? ownerPartyAccount,
    String entryDate,
    SyncMetadata sync,
  });

  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class _$LedgerEntryCopyWithImpl<$Res, $Val extends LedgerEntry>
    implements $LedgerEntryCopyWith<$Res> {
  _$LedgerEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LedgerEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionId = freezed,
    Object? entryType = null,
    Object? title = null,
    Object? note = null,
    Object? reference = null,
    Object? amount = null,
    Object? walletDelta = null,
    Object? mayaWalletDelta = null,
    Object? onHandDelta = null,
    Object? recordedFlow = null,
    Object? tag = null,
    Object? iconKey = null,
    Object? walletAccount = null,
    Object? ownerScope = null,
    Object? ownerMovementType = freezed,
    Object? ownerCategory = freezed,
    Object? ownerPartyName = freezed,
    Object? ownerPartyAccount = freezed,
    Object? entryDate = null,
    Object? sync = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            transactionId: freezed == transactionId
                ? _value.transactionId
                : transactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            entryType: null == entryType
                ? _value.entryType
                : entryType // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
            reference: null == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            walletDelta: null == walletDelta
                ? _value.walletDelta
                : walletDelta // ignore: cast_nullable_to_non_nullable
                      as double,
            mayaWalletDelta: null == mayaWalletDelta
                ? _value.mayaWalletDelta
                : mayaWalletDelta // ignore: cast_nullable_to_non_nullable
                      as double,
            onHandDelta: null == onHandDelta
                ? _value.onHandDelta
                : onHandDelta // ignore: cast_nullable_to_non_nullable
                      as double,
            recordedFlow: null == recordedFlow
                ? _value.recordedFlow
                : recordedFlow // ignore: cast_nullable_to_non_nullable
                      as double,
            tag: null == tag
                ? _value.tag
                : tag // ignore: cast_nullable_to_non_nullable
                      as String,
            iconKey: null == iconKey
                ? _value.iconKey
                : iconKey // ignore: cast_nullable_to_non_nullable
                      as String,
            walletAccount: null == walletAccount
                ? _value.walletAccount
                : walletAccount // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerScope: null == ownerScope
                ? _value.ownerScope
                : ownerScope // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerMovementType: freezed == ownerMovementType
                ? _value.ownerMovementType
                : ownerMovementType // ignore: cast_nullable_to_non_nullable
                      as String?,
            ownerCategory: freezed == ownerCategory
                ? _value.ownerCategory
                : ownerCategory // ignore: cast_nullable_to_non_nullable
                      as String?,
            ownerPartyName: freezed == ownerPartyName
                ? _value.ownerPartyName
                : ownerPartyName // ignore: cast_nullable_to_non_nullable
                      as String?,
            ownerPartyAccount: freezed == ownerPartyAccount
                ? _value.ownerPartyAccount
                : ownerPartyAccount // ignore: cast_nullable_to_non_nullable
                      as String?,
            entryDate: null == entryDate
                ? _value.entryDate
                : entryDate // ignore: cast_nullable_to_non_nullable
                      as String,
            sync: null == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as SyncMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of LedgerEntry
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
abstract class _$$LedgerEntryImplCopyWith<$Res>
    implements $LedgerEntryCopyWith<$Res> {
  factory _$$LedgerEntryImplCopyWith(
    _$LedgerEntryImpl value,
    $Res Function(_$LedgerEntryImpl) then,
  ) = __$$LedgerEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? transactionId,
    String entryType,
    String title,
    String note,
    String reference,
    double amount,
    double walletDelta,
    double mayaWalletDelta,
    double onHandDelta,
    double recordedFlow,
    String tag,
    String iconKey,
    String walletAccount,
    String ownerScope,
    String? ownerMovementType,
    String? ownerCategory,
    String? ownerPartyName,
    String? ownerPartyAccount,
    String entryDate,
    SyncMetadata sync,
  });

  @override
  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class __$$LedgerEntryImplCopyWithImpl<$Res>
    extends _$LedgerEntryCopyWithImpl<$Res, _$LedgerEntryImpl>
    implements _$$LedgerEntryImplCopyWith<$Res> {
  __$$LedgerEntryImplCopyWithImpl(
    _$LedgerEntryImpl _value,
    $Res Function(_$LedgerEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LedgerEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionId = freezed,
    Object? entryType = null,
    Object? title = null,
    Object? note = null,
    Object? reference = null,
    Object? amount = null,
    Object? walletDelta = null,
    Object? mayaWalletDelta = null,
    Object? onHandDelta = null,
    Object? recordedFlow = null,
    Object? tag = null,
    Object? iconKey = null,
    Object? walletAccount = null,
    Object? ownerScope = null,
    Object? ownerMovementType = freezed,
    Object? ownerCategory = freezed,
    Object? ownerPartyName = freezed,
    Object? ownerPartyAccount = freezed,
    Object? entryDate = null,
    Object? sync = null,
  }) {
    return _then(
      _$LedgerEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        transactionId: freezed == transactionId
            ? _value.transactionId
            : transactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        entryType: null == entryType
            ? _value.entryType
            : entryType // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
        reference: null == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        walletDelta: null == walletDelta
            ? _value.walletDelta
            : walletDelta // ignore: cast_nullable_to_non_nullable
                  as double,
        mayaWalletDelta: null == mayaWalletDelta
            ? _value.mayaWalletDelta
            : mayaWalletDelta // ignore: cast_nullable_to_non_nullable
                  as double,
        onHandDelta: null == onHandDelta
            ? _value.onHandDelta
            : onHandDelta // ignore: cast_nullable_to_non_nullable
                  as double,
        recordedFlow: null == recordedFlow
            ? _value.recordedFlow
            : recordedFlow // ignore: cast_nullable_to_non_nullable
                  as double,
        tag: null == tag
            ? _value.tag
            : tag // ignore: cast_nullable_to_non_nullable
                  as String,
        iconKey: null == iconKey
            ? _value.iconKey
            : iconKey // ignore: cast_nullable_to_non_nullable
                  as String,
        walletAccount: null == walletAccount
            ? _value.walletAccount
            : walletAccount // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerScope: null == ownerScope
            ? _value.ownerScope
            : ownerScope // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerMovementType: freezed == ownerMovementType
            ? _value.ownerMovementType
            : ownerMovementType // ignore: cast_nullable_to_non_nullable
                  as String?,
        ownerCategory: freezed == ownerCategory
            ? _value.ownerCategory
            : ownerCategory // ignore: cast_nullable_to_non_nullable
                  as String?,
        ownerPartyName: freezed == ownerPartyName
            ? _value.ownerPartyName
            : ownerPartyName // ignore: cast_nullable_to_non_nullable
                  as String?,
        ownerPartyAccount: freezed == ownerPartyAccount
            ? _value.ownerPartyAccount
            : ownerPartyAccount // ignore: cast_nullable_to_non_nullable
                  as String?,
        entryDate: null == entryDate
            ? _value.entryDate
            : entryDate // ignore: cast_nullable_to_non_nullable
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
class _$LedgerEntryImpl implements _LedgerEntry {
  const _$LedgerEntryImpl({
    required this.id,
    this.transactionId,
    required this.entryType,
    this.title = '',
    this.note = '',
    this.reference = '',
    required this.amount,
    this.walletDelta = 0,
    this.mayaWalletDelta = 0,
    this.onHandDelta = 0,
    this.recordedFlow = 0,
    this.tag = '',
    this.iconKey = '',
    this.walletAccount = '',
    this.ownerScope = 'Business',
    this.ownerMovementType,
    this.ownerCategory,
    this.ownerPartyName,
    this.ownerPartyAccount,
    required this.entryDate,
    required this.sync,
  });

  factory _$LedgerEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LedgerEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String? transactionId;
  @override
  final String entryType;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey()
  final String reference;
  @override
  final double amount;
  @override
  @JsonKey()
  final double walletDelta;
  @override
  @JsonKey()
  final double mayaWalletDelta;
  @override
  @JsonKey()
  final double onHandDelta;
  @override
  @JsonKey()
  final double recordedFlow;
  @override
  @JsonKey()
  final String tag;
  @override
  @JsonKey()
  final String iconKey;
  @override
  @JsonKey()
  final String walletAccount;
  @override
  @JsonKey()
  final String ownerScope;
  @override
  final String? ownerMovementType;
  @override
  final String? ownerCategory;
  @override
  final String? ownerPartyName;
  @override
  final String? ownerPartyAccount;
  @override
  final String entryDate;
  @override
  final SyncMetadata sync;

  @override
  String toString() {
    return 'LedgerEntry(id: $id, transactionId: $transactionId, entryType: $entryType, title: $title, note: $note, reference: $reference, amount: $amount, walletDelta: $walletDelta, mayaWalletDelta: $mayaWalletDelta, onHandDelta: $onHandDelta, recordedFlow: $recordedFlow, tag: $tag, iconKey: $iconKey, walletAccount: $walletAccount, ownerScope: $ownerScope, ownerMovementType: $ownerMovementType, ownerCategory: $ownerCategory, ownerPartyName: $ownerPartyName, ownerPartyAccount: $ownerPartyAccount, entryDate: $entryDate, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LedgerEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.entryType, entryType) ||
                other.entryType == entryType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.walletDelta, walletDelta) ||
                other.walletDelta == walletDelta) &&
            (identical(other.mayaWalletDelta, mayaWalletDelta) ||
                other.mayaWalletDelta == mayaWalletDelta) &&
            (identical(other.onHandDelta, onHandDelta) ||
                other.onHandDelta == onHandDelta) &&
            (identical(other.recordedFlow, recordedFlow) ||
                other.recordedFlow == recordedFlow) &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey) &&
            (identical(other.walletAccount, walletAccount) ||
                other.walletAccount == walletAccount) &&
            (identical(other.ownerScope, ownerScope) ||
                other.ownerScope == ownerScope) &&
            (identical(other.ownerMovementType, ownerMovementType) ||
                other.ownerMovementType == ownerMovementType) &&
            (identical(other.ownerCategory, ownerCategory) ||
                other.ownerCategory == ownerCategory) &&
            (identical(other.ownerPartyName, ownerPartyName) ||
                other.ownerPartyName == ownerPartyName) &&
            (identical(other.ownerPartyAccount, ownerPartyAccount) ||
                other.ownerPartyAccount == ownerPartyAccount) &&
            (identical(other.entryDate, entryDate) ||
                other.entryDate == entryDate) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    transactionId,
    entryType,
    title,
    note,
    reference,
    amount,
    walletDelta,
    mayaWalletDelta,
    onHandDelta,
    recordedFlow,
    tag,
    iconKey,
    walletAccount,
    ownerScope,
    ownerMovementType,
    ownerCategory,
    ownerPartyName,
    ownerPartyAccount,
    entryDate,
    sync,
  ]);

  /// Create a copy of LedgerEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LedgerEntryImplCopyWith<_$LedgerEntryImpl> get copyWith =>
      __$$LedgerEntryImplCopyWithImpl<_$LedgerEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LedgerEntryImplToJson(this);
  }
}

abstract class _LedgerEntry implements LedgerEntry {
  const factory _LedgerEntry({
    required final String id,
    final String? transactionId,
    required final String entryType,
    final String title,
    final String note,
    final String reference,
    required final double amount,
    final double walletDelta,
    final double mayaWalletDelta,
    final double onHandDelta,
    final double recordedFlow,
    final String tag,
    final String iconKey,
    final String walletAccount,
    final String ownerScope,
    final String? ownerMovementType,
    final String? ownerCategory,
    final String? ownerPartyName,
    final String? ownerPartyAccount,
    required final String entryDate,
    required final SyncMetadata sync,
  }) = _$LedgerEntryImpl;

  factory _LedgerEntry.fromJson(Map<String, dynamic> json) =
      _$LedgerEntryImpl.fromJson;

  @override
  String get id;
  @override
  String? get transactionId;
  @override
  String get entryType;
  @override
  String get title;
  @override
  String get note;
  @override
  String get reference;
  @override
  double get amount;
  @override
  double get walletDelta;
  @override
  double get mayaWalletDelta;
  @override
  double get onHandDelta;
  @override
  double get recordedFlow;
  @override
  String get tag;
  @override
  String get iconKey;
  @override
  String get walletAccount;
  @override
  String get ownerScope;
  @override
  String? get ownerMovementType;
  @override
  String? get ownerCategory;
  @override
  String? get ownerPartyName;
  @override
  String? get ownerPartyAccount;
  @override
  String get entryDate;
  @override
  SyncMetadata get sync;

  /// Create a copy of LedgerEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LedgerEntryImplCopyWith<_$LedgerEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
