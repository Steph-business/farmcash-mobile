import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';

/// Vert pâle pour fonds des chips/labels positifs (qualité, certifications,
/// "production naturelle"…) sur la page détail annonce acheteur.
const Color kAnnonceDetailPrimarySoft = Color(0xFFE8F5E9);

/// Jaune doré pour l'étoile de rating dans la section vendeur.
const Color kAnnonceDetailWarn = Color(0xFFF9A825);

/// Formatter numérique partagé par la page et ses widgets (séparateur fr).
final NumberFormat kAnnonceDetailNumFmt = NumberFormat('#,##0', 'fr_FR');

/// Format compact "X kg" basé sur le formatter partagé.
String formatKgAnnonceDetail(double kg) =>
    '${kAnnonceDetailNumFmt.format(kg.round())} kg';

/// Libellé humain pour la qualité d'un produit. Utilisé sur la chip à côté
/// du titre dans `TitleCardAnnonce`.
String qualiteLabelAnnonceDetail(ProductQuality q) {
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
      return '—';
  }
}
