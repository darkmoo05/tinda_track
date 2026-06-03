// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartyImpl _$$PartyImplFromJson(Map<String, dynamic> json) => _$PartyImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  accountNumber: json['accountNumber'] as String? ?? '',
  entityId: json['entityId'] as String? ?? '',
  description: json['description'] as String? ?? '',
  joinDate: json['joinDate'] as String,
  isVerified: json['isVerified'] as bool? ?? false,
  sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$PartyImplToJson(_$PartyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'accountNumber': instance.accountNumber,
      'entityId': instance.entityId,
      'description': instance.description,
      'joinDate': instance.joinDate,
      'isVerified': instance.isVerified,
      'sync': instance.sync,
    };
