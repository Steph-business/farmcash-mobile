import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Onglets de premier niveau de la page « Commandes » côté PRODUCTEUR.
///
/// Deux flux symétriques de ceux côté acheteur :
///   • [ventes]        — commandes payées par les acheteurs (= ventes
///                       du producteur, côté seller)
///   • [reservations]  — réservations faites par les acheteurs sur les
///                       prévisions de récolte du producteur (acompte
///                       versé, pas encore une vraie commande)
enum OngletPrincipalCommandesProducteur { ventes, reservations }

/// Barre 2-segments en haut de la page « Commandes » producteur. Style
/// aligné sur `OngletsCommandes` (underline + couleur primaire) pour
/// rester cohérent avec le sous-filtre interne des Ventes (En cours /
/// Livrées / Annulées).
class OngletsPrincipalCommandesProducteur extends StatelessWidget {
  const OngletsPrincipalCommandesProducteur({
    super.key,
    required this.current,
    required this.onSelect,
    this.reservationsBadge = 0,
  });

  /// Onglet sélectionné.
  final OngletPrincipalCommandesProducteur current;

  /// Callback de sélection d'onglet.
  final ValueChanged<OngletPrincipalCommandesProducteur> onSelect;

  /// Petite pastille sur Réservations (ex. nouvelle réservation reçue).
  final int reservationsBadge;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
          _tab(OngletPrincipalCommandesProducteur.ventes, 'Mes ventes'),
          _tab(
            OngletPrincipalCommandesProducteur.reservations,
            'Réservations',
            badge: reservationsBadge,
          ),
        ],
      ),
    );
  }

  Widget _tab(
    OngletPrincipalCommandesProducteur value,
    String label, {
    int badge = 0,
  }) {
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.button.copyWith(
                  fontSize: 13.5,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active ? AppColors.text : AppColors.textSecondary,
                ),
              ),
              if (badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badge',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
