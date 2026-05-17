// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PanierImpl _$$PanierImplFromJson(Map<String, dynamic> json) => $checkedCreate(
  r'_$PanierImpl',
  json,
  ($checkedConvert) {
    final val = _$PanierImpl(
      id: $checkedConvert('id', (v) => v as String? ?? ''),
      userId: $checkedConvert('user_id', (v) => v as String? ?? ''),
      items: $checkedConvert(
        'items',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => PanierItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const <PanierItem>[],
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'userId': 'user_id', 'updatedAt': 'updated_at'},
);

Map<String, dynamic> _$$PanierImplToJson(_$PanierImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'items': instance.items,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updated_at': value,
    };

_$PanierItemImpl _$$PanierItemImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$PanierItemImpl',
      json,
      ($checkedConvert) {
        final val = _$PanierItemImpl(
          id: $checkedConvert('id', (v) => v as String),
          panierId: $checkedConvert('panier_id', (v) => v as String? ?? ''),
          annonceId: $checkedConvert('annonce_id', (v) => v as String),
          quantiteKg: $checkedConvert(
            'quantite_kg',
            (v) => const FlexDouble().fromJson(v),
          ),
          prixUnitaire: $checkedConvert(
            'prix_unitaire',
            (v) => const FlexDouble().fromJson(v),
          ),
          annonce: $checkedConvert(
            'annonce',
            (v) => v == null
                ? null
                : AnnonceVente.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'panierId': 'panier_id',
        'annonceId': 'annonce_id',
        'quantiteKg': 'quantite_kg',
        'prixUnitaire': 'prix_unitaire',
      },
    );

Map<String, dynamic> _$$PanierItemImplToJson(_$PanierItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'panier_id': instance.panierId,
      'annonce_id': instance.annonceId,
      if (const FlexDouble().toJson(instance.quantiteKg) case final value?)
        'quantite_kg': value,
      if (const FlexDouble().toJson(instance.prixUnitaire) case final value?)
        'prix_unitaire': value,
      if (instance.annonce case final value?) 'annonce': value,
    };
