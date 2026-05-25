import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_dimens.dart';
import '../../communs/carte_solde_hero.dart';
import '../../communs/entete_bonjour.dart';
import '../../communs/grille_actions.dart';
import '_constantes_accueil_transporteur.dart';
import 'carte_mission_active.dart';
import 'cta_declarer_itineraire.dart';
import 'etat_vide_accueil.dart';
import 'kpi_row_transporteur.dart';
import 'section_itineraires.dart';
import 'section_missions.dart';
import 'section_outils_ia.dart';

/// Liste scrollable orchestrant toutes les sections de l'accueil
/// transporteur : entête personnalisé, carte solde hero, grille actions
/// rapides, mission active, CTA itinéraire, KPI, missions disponibles,
/// itinéraires actifs, prochains chargements, outils IA et état vide.
///
/// Les sections vides sont masquées silencieusement (graceful degradation).
class ContenuAccueilTransporteur extends StatelessWidget {
  const ContenuAccueilTransporteur({
    super.key,
    required this.data,
    required this.rating,
    required this.prenom,
  });

  final AccueilTransporteurData data;
  final double rating;

  /// Prénom du transporteur connecté pour l'entête « Bonjour, … ».
  final String prenom;

  @override
  Widget build(BuildContext context) {
    final mActive = data.missionActive;
    final disponibles = data.missionsDisponibles;
    final prochains = data.prochainsChargements;
    final itinerairesActifs =
        data.routes.where((r) => r.isActive).take(5).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        // 0a. Entête personnalisé « Bonjour, [Prénom] 👋 »
        EnteteBonjour(
          prenom: prenom,
          question: 'Quelles courses aujourd\'hui ?',
        ),
        AppDimens.vGap16,
        // 0b. Carte solde wallet — gains du transporteur + CTA wallet
        CarteSoldeHero(
          solde: data.wallet?.balance,
          onOuvrirWallet: () =>
              context.push(RouteNames.transporteurWalletPath),
          titre: 'Mes gains',
          labelBouton: 'Mon wallet',
        ),
        AppDimens.vGap16,
        // 0c. Grille 2×3 d'actions rapides — portes d'entrée transporteur
        GrilleActions(actions: _actions(context)),
        AppDimens.vGap24,
        // 1. Mission active (déjà existant)
        if (mActive != null) ...[
          CarteMissionActive(mission: mActive),
          AppDimens.vGap24,
        ],
        // 2. CTA "Déclarer un itinéraire" — masqué si mission active
        //    (sinon redondant avec le FAB du shell)
        if (mActive == null) ...[
          CtaDeclarerItineraire(
            onTap: () => context.push(RouteNames.transporteurItinerairesPath),
          ),
          AppDimens.vGap24,
        ],
        // 3. KPI
        KpiRowTransporteur(
          gains: data.wallet?.balance ?? 0,
          devise: data.wallet?.currency ?? 'XOF',
          livrees: data.nbLivrees,
          note: rating,
        ),
        AppDimens.vGap24,
        // 4. Missions disponibles (déjà existant)
        if (disponibles.isNotEmpty) ...[
          SectionMissions(
            titre: 'Missions disponibles',
            lienTexte: 'Voir tout',
            onLienTap: () =>
                context.push(RouteNames.transporteurDemandesEntrantesPath),
            missions: disponibles.take(3).toList(),
            avecBoutonAccepter: true,
          ),
          AppDimens.vGap24,
        ],
        // 5. Mes itinéraires actifs (carousel horizontal)
        if (itinerairesActifs.isNotEmpty) ...[
          SectionItineraires(routes: itinerairesActifs),
          AppDimens.vGap24,
        ],
        // 6. Prochains chargements (déjà existant)
        if (prochains.isNotEmpty) ...[
          SectionMissions(
            titre: 'Prochains chargements',
            missions: prochains.take(3).toList(),
            avecBoutonAccepter: false,
          ),
          AppDimens.vGap24,
        ],
        // 7. Outils intelligents (grid 2 cards avec photos)
        SectionOutilsIa(
          onAssistant: () => _snack(context, 'Assistant route — à venir'),
          onOptimisation: () => _snack(context, 'Optimisation — à venir'),
        ),
        AppDimens.vGap24,
        if (data.isEmpty) const EtatVideAccueil(),
      ],
    );
  }

  /// 6 actions rapides transporteur — pattern grille 2×3 commun à tous
  /// les rôles. Routes vérifiées dans `route_names.dart`.
  List<ActionRapide> _actions(BuildContext context) => [
        ActionRapide(
          icone: Icons.assignment_outlined,
          label: 'Missions dispo',
          onTap: () =>
              context.push(RouteNames.transporteurDemandesEntrantesPath),
        ),
        ActionRapide(
          icone: Icons.local_shipping_outlined,
          label: 'Mes missions',
          onTap: () => context.push(RouteNames.transporteurMissionsPath),
        ),
        ActionRapide(
          icone: Icons.map_outlined,
          label: 'Itinéraires',
          onTap: () => context.push(RouteNames.transporteurItinerairesPath),
        ),
        ActionRapide(
          icone: Icons.directions_car_outlined,
          label: 'Mes véhicules',
          onTap: () => context.push(RouteNames.transporteurMesVehiculesPath),
        ),
        ActionRapide(
          icone: Icons.payments_outlined,
          label: 'Paiements',
          onTap: () => context.push(RouteNames.transporteurWalletPath),
        ),
        ActionRapide(
          icone: Icons.more_horiz,
          label: 'Plus',
          onTap: () =>
              context.push(RouteNames.transporteurProfilSettingsPath),
        ),
      ];

  /// SnackBar discrète "à venir".
  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
