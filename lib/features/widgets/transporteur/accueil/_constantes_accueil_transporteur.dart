import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../models/portefeuille.dart';
// `TransporterRoute` provient de `models/livraison.dart`. L'import
// `enums.dart` est conservé pour [ShipmentStatus] utilisé dans les
// getters de `AccueilTransporteurData`.

// ─── COULEURS LOCALES (alignées sur la page producteur) ──────────────────

/// Vert très pâle utilisé pour les badges "Actif" et l'icone-tile des
/// itinéraires (équivalent du `_kPrimarySoft` de la page producteur).
const Color kPrimarySoftTransporteur = Color(0xFFE8F5E9);

// Radius des cards de cette page (14 — acceptable par DESIGN.md pour cette
// page d'accueil avec photos, sauf CTA hero qui est en 16).
const BorderRadius kBrCardTransporteur = BorderRadius.all(Radius.circular(14));
const BorderRadius kBrHeroTransporteur = BorderRadius.all(Radius.circular(16));

// Photos statiques pour les "Outils intelligents" (Unsplash — pas du mock
// data fonctionnel, c'est juste de l'illustration neutre comme demandé).
const String kPhotoAssistantRouteTransporteur =
    'https://images.unsplash.com/photo-1601379329542-31c59a99f1c1?w=400&h=300&fit=crop&auto=format';
const String kPhotoOptimisationTransporteur =
    'https://images.unsplash.com/photo-1494412519320-aa613dfb7738?w=400&h=300&fit=crop&auto=format';

/// Bundle de données chargées en parallèle pour l'accueil transporteur.
///
/// Chaque appel est tolérant : un service en échec retourne `null`/liste
/// vide et les sections concernées sont masquées (graceful degradation).
class AccueilTransporteurData {
  final Portefeuille? wallet;
  final List<Livraison> mesShipments;
  final List<Livraison> disponibles;
  final List<TransporterRoute> routes;

  const AccueilTransporteurData({
    required this.wallet,
    required this.mesShipments,
    required this.disponibles,
    required this.routes,
  });

  /// Mission en cours actuellement (status LOADING ou IN_TRANSIT) parmi
  /// les shipments acceptés par le transporteur.
  Livraison? get missionActive {
    for (final m in mesShipments) {
      if (m.status == ShipmentStatus.loading ||
          m.status == ShipmentStatus.inTransit) {
        return m;
      }
    }
    return null;
  }

  /// Missions ouvertes à acceptation — toujours fournies par l'endpoint
  /// `getAvailableMissions` (statut REQUESTED matchant les routes).
  List<Livraison> get missionsDisponibles => disponibles;

  /// Prochains chargements : missions déjà acceptées par le transporteur
  /// mais pas encore en LOADING/IN_TRANSIT.
  List<Livraison> get prochainsChargements => [
        for (final m in mesShipments)
          if (m.status == ShipmentStatus.accepted) m,
      ];

  int get nbLivrees =>
      mesShipments.where((m) => m.status == ShipmentStatus.delivered).length;

  bool get isEmpty =>
      missionActive == null &&
      missionsDisponibles.isEmpty &&
      prochainsChargements.isEmpty;
}

// ─── HELPERS DE FORMATAGE ────────────────────────────────────────────────

/// Formate `12500` → `12 500 F` (devise XOF uniquement, sinon le code).
String formatMontantTransporteur(double montant, String devise) {
  final formatted = NumberFormat('#,##0', 'fr_FR').format(montant);
  if (devise == 'XOF' || devise.isEmpty) {
    return '$formatted F';
  }
  return '$formatted $devise';
}

/// Formate le prix d'une mission (peut être null).
String formatPrixMission(double? prix) {
  if (prix == null || prix <= 0) return '—';
  return '${NumberFormat('#,##0', 'fr_FR').format(prix)} F';
}

/// `origine → destination` à partir d'une [Livraison]. Préfère
/// `origine_zone`/`destination_zone` (libellés courts du back) et
/// retombe sur l'adresse pickup/delivery sinon.
String formatRouteMission(Livraison m) {
  final itin = m.itineraireLabel;
  if (itin != null && itin.isNotEmpty) return itin;
  final origine = (m.pickupAddress ?? '').trim();
  final dest = (m.deliveryAddress ?? '').trim();
  if (origine.isEmpty && dest.isEmpty) return 'Trajet';
  if (origine.isEmpty) return dest;
  if (dest.isEmpty) return origine;
  return '$origine → $dest';
}

/// Ligne meta d'une mission : aujourd'hui on n'expose ni la quantité ni le
/// produit sur la `Livraison`. On affiche donc l'horaire planifié quand on
/// l'a, sinon `null` (la ligne est alors masquée).
String? formatMetaMission(Livraison m) {
  final dt = m.scheduledAt;
  if (dt == null) return null;
  final local = dt.toLocal();
  final now = DateTime.now();
  final isToday = local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  final isTomorrow = local.year == now.year &&
      local.month == now.month &&
      local.day == now.day + 1;
  final heure = DateFormat('HH:mm', 'fr_FR').format(local);
  if (isToday) return 'Aujourd\'hui $heure';
  if (isTomorrow) return 'Demain $heure';
  return DateFormat('d MMM HH:mm', 'fr_FR').format(local);
}

/// Affichage du trajet d'une route déclarée. Le backend renvoie les zones
/// sous forme de noms lisibles (« Bouaké », « Abidjan »).
String formatTrajetItineraire(TransporterRoute r, int index) {
  final origine = r.origineZone.trim();
  final dest = r.destinationZone.trim();
  if (origine.isEmpty && dest.isEmpty) {
    return 'Itinéraire ${index + 1}';
  }
  return '$origine → $dest';
}
