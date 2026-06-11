// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matching.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchingOpportunityImpl _$$MatchingOpportunityImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$MatchingOpportunityImpl',
  json,
  ($checkedConvert) {
    final val = _$MatchingOpportunityImpl(
      annonceId: $checkedConvert('annonce_id', (v) => v as String),
      buyerName: $checkedConvert('buyer_name', (v) => v as String),
      produitNom: $checkedConvert('produit_nom', (v) => v as String),
      quantiteKg: $checkedConvert(
        'quantite_kg',
        (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
      ),
      prixMaxKg: $checkedConvert(
        'prix_max_kg',
        (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
      ),
      regionName: $checkedConvert('region_name', (v) => v as String?),
      matchScore: $checkedConvert(
        'match_score',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'annonceId': 'annonce_id',
    'buyerName': 'buyer_name',
    'produitNom': 'produit_nom',
    'quantiteKg': 'quantite_kg',
    'prixMaxKg': 'prix_max_kg',
    'regionName': 'region_name',
    'matchScore': 'match_score',
  },
);

Map<String, dynamic> _$$MatchingOpportunityImplToJson(
  _$MatchingOpportunityImpl instance,
) => <String, dynamic>{
  'annonce_id': instance.annonceId,
  'buyer_name': instance.buyerName,
  'produit_nom': instance.produitNom,
  if (const FlexDouble().toJson(instance.quantiteKg) case final value?)
    'quantite_kg': value,
  if (const FlexDouble().toJson(instance.prixMaxKg) case final value?)
    'prix_max_kg': value,
  if (instance.regionName case final value?) 'region_name': value,
  if (const FlexInt().toJson(instance.matchScore) case final value?)
    'match_score': value,
};

_$MatchedSupplierImpl _$$MatchedSupplierImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$MatchedSupplierImpl',
  json,
  ($checkedConvert) {
    final val = _$MatchedSupplierImpl(
      userId: $checkedConvert('user_id', (v) => v as String),
      fullName: $checkedConvert('full_name', (v) => v as String),
      regionId: $checkedConvert('region_id', (v) => v as String?),
      regionName: $checkedConvert('region_name', (v) => v as String?),
      distanceKm: $checkedConvert(
        'distance_km',
        (v) => const FlexDoubleN().fromJson(v),
      ),
      hasActiveAnnonce: $checkedConvert(
        'has_active_annonce',
        (v) => v as bool? ?? false,
      ),
      declaredInCultures: $checkedConvert(
        'declared_in_cultures',
        (v) => v as bool? ?? false,
      ),
      matchScore: $checkedConvert(
        'match_score',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'userId': 'user_id',
    'fullName': 'full_name',
    'regionId': 'region_id',
    'regionName': 'region_name',
    'distanceKm': 'distance_km',
    'hasActiveAnnonce': 'has_active_annonce',
    'declaredInCultures': 'declared_in_cultures',
    'matchScore': 'match_score',
  },
);

Map<String, dynamic> _$$MatchedSupplierImplToJson(
  _$MatchedSupplierImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'full_name': instance.fullName,
  if (instance.regionId case final value?) 'region_id': value,
  if (instance.regionName case final value?) 'region_name': value,
  if (const FlexDoubleN().toJson(instance.distanceKm) case final value?)
    'distance_km': value,
  'has_active_annonce': instance.hasActiveAnnonce,
  'declared_in_cultures': instance.declaredInCultures,
  if (const FlexInt().toJson(instance.matchScore) case final value?)
    'match_score': value,
};
