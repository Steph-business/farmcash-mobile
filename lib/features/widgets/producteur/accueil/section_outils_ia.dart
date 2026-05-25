import 'package:flutter/material.dart';

import '../../../../theme/app_dimens.dart';
import 'outil_tile.dart';
import 'section_head.dart';

/// Section "Outils IA" de l'accueil producteur : grid 2×2 de raccourcis
/// vers Diagnostiquer une plante, Assistant agronomique, Actualités,
/// Catalogue traitements.
class SectionOutilsIA extends StatelessWidget {
  const SectionOutilsIA({
    super.key,
    required this.onAnalyse,
    required this.onAssistant,
    required this.onActualites,
    required this.onTraitements,
  });

  final VoidCallback onAnalyse;
  final VoidCallback onAssistant;
  final VoidCallback onActualites;
  final VoidCallback onTraitements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHead(titre: 'Outils IA'),
        Row(
          children: [
            Expanded(
              child: OutilTile(
                icon: Icons.eco_outlined,
                titre: 'Diagnostiquer une plante',
                onTap: onAnalyse,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: OutilTile(
                icon: Icons.chat_bubble_outline,
                titre: 'Assistant agronomique',
                onTap: onAssistant,
              ),
            ),
          ],
        ),
        AppDimens.vGap12,
        Row(
          children: [
            Expanded(
              child: OutilTile(
                icon: Icons.newspaper_outlined,
                titre: 'Actualités',
                onTap: onActualites,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: OutilTile(
                icon: Icons.science_outlined,
                titre: 'Traitements',
                onTap: onTraitements,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
