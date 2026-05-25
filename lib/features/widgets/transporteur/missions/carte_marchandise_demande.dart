import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));
final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte « Marchandise » d'une demande de transport entrante : affiche la
/// quantité (kg) si fournie + le type de véhicule demandé éventuel.
class CarteMarchandiseDemande extends StatelessWidget {
  const CarteMarchandiseDemande({required this.mission, super.key});

  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final qte = mission.quantiteKg != null
        ? '${_nf.format(mission.quantiteKg!.round())} kg'
        : 'Quantité non précisée';
    final vehicleType = mission.vehicleType;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(Icons.scale_outlined, qte),
          if (vehicleType != null && vehicleType.isNotEmpty) ...[
            const SizedBox(height: 8),
            _row(Icons.local_shipping_outlined, 'Véhicule : $vehicleType'),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSubtle),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}
