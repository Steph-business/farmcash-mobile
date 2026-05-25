import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/commande.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/section_titre.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Section « Montants » de la page détail commande côté acheteur. Affiche
/// le total payé, la décomposition (qté × prix unitaire) et le statut
/// escrow textuel (« Bloqué en escrow » ou « Libéré au vendeur »).
///
/// Carte sur fond pastel vert + icône cadenas/cadenas-ouvert pour
/// signaler visuellement l'état escrow sans avoir à lire le statut.
class SectionMontants extends StatelessWidget {
  const SectionMontants({
    required this.commande,
    super.key,
  });

  final Commande commande;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final total = nf.format(commande.montantTotal.round());
    final qte = nf.format(commande.quantiteKg.round());
    final prixUnit = nf.format(commande.prixUnitaireKg.round());
    final statut = commande.escrowReleased
        ? 'Libéré au vendeur'
        : 'Bloqué en escrow · libéré à la confirmation de réception';
    return SectionTitre(
      titre: 'Montants',
      child: Container(
        decoration: BoxDecoration(
          color: _kPrimarySoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                commande.escrowReleased
                    ? Icons.lock_open_outlined
                    : Icons.lock_outline,
                size: 16,
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
                    'Total : $total F',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$qte kg × $prixUnit F/kg',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statut,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: AppColors.text,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
