import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'commandes_list_constants.dart';

/// Petit chip coloré pour le statut visible dans une carte commande
/// (vert = OK, warn = attention).
class ChipStatutCommande extends StatelessWidget {
  const ChipStatutCommande({
    super.key,
    required this.label,
    required this.kind,
  });

  final String label;
  final ChipKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      ChipKind.warn => (kWarnSoft, kWarn),
      ChipKind.green => (kPrimarySoft, AppColors.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }
}
