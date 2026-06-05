import 'dart:convert';
import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/business_profile.dart';

extension BusinessProfileRowMapper on BusinessProfileRow {
  BusinessProfile toDomain() {
    Map<String, dynamic> prefs = {};
    try {
      prefs = json.decode(preferencesJson) as Map<String, dynamic>;
    } catch (_) {}
    return BusinessProfile(
      id: id,
      businessType: businessType,
      businessName: businessName,
      defaultCurrency: defaultCurrency,
      preferences: prefs,
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
}

extension BusinessProfileCompanionMapper on BusinessProfile {
  BusinessProfilesCompanion toCompanion() => BusinessProfilesCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    businessType: Value(businessType),
    businessName: Value(businessName),
    defaultCurrency: Value(defaultCurrency),
    preferencesJson: Value(json.encode(preferences)),
  );
}

BusinessProfilesCompanion businessProfileCompanionFromRemoteJson(
  Map<String, dynamic> jsonMap,
) {
  final prefs = jsonMap['preferences'];
  final prefsStr = prefs is Map ? json.encode(prefs) : (prefs as String? ?? '{}');
  return BusinessProfilesCompanion(
    id: Value(jsonMap['id'] as String),
    syncId: Value(jsonMap['syncId'] as String),
    deviceId: Value((jsonMap['deviceId'] as String?) ?? ''),
    isDeleted: Value((jsonMap['isDeleted'] as bool?) ?? false),
    isDirty: const Value(false),
    createdAtMs: Value(
      DateTime.parse(jsonMap['createdAt'] as String).millisecondsSinceEpoch,
    ),
    updatedAtMs: Value(
      DateTime.parse(jsonMap['updatedAt'] as String).millisecondsSinceEpoch,
    ),
    businessType: Value(jsonMap['businessType'] as String),
    businessName: Value(jsonMap['businessName'] as String),
    defaultCurrency: Value((jsonMap['defaultCurrency'] as String?) ?? 'PHP'),
    preferencesJson: Value(prefsStr),
  );
}

Map<String, dynamic> businessProfileToRemoteJson(BusinessProfile b) => {
  'id': b.id,
  'syncId': b.sync.syncId,
  'deviceId': b.sync.deviceId,
  'businessType': b.businessType,
  'businessName': b.businessName,
  'defaultCurrency': b.defaultCurrency,
  'preferences': b.preferences,
  'isDeleted': b.sync.isDeleted,
  'createdAt': b.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': b.sync.updatedAt.toUtc().toIso8601String(),
};
