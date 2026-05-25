import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// En-tête de la page détail d'une annonce producteur : back arrow à
/// gauche, titre « Mon annonce » et un bouton d'action optionnel à droite
/// (icône configurable — typiquement supprimer).
class HeaderAnnonceDetail extends StatelessWidget {
  const HeaderAnnonceDetail({
    super.key,
    this.onEdit,
    this.editIcon = Icons.edit_outlined,
    this.editTooltip,
  });

  final VoidCallback? onEdit;
  final IconData editIcon;
  final String? editTooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Mon annonce',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onEdit != null)
            Tooltip(
              message: editTooltip ?? 'Action',
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    editIcon,
                    size: 20,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
