// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooperative.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CooperativeImpl _$$CooperativeImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$CooperativeImpl',
  json,
  ($checkedConvert) {
    final val = _$CooperativeImpl(
      id: $checkedConvert('id', (v) => v as String),
      userId: $checkedConvert('user_id', (v) => v as String),
      nom: $checkedConvert('nom', (v) => v as String),
      numeroAgrement: $checkedConvert('numero_agrement', (v) => v as String?),
      regionId: $checkedConvert('region_id', (v) => v as String?),
      villeId: $checkedConvert('ville_id', (v) => v as String?),
      nbMembres: $checkedConvert(
        'nb_membres',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
      produits: $checkedConvert(
        'produits',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ??
            const <String>[],
      ),
      commissionRate: $checkedConvert(
        'commission_rate',
        (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
      ),
      autoDistribute: $checkedConvert(
        'auto_distribute',
        (v) => v as bool? ?? false,
      ),
      presidentId: $checkedConvert('president_id', (v) => v as String?),
      logoUrl: $checkedConvert('logo_url', (v) => v as String?),
      description: $checkedConvert('description', (v) => v as String?),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      ambassadeurNom: $checkedConvert('ambassadeur_nom', (v) => v as String?),
      ambassadeurTitre: $checkedConvert(
        'ambassadeur_titre',
        (v) => v as String?,
      ),
      ambassadeurOrganisation: $checkedConvert(
        'ambassadeur_organisation',
        (v) => v as String?,
      ),
      ambassadeurValidatedAt: $checkedConvert(
        'ambassadeur_validated_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'userId': 'user_id',
    'numeroAgrement': 'numero_agrement',
    'regionId': 'region_id',
    'villeId': 'ville_id',
    'nbMembres': 'nb_membres',
    'commissionRate': 'commission_rate',
    'autoDistribute': 'auto_distribute',
    'presidentId': 'president_id',
    'logoUrl': 'logo_url',
    'createdAt': 'created_at',
    'ambassadeurNom': 'ambassadeur_nom',
    'ambassadeurTitre': 'ambassadeur_titre',
    'ambassadeurOrganisation': 'ambassadeur_organisation',
    'ambassadeurValidatedAt': 'ambassadeur_validated_at',
  },
);

Map<String, dynamic> _$$CooperativeImplToJson(
  _$CooperativeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'nom': instance.nom,
  if (instance.numeroAgrement case final value?) 'numero_agrement': value,
  if (instance.regionId case final value?) 'region_id': value,
  if (instance.villeId case final value?) 'ville_id': value,
  if (const FlexInt().toJson(instance.nbMembres) case final value?)
    'nb_membres': value,
  'produits': instance.produits,
  if (const FlexDouble().toJson(instance.commissionRate) case final value?)
    'commission_rate': value,
  'auto_distribute': instance.autoDistribute,
  if (instance.presidentId case final value?) 'president_id': value,
  if (instance.logoUrl case final value?) 'logo_url': value,
  if (instance.description case final value?) 'description': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
  if (instance.ambassadeurNom case final value?) 'ambassadeur_nom': value,
  if (instance.ambassadeurTitre case final value?) 'ambassadeur_titre': value,
  if (instance.ambassadeurOrganisation case final value?)
    'ambassadeur_organisation': value,
  if (instance.ambassadeurValidatedAt?.toIso8601String() case final value?)
    'ambassadeur_validated_at': value,
};
