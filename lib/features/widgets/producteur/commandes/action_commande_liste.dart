import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'commandes_list_constants.dart';

/// Action contextuelle à droite d'une carte commande, selon le statut.
/// Soit un bouton primaire compact, soit un simple chevron.
class ActionCommandeListe extends StatelessWidget {
  const ActionCommandeListe({
    super.key,
    required this.action,
    required this.onTap,
  });

  final OrderAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    switch (action) {
      case OrderAction.preparer:
        return _BtnSmallPrimary(label: 'Préparer', onTap: onTap);
      case OrderAction.livrer:
        return _BtnSmallPrimary(label: 'Marquer livré', onTap: onTap);
      case OrderAction.voir:
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSubtle,
            ),
          ),
        );
    }
  }
}

class _BtnSmallPrimary extends StatelessWidget {
  const _BtnSmallPrimary({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}
