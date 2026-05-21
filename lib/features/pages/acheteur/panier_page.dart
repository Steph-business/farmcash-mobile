import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/buyer_address.dart';
import '../../../models/panier.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── Couleurs locales ───────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Frais service appliqués côté UI (1 % du sous-total).
///
/// NB : la livraison est calculée par le backend au moment du paiement —
/// ici on n'affiche pas de ligne livraison tant que la commande n'est pas
/// créée. Le récap final reste honnête.
const double _kFraisServiceTaux = 0.01;

final _panierProvider = FutureProvider.autoDispose<Panier>((ref) async {
  return ref.read(marketplaceServiceProvider).getPanier();
});

/// Adresse de livraison par défaut du BUYER, si elle existe.
final _defaultAddressProvider =
    FutureProvider.autoDispose<BuyerAddress?>((ref) async {
  final addresses = await ref.read(buyerServiceProvider).listAddresses();
  for (final a in addresses) {
    if (a.isDefault) return a;
  }
  return addresses.isEmpty ? null : addresses.first;
});

class PanierAcheteurPage extends ConsumerStatefulWidget {
  const PanierAcheteurPage({super.key});

  @override
  ConsumerState<PanierAcheteurPage> createState() =>
      _PanierAcheteurPageState();
}

class _PanierAcheteurPageState extends ConsumerState<PanierAcheteurPage> {
  final TextEditingController _promoCtrl = TextEditingController();
  String? _itemEnSuppression;

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(_panierProvider);
    await ref.read(_panierProvider.future);
  }

  Future<void> _supprimerItem(PanierItem item) async {
    if (_itemEnSuppression != null) return;
    setState(() => _itemEnSuppression = item.id);
    try {
      await ref.read(marketplaceServiceProvider).removeFromPanier(item.id);
      await _refresh();
      if (mounted) {
        Snackbars.showInfo(context, 'Article retiré du panier');
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _itemEnSuppression = null);
    }
  }

  void _modifierAdresse() {
    context.push(RouteNames.acheteurAdressesLivraisonPath);
  }

  void _appliquerPromo() {
    final code = _promoCtrl.text.trim();
    if (code.isEmpty) return;
    Snackbars.showInfo(context, 'Code « $code » appliqué (à venir)');
  }

  void _commander(Panier panier) {
    if (panier.items.isEmpty) return;
    // V1 mono-vendeur : on ouvre le paiement sur l'annonce du premier
    // item (le backend force déjà un seul vendeur par panier dans la pratique).
    final first = panier.items.first;
    context.push(
      RouteNames.acheteurPaiementCommandePathFor(first.annonceId),
      extra: {'quantiteKg': first.quantiteKg.toInt()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_panierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              _Header(count: 0, onVider: null),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const _Header(count: 0, onVider: null),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le panier. $e',
                    onRetry: _refresh,
                  ),
                ),
              ),
            ],
          ),
          data: (panier) => _buildPanier(panier),
        ),
      ),
    );
  }

  Widget _buildPanier(Panier panier) {
    final sousTotal = panier.total;
    final fraisService = (sousTotal * _kFraisServiceTaux).round();
    final total = sousTotal.round() + fraisService;

    return Column(
      children: [
        _Header(
          count: panier.items.length,
          onVider: panier.items.isEmpty ? null : () => _viderTout(panier),
        ),
        Expanded(
          child: panier.items.isEmpty
              ? const _EmptyPanier()
              : Stack(
                  children: [
                    RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _refresh,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                        children: [
                          ...panier.items.map(
                            (it) => _ItemCard(
                              item: it,
                              suppressionEnCours: _itemEnSuppression == it.id,
                              onSupprimer: () => _supprimerItem(it),
                            ),
                          ),
                          const _SectionTitle(label: 'Adresse de livraison'),
                          _AddrCard(onModifier: _modifierAdresse),
                          const _SectionTitle(label: 'Code promo'),
                          _Coupon(
                            controller: _promoCtrl,
                            onAppliquer: _appliquerPromo,
                          ),
                          const _SectionTitle(label: 'Récapitulatif'),
                          _Recap(
                            sousTotal: sousTotal.round(),
                            fraisService: fraisService,
                            total: total,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _StickyBottom(
                        total: total,
                        onCommander: () => _commander(panier),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _viderTout(Panier panier) async {
    for (final it in panier.items) {
      try {
        await ref.read(marketplaceServiceProvider).removeFromPanier(it.id);
      } catch (_) {/* on continue */}
    }
    await _refresh();
    if (mounted) Snackbars.showInfo(context, 'Panier vidé');
  }
}

// ─── Header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.onVider});

  final int count;
  final VoidCallback? onVider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.accueilAcheteurPath);
              }
            },
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
              'Mon panier ($count)',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: onVider,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                'Vider',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: onVider == null
                      ? AppColors.textSubtle
                      : AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Item card ─────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.suppressionEnCours,
    required this.onSupprimer,
  });

  final PanierItem item;
  final bool suppressionEnCours;
  final VoidCallback onSupprimer;

  @override
  Widget build(BuildContext context) {
    final titre = item.annonceTitre ?? 'Annonce';
    final photo = item.annoncePhotoUrl;
    final vendeur = item.vendeurNom ?? 'Vendeur';
    final loc = item.localisation;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: photo != null
                  ? CachedNetworkImage(
                      imageUrl: photo,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: AppColors.surfaceSoft),
                      errorWidget: (_, _, _) => const Icon(
                        Icons.image_outlined,
                        size: 28,
                        color: AppColors.textSubtle,
                      ),
                    )
                  : const Icon(
                      Icons.image_outlined,
                      size: 28,
                      color: AppColors.textSubtle,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$vendeur${loc != null ? ' · $loc' : ''}',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_fmtKg(item.quantiteKg)} · ${_fmtFcfa(item.prixUnitaire.round())}/kg',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fmtFcfa(item.sousTotal.round()),
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: suppressionEnCours ? null : onSupprimer,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: suppressionEnCours
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textSubtle,
                        ),
                      )
                    : const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sections ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _AddrCard extends ConsumerWidget {
  const _AddrCard({required this.onModifier});
  final VoidCallback onModifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_defaultAddressProvider);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _addrContent(async)),
          InkWell(
            onTap: onModifier,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                async.maybeWhen(
                  data: (a) => a == null ? 'Choisir' : 'Modifier',
                  orElse: () => 'Modifier',
                ),
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addrContent(AsyncValue<BuyerAddress?> async) {
    return async.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chargement de l\'adresse…',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      error: (_, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Adresse indisponible',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Configure une adresse pour la livraison',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      data: (addr) {
        if (addr == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choisir une adresse',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Sélectionne ton adresse de livraison',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }
        final adresseComplete = addr.adresseComplete.trim();
        final ville = addr.villeNom?.trim();
        final adresseLine = [
          if (adresseComplete.isNotEmpty) adresseComplete,
          if (ville != null && ville.isNotEmpty) ville,
        ].join(' · ');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              addr.libelle,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (adresseLine.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                adresseLine,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Coupon extends StatelessWidget {
  const _Coupon({required this.controller, required this.onAppliquer});
  final TextEditingController controller;
  final VoidCallback onAppliquer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.borderStrong,
                width: AppDimens.borderThin,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                hintText: 'Saisir un code',
                hintStyle: AppTextStyles.hint.copyWith(
                  fontSize: 13,
                  color: AppColors.textSubtle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onAppliquer,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary,
                width: AppDimens.borderThin,
              ),
            ),
            child: Text(
              'Appliquer',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Recap extends StatelessWidget {
  const _Recap({
    required this.sousTotal,
    required this.fraisService,
    required this.total,
  });

  final int sousTotal;
  final int fraisService;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row('Sous-total', _fmtFcfa(sousTotal), divider: true),
          _row('Frais service (1%)', _fmtFcfa(fraisService), divider: true),
          _row(
            'Livraison',
            'Calculée au paiement',
            divider: true,
            italic: true,
          ),
          _row('Total estimé', _fmtFcfa(total), isTotal: true),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool divider = false,
    bool isTotal = false,
    bool italic = false,
  }) {
    final labelStyle = isTotal
        ? AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          )
        : AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          );
    final valueStyle = isTotal
        ? AppTextStyles.headlineMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontFamily: 'Poppins',
          )
        : AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          );
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: divider ? AppColors.border : Colors.transparent,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: 12),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

class _StickyBottom extends StatelessWidget {
  const _StickyBottom({required this.total, required this.onCommander});
  final int total;
  final VoidCallback onCommander;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: InkWell(
        onTap: onCommander,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: AppDimens.buttonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Commander · ',
                style: AppTextStyles.button.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimary,
                ),
              ),
              Text(
                _fmtFcfa(total),
                style: AppTextStyles.headlineSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPanier extends StatelessWidget {
  const _EmptyPanier();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Votre panier est vide',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'Parcourez le marché pour ajouter des produits.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');

String _fmtFcfa(int value) => '${_nf.format(value)} F';

String _fmtKg(double v) => '${_nf.format(v.round())} kg';
