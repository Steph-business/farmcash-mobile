import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/annonce_vente.dart';
import '../../../models/cooperative.dart';
import '../../../models/enums.dart';
import '../../../models/parcelle.dart';
import '../../../models/portefeuille.dart';
import '../../../models/produit.dart';
import '../../../models/utilisateur.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── Modèle de données agrégées ────────────────────────────────────────

class _ProfilData {
  const _ProfilData({
    required this.wallet,
    required this.parcelles,
    required this.produits,
    required this.mesAnnonces,
    required this.coopInfo,
  });

  final Portefeuille? wallet;
  final List<Parcelle> parcelles;
  final List<Produit> produits;
  final List<AnnonceVente> mesAnnonces;
  final Cooperative? coopInfo;
}

/// Charge en parallèle toutes les données nécessaires au profil producteur.
/// Chaque appel est tolérant : un échec ponctuel retourne `null`/liste vide
/// et la section concernée se masque ou affiche un fallback.
final _profilProducteurDataProvider =
    FutureProvider.autoDispose<_ProfilData>((ref) async {
  final marketplace = ref.watch(marketplaceServiceProvider);
  final finance = ref.watch(financeServiceProvider);
  final cooperatives = ref.watch(cooperativesServiceProvider);
  final user = ref.watch(currentUserProvider);
  final coopId = user?.cooperativeId;

  final results = await Future.wait<dynamic>([
    // 0 — wallet
    finance.getWallet().then<Object?>((v) => v).catchError((_) => null),
    // 1 — parcelles
    marketplace
        .listParcelles()
        .then<Object?>((v) => v)
        .catchError((_) => <Parcelle>[]),
    // 2 — catalogue produits (pour résoudre les noms des cultures)
    marketplace
        .listProduits()
        .then<Object?>((v) => v)
        .catchError((_) => <Produit>[]),
    // 3 — annonces (filtrées client-side sur farmerId)
    marketplace
        .listAnnoncesVente(limit: 50)
        .then<Object?>((v) => v)
        .catchError((_) => null),
    // 4 — info coopérative si l'utilisateur est membre
    if (coopId != null && coopId.isNotEmpty)
      cooperatives
          .getPublic(coopId)
          .then<Object?>((v) => v)
          .catchError((_) => null),
  ]);

  final walletBundle = results[0];
  final parcelles = (results[1] as List<Parcelle>?) ?? const <Parcelle>[];
  final produits = (results[2] as List<Produit>?) ?? const <Produit>[];
  final annoncesRaw = results[3];
  final coopInfo = (coopId != null && coopId.isNotEmpty)
      ? results[4] as Cooperative?
      : null;

  // Filtrage client-side des annonces sur l'utilisateur courant.
  final farmerId = user?.id;
  final List<AnnonceVente> mesAnnonces = [];
  if (annoncesRaw != null && farmerId != null) {
    try {
      final data = (annoncesRaw as dynamic).data as List;
      for (final a in data) {
        if (a is AnnonceVente && a.farmerId == farmerId) {
          mesAnnonces.add(a);
        }
      }
    } catch (_) {
      // payload inattendu — on garde la liste vide
    }
  }

  return _ProfilData(
    wallet: walletBundle == null
        ? null
        : (walletBundle as dynamic).wallet as Portefeuille?,
    parcelles: parcelles,
    produits: produits,
    mesAnnonces: mesAnnonces,
    coopInfo: coopInfo,
  );
});

// ─── Page principale ───────────────────────────────────────────────────

