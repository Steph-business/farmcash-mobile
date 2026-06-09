import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_dimens.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/negociation.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/alertes_prix_section.dart';
import '../../communs/carte_solde_hero.dart';
import '../../communs/grille_actions.dart';
import '../../communs/snackbars.dart';
import '../demandes/carte_demande_achat.dart';
import '../demandes/demande_achat_modeles.dart';
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

  /// Actions rapides côté producteur (grille 2×3 dynamique). « Offres
  /// d'achat » a été déplacée en SECTION INLINE plus bas (cartes des
  /// vraies annonces d'achat des acheteurs), pour permettre au farmer
  /// de candidater en 1 tap sans passer par un écran intermédiaire.
  /// On remplit la 6e case par « Sollicitations coop » qui complète
  /// le hub de demandes entrantes.
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
        // Sollicitations coop — l'autre voie d'entrée des demandes
        // (groupage d'achat coopérative). Visuellement parallèle à la
        // section « Offres des acheteurs » plus bas.
        ActionRapide(
          icone: Icons.notifications_active_outlined,
          label: 'Sollicitations',
          onTap: () =>
              context.push(RouteNames.producteurSollicitationsPath),
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
        AppDimens.vGap24,
        // D. Offres REÇUES (urgent — TOI tu dois répondre) — remontée
        //    en priorité 2026-06-05 pour s'aligner sur la logique
        //    « ce que tu DOIS faire avant ce que tu PEUX faire ».
        //    Symétrique du bandeau « offres à traiter » sur l'accueil
        //    acheteur — pattern cross-acteur cohérent.
        if (_offresActionnables(data.offresIncoming).isNotEmpty)
          _SectionOffresRecues(
            offres: _offresActionnables(data.offresIncoming).take(3).toList(),
            onVoirTout: () =>
                context.push(RouteNames.producteurOffresRecuesPath),
          ),
        if (_offresActionnables(data.offresIncoming).isNotEmpty)
          AppDimens.vGap24,
        // E. Offres des acheteurs — annonces d'achat publiques, listées
        //    directement sur l'accueil pour candidater en 1 tap (avant,
        //    c'était une tuile qui forçait un écran intermédiaire).
        //    Vient APRÈS les offres reçues : ce sont des opportunités,
        //    pas des actions urgentes.
        if (data.acheteursQuiCherchent.isNotEmpty)
          _SectionOffresAcheteurs(
            demandes: data.acheteursQuiCherchent.take(3).toList(),
            onVoirTout: () =>
                context.push(RouteNames.producteurDemandesAchatPath),
          ),
        if (data.acheteursQuiCherchent.isNotEmpty) AppDimens.vGap24,
        // E. Alertes prix
        AlertesPrixSection(
          alertes: alertesPrix,
          onVoirTout: () => _showSoon(context, 'Alertes prix — à venir'),
        ),
        AppDimens.vGap24,
        // F. Conseil du jour (depuis l'IA insights, masqué si absent)
        if (data.insights != null && data.insights!.tendances.isNotEmpty)
          SectionConseils(tendance: data.insights!.tendances.first),
        if (data.isEmpty) const EtatVide(),
      ],
    );
  }
}

// ─── Helpers privés ──────────────────────────────────────────────

/// Filtre les candidatures REÇUES qui méritent encore une action du
/// producteur (PENDING ou COUNTER_OFFERED). Les ACCEPTED/REJECTED sont
/// masquées — il n'y a plus rien à faire dessus.
List<Candidature> _offresActionnables(List<Candidature> all) {
  return all
      .where((c) =>
          c.status == NegotiationStatus.pending ||
          c.status == NegotiationStatus.counterOffered)
      .toList();
}

final NumberFormat _nfFr = NumberFormat('#,##0', 'fr_FR');

String? _formatRelatif(DateTime? d) {
  if (d == null) return null;
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'à l’instant';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
  final semaines = (diff.inDays / 7).floor();
  if (semaines < 5) return 'il y a $semaines sem';
  return 'il y a ${(diff.inDays / 30).floor()} mois';
}

// ─── Section : Offres des acheteurs (inline accueil) ──────────────

/// Affiche en colonne les 3 dernières annonces d'achat publiques —
/// le producteur peut candidater en 1 tap (la carte navigue déjà vers
/// `producteurDemandeAchatRepondrePath`). En-tête avec lien « Voir tout »
/// vers la liste complète.
class _SectionOffresAcheteurs extends StatelessWidget {
  const _SectionOffresAcheteurs({
    required this.demandes,
    required this.onVoirTout,
  });

  /// Annonces d'achat brutes — on les convertit en `MockDemande`
  /// (format attendu par `CarteDemandeAchat`).
  final List<dynamic> demandes;
  final VoidCallback onVoirTout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header section : titre gros + sous-titre + lien « Voir tout »
        // sur la droite. Pattern repris de la maquette client.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offres des acheteurs',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explorez les offres exclusives pour vos récoltes.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: onVoirTout,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                child: Text(
                  'VOIR\nTOUT',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Trait de séparation discret (vert très pâle).
        Container(
          height: 1,
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < demandes.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          CarteDemandeAchat(demande: annonceAchatToMock(demandes[i])),
        ],
      ],
    );
  }
}

// ─── Section : Offres reçues sur mes annonces ─────────────────────

/// Liste compacte des candidatures d'acheteurs en attente d'action
/// (PENDING / COUNTER_OFFERED) sur les annonces de vente du producteur.
/// Tap → page complète « Offres reçues » pour gérer (accepter / refuser
/// / contre-offre). Avant ce widget, cette page n'avait aucun point
/// d'entrée depuis l'accueil — elle existait sans être joignable.
class _SectionOffresRecues extends StatelessWidget {
  const _SectionOffresRecues({
    required this.offres,
    required this.onVoirTout,
  });

  final List<Candidature> offres;
  final VoidCallback onVoirTout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Offres reçues sur tes annonces',
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            InkWell(
              onTap: onVoirTout,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                child: Text(
                  'Voir tout',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Accepte, refuse ou contre-propose en 1 tap.',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < offres.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _CarteOffreRecue(
            candidature: offres[i],
            onTap: onVoirTout,
          ),
        ],
      ],
    );
  }
}

/// Carte compacte d'une candidature reçue. Le producteur voit l'essentiel
/// (quantité, prix proposé, fraîcheur, statut) sans qu'on charge encore
/// la jointure buyer/annonce — le tap mène à la page détaillée.
class _CarteOffreRecue extends StatelessWidget {
  const _CarteOffreRecue({required this.candidature, required this.onTap});
  final Candidature candidature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = candidature;
    final qte = _nfFr.format(c.quantiteKg.round());
    final prix = _nfFr.format(c.prixProposeKg.round());
    final relatif = _formatRelatif(c.createdAt) ?? '';
    final isCounter = c.status == NegotiationStatus.counterOffered;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Pastille statut : ambre = à traiter, primary = contre-offre
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isCounter
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : const Color(0xFFB45309).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isCounter
                      ? Icons.swap_horiz_rounded
                      : Icons.mark_email_unread_outlined,
                  size: 18,
                  color: isCounter
                      ? AppColors.primary
                      : const Color(0xFFB45309),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$qte kg · $prix F/kg',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCounter
                          ? 'Contre-offre reçue · $relatif'
                          : 'Nouvelle offre · $relatif',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
