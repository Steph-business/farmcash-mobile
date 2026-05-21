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
      vehicleType: $checkedConvert('vehicle_type', (v) => v as String?),
      origineZone: $checkedConvert('origin_zone', (v) => v as String?),
      destinationZone: $checkedConvert('destination_zone', (v) => v as String?),
      pickupAddress: $checkedConvert('pickup_address', (v) => v as String?),
      deliveryAddress: $checkedConvert('delivery_address', (v) => v as String?),
      prixDevis: $checkedConvert(
        'prix_devis',
        (v) => const FlexDoubleN().fromJson(v),
      ),
      prixFinal: $checkedConvert(
        'prix_final',
        (v) => const FlexDoubleN().fromJson(v),
      ),
      quantiteKg: $checkedConvert(
        'quantite_kg',
        (v) => const FlexDoubleN().fromJson(v),
      ),
      photoPreuveUrl: $checkedConvert('photo_preuve_url', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
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
      pickupScannedAt: $checkedConvert(
        'pickup_scanned_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      commande: $checkedConvert(
        'commandes_vente',
        (v) => _commandeApercuFromJson(v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'commandeId': 'commande_id',
    'transporterId': 'transporter_id',
    'vehicleType': 'vehicle_type',
    'origineZone': 'origin_zone',
    'destinationZone': 'destination_zone',
    'pickupAddress': 'pickup_address',
    'deliveryAddress': 'delivery_address',
    'prixDevis': 'prix_devis',
    'prixFinal': 'prix_final',
    'quantiteKg': 'quantite_kg',
    'photoPreuveUrl': 'photo_preuve_url',
    'scheduledAt': 'scheduled_at',
    'deliveredAt': 'delivered_at',
    'createdAt': 'created_at',
    'pickupScannedAt': 'pickup_scanned_at',
    'commande': 'commandes_vente',
  },
);

Map<String, dynamic> _$$LivraisonImplToJson(_$LivraisonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'commande_id': instance.commandeId,
      if (instance.transporterId case final value?) 'transporter_id': value,
      'status': _$ShipmentStatusEnumMap[instance.status]!,
      if (instance.vehicleType case final value?) 'vehicle_type': value,
      if (instance.origineZone case final value?) 'origin_zone': value,
      if (instance.destinationZone case final value?) 'destination_zone': value,
      if (instance.pickupAddress case final value?) 'pickup_address': value,
      if (instance.deliveryAddress case final value?) 'delivery_address': value,
      if (const FlexDoubleN().toJson(instance.prixDevis) case final value?)
        'prix_devis': value,
      if (const FlexDoubleN().toJson(instance.prixFinal) case final value?)
        'prix_final': value,
      if (const FlexDoubleN().toJson(instance.quantiteKg) case final value?)
        'quantite_kg': value,
      if (instance.photoPreuveUrl case final value?) 'photo_preuve_url': value,
      if (instance.notes case final value?) 'notes': value,
      if (instance.scheduledAt?.toIso8601String() case final value?)
        'scheduled_at': value,
      if (instance.deliveredAt?.toIso8601String() case final value?)
        'delivered_at': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      if (instance.pickupScannedAt?.toIso8601String() case final value?)
        'pickup_scanned_at': value,
      if (_commandeApercuToJson(instance.commande) case final value?)
        'commandes_vente': value,
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
      origineZone: $checkedConvert('origin_zone', (v) => v as String),
      destinationZone: $checkedConvert('destination_zone', (v) => v as String),
      capaciteMaxKg: $checkedConvert(
        'capacite_max_kg',
        (v) => const FlexDouble().fromJson(v),
      ),
      tarifKg: $checkedConvert(
        'tarif_kg',
        (v) => const FlexDouble().fromJson(v),
      ),
      tarifMinimum: $checkedConvert(
        'tarif_minimum',
        (v) => v == null ? 0 : const FlexDouble().fromJson(v),
      ),
      delaiTypique: $checkedConvert('delai_typique', (v) => v as String?),
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
    'origineZone': 'origin_zone',
    'destinationZone': 'destination_zone',
    'capaciteMaxKg': 'capacite_max_kg',
    'tarifKg': 'tarif_kg',
    'tarifMinimum': 'tarif_minimum',
    'delaiTypique': 'delai_typique',
    'isActive': 'is_active',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$TransporterRouteImplToJson(
  _$TransporterRouteImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'transporter_id': instance.transporterId,
  'origin_zone': instance.origineZone,
  'destination_zone': instance.destinationZone,
  if (const FlexDouble().toJson(instance.capaciteMaxKg) case final value?)
    'capacite_max_kg': value,
  if (const FlexDouble().toJson(instance.tarifKg) case final value?)
    'tarif_kg': value,
  if (const FlexDouble().toJson(instance.tarifMinimum) case final value?)
    'tarif_minimum': value,
  if (instance.delaiTypique case final value?) 'delai_typique': value,
  'is_active': instance.isActive,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};

_$TransportQuoteImpl _$$TransportQuoteImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$TransportQuoteImpl',
      json,
      ($checkedConvert) {
        final val = _$TransportQuoteImpl(
          routeId: $checkedConvert('route_id', (v) => v as String),
          transporterId: $checkedConvert('transporter_id', (v) => v as String),
          transporterName: $checkedConvert(
            'transporter_name',
            (v) => v as String? ?? '',
          ),
          rating: $checkedConvert(
            'rating',
            (v) => v == null ? 0 : const FlexDouble().fromJson(v),
          ),
          tarifTotal: $checkedConvert(
            'tarif_total',
            (v) => const FlexDouble().fromJson(v),
          ),
          delaiTypique: $checkedConvert('delai_typique', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'routeId': 'route_id',
        'transporterId': 'transporter_id',
        'transporterName': 'transporter_name',
        'tarifTotal': 'tarif_total',
        'delaiTypique': 'delai_typique',
      },
    );

Map<String, dynamic> _$$TransportQuoteImplToJson(
  _$TransportQuoteImpl instance,
) => <String, dynamic>{
  'route_id': instance.routeId,
  'transporter_id': instance.transporterId,
  'transporter_name': instance.transporterName,
  if (const FlexDouble().toJson(instance.rating) case final value?)
    'rating': value,
  if (const FlexDouble().toJson(instance.tarifTotal) case final value?)
    'tarif_total': value,
  if (instance.delaiTypique case final value?) 'delai_typique': value,
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
          note: $checkedConvert('note', (v) => v as String?),
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
      if (instance.note case final value?) 'note': value,
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
