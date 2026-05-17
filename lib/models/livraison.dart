import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'livraison.freezed.dart';
part 'livraison.g.dart';

/// Shipment = livraison physique attachée à une commande.
@freezed
class Livraison with _$Livraison {
  const factory Livraison({
    required String id,
    required String commandeId,
    String? transporterId,
    @JsonKey(unknownEnumValue: ShipmentStatus.unknown)
    @Default(ShipmentStatus.unknown)
    ShipmentStatus status,
    String? pickupLocation,
    String? deliveryLocation,
    @FlexDoubleN() double? pickupLat,
    @FlexDoubleN() double? pickupLng,
    @FlexDoubleN() double? deliveryLat,
    @FlexDoubleN() double? deliveryLng,
    @FlexDoubleN() double? prixDevis,
    @FlexDoubleN() double? prixFinal,
    String? photoPreuveUrl,
    DateTime? scheduledAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
  }) = _Livraison;

  factory Livraison.fromJson(Map<String, dynamic> json) =>
      _$LivraisonFromJson(json);
}

/// Route déclarée par un transporteur (point A → point B avec tarif).
@freezed
class TransporterRoute with _$TransporterRoute {
  const factory TransporterRoute({
    required String id,
    required String transporterId,
    required String origineVilleId,
    required String destinationVilleId,
    @FlexDouble() required double capaciteKg,
    @FlexDouble() required double prixParKm,
    @FlexDoubleN() double? prixForfait,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _TransporterRoute;

  factory TransporterRoute.fromJson(Map<String, dynamic> json) =>
      _$TransporterRouteFromJson(json);
}

/// Événement de tracking GPS sur un shipment.
@freezed
class TrackingEvent with _$TrackingEvent {
  const TrackingEvent._();

  const factory TrackingEvent({
    required String id,
    required String shipmentId,
    TrackingLocation? location,
    String? status,
    DateTime? createdAt,
  }) = _TrackingEvent;

  factory TrackingEvent.fromJson(Map<String, dynamic> json) =>
      _$TrackingEventFromJson(json);

  double? get lat => location?.lat;
  double? get lng => location?.lng;
}

@freezed
class TrackingLocation with _$TrackingLocation {
  const factory TrackingLocation({
    @FlexDoubleN() double? lat,
    @FlexDoubleN() double? lng,
  }) = _TrackingLocation;

  factory TrackingLocation.fromJson(Map<String, dynamic> json) =>
      _$TrackingLocationFromJson(json);
}
