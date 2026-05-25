import 'package:flutter/material.dart';

import '../../../../models/produit.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrInput = BorderRadius.all(Radius.circular(10));

/// Sélecteur de produit principal pour le membre géré : encadré tappable
/// qui ouvre un bottom sheet de choix produit. Affichage placeholder
/// quand aucun produit n'est encore sélectionné.
class SelecteurProduitManaged extends StatelessWidget {
  const SelecteurProduitManaged({
    super.key,
    required this.produit,
    required this.onTap,
    required this.enabled,
  });

  /// Produit actuellement sélectionné (peut être null).
  final Produit? produit;

  /// Action déclenchée au tap (ouvrir la feuille de choix).
  final VoidCallback onTap;

  /// Désactive l'interaction quand le formulaire est en cours d'envoi.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final p = produit;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: _kBrInput,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: _kBrInput,
          border: Border.all(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                p?.nom ?? 'Choisir un produit',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: p == null ? AppColors.textSubtle : AppColors.text,
                  fontWeight: p == null ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.expand_more,
              size: 18,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
