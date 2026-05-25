import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'send_button_assistant.dart';

/// Barre de saisie de message en bas de l'assistant.
///
/// Champ multilignes (max 4 lignes / 110 px), bordure superieure, bouton
/// d'envoi accessible via `SendButtonAssistant`. `onSubmit` recoit le
/// contenu actuel du `controller`.
class InputBarAssistant extends StatelessWidget {
  const InputBarAssistant({
    required this.controller,
    required this.isSending,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController controller;
  final bool isSending;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space12,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 110),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Écrire un message…',
                  hintStyle: AppTextStyles.hint,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppDimens.brInput,
                    borderSide: const BorderSide(
                      color: AppColors.borderStrong,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppDimens.brInput,
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: AppDimens.borderThin,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SendButtonAssistant(
            isSending: isSending,
            onTap: () => onSubmit(controller.text),
          ),
        ],
      ),
    );
  }
}
