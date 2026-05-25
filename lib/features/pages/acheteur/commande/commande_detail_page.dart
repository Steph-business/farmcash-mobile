import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../models/commande.dart';
import '../../../../models/enums.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/commandes/actions_commande_acheteur.dart';
import '../../../widgets/acheteur/commandes/entete_commande_detail.dart';
import '../../../widgets/acheteur/commandes/section_montants.dart';
import '../../../widgets/acheteur/commandes/section_parcours.dart';
import '../../../widgets/acheteur/commandes/section_qr.dart';
import '../../../widgets/acheteur/commandes/section_vendeur.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/section_titre.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/suivi_commande.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Provider ─────────────────────────────────────────────────────────

/// Bundle commande + annonce associée pour avoir le nom du produit, la
/// photo et le vendeur sans dépendre d'un payload « dénormalisé » côté
/// backend.
class _CommandeBundle {
  const _CommandeBundle({required this.commande, this.annonce});
  final Commande commande;
  final AnnonceVente? annonce;
}

final _commandeBundleProvider = FutureProvider.autoDispose
    .family<_CommandeBundle, String>((ref, id) async {
  final orders = ref.read(ordersServiceProvider);
  final market = ref.read(marketplaceServiceProvider);
  final cmd = await orders.getOrder(id);
  AnnonceVente? annonce;
  try {
    annonce = await market.getAnnonceVente(cmd.annonceId);
  } catch (_) {
    // L'annonce peut avoir été dépubliée — on garde la commande seule.
  }
  return _CommandeBundle(commande: cmd, annonce: annonce);
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
              EnteteCommandeDetail(reference: ''),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const EnteteCommandeDetail(reference: ''),
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
    final ref0 = c.reference.isNotEmpty
        ? c.reference
        : c.id.substring(0, 8).toUpperCase();
    // Le suivi devient cliquable seulement quand le transporteur est en
    // route (IN_PROGRESS) — c'est à ce moment-là qu'il y a quelque chose
    // à suivre. Sinon le geste n'apporte rien d'utile.
    final canTrack = c.status == OrderStatus.inProgress;

    return Column(
      children: [
        EnteteCommandeDetail(reference: ref0),
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
              // 2. Vendeur (avec bouton chat).
              SectionVendeur(annonce: bundle.annonce),
              // 3. Montants (escrow status inclus dans le wording).
              SectionMontants(commande: c),
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
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
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
