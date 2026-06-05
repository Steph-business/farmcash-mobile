import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/cooperative.dart';
import '../../../../models/publication_coop.dart';
import '../../../../models/sollicitation.dart';
import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../../services/providers.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/cooperative/bouton_membres_coop.dart';
import '../../../widgets/producteur/cooperative/cooperative_modeles.dart';
import '../../../widgets/producteur/cooperative/header_cooperative.dart';
import '../../../widgets/producteur/cooperative/hero_carte_cooperative.dart';
import '../../../widgets/producteur/cooperative/liste_publications_coop.dart';
import '../../../widgets/producteur/cooperative/liste_sollicitations_coop.dart';
import '../../../widgets/producteur/cooperative/stats_cooperative.dart';
import '../../../widgets/producteur/cooperative/titre_section_cooperative.dart';

// ─── Modèle bundle + provider ──────────────────────────────────────

/// Données agrégées de la page « Ma coopérative » côté producteur.
/// Chaque sous-fetch est tolérant : un service en échec retourne une
/// valeur neutre (null / liste vide / 0) plutôt que de faire échouer
/// toute la page. L'utilisateur voit ce qui a pu être chargé.
class _CoopBundle {
  final Cooperative? coop;
  final List<PublicationCoop> publications;
  final int nbMembres;
  final List<Sollicitation> sollicitations;
  final int nbSollicitationsOpen;

  const _CoopBundle({
    required this.coop,
    required this.publications,
    required this.nbMembres,
    required this.sollicitations,
    required this.nbSollicitationsOpen,
  });
}

/// Charge en parallèle : coop, publications en cours, total membres,
/// sollicitations ouvertes. `autoDispose` → invalidé quand la page sort
/// du shell, refetché à la prochaine visite (donnée fraîche).
final _coopBundleProvider =
    FutureProvider.autoDispose.family<_CoopBundle, String>((ref, coopId) async {
  final svc = ref.watch(cooperativesServiceProvider);

  final results = await Future.wait<dynamic>([
    svc
        .getPublic(coopId)
        .then<Object?>((v) => v)
        .catchError((_) => null),
    svc
        .listPublications(cooperativeId: coopId, limit: 10)
        .then<Object?>((v) => v)
        .catchError((_) => null),
    // listMembers n'a pas de filtre coopId : le backend retourne les
    // membres de la coop du JWT user. Limit=1 suffit, on lit `total`.
    svc
        .listMembers(limit: 1)
        .then<Object?>((v) => v)
        .catchError((_) => null),
    // Côté producteur : on liste les sollicitations DONT il est
    // destinataire (endpoint FARMER-friendly). L'ancien
    // `listSollicitations` est COOP-only → 403.
    svc
        .listSollicitationsPourMoi(status: 'OPEN', limit: 10)
        .then<Object?>((v) => v)
        .catchError((_) => null),
  ]);

  final coop = results[0] as Cooperative?;
  final pubsPage = results[1];
  final membresPage = results[2];
  final sollicitsPage = results[3];

  return _CoopBundle(
    coop: coop,
    publications: pubsPage is List
        ? <PublicationCoop>[]
        : (pubsPage as dynamic)?.data as List<PublicationCoop>? ?? const [],
    nbMembres: membresPage is List
        ? 0
        : (membresPage as dynamic)?.total as int? ?? 0,
    sollicitations: sollicitsPage is List
        ? <Sollicitation>[]
        : (sollicitsPage as dynamic)?.data as List<Sollicitation>? ?? const [],
    nbSollicitationsOpen: sollicitsPage is List
        ? 0
        : (sollicitsPage as dynamic)?.total as int? ?? 0,
  );
});

// ─── Page ──────────────────────────────────────────────────────────

