import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/acheteur/entreprise/chip_zone_achat.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/profil_settings/titre_section_settings.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/transporteur/tarification/champ_tarif.dart';

final _nf = NumberFormat('#,##0', 'fr_FR');

/// Zones couvertes suggérées.
const _kZonesSuggerees = <String>[
  'Abidjan',
  'Yamoussoukro',
  'Bouaké',
  'San-Pédro',
  'Korhogo',
  'Daloa',
  'Man',
  'Gagnoa',
  'Soubré',
  'Divo',
];

/// Page Tarification & zones (transporteur) — consolidation des 3 lignes
/// du profil (Tarif par kg / Tarif minimum / Zones couvertes) en un seul
/// formulaire éditable. Inclut une preview du coût simulé pour 500 kg.
class TarificationTransporteurPage extends ConsumerStatefulWidget {
  /// Construit la page.
  const TarificationTransporteurPage({super.key});

  @override
  ConsumerState<TarificationTransporteurPage> createState() =>
      _TarificationTransporteurPageState();
}

class _TarificationTransporteurPageState
    extends ConsumerState<TarificationTransporteurPage> {
  final _tarifParKgCtrl = TextEditingController(text: '150');
  final _tarifMinimumCtrl = TextEditingController(text: '15000');

  List<String> _zones = const <String>[
    'Abidjan',
    'Yamoussoukro',
    'Bouaké',
  ];

  @override
  void dispose() {
    _tarifParKgCtrl.dispose();
    _tarifMinimumCtrl.dispose();
    super.dispose();
  }

  void _ajouterZone() {
    final disponibles =
        _kZonesSuggerees.where((z) => !_zones.contains(z)).toList();
    if (disponibles.isEmpty) {
      Snackbars.showInfo(context, 'Toutes les zones sont déjà ajoutées.');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pagePaddingH,
            AppDimens.space16,
            AppDimens.pagePaddingH,
            AppDimens.space24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppDimens.vGap16,
              Text(
                'Ajouter une zone couverte',
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppDimens.vGap12,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final z in disponibles)
                    InkWell(
                      onTap: () {
                        setState(() => _zones = [..._zones, z]);
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: ChipZoneAchat(
                        label: z,
                        editable: false,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _retirerZone(String z) {
    setState(() => _zones = _zones.where((x) => x != z).toList());
  }

  void _enregistrer() {
    Snackbars.showInfo(
      context,
      'Tarification enregistrée (backend à câbler)',
    );
  }

  double _parserMontant(String s) {
    return double.tryParse(s.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final tarifKg = _parserMontant(_tarifParKgCtrl.text);
    final tarifMin = _parserMontant(_tarifMinimumCtrl.text);
    final cout500 = (tarifKg * 500).clamp(tarifMin, double.infinity);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteProfilSettings(
              fallbackPath: RouteNames.transporteurProfilPath,
              titre: 'Tarification & zones',
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
                    'Ces tarifs s\'appliquent par défaut à toutes tes '
                    'missions. Tu peux toujours négocier au cas par cas.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  AppDimens.vGap24,

                  const TitreSectionSettings('Tarifs'),
                  ChampTarif(
                    label: 'Tarif par kilo transporté',
                    controller: _tarifParKgCtrl,
                    helper:
                        'Prix au kilo, hors péages et taxes éventuelles.',
                  ),
                  AppDimens.vGap16,
                  ChampTarif(
                    label: 'Tarif minimum par mission',
                    controller: _tarifMinimumCtrl,
                    helper:
                        'Tarif plancher pour rentabiliser un déplacement, '
                        'même pour de petites quantités.',
                  ),
                  AppDimens.vGap24,

                  // Preview
                  const TitreSectionSettings('Simulation 500 kg'),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: AppDimens.brCard,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pour une livraison de 500 kg :',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        AppDimens.vGap8,
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Coût pour l\'acheteur',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${_nf.format(cout500.round())} F',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cout500 > tarifKg * 500
                              ? 'Tarif minimum appliqué (le calcul au kg '
                                  'donne ${_nf.format((tarifKg * 500).round())} F).'
                              : '${_nf.format(tarifKg.round())} F × 500 kg',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppDimens.vGap24,

                  // Zones couvertes
                  Row(
                    children: [
                      Expanded(
                        child:
                            const TitreSectionSettings('Zones couvertes'),
                      ),
                      TextButton.icon(
                        onPressed: _ajouterZone,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Ajouter'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
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
                    child: _zones.isEmpty
                        ? Text(
                            'Aucune zone définie. Ajoute les régions que tu '
                            'desserves pour apparaître dans les recherches '
                            'des acheteurs.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final z in _zones)
                                ChipZoneAchat(
                                  label: z,
                                  editable: true,
                                  onSupprimer: () => _retirerZone(z),
                                ),
                            ],
                          ),
                  ),
                  AppDimens.vGap24,

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
                    child: const Text('Enregistrer les tarifs'),
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
