import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/acheteur/entreprise/champ_texte_entreprise.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/profil_settings/titre_section_settings.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/cooperative/identite/chip_produit.dart';

/// Produits suggérés (catalogue de référence — à remplacer par
/// `marketplaceService.listProduits()` quand on aura un endpoint dédié).
const _kProduitsSuggeres = <String>[
  'Cacao',
  'Café',
  'Anacarde',
  'Hévéa',
  'Palmier à huile',
  'Coton',
  'Riz',
  'Maïs',
  'Igname',
  'Manioc',
  'Banane plantain',
  'Mangue',
];

/// Régions / villes suggérées.
const _kRegionsSuggerees = <String>[
  'District d\'Abidjan',
  'Région du Sud-Comoé',
  'Région du Bélier',
  'Région du Gbêkê',
  'Région du Tonkpi',
  'Région du Poro',
  'Région du Haut-Sassandra',
  'Région des Lagunes',
];

/// Page Identité coopérative — formulaire édition consolidé :
/// numéro d'agrément, région & ville, produits gérés. Pattern lecture
/// par défaut avec bascule en mode édition.
class IdentiteCoopPage extends ConsumerStatefulWidget {
  /// Construit la page Identité coop.
  const IdentiteCoopPage({super.key});

  @override
  ConsumerState<IdentiteCoopPage> createState() => _IdentiteCoopPageState();
}

class _IdentiteCoopPageState extends ConsumerState<IdentiteCoopPage> {
  bool _editing = false;

  final _nomCoopCtrl = TextEditingController(text: 'COOP-CACAO Bouaké');
  final _agrementCtrl = TextEditingController(text: 'COOP-CI-2023-00874');
  final _regionCtrl =
      TextEditingController(text: 'Région du Gbêkê');
  final _villeCtrl = TextEditingController(text: 'Bouaké');
  final _adresseCtrl = TextEditingController(text: 'Quartier Air-France');
  final _anneeCreationCtrl = TextEditingController(text: '2018');

  List<String> _produits = const [
    'Cacao',
    'Café',
    'Anacarde',
  ];

  @override
  void dispose() {
    _nomCoopCtrl.dispose();
    _agrementCtrl.dispose();
    _regionCtrl.dispose();
    _villeCtrl.dispose();
    _adresseCtrl.dispose();
    _anneeCreationCtrl.dispose();
    super.dispose();
  }

  void _toggleEdition() => setState(() => _editing = !_editing);

  void _ajouterProduit() {
    final disponibles = _kProduitsSuggeres
        .where((p) => !_produits.contains(p))
        .toList();
    if (disponibles.isEmpty) {
      Snackbars.showInfo(context, 'Tous les produits sont déjà ajoutés.');
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
                'Ajouter un produit',
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
                  for (final p in disponibles)
                    InkWell(
                      onTap: () {
                        setState(() => _produits = [..._produits, p]);
                        Navigator.of(context).pop();
                      },
                      child: ChipProduitCoop(
                        label: p,
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

  void _retirerProduit(String p) {
    setState(() => _produits = _produits.where((x) => x != p).toList());
  }

  void _enregistrer() {
    setState(() => _editing = false);
    Snackbars.showInfo(
      context,
      'Identité enregistrée (backend à câbler)',
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
            Stack(
              alignment: Alignment.center,
              children: [
                const EnteteProfilSettings(
                  fallbackPath: RouteNames.cooperativeProfilPath,
                  titre: 'Identité de la coop',
                ),
                Positioned(
                  right: AppDimens.space8,
                  child: TextButton(
                    onPressed: _editing ? _enregistrer : _toggleEdition,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(
                      _editing ? 'Enregistrer' : 'Modifier',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
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
                    'Ces informations sont visibles par les acheteurs et '
                    'apparaissent sur la fiche publique de ta coopérative.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  AppDimens.vGap16,

                  const TitreSectionSettings('Identité légale'),
                  ChampTexteEntreprise(
                    label: 'Nom de la coopérative',
                    controller: _nomCoopCtrl,
                    activable: _editing,
                  ),
                  AppDimens.vGap16,
                  ChampTexteEntreprise(
                    label: 'Numéro d\'agrément',
                    controller: _agrementCtrl,
                    activable: _editing,
                    helper:
                        'Numéro officiel délivré par le Ministère de l\'Agriculture',
                  ),
                  AppDimens.vGap16,
                  ChampTexteEntreprise(
                    label: 'Année de création',
                    controller: _anneeCreationCtrl,
                    activable: _editing,
                    keyboardType: TextInputType.number,
                  ),
                  AppDimens.vGap24,

                  const TitreSectionSettings('Localisation'),
                  ChampTexteEntreprise(
                    label: 'Région',
                    controller: _regionCtrl,
                    activable: _editing,
                    placeholder: 'Ex. Région du Gbêkê',
                  ),
                  AppDimens.vGap16,
                  ChampTexteEntreprise(
                    label: 'Ville',
                    controller: _villeCtrl,
                    activable: _editing,
                    placeholder: 'Ex. Bouaké',
                  ),
                  AppDimens.vGap16,
                  ChampTexteEntreprise(
                    label: 'Adresse du siège',
                    controller: _adresseCtrl,
                    activable: _editing,
                    maxLines: 2,
                    placeholder: 'Quartier, repère',
                  ),
                  AppDimens.vGap24,

                  Row(
                    children: [
                      Expanded(
                        child: const TitreSectionSettings('Produits gérés'),
                      ),
                      if (_editing)
                        TextButton.icon(
                          onPressed: _ajouterProduit,
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
                    child: _produits.isEmpty
                        ? Text(
                            'Aucun produit géré pour le moment. Ajoute les '
                            'cultures que ta coopérative collecte ou '
                            'commercialise.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final p in _produits)
                                ChipProduitCoop(
                                  label: p,
                                  editable: _editing,
                                  onSupprimer: () => _retirerProduit(p),
                                ),
                            ],
                          ),
                  ),
                  AppDimens.vGap16,
                  if (_editing)
                    Text(
                      'Suggestions : '
                      '${_kRegionsSuggerees.take(3).join(" · ")}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSubtle,
                        fontSize: 11,
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
