// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReservationImpl _$$ReservationImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$ReservationImpl',
      json,
      ($checkedConvert) {
        final val = _$ReservationImpl(
          id: $checkedConvert('id', (v) => v as String),
          previsionId: $checkedConvert('prevision_id', (v) => v as String),
          acheteurId: $checkedConvert('acheteur_id', (v) => v as String),
          quantiteKg: $checkedConvert(
            'quantite_kg',
            (v) => const FlexDouble().fromJson(v),
          ),
          depositAmount: $checkedConvert(
            'deposit_amount',
            (v) => const FlexDouble().fromJson(v),
          ),
          status: $checkedConvert('status', (v) => v as String? ?? 'PENDING'),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'previsionId': 'prevision_id',
        'acheteurId': 'acheteur_id',
        'quantiteKg': 'quantite_kg',
        'depositAmount': 'deposit_amount',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$$ReservationImplToJson(_$ReservationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prevision_id': instance.previsionId,
      'acheteur_id': instance.acheteurId,
      if (const FlexDouble().toJson(instance.quantiteKg) case final value?)
        'quantite_kg': value,
      if (const FlexDouble().toJson(instance.depositAmount) case final value?)
        'deposit_amount': value,
      'status': instance.status,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };
