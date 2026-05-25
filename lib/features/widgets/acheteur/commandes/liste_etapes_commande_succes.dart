import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Liste des prochaines étapes après une commande passée.
class ListeEtapesCommandeSucces extends StatelessWidget {
  const ListeEtapesCommandeSucces({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _TuileEtape(num: '1', text: 'Le vendeur prépare ton colis'),
        SizedBox(height: 10),
        _TuileEtape(
          num: '2',
          text:
              'Le transporteur prend le colis (paiement libéré au vendeur via escrow auto)',
        ),
        SizedBox(height: 10),
        _TuileEtape(
          num: '3',
          text: 'Tu reçois et tu montres ton QR pour valider la livraison',
        ),
      ],
    );
  }
}

class _TuileEtape extends StatelessWidget {
  const _TuileEtape({required this.num, required this.text});
  final String num;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8F5E9),
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.text,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
