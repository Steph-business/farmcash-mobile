/// Détail enrichi d'une sollicitation côté UI.
///
/// Le backend renvoie un payload Map complexe (annonce + cooperative +
/// recipients + responses_summary). On extrait ce qui sert au récap
/// card de la page de réponse producteur.
class SollicitationDetail {
  const SollicitationDetail({
    required this.coopNom,
    required this.coopLogoUrl,
    required this.produitNom,
    required this.produitThumb,
    required this.quantiteKg,
    required this.prixMinKg,
    required this.expiresAt,
    required this.message,
  });

  final String coopNom;
  final String? coopLogoUrl;
  final String produitNom;
  final String? produitThumb;
  final double? quantiteKg;
  final double? prixMinKg;
  final DateTime? expiresAt;
  final String? message;
}