/// Onglet Profil du producteur — pattern iOS Settings : chaque row est un
/// label + chevron, on tape pour ouvrir le détail (SnackBar pour V1).
/// Seule exception : le solde wallet montre le montant à droite.
class ProfilProducteurPage extends ConsumerWidget {
  const ProfilProducteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final async = ref.watch(_profilProducteurDataProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              onSettings: () => Snackbars.showInfo(
                context,
                'Paramètres — à venir',
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Chargement(size: 22),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.space16),
                  child: VueErreur(
                    message:
                        'Impossible de charger votre profil. $err',
                    onRetry: () =>
                        ref.invalidate(_profilProducteurDataProvider),
                  ),
                ),
                data: (data) => _ProfilContent(user: user, data: data),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar custom ────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mon profil',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          InkWell(
            onTap: onSettings,
            borderRadius: BorderRadius.circular(18),
            child: const Padding(
              padding: EdgeInsets.all(7),
              child: Icon(
                Icons.settings_outlined,
                size: 22,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contenu principal scrollable ──────────────────────────────────────

class _ProfilContent extends ConsumerWidget {
  const _ProfilContent({required this.user, required this.data});

  final Utilisateur? user;
  final _ProfilData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        // 2 — Carte d'identité
        _IdentityCard(
          user: user,
          onEdit: () =>
              Snackbars.showInfo(context, 'Modifier mon profil — à venir'),
          onEditPhoto: () =>
              Snackbars.showInfo(context, 'Modifier la photo — à venir'),
        ),

        const SizedBox(height: AppDimens.space24),

        // 3 — Mon exploitation
        _SectionGroup(
          title: 'Mon exploitation',
          children: [
            _RowTile(
              icon: Icons.grass_outlined,
              iconGreen: true,
              label: 'Mes parcelles & cultures',
              subtitle: _subTexteParcelles(data.parcelles),
              onTap: () =>
                  context.push(RouteNames.producteurMesParcellesPath),
            ),
            _RowTile(
              icon: Icons.eco_outlined,
              iconGreen: true,
              label: 'Cultures principales',
              subtitle: _subTexteCultures(data.parcelles, data.produits),
              onTap: () => Snackbars.showInfo(
                context,
                'Cultures principales — à venir',
              ),
            ),
            _RowTile(
              icon: Icons.groups_outlined,
              iconGreen: true,
              label: 'Ma coopérative',
              subtitle: _subTexteCoop(data.coopInfo),
              onTap: () => Snackbars.showInfo(
                context,
                data.coopInfo == null
                    ? 'Rejoindre une coopérative — à venir'
                    : 'Page coopérative — à venir',
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimens.space24),

        // 4 — Finance
        _SectionGroup(
          title: 'Finance',
          children: [
            _RowTile(
              icon: Icons.account_balance_wallet_outlined,
              iconGreen: true,
              label: 'Mon wallet',
              trailingText: _formatMontant(data.wallet?.balance ?? 0),
              onTap: () =>
                  Snackbars.showInfo(context, 'Mon wallet — à venir'),
            ),
            _RowTile(
              icon: Icons.credit_card_outlined,
              label: 'Moyens de paiement',
              onTap: () => Snackbars.showInfo(
                context,
                'Moyens de paiement — à venir',
              ),
            ),
            _RowTile(
              icon: Icons.show_chart,
              label: 'Mes transactions',
              onTap: () =>
                  Snackbars.showInfo(context, 'Mes transactions — à venir'),
            ),
          ],
        ),

        const SizedBox(height: AppDimens.space24),

        // 5 — Activité
        _SectionGroup(
          title: 'Activité',
          children: [
            _RowTile(
              icon: Icons.list_alt_outlined,
              label: 'Mes annonces',
              subtitle: _subTexteAnnonces(data.mesAnnonces),
              onTap: () =>
                  Snackbars.showInfo(context, 'Mes annonces — à venir'),
            ),
            _RowTile(
              icon: Icons.cloud_upload_outlined,
              label: 'Documents (KYC)',
              subtitle: 'À compléter',
              onTap: () =>
                  Snackbars.showInfo(context, 'Documents KYC — à venir'),
            ),
          ],
        ),

        const SizedBox(height: AppDimens.space24),

        // 6 — Paramètres
        _SectionGroup(
          title: 'Paramètres',
          children: [
            _RowTile(
              icon: Icons.language,
              label: 'Langue',
              trailingText: 'Français',
              onTap: () => Snackbars.showInfo(context, 'Langue — à venir'),
            ),
            _RowTile(
              icon: Icons.notifications_none,
              label: 'Notifications',
              onTap: () =>
                  Snackbars.showInfo(context, 'Notifications — à venir'),
            ),
            _RowTile(
              icon: Icons.lock_outline,
              label: 'Sécurité (PIN, sessions)',
              onTap: () => Snackbars.showInfo(context, 'Sécurité — à venir'),
            ),
          ],
        ),

        const SizedBox(height: AppDimens.space24),

        // 7 — Aide & légal
        _SectionGroup(
          title: 'Aide & légal',
          children: [
            _RowTile(
              icon: Icons.help_outline,
              label: "Centre d'aide",
              onTap: () =>
                  Snackbars.showInfo(context, "Centre d'aide — à venir"),
            ),
            _RowTile(
              icon: Icons.description_outlined,
              label: 'Conditions & confidentialité',
              onTap: () => Snackbars.showInfo(
                context,
                'Conditions & confidentialité — à venir',
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimens.space12),

        // 8 — Bouton déconnexion
        _LogoutButton(
          onTap: () => ref.read(authStateProvider.notifier).logout(),
        ),

        const SizedBox(height: AppDimens.space16),

        // 9 — Légal footer
        Center(
          child: Column(
            children: [
              Text(
                'FarmCash · v1.0.0',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSubtle,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Made in Côte d’Ivoire',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSubtle,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimens.space16),
      ],
    );
  }
}

// ─── Carte d'identité ──────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.user,
    required this.onEdit,
    required this.onEditPhoto,
  });

  final Utilisateur? user;
  final VoidCallback onEdit;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    final nom = user?.fullName?.trim().isNotEmpty == true
        ? user!.fullName!.trim()
        : 'Producteur';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Photo(
            photoUrl: user?.photoUrl,
            initials: _initiales(user?.fullName),
            onEdit: onEditPhoto,
          ),
          const SizedBox(width: AppDimens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _RoleLigne(rating: user?.rating ?? 0),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.space8),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              child: Text(
                'Modifier',
                style: AppTextStyles.link.copyWith(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({
    required this.photoUrl,
    required this.initials,
    required this.onEdit,
  });

  final String? photoUrl;
  final String initials;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
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
              shape: BoxShape.circle,
              color: const Color(0xFFE8F5E9),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: photoUrl != null && photoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _Initiales(initials: initials),
                    errorWidget: (_, __, ___) =>
                        _Initiales(initials: initials),
                  )
                : _Initiales(initials: initials),
          ),
          Positioned(
            bottom: -2,
            right: -2,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Initiales extends StatelessWidget {
  const _Initiales({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8F5E9),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
    );
  }
}

class _RoleLigne extends StatelessWidget {
  const _RoleLigne({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final segments = <String>['Producteur', '—'];
    final hasRating = rating > 0;
    if (hasRating) {
      segments.add('★ ${rating.toStringAsFixed(1)}');
    }

    final children = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) {
        children.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: _Dot(),
        ));
      }
      children.add(Flexible(
        child: Text(
          segments[i],
          style: AppTextStyles.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textSubtle,
      ),
    );
  }
}

// ─── Sections (titre + groupe de rows) ─────────────────────────────────

class _SectionGroup extends StatelessWidget {
  const _SectionGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Intercale des dividers 1px entre les rows.
    final withDividers = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      withDividers.add(children[i]);
      if (i < children.length - 1) {
        withDividers.add(const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.border,
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            4,
            0,
            4,
            AppDimens.space8,
          ),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: withDividers),
        ),
      ],
    );
  }
}

// ─── Row tile (icône + label + sous-texte? + trailing? + chevron) ──────

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailingText,
    this.iconGreen = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? trailingText;
  final bool iconGreen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasSub = subtitle != null && subtitle!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: 14,
        ),
        child: Row(
          children: [
            _RowIcon(icon: icon, isGreen: iconGreen),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasSub) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: AppDimens.space8),
              Text(
                trailingText!,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
              ),
              const SizedBox(width: 6),
            ],
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

class _RowIcon extends StatelessWidget {
  const _RowIcon({required this.icon, required this.isGreen});

