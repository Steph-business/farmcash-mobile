import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/matching.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Provider auto-disposé + family — fournisseurs matchant une demande
/// d'achat précise. Tolérant aux erreurs : renvoie liste vide en cas
/// d'échec pour ne pas casser la page propositions.
final fournisseursPotentielsProvider = FutureProvider.autoDispose
    .family<List<MatchedSupplier>, String>((ref, annonceId) async {
  try {
    return await ref
        .read(matchingServiceProvider)
        .listMatchingSuppliers(annonceId);
  } catch (_) {
    return const <MatchedSupplier>[];
  }
});

/// Section « Fournisseurs potentiels » sur la fiche détail d'une demande
/// d'achat côté acheteur.
///
/// Affiche jusqu'à 5 producteurs matchant la demande (produit + région +
/// cultures déclarées + annonces actives). Si la liste est vide → encart
/// pédagogique rassurant plutôt qu'absence muette.
class SectionFournisseursPotentiels extends ConsumerWidget {
  const SectionFournisseursPotentiels({
    required this.annonceId,
    super.key,
  });

  /// ID de la demande d'achat — passé au provider matching.
  final String annonceId;

  /// Limite l'affichage initial à 5 cartes (le bouton « Voir tous » est
  /// poussé si la liste est plus longue). 5 correspond à la grosseur
  /// visuelle « équilibrée » dans le scroll de la fiche.
  static const int _maxAffiches = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(fournisseursPotentielsProvider(annonceId));

    return async.when(
      loading: () => const _LoadingPlaceholder(),
      error: (_, _) => const SizedBox.shrink(),
      data: (suppliers) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(count: suppliers.length),
            const SizedBox(height: 12),
            if (suppliers.isEmpty)
              const _EncartVidePedagogique()
            else ...[
              for (var i = 0; i < suppliers.take(_maxAffiches).length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _CarteFournisseur(supplier: suppliers[i]),
              ],
              if (suppliers.length > _maxAffiches) ...[
                const SizedBox(height: 10),
                _CtaVoirTous(count: suppliers.length),
              ],
            ],
          ],
        );
      },
    );
  }
}

/// Placeholder loading discret (hauteur équivalente à 2 cartes).
class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
    );
  }
}

/// Header section : titre avec emoji « 🤝 » (encore acceptable ici car
/// dans le mocup design) + sous-titre + badge.
class _Header extends StatelessWidget {
  const _Header({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Fournisseurs potentiels',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: AppColors.text,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$count',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Producteurs qui matchent ta demande.',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Encart pédagogique quand aucun fournisseur ne matche.
class _EncartVidePedagogique extends StatelessWidget {
  const _EncartVidePedagogique();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pas encore de fournisseurs disponibles',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'On te notifiera dès qu\'un producteur de la région '
                  'poste une annonce correspondante.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// CTA « Voir tous (N) » poussé sous la liste tronquée.
class _CtaVoirTous extends StatelessWidget {
  const _CtaVoirTous({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        'Voir tous les $count fournisseurs',
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Carte fournisseur — avatar/initiale + nom + région + 2 chips.
class _CarteFournisseur extends StatelessWidget {
  const _CarteFournisseur({required this.supplier});
  final MatchedSupplier supplier;

  @override
  Widget build(BuildContext context) {
    final s = supplier;
    final hasActive = s.hasActiveAnnonce;
    final hasCulture = s.declaredInCultures;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: InkWell(
        onTap: () => context.push(
          RouteNames.acheteurVendeurDetailPathFor(s.userId),
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar initiale
              _AvatarInitiale(name: s.fullName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    if ((s.regionName ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              s.regionName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (hasActive || hasCulture) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (hasActive)
                            const _Chip(
                              label: 'Annonce active',
                              color: AppColors.success,
                              icon: Icons.bolt_rounded,
                            ),
                          if (hasCulture)
                            const _Chip(
                              label: 'Cultivateur déclaré',
                              color: Color(0xFF1D4ED8),
                              icon: Icons.eco_outlined,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar initiale stylisé (couleur de marque, lettre blanche).
class _AvatarInitiale extends StatelessWidget {
  const _AvatarInitiale({required this.name});
  final String name;

  String get _initiale {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        _initiale,
        style: AppTextStyles.titleLarge.copyWith(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Chip statut compact (annonce active, cultivateur déclaré).
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
