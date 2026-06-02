import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Mini-stepper horizontal — résume visuellement les 4 étapes d'une
/// commande sans le pavé de texte verbeux. Le 1er point (« Payé »)
/// est déjà actif puisqu'on arrive sur cette page après paiement.
///
/// Remplace l'ancienne liste « Et maintenant ? » + 3 grosses tuiles
/// texte (« Le vendeur prépare ton colis », « Le transporteur prend
/// le colis (paiement libéré au vendeur via escrow auto) », etc).
/// Le détail technique reste accessible sur la page « Suivre ma
/// commande » — la confirmation n'a pas besoin de pédagogie.
class ListeEtapesCommandeSucces extends StatelessWidget {
  const ListeEtapesCommandeSucces({super.key});

  @override
  Widget build(BuildContext context) {
    // Premier point actif (payé). Les 3 suivants restent neutres.
    const items = <_StepData>[
      _StepData(icone: Icons.check, label: 'Payé', actif: true),
      _StepData(icone: Icons.inventory_2_outlined, label: 'Préparation'),
      _StepData(icone: Icons.local_shipping_outlined, label: 'Transport'),
      _StepData(icone: Icons.home_outlined, label: 'Livraison'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(child: _PastilleEtape(data: items[i])),
              if (i < items.length - 1)
                _LigneEntre(actif: items[i].actif && items[i + 1].actif),
            ],
          ],
        );
      },
    );
  }
}

class _StepData {
  const _StepData({
    required this.icone,
    required this.label,
    this.actif = false,
  });
  final IconData icone;
  final String label;
  final bool actif;
}

class _PastilleEtape extends StatelessWidget {
  const _PastilleEtape({required this.data});
  final _StepData data;

  @override
  Widget build(BuildContext context) {
    final actif = data.actif;
    final couleurCercle =
        actif ? AppColors.primary : AppColors.primary.withValues(alpha: 0.12);
    final couleurIcone = actif ? Colors.white : AppColors.primary;
    final couleurLabel = actif ? AppColors.text : AppColors.textSecondary;

    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: couleurCercle,
            border: actif
                ? null
                : Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: AppDimens.borderThin,
                  ),
          ),
          alignment: Alignment.center,
          child: Icon(data.icone, size: 18, color: couleurIcone),
        ),
        const SizedBox(height: 6),
        Text(
          data.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11,
            fontWeight: actif ? FontWeight.w700 : FontWeight.w500,
            color: couleurLabel,
          ),
        ),
      ],
    );
  }
}

/// Petit trait entre 2 pastilles (4-5 px d'épaisseur visuelle).
class _LigneEntre extends StatelessWidget {
  const _LigneEntre({required this.actif});
  final bool actif;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        width: 16,
        height: 2,
        color: actif
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.22),
      ),
    );
  }
}
