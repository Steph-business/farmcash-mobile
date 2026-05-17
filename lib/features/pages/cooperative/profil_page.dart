import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/avance_coop.dart';
import '../../../models/cooperative.dart';
import '../../../models/enums.dart';
import '../../../models/membre_coop.dart';
import '../../../models/pagination.dart';
import '../../../models/payout.dart';
import '../../../models/utilisateur.dart';
import '../../../models/wallet_with_transactions.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── COULEURS & RAYONS LOCAUX (alignés sur la maquette) ─────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const BorderRadius _kBrIdentity = BorderRadius.all(Radius.circular(16));
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrPhoto = BorderRadius.all(Radius.circular(14));

/// Page profil de la coopérative — accessible via tap sur l'avatar du header
/// (route TOP-LEVEL hors shell). AppBar avec back button, pas d'icône
/// settings principale (l'icône paramètres déclenche juste un snackbar V1).
class ProfilCooperativePage extends ConsumerWidget {
  const ProfilCooperativePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_profilCoopDataProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          tooltip: 'Retour',
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(RouteNames.accueilCooperativePath),
        ),
        title: Text(
          'Mon profil',
          style: AppTextStyles.titleLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.text,
            ),
            tooltip: 'Paramètres',
            onPressed: () => _snack(context, 'Paramètres — à venir'),
          ),
        ],
      ),
      body: dataAsync.when(
        loading: () => const Chargement(size: 22),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(AppDimens.pagePaddingH),
          child: VueErreur(
            message: 'Impossible de charger le profil.',
            onRetry: () => ref.invalidate(_profilCoopDataProvider),
          ),
        ),
        data: (data) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(_profilCoopDataProvider);
            await ref.read(_profilCoopDataProvider.future);
          },
          child: _ProfilContent(data: data),
        ),
      ),
    );
  }
}

// ─── Provider racine (agrégation des appels API) ────────────────────────

final _profilCoopDataProvider =
    FutureProvider.autoDispose<_ProfilCoopData>((ref) async {
  final user = ref.watch(currentUserProvider);
  final coopSvc = ref.watch(cooperativesServiceProvider);
  final financeSvc = ref.watch(financeServiceProvider);

  // Coop publique : seulement si l'utilisateur a un cooperativeId connu.
  final coopFuture = (user?.cooperativeId != null &&
          user!.cooperativeId!.isNotEmpty)
      ? coopSvc
          .getPublic(user.cooperativeId!)
          .then<Cooperative?>((c) => c)
          .catchError((_) => null)
      : Future<Cooperative?>.value(null);

  final results = await Future.wait<dynamic>([
    coopFuture,
    financeSvc
        .getWallet()
        .then<WalletWithTransactions?>((w) => w)
        .catchError((_) => null),
    coopSvc.listMembers(limit: 100).catchError(
          (_) => const Paginated<MembreCoop>(
            data: [],
            total: 0,
            page: 1,
            limit: 0,
            totalPages: 0,
          ),
        ),
    coopSvc.listJoinRequests().catchError((_) => <CoopJoinRequest>[]),
    financeSvc.listPayoutBatches().catchError((_) => <PayoutBatch>[]),
    coopSvc.listAdvances().catchError((_) => <AvanceCoop>[]),
  ]);

  return _ProfilCoopData(
    user: user,
    coop: results[0] as Cooperative?,
    wallet: results[1] as WalletWithTransactions?,
    membres: results[2] as Paginated<MembreCoop>,
    joinRequests: results[3] as List<CoopJoinRequest>,
    payoutBatches: results[4] as List<PayoutBatch>,
    advances: results[5] as List<AvanceCoop>,
  );
});

// ─── Modèle interne ──────────────────────────────────────────────────────

class _ProfilCoopData {
  _ProfilCoopData({
    required this.user,
    required this.coop,
    required this.wallet,
    required this.membres,
    required this.joinRequests,
    required this.payoutBatches,
    required this.advances,
  });

  final Utilisateur? user;
  final Cooperative? coop;
  final WalletWithTransactions? wallet;
  final Paginated<MembreCoop> membres;
  final List<CoopJoinRequest> joinRequests;
  final List<PayoutBatch> payoutBatches;
  final List<AvanceCoop> advances;

  int get nbMembres => coop?.nbMembres ?? membres.total;

  int get nbDemandesEnAttente => joinRequests
      .where((r) => (r.status).toUpperCase() == 'PENDING')
      .length;

  int get nbDistributions => payoutBatches.length;

  int get nbAvancesActives =>
      advances.where((a) => a.status == CoopAdvanceStatus.paid).length;

  double get soldeWallet => wallet?.wallet.balance ?? 0;

