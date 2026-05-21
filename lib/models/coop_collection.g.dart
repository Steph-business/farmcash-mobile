// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coop_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoopCollectionImpl _$$CoopCollectionImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$CoopCollectionImpl',
  json,
  ($checkedConvert) {
    final val = _$CoopCollectionImpl(
      id: $checkedConvert('id', (v) => v as String),
      cooperativeId: $checkedConvert('cooperative_id', (v) => v as String),
      farmerId: $checkedConvert('farmer_id', (v) => v as String),
      annonceVenteId: $checkedConvert('annonce_vente_id', (v) => v as String?),
      vehicleId: $checkedConvert('vehicle_id', (v) => v as String?),
      scheduledAt: $checkedConvert(
        'scheduled_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      pickupAddress: $checkedConvert(
        'pickup_address',
        (v) => v as String? ?? '',
      ),
      quantitePrevueKg: $checkedConvert(
        'quantite_prevue_kg',
        (v) => v == null ? 0 : const FlexDouble().fromJson(v),
      ),
      status: $checkedConvert('status', (v) => v as String? ?? 'PLANNED'),
      notes: $checkedConvert('notes', (v) => v as String?),
      completedAt: $checkedConvert(
        'completed_at',
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
      farmer: $checkedConvert(
        'users',
        (v) =>
            v == null ? null : Utilisateur.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'cooperativeId': 'cooperative_id',
    'farmerId': 'farmer_id',
    'annonceVenteId': 'annonce_vente_id',
    'vehicleId': 'vehicle_id',
    'scheduledAt': 'scheduled_at',
    'pickupAddress': 'pickup_address',
    'quantitePrevueKg': 'quantite_prevue_kg',
    'completedAt': 'completed_at',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'farmer': 'users',
  },
);

Map<String, dynamic> _$$CoopCollectionImplToJson(
  _$CoopCollectionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'cooperative_id': instance.cooperativeId,
  'farmer_id': instance.farmerId,
  if (instance.annonceVenteId case final value?) 'annonce_vente_id': value,
  if (instance.vehicleId case final value?) 'vehicle_id': value,
  if (instance.scheduledAt?.toIso8601String() case final value?)
    'scheduled_at': value,
  'pickup_address': instance.pickupAddress,
  if (const FlexDouble().toJson(instance.quantitePrevueKg) case final value?)
    'quantite_prevue_kg': value,
  'status': instance.status,
  if (instance.notes case final value?) 'notes': value,
  if (instance.completedAt?.toIso8601String() case final value?)
    'completed_at': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
  if (instance.updatedAt?.toIso8601String() case final value?)
    'updated_at': value,
  if (instance.farmer case final value?) 'users': value,
};
