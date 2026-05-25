import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../models/commande.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/commandes/bandeau_info_livraison_qr.dart';
import '../../../widgets/acheteur/commandes/carte_qr_livraison.dart';
import '../../../widgets/acheteur/commandes/header_livraison_qr.dart';
import '../../../widgets/acheteur/commandes/lien_signaler_livraison.dart';
import '../../../widgets/acheteur/commandes/mini_recap_livraison_qr.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Provider ─────────────────────────────────────────────────────────

class _LivraisonBundle {
  const _LivraisonBundle({required this.commande, this.annonce});
  final Commande commande;
  final AnnonceVente? annonce;
}

final _livraisonBundleProvider = FutureProvider.autoDispose
    .family<_LivraisonBundle, String>((ref, id) async {
  final cmd = await ref.read(ordersServiceProvider).getOrder(id);
  AnnonceVente? annonce;
  try {
    annonce =
        await ref.read(marketplaceServiceProvider).getAnnonceVente(cmd.annonceId);
  } catch (_) {}
  return _LivraisonBundle(commande: cmd, annonce: annonce);
});

/// QR de réception acheteur — à montrer au transporteur quand il arrive.
///
/// Le QR encode l'ID de commande + référence. Côté back, il n'existe pas
/// encore d'endpoint dédié au "scan livraison" (le transporteur déclenche
/// la livraison via `POST /logistics/shipments/:id/deliver`). L'écran sert
/// donc surtout d'aide visuelle pour identifier la commande à la livraison.
class LivraisonQrPage extends ConsumerWidget {
  const LivraisonQrPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_livraisonBundleProvider(commandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              HeaderLivraisonQr(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const HeaderLivraisonQr(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la commande. $e',
                    onRetry: () =>
                        ref.invalidate(_livraisonBundleProvider(commandeId)),
                  ),
                ),
              ),
            ],
          ),
          data: (bundle) => _build(context, bundle),
        ),
      ),
    );
  }

  Widget _build(BuildContext context, _LivraisonBundle bundle) {
    final c = bundle.commande;
    final reference = c.reference.isNotEmpty
        ? c.reference
        : c.id.substring(0, 8).toUpperCase();
    // Payload QR : ID commande + référence. Côté transporteur c'est ce qui
    // permettra de localiser la commande dans son app.
    final qrPayload = 'farmcash://commande/${c.id}?ref=$reference';

    return Column(
      children: [
        const HeaderLivraisonQr(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              const BandeauInfoLivraisonQr(),
              const SizedBox(height: 18),
              CarteQrLivraison(
                payload: qrPayload,
                commandeRef: reference,
              ),
              const SizedBox(height: 14),
              MiniRecapLivraisonQr(commande: c, annonce: bundle.annonce),
              const SizedBox(height: 8),
              LienSignalerLivraison(
                onTap: () => Snackbars.showInfo(
                  context,
                  'Signaler un problème — à venir',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
