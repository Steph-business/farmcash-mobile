import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Petit badge affichant le score de fiabilité d'un vendeur (0-100 %).
/// Couleur conditionnelle :
///   - >= 80 vert  — vendeur fiable, recommandé
///   - 50-79 orange — correct, à surveiller
///   - < 50 rouge — fragile, vendeur peu fiable
///
/// Si le score est null (jointure backend absente), rien n'est affiché —
/// on évite d'afficher "—%" qui parasiterait visuellement.
class BadgeFiabilite extends StatelessWidget {
  const BadgeFiabilite({super.key, required this.score});

  final int? score;

  @override
  Widget build(BuildContext context) {
    if (score == null) return const SizedBox.shrink();
    final s = score!;
    final (bg, fg, label) = s >= 80
        ? (const Color(0xFFE8F5E9), AppColors.primary, 'Fiable')
        : s >= 50
            ? (const Color(0xFFFFF8E1), const Color(0xFFB26A00), 'Moyen')
            : (const Color(0xFFFDECEA), AppColors.error, 'Faible');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 11, color: fg),
          const SizedBox(width: 3),
          Text(
            '$s% · $label',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
