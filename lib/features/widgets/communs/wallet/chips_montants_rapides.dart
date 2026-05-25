import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Rangée de chips de montants prédéfinis (5 000 / 10 000 / …) avec un chip
/// « Tout » optionnel (bordure primaire permanente) — usage : Recharger /
/// Retirer.
class ChipsMontantsRapides extends StatelessWidget {
  const ChipsMontantsRapides({
    super.key,
    required this.montants,
    required this.selectionne,
    required this.onChoisir,
    this.afficherTout = false,
    this.toutActif = false,
    this.onChoisirTout,
  });

  /// Montants proposés (en entiers — affichés formatés via [NumberFormat]).
  final List<int> montants;

  /// Montant actuellement sélectionné. -1 si « Tout » est actif.
  final int selectionne;

  /// Callback à l'appui sur un chip valeur.
  final ValueChanged<int> onChoisir;

  /// Affiche un chip « Tout » à la fin (cas Retirer).
  final bool afficherTout;

  /// Indique si le chip « Tout » est l'état actif (sélection courante).
  final bool toutActif;

  /// Callback à l'appui sur le chip « Tout ». Requis si [afficherTout] est
  /// `true`.
  final VoidCallback? onChoisirTout;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'fr_FR');
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in montants)
          _Chip(
            label: fmt.format(v),
            highlighted: false,
            active: !toutActif && selectionne == v,
            onTap: () => onChoisir(v),
          ),
        if (afficherTout)
          _Chip(
            label: 'Tout',
            highlighted: true,
            active: toutActif,
            onTap: onChoisirTout ?? () {},
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.highlighted,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool highlighted;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? _kPrimarySoft
        : (highlighted ? AppColors.background : AppColors.surfaceSoft);
    final borderColor =
        (highlighted || active) ? AppColors.primary : AppColors.border;
    final fg = (highlighted || active) ? AppColors.primary : AppColors.text;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: AppDimens.borderThin),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}
