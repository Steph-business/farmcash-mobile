// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traitement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TraitementImpl _$$TraitementImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$TraitementImpl',
      json,
      ($checkedConvert) {
        final val = _$TraitementImpl(
          id: $checkedConvert('id', (v) => v as String),
          nom: $checkedConvert('nom', (v) => v as String),
          description: $checkedConvert('description', (v) => v as String?),
          type: $checkedConvert('type', (v) => v as String?),
          mode: $checkedConvert('mode', (v) => v as String?),
          dosage: $checkedConvert('dosage', (v) => v as String?),
          maladies: $checkedConvert(
            'maladies',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const <String>[],
          ),
          produits: $checkedConvert(
            'produits',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const <String>[],
          ),
          isBio: $checkedConvert('is_bio', (v) => v as bool? ?? false),
          prixIndicatif: $checkedConvert(
            'prix_indicatif',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'isBio': 'is_bio',
        'prixIndicatif': 'prix_indicatif',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$$TraitementImplToJson(_$TraitementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      if (instance.description case final value?) 'description': value,
      if (instance.type case final value?) 'type': value,
      if (instance.mode case final value?) 'mode': value,
      if (instance.dosage case final value?) 'dosage': value,
      'maladies': instance.maladies,
      'produits': instance.produits,
      'is_bio': instance.isBio,
      if (const FlexDoubleN().toJson(instance.prixIndicatif) case final value?)
        'prix_indicatif': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };
