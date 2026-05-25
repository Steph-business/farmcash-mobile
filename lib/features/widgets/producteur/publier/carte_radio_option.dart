import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'point_radio.dart';

/// Ligne d'option d'une [CarteRadio] : emoji rond + titre + sous-titre
/// optionnel + [PointRadio] de sélection.
///
/// [onTap] est nullable pour pouvoir afficher une option visible mais
/// non cliquable (ex. audience coop si l'utilisateur n'est pas membre
/// d'une coopérative).
class CarteRadioOption extends StatelessWidget {
  const CarteRadioOption({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final bool selected;
  final bool enabled;
  // Nullable pour permettre aux call-sites de marquer un item comme
  // « affiché mais non cliquable » (ex: option coop visible mais inactive
  // si l'utilisateur n'est pas membre d'une coopérative).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            PointRadio(selected: selected),
          ],
        ),
      ),
    );
  }
}
