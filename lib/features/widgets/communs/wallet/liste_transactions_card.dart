import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'tuile_transaction.dart';

/// Conteneur encadré listant des transactions. Affiche un état vide soigné
/// quand [items] est vide (sauf si [autoriserVide] est désactivé).
///
/// Utilisé par la page liste wallet pour les 4 profils.
class ListeTransactionsCard extends StatelessWidget {
  const ListeTransactionsCard({
    super.key,
    required this.items,
    this.afficherEtatVide = true,
    this.messageVide = 'Aucune transaction pour le moment',
  });

  /// Transactions à afficher (déjà mappées en représentation visuelle).
  final List<ItemTransaction> items;

  /// Si `true` (par défaut), affiche un placeholder quand la liste est vide.
  /// Si `false`, le conteneur reste vide (rend la card invisible visuellement).
  final bool afficherEtatVide;

  /// Texte du placeholder vide.
  final String messageVide;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      clipBehavior: Clip.hardEdge,
      child: items.isEmpty
          ? (afficherEtatVide
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 32,
                        color: AppColors.textSubtle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        messageVide,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink())
          : Column(
              children: List.generate(items.length, (i) {
                return TuileTransaction(
                  item: items[i],
                  dernier: i == items.length - 1,
                );
              }),
            ),
    );
  }
}
