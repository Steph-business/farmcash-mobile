import 'package:flutter/material.dart';

import 'sollicitation_quand.dart';
import 'sollicitation_when_card.dart';

/// Ligne de deux cards pour choisir "Maintenant" ou "Plus tard".
///
/// Encapsule les deux `SollicitationWhenCard` côte à côte ; expose un
/// callback simple `onChange(SollicitationQuand)` au caller.
class SollicitationWhenRow extends StatelessWidget {
  const SollicitationWhenRow({
    required this.selected,
    required this.onChange,
    super.key,
  });

  final SollicitationQuand selected;
  final ValueChanged<SollicitationQuand> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SollicitationWhenCard(
            emoji: '✅',
            title: 'Maintenant',
            subtitle: 'Stocks dispo',
            active: selected == SollicitationQuand.maintenant,
            onTap: () => onChange(SollicitationQuand.maintenant),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SollicitationWhenCard(
            emoji: '⏳',
            title: 'Plus tard',
            subtitle: 'Date à venir',
            active: selected == SollicitationQuand.plusTard,
            onTap: () => onChange(SollicitationQuand.plusTard),
          ),
        ),
      ],
    );
  }
}
