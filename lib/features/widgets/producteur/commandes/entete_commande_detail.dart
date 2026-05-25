import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Header de la page détail commande côté producteur. Affiche
/// `Commande #<reference>` au centre avec un bouton retour à gauche.
class EnteteCommandeDetail extends StatelessWidget {
  const EnteteCommandeDetail({
    required this.commandeId,
    super.key,
  });

  /// ID brut de la commande (ex: UUID). Si déjà préfixé `C-`, affiché tel
  /// quel. Sinon fallback à un placeholder lisible.
  final String commandeId;

  @override
  Widget build(BuildContext context) {
    final ref = commandeId.startsWith('C-') ? commandeId : 'C-2026-0089';
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
              'Commande #$ref',
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
