import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Pastille colorée affichant le rôle d'un membre dans la coopérative.
class PastilleRoleMembre extends StatelessWidget {
  const PastilleRoleMembre({super.key, required this.role});

  /// Libellé brut du rôle.
  final String role;

  @override
  Widget build(BuildContext context) {
    final label = role.toLowerCase() == 'membre' ? 'Membre' : role;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
