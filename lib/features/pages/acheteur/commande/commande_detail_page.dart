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
import '../../../widgets/acheteur/commandes/actions_commande_acheteur.dart';
import '../../../widgets/acheteur/commandes/carte_resume_commande.dart';
import '../../../widgets/acheteur/commandes/carte_vendeur_compacte.dart';
import '../../../widgets/acheteur/commandes/entete_commande_detail.dart';
import '../../../widgets/acheteur/commandes/section_parcours.dart';
import '../../../widgets/acheteur/commandes/section_qr.dart';
import '../../../widgets/communs/carte_bon_de_commande_pdf.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/section_titre.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/suivi_commande.dart';
import '../../../widgets/communs/tracking/carte_tracking_transporteur.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Provider ─────────────────────────────────────────────────────────

/// Bundle commande + annonce associée pour avoir le nom du produit, la
/// photo et le vendeur sans dépendre d'un payload « dénormalisé » côté
/// backend. On y joint aussi le shipment (quand il existe) pour que la
/// carte tracking transporteur affiche les vraies données (nom, plaque,
/// rating) au lieu de placeholders.
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

final _commandeBundleProvider = FutureProvider.autoDispose
    .family<_CommandeBundle, String>((ref, id) async {
  final orders = ref.read(ordersServiceProvider);
  final market = ref.read(marketplaceServiceProvider);
  final logistics = ref.read(logisticsServiceProvider);
  final cmd = await orders.getOrder(id);
  AnnonceVente? annonce;
  // `annonceId` est nullable : les commandes issues d'une proposition
  // (négociation) n'ont pas d'annonce_id côté backend — la source est
  // `annonce_achat_id`. Dans ce cas on n'a pas d'annonce de vente à
  // charger, on garde `annonce: null`.
  final annonceId = cmd.annonceId;
  if (annonceId != null && annonceId.isNotEmpty) {
    try {
      annonce = await market.getAnnonceVente(annonceId);
    } catch (_) {
      // L'annonce peut avoir été dépubliée — on garde la commande seule.
    }
  }
  // Shipment : on ne le fetch QUE si la commande est en livraison —
  // c'est le seul moment où la carte tracking s'affiche. Le service
  // retourne déjà `null` quand le shipment n'existe pas, donc pas
  // besoin de try/catch ici. On laisse remonter les vraies erreurs
  // (auth, réseau) qui méritent d'apparaître côté UI.
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

/// Détail d'une commande — vue acheteur. Composition pure : la page
/// orchestre les sections (header → SUIVI EN TÊTE → vendeur → montants →
/// QR → parcours → actions sticky).
///
/// Note design : on retire volontairement la photo hero, la carte titre
/// et la carte « Mon argent » — ces infos répètent ce que montrent déjà
/// le suivi et la section montants. La page est ainsi compacte et
/// scannable d'un coup d'œil pour un utilisateur low-tech.
class CommandeDetailAcheteurPage extends ConsumerStatefulWidget {
  const CommandeDetailAcheteurPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  ConsumerState<CommandeDetailAcheteurPage> createState() =>
      _CommandeDetailAcheteurPageState();
}

class _CommandeDetailAcheteurPageState
    extends ConsumerState<CommandeDetailAcheteurPage> {
  bool _confirmingDelivery = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_commandeBundleProvider(widget.commandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              EnteteCommandeDetail(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const EnteteCommandeDetail(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la commande. $e',
                    onRetry: () => ref.invalidate(
                      _commandeBundleProvider(widget.commandeId),
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

  Widget _build(_CommandeBundle bundle) {
    final c = bundle.commande;
    // Le suivi devient cliquable seulement quand le transporteur est en
    // route (IN_PROGRESS) — c'est à ce moment-là qu'il y a quelque chose
    // à suivre. Sinon le geste n'apporte rien d'utile.
    final canTrack = c.status == OrderStatus.inProgress;

    return Column(
      children: [
        const EnteteCommandeDetail(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // 1. SUIVI EN TÊTE — l'info la plus importante en premier.
              SectionTitre(
                titre: 'Suivi de ma commande',
                child: _SuiviCliquable(
                  commandeId: c.id,
                  enabled: canTrack,
                  child: SuiviCommande(commande: c, viewerIsBuyer: true),
                ),
              ),
              // 1bis. Carte tracking transporteur — affichée uniquement
              // quand le transporteur est en route. Données réelles
              // injectées depuis le shipment joint (cf. `_CommandeBundle`).
              if (c.status == OrderStatus.inProgress)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: CarteTrackingTransporteur(
                    // Quand on a un nom réel, on le prend. Sinon le
                    // placeholder « Transporteur assigné » reste utile
                    // pour dire qu'il y en a bien un (état IN_PROGRESS).
                    nomTransporteur: bundle.shipment?.transporterName
                                ?.trim()
                                .isNotEmpty ==
                            true
                        ? bundle.shipment!.transporterName!
                        : 'Transporteur assigné',
                    note: bundle.shipment?.transporterRating ?? 0,
                    nbAvis: bundle.shipment?.transporterRatingCount ?? 0,
                    // Pour véhicule / plaque / chauffeur : null si pas
                    // dispo → la carte cache la ligne (au lieu de
                    // « Information à venir » / « — » qui n'apportent
                    // rien à l'utilisateur).
                    typeVehicule: bundle.shipment?.vehiculeLabel,
                    plaque: bundle.shipment?.vehiclePlaque,
                    nomChauffeur: bundle.shipment?.transporterName,
                    photoUrl: bundle.shipment?.transporterPhotoUrl,
                    // Boutons appel + chat : actifs seulement si on
                    // connaît le téléphone (resp. l'ID) du transporteur.
                    onAppeler: _appelerCallback(
                      context,
                      bundle.shipment?.transporterPhone,
                    ),
                    onDiscuter: _discuterCallback(
                      context,
                      ref,
                      bundle.shipment?.transporter?.id,
                    ),
                    // Voir détails : null → le bouton est caché car le
                    // lien « Voir la position du transporteur » juste
                    // au-dessus de la carte mène à la même page.
                  ),
                ),
              // 2. Vendeur compact (avatar + nom + CTA "Discuter").
              CarteVendeurCompacte(annonce: bundle.annonce),
              // 3. Résumé commande pliable (produit + 3 montants clés).
              CarteResumeCommande(
                commande: c,
                annonce: bundle.annonce,
              ),
              // 3.bis Bon de commande PDF — visible UNIQUEMENT pour les
              //       commandes coop ≥ 500 kg (check d'éligibilité auto
              //       backend). Document officiel pour archivage compta.
              const SizedBox(height: 8),
              CarteBonDeCommandePdf(orderId: c.id),
              // 4. QR de réception — affiché en permanence pour permettre
              //    à l'acheteur de le retrouver vite.
              SectionQr(commandeId: c.id),
              // 5. Parcours traçabilité — seulement après livraison.
              if (_parcoursVisible(c))
                SectionParcours(commande: c, annonce: bundle.annonce),
              const SizedBox(height: 8),
            ],
          ),
        ),
        ActionsCommandeAcheteur(
          commande: c,
          busy: _confirmingDelivery,
          onConfirmerReception: () => _confirmerReception(c),
          onAfterLitige: () =>
              ref.invalidate(_commandeBundleProvider(widget.commandeId)),
        ),
      ],
    );
  }

  Future<void> _confirmerReception(Commande c) async {
    if (_confirmingDelivery) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la réception ?'),
        content: const Text(
          'En confirmant, le paiement est libéré au vendeur. '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    setState(() => _confirmingDelivery = true);
    try {
      await ref.read(financeServiceProvider).confirmDelivery(commandeId: c.id);
      ref.invalidate(_commandeBundleProvider(widget.commandeId));
      if (!mounted) return;
      Snackbars.showSucces(context, 'Réception confirmée · escrow libéré');
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _confirmingDelivery = false);
    }
  }
}

/// Visibilité de la section « Parcours du produit ». On l'affiche
/// uniquement à partir de la livraison parce que c'est à ce moment-là
/// que la timeline backend contient assez d'événements pour être
/// intéressante (`HARVESTED`, `PICKED_UP`, `DELIVERED`).
bool _parcoursVisible(Commande c) =>
    c.status == OrderStatus.delivered || c.status == OrderStatus.completed;

/// Construit le callback du bouton « Appeler le chauffeur ». Retourne
/// `null` si on n'a pas de téléphone — la carte cache alors le bouton.
/// Note V1 : on expose directement le numéro du transporteur via `tel:`.
/// Si un proxy Twilio est introduit plus tard, c'est ici qu'on branchera.
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

/// Construit le callback du bouton « Discuter avec le chauffeur ».
/// Retourne `null` si on n'a pas d'ID transporteur — bouton caché.
/// On crée (ou retrouve) une conversation 1-1 puis on ouvre la page chat.
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

/// Wrapper qui rend la section suivi cliquable pour ouvrir la page de
/// tracking GPS du transporteur. Désactivé tant que le statut n'est pas
/// `IN_PROGRESS` (pas de transporteur en route → rien à suivre).
class _SuiviCliquable extends StatelessWidget {
  const _SuiviCliquable({
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
                  const Expanded(
                    child: Text(
                      'Voir la position du transporteur',
                      style: TextStyle(
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
