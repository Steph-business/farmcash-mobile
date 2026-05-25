import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/snackbars.dart';
import 'modele_sollicitation_suivi_coop.dart';

/// Barre d'actions sticky en bas de la page suivi sollicitation :
/// « Relancer non-répondants » (outline, stub à venir) et « Clôturer »
/// (plein, appelle `closeSollicitation` puis invalide le provider).
///
/// Stateful : porte l'état `_busy` partagé entre les deux boutons pour
/// désactiver toute action tant que l'appel réseau est en vol.
class StickySuiviSollicitationCoop extends ConsumerStatefulWidget {
  const StickySuiviSollicitationCoop({
    required this.sollicitationId,
    super.key,
  });

  final String sollicitationId;

  @override
  ConsumerState<StickySuiviSollicitationCoop> createState() =>
      _StickySuiviSollicitationCoopState();
}

class _StickySuiviSollicitationCoopState
    extends ConsumerState<StickySuiviSollicitationCoop> {
  bool _busy = false;

  Future<void> _cloturer() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(cooperativesServiceProvider)
          .closeSollicitation(widget.sollicitationId);
      if (!mounted) return;
      ref.invalidate(sollicitationSuiviCoopProvider(widget.sollicitationId));
      Snackbars.showSucces(context, 'Sollicitation clôturée');
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _relancer() {
    Snackbars.showInfo(context, 'Relance — à venir');
  }

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
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _busy ? null : _relancer,
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Relancer non-répondants',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: _busy ? null : _cloturer,
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Clôturer',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
