import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Header de la page détail commande côté producteur. Affiche un titre
/// simple « Commande » au centre + bouton retour. L'UUID long est
/// volontairement masqué — il est dispo dans la carte résumé pliable.
class EnteteCommandeDetail extends StatelessWidget {
  const EnteteCommandeDetail({
    this.commandeId = '',
    super.key,
  });

  /// Conservé pour compat API — non affiché dans le titre.
  final String commandeId;

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
              'Commande',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
