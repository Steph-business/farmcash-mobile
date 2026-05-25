import 'package:flutter/material.dart';

import '../../../../models/ai_content.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'assistant_constants.dart';

/// Bulle de chat affichant un message — user (a droite, primaire) ou
/// assistant (a gauche, surface douce + avatar circulaire).
///
/// Largeur maximale 75% de l'ecran ; coin "queue" rogne cote interlocuteur.
class BulleMessageAssistant extends StatelessWidget {
  const BulleMessageAssistant({required this.message, super.key});

  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final bg = isUser ? AppColors.primary : AppColors.surfaceSoft;
    final fg = isUser ? AppColors.onPrimary : AppColors.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: kPrimarySoftAssistant,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.auto_awesome_outlined,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12).copyWith(
                  bottomRight:
                      isUser ? const Radius.circular(2) : null,
                  bottomLeft:
                      !isUser ? const Radius.circular(2) : null,
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: AppColors.border,
                        width: AppDimens.borderThin,
                      ),
              ),
              child: Text(
                message.content,
                style: AppTextStyles.bodyMedium.copyWith(color: fg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