/// Aperçu de la coopérative du producteur — vue côté membre.
///
/// 100 % branchée backend : nom coop, stats (membres / publications /
/// sollicitations), liste publications en cours et sollicitations
/// ouvertes proviennent toutes des endpoints `/cooperatives/*` et
/// `/cooperatives/sollicitations`.
class CooperativePage extends ConsumerWidget {
  const CooperativePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final coopId = user?.cooperativeId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderCooperative(),
            Expanded(
              child: coopId == null
                  ? const _EtatPasDeCoop()
                  : _ContenuCoop(coopId: coopId),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Contenu (avec data) ───────────────────────────────────────────

class _ContenuCoop extends ConsumerWidget {
  const _ContenuCoop({required this.coopId});
  final String coopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_coopBundleProvider(coopId));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: AppDimens.space32),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger ta coopérative.',
          onRetry: () => ref.invalidate(_coopBundleProvider(coopId)),
        ),
      ),
      data: (bundle) => RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(_coopBundleProvider(coopId)),
        child: _Liste(bundle: bundle),
      ),
    );
  }
}

class _Liste extends StatelessWidget {
  const _Liste({required this.bundle});
  final _CoopBundle bundle;

  @override
  Widget build(BuildContext context) {
    final coopNom = bundle.coop?.nom ?? 'Ma coopérative';
    final pubs = bundle.publications;
    final sollicits = bundle.sollicitations;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space24,
      ),
      children: [
        HeroCarteCooperative(nom: coopNom),
        AppDimens.vGap16,
        StatsCooperative(
          membres: '${bundle.nbMembres}',
          publications: '${pubs.length}',
          sollicitations: '${bundle.nbSollicitationsOpen}',
        ),
        AppDimens.vGap24,

        // Publications réelles (ou état vide).
        const TitreSectionCooperative('Publications en cours'),
        AppDimens.vGap12,
        if (pubs.isEmpty)
          const _EtatVideSection(
            message: 'Aucune publication en cours dans ta coopérative.',
          )
        else
          ListePublicationsCoop(
            items: pubs.map(_pubToMock).toList(growable: false),
            onTap: (p) => context.push(
              RouteNames.producteurPublicationCoopDetailPathFor(p.id),
            ),
          ),
        AppDimens.vGap24,

        // Sollicitations réelles (ou état vide).
        const TitreSectionCooperative('Sollicitations'),
        AppDimens.vGap12,
        if (sollicits.isEmpty)
          const _EtatVideSection(
            message: 'Aucune sollicitation ouverte pour le moment.',
          )
        else
          ListeSollicitationsCoop(
            items: sollicits.map(_sollicitToMock).toList(growable: false),
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
    );
  }

  // ── Mappings PublicationCoop / Sollicitation → DTOs d'affichage ──

  static final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

  static PubMock _pubToMock(PublicationCoop p) {
    return PubMock(
      id: p.id,
      titre: p.titre,
      quantite: '${_nf.format(p.quantiteKg.round())} kg agrégés',
      prix: '${_nf.format(p.prixParKg.round())} F/kg',
    );
  }

  static SollicitationMock _sollicitToMock(Sollicitation s) {
    final qte = s.quantiteCibleKg?.round();
    final titre = qte != null
        ? '${_nf.format(qte)} kg demandés'
        : (s.message?.trim().isNotEmpty == true
            ? s.message!.trim()
            : 'Sollicitation reçue');
    return SollicitationMock(
      id: s.id,
      titre: titre,
      date: _formatRelatif(s.createdAt) ?? '—',
    );
  }
}

// ─── États bordures ────────────────────────────────────────────────

/// L'utilisateur n'a pas (encore) de coop liée à son compte.
class _EtatPasDeCoop extends StatelessWidget {
  const _EtatPasDeCoop();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.groups_2_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Tu n'es membre d'aucune coopérative",
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Rejoindre une coop te permet de regrouper tes ventes et '
            "d'accéder à des commandes plus importantes.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Encadré sobre quand une section (publications / sollicitations) n'a
/// rien à afficher — évite un trou visuel et est honnête.
class _EtatVideSection extends StatelessWidget {
  const _EtatVideSection({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper : date relative en français ───────────────────────────

String? _formatRelatif(DateTime? date) {
  if (date == null) return null;
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'à l’instant';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
  final semaines = (diff.inDays / 7).floor();
  if (semaines < 5) return 'il y a $semaines sem';
  final mois = (diff.inDays / 30).floor();
  return 'il y a $mois mois';
}
