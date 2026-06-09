import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/pickup_qr_token.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/commandes/header_enlevement_qr.dart';
import '../../../widgets/producteur/commandes/mini_recap_enlevement.dart';
import '../../../widgets/producteur/commandes/qr_card_enlevement.dart';
import '../../../widgets/producteur/commandes/sticky_link_enlevement.dart';
import '../../../widgets/producteur/commandes/top_info_enlevement_qr.dart';
import '../../../widgets/producteur/commandes/transporter_card_enlevement.dart';

const String _kFallbackToken = 'lot89-mb500';

/// Bundle de chargement : on remonte le shipment depuis le commande,
/// puis on demande au backend de générer le token pickup pour ce
/// shipment. Les deux étapes sont nécessaires car `generatePickupQrToken`
/// attend un shipment_id, pas un commande_id.
class _QrEnlevementBundle {
  const _QrEnlevementBundle({required this.token});
  final String token;
}

final _qrEnlevementProvider = FutureProvider.autoDispose
    .family<_QrEnlevementBundle, String>((ref, commandeId) async {
  final logistics = ref.read(logisticsServiceProvider);
  // 1) Retrouver le shipment associé à la commande. Le service retourne
  //    désormais `null` quand pas de shipment — on tombe alors sur le
  //    QR fallback (mode dégradé) sans crasher.
  final shipment = await logistics.getShipmentByCommande(commandeId);
  if (shipment == null) {
    return const _QrEnlevementBundle(token: _kFallbackToken);
  }
  // 2) Demander un token signé (backend valide statut, ownership, etc.).
  PickupQrToken? token;
  try {
    token = await logistics.generatePickupQrToken(shipment.id);
  } catch (_) {
    token = null;
  }
  return _QrEnlevementBundle(token: token?.token ?? _kFallbackToken);
});

/// Bordereau d'enlèvement QR — montré au transporteur pour confirmer
/// l'enlèvement (déclenche l'auto-release de l'escrow PRODUCT).
class EnlevementQrPage extends ConsumerWidget {
  const EnlevementQrPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBundle = ref.watch(_qrEnlevementProvider(commandeId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderEnlevementQr(),
            Expanded(
              child: asyncBundle.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message:
                        'Impossible de générer le QR d\'enlèvement. $e',
                    onRetry: () => ref.invalidate(
                      _qrEnlevementProvider(commandeId),
                    ),
                  ),
                ),
                data: (bundle) => ListView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  children: [
                    const TopInfoEnlevementQr(),
                    AppDimens.vGap16,
                    QrCardEnlevement(
                      payload: 'farmcash.ci/e/${bundle.token}',
                      token: bundle.token,
                    ),
                    AppDimens.vGap16,
                    const MiniRecapEnlevement(),
                    AppDimens.vGap8,
                    const TransporterCardEnlevement(),
                  ],
                ),
              ),
            ),
            StickyLinkEnlevement(commandeId: commandeId),
          ],
        ),
      ),
    );
  }
}
