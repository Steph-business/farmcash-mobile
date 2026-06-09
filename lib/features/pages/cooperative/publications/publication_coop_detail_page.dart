import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/publication_coop.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/orders_service.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/bandeau_intervalle_recolte.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/demandes/demande_achat_modeles.dart'
    show thumbForProduit;

/// Bundle exposé à l'UI : publication + commandes filtrées sur cette
/// publication (déduites du flux `side=seller`). Le backend n'expose pas
/// (encore) `GET /coop/publications/:id/commandes` — on filtre côté client.
class _DetailBundle {
  const _DetailBundle({
    required this.publication,
    required this.commandes,
  });
  final PublicationCoop publication;
  final List<OrderListItem> commandes;
}

/// Famille de provider sur l'id de la publication. Recharge à la fois la
/// publication elle-même (`GET /cooperatives/publications/:id`, public —
/// fournit le shape complet : titre, quantité, prix, qualité, status,
/// nb_contributeurs) et les commandes du seller (filtrées côté client par
/// `publicationCoopId`).
final _detailPublicationCoopProvider = FutureProvider.autoDispose
    .family<_DetailBundle, String>((ref, publicationId) async {
  final coopSvc = ref.read(cooperativesServiceProvider);
  final ordersSvc = ref.read(ordersServiceProvider);

  // 1. La publication — endpoint public coop, expose tous les champs.
  final pub = await coopSvc.getPublication(publicationId);

  // 2. Les commandes côté vendeur ; on filtre celles qui pointent sur cette
  // publication. À défaut d'un endpoint dédié backend, on charge la
  // première page (limit 100 suffisant pour une publication active) et on
  // garde uniquement les commandes liées via `publication_coop_id`.
  List<OrderListItem> commandes;
  try {
    final page =
        await ordersSvc.listMyOrdersWithJoins(side: 'seller', limit: 100);
    commandes = page.data
        .where((o) => o.commande.publicationCoopId == publicationId)
        .toList(growable: false);
  } catch (_) {
    commandes = const <OrderListItem>[];
  }

  return _DetailBundle(publication: pub, commandes: commandes);
});

/// Détail d'une publication coop — vue COOP propriétaire.
///
/// Différent de `producteur/publications/publication_coop_detail_page.dart`
/// qui est la vue lecture côté membre (sa part dans l'agrégat). Ici, la
/// coopérative voit la publication qu'elle a créée, les commandes reçues
/// dessus, et peut la clôturer.
class PublicationCoopDetailPage extends ConsumerWidget {
  const PublicationCoopDetailPage({super.key, required this.id});

  /// UUID de la publication coop.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_detailPublicationCoopProvider(id));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _HeaderPublicationCoop(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la publication. $e',
                    onRetry: () =>
                        ref.invalidate(_detailPublicationCoopProvider(id)),
                  ),
                ),
                data: (bundle) => _DetailContent(bundle: bundle),
              ),
            ),
            async.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (bundle) {
                if (bundle.publication.status != ProductStatus.active &&
                    bundle.publication.status != ProductStatus.unknown) {
                  return const SizedBox.shrink();
                }
                return _StickyBoutonFermer(
                  publicationId: id,
                  onClosed: () =>
                      ref.invalidate(_detailPublicationCoopProvider(id)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────

class _HeaderPublicationCoop extends StatelessWidget {
  const _HeaderPublicationCoop();

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
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.cooperativeMarchePath),
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
              'Publication',
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

// ─── Contenu scrollable ─────────────────────────────────────────────────

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.bundle});

  final _DetailBundle bundle;

  @override
  Widget build(BuildContext context) {
    final pub = bundle.publication;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space24,
      ),
      children: [
        _HeroPublication(pub: pub),
        AppDimens.vGap12,
        // Bandeau intervalle de récolte (visible UNIQUEMENT si les
        // contributions ont une date_recolte). Cache silencieusement
        // sinon — pas de placeholder.
        BandeauIntervalleRecolte(publication: pub),
        AppDimens.vGap16,
        _SectionTitre('Détails'),
        AppDimens.vGap12,
        _StatsCard(pub: pub),
        AppDimens.vGap16,
        _SectionTitre('Composition'),
        AppDimens.vGap12,
        _CompositionCard(pub: pub),
        AppDimens.vGap16,
        _SectionTitre('Commandes reçues'),
        AppDimens.vGap12,
        _CommandesSection(commandes: bundle.commandes),
      ],
    );
  }
}

// ─── Hero : photo + titre + badge statut ────────────────────────────────

