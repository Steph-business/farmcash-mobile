// =====================================================================
//  Widget : SelecteurRegionCi
//  ---------------------------------------------------------------------
//  Sélecteur de région ivoirienne en grille 2 colonnes (cards picto + nom)
//  partagé entre les 3 wizards d'onboarding (producteur, acheteur, coop)
//  ainsi que la page « Mon entreprise » et la page « Identité coop ».
//
//  Pourquoi pas un bottom-sheet : les paysans ciblés sont peu tech et
//  partiellement analphabètes. Une grille de cards avec picto + nom court
//  est plus parlante qu'une liste déroulante, et chaque cible tactile
//  fait largement plus de 50 dp (recommandation Apple/Material).
//
//  Source de vérité : la table `regions_ci` du backend (33 régions
//  officielles de Côte d'Ivoire). Le sélecteur fetch via `GET
//  /marketplace/regions` au build et envoie le VRAI UUID. Plus de slugs
//  hardcodés qui cassent au profil/producteur (qualif validateurs UUID).
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api_client/api_endpoints.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'chargement.dart';

/// Une région ivoirienne avec son UUID backend, son nom UI et son picto.
class RegionCi {
  const RegionCi({
    required this.id,
    required this.code,
    required this.name,
    required this.icon,
  });

  /// UUID backend (`region_id` envoyé en POST profile). Provient de la
  /// colonne `regions_ci.id` (uuid_generate_v4()).
  final String id;

  /// Code court (3-4 lettres) — ex. « ABJ ». Utile pour debug/tracking.
  final String code;

  /// Nom affiché (libellé court FR avec accents).
  final String name;

  /// Picto Material qui distingue visuellement la région. On évite
  /// l'emoji pour rester premium et neutre.
  final IconData icon;
}

/// Mapping code région → picto Material. On garde une table figée plutôt
/// que d'expédier les icônes côté backend (cohérence UI globale).
/// Les codes inconnus retombent sur un picto générique de relief.
IconData _iconForRegion(String code) {
  switch (code.toUpperCase()) {
    case 'ABJ':
      return Icons.location_city_rounded;
    case 'BEL': // Bélier (Yamoussoukro)
      return Icons.account_balance_rounded;
    case 'GBE': // Gbêkê (Bouaké)
      return Icons.terrain_rounded;
    case 'SMC': // San Pedro / Bas-Sassandra
    case 'GBKL':
      return Icons.directions_boat_filled_rounded;
    case 'PRZ': // Poro (Korhogo)
    case 'BAG':
      return Icons.wb_sunny_rounded;
    case 'HSS': // Haut-Sassandra (Daloa)
      return Icons.forest_rounded;
    case 'TON': // Tonkpi (Man)
      return Icons.landscape_rounded;
    case 'IND': // Indénié-Djuablin (Abengourou)
      return Icons.park_rounded;
    default:
      return Icons.location_on_outlined;
  }
}

/// Provider Riverpod qui fetch la liste des régions une fois et la
/// mémoïse pour toute la session (pas autoDispose : on garde en cache).
final regionsCiProvider = FutureProvider<List<RegionCi>>((ref) async {
  final api = ref.read(apiClientProvider);
  final raw = await api.get<dynamic>(ApiEndpoints.regions);
  final list = (raw as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList();
  return list.map((r) {
    final code = (r['code'] as String?) ?? '';
    return RegionCi(
      id: r['id'] as String,
      code: code,
      name: (r['nom'] as String?) ?? code,
      icon: _iconForRegion(code),
    );
  }).toList();
});

/// Sélection simple (mono) — pour producteur/coop.
///
/// Affiche les 33 régions en grille 2 colonnes. La sélection courante
/// (par `id` UUID) est mise en surbrillance avec border + tint primary.
class SelecteurRegionCi extends ConsumerWidget {
  const SelecteurRegionCi({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });

  final String? selectedId;
  final ValueChanged<RegionCi> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(regionsCiProvider);
    return async.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: Chargement(size: 22)),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Impossible de charger les régions. Réessaye dans un instant.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      data: (regions) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
        ),
        itemCount: regions.length,
        itemBuilder: (_, i) {
          final region = regions[i];
          return _RegionCard(
            region: region,
            selected: region.id == selectedId,
            onTap: () => onChanged(region),
          );
        },
      ),
    );
  }
}

/// Sélection multiple — pour zones d'achat acheteur.
class SelecteurRegionsCiMulti extends ConsumerWidget {
  const SelecteurRegionsCiMulti({
    super.key,
    required this.selectedIds,
    required this.onToggle,
  });

  /// Ensemble courant d'identifiants sélectionnés (UUIDs).
  final Set<String> selectedIds;
  final ValueChanged<RegionCi> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(regionsCiProvider);
    return async.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: Chargement(size: 22)),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Impossible de charger les régions. Réessaye dans un instant.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      data: (regions) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
        ),
        itemCount: regions.length,
        itemBuilder: (_, i) {
          final region = regions[i];
          return _RegionCard(
            region: region,
            selected: selectedIds.contains(region.id),
            onTap: () => onToggle(region),
          );
        },
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  const _RegionCard({
    required this.region,
    required this.selected,
    required this.onTap,
  });

  final RegionCi region;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.primary.withValues(alpha: 0.08)
        : Colors.white;
    final borderColor = selected
        ? AppColors.primary
        : AppColors.primary.withValues(alpha: 0.18);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                region.icon,
                size: 20,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  region.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: selected ? AppColors.primary : AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
