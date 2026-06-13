import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../models/commande.dart';
import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/carte_bon_de_commande_pdf.dart';
import '../../../widgets/communs/carte_paiement_etage_vendeur.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/section_titre.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/suivi_commande.dart';
import '../../../widgets/communs/tracking/carte_tracking_transporteur.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/producteur/commandes/actions_commande_producteur.dart';
import '../../../widgets/producteur/commandes/carte_acheteur_compacte.dart';
import '../../../widgets/producteur/commandes/carte_distribution_coop.dart';
import '../../../widgets/producteur/commandes/carte_resume_commande_producteur.dart';

// ─── Provider ────────────────────────────────────────────────────────────

/// Bundle commande + annonce associée — l'annonce nous donne le nom du
/// produit pour afficher en titre de la carte résumé. On y joint aussi
/// le shipment (quand il existe) pour alimenter la carte tracking
/// transporteur en vraies données (nom, plaque, rating).
class _CommandeBundle {
  const _CommandeBundle({required this.commande, this.annonce, this.shipment});
  final Commande commande;
  final AnnonceVente? annonce;
  final Livraison? shipment;
}

final _commandeProvider = FutureProvider.autoDispose
    .family<_CommandeBundle, String>((ref, id) async {
      final orders = ref.read(ordersServiceProvider);
      final market = ref.read(marketplaceServiceProvider);
      final logistics = ref.read(logisticsServiceProvider);
      final cmd = await orders.getOrder(id);
      AnnonceVente? annonce;
      // `annonceId` est nullable : les commandes issues d'une proposition
      // (négociation) n'ont pas d'annonce de vente source — `annonce_achat_id`
      // est rempli à la place. On skip alors le fetch annonce.
      final annonceId = cmd.annonceId;
      if (annonceId != null && annonceId.isNotEmpty) {
        try {
          annonce = await market.getAnnonceVente(annonceId);
        } catch (_) {
          // L'annonce peut avoir été dépubliée — on garde la commande seule.
        }
      }
      // Shipment : fetch en livraison (tracking GPS) ET en ACCEPTED (pour
      // savoir si la coop a déjà demandé un transporteur — bouton « Demander
      // un transporteur » caché si shipment déjà créé). Service tolérant
      // au null (cf. logistics_service.dart).
      Livraison? shipment;
      if (cmd.status == OrderStatus.inProgress ||
          cmd.status == OrderStatus.accepted) {
        shipment = await logistics.getShipmentByCommande(id);
      }
      return _CommandeBundle(
        commande: cmd,
        annonce: annonce,
        shipment: shipment,
      );
    });

