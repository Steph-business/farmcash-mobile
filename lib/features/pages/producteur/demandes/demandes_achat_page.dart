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

// ─── Couleurs accent (warn-soft / coop-orange) ───────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kCoopOrangeBg = Color(0xFFFFF3E0);
const Color _kCoopOrangeFg = Color(0xFFE65100);
const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarn = Color(0xFFB45309);

const String _kMaisThumb =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';
const String _kManiocThumb =
    'https://images.unsplash.com/photo-1574484284002-952d92456975?w=200&h=200&fit=crop&auto=format';
const String _kTomateThumb =
    'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=200&h=200&fit=crop&auto=format';
const String _kBananeThumb =
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=200&h=200&fit=crop&auto=format';

/// Vignette par défaut quand le produit n'est pas identifié.
const String _kDefaultThumb = _kMaisThumb;

/// Choisit une vignette Unsplash selon le nom du produit (mots-clés).
String _thumbForProduit(String produitNom) {
  final n = produitNom.toLowerCase();
  if (n.contains('manioc')) return _kManiocThumb;
  if (n.contains('tomate')) return _kTomateThumb;
  if (n.contains('banane') || n.contains('plantain')) return _kBananeThumb;
  return _kMaisThumb;
}

// ─── Modèle d'affichage local ────────────────────────────────────────────

class _MockDemande {
  final String id;
  final String buyerNom;
  final String buyerAvatar;
  final String ville;
  final bool viaCoop;
  final String produitNom;
  final String produitThumb;
  final String quantite;
  final String prixMaxLabel;
  final String publieIlYa;
  final String livraisonLabel;
  final bool urgent;

  const _MockDemande({
    required this.id,
    required this.buyerNom,
    required this.buyerAvatar,
    required this.ville,
    required this.viaCoop,
    required this.produitNom,
    required this.produitThumb,
    required this.quantite,
    required this.prixMaxLabel,
    required this.publieIlYa,
    required this.livraisonLabel,
    required this.urgent,
  });
}


// ─── Filtres ──────────────────────────────────────────────────────────────

class _Filtre {
  final String key;
  final String label;
  final int count;
  const _Filtre(this.key, this.label, this.count);
}

const List<_Filtre> _kFiltres = [
  _Filtre('all', 'Toutes', 8),
  _Filtre('mais', 'Maïs', 3),
  _Filtre('manioc', 'Manioc', 2),
  _Filtre('tomate', 'Tomate', 2),
  _Filtre('banane', 'Banane', 1),
];

/// Récupère les demandes d'achat publiques depuis le backend. Pas de
/// fallback mock — si l'API renvoie vide ou échoue, l'UI affiche un état
/// vide / erreur honnête.
final _demandesProvider =
    FutureProvider.autoDispose<List<_MockDemande>>((ref) async {
  final paginated =
      await ref.read(marketplaceServiceProvider).listAnnoncesAchat();
  return paginated.data.map(_annonceAchatToMock).toList(growable: false);
});

/// Convertit une `AnnonceAchat` backend (avec ses relations jointes) en
/// modèle d'affichage local. Utilise le nom du buyer et la région réels
/// quand le back les fournit.
_MockDemande _annonceAchatToMock(AnnonceAchat a) {
  final produitNom = a.produitLabel;
  final qte = a.quantiteKg.toStringAsFixed(0);
  final prixMax = a.prixMaxKg.toStringAsFixed(0);
  final total = (a.prixMaxKg * a.quantiteKg).toStringAsFixed(0);
  return _MockDemande(
    id: a.id,
    buyerNom: a.buyerNom ?? 'Acheteur',
    buyerAvatar: a.buyer?.photoUrl ?? _kDefaultThumb,
    ville: a.regionNom ?? '—',
    viaCoop: a.targetCooperativeId != null,
    produitNom: produitNom,
    produitThumb: _thumbForProduit(produitNom),
    quantite: '$qte kg de $produitNom',
    prixMaxLabel: 'jusqu\'à $prixMax F/kg · soit max $total F',
    publieIlYa: a.createdAt != null ? 'Publié récemment' : '—',
    livraisonLabel:
        a.dateLimiteLivraison != null ? 'Livraison sous délai' : 'À convenir',
    urgent: false,
  );
}

