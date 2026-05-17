import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/parcelle.dart';
import '../../../../models/produit.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Couleurs accent ─────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);

// ─── Photos d'illustration (Unsplash) — fallback si pas de photo réelle.
const String _kHeroPhotoFallback =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&h=400&fit=crop&auto=format';

/// Map slug → URL Unsplash pour la vignette culture. Aligné avec la maquette
/// pour les 3 produits principaux. Fallback générique pour les autres.
const Map<String, String> _kProduitThumbBySlug = {
  'mais': 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format',
  'mais-blanc': 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format',
  'mais-grain-blanc': 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format',
  'tomate': 'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=200&h=200&fit=crop&auto=format',
  'manioc': 'https://images.unsplash.com/photo-1567521464027-f127ff144326?w=200&h=200&fit=crop&auto=format',
};

const String _kProduitThumbFallback =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';

/// Bundle de données pour la page détail parcelle : la parcelle elle-même
/// + les cultures associées + le catalogue produit pour résoudre les noms.
class _DetailData {
  final Parcelle? parcelle;
  final List<Culture> cultures;
  final Map<String, Produit> produitsById;

  const _DetailData({
    required this.parcelle,
    required this.cultures,
    required this.produitsById,
  });
}

/// Provider familial : prend l'id de la parcelle, charge les données en
/// parallèle (parcelle + cultures + catalogue produits).
final _parcelleDetailProvider = FutureProvider.autoDispose
    .family<_DetailData, String>((ref, parcelleId) async {
  final svc = ref.watch(marketplaceServiceProvider);

  final results = await Future.wait<dynamic>([
    // 0 — parcelles (filtrage client-side sur id)
    svc.listParcelles().then<Object?>((v) => v).catchError((_) => <Parcelle>[]),
    // 1 — cultures de cette parcelle
    svc
        .listCultures(parcelleId: parcelleId)
        .then<Object?>((v) => v)
        .catchError((_) => <Culture>[]),
    // 2 — catalogue produits pour résoudre les noms
    svc.listProduits().then<Object?>((v) => v).catchError((_) => <Produit>[]),
  ]);

  final parcelles = (results[0] as List<Parcelle>?) ?? const <Parcelle>[];
  final parcelle = parcelles.where((p) => p.id == parcelleId).firstOrNull;
  final cultures = (results[1] as List<Culture>?) ?? const <Culture>[];
  final produits = (results[2] as List<Produit>?) ?? const <Produit>[];
  final byId = {for (final p in produits) p.id: p};

  return _DetailData(
    parcelle: parcelle,
    cultures: cultures,
    produitsById: byId,
  );
});

/// Détail d'une parcelle producteur — header + hero card + cultures.
///
/// Branché sur `marketplaceService.listCultures(parcelleId:)` pour récupérer
/// les cultures réelles. Si la parcelle n'est pas trouvée (id inexistant),
/// on affiche un message d'erreur avec retry.
class ParcelleDetailPage extends ConsumerWidget {
  const ParcelleDetailPage({required this.parcelleId, super.key});

