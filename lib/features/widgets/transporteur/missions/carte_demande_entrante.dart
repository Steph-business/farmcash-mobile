import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));

/// Carte d'une mission disponible dans la liste « Demandes entrantes ».
///
/// Affiche la référence commande, le trajet, la quantité, la date prévue
/// (ou date de publication) et le prix proposé. Au tap, navigue vers le
/// détail de la demande.
class CarteDemandeEntrante extends StatelessWidget {
  const CarteDemandeEntrante({
    required this.mission,
    required this.onTap,
    super.key,
  });

  final Livraison mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final reference = mission.reference ??
        mission.commandeId.substring(0, 8).toUpperCase();
    final trajet = mission.itineraireLabel ?? '—';
    final qte = mission.quantiteKg != null
        ? '${nf.format(mission.quantiteKg!.round())} kg'
        : null;
    final prix = mission.prixDevis ?? mission.prixFinal;
    final prixLabel =
        prix != null ? '+${nf.format(prix.round())} F' : 'à fixer';
    final df = DateFormat('d MMM HH:mm', 'fr_FR');
    final dateLabel = mission.scheduledAt != null
        ? 'Pour ${df.format(mission.scheduledAt!)}'
        : (mission.createdAt != null
            ? 'Publié ${df.format(mission.createdAt!)}'
            : 'À planifier');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: _kBrCard,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _kBrCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _kPrimarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.inbox_outlined,
                      size: 18,
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
                          'Commande #$reference',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          trajet,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (qte != null) ...[
                    const Icon(
                      Icons.scale_outlined,
                      size: 13,
                      color: AppColors.textSubtle,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      qte,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      dateLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ),
                  Text(
                    prixLabel,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
