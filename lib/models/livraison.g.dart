// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livraison.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LivraisonImpl _$$LivraisonImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$LivraisonImpl',
  json,
  ($checkedConvert) {
    final val = _$LivraisonImpl(
      id: $checkedConvert('id', (v) => v as String),
      commandeId: $checkedConvert('commande_id', (v) => v as String),
      transporterId: $checkedConvert('transporter_id', (v) => v as String?),
      status: $checkedConvert(
        'status',
        (v) =>
            $enumDecodeNullable(
              _$ShipmentStatusEnumMap,
              v,
              unknownValue: ShipmentStatus.unknown,
            ) ??
            ShipmentStatus.unknown,
      ),
      pickupLocation: $checkedConvert('pickup_location', (v) => v as String?),
      deliveryLocation: $checkedConvert(
        'delivery_location',
        (v) => v as String?,
      ),
      pickupLat: $checkedConvert(
        'pickup_lat',
        (v) => const FlexDoubleN().fromJson(v),
      ),
      pickupLng: $checkedConvert(
        'pickup_lng',
        (v) => const FlexDoubleN().fromJson(v),
      ),
      deliveryLat: $checkedConvert(
        'delivery_lat',
        (v) => const FlexDoubleN().fromJson(v),
      ),
      deliveryLng: $checkedConvert(
        'delivery_lng',
        (v) => const FlexDoubleN().fromJson(v),
      ),
      prixDevis: $checkedConvert(
        'prix_devis',
        (v) => const FlexDoubleN().fromJson(v),
      ),
      prixFinal: $checkedConvert(
        'prix_final',
        (v) => const FlexDoubleN().fromJson(v),
      ),
      photoPreuveUrl: $checkedConvert('photo_preuve_url', (v) => v as String?),
      scheduledAt: $checkedConvert(
        'scheduled_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      deliveredAt: $checkedConvert(
        'delivered_at',
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
    'commandeId': 'commande_id',
    'transporterId': 'transporter_id',
    'pickupLocation': 'pickup_location',
    'deliveryLocation': 'delivery_location',
    'pickupLat': 'pickup_lat',
    'pickupLng': 'pickup_lng',
    'deliveryLat': 'delivery_lat',
    'deliveryLng': 'delivery_lng',
    'prixDevis': 'prix_devis',
    'prixFinal': 'prix_final',
    'photoPreuveUrl': 'photo_preuve_url',
    'scheduledAt': 'scheduled_at',
    'deliveredAt': 'delivered_at',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$LivraisonImplToJson(
  _$LivraisonImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'commande_id': instance.commandeId,
  if (instance.transporterId case final value?) 'transporter_id': value,
  'status': _$ShipmentStatusEnumMap[instance.status]!,
  if (instance.pickupLocation case final value?) 'pickup_location': value,
  if (instance.deliveryLocation case final value?) 'delivery_location': value,
  if (const FlexDoubleN().toJson(instance.pickupLat) case final value?)
    'pickup_lat': value,
  if (const FlexDoubleN().toJson(instance.pickupLng) case final value?)
    'pickup_lng': value,
  if (const FlexDoubleN().toJson(instance.deliveryLat) case final value?)
    'delivery_lat': value,
  if (const FlexDoubleN().toJson(instance.deliveryLng) case final value?)
    'delivery_lng': value,
  if (const FlexDoubleN().toJson(instance.prixDevis) case final value?)
    'prix_devis': value,
  if (const FlexDoubleN().toJson(instance.prixFinal) case final value?)
    'prix_final': value,
  if (instance.photoPreuveUrl case final value?) 'photo_preuve_url': value,
  if (instance.scheduledAt?.toIso8601String() case final value?)
    'scheduled_at': value,
  if (instance.deliveredAt?.toIso8601String() case final value?)
    'delivered_at': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};

const _$ShipmentStatusEnumMap = {
  ShipmentStatus.requested: 'REQUESTED',
  ShipmentStatus.accepted: 'ACCEPTED',
  ShipmentStatus.loading: 'LOADING',
  ShipmentStatus.inTransit: 'IN_TRANSIT',
  ShipmentStatus.delivered: 'DELIVERED',
  ShipmentStatus.cancelled: 'CANCELLED',
  ShipmentStatus.unknown: 'UNKNOWN',
};

_$TransporterRouteImpl _$$TransporterRouteImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$TransporterRouteImpl',
  json,
  ($checkedConvert) {
    final val = _$TransporterRouteImpl(
      id: $checkedConvert('id', (v) => v as String),
      transporterId: $checkedConvert('transporter_id', (v) => v as String),
      origineVilleId: $checkedConvert('origine_ville_id', (v) => v as String),
      destinationVilleId: $checkedConvert(
        'destination_ville_id',
        (v) => v as String,
      ),
      capaciteKg: $checkedConvert(
        'capacite_kg',
        (v) => const FlexDouble().fromJson(v),
      ),
      prixParKm: $checkedConvert(
        'prix_par_km',
        (v) => const FlexDouble().fromJson(v),
      ),
      prixForfait: $checkedConvert(
        'prix_forfait',
        (v) => const FlexDoubleN().fromJson(v),
      ),
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
    'origineVilleId': 'origine_ville_id',
    'destinationVilleId': 'destination_ville_id',
    'capaciteKg': 'capacite_kg',
    'prixParKm': 'prix_par_km',
    'prixForfait': 'prix_forfait',
    'isActive': 'is_active',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$TransporterRouteImplToJson(
  _$TransporterRouteImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'transporter_id': instance.transporterId,
  'origine_ville_id': instance.origineVilleId,
  'destination_ville_id': instance.destinationVilleId,
  if (const FlexDouble().toJson(instance.capaciteKg) case final value?)
    'capacite_kg': value,
  if (const FlexDouble().toJson(instance.prixParKm) case final value?)
    'prix_par_km': value,
  if (const FlexDoubleN().toJson(instance.prixForfait) case final value?)
    'prix_forfait': value,
  'is_active': instance.isActive,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};

_$TrackingEventImpl _$$TrackingEventImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$TrackingEventImpl',
      json,
      ($checkedConvert) {
        final val = _$TrackingEventImpl(
          id: $checkedConvert('id', (v) => v as String),
          shipmentId: $checkedConvert('shipment_id', (v) => v as String),
          location: $checkedConvert(
            'location',
            (v) => v == null
                ? null
                : TrackingLocation.fromJson(v as Map<String, dynamic>),
          ),
          status: $checkedConvert('status', (v) => v as String?),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'shipmentId': 'shipment_id',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$$TrackingEventImplToJson(_$TrackingEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shipment_id': instance.shipmentId,
      if (instance.location case final value?) 'location': value,
      if (instance.status case final value?) 'status': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };

_$TrackingLocationImpl _$$TrackingLocationImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$TrackingLocationImpl', json, ($checkedConvert) {
  final val = _$TrackingLocationImpl(
    lat: $checkedConvert('lat', (v) => const FlexDoubleN().fromJson(v)),
    lng: $checkedConvert('lng', (v) => const FlexDoubleN().fromJson(v)),
  );
  return val;
});

Map<String, dynamic> _$$TrackingLocationImplToJson(
  _$TrackingLocationImpl instance,
) => <String, dynamic>{
  if (const FlexDoubleN().toJson(instance.lat) case final value?) 'lat': value,
  if (const FlexDoubleN().toJson(instance.lng) case final value?) 'lng': value,
};
