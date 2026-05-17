// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membre_coop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MembreCoopImpl _$$MembreCoopImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$MembreCoopImpl',
      json,
      ($checkedConvert) {
        final val = _$MembreCoopImpl(
          id: $checkedConvert('id', (v) => v as String),
          cooperativeId: $checkedConvert('cooperative_id', (v) => v as String),
          userId: $checkedConvert('user_id', (v) => v as String),
          user: $checkedConvert(
            'user',
            (v) => v == null
                ? null
                : Utilisateur.fromJson(v as Map<String, dynamic>),
          ),
          role: $checkedConvert(
            'role',
            (v) =>
                $enumDecodeNullable(
                  _$CoopMemberRoleEnumMap,
                  v,
                  unknownValue: CoopMemberRole.unknown,
                ) ??
                CoopMemberRole.membre,
          ),
          joinedAt: $checkedConvert(
            'joined_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'cooperativeId': 'cooperative_id',
        'userId': 'user_id',
        'joinedAt': 'joined_at',
      },
    );

Map<String, dynamic> _$$MembreCoopImplToJson(_$MembreCoopImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cooperative_id': instance.cooperativeId,
      'user_id': instance.userId,
      if (instance.user case final value?) 'user': value,
      'role': _$CoopMemberRoleEnumMap[instance.role]!,
      if (instance.joinedAt?.toIso8601String() case final value?)
        'joined_at': value,
    };

const _$CoopMemberRoleEnumMap = {
  CoopMemberRole.membre: 'MEMBRE',
  CoopMemberRole.gerant: 'GERANT',
  CoopMemberRole.tresorier: 'TRESORIER',
  CoopMemberRole.president: 'PRESIDENT',
  CoopMemberRole.unknown: 'UNKNOWN',
};

_$CoopJoinRequestImpl _$$CoopJoinRequestImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$CoopJoinRequestImpl',
  json,
  ($checkedConvert) {
    final val = _$CoopJoinRequestImpl(
      id: $checkedConvert('id', (v) => v as String),
      cooperativeId: $checkedConvert('cooperative_id', (v) => v as String),
      farmerId: $checkedConvert('farmer_id', (v) => v as String),
      status: $checkedConvert('status', (v) => v as String? ?? 'PENDING'),
      message: $checkedConvert('message', (v) => v as String?),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'cooperativeId': 'cooperative_id',
    'farmerId': 'farmer_id',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$CoopJoinRequestImplToJson(
  _$CoopJoinRequestImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'cooperative_id': instance.cooperativeId,
  'farmer_id': instance.farmerId,
  'status': instance.status,
  if (instance.message case final value?) 'message': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};

_$CoopInvitationImpl _$$CoopInvitationImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$CoopInvitationImpl',
      json,
      ($checkedConvert) {
        final val = _$CoopInvitationImpl(
          id: $checkedConvert('id', (v) => v as String),
          cooperativeId: $checkedConvert('cooperative_id', (v) => v as String),
          phone: $checkedConvert('phone', (v) => v as String? ?? ''),
          status: $checkedConvert('status', (v) => v as String? ?? 'PENDING'),
          message: $checkedConvert('message', (v) => v as String?),
          expiresAt: $checkedConvert(
            'expires_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'cooperativeId': 'cooperative_id',
        'expiresAt': 'expires_at',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$$CoopInvitationImplToJson(
  _$CoopInvitationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'cooperative_id': instance.cooperativeId,
  'phone': instance.phone,
  'status': instance.status,
  if (instance.message case final value?) 'message': value,
  if (instance.expiresAt?.toIso8601String() case final value?)
    'expires_at': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};
