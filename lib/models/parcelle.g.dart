// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcelle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParcelleImpl _$$ParcelleImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$ParcelleImpl',
      json,
      ($checkedConvert) {
        final val = _$ParcelleImpl(
          id: $checkedConvert('id', (v) => v as String),
          userId: $checkedConvert('user_id', (v) => v as String),
          nom: $checkedConvert('nom', (v) => v as String),
          superficieHa: $checkedConvert(
            'superficie_ha',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          produitId: $checkedConvert('produit_id', (v) => v as String?),
          contour: $checkedConvert(
            'contour',
            (v) =>
                (v as List<dynamic>?)
                    ?.map((e) => GeoPoint.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                const <GeoPoint>[],
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'userId': 'user_id',
        'superficieHa': 'superficie_ha',
        'produitId': 'produit_id',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$$ParcelleImplToJson(_$ParcelleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'nom': instance.nom,
      if (const FlexDoubleN().toJson(instance.superficieHa) case final value?)
        'superficie_ha': value,
      if (instance.produitId case final value?) 'produit_id': value,
      'contour': instance.contour,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };

_$GeoPointImpl _$$GeoPointImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$GeoPointImpl', json, ($checkedConvert) {
      final val = _$GeoPointImpl(
        lat: $checkedConvert('lat', (v) => const FlexDouble().fromJson(v)),
        lng: $checkedConvert('lng', (v) => const FlexDouble().fromJson(v)),
      );
      return val;
    });

Map<String, dynamic> _$$GeoPointImplToJson(
  _$GeoPointImpl instance,
) => <String, dynamic>{
  if (const FlexDouble().toJson(instance.lat) case final value?) 'lat': value,
  if (const FlexDouble().toJson(instance.lng) case final value?) 'lng': value,
};

_$CultureImpl _$$CultureImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$CultureImpl',
      json,
      ($checkedConvert) {
        final val = _$CultureImpl(
          id: $checkedConvert('id', (v) => v as String),
          parcelleId: $checkedConvert('parcelle_id', (v) => v as String?),
          produitId: $checkedConvert('produit_id', (v) => v as String),
          superficieHa: $checkedConvert(
            'superficie_ha',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          dateSemis: $checkedConvert(
            'date_semis',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          dateRecoltePrevue: $checkedConvert(
            'date_recolte_prevue',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          quantiteEstimeeKg: $checkedConvert(
            'quantite_estimee_kg',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          statut: $checkedConvert('statut', (v) => v as String?),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          produitNom: $checkedConvert(
            'produits_agricoles',
            (v) => _produitNomFromMap(v),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'parcelleId': 'parcelle_id',
        'produitId': 'produit_id',
        'superficieHa': 'superficie_ha',
        'dateSemis': 'date_semis',
        'dateRecoltePrevue': 'date_recolte_prevue',
        'quantiteEstimeeKg': 'quantite_estimee_kg',
        'createdAt': 'created_at',
        'produitNom': 'produits_agricoles',
      },
    );

Map<String, dynamic> _$$CultureImplToJson(
  _$CultureImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  if (instance.parcelleId case final value?) 'parcelle_id': value,
  'produit_id': instance.produitId,
  if (const FlexDoubleN().toJson(instance.superficieHa) case final value?)
    'superficie_ha': value,
  if (instance.dateSemis?.toIso8601String() case final value?)
    'date_semis': value,
  if (instance.dateRecoltePrevue?.toIso8601String() case final value?)
    'date_recolte_prevue': value,
  if (const FlexDoubleN().toJson(instance.quantiteEstimeeKg) case final value?)
    'quantite_estimee_kg': value,
  if (instance.statut case final value?) 'statut': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
  if (instance.produitNom case final value?) 'produits_agricoles': value,
};
