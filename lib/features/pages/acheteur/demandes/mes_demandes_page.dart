import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/annonce_achat.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';

// ─── Couleurs accent ───────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// ─── Photos auto par produit ───────────────────────────────────────────

const String _kMaisThumb =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';
const String _kManiocThumb =
    'https://images.unsplash.com/photo-1574484284002-952d92456975?w=200&h=200&fit=crop&auto=format';
const String _kTomateThumb =
    'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=200&h=200&fit=crop&auto=format';
const String _kBananeThumb =
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=200&h=200&fit=crop&auto=format';

String _thumbForProduit(String produitNom) {
  final n = produitNom.toLowerCase();
  if (n.contains('manioc')) return _kManiocThumb;
  if (n.contains('tomate')) return _kTomateThumb;
  if (n.contains('banane') || n.contains('plantain')) return _kBananeThumb;
  return _kMaisThumb;
}

// ─── Modèle d'affichage ────────────────────────────────────────────────

class _MockDemandeAcheteur {
  const _MockDemandeAcheteur({
    required this.id,
    required this.produitNom,
    required this.quantite,
    required this.prixMaxLabel,
    required this.villeLabel,
    required this.propositions,
    required this.publieIlYa,
    required this.photoUrl,
  });
  final String id;
  final String produitNom;
  final String quantite;
  final String prixMaxLabel;
  final String villeLabel;
  final int propositions;
  final String publieIlYa;
  final String photoUrl;
}

const List<_MockDemandeAcheteur> _kMockDemandes = [
  _MockDemandeAcheteur(
    id: 'demande-1',
    produitNom: 'Maïs blanc',
    quantite: '500 kg',
    prixMaxLabel: 'max 850 F/kg',
    villeLabel: 'Cocody',
    propositions: 5,
    publieIlYa: 'publiée il y a 2j',
    photoUrl: _kMaisThumb,
  ),
  _MockDemandeAcheteur(
    id: 'demande-2',
    produitNom: 'Manioc frais',
    quantite: '300 kg',
    prixMaxLabel: 'max 400 F/kg',
    villeLabel: 'Yopougon',
    propositions: 4,
    publieIlYa: 'publiée il y a 4j',
    photoUrl: _kManiocThumb,
  ),
  _MockDemandeAcheteur(
    id: 'demande-3',
    produitNom: 'Tomate fraîche',
    quantite: '50 kg',
    prixMaxLabel: 'max 1 200 F/kg',
    villeLabel: 'Cocody',
    propositions: 3,
    publieIlYa: 'publiée hier',
    photoUrl: _kTomateThumb,
  ),
];

_MockDemandeAcheteur _annonceAchatToMock(AnnonceAchat a) {
  final produit = a.titre ?? 'Produit';
  return _MockDemandeAcheteur(
    id: a.id,
    produitNom: produit,
    quantite: '${a.quantiteKg.toStringAsFixed(0)} kg',
    prixMaxLabel: 'max ${a.prixMaxKg.toStringAsFixed(0)} F/kg',
    villeLabel: a.regionId ?? '—',
    propositions: 0,
    publieIlYa: 'publiée récemment',
    photoUrl: _thumbForProduit(produit),
  );
}

final _mesDemandesProvider =
    FutureProvider.autoDispose<List<_MockDemandeAcheteur>>((ref) async {
  try {
    final p = await ref.watch(marketplaceServiceProvider).listAnnoncesAchat();
    if (p.data.isEmpty) return _kMockDemandes;
    return p.data.map(_annonceAchatToMock).toList(growable: false);
  } catch (_) {
    return _kMockDemandes;
  }
});

enum _Tab { actives, conclues, archivees }

/// Liste des demandes d'achat publiées par l'acheteur connecté.
/// Calque sur `mockups/acheteur/mes_demandes.html`.
class MesDemandesAcheteurPage extends ConsumerStatefulWidget {
  const MesDemandesAcheteurPage({super.key});

  @override
  ConsumerState<MesDemandesAcheteurPage> createState() =>
      _MesDemandesAcheteurPageState();
}

class _MesDemandesAcheteurPageState
    extends ConsumerState<MesDemandesAcheteurPage> {
  _Tab _tab = _Tab.actives;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_mesDemandesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (_, _) => _Body(
                  items: _kMockDemandes,
                  tab: _tab,
                  onTabChange: (t) => setState(() => _tab = t),
                ),
                data: (items) => _Body(
                  items: items,
                  tab: _tab,
                  onTabChange: (t) => setState(() => _tab = t),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
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
            child: Text(
              'Mes demandes',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Body ──────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.items,
    required this.tab,
    required this.onTabChange,
  });
  final List<_MockDemandeAcheteur> items;
  final _Tab tab;
  final ValueChanged<_Tab> onTabChange;

  @override
  Widget build(BuildContext context) {
    final actives = items.length;
    final totalPropositions =
        items.fold<int>(0, (sum, d) => sum + d.propositions);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ─ Counter primary-soft ─
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
          child: Container(
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: '$actives demandes actives',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' · '),
                  TextSpan(text: '$totalPropositions propositions reçues'),
                ],
              ),
            ),
          ),
        ),
        // ─ Tabs ─
        _Tabs(
          tab: tab,
          activesCount: actives,
          onChange: onTabChange,
        ),
        const SizedBox(height: 14),
        // ─ Cards ─
        if (tab == _Tab.actives)
          for (final d in items) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: _DemandeCard(demande: d),
            ),
          ]
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: Text(
                tab == _Tab.conclues
                    ? 'Aucune demande conclue pour l\'instant.'
                    : 'Aucune demande archivée.',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Tabs ──────────────────────────────────────────────────────────────

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.tab,
    required this.activesCount,
    required this.onChange,
  });
  final _Tab tab;
  final int activesCount;
  final ValueChanged<_Tab> onChange;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            _TabItem(
              label: 'Actives ($activesCount)',
              active: tab == _Tab.actives,
              onTap: () => onChange(_Tab.actives),
            ),
            const SizedBox(width: 18),
            _TabItem(
              label: 'Conclues',
              active: tab == _Tab.conclues,
              onTap: () => onChange(_Tab.conclues),
            ),
            const SizedBox(width: 18),
            _TabItem(
              label: 'Archivées',
              active: tab == _Tab.archivees,
              onTap: () => onChange(_Tab.archivees),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Card demande ──────────────────────────────────────────────────────

class _DemandeCard extends StatelessWidget {
  const _DemandeCard({required this.demande});
  final _MockDemandeAcheteur demande;
  @override
  Widget build(BuildContext context) {
    final hasProps = demande.propositions > 0;
    return InkWell(
      onTap: () => context.push(
        RouteNames.acheteurPropositionsRecuesPathFor(demande.id),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo produit 60×60
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: demande.photoUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surfaceSoft,
                ),
                errorWidget: (_, _, _) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surfaceSoft,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${demande.produitNom} · ${demande.quantite}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${demande.prixMaxLabel} · ${demande.villeLabel}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${demande.propositions} propositions reçues · ${demande.publieIlYa}',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasProps ? _kPrimarySoft : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    hasProps
                        ? '${demande.propositions} propositions'
                        : 'En attente',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          hasProps ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSubtle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

