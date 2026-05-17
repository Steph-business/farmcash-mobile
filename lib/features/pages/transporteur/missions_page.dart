import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/header_utilisateur.dart';

// ─── Couleurs locales (alignées sur la maquette) ────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarn = Color(0xFFB45309);

/// Sémantique du chip / badge mission.
enum _MissionKind { ok, warn }

/// Onglet en haut de la page Missions transporteur.
enum _MissionTab { enCours, disponibles, terminees }

/// Modèle local pour une mission mock — calqué sur la maquette HTML.
class _MockMission {
  final String id;
  final String badgeLabel;
  final _MissionKind badgeKind;
  final String photoUrl;
  final String titre; // « 500 kg Maïs blanc »
  final String route; // « Yao Konan (Yopougon) → … »
  final String meta; // « 12 km · ETA 14h »
  final String chipLabel; // « En route vers enlèvement »
  final _MissionKind chipKind;
  final IconData chipIcon;
  final String prixLabel; // « +18 500 F »
  final _MissionTab tab;

  const _MockMission({
    required this.id,
    required this.badgeLabel,
    required this.badgeKind,
    required this.photoUrl,
    required this.titre,
    required this.route,
    required this.meta,
    required this.chipLabel,
    required this.chipKind,
    required this.chipIcon,
    required this.prixLabel,
    required this.tab,
  });
}

/// Liste mock alignée 1:1 sur `mockups/transporteur/missions.html` (3
/// missions en cours). Noms FULL — le transporteur voit son chantier en clair.
const List<_MockMission> _kMockMissions = [
  _MockMission(
    id: 'mission_baoule_mais',
    badgeLabel: 'Enlèvement en route',
    badgeKind: _MissionKind.ok,
    photoUrl:
        'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716'
        '?w=200&h=200&fit=crop&auto=format',
    titre: '500 kg Maïs blanc',
    route: 'Yao Konan (Yopougon) → Restaurant Le Baoulé (Cocody)',
    meta: '12 km · ETA 14h',
    chipLabel: 'En route vers enlèvement',
    chipKind: _MissionKind.ok,
    chipIcon: Icons.local_shipping_outlined,
    prixLabel: '+18 500 F',
    tab: _MissionTab.enCours,
  ),
  _MockMission(
    id: 'mission_industries_manioc',
    badgeLabel: 'Livraison en cours',
    badgeKind: _MissionKind.ok,
    photoUrl:
        'https://images.unsplash.com/photo-1574484284002-952d92456975'
        '?w=200&h=200&fit=crop&auto=format',
    titre: '300 kg Manioc',
    route: 'COOP Sassandra → Industries Agricoles (Treichville)',
    meta: '235 km · ETA dans 1h',
    chipLabel: 'En route vers livraison',
    chipKind: _MissionKind.ok,
    chipIcon: Icons.local_shipping_outlined,
    prixLabel: '+28 000 F',
    tab: _MissionTab.enCours,
  ),
  _MockMission(
    id: 'mission_aya_tomate',
    badgeLabel: "En attente d'enlèvement",
    badgeKind: _MissionKind.warn,
    photoUrl:
        'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31'
        '?w=200&h=200&fit=crop&auto=format',
    titre: '80 kg Tomate',
    route: "Aya N'Guessan → Marie Yao",
    meta: '8 km · départ programmé 16h',
    chipLabel: 'Programmée',
    chipKind: _MissionKind.warn,
    chipIcon: Icons.schedule,
    prixLabel: '+6 500 F',
    tab: _MissionTab.enCours,
  ),
];

const int _kDisponibles = 5;

/// Onglet Missions du transporteur — accessible via le bottom-nav (shell).
///
/// Reproduction fidèle de `mockups/transporteur/missions.html` : header
/// transporteur, compteur primary-soft, tab bar « En cours / Disponibles
/// / Terminées », et liste de cards mission avec badge statut, photo,
/// route, chip d'état, prix.
///
/// Mock-first : à brancher sur `transporteurSvc.listMissions()` quand prêt.
class MissionsTransporteurPage extends ConsumerStatefulWidget {
  const MissionsTransporteurPage({super.key});