/// Détail d'une commande côté producteur. Composition pure et alignée
/// sur le détail acheteur (même layout, même hiérarchie visuelle) :
///   - Header avec ref + back
///   - **Suivi en TÊTE** (l'info la plus importante)
///   - Acheteur (avec adresse + chat)
///   - Montants nets (brut − 3% frais)
///   - Sticky actions (voir conversation / marquer expédiée)
///
/// Volontairement enlevés :
///   - Hero photo (générique, sans valeur ajoutée)
///   - Carte « Mon argent » (la section Montants dit déjà combien il
///     touchera, et le Suivi indique à quelle étape l'argent arrive)
///
/// Quand le transporteur est en route (IN_PROGRESS), le producteur peut
/// cliquer sur le suivi pour voir la position GPS du transporteur.
class CommandeDetailPage extends ConsumerWidget {
  const CommandeDetailPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_commandeProvider(commandeId));

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Commande'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la commande.',
                    onRetry: () =>
                        ref.invalidate(_commandeProvider(commandeId)),
                  ),
                ),
                data: (bundle) => _Body(bundle: bundle),
              ),
            ),
            async.maybeWhen(
              data: (bundle) => ActionsCommandeProducteur(
                commande: bundle.commande,
                onAfterShipped: () =>
                    ref.invalidate(_commandeProvider(commandeId)),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.bundle});

  final _CommandeBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commande = bundle.commande;
    final qte = commande.quantiteKg;
    final prixKg = commande.prixUnitaireKg;
    final brut = commande.montantTotal > 0
        ? commande.montantTotal
        : qte * prixKg;
    final frais = (brut * 0.03).round().toDouble();
    final net = brut - frais;
    final produitNom = bundle.annonce?.produitLabel.trim().isNotEmpty == true
        ? bundle.annonce!.produitLabel.trim()
        : 'Produit';
    // Tracking du transporteur dispo seulement quand il est en route.
    // Avant ça il n'y a pas encore de position GPS à montrer.
    final canTrack = commande.status == OrderStatus.inProgress;

    // Rôle viewer — le CTA « Alerter le transporteur » est utile aux
    // 2 vendeurs (FARMER vente directe ET COOPERATIVE quand un acheteur
    // commande sur une publication agrégée). Les 2 partagent cette page
    // détail (la coop redirige vers la route producteur).
    final viewerRole = ref.watch(currentUserProvider)?.role;
    final isSellerViewer =
        viewerRole == UserRole.cooperative || viewerRole == UserRole.farmer;
    final shipment = bundle.shipment;
    final canRequestTransport =
        isSellerViewer &&
        commande.status == OrderStatus.accepted &&
        shipment == null;
    final transportAlreadyRequested =
        isSellerViewer &&
        commande.status == OrderStatus.accepted &&
        shipment != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        // 1. SUIVI EN TÊTE — le producteur voit en premier où en est sa
        //    commande.
        SectionTitre(
          titre: 'Suivi de la commande',
          encadre: true,
          child: _SuiviCliquableProducteur(
            commandeId: commande.id,
            enabled: canTrack,
            child: SuiviCommande(
              commande: commande,
              viewerIsBuyer: false,
              // Montant net (après frais 3%) — affiché sur l'étape
              // « argent dans wallet » pour ne pas tromper avec le brut.
              montantNet: net,
            ),
          ),
        ),
        AppDimens.vGap12,
        // 1ter. CTA « Demander un transporteur » — visible UNIQUEMENT
        // pour la coop quand la commande est payée (ACCEPTED) et qu'il
        // n'y a pas encore de shipment. C'est la porte de sortie pour
        // alerter les transporteurs éligibles via le matching backend.
        if (canRequestTransport) ...[
          _CarteDemanderTransporteur(commandeId: commande.id),
          AppDimens.vGap12,
        ] else if (transportAlreadyRequested) ...[
          _CarteTransporteurSollicite(commandeId: commande.id),
          AppDimens.vGap12,
        ],
        // 1bis. Carte tracking transporteur — pour le producteur c'est
        // utile aussi : il voit qui a pris sa marchandise et où elle est.
        if (commande.status == OrderStatus.inProgress) ...[
          CarteTrackingTransporteur(
            // Données réelles depuis le shipment joint (cf. bundle).
            nomTransporteur:
                bundle.shipment?.transporterName?.trim().isNotEmpty == true
                ? bundle.shipment!.transporterName!
                : 'Transporteur assigné',
            note: bundle.shipment?.transporterRating ?? 0,
            nbAvis: bundle.shipment?.transporterRatingCount ?? 0,
            // null si pas dispo → la carte cache la ligne.
            typeVehicule: bundle.shipment?.vehiculeLabel,
            plaque: bundle.shipment?.vehiclePlaque,
            nomChauffeur: bundle.shipment?.transporterName,
            photoUrl: bundle.shipment?.transporterPhotoUrl,
            // Producteur peut joindre le chauffeur quand sa marchandise
            // est en route — utile pour signaler une ouverture portail
            // ou un changement de point d'enlèvement.
            onAppeler: _appelerCallback(
              context,
              bundle.shipment?.transporterPhone,
            ),
            onDiscuter: _discuterCallback(
              context,
              ref,
              bundle.shipment?.transporter?.id,
            ),
            // Voir détails : null → le bouton est caché car le lien
            // « Voir la position du transporteur » au-dessus mène à la
            // même page.
          ),
          AppDimens.vGap12,
        ],
        // Distribution coop — visible UNIQUEMENT pour la coop quand la
        // commande vient d'une publication agrégée. Affiche la cascade
        // FarmCash → commission coop → producteurs au prorata, avec
        // détail nominal de chaque producteur. C'est la garantie
        // anti-litige interne demandée par l'utilisateur.
        if (viewerRole == UserRole.cooperative &&
            commande.publicationCoopId != null) ...[
          CarteDistributionCoop(publicationCoopId: commande.publicationCoopId!),
          AppDimens.vGap12,
          // Bon de commande PDF — uniquement coop vendeur ≥ 500 kg.
          // L'éligibilité est vérifiée côté backend.
          CarteBonDeCommandePdf(orderId: commande.id),
          AppDimens.vGap12,
        ],
        // 1.bis Bandeau paiement étagé — visible pour le vendeur
        //       (producteur ou coop) quand la commande est en mode STAGED
        //       et que le dépôt a été payé. Montre l'avance reçue + le
        //       solde attendu. Cache silencieusement si mode FULL.
        CartePaiementEtageVendeur(commande: commande),
        // 2. Acheteur compact (avatar + nom + CTA Discuter).
        CarteAcheteurCompacte(commande: commande),
        AppDimens.vGap12,
        // 3. Résumé commande pliable (produit + net + prix + qté ; brut /
        //    frais / escrow / référence cachés derrière le chevron).
        CarteResumeCommandeProducteur(
          commande: commande,
          produitNom: produitNom,
          brut: brut,
          frais: frais,
          net: net,
        ),
      ],
    );
  }
}

