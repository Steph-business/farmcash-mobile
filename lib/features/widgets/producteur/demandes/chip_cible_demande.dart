import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'demande_achat_modeles.dart';

/// Chip "Via ma coop" / "Public" affiché en haut à droite d'une carte
/// demande d'achat.
class ChipCibleDemande extends StatelessWidget {
  const ChipCibleDemande({super.key, required this.viaCoop});

  final bool viaCoop;

  @override
  Widget build(BuildContext context) {
    final bg = viaCoop ? kCoopOrangeBg : kPrimarySoftDemande;
    final fg = viaCoop ? kCoopOrangeFg : AppColors.primary;
    final label = viaCoop ? 'Via ma coop' : 'Public';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
