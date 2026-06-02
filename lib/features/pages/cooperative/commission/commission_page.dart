import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/cooperative.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/profil_settings/titre_section_settings.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/cooperative/commission/preview_calcul_commission.dart';

const double _kMinCommission = 0;
const double _kMaxCommission = 30;

/// Provider qui charge le profil coop actuel pour pré-remplir le slider
/// avec le `commission_rate` déjà configuré (chaque coop fixe le sien).
final _coopProfileProvider =
    FutureProvider.autoDispose<Cooperative?>((ref) async {
  final user = ref.watch(currentUserProvider);
  final coopId = user?.cooperativeId;
  if (coopId == null || coopId.isEmpty) return null;
  return ref.read(cooperativesServiceProvider).getPublic(coopId);
});

/// Page Commission par défaut (coopérative). Le taux est **configurable
/// par chaque coop** (entre 0 % et 30 %) — pas une valeur figée par la
/// plateforme. Persisté via `PUT /cooperatives/profile`.
class CommissionCoopPage extends ConsumerStatefulWidget {
  /// Construit la page Commission.
  const CommissionCoopPage({super.key});

  @override
  ConsumerState<CommissionCoopPage> createState() =>
      _CommissionCoopPageState();
}

class _CommissionCoopPageState extends ConsumerState<CommissionCoopPage> {
  double? _taux;
  final _saisieCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _saisieCtrl.dispose();
    super.dispose();
  }

  /// Initialise le slider avec la valeur backend la première fois que
  /// le profil est chargé. `commissionRate` est stocké en fraction (0.05)
  /// → on convertit en pourcentage (5.0) pour l'UI.
  void _hydraterTauxSiBesoin(Cooperative coop) {
    if (_taux != null) return;
    final actuel = (coop.commissionRate * 100).clamp(
      _kMinCommission,
      _kMaxCommission,
    );
    _taux = actuel.toDouble();
    _saisieCtrl.text =
        actuel.toStringAsFixed(1).replaceAll('.', ',');
  }

  void _onSliderChange(double v) {
    setState(() {
      _taux = v;
      _saisieCtrl.text = v.toStringAsFixed(1).replaceAll('.', ',');
    });
  }

  void _onSaisieChange(String s) {
    final cleaned = s.replaceAll(',', '.');
    final parsed = double.tryParse(cleaned);
    if (parsed == null) return;
    if (parsed < _kMinCommission || parsed > _kMaxCommission) return;
    setState(() => _taux = parsed);
  }

  Future<void> _enregistrer() async {
    final taux = _taux;
    if (taux == null || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(cooperativesServiceProvider).updateProfile(
            commissionRate: taux / 100, // UI en %, backend en fraction
          );
      ref.invalidate(_coopProfileProvider);
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Commission par défaut fixée à ${taux.toStringAsFixed(1)} %',
      );
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (_) {
      if (mounted) {
        Snackbars.showErreur(
          context,
          'Impossible d\'enregistrer la commission. Réessaie.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coopAsync = ref.watch(_coopProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteProfilSettings(
              fallbackPath: RouteNames.cooperativeProfilPath,
              titre: 'Commission par défaut',
            ),
            Expanded(
              child: coopAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le profil coop. $e',
                    onRetry: () => ref.invalidate(_coopProfileProvider),
                  ),
                ),
                data: (coop) {
                  if (coop != null) _hydraterTauxSiBesoin(coop);
                  final taux = _taux ?? 5.0;
                  return _buildContenu(taux);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenu(double taux) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space24,
      ),
      children: [
        Text(
          'Pourcentage prélevé automatiquement par ta coopérative sur '
          'chaque vente d\'un membre. Chaque coop fixe son propre taux. '
          'Tu peux toujours définir une commission différente lors de la '
          'publication d\'une annonce spécifique.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        AppDimens.vGap24,

        // Saisie + slider
        Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppDimens.brCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Taux',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _saisieCtrl,
                      onChanged: _onSaisieChange,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceSoft,
                        suffixText: '%',
                        suffixStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: AppDimens.brInput,
                          borderSide: BorderSide(
                            color: AppColors.border,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppDimens.brInput,
                          borderSide: BorderSide(
                            color: AppColors.border,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppDimens.brInput,
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: AppDimens.borderMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppDimens.vGap16,
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.border,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Slider(
                  value: taux.clamp(_kMinCommission, _kMaxCommission),
                  min: _kMinCommission,
                  max: _kMaxCommission,
                  divisions: (_kMaxCommission * 2).round(),
                  label: '${taux.toStringAsFixed(1)} %',
                  onChanged: _onSliderChange,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_kMinCommission.toStringAsFixed(0)} %',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                    ),
                  ),
                  Text(
                    '${_kMaxCommission.toStringAsFixed(0)} %',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppDimens.vGap24,

        const TitreSectionSettings('Aperçu du calcul'),
        PreviewCalculCommission(
          montantReference: 100000,
          tauxPourcent: taux,
        ),
        AppDimens.vGap24,

        // Bouton enregistrer (vraie sauvegarde backend)
        FilledButton(
          onPressed: _saving ? null : _enregistrer,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimens.brButton,
            ),
            textStyle: AppTextStyles.button.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.onPrimary,
                  ),
                )
              : Text('Enregistrer ${taux.toStringAsFixed(1)} %'),
        ),
        AppDimens.vGap16,

        // Note d'info
        Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: AppDimens.brCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
              AppDimens.hGap8,
              Expanded(
                child: Text(
                  'Ce taux s\'applique aux annonces publiées au nom d\'un '
                  'membre, sur le net après les 3 % de commission '
                  'FarmCash. Les annonces directes de la coop ne sont '
                  'pas concernées.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
