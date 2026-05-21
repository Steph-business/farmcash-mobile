import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/enums.dart';
import '../../../models/livraison.dart';
import '../../../models/portefeuille.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── CONSTANTES LOCALES (alignées sur la page producteur) ────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// Radius des cards de cette page (14 — acceptable par DESIGN.md pour cette
// page d'accueil avec photos, sauf CTA hero qui est en 16).
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrHero = BorderRadius.all(Radius.circular(16));

// Photos statiques pour les "Outils intelligents" (Unsplash — pas du mock
// data fonctionnel, c'est juste de l'illustration neutre comme demandé).
const String _kPhotoAssistantRoute =
    'https://images.unsplash.com/photo-1601379329542-31c59a99f1c1?w=400&h=300&fit=crop&auto=format';
const String _kPhotoOptimisation =
    'https://images.unsplash.com/photo-1494412519320-aa613dfb7738?w=400&h=300&fit=crop&auto=format';

/// Bundle de données chargées en parallèle pour l'accueil transporteur.
///
/// Chaque appel est tolérant : un service en échec retourne `null`/liste
/// vide et les sections concernées sont masquées (graceful degradation).
class _AccueilTransporteurData {
  final Portefeuille? wallet;
  final List<Livraison> mesShipments;
  final List<Livraison> disponibles;
  final List<TransporterRoute> routes;

  const _AccueilTransporteurData({
    required this.wallet,
    required this.mesShipments,
    required this.disponibles,
    required this.routes,
  });

  /// Mission en cours actuellement (status LOADING ou IN_TRANSIT) parmi
  /// les shipments acceptés par le transporteur.
  Livraison? get missionActive {
    for (final m in mesShipments) {
      if (m.status == ShipmentStatus.loading ||
          m.status == ShipmentStatus.inTransit) {
        return m;
      }
    }
    return null;
  }

  /// Missions ouvertes à acceptation — toujours fournies par l'endpoint
  /// `getAvailableMissions` (statut REQUESTED matchant les routes).
  List<Livraison> get missionsDisponibles => disponibles;

  /// Prochains chargements : missions déjà acceptées par le transporteur
  /// mais pas encore en LOADING/IN_TRANSIT.
  List<Livraison> get prochainsChargements => [
        for (final m in mesShipments)
          if (m.status == ShipmentStatus.accepted) m,
      ];

  int get nbLivrees =>
      mesShipments.where((m) => m.status == ShipmentStatus.delivered).length;

  bool get isEmpty =>
      missionActive == null &&
      missionsDisponibles.isEmpty &&
      prochainsChargements.isEmpty;
}

/// Charge en parallèle les données nécessaires à l'accueil transporteur.
///
/// **3 sources distinctes** : `getMyMissions()` pour les shipments acceptés
/// (compteur livrées, mission active, prochains chargements),
/// `getAvailableMissions()` pour les missions à accepter, et `getWallet()`
/// pour le solde affiché en KPI.
final accueilTransporteurDataProvider =
    FutureProvider.autoDispose<_AccueilTransporteurData>((ref) async {
  final logistics = ref.watch(logisticsServiceProvider);
  final finance = ref.watch(financeServiceProvider);

  final results = await Future.wait<dynamic>([
    logistics
        .getMyMissions()
        .then<Object?>((v) => v)
        .catchError((_) => <Livraison>[]),
    logistics
        .getAvailableMissions()
        .then<Object?>((v) => v)
        .catchError((_) => <Livraison>[]),
    logistics
        .listMyRoutes()
        .then<Object?>((v) => v)
        .catchError((_) => <TransporterRoute>[]),
    finance.getWallet().then<Object?>((v) => v).catchError((_) => null),
  ]);

  final mesShipments = (results[0] as List<Livraison>?) ?? const [];
  final disponibles = (results[1] as List<Livraison>?) ?? const [];
  final routes = (results[2] as List<TransporterRoute>?) ?? const [];
  final walletBundle = results[3];
  final Portefeuille? wallet =
      walletBundle == null ? null : (walletBundle as dynamic).wallet as Portefeuille;

  return _AccueilTransporteurData(
    wallet: wallet,
    mesShipments: mesShipments,
    disponibles: disponibles,
    routes: routes,
  );
});

