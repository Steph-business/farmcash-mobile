import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/livraison.dart';
import '../../../../models/shipment_evaluation.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

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
            const _Header(),
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
      return Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: _kPrimarySoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.local_shipping_outlined,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Livraison introuvable',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Aucun transport n'est rattaché à cette commande. "
                "L'évaluation devient disponible une fois la livraison effectuée.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final existing = bundle.evaluation;
    if (existing != null) {
      return _readOnly(existing);
    }
    return _form(shipment);
  }

  Widget _readOnly(ShipmentEvaluation evaluation) {
    final dateLabel = evaluation.createdAt != null
        ? DateFormat('d MMM yyyy', 'fr_FR')
            .format(evaluation.createdAt!.toLocal())
        : '—';
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        12,
        AppDimens.pagePaddingH,
        24,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _kPrimarySoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Déjà évalué le $dateLabel',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppDimens.vGap24,
        Text(
          'Votre note',
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 1; i <= 5; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  i <= evaluation.note ? Icons.star : Icons.star_border,
                  size: 32,
                  color: i <= evaluation.note
                      ? AppColors.primary
                      : AppColors.textSubtle,
                ),
              ),
          ],
        ),
        if ((evaluation.commentaire ?? '').isNotEmpty) ...[
          AppDimens.vGap24,
          Text(
            'Votre commentaire',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Text(
              evaluation.commentaire!,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }

  Widget _form(Livraison shipment) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePaddingH,
              12,
              AppDimens.pagePaddingH,
              24,
            ),
            children: [
              Text(
                'Comment s\'est passé le transport ?',
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Votre avis aide les autres acheteurs à choisir.',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              AppDimens.vGap24,
              Text(
                'Votre note',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 1; i <= 5; i++)
                    InkWell(
                      onTap: _busy ? null : () => setState(() => _note = i),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          i <= _note ? Icons.star : Icons.star_border,
                          size: 40,
                          color: i <= _note
                              ? AppColors.primary
                              : AppColors.textSubtle,
                        ),
                      ),
                    ),
                ],
              ),
              AppDimens.vGap24,
              Text(
                'Commentaire (optionnel)',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _commentCtrl,
                  maxLines: 4,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    hintText: 'Délais, état des marchandises, communication…',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSubtle,
                      fontSize: 13,
                    ),
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        _StickyButton(
          busy: _busy,
          onTap: () => _submit(shipment.id),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
              color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space8,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
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
              'Évaluer le transport',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyButton extends StatelessWidget {
  const _StickyButton({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        12,
        AppDimens.pagePaddingH,
        14,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: busy ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Envoyer mon évaluation',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
