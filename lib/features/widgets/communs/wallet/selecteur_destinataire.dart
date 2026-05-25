import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Sélecteur de destinataire (page Retirer) — logo + titre + sous-titre +
/// chevron. Le tap est optionnel (mock visuel pour le moment).
class SelecteurDestinataire extends StatelessWidget {
  const SelecteurDestinataire({
    super.key,
    required this.codeLogo,
    required this.couleurLogo,
    required this.titre,
    required this.sousTitre,
    this.onTap,
  });

  /// Sigle court affiché dans le logo (ex : « OM »).
  final String codeLogo;

  /// Couleur de fond du logo (ex : orange Money).
  final Color couleurLogo;

  /// Titre principal (ex : « Mon numéro MoMo »).
  final String titre;

  /// Sous-titre (ex : « 07 09 88 30 51 · Orange Money »).
  final String sousTitre;

  /// Callback de tap. Si `null`, le tap est inerte mais la décoration
  /// `InkWell` reste pour rester fidèle à la maquette.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.border, width: AppDimens.borderThin),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: couleurLogo,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                codeLogo,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