/// Liste des demandes d'achat qui matchent les cultures du producteur.
class DemandesAchatPage extends ConsumerStatefulWidget {
  const DemandesAchatPage({super.key});

  @override
  ConsumerState<DemandesAchatPage> createState() => _DemandesAchatPageState();
}

class _DemandesAchatPageState extends ConsumerState<DemandesAchatPage> {
  String _activeFilter = 'all';

  List<_MockDemande> _filter(List<_MockDemande> items) {
    if (_activeFilter == 'all') return items;
    return items.where((d) {
      final n = d.produitNom.toLowerCase();
      switch (_activeFilter) {
        case 'mais':
          return n.contains('maïs') || n.contains('mais');
        case 'manioc':
          return n.contains('manioc');
        case 'tomate':
          return n.contains('tomate');
        case 'banane':
          return n.contains('banane') || n.contains('plantain');
        default:
          return true;
      }
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_demandesProvider);

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
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: Center(
                    child: Text(
                      'Impossible de charger les demandes. $e',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (items) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(_demandesProvider);
                    await ref.read(_demandesProvider.future);
                  },
                  child: _Body(
                    items: _filter(items),
                    activeFilter: _activeFilter,
                    onFilterChange: (k) => setState(() => _activeFilter = k),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
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
            child: Text(
              'Acheteurs qui cherchent',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.items,
    required this.activeFilter,
    required this.onFilterChange,
  });

  final List<_MockDemande> items;
  final String activeFilter;
  final ValueChanged<String> onFilterChange;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        _Counter(actives: items.length),
        AppDimens.vGap16,
        _FilterChips(active: activeFilter, onChange: onFilterChange),
        AppDimens.vGap16,
        for (final d in items) ...[
          _DemandeCard(demande: d),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ─── Counter (primary-soft) ──────────────────────────────────────────────

class _Counter extends StatelessWidget {
  const _Counter({required this.actives});

  final int actives;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Demandes qui matchent tes cultures',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '$actives actives',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filtres chips horizontaux ───────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.active, required this.onChange});

  final String active;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _kFiltres.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _kFiltres[i];
          final isActive = f.key == active;
          return InkWell(
            onTap: () => onChange(f.key),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${f.label} (${f.count})',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Card demande ────────────────────────────────────────────────────────

class _DemandeCard extends StatelessWidget {
  const _DemandeCard({required this.demande});

  final _MockDemande demande;

  @override
  Widget build(BuildContext context) {
    final qteLine = demande.quantite;
    final prixLine = demande.prixMaxLabel;
    return InkWell(
      onTap: () => context.push(
        RouteNames.producteurDemandeAchatRepondrePathFor(demande.id),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Row(
              children: [
                ClipOval(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      border: Border.all(
                        color: AppColors.border,
                        width: AppDimens.borderThin,
                      ),
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage(
                      imageUrl: demande.buyerAvatar,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: AppColors.surfaceSoft),
                      errorWidget: (_, _, _) =>
                          Container(color: AppColors.surfaceSoft),
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
                        demande.buyerNom,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        demande.ville,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _TargetChip(viaCoop: demande.viaCoop),
              ],
            ),
            const SizedBox(height: 10),

            // Besoin (bg-soft) + vignette à droite
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          qteLine,
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prixLine,
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        border: Border.all(
                          color: AppColors.border,
                          width: AppDimens.borderThin,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        imageUrl: demande.produitThumb,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: AppColors.surfaceSoft),
                        errorWidget: (_, _, _) =>
                            Container(color: AppColors.surfaceSoft),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Meta row : publié + chip livraison
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  demande.publieIlYa,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: demande.urgent ? _kWarnSoft : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    demande.livraisonLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          demande.urgent ? _kWarn : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({required this.viaCoop});

  final bool viaCoop;

  @override
  Widget build(BuildContext context) {
    final bg = viaCoop ? _kCoopOrangeBg : _kPrimarySoft;
    final fg = viaCoop ? _kCoopOrangeFg : AppColors.primary;
    final label = viaCoop ? 'Via ma coop' : 'Public';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

