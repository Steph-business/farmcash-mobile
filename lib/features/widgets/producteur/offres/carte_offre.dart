import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'chip_statut_offre.dart';
import 'offre_modeles.dart';

/// Carte d'une offre côté FARMER — type + quantité + prix + total + date
/// + statut. Tap → page discussion (l'utilisateur y trouve : le contexte,
/// la conversation, les boutons Accepter / Refuser / Annuler).
///
/// Refonte 2026-06-04 : on a retiré les boutons Accepter/Refuser inline
/// (ils sont maintenant dans la page discussion). La carte devient un
/// **preview tappable** qui ouvre toujours la discussion — UX cohérente
/// avec l'acheteur (qui a aussi un détail séparé).
class CarteOffre extends StatelessWidget {
  const CarteOffre({super.key, required this.offre});

  final OffreUnifiee offre;

  @override
  Widget build(BuildContext context) {
    final qte = '${nfOffres.format(offre.quantiteKg.round())} kg';
    final prix = '${nfOffres.format(offre.prixProposeKg.round())} F/kg';
    final df = DateFormat('d MMM', 'fr_FR');
    final dateLabel =
        offre.createdAt != null ? df.format(offre.createdAt!) : '—';
    final montantTotal = '${nfOffres.format(
      (offre.quantiteKg * offre.prixProposeKg).round(),
    )} F';
    final isCandidature = offre.kind == OffreKind.candidature;
    final kindLabel = isCandidature
        ? "Candidature d'un acheteur"
        : 'Ma proposition à un acheteur';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _ouvrirDiscussion(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête : icône kind + label + chip statut
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kPrimarySoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isCandidature
                            ? Icons.call_received_rounded
                            : Icons.call_made_rounded,
                        size: 19,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            kindLabel,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$qte · $prix',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ChipStatutOffre(status: offre.status),
                  ],
                ),
                const SizedBox(height: 12),
                // Bandeau total + date
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Total estimé',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        montantTotal,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Message libre (preview 1 ligne)
                if (offre.message != null &&
                    offre.message!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '« ${offre.message!.trim()} »',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AppColors.textSubtle,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSubtle,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Ouvrir la discussion',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _ouvrirDiscussion(BuildContext context) {
    final kind = offre.kind == OffreKind.candidature ? 'cand' : 'prop';
    context.push(
      RouteNames.producteurOffreDiscussionPathFor(offre.id, kind: kind),
      extra: offre,
    );
  }
}