/// Wrapper qui rend la section suivi cliquable côté producteur pour
/// ouvrir la page tracking GPS du transporteur. Désactivé tant que le
/// statut n'est pas `IN_PROGRESS` — avant, il n'y a rien à suivre.
///
/// Helpers identiques à ceux côté acheteur — duplication assumée pour
/// que chaque page reste autonome. Si un 3e endroit a besoin de la même
/// logique, on factorisera dans `widgets/communs/`.
VoidCallback? _appelerCallback(BuildContext context, String? telephone) {
  final num = telephone?.trim();
  if (num == null || num.isEmpty) return null;
  return () async {
    final uri = Uri(scheme: 'tel', path: num);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      Snackbars.showErreur(context, 'Impossible de lancer l\'appel.');
    }
  };
}

VoidCallback? _discuterCallback(
  BuildContext context,
  WidgetRef ref,
  String? transporterId,
) {
  if (transporterId == null || transporterId.isEmpty) return null;
  return () async {
    try {
      final conv = await ref
          .read(messagingServiceProvider)
          .createConversation(participantIds: [transporterId]);
      if (!context.mounted) return;
      context.push(RouteNames.chatDetailPathFor(conv.id));
    } on ApiException catch (e) {
      if (context.mounted) Snackbars.showErreur(context, e.message);
    }
  };
}

class _SuiviCliquableProducteur extends StatelessWidget {
  const _SuiviCliquableProducteur({
    required this.commandeId,
    required this.enabled,
    required this.child,
  });

