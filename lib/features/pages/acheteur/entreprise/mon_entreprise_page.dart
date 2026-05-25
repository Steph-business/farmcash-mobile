import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/acheteur/entreprise/champ_texte_entreprise.dart';
import '../../../widgets/acheteur/entreprise/chip_zone_achat.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/profil_settings/titre_section_settings.dart';
import '../../../widgets/communs/snackbars.dart';

/// Liste de zones d'achat suggérées (mock V1 — à remplacer par un endpoint
/// `/marketplace/zones` ou une liste de régions côté backend).
const _kZonesSuggerees = <String>[
  'Abidjan',
  'Yamoussoukro',
  'Bouaké',
  'San-Pédro',
  'Korhogo',
  'Daloa',
  'Man',
  'Gagnoa',
];

/// Page Mon entreprise (acheteur) — fusionne en une seule page éditable
/// l'identité business (raison sociale, RCCM, secteur, contact pro) et
/// les zones d'achat préférées. Mode lecture par défaut, bascule en mode
/// édition via le bouton "Modifier" en haut à droite.
class MonEntrepriseAcheteurPage extends ConsumerStatefulWidget {
  /// Construit la page.
  const MonEntrepriseAcheteurPage({super.key});

  @override
  ConsumerState<MonEntrepriseAcheteurPage> createState() =>
      _MonEntrepriseAcheteurPageState();
}

class _MonEntrepriseAcheteurPageState
    extends ConsumerState<MonEntrepriseAcheteurPage> {
  bool _editing = false;

  final _raisonSocialeCtrl =
      TextEditingController(text: 'AgroNégoce SARL');
  final _rccmCtrl = TextEditingController(text: 'CI-ABJ-2024-B-12345');
  final _secteurCtrl = TextEditingController(text: 'Négoce agricole');
  final _siegeCtrl = TextEditingController(text: 'Abidjan, Cocody');
  final _telProCtrl = TextEditingController(text: '+225 27 22 00 00 00');
  final _emailProCtrl =
      TextEditingController(text: 'contact@agronegoce.ci');

  List<String> _zones = <String>['Abidjan', 'Yamoussoukro', 'Bouaké'];

  @override
  void dispose() {
    _raisonSocialeCtrl.dispose();
    _rccmCtrl.dispose();
    _secteurCtrl.dispose();
    _siegeCtrl.dispose();
    _telProCtrl.dispose();
    _emailProCtrl.dispose();
    super.dispose();
  }

  void _toggleEdition() => setState(() => _editing = !_editing);

  void _ajouterZone() {
    final disponibles = _kZonesSuggerees
        .where((z) => !_zones.contains(z))
        .toList(growable: false);
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
                'Ajouter une zone',
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
    setState(() => _editing = false);
    Snackbars.showInfo(
      context,
      'Modifications enregistrées (backend à câbler)',
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
            _EnteteAvecAction(
              fallbackPath: RouteNames.acheteurProfilPath,
              editing: _editing,
              onAction: _editing ? _enregistrer : _toggleEdition,
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
                    'Les informations de ton entreprise apparaîtront sur tes '
                    'factures et seront partagées avec les producteurs lors '
                    'd\'un achat.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  AppDimens.vGap16,

                  const TitreSectionSettings('Identité légale'),
                  ChampTexteEntreprise(
                    label: 'Raison sociale',
                    controller: _raisonSocialeCtrl,
                    activable: _editing,
                    placeholder: 'Ex. AgroNégoce SARL',
                  ),
                  AppDimens.vGap16,
                  ChampTexteEntreprise(
                    label: 'Numéro RCCM',
                    controller: _rccmCtrl,
                    activable: _editing,
                    helper:
                        'Registre du Commerce et du Crédit Mobilier (format CI-XXX-AAAA-Y-NNNNN)',
                    placeholder: 'Ex. CI-ABJ-2024-B-12345',
                  ),
                  AppDimens.vGap16,
                  ChampTexteEntreprise(
                    label: 'Secteur d\'activité',
                    controller: _secteurCtrl,
                    activable: _editing,
                    placeholder: 'Ex. Négoce agricole, transformation…',
                  ),
                  AppDimens.vGap16,
                  ChampTexteEntreprise(
                    label: 'Adresse du siège',
                    controller: _siegeCtrl,
                    activable: _editing,
                    maxLines: 2,
                    placeholder: 'Quartier, commune, ville',
                  ),
                  AppDimens.vGap24,

                  const TitreSectionSettings('Contact pro'),
                  ChampTexteEntreprise(
                    label: 'Téléphone professionnel',
                    controller: _telProCtrl,
                    keyboardType: TextInputType.phone,
                    activable: _editing,
                  ),
                  AppDimens.vGap16,
                  ChampTexteEntreprise(
                    label: 'Email professionnel',
                    controller: _emailProCtrl,
                    keyboardType: TextInputType.emailAddress,
                    activable: _editing,
                  ),
                  AppDimens.vGap24,

                  // Zones d'achat
                  Row(
                    children: [
                      Expanded(
                        child: const TitreSectionSettings('Zones d\'achat'),
                      ),
                      if (_editing)
                        TextButton.icon(
                          onPressed: _ajouterZone,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Ajouter'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
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
                            'Aucune zone définie. Ajoute les régions où tu '
                            'achètes habituellement pour mieux matcher les '
                            'producteurs.',
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
                                  editable: _editing,
                                  onSupprimer: () => _retirerZone(z),
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

class _EnteteAvecAction extends StatelessWidget {
  const _EnteteAvecAction({
    required this.fallbackPath,
    required this.editing,
    required this.onAction,
  });

  final String fallbackPath;
  final bool editing;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        EnteteProfilSettings(
          fallbackPath: fallbackPath,
          titre: 'Mon entreprise',
        ),
        Positioned(
          right: AppDimens.space8,
          child: TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 36),
            ),
            child: Text(
              editing ? 'Enregistrer' : 'Modifier',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
