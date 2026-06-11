// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_extraction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IdentityCardExtractionImpl _$$IdentityCardExtractionImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$IdentityCardExtractionImpl',
  json,
  ($checkedConvert) {
    final val = _$IdentityCardExtractionImpl(
      fullName: $checkedConvert('full_name', (v) => v as String?),
      documentNumber: $checkedConvert('document_number', (v) => v as String?),
      birthDate: $checkedConvert('birth_date', (v) => v as String?),
      birthPlace: $checkedConvert('birth_place', (v) => v as String?),
      confidence: $checkedConvert(
        'confidence',
        (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
      ),
      rawText: $checkedConvert('raw_text', (v) => v as String? ?? ''),
      isMock: $checkedConvert('is_mock', (v) => v as bool? ?? false),
    );
    return val;
  },
  fieldKeyMap: const {
    'fullName': 'full_name',
    'documentNumber': 'document_number',
    'birthDate': 'birth_date',
    'birthPlace': 'birth_place',
    'rawText': 'raw_text',
    'isMock': 'is_mock',
  },
);

Map<String, dynamic> _$$IdentityCardExtractionImplToJson(
  _$IdentityCardExtractionImpl instance,
) => <String, dynamic>{
  if (instance.fullName case final value?) 'full_name': value,
  if (instance.documentNumber case final value?) 'document_number': value,
  if (instance.birthDate case final value?) 'birth_date': value,
  if (instance.birthPlace case final value?) 'birth_place': value,
  if (const FlexDouble().toJson(instance.confidence) case final value?)
    'confidence': value,
  'raw_text': instance.rawText,
  'is_mock': instance.isMock,
};

_$RccmExtractionImpl _$$RccmExtractionImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$RccmExtractionImpl',
      json,
      ($checkedConvert) {
        final val = _$RccmExtractionImpl(
          companyName: $checkedConvert('company_name', (v) => v as String?),
          rccmNumber: $checkedConvert('rccm_number', (v) => v as String?),
          address: $checkedConvert('address', (v) => v as String?),
          activity: $checkedConvert('activity', (v) => v as String?),
          confidence: $checkedConvert(
            'confidence',
            (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
          ),
          rawText: $checkedConvert('raw_text', (v) => v as String? ?? ''),
          isMock: $checkedConvert('is_mock', (v) => v as bool? ?? false),
        );
        return val;
      },
      fieldKeyMap: const {
        'companyName': 'company_name',
        'rccmNumber': 'rccm_number',
        'rawText': 'raw_text',
        'isMock': 'is_mock',
      },
    );

Map<String, dynamic> _$$RccmExtractionImplToJson(
  _$RccmExtractionImpl instance,
) => <String, dynamic>{
  if (instance.companyName case final value?) 'company_name': value,
  if (instance.rccmNumber case final value?) 'rccm_number': value,
  if (instance.address case final value?) 'address': value,
  if (instance.activity case final value?) 'activity': value,
  if (const FlexDouble().toJson(instance.confidence) case final value?)
    'confidence': value,
  'raw_text': instance.rawText,
  'is_mock': instance.isMock,
};
