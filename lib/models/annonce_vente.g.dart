// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annonce_vente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnnonceVenteImpl _$$AnnonceVenteImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$AnnonceVenteImpl',
  json,
  ($checkedConvert) {
    final val = _$AnnonceVenteImpl(
      id: $checkedConvert('id', (v) => v as String),
      farmerId: $checkedConvert('farmer_id', (v) => v as String),
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
      quantiteMinKg: $checkedConvert(
        'quantite_min_kg',
        (v) => const FlexDoubleN().fromJson(v),
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
      certifications: $checkedConvert(
        'certifications',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ??
            const <String>[],
      ),
      regionId: $checkedConvert('region_id', (v) => v as String?),
      villeId: $checkedConvert('ville_id', (v) => v as String?),
      adresseDetail: $checkedConvert('adresse_detail', (v) => v as String?),
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
      viewsCount: $checkedConvert(
        'views_count',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
      assignedToCooperativeId: $checkedConvert(
        'assigned_to_cooperative_id',
        (v) => v as String?,
      ),
      coopStatus: $checkedConvert(
        'coop_status',
        (v) => $enumDecodeNullable(
          _$CoopAnnonceStatusEnumMap,
          v,
          unknownValue: CoopAnnonceStatus.unknown,
        ),
      ),
      rejectedReason: $checkedConvert('rejected_reason', (v) => v as String?),
      photos: $checkedConvert(
        'medias',
        (v) => v == null ? const <String>[] : mediasToPhotos(v),
      ),
      disponibleJusqu: $checkedConvert(
        'disponible_jusqu',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      dateRecolte: $checkedConvert(
        'date_recolte',
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
      produitNom: $checkedConvert('produits_agricoles', (v) => _nomFromMap(v)),
      vendeur: $checkedConvert('users', (v) => _vendeurInfoFromJson(v)),
      regionNom: $checkedConvert('regions_ci', (v) => _nomFromMap(v)),
      villeNom: $checkedConvert('villes_ci', (v) => _nomFromMap(v)),
      traitements: $checkedConvert(
        'annonce_vente_traitements',
        (v) =>
            v == null ? const <AnnonceTraitement>[] : _traitementsFromJson(v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'farmerId': 'farmer_id',
    'produitId': 'produit_id',
    'quantiteKg': 'quantite_kg',
    'prixParKg': 'prix_par_kg',
    'quantiteMinKg': 'quantite_min_kg',
    'regionId': 'region_id',
    'villeId': 'ville_id',
    'adresseDetail': 'adresse_detail',
    'viewsCount': 'views_count',
    'assignedToCooperativeId': 'assigned_to_cooperative_id',
    'coopStatus': 'coop_status',
    'rejectedReason': 'rejected_reason',
    'photos': 'medias',
    'disponibleJusqu': 'disponible_jusqu',
    'dateRecolte': 'date_recolte',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'produitNom': 'produits_agricoles',
    'vendeur': 'users',
    'regionNom': 'regions_ci',
    'villeNom': 'villes_ci',
    'traitements': 'annonce_vente_traitements',
  },
);

Map<String, dynamic> _$$AnnonceVenteImplToJson(
  _$AnnonceVenteImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'farmer_id': instance.farmerId,
  'produit_id': instance.produitId,
  'titre': instance.titre,
  if (const FlexDouble().toJson(instance.quantiteKg) case final value?)
    'quantite_kg': value,
  if (const FlexDouble().toJson(instance.prixParKg) case final value?)
    'prix_par_kg': value,
  if (const FlexDoubleN().toJson(instance.quantiteMinKg) case final value?)
    'quantite_min_kg': value,
  'qualite': _$ProductQualityEnumMap[instance.qualite]!,
  if (instance.description case final value?) 'description': value,
  'certifications': instance.certifications,
  if (instance.regionId case final value?) 'region_id': value,
  if (instance.villeId case final value?) 'ville_id': value,
  if (instance.adresseDetail case final value?) 'adresse_detail': value,
  'status': _$ProductStatusEnumMap[instance.status]!,
  if (const FlexInt().toJson(instance.viewsCount) case final value?)
    'views_count': value,
  if (instance.assignedToCooperativeId case final value?)
    'assigned_to_cooperative_id': value,
  if (_$CoopAnnonceStatusEnumMap[instance.coopStatus] case final value?)
    'coop_status': value,
  if (instance.rejectedReason case final value?) 'rejected_reason': value,
  'medias': photosToMedias(instance.photos),
  if (instance.disponibleJusqu?.toIso8601String() case final value?)
    'disponible_jusqu': value,
  if (instance.dateRecolte?.toIso8601String() case final value?)
    'date_recolte': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
  if (instance.updatedAt?.toIso8601String() case final value?)
    'updated_at': value,
  if (_nomToMap(instance.produitNom) case final value?)
    'produits_agricoles': value,
  if (_vendeurInfoToJson(instance.vendeur) case final value?) 'users': value,
  if (_nomToMap(instance.regionNom) case final value?) 'regions_ci': value,
  if (_nomToMap(instance.villeNom) case final value?) 'villes_ci': value,
  'annonce_vente_traitements': _traitementsToJson(instance.traitements),
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

const _$CoopAnnonceStatusEnumMap = {
  CoopAnnonceStatus.pending: 'PENDING',
  CoopAnnonceStatus.validated: 'VALIDATED',
  CoopAnnonceStatus.included: 'INCLUDED',
  CoopAnnonceStatus.rejected: 'REJECTED',
  CoopAnnonceStatus.unknown: 'UNKNOWN',
};
