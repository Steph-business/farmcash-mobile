import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/negociation.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import 'accueil_constants.dart';
import 'accueil_helpers.dart';
import 'action_row.dart';
import 'section_head.dart';

/// Section "À traiter" de l'accueil producteur : liste compacte (max 3)
/// des candidatures incoming reçues sur ses annonces. Tappable pour
/// ouvrir la liste complète des offres reçues.
class SectionATraiter extends StatelessWidget {
  const SectionATraiter({super.key, required this.offres});

  final List<Candidature> offres;

  @override
  Widget build(BuildContext context) {
    final items = offres.take(3).map((c) {
      final qte = NumberFormat('#,##0', 'fr_FR').format(c.quantiteKg);
      return ActionItem(
        icon: Icons.shopping_cart_outlined,
        type: ActionType.positive,
        titre: 'Offre reçue · $qte kg',
        sousTitre: ageRelatif(c.createdAt),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHead(
          titre: 'À traiter',
          lienTexte: 'Voir tout',
          onLien: () =>
              context.push(RouteNames.producteurOffresRecuesPath),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: kAccueilBrCard,
            border:
                Border.all(color: AppColors.border, width: AppDimens.borderThin),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              return ActionRow(
                item: items[i],
                isLast: i == items.length - 1,
                onTap: () =>
                    context.push(RouteNames.producteurOffresRecuesPath),
              );
            }),
          ),
        ),
      ],
    );
  }
}
