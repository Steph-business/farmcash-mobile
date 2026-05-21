import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'livraison.freezed.dart';
part 'livraison.g.dart';

/// Shipment = livraison physique attachée à une commande.
///
/// Le backend renvoie certaines listes (ex. missions disponibles) avec
/// la relation `commandes_vente` jointe — on l'aplatit en getters pour
/// éviter d'exposer la sous-structure côté UI.
@freezed
class Livraison with _$Livraison {
  const Livraison._();

  const factory Livraison({
    required String id,
    required String commandeId,
    String? transporterId,
    @JsonKey(unknownEnumValue: ShipmentStatus.unknown)
    @Default(ShipmentStatus.unknown)
    ShipmentStatus status,
    String? vehicleType,
    @JsonKey(name: 'origin_zone') String? origineZone,
    @JsonKey(name: 'destination_zone') String? destinationZone,
    String? pickupAddress,
    String? deliveryAddress,
    @FlexDoubleN() double? prixDevis,
    @FlexDoubleN() double? prixFinal,
    @FlexDoubleN() double? quantiteKg,
    String? photoPreuveUrl,
    String? notes,
    DateTime? scheduledAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? pickupScannedAt,

    /// Champ joint `commandes_vente` quand le backend l'expose
    /// (notamment `GET /logistics/missions/available`).
    @JsonKey(
      name: 'commandes_vente',
      fromJson: _commandeApercuFromJson,
      toJson: _commandeApercuToJson,
    )
    CommandeApercu? commande,
  }) = _Livraison;

  factory Livraison.fromJson(Map<String, dynamic> json) =>
      _$LivraisonFromJson(json);

  /// Référence de commande lisible si elle est jointe.
  String? get reference => commande?.reference;

  /// Montant total de la commande (depuis l'objet joint).
  double? get montantCommande => commande?.montantTotal;

  /// Itinéraire lisible `Origine → Destination`. Renvoie `null` si une
  /// des extrémités est absente.
  String? get itineraireLabel {
    final o = origineZone?.trim();
    final d = destinationZone?.trim();
    if (o == null || o.isEmpty || d == null || d.isEmpty) return null;
    return '$o → $d';
  }
}

/// Sous-objet joint à un shipment : informations minimales sur la commande
/// d'origine. Le backend ne renvoie pas toujours la totalité — tout est
/// nullable.
class CommandeApercu {
  const CommandeApercu({this.reference, this.montantTotal, this.buyerId});

  final String? reference;
  final double? montantTotal;
  final String? buyerId;
}

CommandeApercu? _commandeApercuFromJson(dynamic raw) {
  if (raw is! Map) return null;
  final m = raw.cast<String, dynamic>();
  final total = m['montant_total'];
  return CommandeApercu(
    reference: m['reference'] as String?,
    montantTotal: total is num
        ? total.toDouble()
        : (total is String ? double.tryParse(total) : null),
    buyerId: m['buyer_id'] as String?,
  );
}

Map<String, dynamic>? _commandeApercuToJson(CommandeApercu? c) {
  if (c == null) return null;
  return {
    if (c.reference != null) 'reference': c.reference,
    if (c.montantTotal != null) 'montant_total': c.montantTotal,
    if (c.buyerId != null) 'buyer_id': c.buyerId,
  };
}

/// Route déclarée par un transporteur (zone d'origine → zone destination
/// avec tarif au kg + tarif minimum + capacité maximale).
@freezed
class TransporterRoute with _$TransporterRoute {
  const factory TransporterRoute({
    required String id,
    required String transporterId,
    @JsonKey(name: 'origin_zone') required String origineZone,
    @JsonKey(name: 'destination_zone') required String destinationZone,
    @FlexDouble() required double capaciteMaxKg,
    @FlexDouble() required double tarifKg,
    @FlexDouble() @Default(0) double tarifMinimum,
    String? delaiTypique,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _TransporterRoute;

  factory TransporterRoute.fromJson(Map<String, dynamic> json) =>
      _$TransporterRouteFromJson(json);
}

/// Réponse de l'endpoint `GET /logistics/quotes` : pour une zone +
/// quantité donnée, le back renvoie les meilleures offres triées par
/// prix croissant.
@freezed
class TransportQuote with _$TransportQuote {
  const factory TransportQuote({
    required String routeId,
    required String transporterId,
    @Default('') String transporterName,
    @FlexDouble() @Default(0) double rating,
    @FlexDouble() required double tarifTotal,
    String? delaiTypique,
  }) = _TransportQuote;

  factory TransportQuote.fromJson(Map<String, dynamic> json) =>
      _$TransportQuoteFromJson(json);
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
    String? note,
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
