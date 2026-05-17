// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interactions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AvisImpl _$$AvisImplFromJson(Map<String, dynamic> json) => $checkedCreate(
  r'_$AvisImpl',
  json,
  ($checkedConvert) {
    final val = _$AvisImpl(
      id: $checkedConvert('id', (v) => v as String),
      reviewerId: $checkedConvert('reviewer_id', (v) => v as String),
      reviewedUserId: $checkedConvert('reviewed_user_id', (v) => v as String),
      contextType: $checkedConvert('context_type', (v) => v as String? ?? ''),
      contextId: $checkedConvert('context_id', (v) => v as String?),
      note: $checkedConvert('note', (v) => (v as num?)?.toInt() ?? 0),
      commentaire: $checkedConvert('commentaire', (v) => v as String?),
      reviewer: $checkedConvert(
        'reviewer',
        (v) =>
            v == null ? null : Utilisateur.fromJson(v as Map<String, dynamic>),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'reviewerId': 'reviewer_id',
    'reviewedUserId': 'reviewed_user_id',
    'contextType': 'context_type',
    'contextId': 'context_id',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$AvisImplToJson(_$AvisImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reviewer_id': instance.reviewerId,
      'reviewed_user_id': instance.reviewedUserId,
      'context_type': instance.contextType,
      if (instance.contextId case final value?) 'context_id': value,
      'note': instance.note,
      if (instance.commentaire case final value?) 'commentaire': value,
      if (instance.reviewer case final value?) 'reviewer': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };

_$FavoriImpl _$$FavoriImplFromJson(Map<String, dynamic> json) => $checkedCreate(
  r'_$FavoriImpl',
  json,
  ($checkedConvert) {
    final val = _$FavoriImpl(
      id: $checkedConvert('id', (v) => v as String),
      userId: $checkedConvert('user_id', (v) => v as String),
      annonceId: $checkedConvert('annonce_id', (v) => v as String),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'userId': 'user_id',
    'annonceId': 'annonce_id',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$FavoriImplToJson(_$FavoriImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'annonce_id': instance.annonceId,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };

_$MediaImpl _$$MediaImplFromJson(Map<String, dynamic> json) => $checkedCreate(
  r'_$MediaImpl',
  json,
  ($checkedConvert) {
    final val = _$MediaImpl(
      id: $checkedConvert('id', (v) => v as String),
      ownerId: $checkedConvert('owner_id', (v) => v as String),
      url: $checkedConvert('url', (v) => v as String? ?? ''),
      annonceId: $checkedConvert('annonce_id', (v) => v as String?),
      type: $checkedConvert('type', (v) => v as String?),
      position: $checkedConvert('position', (v) => (v as num?)?.toInt() ?? 0),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'ownerId': 'owner_id',
    'annonceId': 'annonce_id',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$MediaImplToJson(_$MediaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'url': instance.url,
      if (instance.annonceId case final value?) 'annonce_id': value,
      if (instance.type case final value?) 'type': value,
      'position': instance.position,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };
