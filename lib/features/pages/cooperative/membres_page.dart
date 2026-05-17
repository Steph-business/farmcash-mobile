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

/// Sémantique du pill statut membre.
enum _MemberStatus { actif, inactif }

/// Modèle local pour un membre coop mock — calqué sur la maquette HTML.
class _MockMember {
  final String id;
  final String photoUrl;
  final String nomComplet;
  final String ville;
  final String montantVerseLabel;
  final _MemberStatus statut;

  const _MockMember({
    required this.id,
    required this.photoUrl,
    required this.nomComplet,
    required this.ville,
    required this.montantVerseLabel,
    required this.statut,
  });
}

/// Liste mock alignée sur `mockups/cooperative/membres.html` (noms FULL —
/// la coopérative voit ses membres en clair, pas d'anonymisation).
const List<_MockMember> _kMockMembers = [
  _MockMember(
    id: 'mem_yao',
    photoUrl:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
        '?w=120&h=120&fit=crop&auto=format',
    nomComplet: 'Yao Konan',
    ville: 'Yopougon',
    montantVerseLabel: '850 000 F',
    statut: _MemberStatus.actif,
  ),
  _MockMember(
    id: 'mem_aya',
    photoUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d'
        '?w=120&h=120&fit=crop&auto=format',
    nomComplet: "Aya N'Guessan",
    ville: 'Sassandra',
    montantVerseLabel: '620 000 F',
    statut: _MemberStatus.actif,
  ),
  _MockMember(
    id: 'mem_kouadio',
    photoUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e'
        '?w=120&h=120&fit=crop&auto=format',
    nomComplet: 'Kouadio Bertin',
    ville: 'Yamoussoukro',
    montantVerseLabel: '420 000 F',
    statut: _MemberStatus.actif,
  ),
  _MockMember(
    id: 'mem_adjoua',
    photoUrl:
        'https://images.unsplash.com/photo-1599566150163-29194dcaad36'
        '?w=120&h=120&fit=crop&auto=format',
    nomComplet: 'Adjoua Brigitte',
    ville: 'Grand-Bassam',
    montantVerseLabel: '380 000 F',
    statut: _MemberStatus.actif,
  ),
  _MockMember(
    id: 'mem_traore',
    photoUrl:
        'https://images.unsplash.com/photo-1493612276216-ee3925520721'
        '?w=120&h=120&fit=crop&auto=format',
    nomComplet: 'Traoré Salif',
    ville: 'Bingerville',
    montantVerseLabel: '290 000 F',
    statut: _MemberStatus.actif,
  ),
  _MockMember(
    id: 'mem_diabate',
    photoUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80'
        '?w=120&h=120&fit=crop&auto=format',
    nomComplet: 'Diabaté Awa',
    ville: 'Jacqueville',
    montantVerseLabel: '175 000 F',
    statut: _MemberStatus.inactif,
  ),
  _MockMember(
    id: 'mem_konan_adjoua',
    photoUrl:
        'https://images.unsplash.com/photo-1463453091185-61582044d556'
        '?w=120&h=120&fit=crop&auto=format',
    nomComplet: 'Konan Adjoua',
    ville: 'Songon',
    montantVerseLabel: '140 000 F',
    statut: _MemberStatus.inactif,
  ),
  _MockMember(
    id: 'mem_bamba',
    photoUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2'
        '?w=120&h=120&fit=crop&auto=format',
    nomComplet: 'Bamba Yaya',
    ville: 'Port-Bouët',
    montantVerseLabel: '95 000 F',
    statut: _MemberStatus.inactif,
  ),
];

const int _kNbDemandesAdhesion = 3;
const int _kNbActifsCetteSemaine = 12;

/// Onglet Membres de la coopérative — accessible via le bottom-nav (shell).
///
/// Reproduction fidèle de `mockups/cooperative/membres.html` : header coop,
/// compteur récap, bandeau « Demandes d'adhésion », liste de 8 membres
/// avec photo / ville / montant versé / pill statut, et FAB « Inviter ».
///
/// Mock-first : à brancher sur `coopSvc.listMembers()` quand prêt.
class MembresCooperativePage extends ConsumerWidget {
  const MembresCooperativePage({super.key});

  void _ouvrirMembre(BuildContext context, _MockMember m) {
    context.push(RouteNames.cooperativeMembreDetailPathFor(m.id));
  }

  void _ouvrirAdhesions(BuildContext context) {
    context.push(RouteNames.cooperativeAdhesionsPath);
  }

  void _ouvrirInviter(BuildContext context) {
    context.push(RouteNames.cooperativeInviterFarmerPath);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                const HeaderUtilisateur(variant: HeaderVariant.cooperative),
                const _PageTitle(),
                const _Summary(
                  total: 47,
                  actifsCetteSemaine: _kNbActifsCetteSemaine,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.pagePaddingH,
                      AppDimens.space8,
                      AppDimens.pagePaddingH,
                      // Espace pour ne pas que le FAB cache la dernière card.
                      AppDimens.space48 + AppDimens.space24,
                    ),
                    children: [
                      _AdhesionsBanner(
                        count: _kNbDemandesAdhesion,
                        onTap: () => _ouvrirAdhesions(context),
                      ),
                      AppDimens.vGap16,
                      _MembersCard(
                        members: _kMockMembers,
                        onTap: (m) => _ouvrirMembre(context, m),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: AppDimens.pagePaddingH,
              bottom: AppDimens.space24,
              child: _FabInviter(onTap: () => _ouvrirInviter(context)),
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
        'Membres',
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

// ─── Récap ──────────────────────────────────────────────────────────────

class _Summary extends StatelessWidget {
  const _Summary({required this.total, required this.actifsCetteSemaine});

  final int total;
  final int actifsCetteSemaine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: '$total membres',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            TextSpan(text: ' · $actifsCetteSemaine actifs cette semaine'),
          ],
        ),
      ),
    );
  }
}

// ─── Bandeau Demandes d'adhésion ────────────────────────────────────────

class _AdhesionsBanner extends StatelessWidget {
  const _AdhesionsBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space16,
            vertical: AppDimens.space12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.group_add_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              AppDimens.hGap12,
              Expanded(
                child: Text(
                  "Demandes d'adhésion",
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _kWarnSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kWarn,
                    height: 1.2,
                  ),
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
        ),
      ),
    );
  }
}

// ─── Card membres ───────────────────────────────────────────────────────

class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.members, required this.onTap});

  final List<_MockMember> members;
  final ValueChanged<_MockMember> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < members.length; i++) ...[
            _MemberRow(
              member: members[i],
              onTap: () => onTap(members[i]),
            ),
            if (i < members.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.onTap});

  final _MockMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: member.photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    const ColoredBox(color: AppColors.surfaceSoft),
                errorWidget: (_, _, _) => const Icon(
                  Icons.person_outline,
                  color: AppColors.textSubtle,
                  size: 20,
                ),
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    member.nomComplet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.ville,
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
            AppDimens.hGap8,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.montantVerseLabel,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusPill(statut: member.statut),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.statut});

  final _MemberStatus statut;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (statut) {
      _MemberStatus.actif => (_kPrimarySoft, AppColors.primary, 'Actif'),
      _MemberStatus.inactif => (
        AppColors.surfaceSoft,
        AppColors.textSecondary,
        'Inactif'
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }
}

// ─── FAB "Inviter" ──────────────────────────────────────────────────────

class _FabInviter extends StatelessWidget {
  const _FabInviter({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 18, color: AppColors.onPrimary),
              const SizedBox(width: 6),
              Text(
                'Inviter',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
