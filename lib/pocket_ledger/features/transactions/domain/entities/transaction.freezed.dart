// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TxRecord _$TxRecordFromJson(Map<String, dynamic> json) {
  return _TxRecord.fromJson(json);
}

/// @nodoc
mixin _$TxRecord {
  String get id => throw _privateConstructorUsedError;
  @_WalletProviderConverter()
  WalletProvider get walletProvider => throw _privateConstructorUsedError;
  @_TransactionDirectionConverter()
  TransactionDirection get direction => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get chargeAmount => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  double get balanceBefore => throw _privateConstructorUsedError;
  double get balanceAfter => throw _privateConstructorUsedError;
  double? get chargeLowerBound => throw _privateConstructorUsedError;
  double? get chargeUpperBound => throw _privateConstructorUsedError;
  String get chargeHandling => throw _privateConstructorUsedError;
  String? get receiptImagePath => throw _privateConstructorUsedError;
  String? get receiptOriginalName => throw _privateConstructorUsedError;
  String? get receiptMimeType => throw _privateConstructorUsedError;
  DateTime? get receiptUploadedAt => throw _privateConstructorUsedError;
  @_OcrStatusConverter()
  OcrStatus get ocrStatus => throw _privateConstructorUsedError;
  double? get ocrExtractedAmount => throw _privateConstructorUsedError;
  String? get ocrRawText => throw _privateConstructorUsedError;
  DateTime? get ocrProcessedAt => throw _privateConstructorUsedError;
  String? get externalProvider => throw _privateConstructorUsedError;
  String? get externalTransactionId => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  String get reference => throw _privateConstructorUsedError;
  String get entryDate => throw _privateConstructorUsedError;
  @_TransactionStatusConverter()
  TransactionStatus get status => throw _privateConstructorUsedError;
  SyncMetadata get sync => throw _privateConstructorUsedError;

  /// Serializes this TxRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TxRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TxRecordCopyWith<TxRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TxRecordCopyWith<$Res> {
  factory $TxRecordCopyWith(TxRecord value, $Res Function(TxRecord) then) =
      _$TxRecordCopyWithImpl<$Res, TxRecord>;
  @useResult
  $Res call({
    String id,
    @_WalletProviderConverter() WalletProvider walletProvider,
    @_TransactionDirectionConverter() TransactionDirection direction,
    double amount,
    double chargeAmount,
    double totalAmount,
    double balanceBefore,
    double balanceAfter,
    double? chargeLowerBound,
    double? chargeUpperBound,
    String chargeHandling,
    String? receiptImagePath,
    String? receiptOriginalName,
    String? receiptMimeType,
    DateTime? receiptUploadedAt,
    @_OcrStatusConverter() OcrStatus ocrStatus,
    double? ocrExtractedAmount,
    String? ocrRawText,
    DateTime? ocrProcessedAt,
    String? externalProvider,
    String? externalTransactionId,
    String note,
    String reference,
    String entryDate,
    @_TransactionStatusConverter() TransactionStatus status,
    SyncMetadata sync,
  });

  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class _$TxRecordCopyWithImpl<$Res, $Val extends TxRecord>
    implements $TxRecordCopyWith<$Res> {
  _$TxRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TxRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? walletProvider = null,
    Object? direction = null,
    Object? amount = null,
    Object? chargeAmount = null,
    Object? totalAmount = null,
    Object? balanceBefore = null,
    Object? balanceAfter = null,
    Object? chargeLowerBound = freezed,
    Object? chargeUpperBound = freezed,
    Object? chargeHandling = null,
    Object? receiptImagePath = freezed,
    Object? receiptOriginalName = freezed,
    Object? receiptMimeType = freezed,
    Object? receiptUploadedAt = freezed,
    Object? ocrStatus = null,
    Object? ocrExtractedAmount = freezed,
    Object? ocrRawText = freezed,
    Object? ocrProcessedAt = freezed,
    Object? externalProvider = freezed,
    Object? externalTransactionId = freezed,
    Object? note = null,
    Object? reference = null,
    Object? entryDate = null,
    Object? status = null,
    Object? sync = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            walletProvider: null == walletProvider
                ? _value.walletProvider
                : walletProvider // ignore: cast_nullable_to_non_nullable
                      as WalletProvider,
            direction: null == direction
                ? _value.direction
                : direction // ignore: cast_nullable_to_non_nullable
                      as TransactionDirection,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            chargeAmount: null == chargeAmount
                ? _value.chargeAmount
                : chargeAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            balanceBefore: null == balanceBefore
                ? _value.balanceBefore
                : balanceBefore // ignore: cast_nullable_to_non_nullable
                      as double,
            balanceAfter: null == balanceAfter
                ? _value.balanceAfter
                : balanceAfter // ignore: cast_nullable_to_non_nullable
                      as double,
            chargeLowerBound: freezed == chargeLowerBound
                ? _value.chargeLowerBound
                : chargeLowerBound // ignore: cast_nullable_to_non_nullable
                      as double?,
            chargeUpperBound: freezed == chargeUpperBound
                ? _value.chargeUpperBound
                : chargeUpperBound // ignore: cast_nullable_to_non_nullable
                      as double?,
            chargeHandling: null == chargeHandling
                ? _value.chargeHandling
                : chargeHandling // ignore: cast_nullable_to_non_nullable
                      as String,
            receiptImagePath: freezed == receiptImagePath
                ? _value.receiptImagePath
                : receiptImagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            receiptOriginalName: freezed == receiptOriginalName
                ? _value.receiptOriginalName
                : receiptOriginalName // ignore: cast_nullable_to_non_nullable
                      as String?,
            receiptMimeType: freezed == receiptMimeType
                ? _value.receiptMimeType
                : receiptMimeType // ignore: cast_nullable_to_non_nullable
                      as String?,
            receiptUploadedAt: freezed == receiptUploadedAt
                ? _value.receiptUploadedAt
                : receiptUploadedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            ocrStatus: null == ocrStatus
                ? _value.ocrStatus
                : ocrStatus // ignore: cast_nullable_to_non_nullable
                      as OcrStatus,
            ocrExtractedAmount: freezed == ocrExtractedAmount
                ? _value.ocrExtractedAmount
                : ocrExtractedAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            ocrRawText: freezed == ocrRawText
                ? _value.ocrRawText
                : ocrRawText // ignore: cast_nullable_to_non_nullable
                      as String?,
            ocrProcessedAt: freezed == ocrProcessedAt
                ? _value.ocrProcessedAt
                : ocrProcessedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            externalProvider: freezed == externalProvider
                ? _value.externalProvider
                : externalProvider // ignore: cast_nullable_to_non_nullable
                      as String?,
            externalTransactionId: freezed == externalTransactionId
                ? _value.externalTransactionId
                : externalTransactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
            reference: null == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as String,
            entryDate: null == entryDate
                ? _value.entryDate
                : entryDate // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TransactionStatus,
            sync: null == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as SyncMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of TxRecord
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
abstract class _$$TxRecordImplCopyWith<$Res>
    implements $TxRecordCopyWith<$Res> {
  factory _$$TxRecordImplCopyWith(
    _$TxRecordImpl value,
    $Res Function(_$TxRecordImpl) then,
  ) = __$$TxRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @_WalletProviderConverter() WalletProvider walletProvider,
    @_TransactionDirectionConverter() TransactionDirection direction,
    double amount,
    double chargeAmount,
    double totalAmount,
    double balanceBefore,
    double balanceAfter,
    double? chargeLowerBound,
    double? chargeUpperBound,
    String chargeHandling,
    String? receiptImagePath,
    String? receiptOriginalName,
    String? receiptMimeType,
    DateTime? receiptUploadedAt,
    @_OcrStatusConverter() OcrStatus ocrStatus,
    double? ocrExtractedAmount,
    String? ocrRawText,
    DateTime? ocrProcessedAt,
    String? externalProvider,
    String? externalTransactionId,
    String note,
    String reference,
    String entryDate,
    @_TransactionStatusConverter() TransactionStatus status,
    SyncMetadata sync,
  });

  @override
  $SyncMetadataCopyWith<$Res> get sync;
}

