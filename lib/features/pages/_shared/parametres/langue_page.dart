import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../storage/prefs_storage.dart';
import '../../../widgets/communs/parametres/tuile_option_radio.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/profil_settings/groupe_settings.dart';
import '../../../widgets/communs/profil_settings/titre_section_settings.dart';
import '../../../widgets/communs/snackbars.dart';

/// Options proposées par la page Langue.
const _kOptionsLangue = <_OptionLangue>[
  _OptionLangue(code: 'fr', label: 'Français', sousTitre: 'France · Afrique'),
  _OptionLangue(code: 'en', label: 'English', sousTitre: 'United States'),
];

/// Provider exposant le code langue actuellement enregistré (défaut `fr`).
final _langueCouranteProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(prefsStorageProvider);
  final stored = prefs.locale;
  if (stored == null || stored.isEmpty) return 'fr';
  return stored;
});

/// Page Langue partagée (tous rôles) — sélection radio de la langue de
/// l'interface. Pour V1, le changement est persisté mais l'app ne se
/// retraduit pas immédiatement (pas d'i18n encore). Snackbar de feedback.
class LanguePage extends ConsumerWidget {
  /// Construit la page Langue.
  const LanguePage({super.key, required this.fallbackPath});

  /// Chemin de repli si la pile de navigation est vide (deep link).
  final String fallbackPath;

  Future<void> _selectionner(
    BuildContext context,
    WidgetRef ref,
    String code,
  ) async {
    await ref.read(prefsStorageProvider).setLocale(code);
    ref.read(_langueCouranteProvider.notifier).state = code;
    if (!context.mounted) return;
    Snackbars.showInfo(
      context,
      'Langue mise à jour — relance l\'app pour voir les changements.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courante = ref.watch(_langueCouranteProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteProfilSettings(
              fallbackPath: fallbackPath,
              titre: 'Langue',
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
                    'Choisis la langue de l\'application. Les traductions '
                    'sont disponibles pour le contenu principal.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  AppDimens.vGap16,
                  const TitreSectionSettings('Langues disponibles'),
                  GroupeSettings(
                    rows: [
                      for (final o in _kOptionsLangue)
                        TuileOptionRadio(
                          icone: Icons.language,
                          label: o.label,
                          sousTitre: o.sousTitre,
                          selectionnee: courante == o.code,
                          onTap: () => _selectionner(context, ref, o.code),
                        ),
                    ],
                  ),
                  AppDimens.vGap24,
                  const TitreSectionSettings('Bientôt'),
                  GroupeSettings(
                    rows: [
                      TuileOptionRadio(
                        icone: Icons.language,
                        label: 'Bambara',
                        sousTitre: 'Disponible prochainement',
                        selectionnee: false,
                        onTap: () => Snackbars.showInfo(
                          context,
                          'Bambara — bientôt disponible',
                        ),
                      ),
                      TuileOptionRadio(
                        icone: Icons.language,
                        label: 'Wolof',
                        sousTitre: 'Disponible prochainement',
                        selectionnee: false,
                        onTap: () => Snackbars.showInfo(
                          context,
                          'Wolof — bientôt disponible',
                        ),
                      ),
                    ],
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

class _OptionLangue {
  const _OptionLangue({
    required this.code,
    required this.label,
    required this.sousTitre,
  });

  final String code;
  final String label;
  final String sousTitre;
}
