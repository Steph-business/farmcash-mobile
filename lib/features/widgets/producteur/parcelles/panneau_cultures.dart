import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/chargement.dart';
import 'parcelle_providers.dart';
import 'puces_cultures.dart';

/// Panel de sélection des cultures pour l'étape 3 du wizard parcelle.
///
/// Trois modes d'affichage selon les entrées utilisateur :
///   - [query] non vide → filtre la liste complète et affiche les
///     résultats sous forme de [PucesCultures].
///   - [showAll] vrai → affiche toute la liste, avec un bouton
///     "Réduire" pour revenir à la vue top-6.
///   - sinon → affiche les 6 cultures populaires en CI (cf.
///     [kTopCulturesCI]) et un bouton "Voir toutes".
class PanneauCultures extends ConsumerWidget {
  const PanneauCultures({
    required this.selectedIds,
    required this.query,
    required this.showAll,
    required this.enabled,
    required this.onToggle,
    required this.onToggleShowAll,
    super.key,
  });

  final Set<String> selectedIds;
  final String query;
  final bool showAll;
  final bool enabled;
  final ValueChanged<String> onToggle;
  final VoidCallback onToggleShowAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(produitsParcelleProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.space12),
        child: Chargement(size: 18),
      ),
      error: (_, _) => Text(
        'Impossible de charger les produits.',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
      data: (produits) {
        final q = query.trim().toLowerCase();
        if (q.isNotEmpty) {
          final filtered = produits
              .where((p) => p.nom.toLowerCase().contains(q))
              .toList(growable: false);
          return PucesCultures(
            produits: filtered,
            selectedIds: selectedIds,
            enabled: enabled,
            onToggle: onToggle,
          );
        }
        if (showAll) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PucesCultures(
                produits: produits,
                selectedIds: selectedIds,
                enabled: enabled,
                onToggle: onToggle,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onToggleShowAll,
                child: const Text('Réduire'),
              ),
            ],
          );
        }
        // Vue par défaut : top 6 + bouton "Voir toutes".
        final top = produits
            .where((p) => kTopCulturesCI.any((t) =>
                p.nom.toLowerCase().contains(t.toLowerCase())))
            .toList(growable: false);
        final fallback = top.isEmpty ? produits.take(6).toList() : top;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 8),
              child: Text(
                'Cultures populaires',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            PucesCultures(
              produits: fallback,
              selectedIds: selectedIds,
              enabled: enabled,
              onToggle: onToggle,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onToggleShowAll,
              icon: const Icon(Icons.unfold_more, size: 16),
              label: Text('Voir toutes (${produits.length})'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        );
      },
    );
  }
}
