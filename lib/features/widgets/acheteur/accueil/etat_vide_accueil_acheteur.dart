import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_acheteur_constants.dart';

/// État vide global de l'accueil acheteur — affiché si on n'a ni
/// catégories, ni annonces, ni demandes (marché complètement vide).
/// Embarque son propre `RefreshIndicator` pour permettre un pull-to-refresh
/// même quand la page n'a aucun contenu scrollable.
class EtatVideAccueilAcheteur extends StatelessWidget {
  const EtatVideAccueilAcheteur({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space48,
          AppDimens.pagePaddingH,
          AppDimens.space24,
        ),
        children: [
          Text(
            'Aucun produit pour le moment',
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap8,
          Text(
            'Le marché est vide. Reviens dans quelques instants.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap24,
          Center(
            child: SizedBox(
              height: AppDimens.buttonHeightSmall,
              child: OutlinedButton(
                onPressed: onRefresh,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                    color: AppColors.borderStrong,
                    width: AppDimens.borderThin,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimens.brButton,
                  ),
                ),
                child: const Text('Actualiser'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// État vide d'une section accueil — versions premium 2026-06-05.
/// Avant : juste un texte centré dans une surface grise (cul-de-sac).
/// Après : icône + titre + texte + CTA actionnable optionnel
/// (« Publier ma demande », « Actualiser », …).
///
/// Si `ctaLabel` et `onCtaTap` sont fournis, un bouton outlined vert
/// apparaît sous le texte. Sinon, fallback sur l'ancien comportement
/// neutre (compat avec les call sites existants).
class EtatVideSectionAccueil extends StatelessWidget {
  const EtatVideSectionAccueil({
    super.key,
    required this.message,
    this.icone,
    this.ctaLabel,
    this.onCtaTap,
  });

  final String message;

  /// Icône optionnelle au-dessus du texte (ex: Icons.storefront_outlined).
  final IconData? icone;

  /// Label du CTA optionnel. Si fourni avec onCtaTap → bouton outlined.
  final String? ctaLabel;
  final VoidCallback? onCtaTap;

  @override
  Widget build(BuildContext context) {
    final hasCta = ctaLabel != null && onCtaTap != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: kAccueilBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icone, size: 26, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasCta) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: AppDimens.buttonHeightSmall,
              child: OutlinedButton(
                onPressed: onCtaTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimens.brButton,
                  ),
                ),
                child: Text(
                  ctaLabel!,
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
