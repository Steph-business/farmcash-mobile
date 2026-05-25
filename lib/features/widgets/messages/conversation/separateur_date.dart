import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kIncomingBubble = Color(0xFFF3F4F6);

/// Séparateur de date inséré entre deux messages d'un jour différent.
///
/// Le libellé varie selon la proximité par rapport à aujourd'hui :
///   • même jour → "Aujourd'hui"
///   • veille → "Hier"
///   • moins d'une semaine → nom du jour ("lundi", "mardi"…)
///   • plus ancien → date complète ("12 mai 2026")
class SeparateurDate extends StatelessWidget {
  const SeparateurDate({required this.when, super.key});

  final DateTime? when;

  @override
  Widget build(BuildContext context) {
    if (when == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final whenLocal = when!.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final whenDay = DateTime(whenLocal.year, whenLocal.month, whenLocal.day);
    final diff = today.difference(whenDay).inDays;
    final String label;
    if (diff == 0) {
      label = "Aujourd'hui";
    } else if (diff == 1) {
      label = 'Hier';
    } else if (diff < 7) {
      label = DateFormat('EEEE', 'fr_FR').format(whenLocal);
    } else {
      label = DateFormat('d MMMM y', 'fr_FR').format(whenLocal);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _kIncomingBubble,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
