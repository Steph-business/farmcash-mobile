import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_dimens.dart';
import '../../communs/alertes_prix_section.dart';
import '../../communs/carte_solde_hero.dart';
import '../../communs/entete_bonjour.dart';
import '../../communs/grille_actions.dart';
import '../../communs/snackbars.dart';
import 'accueil_producteur_data.dart';
import 'etat_vide.dart';
import 'section_conseils.dart';

/// Composition principale de l'accueil producteur, sous le `HeaderUtilisateur`.
///
/// Layout volontairement épuré pour un farmer low-tech :
///   - **A** Bonjour + prénom
///   - **B** Solde wallet (CTA « Mon wallet »)
///   - **C** Grille 2×3 d'actions rapides (toutes les pages clés)
///   - **D** Alertes prix
///   - **E** Conseil du jour (depuis l'IA insights)
///
/// Toutes les sections riches (KPI, à traiter, acheteurs qui cherchent,
/// coop, IA, mes annonces) ont été retirées : elles font doublon avec
/// les tuiles de la grille qui pointent vers les pages dédiées. L'accueil
/// reste ainsi un **hub clair**, pas un mur d'informations.
class ContenuAccueil extends StatelessWidget {
  const ContenuAccueil({
    super.key,
    required this.data,
    required this.parcellesCount,
    required this.prenom,
  });

  final AccueilProducteurData data;

  /// Compteur de parcelles — gardé en paramètre par compatibilité avec
  /// le provider parent. Plus affiché ici (le bandeau « 0 parcelle » a
  /// été retiré sur instruction utilisateur).
  final AsyncValue<int> parcellesCount;

  /// Prénom du producteur (premier mot de `fullName`) affiché dans le
  /// hero « Bonjour, [prenom] 👋 » en haut de l'accueil.
  final String prenom;

  /// Snackbar d'attente pour les actions sans page dédiée.
  ///
  /// Délègue au helper unifié — design pro (fond sombre + icône colorée),
  /// cohérent avec le reste de l'app (Uber/Jumia style).
  void _showSoon(BuildContext context, String message) {
    Snackbars.showInfo(context, message);
  }

  /// Liste des 6 actions rapides côté producteur (grid 2×3). Ordre pensé
  /// pour un farmer low-tech : ses outils métier (parcelles, annonces,
  /// commandes) puis IA, coop, et **offres d'achat** (les demandes des
  /// acheteurs auxquelles le producteur peut répondre).
  List<ActionRapide> _actions(BuildContext context) => [
        ActionRapide(
          icone: Icons.eco_outlined,
          label: 'Mes parcelles',
          onTap: () =>
              context.push(RouteNames.producteurMesParcellesPath),
        ),
        ActionRapide(
          icone: Icons.campaign_outlined,
          label: 'Mes annonces',
          onTap: () =>
              context.push(RouteNames.producteurMesPublicationsPath),
        ),
        ActionRapide(
          icone: Icons.receipt_long_outlined,
          label: 'Commandes',
          // Onglet shell → context.go pour que le bottom nav active la
          // bonne branche (sinon "Accueil" reste highlight).
          onTap: () => context.go(RouteNames.producteurCommandesPath),
        ),
        ActionRapide(
          icone: Icons.smart_toy_outlined,
          label: 'Diagnostic plante',
          onTap: () =>
              context.push(RouteNames.producteurAiAnalysePlantePath),
        ),
        ActionRapide(
          icone: Icons.account_balance_outlined,
          label: 'Coopérative',
          onTap: () => context.push(RouteNames.producteurCooperativePath),
        ),
        // Tuile « Offres d'achat » : pointe vers les demandes d'achat
        // publiées par les acheteurs. Le producteur peut y répondre via
        // `demande_achat_repondre_page` (négociation). Remplace l'ancien
        // « Plus » qui ne servait à rien (le profil est déjà accessible
        // via l'avatar dans le HeaderUtilisateur).
        ActionRapide(
          icone: Icons.shopping_basket_outlined,
          label: 'Offres d\'achat',
          onTap: () =>
              context.push(RouteNames.producteurDemandesAchatPath),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    // Alertes prix mockées (cacao −5 %, anacarde −3 %) en attendant un
    // endpoint dédié IA. Réutilise le même `AlertesPrixSection` que
    // l'accueil acheteur.
    const alertesPrix = [
      AlertePrix(produit: 'Cacao', variationPct: -5),
      AlertePrix(produit: 'Anacarde', variationPct: -3),
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        // A. Hero personnalisé « Bonjour, [Prénom] 👋 »
        EnteteBonjour(prenom: prenom),
        AppDimens.vGap16,
        // B. Carte solde wallet — CTA « Mon wallet », label « Mes gains »
        CarteSoldeHero(
          solde: data.wallet?.balance,
          onOuvrirWallet: () =>
              context.push(RouteNames.producteurWalletPath),
          titre: 'Mes gains',
          labelBouton: 'Mon wallet',
        ),
        AppDimens.vGap16,
        // C. Grille 2×3 d'actions rapides
        GrilleActions(actions: _actions(context)),
        AppDimens.vGap16,
        // D. Alertes prix
        AlertesPrixSection(
          alertes: alertesPrix,
          onVoirTout: () => _showSoon(context, 'Alertes prix — à venir'),
        ),
        AppDimens.vGap24,
        // E. Conseil du jour (depuis l'IA insights, masqué si absent)
        if (data.insights != null && data.insights!.tendances.isNotEmpty)
          SectionConseils(tendance: data.insights!.tendances.first),
        if (data.isEmpty) const EtatVide(),
      ],
    );
  }
}
