import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import 'puce_publier.dart';

/// Ligne de puces de quantités rapides (10, 25, 50, 100 kg) à l'étape 2.
///
/// Notifie le parent via [onPick] avec la quantité choisie en kg.
class ChipsKgRapides extends StatelessWidget {
  const ChipsKgRapides({super.key, required this.onPick});

  final ValueChanged<int> onPick;

  static const _kg = [10, 25, 50, 100];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space8,
      children: [
        for (final kg in _kg)
          PucePublier(
            label: '$kg kg',
            selected: false,
            enabled: true,
            onTap: () => onPick(kg),
          ),
      ],
    );
  }
}
