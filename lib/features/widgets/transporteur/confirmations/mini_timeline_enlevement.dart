import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// État d'une étape dans la timeline d'enlèvement : terminée, en cours
/// ou à venir.
enum EtatEtapeEnlevement { done, current, pending }

/// Donnée d'une étape de la timeline d'enlèvement (icône + libellé + état).
class DonneeEtapeEnlevement {
  const DonneeEtapeEnlevement({
    required this.icon,
    required this.label,
    required this.state,
  });

  final IconData icon;
  final String label;
  final EtatEtapeEnlevement state;
}

/// Mini timeline verticale affichant les étapes de la mission lors de la
/// confirmation d'enlèvement. Chaque état (done/current/pending) a son
/// propre rendu visuel.
class MiniTimelineEnlevement extends StatelessWidget {
  const MiniTimelineEnlevement({required this.items, super.key});

  final List<DonneeEtapeEnlevement> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++)
            _LigneTimelineEnlevement(
              data: items[i],
              isLast: i == items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _LigneTimelineEnlevement extends StatelessWidget {
  const _LigneTimelineEnlevement({required this.data, required this.isLast});

  final DonneeEtapeEnlevement data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    Color circleBg;
    Color iconColor;
    switch (data.state) {
      case EtatEtapeEnlevement.done:
        circleBg = AppColors.primary;
        iconColor = Colors.white;
      case EtatEtapeEnlevement.current:
        circleBg = _kPrimarySoft;
        iconColor = AppColors.primary;
      case EtatEtapeEnlevement.pending:
        circleBg = AppColors.surfaceSoft;
        iconColor = AppColors.textSubtle;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: circleBg,
              shape: BoxShape.circle,
              border: data.state == EtatEtapeEnlevement.pending
                  ? Border.all(
                      color: AppColors.border, width: AppDimens.borderThin)
                  : null,
            ),
            alignment: Alignment.center,
            child: Icon(data.icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: data.state == EtatEtapeEnlevement.pending
                    ? FontWeight.w500
                    : FontWeight.w600,
                color: data.state == EtatEtapeEnlevement.pending
                    ? AppColors.textSecondary
                    : AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
