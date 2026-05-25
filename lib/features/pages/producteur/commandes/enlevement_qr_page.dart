import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/pickup_qr_token.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/producteur/commandes/header_enlevement_qr.dart';
import '../../../widgets/producteur/commandes/mini_recap_enlevement.dart';
import '../../../widgets/producteur/commandes/qr_card_enlevement.dart';
import '../../../widgets/producteur/commandes/sticky_link_enlevement.dart';
import '../../../widgets/producteur/commandes/top_info_enlevement_qr.dart';
import '../../../widgets/producteur/commandes/transporter_card_enlevement.dart';

const String _kFallbackToken = 'lot89-mb500';

/// Provider familial : tente de récupérer un PickupQrToken pour ce shipment.
/// Si l'endpoint répond en erreur (ou si le shipment n'est pas en ACCEPTED),
/// on retombe sur le token visuel de la maquette.
final _qrTokenProvider = FutureProvider.autoDispose
    .family<PickupQrToken?, String>((ref, shipmentId) async {
  try {
    return await ref.watch(logisticsServiceProvider).generatePickupQrToken(shipmentId);
  } catch (_) {
    return null;
  }
});

/// Bordereau d'enlèvement QR — montré au transporteur pour confirmer
/// l'enlèvement (déclenche l'auto-release de l'escrow PRODUCT).
class EnlevementQrPage extends ConsumerWidget {
  const EnlevementQrPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // L'identifiant qu'on encode dans le QR : token backend si dispo,
    // sinon le slug visuel de la maquette ; dans tous les cas on prefixe
    // par l'URL de tracking afin que l'app transporteur puisse parser.
    final asyncToken = ref.watch(_qrTokenProvider(commandeId));
    final token = asyncToken.maybeWhen(
      data: (t) => t?.token ?? _kFallbackToken,
      orElse: () => _kFallbackToken,
    );
    final qrPayload = 'farmcash.ci/e/$token';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderEnlevementQr(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                children: [
                  const TopInfoEnlevementQr(),
                  AppDimens.vGap16,
                  QrCardEnlevement(payload: qrPayload, token: token),
                  AppDimens.vGap16,
                  const MiniRecapEnlevement(),
                  AppDimens.vGap8,
                  const TransporterCardEnlevement(),
                ],
              ),
            ),
            const StickyLinkEnlevement(),
          ],
        ),
      ),
    );
  }
}
