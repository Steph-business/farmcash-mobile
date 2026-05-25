import 'package:flutter/material.dart';

import '../../../../models/prevision.dart';
import '../../../../theme/app_text_styles.dart';
import 'prevision_detail_constants.dart';

/// Petite chip jaune affichant le compte à rebours avant la date prévue de
/// récolte ("Prévision · J-7", "Aujourd'hui", "échue"). Si la prévision n'a
/// pas de date, affiche simplement "Prévision".
class ChipPrevision extends StatelessWidget {
  const ChipPrevision({required this.prevision, super.key});

  final Prevision prevision;

  @override
  Widget build(BuildContext context) {
    final date = prevision.dateRecoltePrev;
    String label = 'Prévision';
    if (date != null) {
      final diff = date.difference(DateTime.now()).inDays;
      if (diff > 0) {
        label = 'Prévision · J-$diff';
      } else if (diff == 0) {
        label = 'Prévision · Aujourd\'hui';
      } else {
        label = 'Prévision · échue';
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: kPrevisionDetailWarnSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: kPrevisionDetailWarn,
        ),
      ),
    );
  }
}
