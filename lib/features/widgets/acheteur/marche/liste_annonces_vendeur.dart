import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

final _nf = NumberFormat('#,##0', 'fr_FR');

String _fmtKg(double v) => '${_nf.format(v.round())} kg';

/// Liste empilée des annonces actives d'un vendeur, affichée sur sa page
/// profil. Chaque ligne est cliquable et conduit au détail de l'annonce.
class ListeAnnoncesVendeur extends StatelessWidget {
  const ListeAnnoncesVendeur({
    required this.items,
    required this.onTap,
    super.key,
  });

  /// Annonces à afficher.
  final List<AnnonceVente> items;

  /// Callback invoqué au tap sur une annonce.
  final ValueChanged<AnnonceVente> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            InkWell(
              onTap: () => onTap(items[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space16,
                  vertical: AppDimens.space12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _kPrimarySoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.border,
                          width: AppDimens.borderThin,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: items[i].photos.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: items[i].photos.first,
                              fit: BoxFit.cover,
                              placeholder: (_, _) =>
                                  const ColoredBox(color: _kPrimarySoft),
                              errorWidget: (_, _, _) => const Icon(
                                Icons.image_outlined,
                                size: 22,
                                color: AppColors.textSubtle,
                              ),
                            )
                          : const Icon(
                              Icons.image_outlined,
                              size: 22,
                              color: AppColors.textSubtle,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            items[i].produitLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_fmtKg(items[i].quantiteKg)} disponibles',
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
                    const SizedBox(width: 8),
                    Text(
                      '${_nf.format(items[i].prixParKg)} F/kg',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}