  final String parcelleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_parcelleDetailProvider(parcelleId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              _HeaderLoading(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const _HeaderLoading(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la parcelle.',
                    onRetry: () =>
                        ref.invalidate(_parcelleDetailProvider(parcelleId)),
                  ),
                ),
              ),
            ],
          ),
          data: (data) {
            if (data.parcelle == null) {
              return Column(
                children: [
                  const _Header(titre: 'Parcelle introuvable'),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                      child: VueErreur(
                        message: 'Cette parcelle n\'existe plus ou tu n\'y as pas accès.',
                        onRetry: () =>
                            ref.invalidate(_parcelleDetailProvider(parcelleId)),
                      ),
                    ),
                  ),
                ],
              );
            }
            return _Content(data: data);
          },
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.titre, this.sousTitre});

  final String titre;
  final String? sousTitre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titre,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (sousTitre != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sousTitre!,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header sans titre (utilisé pendant le chargement, on évite un flash).
class _HeaderLoading extends StatelessWidget {
  const _HeaderLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contenu principal ───────────────────────────────────────────────────

class _Content extends StatelessWidget {
  const _Content({required this.data});

  final _DetailData data;

  @override
  Widget build(BuildContext context) {
    final parcelle = data.parcelle!;
    return Column(
      children: [
        _Header(
          titre: parcelle.nom,
          sousTitre: 'Détail de la parcelle',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePaddingH,
              0,
              AppDimens.pagePaddingH,
              AppDimens.space16,
            ),
            children: [
              _HeroCard(parcelle: parcelle),
              const SizedBox(height: AppDimens.space24),
              _SectionCultures(
                cultures: data.cultures,
                produitsById: data.produitsById,
                onAjouter: () => Snackbars.showInfo(
                  context,
                  'Ajouter une culture — à venir',
                ),
              ),
              const SizedBox(height: 18),
              _DangerLink(
                onTap: () => Snackbars.showInfo(
                  context,
                  'Supprimer la parcelle — à venir',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Hero card ───────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.parcelle});

  final Parcelle parcelle;

  @override
  Widget build(BuildContext context) {
    final sub = _formatSubtitle(parcelle);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: _kHeroPhotoFallback,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  parcelle.nom,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    _Pill(label: 'Active'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSubtitle(Parcelle p) {
    final parts = <String>[];
    // Ville/zone : inconnue côté modèle parcelle — on garde "Yopougon" si
    // pas mieux pour ne pas casser la mise en page (la maquette montre un
    // sous-titre composé). À remplacer par un vrai champ ville quand le
    // back l'expose.
    parts.add('Yopougon');
    if (p.superficieHa != null) {
      final ha = p.superficieHa!;
      final formatted = (ha - ha.truncate()).abs() < 0.05
          ? ha.toStringAsFixed(0)
          : ha.toStringAsFixed(1);
      parts.add('$formatted ha');
    }
    if (p.contour.isNotEmpty) {
      final pt = p.contour.first;
      parts.add('GPS ${pt.lat.toStringAsFixed(2)}, ${pt.lng.toStringAsFixed(2)}');
    } else {
      parts.add('GPS 5.36, -4.01');
    }
    return parts.join(' · ');
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kPrimarySoft, width: AppDimens.borderThin),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─── Section cultures ────────────────────────────────────────────────────

class _SectionCultures extends StatelessWidget {
  const _SectionCultures({
    required this.cultures,
    required this.produitsById,
    required this.onAjouter,
  });

  final List<Culture> cultures;
  final Map<String, Produit> produitsById;
  final VoidCallback onAjouter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.space12),
          child: Text(
            'Cultures sur cette parcelle',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (cultures.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.space12),
            child: Text(
              'Aucune culture enregistrée sur cette parcelle.',
              style: AppTextStyles.bodySmall,
            ),
          )
        else
          for (final c in cultures)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CultureCard(
                culture: c,
                produit: c.produitId.isNotEmpty
                    ? produitsById[c.produitId]
                    : null,
              ),
            ),
        const SizedBox(height: 6),
        _BoutonSecondaire(
          label: '+ Ajouter une culture',
          onTap: onAjouter,
        ),
      ],
    );
  }
}

class _CultureCard extends StatelessWidget {
  const _CultureCard({required this.culture, required this.produit});

  final Culture culture;
  final Produit? produit;

  @override
  Widget build(BuildContext context) {
    final nom = (culture.produitNom != null && culture.produitNom!.isNotEmpty)
        ? culture.produitNom!
        : (produit?.nom ?? 'Culture');
    final thumb = (produit != null && _kProduitThumbBySlug[produit!.slug] != null)
        ? _kProduitThumbBySlug[produit!.slug]!
        : _kProduitThumbFallback;
    final ha = culture.superficieHa;
    final superficieTxt = ha != null
        ? (ha - ha.truncate()).abs() < 0.05
            ? '${ha.toStringAsFixed(0)} ha'
            : '${ha.toStringAsFixed(1)} ha'
        : '— ha';
    final statut = _formatStatut(culture);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              imageUrl: thumb,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) => Container(color: AppColors.surfaceSoft),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  superficieTxt,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusChip(label: statut.label, isWarn: statut.isWarn),
        ],
      ),
    );
  }

  /// Mappe le `statut` libre côté API vers une étiquette FR + couleur.
  ({String label, bool isWarn}) _formatStatut(Culture c) {
    final raw = c.statut?.toUpperCase().trim() ?? '';
    if (raw.contains('SEMER') || raw == 'TO_SOW' || raw == 'PLANNED') {
      return (label: 'À semer', isWarn: true);
    }
    return (label: 'En production', isWarn: false);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.isWarn});

  final String label;
  final bool isWarn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isWarn ? _kWarnSoft : _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isWarn ? _kWarn : AppColors.primary,
        ),
      ),
    );
  }
}

// ─── Bouton secondaire (bordure verte, fond blanc) ───────────────────────

class _BoutonSecondaire extends StatelessWidget {
  const _BoutonSecondaire({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ─── Lien rouge "Supprimer" ─────────────────────────────────────────────

class _DangerLink extends StatelessWidget {
  const _DangerLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'Supprimer cette parcelle',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}
