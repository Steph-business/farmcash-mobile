import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/livraison.dart';
import '../../../../models/shipment_evaluation.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/commandes/etat_vide_evaluation_commande.dart';
import '../../../widgets/acheteur/commandes/formulaire_evaluation_commande.dart';
import '../../../widgets/acheteur/commandes/vue_evaluation_existante_commande.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

/// Bundle "shipment associé à une commande + éventuelle évaluation déjà
/// soumise". Le backend n'expose pas de getShipmentByOrder direct — on
/// retrouve donc le shipment dans `/logistics/shipments/my` (qui est
/// role-scoped : pour un buyer, renvoie ses livraisons).
class _EvaluationBundle {
  const _EvaluationBundle({
    required this.shipment,
    required this.evaluation,
  });

  final Livraison? shipment;
  final ShipmentEvaluation? evaluation;
}

final _evaluationBundleProvider = FutureProvider.autoDispose
    .family<_EvaluationBundle, String>((ref, commandeId) async {
  final logi = ref.read(logisticsServiceProvider);
  final mes = await logi.getMyMissions();
  Livraison? shipment;
  for (final l in mes) {
    if (l.commandeId == commandeId) {
      shipment = l;
      break;
    }
  }
  if (shipment == null) {
    return const _EvaluationBundle(shipment: null, evaluation: null);
  }
  final existing = await logi.getShipmentEvaluation(shipment.id);
  return _EvaluationBundle(shipment: shipment, evaluation: existing);
});

/// Évaluation du transporteur par l'acheteur après une livraison confirmée.
/// Reçoit `commandeId` en arg ; résout le shipmentId côté client.
class EvaluationTransportPage extends ConsumerStatefulWidget {
  const EvaluationTransportPage({super.key, required this.commandeId});

  final String commandeId;

  @override
  ConsumerState<EvaluationTransportPage> createState() =>
      _EvaluationTransportPageState();
}

class _EvaluationTransportPageState
    extends ConsumerState<EvaluationTransportPage> {
  final TextEditingController _commentCtrl = TextEditingController();
  int _note = 0;
  bool _busy = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(String shipmentId) async {
    if (_busy) return;
    if (_note < 1 || _note > 5) {
      Snackbars.showErreur(context, 'Choisissez une note de 1 à 5 étoiles');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(logisticsServiceProvider).evaluateShipment(
            shipmentId: shipmentId,
            note: _note,
            commentaire: _commentCtrl.text.trim(),
          );
      if (!mounted) return;
      ref.invalidate(_evaluationBundleProvider(widget.commandeId));
      Snackbars.showSucces(context, 'Évaluation enregistrée. Merci !');
      if (context.canPop()) context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_evaluationBundleProvider(widget.commandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Évaluer le transport'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la livraison. $e',
                    onRetry: () => ref.invalidate(
                      _evaluationBundleProvider(widget.commandeId),
                    ),
                  ),
                ),
                data: (bundle) => _content(bundle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(_EvaluationBundle bundle) {
    final shipment = bundle.shipment;
    if (shipment == null) {
      return const EtatVideEvaluationCommande();
    }

    final existing = bundle.evaluation;
    if (existing != null) {
      return VueEvaluationExistanteCommande(evaluation: existing);
    }
    return FormulaireEvaluationCommande(
      note: _note,
      busy: _busy,
      commentCtrl: _commentCtrl,
      onNoteChanged: (i) => setState(() => _note = i),
      onSubmit: () => _submit(shipment.id),
    );
  }
}
