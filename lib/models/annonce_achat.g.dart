// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annonce_achat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnnonceAchatImpl _$$AnnonceAchatImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$AnnonceAchatImpl',
      json,
      ($checkedConvert) {
        final val = _$AnnonceAchatImpl(
          id: $checkedConvert('id', (v) => v as String),
          buyerId: $checkedConvert('buyer_id', (v) => v as String),
          produitId: $checkedConvert('produit_id', (v) => v as String),
          quantiteKg: $checkedConvert(
            'quantite_kg',
            (v) => const FlexDouble().fromJson(v),
          ),
          prixMaxKg: $checkedConvert(
            'prix_max_kg',
            (v) => const FlexDouble().fromJson(v),
          ),
          regionId: $checkedConvert('region_id', (v) => v as String?),
          villeId: $checkedConvert('ville_id', (v) => v as String?),
          titre: $checkedConvert('titre', (v) => v as String?),
          description: $checkedConvert('description', (v) => v as String?),
          isActive: $checkedConvert('is_active', (v) => v as bool? ?? true),
          audience: $checkedConvert(
            'target_audience',
            (v) =>
                $enumDecodeNullable(
                  _$BuyOfferAudienceEnumMap,
                  v,
                  unknownValue: BuyOfferAudience.unknown,
                ) ??
                BuyOfferAudience.unknown,
          ),
          targetCooperativeId: $checkedConvert(
            'target_cooperative_id',
            (v) => v as String?,
          ),
          dateLimiteLivraison: $checkedConvert(
            'date_limite_livraison',
            (v) => v == null ? null : DateTime.parse(v as String),
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
        'buyerId': 'buyer_id',
        'produitId': 'produit_id',
        'quantiteKg': 'quantite_kg',
        'prixMaxKg': 'prix_max_kg',
        'regionId': 'region_id',
        'villeId': 'ville_id',
        'isActive': 'is_active',
        'audience': 'target_audience',
        'targetCooperativeId': 'target_cooperative_id',
        'dateLimiteLivraison': 'date_limite_livraison',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$$AnnonceAchatImplToJson(_$AnnonceAchatImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'buyer_id': instance.buyerId,
      'produit_id': instance.produitId,
      if (const FlexDouble().toJson(instance.quantiteKg) case final value?)
        'quantite_kg': value,
      if (const FlexDouble().toJson(instance.prixMaxKg) case final value?)
        'prix_max_kg': value,
      if (instance.regionId case final value?) 'region_id': value,
      if (instance.villeId case final value?) 'ville_id': value,
      if (instance.titre case final value?) 'titre': value,
      if (instance.description case final value?) 'description': value,
      'is_active': instance.isActive,
      'target_audience': _$BuyOfferAudienceEnumMap[instance.audience]!,
      if (instance.targetCooperativeId case final value?)
        'target_cooperative_id': value,
      if (instance.dateLimiteLivraison?.toIso8601String() case final value?)
        'date_limite_livraison': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updated_at': value,
    };

const _$BuyOfferAudienceEnumMap = {
  BuyOfferAudience.public: 'PUBLIC',
  BuyOfferAudience.allCooperatives: 'ALL_COOPERATIVES',
  BuyOfferAudience.specificCooperative: 'SPECIFIC_COOPERATIVE',
  BuyOfferAudience.unknown: 'UNKNOWN',
};
