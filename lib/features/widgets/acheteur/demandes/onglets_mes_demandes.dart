import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Onglets de filtrage de la liste « Mes demandes » côté acheteur.
enum OngletMesDemandes { actives, conclues, archivees }

/// Barre d'onglets pour la page « Mes demandes ». Bascule entre Actives,
/// Conclues et Archivées avec un compteur sur Actives.
class OngletsMesDemandes extends StatelessWidget {
  const OngletsMesDemandes({
    required this.tab,
    required this.activesCount,
    required this.onChange,
    super.key,
  });

  /// Onglet courant.
  final OngletMesDemandes tab;

  /// Nombre de demandes actives à afficher en compteur.
  final int activesCount;

  /// Callback invoqué quand un onglet est sélectionné.
  final ValueChanged<OngletMesDemandes> onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            _TabItem(
              label: 'Actives ($activesCount)',
              active: tab == OngletMesDemandes.actives,
              onTap: () => onChange(OngletMesDemandes.actives),
            ),
            const SizedBox(width: 18),
            _TabItem(
              label: 'Conclues',
              active: tab == OngletMesDemandes.conclues,
              onTap: () => onChange(OngletMesDemandes.conclues),
            ),
            const SizedBox(width: 18),
            _TabItem(
              label: 'Archivées',
              active: tab == OngletMesDemandes.archivees,
              onTap: () => onChange(OngletMesDemandes.archivees),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
