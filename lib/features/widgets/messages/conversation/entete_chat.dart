import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'avatar_bot.dart';
import 'avatar_chat.dart';

/// En-tête du chat avec photo (ou avatar bot pour IA) + nom + sous-titre
/// + bouton retour.
///
/// Deux modes bien distincts selon `isAi` :
///   • CONV IA → avatar bot vert + "Assistant agronomique" + "Bot IA ·
///     répond instantanément"
///   • CONV HUMAINE → photo + full_name de l'autre participant + "En ligne"
///
/// Le parent reste responsable du calcul de `name`, `sousTitre`, `isAi`,
/// `photoUrl` à partir de l'état conversation (l'en-tête ne consomme pas
/// de provider directement, ce qui le garde testable et purement
/// présentationnel).
class EnteteChat extends StatelessWidget {
  const EnteteChat({
    required this.name,
    required this.sousTitre,
    required this.isAi,
    required this.photoUrl,
    required this.onBack,
    super.key,
  });

  final String name;
  final String sousTitre;
  final bool isAi;
  final String? photoUrl;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space8,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
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
          const SizedBox(width: 4),
          if (isAi)
            const AvatarBot()
          else
            AvatarChat(photoUrl: photoUrl, fallbackName: name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  sousTitre,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
