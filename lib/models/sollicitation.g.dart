// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sollicitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SollicitationImpl _$$SollicitationImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$SollicitationImpl',
      json,
      ($checkedConvert) {
        final val = _$SollicitationImpl(
          id: $checkedConvert('id', (v) => v as String),
          cooperativeId: $checkedConvert('cooperative_id', (v) => v as String),
          annonceAchatId: $checkedConvert(
            'annonce_achat_id',
            (v) => v as String,
          ),
          initiatedBy: $checkedConvert('initiated_by', (v) => v as String?),
          message: $checkedConvert('message', (v) => v as String?),
          audiences: $checkedConvert(
            'audiences',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const <String>[],
          ),
          rayonKm: $checkedConvert(
            'rayon_km',
            (v) => v == null ? 50 : const FlexInt().fromJson(v),
          ),
          quantiteCibleKg: $checkedConvert(
            'quantite_cible_kg',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          expiresAt: $checkedConvert(
            'expires_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          status: $checkedConvert('status', (v) => v as String? ?? 'OPEN'),
          totalRecipients: $checkedConvert(
            'total_recipients',
            (v) => v == null ? 0 : const FlexInt().fromJson(v),
          ),
          totalResponses: $checkedConvert(
            'total_responses',
            (v) => v == null ? 0 : const FlexInt().fromJson(v),
          ),
          totalQuantiteOfferte: $checkedConvert(
            'total_quantite_offerte',
            (v) => v == null ? 0 : const FlexDouble().fromJson(v),
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'cooperativeId': 'cooperative_id',
        'annonceAchatId': 'annonce_achat_id',
        'initiatedBy': 'initiated_by',
        'rayonKm': 'rayon_km',
        'quantiteCibleKg': 'quantite_cible_kg',
        'expiresAt': 'expires_at',
        'totalRecipients': 'total_recipients',
        'totalResponses': 'total_responses',
        'totalQuantiteOfferte': 'total_quantite_offerte',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$$SollicitationImplToJson(
  _$SollicitationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'cooperative_id': instance.cooperativeId,
  'annonce_achat_id': instance.annonceAchatId,
  if (instance.initiatedBy case final value?) 'initiated_by': value,
  if (instance.message case final value?) 'message': value,
  'audiences': instance.audiences,
  if (const FlexInt().toJson(instance.rayonKm) case final value?)
    'rayon_km': value,
  if (const FlexDoubleN().toJson(instance.quantiteCibleKg) case final value?)
    'quantite_cible_kg': value,
  if (instance.expiresAt?.toIso8601String() case final value?)
    'expires_at': value,
  'status': instance.status,
  if (const FlexInt().toJson(instance.totalRecipients) case final value?)
    'total_recipients': value,
  if (const FlexInt().toJson(instance.totalResponses) case final value?)
    'total_responses': value,
  if (const FlexDouble().toJson(instance.totalQuantiteOfferte)
      case final value?)
    'total_quantite_offerte': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
  if (instance.updatedAt?.toIso8601String() case final value?)
    'updated_at': value,
};

_$SollicitationRecipientImpl _$$SollicitationRecipientImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$SollicitationRecipientImpl',
  json,
  ($checkedConvert) {
    final val = _$SollicitationRecipientImpl(
      id: $checkedConvert('id', (v) => v as String),
      sollicitationId: $checkedConvert('sollicitation_id', (v) => v as String),
      userId: $checkedConvert('user_id', (v) => v as String),
      audienceSegment: $checkedConvert('audience_segment', (v) => v as String),
      cooperativeId: $checkedConvert('cooperative_id', (v) => v as String?),
      notificationId: $checkedConvert('notification_id', (v) => v as String?),
      smsSentAt: $checkedConvert(
        'sms_sent_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      openedAt: $checkedConvert(
        'opened_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      respondedAt: $checkedConvert(
        'responded_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      responseAction: $checkedConvert('response_action', (v) => v as String?),
      responseQuantiteKg: $checkedConvert(
        'response_quantite_kg',
        (v) => const FlexDoubleN().fromJson(v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'sollicitationId': 'sollicitation_id',
    'userId': 'user_id',
    'audienceSegment': 'audience_segment',
    'cooperativeId': 'cooperative_id',
    'notificationId': 'notification_id',
    'smsSentAt': 'sms_sent_at',
    'openedAt': 'opened_at',
    'respondedAt': 'responded_at',
    'responseAction': 'response_action',
    'responseQuantiteKg': 'response_quantite_kg',
  },
);

Map<String, dynamic> _$$SollicitationRecipientImplToJson(
  _$SollicitationRecipientImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sollicitation_id': instance.sollicitationId,
  'user_id': instance.userId,
  'audience_segment': instance.audienceSegment,
  if (instance.cooperativeId case final value?) 'cooperative_id': value,
  if (instance.notificationId case final value?) 'notification_id': value,
  if (instance.smsSentAt?.toIso8601String() case final value?)
    'sms_sent_at': value,
  if (instance.openedAt?.toIso8601String() case final value?)
    'opened_at': value,
  if (instance.respondedAt?.toIso8601String() case final value?)
    'responded_at': value,
  if (instance.responseAction case final value?) 'response_action': value,
  if (const FlexDoubleN().toJson(instance.responseQuantiteKg) case final value?)
    'response_quantite_kg': value,
};