/// Accueil transporteur — mission active, KPI, missions disponibles,
/// prochains chargements.
///
/// Conforme à `mockups/transporteur_accueil.html`. Pas de mock data : tous
/// les blocs consomment les services Riverpod (`logistics`, `finance`).
/// Les sections sans donnée se masquent silencieusement.
class AccueilPage extends ConsumerWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(accueilTransporteurDataProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HeaderUtilisateur(
              variant: HeaderVariant.transporteur,
              subtitleOverride: _sousTitreHeader(async, user?.rating),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger l\'accueil.',
                    onRetry: () =>
                        ref.invalidate(accueilTransporteurDataProvider),
                  ),
                ),
                data: (data) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async =>
                      ref.invalidate(accueilTransporteurDataProvider),
                  child: _ContenuAccueil(data: data, rating: user?.rating ?? 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sousTitreHeader(
    AsyncValue<_AccueilTransporteurData> async,
    double? rating,
  ) {
    final data = async.value;
    final nb = data?.missionsDisponibles.length ?? 0;
    final missionsTxt = nb == 0
        ? 'Aucune mission disponible'
        : '$nb mission${nb > 1 ? 's' : ''} disponible${nb > 1 ? 's' : ''}';
    return missionsTxt;
  }
}

// ─── CONTENU ─────────────────────────────────────────────────────────────

class _ContenuAccueil extends StatelessWidget {
  const _ContenuAccueil({required this.data, required this.rating});

  final _AccueilTransporteurData data;
  final double rating;

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
        // 1. Mission active (déjà existant)
        if (mActive != null) ...[
          _MissionActiveCard(mission: mActive),
          AppDimens.vGap24,
        ],
        // 2. CTA "Déclarer un itinéraire" — masqué si mission active
        //    (sinon redondant avec le FAB du shell)
        if (mActive == null) ...[
          _CtaDeclarerItineraire(
            onTap: () => context.push(RouteNames.transporteurItinerairesPath),
          ),
          AppDimens.vGap24,
        ],
        // 3. KPI
        _KpiRow(
          gains: data.wallet?.balance ?? 0,
          devise: data.wallet?.currency ?? 'XOF',
          livrees: data.nbLivrees,
          note: rating,
        ),
        AppDimens.vGap24,
        // 4. Missions disponibles (déjà existant)
        if (disponibles.isNotEmpty) ...[
          _SectionMissions(
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
          _SectionItineraires(routes: itinerairesActifs),
          AppDimens.vGap24,
        ],
        // 6. Prochains chargements (déjà existant)
        if (prochains.isNotEmpty) ...[
          _SectionMissions(
            titre: 'Prochains chargements',
            missions: prochains.take(3).toList(),
            avecBoutonAccepter: false,
          ),
          AppDimens.vGap24,
        ],
        // 7. Outils intelligents (grid 2 cards avec photos)
        _SectionOutilsIA(
          onAssistant: () => _snack(context, 'Assistant route — à venir'),
          onOptimisation: () => _snack(context, 'Optimisation — à venir'),
        ),
        AppDimens.vGap24,
        if (data.isEmpty) const _EtatVide(),
      ],
    );
  }
}

// ─── MISSION ACTIVE ──────────────────────────────────────────────────────