  @override
  ConsumerState<MissionsTransporteurPage> createState() =>
      _MissionsTransporteurPageState();
}

class _MissionsTransporteurPageState
    extends ConsumerState<MissionsTransporteurPage> {
  _MissionTab _tab = _MissionTab.enCours;

  List<_MockMission> get _filtered =>
      _kMockMissions.where((m) => m.tab == _tab).toList(growable: false);

  int get _countEnCours =>
      _kMockMissions.where((m) => m.tab == _MissionTab.enCours).length;

  void _ouvrirMission(_MockMission m) {
    context.push(RouteNames.transporteurMissionDetailPathFor(m.id));
  }

  @override
  Widget build(BuildContext context) {
    final missions = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderUtilisateur(variant: HeaderVariant.transporteur),
            const _PageTitle(),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.pagePaddingH,
                0,
                AppDimens.pagePaddingH,
                AppDimens.space12,
              ),
              child: _CounterHero(
                texte: '3 missions actives · 87 km au total',
              ),
            ),
            _TabBar(
              current: _tab,
              enCoursCount: _countEnCours,
              disponiblesCount: _kDisponibles,
              onSelect: (t) => setState(() => _tab = t),
            ),
            Expanded(
              child: missions.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.pagePaddingH,
                        AppDimens.space12,
                        AppDimens.pagePaddingH,
                        AppDimens.space16,
                      ),
                      itemCount: missions.length,
                      itemBuilder: (_, i) => _MissionCard(
                        mission: missions[i],
                        onTap: () => _ouvrirMission(missions[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Titre de page ──────────────────────────────────────────────────────

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space8,
      ),
      child: Text(
        'Missions',
        style: AppTextStyles.displayLarge.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

// ─── Compteur hero (primary soft) ───────────────────────────────────────

class _CounterHero extends StatelessWidget {
  const _CounterHero({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 18,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texte,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab bar ────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.current,
    required this.enCoursCount,
    required this.disponiblesCount,
    required this.onSelect,
  });

  final _MissionTab current;
  final int enCoursCount;
  final int disponiblesCount;
  final ValueChanged<_MissionTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePaddingH),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          _tab(_MissionTab.enCours, 'En cours ($enCoursCount)'),
          const SizedBox(width: 18),
          _tab(_MissionTab.disponibles, 'Disponibles ($disponiblesCount)'),
          const SizedBox(width: 18),
          _tab(_MissionTab.terminees, 'Terminées'),
        ],
      ),
    );
  }

  Widget _tab(_MissionTab value, String label) {
    final active = value == current;
    return InkWell(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Mission card ───────────────────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.onTap});

  final _MockMission mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Badge(label: mission.badgeLabel, kind: mission.badgeKind),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.border,
                          width: AppDimens.borderThin,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: mission.photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            const ColoredBox(color: AppColors.surfaceSoft),
                        errorWidget: (_, _, _) => const Icon(
                          Icons.local_shipping_outlined,
                          color: AppColors.textSubtle,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mission.titre,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mission.route,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mission.meta,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSubtle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.textSubtle,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Chip(
                        label: mission.chipLabel,
                        kind: mission.chipKind,
                        icon: mission.chipIcon,
                      ),
                    ),
                    Text(
                      mission.prixLabel,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.kind});

  final String label;
  final _MissionKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      _MissionKind.ok => (_kPrimarySoft, AppColors.primary),
      _MissionKind.warn => (_kWarnSoft, _kWarn),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.kind, required this.icon});

  final String label;
  final _MissionKind kind;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      _MissionKind.ok => (_kPrimarySoft, AppColors.primary),
      _MissionKind.warn => (_kWarnSoft, _kWarn),
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── État vide ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucune mission dans cet onglet',
              style: AppTextStyles.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
