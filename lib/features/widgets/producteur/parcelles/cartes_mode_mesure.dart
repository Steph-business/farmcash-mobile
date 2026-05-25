import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Paire de cartes radio pour choisir le mode de mesure de la
/// superficie : saisie manuelle en hectares OU marche autour
/// (GPS multi-points).
///
/// [modeMarche] = false → saisie ; true → marche.
class CartesModeMesure extends StatelessWidget {
  const CartesModeMesure({
    required this.modeMarche,
    required this.onSelect,
    super.key,
  });

  final bool modeMarche;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CarteMode(
            icon: Icons.edit_outlined,
            title: 'Je saisis',
            subtitle: 'En hectares',
            selected: !modeMarche,
            onTap: () => onSelect(false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CarteMode(
            icon: Icons.directions_walk,
            title: 'Je marche autour',
            subtitle: 'GPS auto',
            selected: modeMarche,
            onTap: () => onSelect(true),
          ),
        ),
      ],
    );
  }
}

/// Carte unitaire utilisée dans [CartesModeMesure] : icône + titre +
/// sous-titre, état sélectionné/non sélectionné avec bordure et fond
/// adaptés.
class CarteMode extends StatelessWidget {
  const CarteMode({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F5E9) : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : AppDimens.borderThin,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
