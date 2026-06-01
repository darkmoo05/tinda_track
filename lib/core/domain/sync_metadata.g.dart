// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SyncMetadataImpl _$$SyncMetadataImplFromJson(Map<String, dynamic> json) =>
    _$SyncMetadataImpl(
      syncId: json['syncId'] as String,
      deviceId: json['deviceId'] as String? ?? '',
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SyncMetadataImplToJson(_$SyncMetadataImpl instance) =>
    <String, dynamic>{
      'syncId': instance.syncId,
      'deviceId': instance.deviceId,
      'isDeleted': instance.isDeleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
