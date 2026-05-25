import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../models/enums.dart';
import '../../../../models/wallet_with_transactions.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/orders_service.dart' show OrderSourceType;
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/commandes/bandeau_solde_insuffisant.dart';
import '../../../widgets/acheteur/commandes/carte_adresse_livraison.dart';
import '../../../widgets/acheteur/commandes/carte_montants_paiement.dart';
import '../../../widgets/acheteur/commandes/carte_recap_paiement.dart';
import '../../../widgets/acheteur/commandes/champ_note_vendeur.dart';
import '../../../widgets/acheteur/commandes/grille_methodes_paiement.dart';
import '../../../widgets/acheteur/commandes/header_paiement_commande.dart';
import '../../../widgets/acheteur/commandes/options_livraison.dart';
import '../../../widgets/acheteur/commandes/sticky_bottom_paiement.dart';
import '../../../widgets/acheteur/commandes/titre_section_paiement.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/moyen_paiement_ajout_sheet.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Provider ─────────────────────────────────────────────────────────

class _PaiementBundle {
  const _PaiementBundle({required this.annonce, required this.wallet});
  final AnnonceVente annonce;
  final WalletWithTransactions? wallet;
}

final _paiementBundleProvider = FutureProvider.autoDispose
    .family<_PaiementBundle, String>((ref, annonceId) async {
  final svc = ref.read(marketplaceServiceProvider);
  final finance = ref.read(financeServiceProvider);
  final results = await Future.wait<dynamic>([
    svc.getAnnonceVente(annonceId),
    finance.getWallet(limit: 1).then<Object?>((v) => v).catchError((_) => null),
  ]);
  return _PaiementBundle(
    annonce: results[0] as AnnonceVente,
    wallet: results[1] as WalletWithTransactions?,
  );
});

/// Paiement d'une commande (acheteur, depuis une annonce ferme).
class PaiementCommandePage extends ConsumerStatefulWidget {
  const PaiementCommandePage({
    required this.annonceId,
    this.quantiteKgInitiale,
    super.key,
  });

  final String annonceId;
  final int? quantiteKgInitiale;

  @override
  ConsumerState<PaiementCommandePage> createState() =>
      _PaiementCommandePageState();
}

