import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/membre_coop.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/header_utilisateur.dart';
import '../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarn = Color(0xFFB45309);

/// Bundle membres + nombre de demandes d'adhésion en attente.
class _MembresData {
  const _MembresData({required this.membres, required this.adhesionsCount});
  final List<MembreCoop> membres;
  final int adhesionsCount;
}

final _membresProvider =
    FutureProvider.autoDispose<_MembresData>((ref) async {
  final svc = ref.read(cooperativesServiceProvider);
  final results = await Future.wait<dynamic>([
    svc.listMembers(limit: 100).then<Object?>((v) => v),
    svc
        .listJoinRequests()
        .then<Object?>((v) => v)
        .catchError((_) => const <CoopJoinRequest>[]),
  ]);
  final page = results[0] as dynamic;
  final adhesions = results[1] as List<CoopJoinRequest>;
  return _MembresData(
    membres: page.data as List<MembreCoop>,
    adhesionsCount:
        adhesions.where((a) => a.status.toUpperCase() == 'PENDING').length,
  );
});

/// Liste des membres de la coopérative — branchée sur `listMembers`.
class MembresCooperativePage extends ConsumerWidget {
  const MembresCooperativePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_membresProvider);
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
                Expanded(
                  child: async.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Chargement(size: 22),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                      child: VueErreur(
                        message: 'Impossible de charger les membres. $e',
                        onRetry: () => ref.invalidate(_membresProvider),
                      ),
                    ),
                    data: (data) => RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        ref.invalidate(_membresProvider);
                        await ref.read(_membresProvider.future);
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.pagePaddingH,
                          AppDimens.space8,
                          AppDimens.pagePaddingH,
                          AppDimens.space48 + AppDimens.space24,
                        ),
                        children: [
                          _Summary(total: data.membres.length),
                          AppDimens.vGap16,
                          if (data.adhesionsCount > 0) ...[
                            _AdhesionsBanner(
                              count: data.adhesionsCount,
                              onTap: () => context.push(
                                RouteNames.cooperativeAdhesionsPath,
                              ),
                            ),
                            AppDimens.vGap16,
                          ],
                          if (data.membres.isEmpty)
                            const _EmptyState()
                          else
                            _MembersCard(
                              members: data.membres,
                              onTap: (m) => context.push(
                                RouteNames.cooperativeMembreDetailPathFor(m.userId),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: AppDimens.pagePaddingH,
              bottom: AppDimens.space24,
              child: _FabInviter(
                onTap: () =>
                    context.push(RouteNames.cooperativeInviterFarmerPath),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

class _Summary extends StatelessWidget {
  const _Summary({required this.total});
  final int total;
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        children: [
          TextSpan(
            text: '$total membre${total > 1 ? 's' : ''}',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const TextSpan(text: ' dans la coopérative'),
        ],
      ),
    );
  }
}

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.members, required this.onTap});
  final List<MembreCoop> members;
  final ValueChanged<MembreCoop> onTap;

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
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          for (var i = 0; i < members.length; i++) ...[
            _MemberRow(
              membre: members[i],
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
  const _MemberRow({required this.membre, required this.onTap});
  final MembreCoop membre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nom = membre.fullName ?? 'Membre';
    final phone = membre.phone ?? '';
    final df = DateFormat('MMM y', 'fr_FR');
    final joined =
        membre.joinedAt != null ? 'rejoint en ${df.format(membre.joinedAt!)}' : '';
    final sousTitre = [if (phone.isNotEmpty) phone, if (joined.isNotEmpty) joined]
        .join(' · ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _initiales(nom),
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
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
                    nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (sousTitre.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sousTitre,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            _RolePill(role: membre.role.apiValue),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role});
  final String role;
  @override
  Widget build(BuildContext context) {
    final label = role.toLowerCase() == 'membre' ? 'Membre' : role;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _FabInviter extends StatelessWidget {
  const _FabInviter({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_add_alt_1, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Inviter',
              style: AppTextStyles.button.copyWith(
                color: AppColors.onPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.group_outlined,
            size: 40,
            color: AppColors.textSubtle.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun membre pour le moment',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Invite des farmers via le bouton « Inviter ».',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

String _initiales(String s) {
  final t = s.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}
