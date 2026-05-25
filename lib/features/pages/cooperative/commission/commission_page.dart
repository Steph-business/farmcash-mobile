import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/profil_settings/titre_section_settings.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/cooperative/commission/preview_calcul_commission.dart';

const double _kMinCommission = 0;
const double _kMaxCommission = 30;

/// Page Commission par défaut (coopérative). Slider + saisie numérique +
/// preview du calcul sur 100 000 F. Le taux s'applique automatiquement à
/// toutes les ventes effectuées via la coop, sauf override par annonce.
class CommissionCoopPage extends ConsumerStatefulWidget {
  /// Construit la page Commission.
  const CommissionCoopPage({super.key});

  @override
  ConsumerState<CommissionCoopPage> createState() =>
      _CommissionCoopPageState();
}

class _CommissionCoopPageState extends ConsumerState<CommissionCoopPage> {
  double _taux = 5;
  final _saisieCtrl = TextEditingController(text: '5,0');

  @override
  void dispose() {
    _saisieCtrl.dispose();
    super.dispose();
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

  void _enregistrer() {
    Snackbars.showInfo(
      context,
      'Commission par défaut fixée à ${_taux.toStringAsFixed(1)} %',
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  AppDimens.space8,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: [
                  Text(
                    'Pourcentage prélevé automatiquement par la coopérative '
                    'sur chaque vente d\'un membre. Tu peux toujours définir '
                    'une commission différente lors de la publication d\'une '
                    'annonce spécifique.',
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
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.surfaceSoft,
                                  suffixText: '%',
                                  suffixStyle:
                                      AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
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
                            overlayColor:
                                AppColors.primary.withValues(alpha: 0.1),
                          ),
                          child: Slider(
                            value: _taux,
                            min: _kMinCommission,
                            max: _kMaxCommission,
                            divisions: (_kMaxCommission * 2).round(),
                            label: '${_taux.toStringAsFixed(1)} %',
                            onChanged: _onSliderChange,
                          ),
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
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
                    tauxPourcent: _taux,
                  ),
                  AppDimens.vGap24,

                  // Bouton enregistrer
                  FilledButton(
                    onPressed: _enregistrer,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      minimumSize:
                          const Size.fromHeight(AppDimens.buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimens.brButton,
                      ),
                      textStyle: AppTextStyles.button.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(
                      'Enregistrer ${_taux.toStringAsFixed(1)} %',
                    ),
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
                            'Ce taux ne s\'applique qu\'aux annonces '
                            'publiées au nom d\'un membre. Les annonces '
                            'directes de la coopérative restent à 100 % '
                            'pour la coop.',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
