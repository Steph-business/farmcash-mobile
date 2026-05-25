import '../../../../models/enums.dart';

/// Libellé court d'un [ProductStatus] pour la chip statut de la page détail
/// d'une annonce producteur.
String annonceDetailStatusLabel(ProductStatus s) {
  switch (s) {
    case ProductStatus.active:
      return 'Active';
    case ProductStatus.paused:
      return 'En pause';
    case ProductStatus.sold:
      return 'Vendue';
    case ProductStatus.draft:
      return 'Brouillon';
    case ProductStatus.expired:
      return 'Expirée';
    case ProductStatus.unknown:
      return 'Active';
  }
}

/// Libellé court d'une [ProductQuality]. Retourne `null` si la qualité est
/// inconnue pour qu'on n'affiche pas une ligne vide dans les caractéristiques.
String? annonceDetailQualiteLabel(ProductQuality q) {
  switch (q) {
    case ProductQuality.standard:
      return 'Standard';
    case ProductQuality.premium:
      return 'Premium';
    case ProductQuality.bio:
      return 'Bio';
    case ProductQuality.equitable:
      return 'Équitable';
    case ProductQuality.unknown:
      return null;
  }
}

/// Libellé d'un [NegotiationStatus] pour la ligne « acheteur intéressé »
/// de la page détail d'une annonce producteur.
String annonceDetailNegotiationStatusLabel(NegotiationStatus s) {
  switch (s) {
    case NegotiationStatus.pending:
      return 'En attente';
    case NegotiationStatus.accepted:
      return 'Accepté';
    case NegotiationStatus.rejected:
      return 'Refusé';
    case NegotiationStatus.counterOffered:
      return 'Contre-offre';
    case NegotiationStatus.cancelled:
      return 'Annulé';
    case NegotiationStatus.unknown:
      return '—';
  }
}
