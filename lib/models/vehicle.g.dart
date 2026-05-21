// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleImpl _$$VehicleImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$VehicleImpl',
      json,
      ($checkedConvert) {
        final val = _$VehicleImpl(
          id: $checkedConvert('id', (v) => v as String),
          transporterId: $checkedConvert('transporter_id', (v) => v as String),
          type: $checkedConvert('type', (v) => v as String? ?? ''),
          immatriculation: $checkedConvert(
            'immatriculation',
            (v) => v as String?,
          ),
          marque: $checkedConvert('marque', (v) => v as String?),
          chargeMaxKg: $checkedConvert(
            'charge_max_kg',
            (v) => v == null ? 0 : const FlexDouble().fromJson(v),
          ),
          volumeM3: $checkedConvert(
            'volume_m3',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          photoUrl: $checkedConvert('photo_url', (v) => v as String?),
          isActive: $checkedConvert('is_active', (v) => v as bool? ?? true),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'transporterId': 'transporter_id',
        'chargeMaxKg': 'charge_max_kg',
        'volumeM3': 'volume_m3',
        'photoUrl': 'photo_url',
        'isActive': 'is_active',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$$VehicleImplToJson(_$VehicleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transporter_id': instance.transporterId,
      'type': instance.type,
      if (instance.immatriculation case final value?) 'immatriculation': value,
      if (instance.marque case final value?) 'marque': value,
      if (const FlexDouble().toJson(instance.chargeMaxKg) case final value?)
        'charge_max_kg': value,
      if (const FlexDoubleN().toJson(instance.volumeM3) case final value?)
        'volume_m3': value,
      if (instance.photoUrl case final value?) 'photo_url': value,
      'is_active': instance.isActive,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };
