import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Onglets de premier niveau de la page « Mes commandes » côté acheteur.
///
/// Deux flux :
///   • [commandes]    — achats payés (en cours / livrés / etc.)
///   • [reservations] — précommandes sur prévisions (acompte versé)
///
/// L'ancienne option `negociations` a été retirée le 2026-05-27 — les
/// négociations ont leur propre page autonome (`/acheteur/negociations`)
/// accessible via la tuile dédiée sur l'accueil. Une négociation n'est
/// pas une commande, mélanger les deux concepts ici n'était pas clair.
enum OngletPrincipalCommandes { commandes, reservations }

/// Barre 2-segments en haut de la page « Mes commandes » acheteur.
/// Style aligné sur `OngletsCommandes` (underline + couleur primaire)
/// pour rester cohérent avec le sous-filtre interne de Commandes.
class OngletsPrincipalCommandes extends StatelessWidget {
  const OngletsPrincipalCommandes({
    required this.current,
    required this.onSelect,
    this.reservationsBadge = 0,
    super.key,
  });

  /// Onglet sélectionné.
  final OngletPrincipalCommandes current;

  /// Callback de sélection d'onglet.
  final ValueChanged<OngletPrincipalCommandes> onSelect;

  /// Petite pastille sur Réservations (ex: nouvelle confirmation).
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
          _tab(OngletPrincipalCommandes.commandes, 'Commandes'),
          _tab(
            OngletPrincipalCommandes.reservations,
            'Réservations',
            badge: reservationsBadge,
          ),
        ],
      ),
    );
  }

  Widget _tab(
    OngletPrincipalCommandes value,
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
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.primary : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badge > 9 ? '9+' : '$badge',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
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
