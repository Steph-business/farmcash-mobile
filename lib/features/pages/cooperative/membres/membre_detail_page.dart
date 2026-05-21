import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/membre_coop.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── COULEURS & RADIUS LOCAUX (alignés sur la maquette) ─────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const BorderRadius _kBrHero = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));

/// Provider qui retrouve un membre via `listMembers()` filtré par userId.
///
/// Le backend n'a pas de `GET /coop/members/:id` ; on récupère la liste
/// complète paginée (limite 100) puis on filtre côté client par `userId`,
/// qui est le paramètre passé dans l'URL.
final _membreDetailProvider = FutureProvider.autoDispose
    .family<MembreCoop?, String>((ref, userId) async {
  final svc = ref.read(cooperativesServiceProvider);
  final page = await svc.listMembers(limit: 100);
  for (final m in page.data) {
    if (m.userId == userId || m.id == userId) return m;
  }
  return null;
});

/// Fiche d'un membre de la coopérative (accès via la liste membres).
///
/// CRITIQUE — règle chantier 3b "anti-contournement" :
/// La coopérative voit FULL ses membres. Cet écran affiche donc :
///   • le nom complet réel (header, hero) ;
///   • le téléphone réel ;
///   • le rôle réel ;
///   • la date d'adhésion.
///
/// Cette EXCEPTION s'applique UNIQUEMENT entre la coop et SES membres.
class MembreDetailPage extends ConsumerWidget {
  const MembreDetailPage({super.key, required this.membreId});

  /// `userId` du membre — c'est ce qui figure dans l'URL `/membres/:id`.
  final String membreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_membreDetailProvider(membreId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              nom: async.maybeWhen(
                data: (m) => m?.fullName ?? 'Membre',
                orElse: () => 'Membre',
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger ce membre. $e',
                    onRetry: () =>
                        ref.invalidate(_membreDetailProvider(membreId)),
                  ),
                ),
                data: (membre) {
                  if (membre == null) {
                    return Padding(
                      padding:
                          const EdgeInsets.all(AppDimens.pagePaddingH),
                      child: Text(
                        'Membre introuvable.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    );
                  }
                  return _Body(membre: membre);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.membre});

  final MembreCoop membre;

  @override
  Widget build(BuildContext context) {
    final fullName = membre.fullName ?? 'Membre';
    final phone = membre.phone;
    final photoUrl = membre.photoUrl;
    final dateAdhesion = membre.joinedAt;
    final membreDepuisLabel = dateAdhesion == null
        ? 'Adhésion récente'
        : 'Membre depuis ${DateFormat('MM/y').format(dateAdhesion)}';
    final roleLabel = _roleLabel(membre.role);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        // 1. Hero card : photo + nom + tag membre + tel
        _HeroCard(
          nom: fullName,
          phone: phone,
          photoUrl: photoUrl,
          membreDepuis: membreDepuisLabel,
          roleLabel: roleLabel,
          onAppeler: () =>
              _snack(context, 'Appel en cours — à venir'),
          onMessage: () => _snack(context, 'Message — à venir'),
        ),
        AppDimens.vGap16,

        // 2. Section "Wallet du membre"
        const _SectionHead(titre: 'Actions'),
        _ActionsCard(
          onVerserAvance: () => context.push(
            '${RouteNames.cooperativeVerserAvancePath}?membreId=${membre.userId}',
          ),
        ),
      ],
    );
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

String _roleLabel(CoopMemberRole role) {
  switch (role) {
    case CoopMemberRole.president:
      return 'Président';
    case CoopMemberRole.gerant:
      return 'Gérant';
    case CoopMemberRole.tresorier:
      return 'Trésorier';
    case CoopMemberRole.membre:
      return 'Membre';
    case CoopMemberRole.unknown:
      return 'Membre';
  }
}

// ─── Header (back + nom COMPLET du membre) ──────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.nom});

  final String nom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.cooperativeMembresPath),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              nom,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero card ──────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.nom,
    required this.phone,
    required this.photoUrl,
    required this.membreDepuis,
    required this.roleLabel,
    required this.onAppeler,
    required this.onMessage,
  });

  final String nom;
  final String? phone;
  final String? photoUrl;
  final String membreDepuis;
  final String roleLabel;
  final VoidCallback onAppeler;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrHero,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          // Photo ronde 80px
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: (photoUrl != null && photoUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: _kPrimarySoft),
                    errorWidget: (_, _, _) => _initialesAvatar(nom),
                  )
                : _initialesAvatar(nom),
          ),
          const SizedBox(height: 12),
          Text(
            nom,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (phone != null && phone!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              phone!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _Tag(label: roleLabel),
              _Tag(label: membreDepuis),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.phone_outlined,
                  label: 'Appeler',
                  filled: false,
                  onTap: onAppeler,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Message',
                  filled: true,
                  onTap: onMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _initialesAvatar(String nom) {
  return Center(
    child: Text(
      _initiales(nom),
      style: AppTextStyles.titleLarge.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.onPrimary : AppColors.text;
    final bg = filled ? AppColors.primary : AppColors.background;
    final border = filled ? AppColors.primary : AppColors.border;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: AppDimens.borderThin),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section head ───────────────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.titre});

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        titre,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Actions ────────────────────────────────────────────────────────────

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({required this.onVerserAvance});

  final VoidCallback onVerserAvance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: AppColors.primary,
        child: InkWell(
          onTap: onVerserAvance,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              'Verser une avance',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────

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
