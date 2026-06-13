import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../models/buyer_address.dart';
import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../models/wallet_with_transactions.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/orders_service.dart' show OrderSourceType;
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../state/badges_state.dart';
import '../../../widgets/acheteur/commandes/bandeau_confiance_escrow.dart';
import '../../../widgets/acheteur/commandes/bandeau_solde_insuffisant.dart';
import '../../../widgets/acheteur/commandes/carte_adresse_livraison.dart';
import '../../../widgets/acheteur/commandes/carte_montants_paiement.dart';
import '../../../widgets/acheteur/commandes/carte_choix_mode_paiement.dart';
import '../../../widgets/acheteur/commandes/carte_recap_paiement.dart';
import '../../../widgets/acheteur/commandes/champ_note_vendeur.dart';
import '../../../widgets/acheteur/commandes/grille_methodes_paiement.dart';
import '../../../widgets/acheteur/commandes/options_livraison.dart';
import '../../../widgets/acheteur/commandes/sticky_bottom_paiement.dart';
import '../../../widgets/acheteur/commandes/titre_section_paiement.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/moyen_paiement_ajout_sheet.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Provider ─────────────────────────────────────────────────────────

class _PaiementBundle {
  const _PaiementBundle({
    required this.annonce,
    required this.wallet,
    required this.addresses,
  });
  final AnnonceVente annonce;
  final WalletWithTransactions? wallet;
  /// Adresses de livraison enregistrées par le buyer. Vide si aucune.
  /// Utilisée pour pré-remplir `delivery_address` au paiement (et donc
  /// permettre au backend de faire le matching auto transporteur).
  final List<BuyerAddress> addresses;
}

