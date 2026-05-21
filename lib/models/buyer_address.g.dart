// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyer_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BuyerAddressImpl _$$BuyerAddressImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$BuyerAddressImpl',
      json,
      ($checkedConvert) {
        final val = _$BuyerAddressImpl(
          id: $checkedConvert('id', (v) => v as String),
          userId: $checkedConvert('user_id', (v) => v as String),
          libelle: $checkedConvert('libelle', (v) => v as String),
          contactNom: $checkedConvert('contact_nom', (v) => v as String? ?? ''),
          contactPhone: $checkedConvert(
            'contact_phone',
            (v) => v as String? ?? '',
          ),
          adresseComplete: $checkedConvert(
            'adresse_complete',
            (v) => v as String? ?? '',
          ),
          villeId: $checkedConvert('ville_id', (v) => v as String?),
          lat: $checkedConvert('lat', (v) => const FlexDoubleN().fromJson(v)),
          lng: $checkedConvert('lng', (v) => const FlexDoubleN().fromJson(v)),
          isDefault: $checkedConvert('is_default', (v) => v as bool? ?? false),
          isActive: $checkedConvert('is_active', (v) => v as bool? ?? true),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          villeNom: $checkedConvert('villes_ci', (v) => _nomFromMap(v)),
        );
        return val;
      },
      fieldKeyMap: const {
        'userId': 'user_id',
        'contactNom': 'contact_nom',
        'contactPhone': 'contact_phone',
        'adresseComplete': 'adresse_complete',
        'villeId': 'ville_id',
        'isDefault': 'is_default',
        'isActive': 'is_active',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
        'villeNom': 'villes_ci',
      },
    );

Map<String, dynamic> _$$BuyerAddressImplToJson(
  _$BuyerAddressImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'libelle': instance.libelle,
  'contact_nom': instance.contactNom,
  'contact_phone': instance.contactPhone,
  'adresse_complete': instance.adresseComplete,
  if (instance.villeId case final value?) 'ville_id': value,
  if (const FlexDoubleN().toJson(instance.lat) case final value?) 'lat': value,
  if (const FlexDoubleN().toJson(instance.lng) case final value?) 'lng': value,
  'is_default': instance.isDefault,
  'is_active': instance.isActive,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
  if (instance.updatedAt?.toIso8601String() case final value?)
    'updated_at': value,
  if (_nomToMap(instance.villeNom) case final value?) 'villes_ci': value,
};
