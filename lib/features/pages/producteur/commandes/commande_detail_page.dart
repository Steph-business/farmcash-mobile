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
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/section_titre.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/suivi_commande.dart';
import '../../../widgets/communs/tracking/carte_tracking_transporteur.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/commandes/actions_commande_producteur.dart';
import '../../../widgets/producteur/commandes/carte_acheteur_compacte.dart';
import '../../../widgets/producteur/commandes/carte_resume_commande_producteur.dart';
import '../../../widgets/producteur/commandes/entete_commande_detail.dart';

// ─── Provider ────────────────────────────────────────────────────────────

/// Bundle commande + annonce associée — l'annonce nous donne le nom du
/// produit pour afficher en titre de la carte résumé. On y joint aussi
/// le shipment (quand il existe) pour alimenter la carte tracking
/// transporteur en vraies données (nom, plaque, rating).
class _CommandeBundle {
  const _CommandeBundle({
    required this.commande,
    this.annonce,
    this.shipment,
  });
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
  // Shipment : fetch UNIQUEMENT en livraison — sinon il n'existe pas
  // ou n'a plus d'intérêt sur cette page. Le service retourne null
  // proprement quand pas de shipment (cf. logistics_service.dart).
  Livraison? shipment;
  if (cmd.status == OrderStatus.inProgress) {
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
            const EnteteCommandeDetail(),
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
                    onRetry: () => ref.invalidate(_commandeProvider(commandeId)),
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
        // 1bis. Carte tracking transporteur — pour le producteur c'est
        // utile aussi : il voit qui a pris sa marchandise et où elle est.
        if (commande.status == OrderStatus.inProgress) ...[
          CarteTrackingTransporteur(
            // Données réelles depuis le shipment joint (cf. bundle).
            nomTransporteur: bundle.shipment?.transporterName
                        ?.trim()
                        .isNotEmpty ==
                    true
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
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
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
