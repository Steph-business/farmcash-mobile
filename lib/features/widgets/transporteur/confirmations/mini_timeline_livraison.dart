import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Donnée d'une étape de la timeline de confirmation (toutes les étapes
/// affichées par [MiniTimelineLivraison] sont considérées comme terminées).
class DonneeEtapeTimeline {
  const DonneeEtapeTimeline({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Mini timeline verticale affichant les étapes complétées de la mission
/// (enlèvement confirmé + livraison confirmée). Chaque étape est rendue
/// avec une pastille verte primaire et l'icône fournie.
class MiniTimelineLivraison extends StatelessWidget {
  const MiniTimelineLivraison({required this.items, super.key});

  final List<DonneeEtapeTimeline> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child:
                        Icon(items[i].icon, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[i].label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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
