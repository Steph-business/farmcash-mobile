import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'modele_sollicitation_suivi_coop.dart';
import 'progress_card_suivi_sollicitation_coop.dart';
import 'recap_card_suivi_sollicitation_coop.dart';
import 'reply_tile_suivi_sollicitation_coop.dart';
import 'section_title_suivi_sollicitation_coop.dart';

/// Corps scrollable de la page suivi sollicitation coopérative : enchaîne
/// le récap produit/statut, la barre de progression du remplissage et la
/// liste des réponses fournisseurs (ou un vide-message).
class BodySuiviSollicitationCoop extends StatelessWidget {
  const BodySuiviSollicitationCoop({
    required this.detail,
    required this.sollicitationId,
    super.key,
  });

  final SollicitationDetailCoop detail;
  final String sollicitationId;

  @override
  Widget build(BuildContext context) {
    final replies = detail.replies;
    final cible = detail.quantiteCibleKg ?? 0;
    final offerte = detail.quantiteOfferteKg;
    final pct = (cible > 0) ? (offerte / cible).clamp(0.0, 1.0) : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        const SectionTitleSuiviSollicitationCoop(title: 'Récap'),
        AppDimens.vGap12,
        RecapCardSuiviSollicitationCoop(
          produit: detail.produitNom ?? 'Produit',
          quantiteCibleKg: cible,
          totalRecipients: detail.totalRecipients,
          status: detail.status,
        ),
        AppDimens.vGap24,
        const SectionTitleSuiviSollicitationCoop(
          title: 'Progression du remplissage',
        ),
        AppDimens.vGap12,
        ProgressCardSuiviSollicitationCoop(
          quantiteOfferteKg: offerte,
          quantiteCibleKg: cible,
          pct: pct,
        ),
        AppDimens.vGap24,
        SectionTitleSuiviSollicitationCoop(
          title: 'Réponses reçues (${replies.length})',
        ),
        AppDimens.vGap12,
        if (replies.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Aucune réponse pour le moment.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          for (final r in replies) ...[
            ReplyTileSuiviSollicitationCoop(
              reply: r,
              sollicitationId: sollicitationId,
            ),
            AppDimens.vGap8,
          ],
      ],
    );
  }
}
