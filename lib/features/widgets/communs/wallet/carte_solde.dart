import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Action affichée sous le solde (boutons Retirer/Recharger).
class ActionSolde {
  const ActionSolde({
    required this.label,
    required this.primaire,
    required this.onTap,
  });

  final String label;
  final bool primaire;
  final VoidCallback onTap;
}

/// Carte hero du wallet — solde principal + sous-titre + boutons d'action.
///
/// Utilisé sur la page liste wallet (Producteur / Acheteur / Transporteur /
/// Coopérative). Le sous-titre permet d'afficher escrow ou variation
/// hebdo selon le profil.
class CarteSolde extends StatelessWidget {
  const CarteSolde({
    super.key,
    required this.balance,
    required this.labelSolde,
    this.sousTitre,
    this.actions = const [],
  });

  /// Solde affiché en gros (formaté avec espaces fr_FR).
  final double balance;

  /// Libellé du solde (ex : « Solde », « Solde actuel »).
  final String labelSolde;

  /// Sous-titre optionnel sous le solde (ex : « En escrow : 12 000 F »,
  /// « +95 000 F cette semaine », « En attente (transport en escrow) … »).
  final String? sousTitre;

  /// Boutons d'action affichés en pied de carte (généralement 2).
  final List<ActionSolde> actions;

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,##0', 'fr_FR').format(balance);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelSolde,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$formatted F',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          if (sousTitre != null) ...[
            const SizedBox(height: 6),
            Text(
              sousTitre!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: _BoutonAction(action: actions[i])),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BoutonAction extends StatelessWidget {
  const _BoutonAction({required this.action});

  final ActionSolde action;

  @override
  Widget build(BuildContext context) {
    final bg = action.primaire ? AppColors.primary : AppColors.background;
    final fg = action.primaire ? AppColors.onPrimary : AppColors.primary;
    return InkWell(
      onTap: action.onTap,
      borderRadius: AppDimens.brButton,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppDimens.brButton,
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          action.label,
          style: AppTextStyles.button.copyWith(
            fontSize: 14,
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