class _PaiementCommandePageState extends ConsumerState<PaiementCommandePage> {
  MobileProvider _provider = MobileProvider.wallet;
  ModeLivraisonPaiement _livraison = ModeLivraisonPaiement.auto;
  final TextEditingController _noteCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_paiementBundleProvider(widget.annonceId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              HeaderPaiementCommande(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const HeaderPaiementCommande(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la commande. $e',
                    onRetry: () => ref.invalidate(
                      _paiementBundleProvider(widget.annonceId),
                    ),
                  ),
                ),
              ),
            ],
          ),
          data: (bundle) => _build(bundle),
        ),
      ),
    );
  }

  Widget _build(_PaiementBundle bundle) {
    final annonce = bundle.annonce;
    final dispo = max(1, annonce.quantiteKg.round());
    final qteMin = (annonce.quantiteMinKg ?? 1).round().clamp(1, dispo);
    final qte = (widget.quantiteKgInitiale ?? qteMin).clamp(qteMin, dispo);
    final prix = annonce.prixParKg.round();
    final sousTotal = qte * prix;
    final frais = (sousTotal * 0.015).round();
    final total = sousTotal + frais;

    final soldeWallet = bundle.wallet?.wallet.balance ?? 0.0;
    final walletInsuffisant =
        _provider == MobileProvider.wallet && soldeWallet < total;

    return Column(
      children: [
        const HeaderPaiementCommande(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            children: [
              CarteRecapPaiement(annonce: annonce, quantiteKg: qte),
              const SizedBox(height: 18),
              const TitreSectionPaiement('Mode de livraison'),
              const SizedBox(height: 10),
              OptionsLivraison(
                selection: _livraison,
                onChange: (mode) {
                  setState(() => _livraison = mode);
                  if (mode == ModeLivraisonPaiement.choisir) {
                    context.push(
                      RouteNames.acheteurChoisirTransporteurPath,
                    );
                  }
                },
              ),
              const SizedBox(height: 18),
              const TitreSectionPaiement('Montants'),
              const SizedBox(height: 10),
              CarteMontantsPaiement(
                sousTotal: sousTotal,
                frais: frais,
                total: total,
              ),
              const SizedBox(height: 18),
              const TitreSectionPaiement('Méthode de paiement'),
              const SizedBox(height: 10),
              GrilleMethodesPaiement(
                selection: _provider,
                soldeWallet: soldeWallet,
                onSelect: (p) => setState(() => _provider = p),
              ),
              if (walletInsuffisant) ...[
                const SizedBox(height: 8),
                BandeauSoldeInsuffisant(
                  manquant: (total - soldeWallet).round(),
                  onRecharger: () =>
                      context.push(RouteNames.acheteurWalletRechargerPath),
                ),
              ],
              const SizedBox(height: 18),
              const TitreSectionPaiement('Adresse de livraison'),
              const SizedBox(height: 10),
              CarteAdresseLivraison(
                onModifier: () =>
                    context.push(RouteNames.acheteurAdressesLivraisonPath),
              ),
              const SizedBox(height: 18),
              const TitreSectionPaiement('Note pour le vendeur (optionnel)'),
              const SizedBox(height: 10),
              ChampNoteVendeur(controller: _noteCtrl),
            ],
          ),
        ),
        StickyBottomPaiement(
          total: total,
          occupe: _busy,
          active: !walletInsuffisant,
          onPayer: () => _payer(annonce, qte),
        ),
      ],
    );
  }

  Future<void> _payer(AnnonceVente annonce, int qte) async {
    if (_busy) return;
    setState(() => _busy = true);
    final idempotencyKey = _generateIdempotencyKey();
    try {
      // 1) Charger les moyens de paiement de l'acheteur. Backend exige
      // un `payment_method_id` ou un moyen marqué `is_default` ; on
      // évite l'erreur "Aucun moyen de paiement par défaut" en
      // sélectionnant explicitement côté client.
      var moyens =
          await ref.read(financeServiceProvider).listMoyensPayement();

      // Cas zéro moyen : on propose immédiatement d'en ajouter un via
      // un bottom sheet inline (au lieu de bloquer l'utilisateur avec
      // un snackbar peu actionnable). Au retour, on re-fetch et on
      // poursuit le paiement.
      if (moyens.isEmpty) {
        if (!mounted) return;
        final ajoute = await showAjouterMoyenPaiementSheet(context);
        if (ajoute == null) {
          // Utilisateur a annulé → on stoppe le paiement, sans erreur.
          return;
        }
        moyens =
            await ref.read(financeServiceProvider).listMoyensPayement();
        if (moyens.isEmpty) {
          // Sécurité : le sheet a renvoyé un moyen mais la liste est
          // vide ? incohérent — on arrête poliment.
          if (mounted) {
            Snackbars.showErreur(
              context,
              'Moyen de paiement non disponible. Réessaie.',
            );
          }
          return;
        }
      }
      // Prend le moyen `is_default` ; à défaut le premier de la liste.
      final defaultMp = moyens.firstWhere(
        (m) => m.isDefault,
        orElse: () => moyens.first,
      );

      // 2) Crée la commande avec le payment_method_id explicite.
      final commande = await ref.read(ordersServiceProvider).createOrder(
            sourceType: OrderSourceType.directAnnonceVente,
            annonceVenteId: annonce.id,
            quantiteKg: qte.toDouble(),
            paymentMethodId: defaultMp.id,
            idempotencyKey: idempotencyKey,
          );
      // Rafraîchit le wallet (le débit immédiat éventuel).
      ref.invalidate(_paiementBundleProvider(widget.annonceId));
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Commande créée · escrow activé',
      );
      context.go(RouteNames.acheteurCommandeSuccesPathFor(commande.id));
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// UUID v4 simplifié à partir de Random.secure() + timestamp. Suffisant
  /// pour l'idempotency key (côté backend : header `Idempotency-Key`).
  String _generateIdempotencyKey() {
    final rnd = Random.secure();
    String chunk(int n) {
      final buf = StringBuffer();
      for (var i = 0; i < n; i++) {
        buf.write(rnd.nextInt(16).toRadixString(16));
      }
      return buf.toString();
    }

    return '${chunk(8)}-${chunk(4)}-4${chunk(3)}-'
        '${(8 + rnd.nextInt(4)).toRadixString(16)}${chunk(3)}-${chunk(12)}';
  }
}