/// @nodoc
class __$$TxRecordImplCopyWithImpl<$Res>
    extends _$TxRecordCopyWithImpl<$Res, _$TxRecordImpl>
    implements _$$TxRecordImplCopyWith<$Res> {
  __$$TxRecordImplCopyWithImpl(
    _$TxRecordImpl _value,
    $Res Function(_$TxRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TxRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? walletProvider = null,
    Object? direction = null,
    Object? amount = null,
    Object? chargeAmount = null,
    Object? totalAmount = null,
    Object? balanceBefore = null,
    Object? balanceAfter = null,
    Object? chargeLowerBound = freezed,
    Object? chargeUpperBound = freezed,
    Object? chargeHandling = null,
    Object? receiptImagePath = freezed,
    Object? receiptOriginalName = freezed,
    Object? receiptMimeType = freezed,
    Object? receiptUploadedAt = freezed,
    Object? ocrStatus = null,
    Object? ocrExtractedAmount = freezed,
    Object? ocrRawText = freezed,
    Object? ocrProcessedAt = freezed,
    Object? externalProvider = freezed,
    Object? externalTransactionId = freezed,
    Object? note = null,
    Object? reference = null,
    Object? entryDate = null,
    Object? status = null,
    Object? sync = null,
  }) {
    return _then(
      _$TxRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        walletProvider: null == walletProvider
            ? _value.walletProvider
            : walletProvider // ignore: cast_nullable_to_non_nullable
                  as WalletProvider,
        direction: null == direction
            ? _value.direction
            : direction // ignore: cast_nullable_to_non_nullable
                  as TransactionDirection,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        chargeAmount: null == chargeAmount
            ? _value.chargeAmount
            : chargeAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        balanceBefore: null == balanceBefore
            ? _value.balanceBefore
            : balanceBefore // ignore: cast_nullable_to_non_nullable
                  as double,
        balanceAfter: null == balanceAfter
            ? _value.balanceAfter
            : balanceAfter // ignore: cast_nullable_to_non_nullable
                  as double,
        chargeLowerBound: freezed == chargeLowerBound
            ? _value.chargeLowerBound
            : chargeLowerBound // ignore: cast_nullable_to_non_nullable
                  as double?,
        chargeUpperBound: freezed == chargeUpperBound
            ? _value.chargeUpperBound
            : chargeUpperBound // ignore: cast_nullable_to_non_nullable
                  as double?,
        chargeHandling: null == chargeHandling
            ? _value.chargeHandling
            : chargeHandling // ignore: cast_nullable_to_non_nullable
                  as String,
        receiptImagePath: freezed == receiptImagePath
            ? _value.receiptImagePath
            : receiptImagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        receiptOriginalName: freezed == receiptOriginalName
            ? _value.receiptOriginalName
            : receiptOriginalName // ignore: cast_nullable_to_non_nullable
                  as String?,
        receiptMimeType: freezed == receiptMimeType
            ? _value.receiptMimeType
            : receiptMimeType // ignore: cast_nullable_to_non_nullable
                  as String?,
        receiptUploadedAt: freezed == receiptUploadedAt
            ? _value.receiptUploadedAt
            : receiptUploadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        ocrStatus: null == ocrStatus
            ? _value.ocrStatus
            : ocrStatus // ignore: cast_nullable_to_non_nullable
                  as OcrStatus,
        ocrExtractedAmount: freezed == ocrExtractedAmount
            ? _value.ocrExtractedAmount
            : ocrExtractedAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        ocrRawText: freezed == ocrRawText
            ? _value.ocrRawText
            : ocrRawText // ignore: cast_nullable_to_non_nullable
                  as String?,
        ocrProcessedAt: freezed == ocrProcessedAt
            ? _value.ocrProcessedAt
            : ocrProcessedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        externalProvider: freezed == externalProvider
            ? _value.externalProvider
            : externalProvider // ignore: cast_nullable_to_non_nullable
                  as String?,
        externalTransactionId: freezed == externalTransactionId
            ? _value.externalTransactionId
            : externalTransactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
        reference: null == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String,
        entryDate: null == entryDate
            ? _value.entryDate
            : entryDate // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TransactionStatus,
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
class _$TxRecordImpl implements _TxRecord {
  const _$TxRecordImpl({
    required this.id,
    @_WalletProviderConverter() required this.walletProvider,
    @_TransactionDirectionConverter() required this.direction,
    required this.amount,
    this.chargeAmount = 0,
    required this.totalAmount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.chargeLowerBound,
    this.chargeUpperBound,
    this.chargeHandling = 'addOnTop',
    this.receiptImagePath,
    this.receiptOriginalName,
    this.receiptMimeType,
    this.receiptUploadedAt,
    @_OcrStatusConverter() this.ocrStatus = OcrStatus.pending,
    this.ocrExtractedAmount,
    this.ocrRawText,
    this.ocrProcessedAt,
    this.externalProvider,
    this.externalTransactionId,
    this.note = '',
    this.reference = '',
    required this.entryDate,
    @_TransactionStatusConverter() this.status = TransactionStatus.completed,
    required this.sync,
  });

  factory _$TxRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$TxRecordImplFromJson(json);

  @override
  final String id;
  @override
  @_WalletProviderConverter()
  final WalletProvider walletProvider;
  @override
  @_TransactionDirectionConverter()
  final TransactionDirection direction;
  @override
  final double amount;
  @override
  @JsonKey()
  final double chargeAmount;
  @override
  final double totalAmount;
  @override
  final double balanceBefore;
  @override
  final double balanceAfter;
  @override
  final double? chargeLowerBound;
  @override
  final double? chargeUpperBound;
  @override
  @JsonKey()
  final String chargeHandling;
  @override
  final String? receiptImagePath;
  @override
  final String? receiptOriginalName;
  @override
  final String? receiptMimeType;
  @override
  final DateTime? receiptUploadedAt;
  @override
  @JsonKey()
  @_OcrStatusConverter()
  final OcrStatus ocrStatus;
  @override
  final double? ocrExtractedAmount;
  @override
  final String? ocrRawText;
  @override
  final DateTime? ocrProcessedAt;
  @override
  final String? externalProvider;
  @override
  final String? externalTransactionId;
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey()
  final String reference;
  @override
  final String entryDate;
  @override
  @JsonKey()
  @_TransactionStatusConverter()
  final TransactionStatus status;
  @override
  final SyncMetadata sync;

  @override
  String toString() {
    return 'TxRecord(id: $id, walletProvider: $walletProvider, direction: $direction, amount: $amount, chargeAmount: $chargeAmount, totalAmount: $totalAmount, balanceBefore: $balanceBefore, balanceAfter: $balanceAfter, chargeLowerBound: $chargeLowerBound, chargeUpperBound: $chargeUpperBound, chargeHandling: $chargeHandling, receiptImagePath: $receiptImagePath, receiptOriginalName: $receiptOriginalName, receiptMimeType: $receiptMimeType, receiptUploadedAt: $receiptUploadedAt, ocrStatus: $ocrStatus, ocrExtractedAmount: $ocrExtractedAmount, ocrRawText: $ocrRawText, ocrProcessedAt: $ocrProcessedAt, externalProvider: $externalProvider, externalTransactionId: $externalTransactionId, note: $note, reference: $reference, entryDate: $entryDate, status: $status, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TxRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.walletProvider, walletProvider) ||
                other.walletProvider == walletProvider) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.chargeAmount, chargeAmount) ||
                other.chargeAmount == chargeAmount) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.balanceBefore, balanceBefore) ||
                other.balanceBefore == balanceBefore) &&
            (identical(other.balanceAfter, balanceAfter) ||
                other.balanceAfter == balanceAfter) &&
            (identical(other.chargeLowerBound, chargeLowerBound) ||
                other.chargeLowerBound == chargeLowerBound) &&
            (identical(other.chargeUpperBound, chargeUpperBound) ||
                other.chargeUpperBound == chargeUpperBound) &&
            (identical(other.chargeHandling, chargeHandling) ||
                other.chargeHandling == chargeHandling) &&
            (identical(other.receiptImagePath, receiptImagePath) ||
                other.receiptImagePath == receiptImagePath) &&
            (identical(other.receiptOriginalName, receiptOriginalName) ||
                other.receiptOriginalName == receiptOriginalName) &&
            (identical(other.receiptMimeType, receiptMimeType) ||
                other.receiptMimeType == receiptMimeType) &&
            (identical(other.receiptUploadedAt, receiptUploadedAt) ||
                other.receiptUploadedAt == receiptUploadedAt) &&
            (identical(other.ocrStatus, ocrStatus) ||
                other.ocrStatus == ocrStatus) &&
            (identical(other.ocrExtractedAmount, ocrExtractedAmount) ||
                other.ocrExtractedAmount == ocrExtractedAmount) &&
            (identical(other.ocrRawText, ocrRawText) ||
                other.ocrRawText == ocrRawText) &&
            (identical(other.ocrProcessedAt, ocrProcessedAt) ||
                other.ocrProcessedAt == ocrProcessedAt) &&
            (identical(other.externalProvider, externalProvider) ||
                other.externalProvider == externalProvider) &&
            (identical(other.externalTransactionId, externalTransactionId) ||
                other.externalTransactionId == externalTransactionId) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.entryDate, entryDate) ||
                other.entryDate == entryDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    walletProvider,
    direction,
    amount,
    chargeAmount,
    totalAmount,
    balanceBefore,
    balanceAfter,
    chargeLowerBound,
    chargeUpperBound,
    chargeHandling,
    receiptImagePath,
    receiptOriginalName,
    receiptMimeType,
    receiptUploadedAt,
    ocrStatus,
    ocrExtractedAmount,
    ocrRawText,
    ocrProcessedAt,
    externalProvider,
    externalTransactionId,
    note,
    reference,
    entryDate,
    status,
    sync,
  ]);

  /// Create a copy of TxRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TxRecordImplCopyWith<_$TxRecordImpl> get copyWith =>
      __$$TxRecordImplCopyWithImpl<_$TxRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TxRecordImplToJson(this);
  }
}

