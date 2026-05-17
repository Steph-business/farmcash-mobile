// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avance_coop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AvanceCoopImpl _$$AvanceCoopImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$AvanceCoopImpl',
  json,
  ($checkedConvert) {
    final val = _$AvanceCoopImpl(
      id: $checkedConvert('id', (v) => v as String),
      cooperativeId: $checkedConvert('cooperative_id', (v) => v as String),
      farmerId: $checkedConvert('farmer_id', (v) => v as String),
      amount: $checkedConvert('amount', (v) => const FlexDouble().fromJson(v)),
      annonceVenteId: $checkedConvert('annonce_vente_id', (v) => v as String?),
      status: $checkedConvert(
        'status',
        (v) =>
            $enumDecodeNullable(
              _$CoopAdvanceStatusEnumMap,
              v,
              unknownValue: CoopAdvanceStatus.unknown,
            ) ??
            CoopAdvanceStatus.unknown,
      ),
      motif: $checkedConvert('motif', (v) => v as String?),
      paidAt: $checkedConvert(
        'paid_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      reimbursedAt: $checkedConvert(
        'reimbursed_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'cooperativeId': 'cooperative_id',
    'farmerId': 'farmer_id',
    'annonceVenteId': 'annonce_vente_id',
    'paidAt': 'paid_at',
    'reimbursedAt': 'reimbursed_at',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$AvanceCoopImplToJson(
  _$AvanceCoopImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'cooperative_id': instance.cooperativeId,
  'farmer_id': instance.farmerId,
  if (const FlexDouble().toJson(instance.amount) case final value?)
    'amount': value,
  if (instance.annonceVenteId case final value?) 'annonce_vente_id': value,
  'status': _$CoopAdvanceStatusEnumMap[instance.status]!,
  if (instance.motif case final value?) 'motif': value,
  if (instance.paidAt?.toIso8601String() case final value?) 'paid_at': value,
  if (instance.reimbursedAt?.toIso8601String() case final value?)
    'reimbursed_at': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};

const _$CoopAdvanceStatusEnumMap = {
  CoopAdvanceStatus.paid: 'PAID',
  CoopAdvanceStatus.reimbursed: 'REIMBURSED',
  CoopAdvanceStatus.cancelled: 'CANCELLED',
  CoopAdvanceStatus.unknown: 'UNKNOWN',
};
