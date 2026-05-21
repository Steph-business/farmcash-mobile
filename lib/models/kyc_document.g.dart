// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KycDocumentImpl _$$KycDocumentImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$KycDocumentImpl',
      json,
      ($checkedConvert) {
        final val = _$KycDocumentImpl(
          id: $checkedConvert('id', (v) => v as String),
          userId: $checkedConvert('user_id', (v) => v as String),
          docType: $checkedConvert('doc_type', (v) => v as String? ?? ''),
          url: $checkedConvert('url', (v) => v as String? ?? ''),
          status: $checkedConvert('status', (v) => v as String? ?? 'PENDING'),
          rejectionReason: $checkedConvert(
            'rejection_reason',
            (v) => v as String?,
          ),
          uploadedAt: $checkedConvert(
            'uploaded_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          validatedAt: $checkedConvert(
            'validated_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          validatedBy: $checkedConvert('validated_by', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'userId': 'user_id',
        'docType': 'doc_type',
        'rejectionReason': 'rejection_reason',
        'uploadedAt': 'uploaded_at',
        'validatedAt': 'validated_at',
        'validatedBy': 'validated_by',
      },
    );

Map<String, dynamic> _$$KycDocumentImplToJson(_$KycDocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'doc_type': instance.docType,
      'url': instance.url,
      'status': instance.status,
      if (instance.rejectionReason case final value?) 'rejection_reason': value,
      if (instance.uploadedAt?.toIso8601String() case final value?)
        'uploaded_at': value,
      if (instance.validatedAt?.toIso8601String() case final value?)
        'validated_at': value,
      if (instance.validatedBy case final value?) 'validated_by': value,
    };
