import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Bouton d'envoi a droite de la zone de saisie de l'assistant.
///
/// Affiche un loader pendant `isSending`, sinon une fleche montante. Tap
/// desactive pendant l'envoi.
class SendButtonAssistant extends StatelessWidget {
  const SendButtonAssistant({
    required this.isSending,
    required this.onTap,
    super.key,
  });

  final bool isSending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: isSending ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : const Icon(
                    Icons.arrow_upward,
                    color: AppColors.onPrimary,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
