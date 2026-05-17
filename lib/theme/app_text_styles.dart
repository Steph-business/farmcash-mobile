// =====================================================================
//  AppTextStyles — Typographie FarmCash (alignée DESIGN.md)
//  ---------------------------------------------------------------------
//  Deux polices SEULEMENT, chargées via google_fonts :
//
//   • Poppins  → titres et marque uniquement (display, headline, title)
//   • Inter    → corps, labels, boutons, liens, captions
//
//  Letter-spacing négatif sur les gros titres pour la sobriété.
//  Pas de styles "métier" ornementaux (priceLarge, badge…). Les
//  composants applicatifs composent eux-mêmes leurs styles à partir
//  de la base.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ───────────────────────────────────────────────────────────────────
  //  Helpers internes
  // ───────────────────────────────────────────────────────────────────
  static TextStyle _poppins({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.text,
    );
  }

  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.text,
    );
  }

  // ───────────────────────────────────────────────────────────────────
  //  POPPINS — titres & marque
  // ───────────────────────────────────────────────────────────────────
  // Display : très rares (splash, onboarding hero)
  static TextStyle get displayLarge => _poppins(
        fontSize: 28, fontWeight: FontWeight.w700,
        height: 1.2, letterSpacing: -0.5,
      );
  static TextStyle get displayMedium => _poppins(
        fontSize: 26, fontWeight: FontWeight.w700,
        height: 1.2, letterSpacing: -0.5,
      );
  static TextStyle get displaySmall => _poppins(
        fontSize: 24, fontWeight: FontWeight.w700,
        height: 1.25, letterSpacing: -0.4,
      );

  // Headline : titres de page (H1) et sections (H2)
  static TextStyle get headlineLarge => _poppins(
        fontSize: 22, fontWeight: FontWeight.w700,
        height: 1.3, letterSpacing: -0.3,
      );
  static TextStyle get headlineMedium => _poppins(
        fontSize: 20, fontWeight: FontWeight.w600,
        height: 1.3, letterSpacing: -0.3,
      );
  static TextStyle get headlineSmall => _poppins(
        fontSize: 18, fontWeight: FontWeight.w600,
        height: 1.35, letterSpacing: -0.2,
      );

  // Title : app bar, cards (titre principal d'un bloc)
  static TextStyle get titleLarge => _poppins(
        fontSize: 18, fontWeight: FontWeight.w600,
        height: 1.4, letterSpacing: -0.2,
      );

  // ───────────────────────────────────────────────────────────────────
  //  INTER — corps, labels, boutons, liens, captions
  // ───────────────────────────────────────────────────────────────────
  // Title (mini) : intra-card, list item
  static TextStyle get titleMedium => _inter(
        fontSize: 15, fontWeight: FontWeight.w600,
        height: 1.4,
      );
  static TextStyle get titleSmall => _inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // Body : texte courant
  static TextStyle get bodyLarge => _inter(
        fontSize: 15, fontWeight: FontWeight.w400,
        height: 1.5,
      );
  static TextStyle get bodyMedium => _inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        height: 1.5,
      );
  static TextStyle get bodySmall => _inter(
        fontSize: 12, fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  // Label : labels de champs, boutons, liens
  static TextStyle get labelLarge => _inter(
        fontSize: 15, fontWeight: FontWeight.w600,
        height: 1.4,
      ); // utilisé pour les boutons primaires
  static TextStyle get labelMedium => _inter(
        fontSize: 13, fontWeight: FontWeight.w500,
        height: 1.4,
      ); // labels au-dessus des champs
  static TextStyle get labelSmall => _inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.textSecondary,
      ); // légal, captions

  // ───────────────────────────────────────────────────────────────────
  //  Spécialisés (sobres)
  // ───────────────────────────────────────────────────────────────────
  static TextStyle get hint => _inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textSubtle,
      );

  static TextStyle get link => _inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.primary,
      ); // pas de soulignement par défaut (DESIGN.md)

  static TextStyle get errorText => _inter(
        fontSize: 12, fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.error,
      );

  static TextStyle get button => _inter(
        fontSize: 15, fontWeight: FontWeight.w600,
        height: 1.25,
      );

  // ───────────────────────────────────────────────────────────────────
  //  TextTheme assemblé pour ThemeData
  // ───────────────────────────────────────────────────────────────────
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );

  static TextTheme get textThemeDark => TextTheme(
        displayLarge: displayLarge.copyWith(color: AppColors.textDark),
        displayMedium: displayMedium.copyWith(color: AppColors.textDark),
        displaySmall: displaySmall.copyWith(color: AppColors.textDark),
        headlineLarge: headlineLarge.copyWith(color: AppColors.textDark),
        headlineMedium: headlineMedium.copyWith(color: AppColors.textDark),
        headlineSmall: headlineSmall.copyWith(color: AppColors.textDark),
        titleLarge: titleLarge.copyWith(color: AppColors.textDark),
        titleMedium: titleMedium.copyWith(color: AppColors.textDark),
        titleSmall: titleSmall.copyWith(color: AppColors.textDark),
        bodyLarge: bodyLarge.copyWith(color: AppColors.textDark),
        bodyMedium: bodyMedium.copyWith(color: AppColors.textDark),
        bodySmall: bodySmall.copyWith(color: AppColors.textSecondaryDark),
        labelLarge: labelLarge.copyWith(color: AppColors.textDark),
        labelMedium: labelMedium.copyWith(color: AppColors.textDark),
        labelSmall: labelSmall.copyWith(color: AppColors.textSecondaryDark),
      );
}
