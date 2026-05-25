import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'chip_meta_itineraire.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte représentant un itinéraire (origine → destination) déclaré
/// par le transporteur : icône, switch d'activation, méta-infos
/// (capacité, tarif, etc.) et action de suppression.
class CarteItineraire extends StatelessWidget {
  const CarteItineraire({
    required this.route,
    required this.busy,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final TransporterRoute route;
  final bool busy;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final capacite = '${_nf.format(route.capaciteMaxKg.round())} kg max';
    final tarif = '${_nf.format(route.tarifKg.round())} F/kg';
    final minimum = route.tarifMinimum > 0
        ? 'min ${_nf.format(route.tarifMinimum.round())} F'
        : null;
    final delai = route.delaiTypique;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
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
                    Icons.alt_route,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${route.origineZone} → ${route.destinationZone}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (busy)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Switch(
                    value: route.isActive,
                    activeThumbColor: AppColors.primary,
                    onChanged: (_) => onToggle(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ChipMetaItineraire(label: capacite),
                ChipMetaItineraire(label: tarif),
                if (minimum != null) ChipMetaItineraire(label: minimum),
                if (delai != null) ChipMetaItineraire(label: delai),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: busy ? null : onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Supprimer',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
