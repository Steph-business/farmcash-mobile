import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Bouton CTA « Envoyer un message » présent au bas de la page profil
/// vendeur. Le téléphone n'est jamais affiché côté acheteur — la prise
/// de contact passe uniquement par la messagerie.
class CtaMessageVendeur extends StatelessWidget {
  const CtaMessageVendeur({required this.onTap, super.key});

  /// Callback déclenché au tap sur le bouton.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(
          Icons.chat_bubble_outline,
          size: 18,
          color: AppColors.onPrimary,
        ),
        label: Text(
          'Envoyer un message',
          style: AppTextStyles.button.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brButton,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space24,
          ),
        ),
      ),
    );
  }
}
