import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../profil_settings/hero_identite.dart' show kHeroPrimarySoft;

/// Ligne de paramètre avec interrupteur (switch) à droite — pour préférences
/// notifications, biométrie, mode sombre, etc.
///
/// Cohérente visuellement avec `TuileSettings` mais le tap sur la ligne
/// entière déclenche le toggle (pas seulement le switch).
class TuileToggleSettings extends StatelessWidget {
  /// Construit la ligne toggle.
  const TuileToggleSettings({
    super.key,
    required this.icone,
    required this.label,
    this.sousTitre,
    required this.valeur,
    required this.onChanged,
    this.iconeVerte = false,
  });

  /// Icône affichée à gauche.
  final IconData icone;

  /// Label principal.
  final String label;

  /// Texte secondaire optionnel sous le label.
  final String? sousTitre;

  /// Valeur courante du switch.
  final bool valeur;

  /// Callback déclenché par tap (ligne entière ou switch).
  final ValueChanged<bool> onChanged;

  /// Si vrai, l'icône utilise la palette primaire (vert sur vert pâle).
  final bool iconeVerte;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!valeur),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    iconeVerte ? kHeroPrimarySoft : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                icone,
                size: 18,
                color: iconeVerte
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  if (sousTitre != null && sousTitre!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sousTitre!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Switch.adaptive(
              value: valeur,
              onChanged: onChanged,
              activeTrackColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