final _paiementBundleProvider = FutureProvider.autoDispose
    .family<_PaiementBundle, String>((ref, annonceId) async {
  final svc = ref.read(marketplaceServiceProvider);
  final finance = ref.read(financeServiceProvider);
  final buyer = ref.read(buyerServiceProvider);
  final results = await Future.wait<dynamic>([
    svc.getAnnonceVente(annonceId),
    finance.getWallet(limit: 1).then<Object?>((v) => v).catchError((_) => null),
    buyer.listAddresses().then<Object?>((v) => v).catchError(
          (_) => const <BuyerAddress>[],
        ),
  ]);
  return _PaiementBundle(
    annonce: results[0] as AnnonceVente,
    wallet: results[1] as WalletWithTransactions?,
    addresses: results[2] as List<BuyerAddress>,
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
  /// Mode de paiement choisi par l'acheteur :
  ///   • FULL    — paye 100 % maintenant, libéré au vendeur à la livraison
  ///   • STAGED  — paye un acompte (20 % par défaut), solde à la livraison
  ///               → la coop reçoit immédiatement 80 % de l'acompte pour
  ///               payer ses producteurs
  ModePaiementAcheteur _modePaiement = ModePaiementAcheteur.full;
  final TextEditingController _noteCtrl = TextEditingController();
  bool _busy = false;

  /// Quote (route + transporteur + prix) sélectionnée quand l'acheteur
  /// est passé sur la page « Choisir mon transporteur » en mode manuel.
  /// Null si pas encore choisi OU si mode = auto.
  TransportQuote? _quoteChoisie;

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
              EntetePageStandard(
                  titre: 'Paiement commande', montrerNotifications: false),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const EntetePageStandard(
            titre: 'Paiement commande', montrerNotifications: false),
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
    // L'acheteur ne paye AUCUNE commission FarmCash (modèle "buyer-side
    // zero fees"). Les frais 3 % sont retenus sur la part du vendeur et
    // du transporteur au moment du release d'escrow. Le total à payer
    // est strictement le sous-total — pas de surcharge cachée.
    final frais = 0;
    final total = sousTotal + frais;

    final soldeWallet = bundle.wallet?.wallet.balance ?? 0.0;
    final walletInsuffisant =
        _provider == MobileProvider.wallet && soldeWallet < total;

    return Column(
      children: [
        const EntetePageStandard(
            titre: 'Paiement commande', montrerNotifications: false),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            children: [
              CarteRecapPaiement(annonce: annonce, quantiteKg: qte),
              const SizedBox(height: 12),
              // Bandeau confiance escrow — premium (3 puces) si total
              // >= 500 000 F, compact sinon. Réduit l'hésitation de
              // l'acheteur sur le paiement 100% upfront, surtout pour
              // les gros volumes coopérative (5T = 4-5 M F).
              BandeauConfianceEscrow(montantTotal: total),
              const SizedBox(height: 14),
              // Choix mode paiement (intégral ou étagé). Le mode étagé
              // permet à la coop de payer ses producteurs dès la
              // commande (80% du dépôt libéré immédiatement).
              CarteChoixModePaiement(
                montantTotal: total.toDouble(),
                mode: _modePaiement,
                onChange: (m) => setState(() => _modePaiement = m),
              ),
              const SizedBox(height: 18),
              const TitreSectionPaiement('Mode de livraison'),
              const SizedBox(height: 10),
              OptionsLivraison(
                selection: _livraison,
                onChange: (mode) async {
                  setState(() {
                    _livraison = mode;
                    // Switch vers auto → on oublie la quote précédemment
                    // choisie (sinon on enverrait l'ID au backend alors
                    // que l'user a changé d'avis).
                    if (mode == ModeLivraisonPaiement.auto) {
                      _quoteChoisie = null;
                    }
                  });
                  if (mode == ModeLivraisonPaiement.choisir) {
                    // Push la page liste de transporteurs. Le tap sur
                    // une carte pop la quote choisie → on la stocke
                    // pour l'envoyer au backend lors du paiement.
                    final result = await context.push<TransportQuote>(
                      RouteNames.acheteurChoisirTransporteurPath,
                    );
                    if (result != null && mounted) {
                      setState(() => _quoteChoisie = result);
                    }
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

      // 2) Résoud l'adresse de livraison : par défaut, la 1re adresse
      //    `is_default` du buyer (sinon la 1re tout court). Sans
      //    delivery_address, le backend ne peut PAS faire le matching
      //    auto transporteur — le shipment ne sera pas créé.
      final bundle = ref.read(_paiementBundleProvider(annonce.id)).value;
      BuyerAddress? defaultAdd;
      if (bundle != null && bundle.addresses.isNotEmpty) {
        defaultAdd = bundle.addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => bundle.addresses.first,
        );
      }
      final deliveryAddress =
          defaultAdd != null && defaultAdd.adresseComplete.isNotEmpty
              ? defaultAdd.adresseComplete
              : null;

      // 3) Branche transport selon le mode choisi :
      //   - choisir + quote sélectionnée → on envoie l'ID de la route
      //   - auto                          → on envoie auto_assign = true
      //                                     le backend trouvera la route
      //   - choisir SANS quote (l'user n'a pas validé la liste)
      //                                   → fallback auto
      String? transporterRouteId;
      bool autoAssign = false;
      if (_livraison == ModeLivraisonPaiement.choisir &&
          _quoteChoisie != null) {
        transporterRouteId = _quoteChoisie!.routeId;
      } else {
        autoAssign = true;
      }

      // 4) Crée la commande avec tous les paramètres logistique +
      //    mode de paiement (FULL ou STAGED). Le backend applique la
      //    grille adaptative pour le montant du dépôt si STAGED.
      final commande = await ref.read(ordersServiceProvider).createOrder(
            sourceType: OrderSourceType.directAnnonceVente,
            annonceVenteId: annonce.id,
            quantiteKg: qte.toDouble(),
            paymentMethodId: defaultMp.id,
            transporterRouteId: transporterRouteId,
            autoAssignTransporter: autoAssign,
            deliveryAddress: deliveryAddress,
            idempotencyKey: idempotencyKey,
            paymentMode: _modePaiement.apiValue,
          );

      // 3) Nettoyage post-commande : vider TOUT le panier. V1 est
      //    mono-vendeur (le backend force déjà un seul vendeur par
      //    panier) ET le bouton « Commander » ne paye que le 1er item
      //    — l'utilisateur croit pourtant avoir tout commandé. Si on
      //    ne garde que les items « non commandés », il retombe sur le
      //    panier avec l'article encore présent (« je l'ai pourtant
      //    commandé ? »). On vide donc tout : c'est ce qu'il attend.
      //    Best-effort : on avale les erreurs pour ne pas bloquer la
      //    redirection vers la page succès (commande déjà créée).
      await _viderPanier();

      // Force le rafraîchissement immédiat du badge panier (icône
      // header dans tout l'app). On attend la nouvelle valeur avant
      // de naviguer — sinon le header peut conserver la valeur en
      // cache et afficher « 1 » alors que le panier est vide.
      ref.invalidate(cartCountProvider);
      try {
        await ref.read(cartCountProvider.future);
      } catch (_) {
        // Si la requête échoue (réseau HS), on ne bloque pas la nav.
      }
      // Wallet (débit immédiat éventuel) : invalide aussi.
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
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Best-effort : vide intégralement le panier de l'utilisateur. En
  /// V1, le bouton « Commander » ne paye que le 1er item du panier, mais
  /// l'utilisateur s'attend à un panier vide après paiement (modèle
  /// e-commerce classique « j'ai payé → mon panier est vide »). Comme
  /// le backend force déjà un seul vendeur par panier (mono-vendeur),
  /// vider tout est sans risque et matche l'attente UX.
  ///
  /// Toute erreur est avalée (la commande est déjà créée, on ne veut
  /// pas bloquer la redirection vers la page succès).
  Future<void> _viderPanier() async {
    try {
      final svc = ref.read(marketplaceServiceProvider);
      final panier = await svc.getPanier();
      for (final it in panier.items) {
        try {
          await svc.removeFromPanier(it.id);
        } catch (_) {
          // Continue même si la suppression d'un item échoue.
        }
      }
    } catch (_) {
      // Réseau HS, panier inaccessible : on abandonne silencieusement.
      // Le badge sera de toute façon ré-évalué au prochain refresh.
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