  final String commandeId;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        if (enabled) ...[
          const SizedBox(height: 12),
          InkWell(
            // Le producteur réutilise la page tracking acheteur — c'est
            // la même donnée GPS (position du transporteur), même UI.
            onTap: () => context.push(
              RouteNames.acheteurLivraisonTrackingPathFor(commandeId),
            ),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Voir la position du transporteur',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── CTA Alerter le transporteur (coop uniquement) ──────────────────

/// Carte verte avec bouton « Alerter le transporteur ». Le shipment est
/// déjà créé au moment du paiement (l'acheteur a choisi un transporteur
/// ou matching auto). La coop alerte juste le transporteur que le colis
/// est prêt à enlever. Si pas de transporteur encore assigné, relance
/// le matching auto via les routes déclarées.
class _CarteDemanderTransporteur extends ConsumerStatefulWidget {
  const _CarteDemanderTransporteur({required this.commandeId});
  final String commandeId;

  @override
  ConsumerState<_CarteDemanderTransporteur> createState() =>
      _CarteDemanderTransporteurState();
}

class _CarteDemanderTransporteurState
    extends ConsumerState<_CarteDemanderTransporteur> {
  bool _isSending = false;
  bool _isDeclaringInternal = false;

  Future<void> _alerter() async {
    if (_isSending) return;
    setState(() => _isSending = true);
    try {
      final res = await ref
          .read(coopLogisticsServiceProvider)
          .notifyPickupReady(widget.commandeId);
      if (!mounted) return;
      // Le backend renvoie un message déjà adapté au cas (notif directe
      // OU re-broadcast). On l'affiche tel quel.
      Snackbars.showSucces(
        context,
        (res['message'] as String?) ?? 'Transporteur alerté.',
      );
      ref.invalidate(_commandeProvider(widget.commandeId));
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  /// Chantier 4 : le vendeur déclare livrer lui-même.
  Future<void> _livrerMoiMeme() async {
    if (_isDeclaringInternal) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Livrer moi-même ?'),
        content: const Text(
          "Tu vas livrer la marchandise avec ton propre véhicule. "
          "Aucun transporteur externe ne sera contacté et il n'y aura "
          "pas de commission FarmCash sur le transport.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Oui, je livre'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _isDeclaringInternal = true);
    try {
      await ref
          .read(logisticsServiceProvider)
          .declareInternalTransport(commandeId: widget.commandeId);
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Livraison interne déclarée · acheteur prévenu.',
      );
      ref.invalidate(_commandeProvider(widget.commandeId));
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _isDeclaringInternal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.local_shipping_outlined,
                  size: 20,
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
                      'Colis prêt à expédier ?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Alerte le transporteur pour qu\'il vienne enlever la marchandise.',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _isSending ? null : _alerter,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.notifications_active_outlined,
                              size: 17,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Alerter le transporteur',
                              style: AppTextStyles.button.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Chantier 4 — option transport coop interne.
          // Le vendeur peut livrer lui-même (Hilux, camion perso) sans
          // passer par le marketplace transporteur.
          SizedBox(
            height: 40,
            child: OutlinedButton.icon(
              onPressed: _isDeclaringInternal ? null : _livrerMoiMeme,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _isDeclaringInternal
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(Icons.directions_car_outlined, size: 16),
              label: Text(
                _isDeclaringInternal
                    ? 'Déclaration en cours...'
                    : 'Je livre moi-même',
                style: AppTextStyles.button.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Affichée quand la coop a déjà alerté le transporteur (le shipment
/// existe avec un transporter_id). La coop peut quand même re-cliquer
/// pour relancer (idempotent côté backend) — d'où le bouton secondaire
/// « Relancer la notif ».
class _CarteTransporteurSollicite extends ConsumerStatefulWidget {
  const _CarteTransporteurSollicite({required this.commandeId});
  final String commandeId;

  @override
  ConsumerState<_CarteTransporteurSollicite> createState() =>
      _CarteTransporteurSolliciteState();
}

class _CarteTransporteurSolliciteState
    extends ConsumerState<_CarteTransporteurSollicite> {
  bool _isSending = false;

  Future<void> _relancer() async {
    if (_isSending) return;
    setState(() => _isSending = true);
    try {
      final res = await ref
          .read(coopLogisticsServiceProvider)
          .notifyPickupReady(widget.commandeId);
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        (res['message'] as String?) ?? 'Transporteur relancé.',
      );
      ref.invalidate(_commandeProvider(widget.commandeId));
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB45309).withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFB45309).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 20,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Transporteur alerté',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'En attente qu\'il vienne enlever le colis.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _isSending ? null : _relancer,
            child: _isSending
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Relancer',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB45309),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
