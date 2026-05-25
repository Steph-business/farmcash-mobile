import 'package:flutter/material.dart';

/// Types de documents proposes a l'upload KYC. `apiValue` est le string
/// attendu cote backend dans le champ `doc_type`.
enum KycDocTypeKyc {
  cniRecto('CNI_RECTO', 'CNI — Recto', Icons.badge_outlined),
  cniVerso('CNI_VERSO', 'CNI — Verso', Icons.badge_outlined),
  selfie('SELFIE', 'Selfie', Icons.face_outlined),
  carteProducteur(
    'CARTE_PRODUCTEUR',
    'Carte producteur',
    Icons.card_membership,
  ),
  justificatifParcelle(
    'JUSTIFICATIF_PARCELLE',
    'Justificatif de parcelle',
    Icons.landscape_outlined,
  );

  const KycDocTypeKyc(this.apiValue, this.label, this.icon);
  final String apiValue;
  final String label;
  final IconData icon;

  /// Map inverse : convertit la valeur API serveur en type local
  /// (`null` si non reconnu — typiquement type futur non encore supporte).
  static KycDocTypeKyc? fromApi(String raw) {
    for (final t in values) {
      if (t.apiValue == raw) return t;
    }
    return null;
  }
}

/// Vert pale utilise en surface (vignette icone, ajout, message info).
const Color kPrimarySoftKyc = Color(0xFFE8F5E9);
