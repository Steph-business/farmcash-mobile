import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/producteur/cooperative/bouton_membres_coop.dart';
import '../../../widgets/producteur/cooperative/cooperative_modeles.dart';
import '../../../widgets/producteur/cooperative/header_cooperative.dart';
import '../../../widgets/producteur/cooperative/hero_carte_cooperative.dart';
import '../../../widgets/producteur/cooperative/liste_publications_coop.dart';
import '../../../widgets/producteur/cooperative/liste_sollicitations_coop.dart';
import '../../../widgets/producteur/cooperative/stats_cooperative.dart';
import '../../../widgets/producteur/cooperative/titre_section_cooperative.dart';

/// Aperçu de la coopérative du producteur — vue côté membre.
///
/// Affiche le logo + nom + stats + publications en cours + sollicitations.
/// Tap sur une publication → détail. Tap "Voir tous les membres" →
/// snackbar (route dédiée non encore prête côté API publique).
class CooperativePage extends ConsumerWidget {
  const CooperativePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    // Fallback "COOP-AGRI Lagunes" si l'utilisateur n'a pas de coop ou
    // qu'on n'a pas de nom : pas de blocage UX.
    final coopNom = user?.cooperativeId != null
        ? 'COOP-AGRI Lagunes'
        : 'COOP-AGRI Lagunes';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderCooperative(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: [
                  HeroCarteCooperative(nom: coopNom),
                  AppDimens.vGap16,
                  const StatsCooperative(
                    membres: '48',
                    publications: '3',
                    sollicitations: '2',
                  ),
                  AppDimens.vGap24,
                  const TitreSectionCooperative('Publications en cours'),
                  AppDimens.vGap12,
                  ListePublicationsCoop(
                    items: kPubsMockCoop,
                    onTap: (p) => context.push(
                      RouteNames.producteurPublicationCoopDetailPathFor(p.id),
                    ),
                  ),
                  AppDimens.vGap24,
                  const TitreSectionCooperative('Sollicitations'),
                  AppDimens.vGap12,
                  ListeSollicitationsCoop(
                    items: kSollicitationsMockCoop,
                    onTap: (_) =>
                        context.push(RouteNames.producteurSollicitationsPath),
                  ),
                  AppDimens.vGap24,
                  BoutonMembresCoop(
                    onTap: () => Snackbars.showInfo(
                      context,
                      'Liste des membres — à venir',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
