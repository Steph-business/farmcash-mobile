import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/cooperative.dart';
import '../../../../models/publication_coop.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import 'accueil_constants.dart';
import 'coop_banner.dart';
import 'coop_publication_row.dart';
import 'section_head.dart';

/// Section "Ma coopérative" de l'accueil producteur (affichée uniquement
/// si le farmer est membre d'une coop) : bandeau coop + lignes de
/// publications récentes empilées dans une seule card.
class SectionCoop extends StatelessWidget {
  const SectionCoop({
    super.key,
    required this.coop,
    required this.publications,
  });

  final Cooperative coop;
  final List<PublicationCoop> publications;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHead(
          titre: 'Ma coopérative',
          lienTexte: 'Voir tout',
          onLien: () =>
              context.push(RouteNames.producteurCooperativePath),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: kAccueilBrCard,
            border:
                Border.all(color: AppColors.border, width: AppDimens.borderThin),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              CoopBanner(coop: coop),
              for (final p in publications) CoopPublicationRow(publication: p),
            ],
          ),
        ),
      ],
    );
  }
}
