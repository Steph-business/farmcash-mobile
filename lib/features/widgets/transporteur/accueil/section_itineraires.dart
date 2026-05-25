import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/livraison.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '_constantes_accueil_transporteur.dart';
import 'section_head_transporteur.dart';

/// Section "Mes itinéraires actifs" — carousel horizontal de [CarteItineraire]
/// avec lien "Voir tout" vers la liste complète des itinéraires déclarés.
class SectionItineraires extends StatelessWidget {
  const SectionItineraires({super.key, required this.routes});

  final List<TransporterRoute> routes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeadTransporteur(
          titre: 'Mes itinéraires actifs',
          lienTexte: 'Voir tout',
          onLienTap: () =>
              context.push(RouteNames.transporteurItinerairesPath),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: routes.length,
            separatorBuilder: (_, __) => AppDimens.hGap12,
            itemBuilder: (context, i) =>
                CarteItineraire(route: routes[i], index: i),
          ),
        ),
      ],
    );
  }
}

/// Carte horizontale d'un itinéraire déclaré — icône, trajet, capacité,
/// tarif, et badge "Actif" si la route est en cours.
class CarteItineraire extends StatelessWidget {
  const CarteItineraire({
    super.key,
    required this.route,
    required this.index,
  });

  final TransporterRoute route;
  final int index;

  @override
  Widget build(BuildContext context) {
    final trajet = formatTrajetItineraire(route, index);
    final capacite =
        NumberFormat('#,##0', 'fr_FR').format(route.capaciteMaxKg);
    final prix = NumberFormat('#,##0', 'fr_FR').format(route.tarifKg);

    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: kBrCardTransporteur,
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimarySoftTransporteur,
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.alt_route,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trajet,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$capacite kg · $prix F/km',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (route.isActive) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimarySoftTransporteur,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Actif',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
