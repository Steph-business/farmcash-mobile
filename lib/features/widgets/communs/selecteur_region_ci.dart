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
//  Source de vérité : la liste des 8 régions principales est hard-codée
//  ici (Yamoussoukro, Abidjan, Bouaké, San Pedro, Korhogo, Daloa, Man,
//  Abengourou). Le backend stocke `region_id` en string (slug) — pas
//  d'UUID — pour rester rétrocompatible avec d'éventuels champs libres.
// =====================================================================

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Une région ivoirienne avec son slug backend, son nom UI et son picto.
class RegionCi {
  const RegionCi({
    required this.id,
    required this.name,
    required this.icon,
  });

  /// Identifiant envoyé au backend (`region_id`). Slug en minuscules
  /// sans accents pour éviter les surprises d'encoding.
  final String id;

  /// Nom affiché (libellé court FR avec accents).
  final String name;

  /// Picto Material qui distingue visuellement la région. On évite
  /// l'emoji pour rester premium et neutre.
  final IconData icon;
}

/// Catalogue partagé des 8 régions principales de Côte d'Ivoire.
const List<RegionCi> kCoteIvoireRegions = [
  RegionCi(
    id: 'abidjan',
    name: 'Abidjan',
    icon: Icons.location_city_rounded,
  ),
  RegionCi(
    id: 'yamoussoukro',
    name: 'Yamoussoukro',
    icon: Icons.account_balance_rounded,
  ),
  RegionCi(
    id: 'bouake',
    name: 'Bouaké',
    icon: Icons.terrain_rounded,
  ),
  RegionCi(
    id: 'san-pedro',
    name: 'San Pedro',
    icon: Icons.directions_boat_filled_rounded,
  ),
  RegionCi(
    id: 'korhogo',
    name: 'Korhogo',
    icon: Icons.wb_sunny_rounded,
  ),
  RegionCi(
    id: 'daloa',
    name: 'Daloa',
    icon: Icons.forest_rounded,
  ),
  RegionCi(
    id: 'man',
    name: 'Man',
    icon: Icons.landscape_rounded,
  ),
  RegionCi(
    id: 'abengourou',
    name: 'Abengourou',
    icon: Icons.park_rounded,
  ),
];

/// Sélection simple (mono) — pour producteur/coop.
///
/// Affiche les 8 régions en grille 2 colonnes. La sélection courante
/// (par `id`) est mise en surbrillance avec border + tint primary.
class SelecteurRegionCi extends StatelessWidget {
  const SelecteurRegionCi({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });

  final String? selectedId;
  final ValueChanged<RegionCi> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: kCoteIvoireRegions.length,
      itemBuilder: (_, i) {
        final region = kCoteIvoireRegions[i];
        return _RegionCard(
          region: region,
          selected: region.id == selectedId,
          onTap: () => onChanged(region),
        );
      },
    );
  }
}

/// Sélection multiple — pour zones d'achat acheteur.
class SelecteurRegionsCiMulti extends StatelessWidget {
  const SelecteurRegionsCiMulti({
    super.key,
    required this.selectedIds,
    required this.onToggle,
  });

  /// Ensemble courant d'identifiants sélectionnés. Utiliser `Set<String>`
  /// pour éviter les doublons en interne.
  final Set<String> selectedIds;
  final ValueChanged<RegionCi> onToggle;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: kCoteIvoireRegions.length,
      itemBuilder: (_, i) {
        final region = kCoteIvoireRegions[i];
        return _RegionCard(
          region: region,
          selected: selectedIds.contains(region.id),
          onTap: () => onToggle(region),
        );
      },
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
        ? AppColors.primary.withValues(alpha: 0.55)
        : AppColors.border;
    final fg =
        selected ? AppColors.primary : AppColors.text;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.16)
                          : AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      region.icon,
                      size: 22,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    region.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ],
              ),
              if (selected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
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
