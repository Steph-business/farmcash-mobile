import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Barre de recherche utilisée par la page Messages.
///
/// Adapte sa taille et son padding au rôle acheteur (variant "card" 42 px
/// + padding latéral 20) vs. les autres rôles (variant standard).
class BarreRechercheMessages extends StatelessWidget {
  const BarreRechercheMessages({
    required this.controller,
    required this.onChanged,
    required this.role,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final isAcheteur = role == UserRole.buyer;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isAcheteur ? 20 : AppDimens.pagePaddingH,
        0,
        isAcheteur ? 20 : AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Container(
        height: isAcheteur ? 42 : null,
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAcheteur ? AppColors.borderStrong : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: isAcheteur ? 14 : 12),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: isAcheteur ? 18 : 16,
              color: isAcheteur ? AppColors.textSubtle : AppColors.textSecondary,
            ),
            SizedBox(width: isAcheteur ? 10 : 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.text,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isAcheteur ? 12 : 10,
                  ),
                  border: InputBorder.none,
                  hintText: isAcheteur
                      ? 'Rechercher une conversation…'
                      : 'Rechercher une conversation',
                  hintStyle: AppTextStyles.hint.copyWith(
                    fontSize: 13,
                    color: AppColors.textSubtle,
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
