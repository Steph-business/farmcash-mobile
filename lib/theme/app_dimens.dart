// =====================================================================
//  AppDimens — Spacing & sizing (alignée DESIGN.md)
//  ---------------------------------------------------------------------
//  Pas d'ombres ici. Le design FarmCash n'utilise pas d'élévation
//  prononcée : bordure 1px plutôt qu'ombre portée.
//
//  Échelle :
//   • spacing : 4 / 8 / 12 / 16 / 24 / 32 (8pt grid)
//   • radius  : 10 (standard) / 12 (max cards) / 999 (pill)
//   • hauteur : 50 (inputs, boutons)
// =====================================================================

import 'package:flutter/material.dart';

class AppDimens {
  AppDimens._();

  // ───────────────────────────────────────────────────────────────────
  //  SPACING (8pt grid)
  // ───────────────────────────────────────────────────────────────────
  static const double space4 = 4.0;    // gap minimal (icône + texte)
  static const double space8 = 8.0;    // espacement compact
  static const double space12 = 12.0;  // label → input
  static const double space16 = 16.0;  // entre champs (standard)
  static const double space24 = 24.0;  // entre blocs
  static const double space32 = 32.0;  // entre sections
  static const double space48 = 48.0;  // séparation hero / rare

  // Padding horizontal d'une page (24–32px selon densité)
  static const double pagePaddingH = 24.0;

  // ───────────────────────────────────────────────────────────────────
  //  RADIUS
  // ───────────────────────────────────────────────────────────────────
  static const double radiusS = 8.0;    // chips, petits éléments
  static const double radius = 10.0;    // standard : inputs, boutons
  static const double radiusCard = 12.0; // max pour cards
  static const double radiusPill = 999.0; // pilule (rare, ex: badge statut)

  static const BorderRadius brInput =
      BorderRadius.all(Radius.circular(radius));
  static const BorderRadius brButton =
      BorderRadius.all(Radius.circular(radius));
  static const BorderRadius brCard =
      BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius brBottomSheet =
      BorderRadius.vertical(top: Radius.circular(radiusCard));

  // ───────────────────────────────────────────────────────────────────
  //  HAUTEURS COMPOSANTS
  // ───────────────────────────────────────────────────────────────────
  static const double inputHeight = 50.0;
  static const double buttonHeight = 50.0;
  static const double buttonHeightSmall = 40.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 64.0;
  static const double chipHeight = 30.0;
  static const double listItemHeight = 56.0;

  // ───────────────────────────────────────────────────────────────────
  //  ICON SIZE
  // ───────────────────────────────────────────────────────────────────
  static const double iconS = 16.0;
  static const double iconM = 18.0; // taille par défaut UI
  static const double iconL = 22.0; // app bar, nav
  static const double iconXl = 28.0; // hero rare

  // ───────────────────────────────────────────────────────────────────
  //  BORDURES
  // ───────────────────────────────────────────────────────────────────
  static const double borderThin = 1.0;     // standard (inputs, cards)
  static const double borderMedium = 1.5;   // focus accentué si besoin
  static const double borderHairline = 0.5; // divider très fin

  // ───────────────────────────────────────────────────────────────────
  //  BREAKPOINTS (mobile-first)
  // ───────────────────────────────────────────────────────────────────
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 905.0;

  // ───────────────────────────────────────────────────────────────────
  //  ANIMATIONS (transitions discrètes — 150ms max sur composants)
  // ───────────────────────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 200);

  // ───────────────────────────────────────────────────────────────────
  //  EDGE INSETS prêts à l'emploi
  // ───────────────────────────────────────────────────────────────────
  static const EdgeInsets paddingPage = EdgeInsets.symmetric(
    horizontal: pagePaddingH,
    vertical: space16,
  );
  static const EdgeInsets paddingPageH =
      EdgeInsets.symmetric(horizontal: pagePaddingH);
  static const EdgeInsets paddingCard = EdgeInsets.all(space16);
  static const EdgeInsets paddingInput =
      EdgeInsets.symmetric(horizontal: 14, vertical: 0);
  static const EdgeInsets paddingButton =
      EdgeInsets.symmetric(horizontal: space24, vertical: space12);

  // Gaps verticaux prêts à l'emploi
  static const SizedBox vGap4 = SizedBox(height: space4);
  static const SizedBox vGap8 = SizedBox(height: space8);
  static const SizedBox vGap12 = SizedBox(height: space12);
  static const SizedBox vGap16 = SizedBox(height: space16);
  static const SizedBox vGap24 = SizedBox(height: space24);
  static const SizedBox vGap32 = SizedBox(height: space32);

  static const SizedBox hGap4 = SizedBox(width: space4);
  static const SizedBox hGap8 = SizedBox(width: space8);
  static const SizedBox hGap12 = SizedBox(width: space12);
  static const SizedBox hGap16 = SizedBox(width: space16);
}
