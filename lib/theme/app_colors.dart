// =====================================================================
//  AppColors — Palette FarmCash (alignée DESIGN.md)
//  ---------------------------------------------------------------------
//  Palette STRICTE — max 2 couleurs visibles par écran simple.
//  Aucun gradient. Aucun halo. Sobriété fintech.
// =====================================================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ───────────────────────────────────────────────────────────────────
  //  PRIMAIRE — Vert agricole, utilisé avec PARCIMONIE
  //  (bouton primaire, lien, bordure d'input au focus, statut actif)
  // ───────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryHover = Color(0xFF256528);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ───────────────────────────────────────────────────────────────────
  //  TEXTE
  // ───────────────────────────────────────────────────────────────────
  static const Color text = Color(0xFF111827);          // titres, labels, valeurs
  static const Color textSecondary = Color(0xFF6B7280); // sous-titres, helper
  static const Color textSubtle = Color(0xFF9CA3AF);    // placeholder, légal, caption

  // ───────────────────────────────────────────────────────────────────
  //  SURFACES & BORDURES
  // ───────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);    // fond pages
  static const Color surface = Color(0xFFFFFFFF);       // cards
  static const Color surfaceSoft = Color(0xFFF9FAFB);   // zones secondaires (rare)
  static const Color border = Color(0xFFE5E7EB);        // séparateurs, divider
  static const Color borderStrong = Color(0xFFD1D5DB);  // inputs au repos

  // ───────────────────────────────────────────────────────────────────
  //  ÉTATS SÉMANTIQUES
  //  Succès volontairement distinct du vert de marque pour ne pas
  //  confondre "couleur de marque" et "couleur d'état OK".
  // ───────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1B7F3A);
  static const Color error = Color(0xFFC62828);
  static const Color onError = Color(0xFFFFFFFF);

  // ───────────────────────────────────────────────────────────────────
  //  DARK THEME (équivalents)
  // ───────────────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F1115);
  static const Color surfaceDark = Color(0xFF1A1D22);
  static const Color surfaceSoftDark = Color(0xFF22262C);
  static const Color borderDark = Color(0xFF2A2F36);
  static const Color borderStrongDark = Color(0xFF3A4049);
  static const Color textDark = Color(0xFFEDEDED);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textSubtleDark = Color(0xFF7A7F86);
  static const Color primaryDark = Color(0xFF4CAF50); // vert un peu plus clair en dark
}
