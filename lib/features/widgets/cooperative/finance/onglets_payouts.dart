import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Onglets disponibles sur la liste des distributions.
enum PayoutTab { aDistribuer, historique }

/// Barre d'onglets `À distribuer (n)` / `Historique (n)` pour la page
/// Distributions cooperative.
class OngletsPayouts extends StatelessWidget {
  const OngletsPayouts({
    required this.tab,
    required this.aDistribuerCount,
    required this.historiqueCount,
    required this.onChange,
    super.key,
  });

  final PayoutTab tab;
  final int aDistribuerCount;
  final int historiqueCount;
  final ValueChanged<PayoutTab> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          _OngletItem(
            label: 'À distribuer ($aDistribuerCount)',
            active: tab == PayoutTab.aDistribuer,
            onTap: () => onChange(PayoutTab.aDistribuer),
          ),
          _OngletItem(
            label: 'Historique ($historiqueCount)',
            active: tab == PayoutTab.historique,
            onTap: () => onChange(PayoutTab.historique),
          ),
        ],
      ),
    );
  }
}

class _OngletItem extends StatelessWidget {
  const _OngletItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
