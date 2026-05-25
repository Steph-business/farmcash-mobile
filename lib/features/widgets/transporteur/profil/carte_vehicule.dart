import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/vehicle.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'chip_statut_vehicule.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Carte décrivant un véhicule de la flotte du transporteur : vignette
/// photo (ou icône camion), marque/type, immatriculation, capacité utile
/// et chip de statut. Un bouton corbeille déclenche [onDelete].
class CarteVehicule extends StatelessWidget {
  const CarteVehicule({required this.v, required this.onDelete, super.key});

  final Vehicle v;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final titre = v.marque?.trim().isNotEmpty == true
        ? v.marque!.trim()
        : (v.type.isNotEmpty ? v.type : 'Véhicule');
    final typeImmat = [
      if (v.type.isNotEmpty) v.type,
      if (v.immatriculation?.trim().isNotEmpty == true)
        v.immatriculation!.trim(),
    ].join(' · ');
    final capacite = v.chargeMaxKg > 0
        ? '${nf.format(v.chargeMaxKg.round())} kg utiles'
        : 'Capacité non renseignée';
    final photo = v.photoUrl;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: photo != null && photo.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photo,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: _kPrimarySoft),
                    errorWidget: (_, _, _) => const Icon(
                      Icons.local_shipping_outlined,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.local_shipping_outlined,
                    size: 24,
                    color: AppColors.primary,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    ChipStatutVehicule(actif: v.isActive),
                  ],
                ),
                if (typeImmat.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    typeImmat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  capacite,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Supprimer',
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