class _HeroPublication extends StatelessWidget {
  const _HeroPublication({required this.pub});

  final PublicationCoop pub;

  @override
  Widget build(BuildContext context) {
    // Image : on privilégie la 1re photo de la publication, sinon on
    // retombe sur la vignette par produit (thumbForProduit, du dossier
    // demandes — réutilisé pour cohérence visuelle des fiches).
    final photoUrl = pub.photos.isNotEmpty
        ? pub.photos.first
        : thumbForProduit(pub.titre);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    const ColoredBox(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.surfaceSoft,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.textSubtle,
                    size: 28,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pub.titre,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  AppDimens.vGap8,
                  _BadgeStatut(status: pub.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeStatut extends StatelessWidget {
  const _BadgeStatut({required this.status});

  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = _stylePour(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  (String, Color, Color) _stylePour(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
      case ProductStatus.unknown:
        return ('Active', AppColors.success, const Color(0xFFE6F4EA));
      case ProductStatus.paused:
        return ('En pause', const Color(0xFFB45309), const Color(0xFFFEF3C7));
      case ProductStatus.sold:
        return ('Vendue', AppColors.textSecondary, AppColors.surfaceSoft);
      case ProductStatus.expired:
        return ('Clôturée', AppColors.textSecondary, AppColors.surfaceSoft);
      case ProductStatus.draft:
        return ('Brouillon', AppColors.textSecondary, AppColors.surfaceSoft);
    }
  }
}

// ─── Section titre ──────────────────────────────────────────────────────

class _SectionTitre extends StatelessWidget {
  const _SectionTitre(this.titre);

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Text(
      titre,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─── Carte stats (qté, prix/kg, valeur totale) ──────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.pub});

  final PublicationCoop pub;

  @override
  Widget build(BuildContext context) {
    final valeurTotale = pub.quantiteKg * pub.prixParKg;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          _LigneStat(
            icon: Icons.scale_outlined,
            label: 'Quantité totale',
            value: '${_nf.format(pub.quantiteKg.round())} kg',
          ),
          const _DividerStat(),
          _LigneStat(
            icon: Icons.local_offer_outlined,
            label: 'Prix par kg',
            value: '${_nf.format(pub.prixParKg.round())} F CFA',
          ),
          const _DividerStat(),
          _LigneStat(
            icon: Icons.payments_outlined,
            label: 'Valeur totale',
            value: '${_nf.format(valeurTotale.round())} F CFA',
            valueAccent: true,
          ),
          const _DividerStat(),
          _LigneStat(
            icon: Icons.verified_outlined,
            label: 'Qualité',
            value: _qualiteLabel(pub.qualite),
          ),
        ],
      ),
    );
  }
}

class _DividerStat extends StatelessWidget {
  const _DividerStat();
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 18,
      thickness: AppDimens.borderHairline,
      color: AppColors.border,
    );
  }
}

class _LigneStat extends StatelessWidget {
  const _LigneStat({
    required this.icon,
    required this.label,
    required this.value,
    this.valueAccent = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool valueAccent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppDimens.iconM, color: AppColors.textSecondary),
        AppDimens.hGap12,
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueAccent ? AppColors.primary : AppColors.text,
          ),
        ),
      ],
    );
  }
}

String _qualiteLabel(ProductQuality q) {
  switch (q) {
    case ProductQuality.standard:
      return 'Standard';
    case ProductQuality.premium:
      return 'Premium';
    case ProductQuality.bio:
      return 'Bio';
    case ProductQuality.equitable:
      return 'Équitable';
    case ProductQuality.unknown:
      return '—';
  }
}

// ─── Composition (nb contributeurs) ─────────────────────────────────────

class _CompositionCard extends StatelessWidget {
  const _CompositionCard({required this.pub});

  final PublicationCoop pub;

  @override
  Widget build(BuildContext context) {
    final nb = pub.nbContributeurs;
    final label = nb == 0
        ? 'Publication directe — pas d\'agrégation depuis des annonces membres'
        : nb == 1
            ? '1 annonce membre agrégée'
            : '$nb annonces membres agrégées';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE6F4EA),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.groups_outlined,
              size: 20,
              color: AppColors.success,
            ),
          ),
          AppDimens.hGap12,
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Commandes reçues ───────────────────────────────────────────────────

class _CommandesSection extends StatelessWidget {
  const _CommandesSection({required this.commandes});

  final List<OrderListItem> commandes;

