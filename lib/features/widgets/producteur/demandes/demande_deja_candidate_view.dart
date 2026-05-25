import 'package:flutter/material.dart';

import '../../../../models/annonce_achat.dart';
import '../../../../models/enums.dart';
import '../../../../models/negociation.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'demande_recap_card.dart';
import 'demande_repondre_header.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Vue alternative quand le FARMER a déjà une proposition active sur
/// cette demande.
///
/// Affiche la récap de la demande + un panneau explicatif avec deux
/// actions : voir mes offres OU revenir en arrière. Évite le 409 backend
/// qui était confus pour l'utilisateur.
class DemandeDejaCandidateView extends StatelessWidget {
  const DemandeDejaCandidateView({
    required this.demande,
    required this.proposition,
    super.key,
  });

  final AnnonceAchat demande;
  final Proposition proposition;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DemandeRepondreHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              DemandeRecapCard(demande: demande),
              AppDimens.vGap24,
              // Bannière info — pas une erreur car le user n'a rien
              // fait de mal. Couleur _kPrimarySoft (vert pâle).
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tu as déjà candidaté',
                            style: AppTextStyles.titleSmall.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ta proposition est en cours d\'examen par '
                            'l\'acheteur. Tu peux la retrouver et la '
                            'modifier depuis "Mes offres".',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                          AppDimens.vGap8,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.border,
                                width: AppDimens.borderThin,
                              ),
                            ),
                            child: Text(
                              _statusLabel(proposition.status),
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppDimens.vGap16,
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO(offres-route): pousser vers la page "Offres
                    // reçues" du producteur ; le router actuel n'expose
                    // pas encore une route directe → on pop simplement.
                  },
                  child: Text(
                    'Voir mes offres',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              AppDimens.vGap8,
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Retour',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _statusLabel(NegotiationStatus s) {
    switch (s) {
      case NegotiationStatus.pending:
        return 'En attente de réponse';
      case NegotiationStatus.counterOffered:
        return 'Contre-offre reçue';
      case NegotiationStatus.accepted:
        return 'Acceptée';
      case NegotiationStatus.rejected:
        return 'Refusée';
      case NegotiationStatus.cancelled:
        return 'Annulée';
      case NegotiationStatus.unknown:
        return 'Statut inconnu';
    }
  }
}