  final IconData icon;
  final bool isGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isGreen ? const Color(0xFFE8F5E9) : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 18,
        color: isGreen ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

// ─── Bouton "Se déconnecter" ───────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout,
              size: 18,
              color: AppColors.error,
            ),
            const SizedBox(width: AppDimens.space8),
            Text(
              'Se déconnecter',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers locaux ────────────────────────────────────────────────────

String _initiales(String? fullName) {
  if (fullName == null || fullName.trim().isEmpty) return '?';
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

String _formatMontant(double value) {
  final f = NumberFormat('#,##0', 'fr_FR');
  return '${f.format(value)} F';
}

/// Mois abrégé "janv. 2026" sans dépendre de `initializeDateFormatting`.
String _formatMois(DateTime date) {
  const mois = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
  final idx = (date.month - 1).clamp(0, 11);
  return '${mois[idx]} ${date.year}';
}

/// Sous-texte "X parcelles · Y ha" (retourne `null` si liste vide).
String? _subTexteParcelles(List<Parcelle> parcelles) {
  if (parcelles.isEmpty) return null;
  final nb = parcelles.length;
  final total = parcelles.fold<double>(
    0,
    (acc, p) => acc + (p.superficieHa ?? 0),
  );
  final labelNb = nb > 1 ? 'parcelles' : 'parcelle';
  if (total <= 0) return '$nb $labelNb';
  // Formate l'hectare sans décimale si entier, sinon 1 décimale.
  final ha = (total - total.truncate()).abs() < 0.05
      ? total.toStringAsFixed(0)
      : total.toStringAsFixed(1);
  return '$nb $labelNb · $ha ha';
}

/// Sous-texte cultures principales : noms uniques des produits cultivés
/// dans les parcelles, max 3 — résolus depuis le catalogue.
String? _subTexteCultures(List<Parcelle> parcelles, List<Produit> produits) {
  if (parcelles.isEmpty) return null;
  final byId = {for (final p in produits) p.id: p.nom};
  final noms = <String>{};
  for (final parc in parcelles) {
    final pid = parc.produitId;
    if (pid == null || pid.isEmpty) continue;
    final nom = byId[pid];
    if (nom != null && nom.isNotEmpty) noms.add(nom);
  }
  if (noms.isEmpty) return 'Aucune renseignée';
  final liste = noms.take(3).join(', ');
  return liste;
}

/// Sous-texte coop : "{nom} · membre depuis {mois}" si l'utilisateur a une
/// coopérative renseignée ; sinon "Aucune coopérative".
String _subTexteCoop(Cooperative? coop) {
  if (coop == null) return 'Aucune coopérative';
  final dateMembre = coop.createdAt;
  if (dateMembre == null) return coop.nom;
  return '${coop.nom} · membre depuis ${_formatMois(dateMembre)}';
}

/// Sous-texte annonces : "X actives · Y archivées".
String? _subTexteAnnonces(List<AnnonceVente> annonces) {
  if (annonces.isEmpty) return null;
  final actives =
      annonces.where((a) => a.status == ProductStatus.active).length;
  final archives = annonces.where((a) {
    return a.status == ProductStatus.sold ||
        a.status == ProductStatus.expired ||
        a.status == ProductStatus.paused;
  }).length;
  return '$actives actives · $archives archivées';
}
