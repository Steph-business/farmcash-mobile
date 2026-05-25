import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Onglets de filtrage de la liste « Mes commandes » côté acheteur.
enum OngletCommandes { enCours, livrees, toutes }

/// Barre d'onglets pour basculer entre les listes filtrées de commandes
/// (En cours / Livrées / Toutes). Affiche les compteurs pour chaque onglet.
class OngletsCommandes extends StatelessWidget {
  const OngletsCommandes({
    required this.current,
    required this.enCoursCount,
    required this.livreesCount,
    required this.onSelect,
    super.key,
  });

  /// Onglet actuellement sélectionné.
  final OngletCommandes current;

  /// Nombre de commandes en cours.
  final int enCoursCount;

  /// Nombre de commandes livrées.
  final int livreesCount;

  /// Callback invoqué lorsqu'un onglet est sélectionné.
  final ValueChanged<OngletCommandes> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: Row(
        children: [
          _tab(OngletCommandes.enCours, 'En cours ($enCoursCount)'),
          _tab(OngletCommandes.livrees, 'Livrées ($livreesCount)'),
          _tab(OngletCommandes.toutes, 'Toutes'),
        ],
      ),
    );
  }

  Widget _tab(OngletCommandes value, String label) {
    final active = value == current;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
