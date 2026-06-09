import 'package:freezed_annotation/freezed_annotation.dart';

import 'annonce_vente.dart' show mediasToPhotos, photosToMedias;
import 'converters.dart';
import 'enums.dart';
import 'utilisateur.dart';

part 'publication_coop.freezed.dart';
part 'publication_coop.g.dart';

/// Publication agrégée par une coopérative (somme de N annonces de membres).
@freezed
class PublicationCoop with _$PublicationCoop {
  const PublicationCoop._();

  const factory PublicationCoop({
    required String id,
    required String cooperativeId,
    required String produitId,
    required String titre,
    @FlexDouble() required double quantiteKg,
    @FlexDouble() required double prixParKg,
    @JsonKey(unknownEnumValue: ProductQuality.unknown)
    @Default(ProductQuality.unknown)
    ProductQuality qualite,
    String? description,
    @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
    @Default(<String>[])
    List<String> photos,
    @JsonKey(unknownEnumValue: ProductStatus.unknown)
    @Default(ProductStatus.unknown)
    ProductStatus status,
    @Default(0) int nbContributeurs,
    DateTime? createdAt,
    DateTime? updatedAt,

    /// Dates de récolte des annonces du lot agrégé, parsées depuis
    /// `publication_contributions[].annonces_vente.date_recolte`.
    /// Liste plate triée croissant. Vide si le backend ne joint pas ou
    /// si aucune contribution n'a renseigné `date_recolte`.
    /// Utilisée par les getters `dateRecolteMin/Max` ci-dessous pour
    /// afficher « Récolté entre le X et le Y » côté acheteur (signal
    /// de fraîcheur clé pour produits frais).
    @JsonKey(
      name: 'publication_contributions',
      fromJson: _datesRecolteFromContribs,
      toJson: _datesRecolteToJson,
    )
    @Default(<DateTime>[])
    List<DateTime> datesRecolteAnnonces,
  }) = _PublicationCoop;

  factory PublicationCoop.fromJson(Map<String, dynamic> json) =>
      _$PublicationCoopFromJson(json);

  /// Première date de récolte du lot (min). Null si aucune contribution
  /// n'a renseigné `date_recolte`.
  DateTime? get dateRecolteMin =>
      datesRecolteAnnonces.isEmpty ? null : datesRecolteAnnonces.first;

  /// Dernière date de récolte du lot (max). Null si aucune contribution
  /// n'a renseigné `date_recolte`.
  DateTime? get dateRecolteMax =>
      datesRecolteAnnonces.isEmpty ? null : datesRecolteAnnonces.last;
}

/// Extrait + trie les dates de récolte des contributions backend.
/// Le backend renvoie `publication_contributions: [{annonces_vente:
/// {date_recolte: "2026-06-03"}}, ...]`. On flatten + parse + trie.
List<DateTime> _datesRecolteFromContribs(dynamic raw) {
  if (raw is! List) return const [];
  final dates = raw
      .whereType<Map>()
      .map((m) => (m['annonces_vente'] as Map?)?['date_recolte'])
      .map((d) => d is String ? DateTime.tryParse(d) : null)
      .whereType<DateTime>()
      .toList();
  dates.sort();
  return dates;
}

/// Les dates sont calculées côté mobile, jamais ré-envoyées au backend.
List<dynamic> _datesRecolteToJson(List<DateTime> _) => const [];

/// Détail d'un contributeur à une publication coop (qui a apporté quoi
/// dans le lot agrégé). Utilisé pour afficher la composition + la
/// distribution des paiements aux producteurs membres.
///
/// Mapping aligné sur la table `publication_contributions` du backend :
///   - `farmer_id`        — l'user producteur
///   - `annonce_vente_id` — l'annonce source de la contribution
///   - `quantite_kg`      — qté apportée (kg)
///   - `prix_kg`          — prix unitaire de l'annonce source
///   - `part_pct`         — part du lot (0.0 - 1.0)
///   - `paid_amount`/`paid_at` — quand/combien a été versé
///   - jointure `users.full_name` — nom affiché
///
/// Avant 2026-06-05 le mapping freezed était cassé : `userId`/`annonceId`/
/// `partPourcent` ne correspondaient à rien côté backend → le widget
/// recevait null partout. Réécrit en classe manuelle pour parser le
/// shape réel sans dépendre de codegen.
class CoopContribution {
  const CoopContribution({
    required this.id,
    required this.farmerId,
    required this.annonceVenteId,
    required this.quantiteKg,
    required this.prixKg,
    required this.partPct,
    this.paidAmount,
    this.paidAt,
    this.farmerName,
    this.farmerPhone,
    this.annonceTitre,
  });

  final String id;
  final String farmerId;
  final String annonceVenteId;
  final double quantiteKg;
  final double prixKg;

  /// Part du producteur dans le lot total (0.0 - 1.0). 0.4 = 40 %.
  final double partPct;

  /// Montant net déjà versé (null = pas encore distribué).
  final double? paidAmount;

  /// Quand le paiement a été effectué. Null si pas encore distribué.
  final DateTime? paidAt;

  /// Nom du producteur (joint via `users.full_name`).
  final String? farmerName;

  final String? farmerPhone;
  final String? annonceTitre;

  bool get isPaid => paidAt != null;

  factory CoopContribution.fromJson(Map<String, dynamic> json) {
    final users = json['users'];
    final annonces = json['annonces_vente'];
    return CoopContribution(
      id: json['id'] as String? ?? '',
      farmerId: json['farmer_id'] as String? ?? '',
      annonceVenteId: json['annonce_vente_id'] as String? ?? '',
      quantiteKg: _toDouble(json['quantite_kg']),
      prixKg: _toDouble(json['prix_kg']),
      partPct: _toDouble(json['part_pct']),
      paidAmount: json['paid_amount'] != null
          ? _toDouble(json['paid_amount'])
          : null,
      paidAt: json['paid_at'] is String
          ? DateTime.tryParse(json['paid_at'] as String)
          : null,
      farmerName: users is Map ? users['full_name'] as String? : null,
      farmerPhone: users is Map ? users['phone'] as String? : null,
      annonceTitre:
          annonces is Map ? annonces['titre'] as String? : null,
    );
  }
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
