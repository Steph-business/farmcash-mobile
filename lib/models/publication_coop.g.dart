// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publication_coop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PublicationCoopImpl _$$PublicationCoopImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$PublicationCoopImpl',
  json,
  ($checkedConvert) {
    final val = _$PublicationCoopImpl(
      id: $checkedConvert('id', (v) => v as String),
      cooperativeId: $checkedConvert('cooperative_id', (v) => v as String),
      produitId: $checkedConvert('produit_id', (v) => v as String),
      titre: $checkedConvert('titre', (v) => v as String),
      quantiteKg: $checkedConvert(
        'quantite_kg',
        (v) => const FlexDouble().fromJson(v),
      ),
      prixParKg: $checkedConvert(
        'prix_par_kg',
        (v) => const FlexDouble().fromJson(v),
      ),
      qualite: $checkedConvert(
        'qualite',
        (v) =>
            $enumDecodeNullable(
              _$ProductQualityEnumMap,
              v,
              unknownValue: ProductQuality.unknown,
            ) ??
            ProductQuality.unknown,
      ),
      description: $checkedConvert('description', (v) => v as String?),
      photos: $checkedConvert(
        'medias',
        (v) => v == null ? const <String>[] : mediasToPhotos(v),
      ),
      status: $checkedConvert(
        'status',
        (v) =>
            $enumDecodeNullable(
              _$ProductStatusEnumMap,
              v,
              unknownValue: ProductStatus.unknown,
            ) ??
            ProductStatus.unknown,
      ),
      nbContributeurs: $checkedConvert(
        'nb_contributeurs',
        (v) => (v as num?)?.toInt() ?? 0,
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      datesRecolteAnnonces: $checkedConvert(
        'publication_contributions',
        (v) => v == null ? const <DateTime>[] : _datesRecolteFromContribs(v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'cooperativeId': 'cooperative_id',
    'produitId': 'produit_id',
    'quantiteKg': 'quantite_kg',
    'prixParKg': 'prix_par_kg',
    'photos': 'medias',
    'nbContributeurs': 'nb_contributeurs',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'datesRecolteAnnonces': 'publication_contributions',
  },
);

Map<String, dynamic> _$$PublicationCoopImplToJson(
  _$PublicationCoopImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'cooperative_id': instance.cooperativeId,
  'produit_id': instance.produitId,
  'titre': instance.titre,
  if (const FlexDouble().toJson(instance.quantiteKg) case final value?)
    'quantite_kg': value,
  if (const FlexDouble().toJson(instance.prixParKg) case final value?)
    'prix_par_kg': value,
  'qualite': _$ProductQualityEnumMap[instance.qualite]!,
  if (instance.description case final value?) 'description': value,
  'medias': photosToMedias(instance.photos),
  'status': _$ProductStatusEnumMap[instance.status]!,
  'nb_contributeurs': instance.nbContributeurs,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
  if (instance.updatedAt?.toIso8601String() case final value?)
    'updated_at': value,
  'publication_contributions': _datesRecolteToJson(
    instance.datesRecolteAnnonces,
  ),
};

const _$ProductQualityEnumMap = {
  ProductQuality.standard: 'STANDARD',
  ProductQuality.premium: 'PREMIUM',
  ProductQuality.bio: 'BIO',
  ProductQuality.equitable: 'EQUITABLE',
  ProductQuality.unknown: 'UNKNOWN',
};

const _$ProductStatusEnumMap = {
  ProductStatus.draft: 'DRAFT',
  ProductStatus.active: 'ACTIVE',
  ProductStatus.paused: 'PAUSED',
  ProductStatus.sold: 'SOLD',
  ProductStatus.expired: 'EXPIRED',
  ProductStatus.unknown: 'UNKNOWN',
};