class _MissionActiveCard extends StatelessWidget {
  const _MissionActiveCard({required this.mission});

  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final route = _formatRoute(mission);
    final meta = _formatMeta(mission);
    final eta = _formatEta(mission);

    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.primary, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppDimens.hGap8,
                    Flexible(
                      child: Text(
                        _labelStatut(mission.status),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (eta != null)
                Text(
                  eta,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            route,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (meta != null) ...[
            const SizedBox(height: 4),
            Text(
              meta,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BoutonSecondaire(
                  label: 'Suivre',
                  onTap: () => context.push(
                    RouteNames.transporteurMissionEnRoutePathFor(mission.id),
                  ),
                ),
              ),
              AppDimens.hGap8,
              Expanded(
                child: _BoutonPrimaire(
                  label: 'Marquer livré',
                  onTap: () =>
                      context.push(RouteNames.transporteurScannerPath),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _labelStatut(ShipmentStatus s) {
    switch (s) {
      case ShipmentStatus.inTransit:
        return 'EN TRANSIT';
      case ShipmentStatus.loading:
        return 'CHARGEMENT';
      case ShipmentStatus.accepted:
        return 'ACCEPTÉE';
      case ShipmentStatus.requested:
        return 'EN ATTENTE';
      case ShipmentStatus.delivered:
        return 'LIVRÉE';
      case ShipmentStatus.cancelled:
        return 'ANNULÉE';
      case ShipmentStatus.unknown:
        return 'EN COURS';
    }
  }

  String? _formatEta(Livraison m) {
    final dt = m.scheduledAt;
    if (dt == null) return null;
    return 'Arrivée ${DateFormat('HH:mm', 'fr_FR').format(dt.toLocal())}';
  }
}

// ─── KPI ROW ─────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.gains,
    required this.devise,
    required this.livrees,
    required this.note,
  });

  final double gains;
  final String devise;
  final int livrees;
  final double note;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            icon: Icons.payments_outlined,
            valeur: _formatMontant(gains, devise),
            libelle: 'Gains 7 jours',
          ),
        ),
        AppDimens.hGap8,
        Expanded(
          child: _KpiCard(
            icon: Icons.local_shipping_outlined,
            valeur: livrees.toString(),
            libelle: 'Livrées',
          ),
        ),
        AppDimens.hGap8,
        Expanded(
          child: _KpiCard(
            icon: Icons.star_border,
            valeur: note > 0
                ? '★ ${note.toStringAsFixed(1).replaceAll('.', ',')}'
                : '—',
            libelle: 'Note',
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.valeur,
    required this.libelle,
  });

  final IconData icon;
  final String valeur;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimens.iconS,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 6),
          Text(
            valeur,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            libelle,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── SECTION MISSIONS ────────────────────────────────────────────────────

class _SectionMissions extends StatelessWidget {
  const _SectionMissions({
    required this.titre,
    required this.missions,
    required this.avecBoutonAccepter,
    this.lienTexte,
    this.onLienTap,
  });

  final String titre;
  final String? lienTexte;
  final VoidCallback? onLienTap;
  final List<Livraison> missions;
  final bool avecBoutonAccepter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(
          titre: titre,
          lienTexte: lienTexte,
          onLienTap: onLienTap,
        ),
        for (var i = 0; i < missions.length; i++) ...[
          _MissionCard(
            mission: missions[i],
            avecBoutonAccepter: avecBoutonAccepter,
          ),
          if (i < missions.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.mission,
    required this.avecBoutonAccepter,
  });

  final Livraison mission;
  final bool avecBoutonAccepter;

  @override
  Widget build(BuildContext context) {
    final route = _formatRoute(mission);
    final meta = _formatMeta(mission);
    final prix = _formatPrix(mission.prixDevis);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimens.brCard,
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      route,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (meta != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              AppDimens.hGap8,
              Text(
                prix,
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          if (avecBoutonAccepter) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () => context.push(
                    RouteNames.transporteurMissionDetailPathFor(mission.id),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimens.brButton,
                    ),
                    textStyle: AppTextStyles.button.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  child: const Text('Accepter'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── SECTION HEAD ────────────────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({
    required this.titre,
    this.lienTexte,
    this.onLienTap,
  });

  final String titre;
  final String? lienTexte;
  final VoidCallback? onLienTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titre,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (lienTexte != null)
            InkWell(
              onTap: onLienTap,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                child: Text(
                  lienTexte!,
                  style: AppTextStyles.link.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── BOUTONS MISSION ACTIVE ──────────────────────────────────────────────

class _BoutonSecondaire extends StatelessWidget {
  const _BoutonSecondaire({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          backgroundColor: AppColors.surface,
          side: const BorderSide(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brButton,
          ),
          padding: EdgeInsets.zero,
          textStyle: AppTextStyles.button.copyWith(fontSize: 13),
        ),
        child: Text(label),
      ),
    );
  }
}

class _BoutonPrimaire extends StatelessWidget {
  const _BoutonPrimaire({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.brButton,
          ),
          textStyle: AppTextStyles.button.copyWith(fontSize: 13),
        ),
        child: Text(label),
      ),
    );
  }
}

// ─── ÉTAT VIDE ───────────────────────────────────────────────────────────

class _EtatVide extends StatelessWidget {
  const _EtatVide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space32),
      child: Column(
        children: [
          Text(
            'Aucune mission pour le moment',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap8,
          Text(
            'Déclarez un itinéraire pour recevoir des propositions.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap16,
          SizedBox(
            height: AppDimens.buttonHeight,
            child: ElevatedButton(
              onPressed: () =>
                  context.push(RouteNames.transporteurItinerairesPath),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppDimens.brButton,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space24,
                ),
              ),
              child: Text(
                'Déclarer un itinéraire',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CTA "DÉCLARER UN ITINÉRAIRE" ────────────────────────────────────────

class _CtaDeclarerItineraire extends StatelessWidget {
  const _CtaDeclarerItineraire({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: _kBrHero,
      child: InkWell(
        onTap: onTap,
        borderRadius: _kBrHero,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Déclarer un itinéraire',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Indique tes trajets habituels pour recevoir plus de missions',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.onPrimary.withValues(alpha: 0.9),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              AppDimens.hGap12,
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.alt_route,
                  size: 20,
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SECTION "MES ITINÉRAIRES ACTIFS" ────────────────────────────────────

class _SectionItineraires extends StatelessWidget {
  const _SectionItineraires({required this.routes});

  final List<TransporterRoute> routes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHead(
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
                _ItineraireCard(route: routes[i], index: i),
          ),
        ),
      ],
    );
  }
}

class _ItineraireCard extends StatelessWidget {
  const _ItineraireCard({required this.route, required this.index});

  final TransporterRoute route;
  final int index;

  @override
  Widget build(BuildContext context) {
    final trajet = _formatTrajet(route, index);
    final capacite =
        NumberFormat('#,##0', 'fr_FR').format(route.capaciteMaxKg);
    final prix = NumberFormat('#,##0', 'fr_FR').format(route.tarifKg);

    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
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
                      color: _kPrimarySoft,
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

// ─── SECTION "OUTILS INTELLIGENTS" (grid 2 cards avec photos) ────────────

class _SectionOutilsIA extends StatelessWidget {
  const _SectionOutilsIA({
    required this.onAssistant,
    required this.onOptimisation,
  });

  final VoidCallback onAssistant;
  final VoidCallback onOptimisation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHead(titre: 'Outils intelligents'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _OutilCard(
                photoUrl: _kPhotoAssistantRoute,
                badgeIcon: Icons.chat_bubble_outline,
                titre: 'Assistant route',
                sousTitre: 'Conseils trajet, météo, conditions',
                onTap: onAssistant,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: _OutilCard(
                photoUrl: _kPhotoOptimisation,
                badgeIcon: Icons.trending_up,
                titre: 'Optimisation',
                sousTitre: 'Identifie les meilleures opportunités',
                onTap: onOptimisation,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OutilCard extends StatelessWidget {
  const _OutilCard({
    required this.photoUrl,
    required this.badgeIcon,
    required this.titre,
    required this.sousTitre,
    required this.onTap,
  });

  final String photoUrl;
  final IconData badgeIcon;
  final String titre;
  final String sousTitre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: _kBrCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: _kBrCard,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: _kBrCard,
            border:
                Border.all(color: AppColors.border, width: AppDimens.borderThin),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo + badge en bas-droite (overflow autorisé via Stack)
              SizedBox(
                height: 80 + 12, // 80 photo + 12 badge overflow
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      bottom: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.surfaceSoft,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceSoft,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          badgeIcon,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                titre,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                sousTitre,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────

/// Formate `12500` → `12 500 F` (devise XOF uniquement, sinon le code).
String _formatMontant(double montant, String devise) {
  final formatted = NumberFormat('#,##0', 'fr_FR').format(montant);
  if (devise == 'XOF' || devise.isEmpty) {
    return '$formatted F';
  }
  return '$formatted $devise';
}

/// Formate le prix d'une mission (peut être null).
String _formatPrix(double? prix) {
  if (prix == null || prix <= 0) return '—';
  return '${NumberFormat('#,##0', 'fr_FR').format(prix)} F';
}

/// `origine → destination` à partir d'une [Livraison]. Préfère
/// `origine_zone`/`destination_zone` (libellés courts du back) et
/// retombe sur l'adresse pickup/delivery sinon.
String _formatRoute(Livraison m) {
  final itin = m.itineraireLabel;
  if (itin != null && itin.isNotEmpty) return itin;
  final origine = (m.pickupAddress ?? '').trim();
  final dest = (m.deliveryAddress ?? '').trim();
  if (origine.isEmpty && dest.isEmpty) return 'Trajet';
  if (origine.isEmpty) return dest;
  if (dest.isEmpty) return origine;
  return '$origine → $dest';
}

/// Ligne meta d'une mission : aujourd'hui on n'expose ni la quantité ni le
/// produit sur la `Livraison`. On affiche donc l'horaire planifié quand on
/// l'a, sinon `null` (la ligne est alors masquée).
String? _formatMeta(Livraison m) {
  final dt = m.scheduledAt;
  if (dt == null) return null;
  final local = dt.toLocal();
  final now = DateTime.now();
  final isToday = local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  final isTomorrow = local.year == now.year &&
      local.month == now.month &&
      local.day == now.day + 1;
  final heure = DateFormat('HH:mm', 'fr_FR').format(local);
  if (isToday) return 'Aujourd\'hui $heure';
  if (isTomorrow) return 'Demain $heure';
  return DateFormat('d MMM HH:mm', 'fr_FR').format(local);
}

/// SnackBar discrète "à venir".
void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Affichage du trajet d'une route déclarée. Le backend renvoie les zones
/// sous forme de noms lisibles (« Bouaké », « Abidjan »).
String _formatTrajet(TransporterRoute r, int index) {
  final origine = r.origineZone.trim();
  final dest = r.destinationZone.trim();
  if (origine.isEmpty && dest.isEmpty) {
    return 'Itinéraire ${index + 1}';
  }
  return '$origine → $dest';
}
