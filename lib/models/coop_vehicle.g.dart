// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coop_vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoopVehicleImpl _$$CoopVehicleImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$CoopVehicleImpl',
  json,
  ($checkedConvert) {
    final val = _$CoopVehicleImpl(
      id: $checkedConvert('id', (v) => v as String),
      cooperativeId: $checkedConvert('cooperative_id', (v) => v as String),
      type: $checkedConvert('type', (v) => v as String? ?? ''),
      immatriculation: $checkedConvert('immatriculation', (v) => v as String?),
      marque: $checkedConvert('marque', (v) => v as String?),
      chargeMaxKg: $checkedConvert(
        'charge_max_kg',
        (v) => v == null ? 0 : const FlexDouble().fromJson(v),
      ),
      chauffeurNom: $checkedConvert('chauffeur_nom', (v) => v as String?),
      chauffeurPhone: $checkedConvert('chauffeur_phone', (v) => v as String?),
      isActive: $checkedConvert('is_active', (v) => v as bool? ?? true),
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
    'cooperativeId': 'cooperative_id',
    'chargeMaxKg': 'charge_max_kg',
    'chauffeurNom': 'chauffeur_nom',
    'chauffeurPhone': 'chauffeur_phone',
    'isActive': 'is_active',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$$CoopVehicleImplToJson(_$CoopVehicleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cooperative_id': instance.cooperativeId,
      'type': instance.type,
      if (instance.immatriculation case final value?) 'immatriculation': value,
      if (instance.marque case final value?) 'marque': value,
      if (const FlexDouble().toJson(instance.chargeMaxKg) case final value?)
        'charge_max_kg': value,
      if (instance.chauffeurNom case final value?) 'chauffeur_nom': value,
      if (instance.chauffeurPhone case final value?) 'chauffeur_phone': value,
      'is_active': instance.isActive,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updated_at': value,
    };
