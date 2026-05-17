// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prevision.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrevisionImpl _$$PrevisionImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$PrevisionImpl',
      json,
      ($checkedConvert) {
        final val = _$PrevisionImpl(
          id: $checkedConvert('id', (v) => v as String),
          farmerId: $checkedConvert('farmer_id', (v) => v as String),
          produitId: $checkedConvert('produit_id', (v) => v as String),
          quantitePrevKg: $checkedConvert(
            'quantite_prev_kg',
            (v) => const FlexDouble().fromJson(v),
          ),
          parcelleId: $checkedConvert('parcelle_id', (v) => v as String?),
          dateRecoltePrev: $checkedConvert(
            'date_recolte_prev',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          prixCibleKg: $checkedConvert(
            'prix_cible_kg',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          status: $checkedConvert(
            'status',
            (v) =>
                $enumDecodeNullable(
                  _$PrevisionStatusEnumMap,
                  v,
                  unknownValue: PrevisionStatus.unknown,
                ) ??
                PrevisionStatus.unknown,
          ),
          assignedToCooperativeId: $checkedConvert(
            'assigned_to_cooperative_id',
            (v) => v as String?,
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
        'farmerId': 'farmer_id',
        'produitId': 'produit_id',
        'quantitePrevKg': 'quantite_prev_kg',
        'parcelleId': 'parcelle_id',
        'dateRecoltePrev': 'date_recolte_prev',
        'prixCibleKg': 'prix_cible_kg',
        'assignedToCooperativeId': 'assigned_to_cooperative_id',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$$PrevisionImplToJson(_$PrevisionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'farmer_id': instance.farmerId,
      'produit_id': instance.produitId,
      if (const FlexDouble().toJson(instance.quantitePrevKg) case final value?)
        'quantite_prev_kg': value,
      if (instance.parcelleId case final value?) 'parcelle_id': value,
      if (instance.dateRecoltePrev?.toIso8601String() case final value?)
        'date_recolte_prev': value,
      if (const FlexDoubleN().toJson(instance.prixCibleKg) case final value?)
        'prix_cible_kg': value,
      'status': _$PrevisionStatusEnumMap[instance.status]!,
      if (instance.assignedToCooperativeId case final value?)
        'assigned_to_cooperative_id': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updated_at': value,
    };

const _$PrevisionStatusEnumMap = {
  PrevisionStatus.open: 'OPEN',
  PrevisionStatus.converted: 'CONVERTED',
  PrevisionStatus.expired: 'EXPIRED',
  PrevisionStatus.cancelled: 'CANCELLED',
  PrevisionStatus.unknown: 'UNKNOWN',
};
