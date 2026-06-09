import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/carte_solde_hero.dart';
import '../../communs/grille_actions.dart';
import '../../communs/snackbars.dart';
import '_constantes_accueil_transporteur.dart';
import 'bandeau_pas_de_route.dart';
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
        // 0a-bis. Alerte si aucun itinéraire actif déclaré. Sans route,
        //         le backend ne push aucune mission au transporteur
        //         (catch-22). On force la visibilité du problème + CTA.
        if (itinerairesActifs.isEmpty) ...[
          const BandeauPasDeRoute(),
          AppDimens.vGap16,
        ],
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
        //    Tap → bottom sheet teaser premium « Bientôt disponible »
        //    avec explication + CTA « Me prévenir au lancement »
        //    (vs ancien snackbar « à venir » qui était décevant).
        SectionOutilsIa(
          onAssistant: () => _afficherTeaserOutilIa(
            context,
            titre: 'Assistant route IA',
            description:
                'Optimise tes trajets, propose les meilleurs créneaux '
                'et trouve les chargements complémentaires sur ta route.',
            icone: Icons.route_rounded,
          ),
          onOptimisation: () => _afficherTeaserOutilIa(
            context,
            titre: 'Optimisation IA',
            description:
                'Maximise tes revenus : combiner missions, éviter les '
                'retours à vide, suggérer les meilleures zones par jour.',
            icone: Icons.auto_awesome_rounded,
          ),
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
          // Onglet shell → go pour activer la branche bottom nav.
          onTap: () => context.go(RouteNames.transporteurMissionsPath),
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

  /// SnackBar discrète "à venir" — gardée pour usages divers.
  // ignore: unused_element
  void _snack(BuildContext context, String message) {
    Snackbars.showInfo(context, message);
  }
}

/// Bottom sheet teaser premium pour une fonctionnalité IA pas encore
/// dispo. Bien plus engageant qu'un snackbar « à venir » : explique
/// ce que ça apportera, capte de l'intérêt utilisateur (CTA « Me
/// prévenir »). Pattern Stripe/Linear.
void _afficherTeaserOutilIa(
  BuildContext context, {
  required String titre,
  required String description,
  required IconData icone,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle grip
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Hero icône
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryHover],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(icone, size: 34, color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Badge "Bientôt"
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Bientôt disponible',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              titre,
              style: AppTextStyles.titleLarge.copyWith(
                fontFamily: 'Poppins',
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: AppDimens.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Snackbars.showSucces(
                    context,
                    'Promis, on te prévient dès que c\'est dispo 🚀',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimens.brButton,
                  ),
                ),
                child: Text(
                  'Me prévenir au lancement',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Plus tard',
                style: AppTextStyles.button.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
