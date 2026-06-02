import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

const Color _kPastelVert = Color(0xFFE8F5E9);

/// Tuile d'action rapide affichée dans la grille accueil — icône
/// thématique + label sur 2 lignes max, callback au tap. Réutilisée
/// sur les 4 rôles (acheteur / producteur / coop / transporteur).
class ActionRapide {
  const ActionRapide({
    required this.icone,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;

  /// Pastille rouge optionnelle posée sur l'icône (ex: nombre de
  /// propositions reçues non vues). `0` → pas de badge.
  final int badge;
}

/// Grille 2×3 (par défaut) d'actions rapides sur l'accueil de tous les
/// rôles. Chaque tuile = carré arrondi avec icône pastel verte + label
/// sous l'icône. Pattern inspiré des maquettes FarmCash AI — donne au
/// user low-tech 6 portes d'entrée évidentes vers les pages clés de
/// son rôle.
class GrilleActions extends StatelessWidget {
  const GrilleActions({
    required this.actions,
    super.key,
  });

  /// Liste d'actions (6 attendues pour un grid 2×3 propre).
  final List<ActionRapide> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, i) => _Tuile(action: actions[i]),
    );
  }
}

class _Tuile extends StatelessWidget {
  const _Tuile({required this.action});
  final ActionRapide action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _kPastelVert,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      action.icone,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  if (action.badge > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: AppColors.background,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          action.badge > 99 ? '99+' : '${action.badge}',
                          style: const TextStyle(
                            color: AppColors.onError,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
