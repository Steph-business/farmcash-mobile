import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Tuile d'une session de connexion active (page Sécurité).
///
/// Affiche : icône de l'appareil, label de l'appareil, sous-ligne "ville ·
/// dernier accès" et badge "Cet appareil" sur la session courante.
/// Le bouton de droite, "Déconnecter", est masqué si [estCetAppareil] est
/// vrai (impossible de se déconnecter de soi-même via ce contrôle).
class TuileSessionActive extends StatelessWidget {
  /// Construit une ligne de session.
  const TuileSessionActive({
    super.key,
    required this.icone,
    required this.appareil,
    required this.localisation,
    required this.dernierAcces,
    required this.estCetAppareil,
    required this.onDeconnecter,
  });

  /// Icône représentant le type d'appareil (phone, tablet, laptop, etc.).
  final IconData icone;

  /// Label "iPhone 13" / "Pixel 7" / "Chrome — MacBook".
  final String appareil;

  /// Ville ou région détectée.
  final String localisation;

  /// Dernier accès formaté "il y a X heures" ou date courte.
  final String dernierAcces;

  /// Vrai si c'est l'appareil courant — affiche un badge et masque le
  /// bouton "Déconnecter".
  final bool estCetAppareil;

  /// Callback de déconnexion de la session (uniquement pour les autres).
  final VoidCallback onDeconnecter;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              icone,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          AppDimens.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        appareil,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (estCetAppareil) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Cet appareil',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$localisation · $dernierAcces',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!estCetAppareil) ...[
            const SizedBox(width: 6),
            TextButton(
              onPressed: onDeconnecter,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text(
                'Déconnecter',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
