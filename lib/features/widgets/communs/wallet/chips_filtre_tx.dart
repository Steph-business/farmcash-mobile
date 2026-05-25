import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Option de filtre de transactions (label + clé).
class OptionFiltreTx {
  const OptionFiltreTx({required this.cle, required this.label});

  /// Clé utilisée pour comparer la sélection courante (typiquement une
  /// valeur d'enum).
  final Object cle;

  /// Libellé affiché sur le chip.
  final String label;
}

/// Rangée de chips de filtres de transactions — usage : page liste wallet.
///
/// Les options changent selon le profil : producteur (Tout/Entrées/Sorties),
/// acheteur (Tout/Achats/Recharges/Escrow), coopérative (+ Avances).
class ChipsFiltreTx extends StatelessWidget {
  const ChipsFiltreTx({
    super.key,
    required this.options,
    required this.actif,
    required this.onChanger,
  });

  /// Options proposées.
  final List<OptionFiltreTx> options;

  /// Clé actuellement active (matche [OptionFiltreTx.cle]).
  final Object actif;

  /// Callback appelé avec la nouvelle clé active.
  final ValueChanged<Object> onChanger;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final o = options[i];
          return _Chip(
            label: o.label,
            active: o.cle == actif,
            onTap: () => onChanger(o.cle),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