  @override
  Widget build(BuildContext context) {
    if (commandes.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 22,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: const [
            Icon(
              Icons.receipt_long_outlined,
              size: 22,
              color: AppColors.textSubtle,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucune commande pour le moment.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (final c in commandes) ...[
          _CommandeRow(item: c),
          if (c != commandes.last) AppDimens.vGap8,
        ],
      ],
    );
  }
}

class _CommandeRow extends StatelessWidget {
  const _CommandeRow({required this.item});

  final OrderListItem item;

  @override
  Widget build(BuildContext context) {
    final c = item.commande;
    final buyer = (item.buyerName?.trim().isNotEmpty ?? false)
        ? item.buyerName!.trim()
        : 'Acheteur';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        onTap: () => context.push(
          RouteNames.producteurCommandeDetailPathFor(c.id),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceSoft,
                ),
                alignment: Alignment.center,
                child: Text(
                  buyer.isNotEmpty ? buyer[0].toUpperCase() : '?',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              AppDimens.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buyer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_nf.format(c.quantiteKg.round())} kg · '
                      '${_nf.format(c.montantTotal.round())} F',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppDimens.hGap8,
              _ChipStatutCommande(status: c.status),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
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

class _ChipStatutCommande extends StatelessWidget {
  const _ChipStatutCommande({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = _pour(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
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

  (String, Color, Color) _pour(OrderStatus status) {
    switch (status) {
      case OrderStatus.sent:
        return ('Envoyée', const Color(0xFFB45309), const Color(0xFFFEF3C7));
      case OrderStatus.accepted:
        return ('Acceptée', AppColors.success, const Color(0xFFE6F4EA));
      case OrderStatus.rejected:
        return ('Refusée', AppColors.error, const Color(0xFFFEE2E2));
      case OrderStatus.inProgress:
        return ('En cours', AppColors.primary, const Color(0xFFE6F4EA));
      case OrderStatus.delivered:
        return ('Livrée', AppColors.success, const Color(0xFFE6F4EA));
      case OrderStatus.completed:
        return ('Terminée', AppColors.success, const Color(0xFFE6F4EA));
      case OrderStatus.disputed:
        return ('Litige', AppColors.error, const Color(0xFFFEE2E2));
      case OrderStatus.cancelled:
        return ('Annulée', AppColors.textSecondary, AppColors.surfaceSoft);
      case OrderStatus.unknown:
        return ('—', AppColors.textSecondary, AppColors.surfaceSoft);
    }
  }
}

// ─── Sticky bouton "Fermer la publication" ──────────────────────────────

class _StickyBoutonFermer extends ConsumerStatefulWidget {
  const _StickyBoutonFermer({
    required this.publicationId,
    required this.onClosed,
  });

  final String publicationId;
  final VoidCallback onClosed;

  @override
  ConsumerState<_StickyBoutonFermer> createState() =>
      _StickyBoutonFermerState();
}

class _StickyBoutonFermerState extends ConsumerState<_StickyBoutonFermer> {
  bool _busy = false;

  Future<void> _confirmer() async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Fermer la publication ?'),
        content: const Text(
          'Elle ne sera plus visible côté marché acheteur. '
          'Les commandes déjà reçues restent valides et l\'historique '
          'est conservé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      // Pas de méthode `closePublication` dédiée côté service mobile :
      // le backend n'expose pas de route `/close` et `updatePublication`
      // avec `is_active: false` est l'équivalent métier (publication
      // masquée du marché, historique préservé).
      await ref
          .read(cooperativesServiceProvider)
          .updatePublication(widget.publicationId, isActive: false);
      if (!mounted) return;
      Snackbars.showSucces(context, 'Publication fermée.');
      widget.onClosed();
    } on ApiException catch (e) {
      messenger.hideCurrentSnackBar();
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      messenger.hideCurrentSnackBar();
      if (!mounted) return;
      Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderHairline,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space12,
        AppDimens.pagePaddingH,
        MediaQuery.of(context).padding.bottom + AppDimens.space12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppDimens.buttonHeight,
        child: TextButton.icon(
          onPressed: _busy ? null : _confirmer,
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFFEE2E2),
            foregroundColor: AppColors.error,
            disabledBackgroundColor: AppColors.surfaceSoft,
            disabledForegroundColor: AppColors.textSubtle,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radius),
            ),
          ),
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.error,
                  ),
                )
              : const Icon(Icons.lock_outline, size: 18),
          label: Text(
            _busy ? 'Fermeture…' : 'Fermer la publication',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _busy ? AppColors.textSubtle : AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}
