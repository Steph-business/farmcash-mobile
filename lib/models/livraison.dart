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

    /// Champ joint `users` (le transporteur assigné) quand le backend
    /// l'expose — notamment `GET /shipments/by-commande/:id`. Permet
    /// d'afficher nom + photo + rating sans appel supplémentaire.
    @JsonKey(
      name: 'users',
      fromJson: _transporterApercuFromJson,
      toJson: _transporterApercuToJson,
    )
    TransporterApercu? transporter,
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

  // ─── Raccourcis vers les infos transporteur jointes ─────────────────

  String? get transporterName => transporter?.fullName;
  String? get transporterPhone => transporter?.phone;
  String? get transporterPhotoUrl => transporter?.photoUrl;
  double? get transporterRating => transporter?.rating;
  int? get transporterRatingCount => transporter?.ratingCount;
  String? get vehiclePlaque => transporter?.vehicle?.immatriculation;
  String? get vehicleMarque => transporter?.vehicle?.marque;

  /// Label affichable du véhicule. On préfère « Marque + Type » (ex.
  /// « Renault — Camion 10t ») si la marque est jointe, sinon on retombe
  /// sur le `vehicle_type` brut du shipment, sinon le type du véhicule.
  String? get vehiculeLabel {
    final marque = transporter?.vehicle?.marque?.trim();
    final typeV = transporter?.vehicle?.type?.trim();
    final fallbackType = vehicleType?.trim();
    if (marque != null && marque.isNotEmpty) {
      if (typeV != null && typeV.isNotEmpty) return '$marque · $typeV';
      return marque;
    }
    if (typeV != null && typeV.isNotEmpty) return typeV;
    if (fallbackType != null && fallbackType.isNotEmpty) return fallbackType;
    return null;
  }
}

/// Sous-objet joint à un shipment : informations minimales sur le
/// transporteur assigné. Le `vehicle` est le 1er véhicule actif du
/// transporteur (cf. service backend).
class TransporterApercu {
  const TransporterApercu({
    this.id,
    this.fullName,
    this.phone,
    this.photoUrl,
    this.rating,
    this.ratingCount,
    this.vehicle,
  });

  final String? id;
  final String? fullName;

  /// Téléphone du chauffeur — utilisé pour le bouton « Appeler » qui
  /// déclenche `tel:` via `url_launcher`. Peut être null en dev / si le
  /// transporteur n'a pas renseigné son numéro.
  final String? phone;
  final String? photoUrl;
  final double? rating;
  final int? ratingCount;
  final VehiculeApercu? vehicle;
}

/// Snapshot d'un véhicule joint au transporteur. Pas tous les champs sont
/// exposés — juste ce qu'on affiche sur la carte tracking.
class VehiculeApercu {
  const VehiculeApercu({
    this.id,
    this.type,
    this.immatriculation,
    this.marque,
  });

  final String? id;
  final String? type;
  final String? immatriculation;
  final String? marque;
}

TransporterApercu? _transporterApercuFromJson(dynamic raw) {
  if (raw is! Map) return null;
  final m = raw.cast<String, dynamic>();
  // `vehicles` est joint via `users.vehicles { take: 1, where: is_active }`
  // côté backend — donc c'est toujours un array de 0 ou 1 élément.
  VehiculeApercu? vehicle;
  final vehicles = m['vehicles'];
  if (vehicles is List && vehicles.isNotEmpty) {
    final v = vehicles.first;
    if (v is Map) {
      final mv = v.cast<String, dynamic>();
      vehicle = VehiculeApercu(
        id: mv['id'] as String?,
        type: mv['type'] as String?,
        immatriculation: mv['immatriculation'] as String?,
        marque: mv['marque'] as String?,
      );
    }
  }
  final rating = m['rating'];
  final ratingCount = m['rating_count'];
  return TransporterApercu(
    id: m['id'] as String?,
    fullName: m['full_name'] as String?,
    phone: m['phone'] as String?,
    photoUrl: m['photo_url'] as String?,
    rating: rating is num
        ? rating.toDouble()
        : (rating is String ? double.tryParse(rating) : null),
    ratingCount: ratingCount is num
        ? ratingCount.toInt()
        : (ratingCount is String ? int.tryParse(ratingCount) : null),
    vehicle: vehicle,
  );
}

Map<String, dynamic>? _transporterApercuToJson(TransporterApercu? t) {
  if (t == null) return null;
  return {
    if (t.id != null) 'id': t.id,
    if (t.fullName != null) 'full_name': t.fullName,
    if (t.phone != null) 'phone': t.phone,
    if (t.photoUrl != null) 'photo_url': t.photoUrl,
    if (t.rating != null) 'rating': t.rating,
    if (t.ratingCount != null) 'rating_count': t.ratingCount,
    if (t.vehicle != null)
      'vehicles': [
        {
          if (t.vehicle!.id != null) 'id': t.vehicle!.id,
          if (t.vehicle!.type != null) 'type': t.vehicle!.type,
          if (t.vehicle!.immatriculation != null)
            'immatriculation': t.vehicle!.immatriculation,
          if (t.vehicle!.marque != null) 'marque': t.vehicle!.marque,
        }
      ],
  };
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
