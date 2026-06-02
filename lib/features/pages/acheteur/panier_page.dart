import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/panier.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../state/badges_state.dart';
import '../../widgets/acheteur/commandes/bouton_sticky_commander.dart';
import '../../widgets/acheteur/commandes/carte_adresse_panier.dart';
import '../../widgets/acheteur/commandes/carte_item_panier.dart';
import '../../widgets/acheteur/commandes/champ_coupon_panier.dart';
import '../../widgets/acheteur/commandes/entete_panier_acheteur.dart';
import '../../widgets/acheteur/commandes/recap_panier.dart';
import '../../widgets/acheteur/commandes/titre_section_panier.dart';
import '../../widgets/acheteur/commandes/vue_panier_vide.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

/// Frais service appliqués côté UI (1 % du sous-total).
///
/// NB : la livraison est calculée par le backend au moment du paiement —
/// ici on n'affiche pas de ligne livraison tant que la commande n'est pas
/// créée. Le récap final reste honnête.
const double _kFraisServiceTaux = 0.01;

final _panierProvider = FutureProvider.autoDispose<Panier>((ref) async {
  return ref.read(marketplaceServiceProvider).getPanier();
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
    // Invalide d'abord le provider local (la page panier) ET le badge
    // global (icône header) — sinon le compteur du header reste
    // obsolète quand l'utilisateur quitte la page. Les deux ciblent
    // la même API (getPanier) mais sont des providers distincts.
    ref.invalidate(_panierProvider);
    ref.invalidate(cartCountProvider);
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
              EntetePanierAcheteur(count: 0, onVider: null),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const EntetePanierAcheteur(count: 0, onVider: null),
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
        EntetePanierAcheteur(
          count: panier.items.length,
          onVider: panier.items.isEmpty ? null : () => _viderTout(panier),
        ),
        Expanded(
          child: panier.items.isEmpty
              ? const VuePanierVide()
              : Stack(
                  children: [
                    RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _refresh,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                        children: [
                          ...panier.items.map(
                            (it) => CarteItemPanier(
                              item: it,
                              suppressionEnCours: _itemEnSuppression == it.id,
                              onSupprimer: () => _supprimerItem(it),
                            ),
                          ),
                          const TitreSectionPanier(label: 'Adresse de livraison'),
                          CarteAdressePanier(onModifier: _modifierAdresse),
                          const TitreSectionPanier(label: 'Code promo'),
                          ChampCouponPanier(
                            controller: _promoCtrl,
                            onAppliquer: _appliquerPromo,
                          ),
                          const TitreSectionPanier(label: 'Récapitulatif'),
                          RecapPanier(
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
                      child: BoutonStickyCommander(
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
