import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/prevision.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Carte d'une prévision de récolte dans la grille du marché. Pas de
/// photo (icône calendrier à la place car la prévision n'a souvent pas
/// encore d'image associée), affiche la date prévue + le prix cible
/// (« prévu ») + la quantité prévue.
class CartePrevisionMarche extends StatelessWidget {
  const CartePrevisionMarche({
    required this.prevision,
    required this.nomProduit,
    required this.onTap,
    super.key,
  });

  final Prevision prevision;
  final String nomProduit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final dateStr = prevision.dateRecoltePrev != null
        ? 'Récolte ${DateFormat('d MMM', 'fr_FR').format(prevision.dateRecoltePrev!)}'
        : 'Récolte à venir';
    final prix = prevision.prixCibleKg != null
        ? '${nf.format(prevision.prixCibleKg!.round())} F/kg (prévu)'
        : 'Prix à venir';

    return InkWell(
      onTap: onTap,
      borderRadius: _kBrCard,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: _kBrCard,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 100,
              child: Container(
                color: AppColors.surfaceSoft,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.event_available_outlined,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomProduit,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateStr,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      prix,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${nf.format(prevision.quantitePrevKg.round())} kg prévus',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
