import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'accueil_constants.dart';

/// Type sémantique d'une action listée dans la section "À traiter".
/// Pilote la couleur de la bulle d'icône à gauche de la ligne.
enum ActionType { positive, validation, warning, error }

/// Données d'une ligne d'action affichée dans la section "À traiter" de
/// l'accueil producteur.
class ActionItem {
  final IconData icon;
  final ActionType type;
  final String titre;
  final String sousTitre;
  const ActionItem({
    required this.icon,
    required this.type,
    required this.titre,
    required this.sousTitre,
  });
}

/// Ligne d'action de la section "À traiter" : icône colorée + titre +
/// sous-titre + chevron. Tappable pour ouvrir la cible (typiquement la
/// liste des offres reçues).
class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.item,
    required this.isLast,
    this.onTap,
  });

  final ActionItem item;
  final bool isLast;
  final VoidCallback? onTap;

  Color get _bubbleBg {
    switch (item.type) {
      case ActionType.positive:
      case ActionType.validation:
        return kAccueilPrimarySoft;
      case ActionType.warning:
        return kAccueilWarnSoft;
      case ActionType.error:
        return kAccueilRedSoft;
    }
  }

  Color get _bubbleFg {
    switch (item.type) {
      case ActionType.positive:
      case ActionType.validation:
        return AppColors.primary;
      case ActionType.warning:
        return kAccueilWarn;
      case ActionType.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _bubbleBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, size: 20, color: _bubbleFg),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.titre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: AppDimens.iconM,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
