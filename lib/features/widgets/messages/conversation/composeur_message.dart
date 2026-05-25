import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Barre de composition (input multi-lignes + bouton d'envoi rond) sticky
/// en bas d'un écran de conversation chat.
///
/// Le parent contrôle l'état (`controller`, `enabled`, `canSend`,
/// `isSending`) et le callback `onSend`. Le composer reste purement
/// présentationnel : aucune logique d'envoi ici.
class ComposeurMessage extends StatelessWidget {
  const ComposeurMessage({
    required this.controller,
    required this.enabled,
    required this.canSend,
    required this.isSending,
    required this.onSend,
    super.key,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool canSend;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  maxHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Écrire un message…',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SendButton(
              canSend: canSend,
              isSending: isSending,
              onTap: canSend ? onSend : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton rond d'envoi : couleur primary quand actif, gris quand
/// désactivé, spinner blanc pendant l'envoi en cours.
class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.canSend,
    required this.isSending,
    required this.onTap,
  });

  final bool canSend;
  final bool isSending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: canSend ? AppColors.primary : AppColors.borderStrong,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: isSending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : Icon(
                Icons.send,
                size: 18,
                color: canSend
                    ? AppColors.onPrimary
                    : AppColors.textSubtle,
              ),
      ),
    );
  }
}
