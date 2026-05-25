import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Sous-titre de section dans les pages wallet — variante compacte (14pt
/// w700) utilisée par les pages Recharger / Retirer pour les sections
/// « Méthode de paiement », « Destinataire », « Code PIN MoMo ».
class TitreSectionWallet extends StatelessWidget {
  const TitreSectionWallet(this.label, {super.key});

  /// Libellé affiché.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        label,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }
}
