import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../../../../core/sync/remote/json_coercion.dart';

extension LedgerEntryRowMapper on LedgerEntryRow {
  LedgerEntry toDomain() => LedgerEntry(
    id: id,
    transactionId: transactionId,
    entryType: entryType,
    title: title,
    note: note,
    reference: reference,
    amount: amount,
    walletDelta: walletDelta,
    mayaWalletDelta: mayaWalletDelta,
    onHandDelta: onHandDelta,
    recordedFlow: recordedFlow,
    tag: tag,
    iconKey: iconKey,
    walletAccount: walletAccount,
    ownerScope: ownerScope,
    ownerMovementType: ownerMovementType,
    ownerCategory: ownerCategory,
    ownerPartyName: ownerPartyName,
    ownerPartyAccount: ownerPartyAccount,
    entryDate: entryDate,
    sync: SyncMetadata(
      syncId: syncId,
      deviceId: deviceId,
      isDeleted: isDeleted,
      isDirty: isDirty,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    ),
  );
}

extension LedgerEntryCompanionMapper on LedgerEntry {
  LedgerEntriesCompanion toCompanion() => LedgerEntriesCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    transactionId: Value(transactionId),
    entryType: Value(entryType),
    title: Value(title),
    note: Value(note),
    reference: Value(reference),
    amount: Value(amount),
    walletDelta: Value(walletDelta),
    mayaWalletDelta: Value(mayaWalletDelta),
    onHandDelta: Value(onHandDelta),
    recordedFlow: Value(recordedFlow),
    tag: Value(tag),
    iconKey: Value(iconKey),
    walletAccount: Value(walletAccount),
    ownerScope: Value(ownerScope),
    ownerMovementType: Value(ownerMovementType),
    ownerCategory: Value(ownerCategory),
    ownerPartyName: Value(ownerPartyName),
    ownerPartyAccount: Value(ownerPartyAccount),
    entryDate: Value(entryDate),
  );
}

LedgerEntriesCompanion ledgerEntryCompanionFromRemoteJson(
  Map<String, dynamic> json,
) {
  return LedgerEntriesCompanion(
    id: Value(json['id'] as String),
    syncId: Value(json['syncId'] as String),
    deviceId: Value((json['deviceId'] as String?) ?? ''),
    isDeleted: Value((json['isDeleted'] as bool?) ?? false),
    isDirty: const Value(false),
    createdAtMs: Value(
      DateTime.parse(json['createdAt'] as String).millisecondsSinceEpoch,
    ),
    updatedAtMs: Value(
      DateTime.parse(json['updatedAt'] as String).millisecondsSinceEpoch,
    ),
    transactionId: Value(json['transactionId'] as String?),
    entryType: Value(json['entryType'] as String),
    title: Value((json['title'] as String?) ?? ''),
    note: Value((json['note'] as String?) ?? ''),
    reference: Value((json['reference'] as String?) ?? ''),
    amount: Value(asDouble(json['amount'])),
    walletDelta: Value(asDouble(json['walletDelta'])),
    mayaWalletDelta: Value(asDouble(json['mayaWalletDelta'])),
    onHandDelta: Value(asDouble(json['onHandDelta'])),
    recordedFlow: Value(asDouble(json['recordedFlow'])),
    tag: Value((json['tag'] as String?) ?? ''),
    iconKey: Value((json['iconKey'] as String?) ?? ''),
    walletAccount: Value((json['walletAccount'] as String?) ?? ''),
    ownerScope: Value((json['ownerScope'] as String?) ?? 'Business'),
    ownerMovementType: Value(json['ownerMovementType'] as String?),
    ownerCategory: Value(json['ownerCategory'] as String?),
    ownerPartyName: Value(json['ownerPartyName'] as String?),
    ownerPartyAccount: Value(json['ownerPartyAccount'] as String?),
    entryDate: Value(json['entryDate'] as String),
  );
}

Map<String, dynamic> ledgerEntryToRemoteJson(LedgerEntry e) => {
  'id': e.id,
  'syncId': e.sync.syncId,
  'deviceId': e.sync.deviceId,
  'transactionId': e.transactionId,
  'entryType': e.entryType,
  'title': e.title,
  'note': e.note,
  'reference': e.reference,
  'amount': e.amount,
  'walletDelta': e.walletDelta,
  'mayaWalletDelta': e.mayaWalletDelta,
  'onHandDelta': e.onHandDelta,
  'recordedFlow': e.recordedFlow,
  'tag': e.tag,
  'iconKey': e.iconKey,
  'walletAccount': e.walletAccount,
  'ownerScope': e.ownerScope,
  'ownerMovementType': e.ownerMovementType,
  'ownerCategory': e.ownerCategory,
  'ownerPartyName': e.ownerPartyName,
  'ownerPartyAccount': e.ownerPartyAccount,
  'entryDate': e.entryDate,
  'isDeleted': e.sync.isDeleted,
  'createdAt': e.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': e.sync.updatedAt.toUtc().toIso8601String(),
};
