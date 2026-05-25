import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/negociation.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/chargement.dart';
import 'buyer_row_annonce.dart';
import 'section_card_annonce.dart';

/// Section « Mes propositions » de la page détail d'une annonce producteur.
/// Affiche les candidatures incoming filtrées sur l'annonce courante avec
/// gestion des états loading/erreur/vide.
class SectionAcheteursInteresses extends StatelessWidget {
  const SectionAcheteursInteresses({
    required this.async,
    required this.onRetry,
    required this.onRepondre,
    super.key,
  });

  final AsyncValue<List<Candidature>> async;
  final VoidCallback onRetry;
  final ValueChanged<Candidature> onRepondre;

  @override
  Widget build(BuildContext context) {
    return SectionCardAnnonce(
      title: 'Mes propositions',
      children: [
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Chargement(size: 18),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Impossible de charger les propositions.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aucune proposition pour l\'instant.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < list.length; i++)
                  BuyerRowAnnonce(
                    candidature: list[i],
                    isLast: i == list.length - 1,
                    onRepondre: () => onRepondre(list[i]),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
