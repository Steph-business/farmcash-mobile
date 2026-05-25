import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/models.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

final _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte d'un devis transporteur affiché dans la liste de comparaison
/// côté acheteur. Met en évidence le meilleur prix via une bordure verte
/// et un chip « Meilleur prix ».
class CarteDevisTransporteur extends StatelessWidget {
  const CarteDevisTransporteur({
    required this.quote,
    required this.isBest,
    required this.onChoose,
    super.key,
  });

  /// Devis transport à afficher.
  final TransportQuote quote;

  /// `true` si ce devis est le meilleur prix de la liste.
  final bool isBest;

  /// Callback invoqué quand l'acheteur clique sur « Choisir ».
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final nom = quote.transporterName.isNotEmpty
        ? quote.transporterName
        : 'Transporteur';
    final delai = quote.delaiTypique?.trim();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBest ? AppColors.primary : AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 22,
              color: AppColors.primary,
            ),
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
                      nom,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isBest) const _ChipMeilleurPrix(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  quote.rating > 0
                      ? '${quote.rating.toStringAsFixed(1)} ★'
                      : 'Nouveau',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_nf.format(quote.tarifTotal)} F',
                            style: AppTextStyles.titleSmall.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (delai != null && delai.isNotEmpty)
                            Text(
                              delai,
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onChoose,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        child: Text(
                          'Choisir',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipMeilleurPrix extends StatelessWidget {
  const _ChipMeilleurPrix();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Meilleur prix',
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
