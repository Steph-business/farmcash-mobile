import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB45309);

/// Pastille colorée affichant le statut d'une commande (Envoyée, Acceptée,
/// En cours, Livrée, Litige, etc.). Couleurs adaptées au statut.
class ChipStatutCommande extends StatelessWidget {
  const ChipStatutCommande({required this.status, super.key});

  /// Statut métier de la commande à afficher.
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _spec(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }

  (Color, Color, String) _spec(OrderStatus s) {
    switch (s) {
      case OrderStatus.sent:
        return (_kWarnSoft, _kWarn, 'Envoyée');
      case OrderStatus.accepted:
        return (_kPrimarySoft, AppColors.primary, 'Acceptée');
      case OrderStatus.rejected:
        return (const Color(0xFFFEE2E2), AppColors.error, 'Refusée');
      case OrderStatus.inProgress:
        return (_kPrimarySoft, AppColors.primary, 'En cours');
      case OrderStatus.delivered:
        return (_kPrimarySoft, AppColors.primary, 'Livrée');
      case OrderStatus.completed:
        return (_kPrimarySoft, AppColors.primary, 'Clôturée');
      case OrderStatus.disputed:
        return (_kWarnSoft, _kWarn, 'Litige');
      case OrderStatus.cancelled:
        return (
          const Color(0xFFE5E7EB),
          AppColors.textSecondary,
          'Annulée',
        );
      case OrderStatus.unknown:
        return (
          const Color(0xFFE5E7EB),
          AppColors.textSecondary,
          '—',
        );
    }
  }
}
