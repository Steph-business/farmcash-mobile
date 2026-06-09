// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'negociation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CandidatureImpl _$$CandidatureImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$CandidatureImpl',
      json,
      ($checkedConvert) {
        final val = _$CandidatureImpl(
          id: $checkedConvert('id', (v) => v as String),
          annonceId: $checkedConvert('annonce_id', (v) => v as String),
          buyerId: $checkedConvert('buyer_id', (v) => v as String),
          quantiteKg: $checkedConvert(
            'quantite_kg',
            (v) => const FlexDouble().fromJson(v),
          ),
          prixProposeKg: $checkedConvert(
            'prix_propose_kg',
            (v) => const FlexDouble().fromJson(v),
          ),
          status: $checkedConvert(
            'status',
            (v) =>
                $enumDecodeNullable(
                  _$NegotiationStatusEnumMap,
                  v,
                  unknownValue: NegotiationStatus.unknown,
                ) ??
                NegotiationStatus.unknown,
          ),
          message: $checkedConvert('message', (v) => v as String?),
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
        'annonceId': 'annonce_id',
        'buyerId': 'buyer_id',
        'quantiteKg': 'quantite_kg',
        'prixProposeKg': 'prix_propose_kg',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$$CandidatureImplToJson(_$CandidatureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'annonce_id': instance.annonceId,
      'buyer_id': instance.buyerId,
      if (const FlexDouble().toJson(instance.quantiteKg) case final value?)
        'quantite_kg': value,
      if (const FlexDouble().toJson(instance.prixProposeKg) case final value?)
        'prix_propose_kg': value,
      'status': _$NegotiationStatusEnumMap[instance.status]!,
      if (instance.message case final value?) 'message': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updated_at': value,
    };

const _$NegotiationStatusEnumMap = {
  NegotiationStatus.pending: 'PENDING',
  NegotiationStatus.accepted: 'ACCEPTED',
  NegotiationStatus.rejected: 'REJECTED',
  NegotiationStatus.counterOffered: 'COUNTER_OFFERED',
  NegotiationStatus.cancelled: 'CANCELLED',
  NegotiationStatus.unknown: 'UNKNOWN',
};

_$PropositionImpl _$$PropositionImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$PropositionImpl',
      json,
      ($checkedConvert) {
        final val = _$PropositionImpl(
          id: $checkedConvert('id', (v) => v as String),
          annonceAchatId: $checkedConvert(
            'annonce_achat_id',
            (v) => v as String,
          ),
          vendeurId: $checkedConvert('vendeur_id', (v) => v as String),
          quantiteKg: $checkedConvert(
            'quantite_kg',
            (v) => const FlexDouble().fromJson(v),
          ),
          prixProposeKg: $checkedConvert(
            'prix_propose_kg',
            (v) => const FlexDouble().fromJson(v),
          ),
          status: $checkedConvert(
            'status',
            (v) =>
                $enumDecodeNullable(
                  _$NegotiationStatusEnumMap,
                  v,
                  unknownValue: NegotiationStatus.unknown,
                ) ??
                NegotiationStatus.unknown,
          ),
          message: $checkedConvert('message', (v) => v as String?),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          vendeur: $checkedConvert('users', (v) => _vendeurFromJson(v)),
        );
        return val;
      },
      fieldKeyMap: const {
        'annonceAchatId': 'annonce_achat_id',
        'vendeurId': 'vendeur_id',
        'quantiteKg': 'quantite_kg',
        'prixProposeKg': 'prix_propose_kg',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
        'vendeur': 'users',
      },
    );

Map<String, dynamic> _$$PropositionImplToJson(_$PropositionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'annonce_achat_id': instance.annonceAchatId,
      'vendeur_id': instance.vendeurId,
      if (const FlexDouble().toJson(instance.quantiteKg) case final value?)
        'quantite_kg': value,
      if (const FlexDouble().toJson(instance.prixProposeKg) case final value?)
        'prix_propose_kg': value,
      'status': _$NegotiationStatusEnumMap[instance.status]!,
      if (instance.message case final value?) 'message': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updated_at': value,
      if (_vendeurToJson(instance.vendeur) case final value?) 'users': value,
    };

_$TraitementNegociationResultatImpl
_$$TraitementNegociationResultatImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$TraitementNegociationResultatImpl',
      json,
      ($checkedConvert) {
        final val = _$TraitementNegociationResultatImpl(
          message: $checkedConvert('message', (v) => v as String? ?? ''),
          commandeId: $checkedConvert('commande_id', (v) => v as String?),
          reference: $checkedConvert('reference', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'commandeId': 'commande_id'},
    );

Map<String, dynamic> _$$TraitementNegociationResultatImplToJson(
  _$TraitementNegociationResultatImpl instance,
) => <String, dynamic>{
  'message': instance.message,
  if (instance.commandeId case final value?) 'commande_id': value,
  if (instance.reference case final value?) 'reference': value,
};

_$ContreOffreCoopImpl _$$ContreOffreCoopImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$ContreOffreCoopImpl',
  json,
  ($checkedConvert) {
    final val = _$ContreOffreCoopImpl(
      id: $checkedConvert('id', (v) => v as String),
      publicationCoopId: $checkedConvert(
        'publication_coop_id',
        (v) => v as String,
      ),
      buyerId: $checkedConvert('buyer_id', (v) => v as String),
      quantiteKg: $checkedConvert(
        'quantite_kg',
        (v) => const FlexDouble().fromJson(v),
      ),
      prixProposeKg: $checkedConvert(
        'prix_propose_kg',
        (v) => const FlexDouble().fromJson(v),
      ),
      status: $checkedConvert(
        'status',
        (v) =>
            $enumDecodeNullable(
              _$NegotiationStatusEnumMap,
              v,
              unknownValue: NegotiationStatus.unknown,
            ) ??
            NegotiationStatus.unknown,
      ),
      message: $checkedConvert('message', (v) => v as String?),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'publicationCoopId': 'publication_coop_id',
    'buyerId': 'buyer_id',
    'quantiteKg': 'quantite_kg',
    'prixProposeKg': 'prix_propose_kg',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$ContreOffreCoopImplToJson(
  _$ContreOffreCoopImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'publication_coop_id': instance.publicationCoopId,
  'buyer_id': instance.buyerId,
  if (const FlexDouble().toJson(instance.quantiteKg) case final value?)
    'quantite_kg': value,
  if (const FlexDouble().toJson(instance.prixProposeKg) case final value?)
    'prix_propose_kg': value,
  'status': _$NegotiationStatusEnumMap[instance.status]!,
  if (instance.message case final value?) 'message': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};