abstract class _TxRecord implements TxRecord {
  const factory _TxRecord({
    required final String id,
    @_WalletProviderConverter() required final WalletProvider walletProvider,
    @_TransactionDirectionConverter()
    required final TransactionDirection direction,
    required final double amount,
    final double chargeAmount,
    required final double totalAmount,
    required final double balanceBefore,
    required final double balanceAfter,
    final double? chargeLowerBound,
    final double? chargeUpperBound,
    final String chargeHandling,
    final String? receiptImagePath,
    final String? receiptOriginalName,
    final String? receiptMimeType,
    final DateTime? receiptUploadedAt,
    @_OcrStatusConverter() final OcrStatus ocrStatus,
    final double? ocrExtractedAmount,
    final String? ocrRawText,
    final DateTime? ocrProcessedAt,
    final String? externalProvider,
    final String? externalTransactionId,
    final String note,
    final String reference,
    required final String entryDate,
    @_TransactionStatusConverter() final TransactionStatus status,
    required final SyncMetadata sync,
  }) = _$TxRecordImpl;

  factory _TxRecord.fromJson(Map<String, dynamic> json) =
      _$TxRecordImpl.fromJson;

  @override
  String get id;
  @override
  @_WalletProviderConverter()
  WalletProvider get walletProvider;
  @override
  @_TransactionDirectionConverter()
  TransactionDirection get direction;
  @override
  double get amount;
  @override
  double get chargeAmount;
  @override
  double get totalAmount;
  @override
  double get balanceBefore;
  @override
  double get balanceAfter;
  @override
  double? get chargeLowerBound;
  @override
  double? get chargeUpperBound;
  @override
  String get chargeHandling;
  @override
  String? get receiptImagePath;
  @override
  String? get receiptOriginalName;
  @override
  String? get receiptMimeType;
  @override
  DateTime? get receiptUploadedAt;
  @override
  @_OcrStatusConverter()
  OcrStatus get ocrStatus;
  @override
  double? get ocrExtractedAmount;
  @override
  String? get ocrRawText;
  @override
  DateTime? get ocrProcessedAt;
  @override
  String? get externalProvider;
  @override
  String? get externalTransactionId;
  @override
  String get note;
  @override
  String get reference;
  @override
  String get entryDate;
  @override
  @_TransactionStatusConverter()
  TransactionStatus get status;
  @override
  SyncMetadata get sync;

  /// Create a copy of TxRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TxRecordImplCopyWith<_$TxRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
