import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bouton plein vert « Confirmer » utilisé à droite des tuiles de
/// réponse fournisseur. Désactivé (opacité 0.5) si [onTap] est null,
/// et capable d'afficher un libellé alternatif (ex : « … » pendant
/// l'appel réseau).
class AcceptBtnSuiviSollicitationCoop extends StatelessWidget {
  const AcceptBtnSuiviSollicitationCoop({
    required this.onTap,
    this.label = 'Confirmer',
    super.key,
  });

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
