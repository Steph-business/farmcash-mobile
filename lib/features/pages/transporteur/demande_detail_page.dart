import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/livraison.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/transporteur/missions/actions_sticky_demande.dart';
import '../../widgets/transporteur/missions/carte_emetteur_demande.dart';
import '../../widgets/transporteur/missions/carte_marchandise_demande.dart';
import '../../widgets/transporteur/missions/carte_montant_demande.dart';
import '../../widgets/transporteur/missions/carte_notes_demande.dart';
import '../../widgets/transporteur/missions/carte_trajet_demande.dart';
import '../../widgets/transporteur/missions/entete_demande_detail.dart';
import '../../widgets/transporteur/missions/titre_section_mission.dart';

/// Charge la mission depuis la liste disponible (le back n'expose pas de
/// GET unitaire shipment côté transporteur — on filtre la liste).
final _demandeProvider = FutureProvider.autoDispose
    .family<Livraison?, String>((ref, id) async {
  final list = await ref.read(logisticsServiceProvider).getAvailableMissions();
  for (final m in list) {
    if (m.id == id) return m;
  }
  return null;
});

/// Détail d'une demande de transport entrante — vue avant acceptation.
/// Le CTA "Accepter" appelle `acceptShipment` (first-arrived first-served).
class DemandeDetailPage extends ConsumerStatefulWidget {
  const DemandeDetailPage({required this.demandeId, super.key});

  final String demandeId;

  @override
  ConsumerState<DemandeDetailPage> createState() => _DemandeDetailPageState();
}

class _DemandeDetailPageState extends ConsumerState<DemandeDetailPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_demandeProvider(widget.demandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              EnteteDemandeDetail(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const EnteteDemandeDetail(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la demande. $e',
                    onRetry: () =>
                        ref.invalidate(_demandeProvider(widget.demandeId)),
                  ),
                ),
              ),
            ],
          ),
          data: (m) {
            if (m == null) {
              return Column(
                children: [
                  const EnteteDemandeDetail(),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                        child: Text(
                          'Cette demande n\'est plus disponible.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                const EnteteDemandeDetail(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                    children: [
                      CarteEmetteurDemande(mission: m),
                      AppDimens.vGap16,
                      const TitreSectionMission('Marchandise'),
                      AppDimens.vGap8,
                      CarteMarchandiseDemande(mission: m),
                      AppDimens.vGap16,
                      const TitreSectionMission('Trajet'),
                      AppDimens.vGap8,
                      CarteTrajetDemande(mission: m),
                      AppDimens.vGap16,
                      const TitreSectionMission('Montant'),
                      AppDimens.vGap8,
                      CarteMontantDemande(mission: m),
                      if (m.notes != null && m.notes!.trim().isNotEmpty) ...[
                        AppDimens.vGap16,
                        const TitreSectionMission('Notes'),
                        AppDimens.vGap8,
                        CarteNotesDemande(notes: m.notes!),
                      ],
                    ],
                  ),
                ),
                ActionsStickyDemande(
                  busy: _busy,
                  onRefuser: () => Navigator.of(context).maybePop(),
                  onAccepter: () => _accepter(m),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _accepter(Livraison mission) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(logisticsServiceProvider).acceptShipment(mission.id);
      if (!mounted) return;
      Snackbars.showSucces(context, 'Mission acceptée');
      // Recharge la liste pour que la mission disparaisse des disponibles.
      ref.invalidate(_demandeProvider(widget.demandeId));
      context.go(RouteNames.transporteurMissionDetailPathFor(mission.id));
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
