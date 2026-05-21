// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment_evaluation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShipmentEvaluationImpl _$$ShipmentEvaluationImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$ShipmentEvaluationImpl',
  json,
  ($checkedConvert) {
    final val = _$ShipmentEvaluationImpl(
      id: $checkedConvert('id', (v) => v as String),
      reviewerId: $checkedConvert('reviewer_id', (v) => v as String),
      reviewedUserId: $checkedConvert('reviewed_user_id', (v) => v as String),
      note: $checkedConvert('note', (v) => (v as num?)?.toInt() ?? 0),
      commentaire: $checkedConvert('commentaire', (v) => v as String?),
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
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$ShipmentEvaluationImplToJson(
  _$ShipmentEvaluationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'reviewer_id': instance.reviewerId,
  'reviewed_user_id': instance.reviewedUserId,
  'note': instance.note,
  if (instance.commentaire case final value?) 'commentaire': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};
