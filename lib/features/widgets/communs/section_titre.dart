import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Section générique « titre (en capitales) + contenu » utilisée dans les
/// pages de détail (commande, parcelle, etc.). Deux variantes selon le
/// contexte d'affichage :
///
/// - [encadre]=false (défaut) : style « flat », séparateur en bas, pas de
///   fond. À utiliser quand la page empile plusieurs sections les unes
///   au-dessus des autres sur un fond blanc.
/// - [encadre]=true : style « carte », bordure arrondie + fond blanc + pad
///   intérieur. À utiliser sur les pages dont le scaffold a un fond gris
///   doux ([AppColors.surfaceSoft]) — chaque section devient une carte.
class SectionTitre extends StatelessWidget {
  const SectionTitre({
    required this.titre,
    required this.child,
    this.encadre = false,
    super.key,
  });

  /// Titre affiché en capitales au-dessus du contenu.
  final String titre;

  /// Contenu de la section (texte, sous-cards, listes, etc.).
  final Widget child;

  /// `true` → variante carte (border + radius + bg blanc).
  /// `false` → variante flat (juste un séparateur en bas).
  final bool encadre;

  @override
  Widget build(BuildContext context) {
    if (encadre) {
      // Variante carte : utilisée sur fond surfaceSoft, chaque section
      // est un bloc autonome.
      // Titre vide → section sans en-tête (compact, juste la carte).
      // Utile pour les sections où le contenu est déjà auto-explicatif
      // (acheteur avec photo + nom, par exemple).
      final hasTitle = titre.trim().isNotEmpty;
      return Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasTitle) ...[
              Text(
                titre.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      );
    }
    // Variante flat : utilisée sur les pages avec fond blanc, sections
    // séparées par un trait en bas (style listing vertical sans carte).
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titre.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
