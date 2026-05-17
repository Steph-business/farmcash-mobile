// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyse_plante.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnalysePlanteImpl _$$AnalysePlanteImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$AnalysePlanteImpl',
  json,
  ($checkedConvert) {
    final val = _$AnalysePlanteImpl(
      id: $checkedConvert('id', (v) => v as String),
      farmerId: $checkedConvert('farmer_id', (v) => v as String),
      imageUrl: $checkedConvert('image_url', (v) => v as String? ?? ''),
      parcelleId: $checkedConvert('parcelle_id', (v) => v as String?),
      diseaseDetected: $checkedConvert('disease_detected', (v) => v as String?),
      riskLevel: $checkedConvert('risk_level', (v) => v as String?),
      confidenceScore: $checkedConvert(
        'confidence_score',
        (v) => const FlexDoubleN().fromJson(v),
      ),
      recommendations: $checkedConvert('recommendations', (v) => v as String?),
      treatmentIds: $checkedConvert(
        'treatment_ids',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ??
            const <String>[],
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'farmerId': 'farmer_id',
    'imageUrl': 'image_url',
    'parcelleId': 'parcelle_id',
    'diseaseDetected': 'disease_detected',
    'riskLevel': 'risk_level',
    'confidenceScore': 'confidence_score',
    'treatmentIds': 'treatment_ids',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$AnalysePlanteImplToJson(
  _$AnalysePlanteImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'farmer_id': instance.farmerId,
  'image_url': instance.imageUrl,
  if (instance.parcelleId case final value?) 'parcelle_id': value,
  if (instance.diseaseDetected case final value?) 'disease_detected': value,
  if (instance.riskLevel case final value?) 'risk_level': value,
  if (const FlexDoubleN().toJson(instance.confidenceScore) case final value?)
    'confidence_score': value,
  if (instance.recommendations case final value?) 'recommendations': value,
  'treatment_ids': instance.treatmentIds,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};
