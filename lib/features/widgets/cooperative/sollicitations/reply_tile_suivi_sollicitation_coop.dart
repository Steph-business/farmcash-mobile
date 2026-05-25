import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/snackbars.dart';
import 'accept_btn_suivi_sollicitation_coop.dart';
import 'confirmed_chip_suivi_sollicitation_coop.dart';
import 'done_chip_suivi_sollicitation_coop.dart';
import 'mode_chip_suivi_sollicitation_coop.dart';
import 'modele_sollicitation_suivi_coop.dart';
import 'role_tag_suivi_sollicitation_coop.dart';

/// Tuile d'une réponse fournisseur dans le suivi sollicitation : avatar
/// initiales, nom + badge rôle, quantité kg + chip mode, et bouton
/// d'action contextuel à droite (Confirmer / Confirmé / En attente).
///
/// Stateful : porte l'état `_busy` pendant l'appel
/// `confirmRecipientResponse` et invalide
/// [sollicitationSuiviCoopProvider] au succès.
class ReplyTileSuiviSollicitationCoop extends ConsumerStatefulWidget {
  const ReplyTileSuiviSollicitationCoop({
    required this.reply,
    required this.sollicitationId,
    super.key,
  });

  final SollicitationReplyCoop reply;
  final String sollicitationId;

  @override
  ConsumerState<ReplyTileSuiviSollicitationCoop> createState() =>
      _ReplyTileSuiviSollicitationCoopState();
}

class _ReplyTileSuiviSollicitationCoopState
    extends ConsumerState<ReplyTileSuiviSollicitationCoop> {
  bool _busy = false;

  Future<void> _confirmer() async {
    if (_busy) return;
    final recipientId = widget.reply.recipientId;
    if (recipientId == null || recipientId.isEmpty) {
      Snackbars.showErreur(context, 'Identifiant de destinataire manquant');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(cooperativesServiceProvider).confirmRecipientResponse(
            sollicitationId: widget.sollicitationId,
            recipientId: recipientId,
          );
      if (!mounted) return;
      ref.invalidate(sollicitationSuiviCoopProvider(widget.sollicitationId));
      Snackbars.showSucces(context, 'Engagement confirmé');
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reply = widget.reply;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kPrimarySoftSollicitationCoop,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initialesSollicitationCoop(reply.nom),
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        reply.nom,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    RoleTagSuiviSollicitationCoop(role: reply.role),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${formatKgSollicitationCoop(reply.qtyKg)} kg',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const ModeChipSuiviSollicitationCoop(label: 'Maintenant'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (reply.confirme)
            const ConfirmedChipSuiviSollicitationCoop()
          else if (reply.deja)
            AcceptBtnSuiviSollicitationCoop(
              label: _busy ? '…' : 'Confirmer',
              onTap: _busy ? null : _confirmer,
            )
          else
            const DoneChipSuiviSollicitationCoop(label: 'En attente'),
        ],
      ),
    );
  }
}
