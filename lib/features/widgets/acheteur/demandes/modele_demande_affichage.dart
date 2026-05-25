/// Modèle d'affichage d'une demande d'achat dans la liste « Mes demandes »
/// côté acheteur. Toutes les valeurs sont déjà formatées pour l'UI.
class ModeleDemandeAffichage {
  const ModeleDemandeAffichage({
    required this.id,
    required this.produitNom,
    required this.quantite,
    required this.prixMaxLabel,
    required this.villeLabel,
    required this.propositions,
    required this.publieIlYa,
    required this.photoUrl,
  });

  /// Identifiant technique de la demande (utilisé pour la navigation).
  final String id;

  /// Nom du produit (ex: « Maïs »).
  final String produitNom;

  /// Quantité déjà formatée (ex: « 500 kg »).
  final String quantite;

  /// Libellé du prix max (ex: « max 250 F/kg »).
  final String prixMaxLabel;

  /// Libellé ville/région.
  final String villeLabel;

  /// Nombre de propositions reçues.
  final int propositions;

  /// Libellé temporel (ex: « publiée il y a 2 jours »).
  final String publieIlYa;

  /// URL de l'image vignette du produit.
  final String photoUrl;
}
