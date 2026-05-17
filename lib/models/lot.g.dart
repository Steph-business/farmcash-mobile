// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LotImpl _$$LotImplFromJson(Map<String, dynamic> json) => $checkedCreate(
  r'_$LotImpl',
  json,
  ($checkedConvert) {
    final val = _$LotImpl(
      id: $checkedConvert('id', (v) => v as String),
      lotCode: $checkedConvert('lot_code', (v) => v as String),
      type: $checkedConvert('type', (v) => v as String? ?? 'INDIVIDUAL'),
      produitId: $checkedConvert('produit_id', (v) => v as String),
      quantiteKg: $checkedConvert(
        'quantite_kg',
        (v) => const FlexDouble().fromJson(v),
      ),
      farmerId: $checkedConvert('farmer_id', (v) => v as String?),
      cooperativeId: $checkedConvert('cooperative_id', (v) => v as String?),
      qualite: $checkedConvert(
        'qualite',
        (v) =>
            $enumDecodeNullable(
              _$ProductQualityEnumMap,
              v,
              unknownValue: ProductQuality.unknown,
            ) ??
            ProductQuality.unknown,
      ),
      dateRecolte: $checkedConvert(
        'date_recolte',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      blockchainTx: $checkedConvert('blockchain_tx', (v) => v as String?),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'lotCode': 'lot_code',
    'produitId': 'produit_id',
    'quantiteKg': 'quantite_kg',
    'farmerId': 'farmer_id',
    'cooperativeId': 'cooperative_id',
    'dateRecolte': 'date_recolte',
    'blockchainTx': 'blockchain_tx',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$LotImplToJson(_$LotImpl instance) => <String, dynamic>{
  'id': instance.id,
  'lot_code': instance.lotCode,
  'type': instance.type,
  'produit_id': instance.produitId,
  if (const FlexDouble().toJson(instance.quantiteKg) case final value?)
    'quantite_kg': value,
  if (instance.farmerId case final value?) 'farmer_id': value,
  if (instance.cooperativeId case final value?) 'cooperative_id': value,
  'qualite': _$ProductQualityEnumMap[instance.qualite]!,
  if (instance.dateRecolte?.toIso8601String() case final value?)
    'date_recolte': value,
  if (instance.blockchainTx case final value?) 'blockchain_tx': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};

const _$ProductQualityEnumMap = {
  ProductQuality.standard: 'STANDARD',
  ProductQuality.premium: 'PREMIUM',
  ProductQuality.bio: 'BIO',
  ProductQuality.equitable: 'EQUITABLE',
  ProductQuality.unknown: 'UNKNOWN',
};

_$EntrepotImpl _$$EntrepotImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$EntrepotImpl',
      json,
      ($checkedConvert) {
        final val = _$EntrepotImpl(
          id: $checkedConvert('id', (v) => v as String),
          ownerId: $checkedConvert('owner_id', (v) => v as String),
          nom: $checkedConvert('nom', (v) => v as String),
          capaciteKg: $checkedConvert(
            'capacite_kg',
            (v) => const FlexDouble().fromJson(v),
          ),
          location: $checkedConvert('location', (v) => v as String?),
          lat: $checkedConvert('lat', (v) => const FlexDoubleN().fromJson(v)),
          lng: $checkedConvert('lng', (v) => const FlexDoubleN().fromJson(v)),
          isRefrigere: $checkedConvert(
            'is_refrigere',
            (v) => v as bool? ?? false,
          ),
          temperatureMin: $checkedConvert(
            'temperature_min',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          temperatureMax: $checkedConvert(
            'temperature_max',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'ownerId': 'owner_id',
        'capaciteKg': 'capacite_kg',
        'isRefrigere': 'is_refrigere',
        'temperatureMin': 'temperature_min',
        'temperatureMax': 'temperature_max',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$$EntrepotImplToJson(
  _$EntrepotImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'nom': instance.nom,
  if (const FlexDouble().toJson(instance.capaciteKg) case final value?)
    'capacite_kg': value,
  if (instance.location case final value?) 'location': value,
  if (const FlexDoubleN().toJson(instance.lat) case final value?) 'lat': value,
  if (const FlexDoubleN().toJson(instance.lng) case final value?) 'lng': value,
  'is_refrigere': instance.isRefrigere,
  if (const FlexDoubleN().toJson(instance.temperatureMin) case final value?)
    'temperature_min': value,
  if (const FlexDoubleN().toJson(instance.temperatureMax) case final value?)
    'temperature_max': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};

_$TraceabilityEventImpl _$$TraceabilityEventImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$TraceabilityEventImpl',
  json,
  ($checkedConvert) {
    final val = _$TraceabilityEventImpl(
      id: $checkedConvert('id', (v) => v as String),
      lotId: $checkedConvert('lot_id', (v) => v as String),
      eventType: $checkedConvert('event_type', (v) => v as String),
      actorId: $checkedConvert('actor_id', (v) => v as String?),
      location: $checkedConvert('location', (v) => v as String?),
      metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
      blockchainTx: $checkedConvert('blockchain_tx', (v) => v as String?),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'lotId': 'lot_id',
    'eventType': 'event_type',
    'actorId': 'actor_id',
    'blockchainTx': 'blockchain_tx',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$TraceabilityEventImplToJson(
  _$TraceabilityEventImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'lot_id': instance.lotId,
  'event_type': instance.eventType,
  if (instance.actorId case final value?) 'actor_id': value,
  if (instance.location case final value?) 'location': value,
  if (instance.metadata case final value?) 'metadata': value,
  if (instance.blockchainTx case final value?) 'blockchain_tx': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};
