import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));
final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte « Marchandise » du détail mission : présente la quantité en kg
/// et le type de véhicule attendu, alignés à gauche/droite.
class CarteMarchandiseMission extends StatelessWidget {
  const CarteMarchandiseMission({required this.mission, super.key});
  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final qte = mission.quantiteKg != null
        ? '${_nf.format(mission.quantiteKg!.round())} kg'
        : 'Quantité non précisée';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.scale_outlined, size: 16, color: AppColors.textSubtle),
          const SizedBox(width: 8),
          Text(
            qte,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const Spacer(),
          if (mission.vehicleType != null)
            Text(
              mission.vehicleType!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
