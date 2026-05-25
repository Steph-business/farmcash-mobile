import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

const BorderRadius _kBrCard12 = BorderRadius.all(Radius.circular(12));

/// Encart « Pas d'invitation envoyée » affiché à la place de l'historique
/// quand la coopérative n'a encore invité personne.
class EtatVideInvitations extends StatelessWidget {
  const EtatVideInvitations({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: _kBrCard12,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.outbox_outlined,
            size: 28,
            color: AppColors.textSubtle,
          ),
          const SizedBox(height: 8),
          Text(
            'Pas d\'invitation envoyée',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
