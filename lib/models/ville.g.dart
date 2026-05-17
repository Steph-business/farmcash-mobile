// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ville.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VilleImpl _$$VilleImplFromJson(Map<String, dynamic> json) => $checkedCreate(
  r'_$VilleImpl',
  json,
  ($checkedConvert) {
    final val = _$VilleImpl(
      id: $checkedConvert('id', (v) => v as String),
      nom: $checkedConvert('nom', (v) => v as String),
      regionId: $checkedConvert('region_id', (v) => v as String),
      regionNom: $checkedConvert('regions_ci', (v) => _regionNomFromMap(v)),
    );
    return val;
  },
  fieldKeyMap: const {'regionId': 'region_id', 'regionNom': 'regions_ci'},
);

Map<String, dynamic> _$$VilleImplToJson(_$VilleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'region_id': instance.regionId,
      if (instance.regionNom case final value?) 'regions_ci': value,
    };