  String get nomCoop {
    final n = coop?.nom.trim();
    if (n != null && n.isNotEmpty) return n;
    final un = user?.fullName?.trim();
    if (un != null && un.isNotEmpty) return un;
    return 'Ma coopérative';
  }

  String? get photoUrl {
    final p = coop?.logoUrl?.trim();
    if (p != null && p.isNotEmpty) return p;
    final up = user?.photoUrl?.trim();
    if (up != null && up.isNotEmpty) return up;
    return null;
  }

  /// Rating utilisateur (≈ note coop). Affiché formaté à 1 décimale.
  double get rating => user?.rating ?? 0;
}

// ─── Contenu principal ───────────────────────────────────────────────────

class _ProfilContent extends ConsumerWidget {
  const _ProfilContent({required this.data});

  final _ProfilCoopData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produits = data.coop?.produits ?? const <String>[];
    final autoDistribute = data.coop?.autoDistribute ?? false;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        // 1. CARTE IDENTITÉ
        _IdentityCard(
          nom: data.nomCoop,
          photoUrl: data.photoUrl,
          nbMembres: data.nbMembres,
          rating: data.rating,
          onEdit: () => _snack(context, 'Modification du profil — à venir'),
        ),
        AppDimens.vGap24,

        // 2. LIGNE 3 STATS
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _StatCard(value: '—', label: 'Ventes cumulées'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                value: '${data.nbDistributions}',
                label: 'Distributions',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                value: '${data.nbAvancesActives}',
                label: 'Avances actives',
              ),
            ),
          ],
        ),
        AppDimens.vGap24,

        // 3. SECTION IDENTITÉ DE LA COOP
        _SectionGroup(
          titre: 'Identité de la coop',
          rows: [
            _RowTile(
              icon: Icons.assignment_outlined,
              iconGreen: true,
              label: 'Numéro d\'agrément',
              onTap: () => _snack(context, 'à venir'),
            ),
            _RowTile(
              icon: Icons.location_on_outlined,
              iconGreen: true,
              label: 'Région & ville',
              onTap: () => _snack(context, 'à venir'),
            ),
            _RowTile(
              icon: Icons.eco_outlined,
              iconGreen: true,
              label: 'Produits gérés',
              sub: produits.isNotEmpty
                  ? produits.take(4).join(', ')
                  : null,
              onTap: () => _snack(context, 'à venir'),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 4. SECTION FINANCE
        _SectionGroup(
          titre: 'Finance',
          rows: [
            _RowTile(
              icon: Icons.account_balance_wallet_outlined,
              iconGreen: true,
              label: 'Wallet coopérative',
              value: _formatMontant(data.soldeWallet),
              onTap: () => _snack(context, 'à venir'),
            ),
            _RowTile(
              icon: Icons.percent,
              label: 'Commission par défaut',
              onTap: () => _snack(context, 'à venir'),
            ),
            _RowToggle(
              icon: Icons.autorenew,
              label: 'Distribution automatique',
              sub: 'Paiements aux membres après vente',
              value: autoDistribute,
              onChanged: (_) =>
                  _snack(context, 'Distribution automatique — à venir'),
            ),
            _RowTile(
              icon: Icons.show_chart,
              label: 'Transactions & payouts',
              onTap: () => _snack(context, 'à venir'),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 5. SECTION GESTION
        _SectionGroup(
          titre: 'Gestion',
          rows: [
            _RowTile(
              icon: Icons.groups_outlined,
              label: 'Mes membres',
              sub: _sousTitreMembres(
                actifs: data.nbMembres,
                enAttente: data.nbDemandesEnAttente,
              ),
              onTap: () => _snack(context, 'à venir'),
            ),
            _RowTile(
              icon: Icons.cloud_upload_outlined,
              label: 'Documents officiels',
              onTap: () => _snack(context, 'à venir'),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 6. SECTION PARAMÈTRES
        _SectionGroup(
          titre: 'Paramètres',
          rows: [
            _RowTile(
              icon: Icons.language,
              label: 'Langue',
              onTap: () => _snack(context, 'à venir'),
            ),
            _RowTile(
              icon: Icons.notifications_none,
              label: 'Notifications',
              onTap: () => _snack(context, 'à venir'),
            ),
            _RowTile(
              icon: Icons.lock_outline,
              label: 'Sécurité (PIN, sessions)',
              onTap: () => _snack(context, 'à venir'),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 7. SECTION AIDE & LÉGAL
        _SectionGroup(
          titre: 'Aide & légal',
          rows: [
            _RowTile(
              icon: Icons.help_outline,
              label: 'Centre d\'aide',
              onTap: () => _snack(context, 'à venir'),
            ),
            _RowTile(
              icon: Icons.description_outlined,
              label: 'Conditions & confidentialité',
              onTap: () => _snack(context, 'à venir'),
            ),
          ],
        ),
        AppDimens.vGap8,

        // 8. BOUTON DÉCONNEXION
        _LogoutButton(
          onTap: () async {
            await ref.read(authStateProvider.notifier).logout();
            if (context.mounted) {
              context.go(RouteNames.bienvenuePath);
            }
          },
        ),

        // 9. FOOTER LÉGAL
        const SizedBox(height: AppDimens.space16),
        const _FooterLegal(),
        const SizedBox(height: AppDimens.space8),
      ],
    );
  }
}

// ─── CARTE IDENTITÉ ──────────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.nom,
    required this.photoUrl,
    required this.nbMembres,
    required this.rating,
    required this.onEdit,
  });

  final String nom;
  final String? photoUrl;
  final int nbMembres;
  final double rating;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrIdentity,
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        children: [
          _PhotoCarree(photoUrl: photoUrl, nom: nom, onEdit: onEdit),
          AppDimens.hGap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _sousLigneCoop(nbMembres, rating),
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
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),
              child: Text(
                'Modifier',
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

class _PhotoCarree extends StatelessWidget {
  const _PhotoCarree({
    required this.photoUrl,
    required this.nom,
    required this.onEdit,
  });

  final String? photoUrl;
  final String nom;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final initiales = _initiales(nom);
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: _kBrPhoto,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? CachedNetworkImage(
                    imageUrl: photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ColoredBox(color: _kPrimarySoft),
                    errorWidget: (_, __, ___) => Center(
                      child: Text(
                        initiales,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      initiales,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: InkWell(
              onTap: onEdit,
              customBorder: const CircleBorder(),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.edit,
                  size: 12,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── STAT CARD (ligne de 3) ──────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _kBrCard,
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SECTION GROUP (titre + group de rows) ───────────────────────────────

class _SectionGroup extends StatelessWidget {
  const _SectionGroup({required this.titre, required this.rows});

  final String titre;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppDimens.space8),
          child: Text(
            titre.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _kBrCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── ROW TILE (icône + label [+ sub] [+ value] + chevron) ────────────────

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.icon,
    required this.label,
    this.iconGreen = false,
    this.sub,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool iconGreen;
  final String? sub;
  final String? value;
  final VoidCallback? onTap;

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
            _RowIcon(icon: icon, green: iconGreen),
            AppDimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                  if (sub != null && sub!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null && value!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
            ] else
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

// ─── ROW TOGGLE (icône + label + sub + switch) ───────────────────────────

class _RowToggle extends StatelessWidget {
  const _RowToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.sub,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: 10,
      ),
      child: Row(
        children: [
          _RowIcon(icon: icon, green: false),
          AppDimens.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                if (sub != null && sub!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ─── ICÔNE DE ROW (carrée, fond pâle, vert si demandé) ───────────────────

class _RowIcon extends StatelessWidget {
  const _RowIcon({required this.icon, required this.green});

  final IconData icon;
  final bool green;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: green ? _kPrimarySoft : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radius),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 18,
        color: green ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

// ─── BOUTON DÉCONNEXION ──────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

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
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            borderRadius: _kBrCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout,
                size: 18,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                'Se déconnecter',
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── FOOTER LÉGAL ────────────────────────────────────────────────────────

class _FooterLegal extends StatelessWidget {
  const _FooterLegal();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            'FarmCash · v1.0.0',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSubtle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Made in Côte d\'Ivoire',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────

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

/// Formate "{nbMembres} membres · ★ {rating}" avec préfixe "Coopérative".
String _sousLigneCoop(int nbMembres, double rating) {
  final ratingTxt = rating > 0
      ? rating.toStringAsFixed(1).replaceAll('.', ',')
      : '—';
  final membresTxt = nbMembres > 1
      ? '$nbMembres membres'
      : '$nbMembres membre';
  return 'Coopérative · $membresTxt · ★ $ratingTxt';
}

/// Sous-titre dynamique "Mes membres" : "{actifs} actifs · {m} demandes en attente".
String _sousTitreMembres({required int actifs, required int enAttente}) {
  final actifTxt = actifs > 1 ? '$actifs actifs' : '$actifs actif';
  if (enAttente <= 0) return actifTxt;
  final dem = enAttente > 1
      ? '$enAttente demandes en attente'
      : '$enAttente demande en attente';
  return '$actifTxt · $dem';
}

/// Formate un montant XOF "fr_FR" + " F".
String _formatMontant(double v) {
  final fmt = NumberFormat('#,##0', 'fr_FR');
  return '${fmt.format(v)} F';
}

/// 2 premières lettres significatives du nom — fallback "?".
String _initiales(String nom) {
  final t = nom.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}
