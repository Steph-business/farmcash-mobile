import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../models/commande.dart';
import '../../../../models/enums.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPastelVert = Color(0xFFE8F5E9);

/// Centre par défaut quand on n'a pas encore de position GPS du
/// transporteur — Abidjan, Côte d'Ivoire. Évite une carte « monde »
/// vide qui ferait peur à un utilisateur low-tech.
final LatLng _kDefaultCenter = LatLng(5.345317, -4.024429);

final _commandeTrackingProvider =
    FutureProvider.autoDispose.family<Commande, String>((ref, id) async {
  return ref.read(ordersServiceProvider).getOrder(id);
});

/// Page de tracking GPS d'une livraison — accessible depuis le suivi de
/// commande côté acheteur quand le transporteur est en route.
///
/// Affiche une carte OpenStreetMap (via `flutter_map`) centrée sur la
/// dernière position connue du transporteur. Si aucune position n'est
/// disponible (pas encore en route ou le backend ne stocke pas encore
/// les events GPS), on affiche un placeholder honnête.
///
/// V1 : carte + infos commande + bannière « En attente ». À enrichir
/// quand le backend exposera `GET /logistics/shipments?commande_id=X`
/// avec les events de tracking joints (le service `getTracking` existe
/// déjà côté Logistics mais on n'a pas encore le shipmentId).
class LivraisonTrackingPage extends ConsumerWidget {
  const LivraisonTrackingPage({required this.commandeId, super.key});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_commandeTrackingProvider(commandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: async.when(
                loading: () => const Chargement(size: 22),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le suivi. $e',
                    onRetry: () =>
                        ref.invalidate(_commandeTrackingProvider(commandeId)),
                  ),
                ),
                data: (cmd) => _build(cmd),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build(Commande cmd) {
    final enRoute = cmd.status == OrderStatus.inProgress;
    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _kDefaultCenter,
              initialZoom: 11,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.farmcash.mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _kDefaultCenter,
                    width: 44,
                    height: 44,
                    child: const _DestinationPin(),
                  ),
                ],
              ),
            ],
          ),
        ),
        _Footer(commande: cmd, enRoute: enRoute),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (context.canPop()) context.pop();
            },
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Suivi du transporteur',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationPin extends StatelessWidget {
  const _DestinationPin();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.local_shipping,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.commande, required this.enRoute});

  final Commande commande;
  final bool enRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (commande.livraisonAdresse != null &&
              commande.livraisonAdresse!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    commande.livraisonAdresse!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kPastelVert,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.gps_fixed,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    enRoute
                        ? 'Le transporteur est en route. Sa position GPS sera affichée ici dès la prochaine mise à jour.'
                        : 'Le transporteur n\'a pas encore pris le colis. Tu verras sa position en temps réel ici dès qu\'il sera en route.',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: AppColors.text,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
