/// Aperçu d'un producteur unique dérivé des annonces de vente
/// (groupé par farmerId) pour la section "Producteurs à découvrir" de
/// l'accueil acheteur.
///
/// Distinct du modèle `VendeurApercu` (dans `models/annonce_vente.dart`)
/// qui représente les infos vendeur jointes à une annonce — ici on agrège
/// des annonces, donc on stocke `nbProduits`, `premierProduitNom`, etc.
class ApercuProducteur {
  const ApercuProducteur({
    required this.farmerId,
    required this.regionId,
    required this.nbProduits,
    required this.premierProduitNom,
    this.fullName,
    this.reliabilityScore,
  });

  final String farmerId;
  final String? regionId;
  final int nbProduits;
  final String premierProduitNom;
  final String? fullName;

  /// Score de fiabilité (0-100) hérité de `AnnonceVente.vendeur.reliabilityScore`.
  /// Affiché en % sur la card pour aider l'acheteur à juger la confiance
  /// avant d'acheter.
  final int? reliabilityScore;
}
