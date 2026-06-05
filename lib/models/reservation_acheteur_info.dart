/// Réservation faite par un ACHETEUR sur une prévision donnée — vue
/// côté FARMER propriétaire.
///
/// Modèle distinct de [Reservation] (qui n'a pas les infos buyer
/// jointes et utilise une signature différente). Parsé manuellement
/// (sans freezed) pour rester léger — c'est consommé à un seul endroit
/// (page détail prévision) et le contrat backend est stable.
class ReservationAcheteurInfo {
  final String id;
  final String previsionId;
  final String acheteurId;
  final double quantiteKg;
  final double? prixReserveKg;

  /// PENDING | CONFIRMED | CANCELLED — laissé en String pour souplesse.
  final String status;
  final DateTime? createdAt;

  /// Nom complet de l'acheteur (joint backend). `null` si la jointure
  /// n'a pas été demandée ou si l'utilisateur a été supprimé.
  final String? acheteurNom;
  final String? acheteurPhotoUrl;

  const ReservationAcheteurInfo({
    required this.id,
    required this.previsionId,
    required this.acheteurId,
    required this.quantiteKg,
    this.prixReserveKg,
    required this.status,
    this.createdAt,
    this.acheteurNom,
    this.acheteurPhotoUrl,
  });

  factory ReservationAcheteurInfo.fromJson(Map<String, dynamic> json) {
    final users = json['users'] is Map
        ? (json['users'] as Map).cast<String, dynamic>()
        : null;
    return ReservationAcheteurInfo(
      id: json['id'] as String,
      previsionId: json['prevision_id'] as String,
      acheteurId: json['acheteur_id'] as String,
      quantiteKg: (json['quantite_kg'] as num).toDouble(),
      prixReserveKg: json['prix_reserve_kg'] is num
          ? (json['prix_reserve_kg'] as num).toDouble()
          : null,
      status: (json['status'] as String?) ?? 'PENDING',
      createdAt: json['created_at'] is String
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      acheteurNom: users?['full_name'] as String?,
      acheteurPhotoUrl: users?['photo_url'] as String?,
    );
  }
}
