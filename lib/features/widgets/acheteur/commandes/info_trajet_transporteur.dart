import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'args_devis_transporteur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

final _nf = NumberFormat('#,##0', 'fr_FR');

/// Bandeau récapitulant le trajet et la quantité pour la page
/// « Choisir mon transporteur ». Affiché juste au-dessus des devis.
class InfoTrajetTransporteur extends StatelessWidget {
  const InfoTrajetTransporteur({required this.args, super.key});

  /// Arguments décrivant le trajet (origine, destination, quantité kg).
  final ArgsDevisTransporteur args;

  @override
  Widget build(BuildContext context) {
    final qte = _nf.format(args.quantiteKg.round());
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Trajet : ${args.origineZone} → ${args.destinationZone} · $qte kg',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
