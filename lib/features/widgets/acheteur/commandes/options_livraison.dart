import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Choix entre livraison auto (recommandée) et choix manuel du
/// transporteur. Mode exposé via [ModeLivraisonPaiement] consommé par la
/// page paiement pour router vers la liste des transporteurs.
enum ModeLivraisonPaiement { auto, choisir }

/// Bloc « Mode de livraison » : 2 cartes empilées (auto vs choisir),
/// avec radio à gauche et badge « Recommandé » sur la première.
class OptionsLivraison extends StatelessWidget {
  const OptionsLivraison({
    required this.selection,
    required this.onChange,
    super.key,
  });

  final ModeLivraisonPaiement selection;
  final ValueChanged<ModeLivraisonPaiement> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OptionLivraison(
          selectionnee: selection == ModeLivraisonPaiement.auto,
          titre: 'Trouvé automatiquement par FarmCash',
          badge: 'Recommandé',
          sousTitre:
              'Prix fixe · ETA 1-2j · Le 1er transporteur dispo prend',
          onTap: () => onChange(ModeLivraisonPaiement.auto),
        ),
        const SizedBox(height: 8),
        OptionLivraison(
          selectionnee: selection == ModeLivraisonPaiement.choisir,
          titre: 'Choisir mon transporteur',
          badge: null,
          sousTitre: 'Compare les transporteurs dispos dans ta zone',
          onTap: () => onChange(ModeLivraisonPaiement.choisir),
        ),
      ],
    );
  }
}

/// Une option (radio button + titre + badge optionnel + sous-titre).
class OptionLivraison extends StatelessWidget {
  const OptionLivraison({
    required this.selectionnee,
    required this.titre,
    required this.sousTitre,
    required this.onTap,
    this.badge,
    super.key,
  });

  final bool selectionnee;
  final String titre;
  final String sousTitre;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selectionnee ? _kPrimarySoft : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectionnee ? AppColors.primary : AppColors.borderStrong,
            width: selectionnee ? 1.5 : AppDimens.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectionnee
                      ? AppColors.primary
                      : AppColors.borderStrong,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: selectionnee
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        titre,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
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
