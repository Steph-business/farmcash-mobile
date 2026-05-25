import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/coop_vehicle.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));
final _nf = NumberFormat('#,##0', 'fr_FR');

/// Ligne d'un vehicule dans le parc coop : icone primaire, libelle
/// "Marque type - immatriculation", sous-ligne "Charge max XX kg -
/// chauffeur" et badge "Inactif" si le vehicule est desactive.
class LigneVehicule extends StatelessWidget {
  const LigneVehicule({required this.vehicle, super.key});

  final CoopVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final immat = (vehicle.immatriculation ?? '').isEmpty
        ? '—'
        : vehicle.immatriculation!;
    final marque = (vehicle.marque ?? '').isEmpty ? '' : vehicle.marque!;
    final chargeLabel = '${_nf.format(vehicle.chargeMaxKg.round())} kg';
    final chauffeur = (vehicle.chauffeurNom ?? '').isEmpty
        ? null
        : vehicle.chauffeurNom!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard,
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  marque.isEmpty
                      ? '${vehicle.type} · $immat'
                      : '$marque ${vehicle.type} · $immat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Charge max $chargeLabel'
                  '${chauffeur != null ? ' · $chauffeur' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!vehicle.isActive)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Inactif',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
