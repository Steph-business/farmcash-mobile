import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Critère de tri applicable au marché.
enum TriMarche {
  /// Plus récent en premier (défaut).
  recent,

  /// Du moins cher au plus cher.
  prixCroissant,

  /// Du plus cher au moins cher.
  prixDecroissant,

  /// Quantité disponible (plus grosse en premier).
  quantite,
}

extension TriMarcheLabel on TriMarche {
  /// Libellé court affiché dans la sheet.
  String get label {
    switch (this) {
      case TriMarche.recent:
        return 'Plus récent';
      case TriMarche.prixCroissant:
        return 'Prix croissant';
      case TriMarche.prixDecroissant:
        return 'Prix décroissant';
      case TriMarche.quantite:
        return 'Quantité disponible';
    }
  }

  /// Icône indicative.
  IconData get icone {
    switch (this) {
      case TriMarche.recent:
        return Icons.schedule;
      case TriMarche.prixCroissant:
        return Icons.south;
      case TriMarche.prixDecroissant:
        return Icons.north;
      case TriMarche.quantite:
        return Icons.scale;
    }
  }
}

/// État retourné par la sheet quand l'utilisateur valide.
class ResultatFiltresAvances {
  /// Construit le résultat.
  const ResultatFiltresAvances({
    required this.tri,
    required this.qualite,
    required this.prixMaxKg,
  });

  /// Critère de tri sélectionné.
  final TriMarche tri;

  /// Qualité sélectionnée. `null` = toutes les qualités.
  final ProductQuality? qualite;

  /// Prix max par kg (slider 0-2000 F). `null` = pas de plafond.
  final double? prixMaxKg;
}

/// Bottom sheet de filtres avancés du marché. Ouvre via `+ Filtres`.
///
/// Permet de choisir un tri, une qualité, et un prix maximum. Retourne
/// un [ResultatFiltresAvances] via `Navigator.pop(context, resultat)`.
class SheetFiltresAvancesMarche extends StatefulWidget {
  /// Construit la sheet en pré-remplissant l'état courant.
  const SheetFiltresAvancesMarche({
    super.key,
    required this.triInitial,
    required this.qualiteInitiale,
    required this.prixMaxInitial,
  });

  /// Tri initialement sélectionné.
  final TriMarche triInitial;

  /// Qualité initialement sélectionnée (null = toutes).
  final ProductQuality? qualiteInitiale;

  /// Prix max initial (null = pas de plafond).
  final double? prixMaxInitial;

  @override
  State<SheetFiltresAvancesMarche> createState() =>
      _SheetFiltresAvancesMarcheState();
}

class _SheetFiltresAvancesMarcheState
    extends State<SheetFiltresAvancesMarche> {
  late TriMarche _tri;
  ProductQuality? _qualite;
  late double _prixMax;
  static const double _kPrixMaxBorne = 2000;

  @override
  void initState() {
    super.initState();
    _tri = widget.triInitial;
    _qualite = widget.qualiteInitiale;
    _prixMax = widget.prixMaxInitial ?? _kPrixMaxBorne;
  }

  void _reinitialiser() {
    setState(() {
      _tri = TriMarche.recent;
      _qualite = null;
      _prixMax = _kPrixMaxBorne;
    });
  }

  void _appliquer() {
    Navigator.of(context).pop(
      ResultatFiltresAvances(
        tri: _tri,
        qualite: _qualite,
        prixMaxKg: _prixMax >= _kPrixMaxBorne ? null : _prixMax,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filtres avancés',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _reinitialiser,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'Réinitialiser',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            AppDimens.vGap16,

            // Tri
            Text(
              'Trier par',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            AppDimens.vGap8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in TriMarche.values)
                  _ChipFiltreSheet(
                    icone: t.icone,
                    label: t.label,
                    actif: _tri == t,
                    onTap: () => setState(() => _tri = t),
                  ),
              ],
            ),
            AppDimens.vGap24,

            // Qualité
            Text(
              'Qualité',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            AppDimens.vGap8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChipFiltreSheet(
                  icone: Icons.all_inclusive,
                  label: 'Toutes',
                  actif: _qualite == null,
                  onTap: () => setState(() => _qualite = null),
                ),
                _ChipFiltreSheet(
                  icone: Icons.label_outline,
                  label: 'Standard',
                  actif: _qualite == ProductQuality.standard,
                  onTap: () => setState(
                    () => _qualite = ProductQuality.standard,
                  ),
                ),
                _ChipFiltreSheet(
                  icone: Icons.workspace_premium_outlined,
                  label: 'Premium',
                  actif: _qualite == ProductQuality.premium,
                  onTap: () => setState(
                    () => _qualite = ProductQuality.premium,
                  ),
                ),
                _ChipFiltreSheet(
                  icone: Icons.eco_outlined,
                  label: 'Bio',
                  actif: _qualite == ProductQuality.bio,
                  onTap: () => setState(
                    () => _qualite = ProductQuality.bio,
                  ),
                ),
                _ChipFiltreSheet(
                  icone: Icons.handshake_outlined,
                  label: 'Équitable',
                  actif: _qualite == ProductQuality.equitable,
                  onTap: () => setState(
                    () => _qualite = ProductQuality.equitable,
                  ),
                ),
              ],
            ),
            AppDimens.vGap24,

            // Prix max
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Prix max par kg',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  _prixMax >= _kPrixMaxBorne
                      ? 'Sans limite'
                      : '${_prixMax.round()} F/kg',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: _prixMax,
                min: 100,
                max: _kPrixMaxBorne,
                divisions: 19,
                label: _prixMax >= _kPrixMaxBorne
                    ? 'Sans limite'
                    : '${_prixMax.round()} F',
                onChanged: (v) => setState(() => _prixMax = v),
              ),
            ),
            AppDimens.vGap16,

            // CTA Appliquer
            FilledButton(
              onPressed: _appliquer,
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
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipFiltreSheet extends StatelessWidget {
  const _ChipFiltreSheet({
    required this.icone,
    required this.label,
    required this.actif,
    required this.onTap,
  });

  final IconData icone;
  final String label;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: actif
              ? const Color(0xFFE8F5E9)
              : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: actif
                ? AppColors.primary
                : AppColors.border,
            width: actif ? 1.5 : AppDimens.borderThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: 14,
              color: actif ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    actif ? AppColors.primary : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
