import '../../../../models/enums.dart';

/// Convertit une [ProductQuality] en libellé court en français pour
/// l'affichage UI (pesée, hero card livraison, …). `unknown` est traité
/// comme « Standard ».
String libelleQualiteProduit(ProductQuality q) {
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
      return 'Standard';
  }
}
