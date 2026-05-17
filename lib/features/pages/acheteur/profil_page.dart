import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/annonce_achat.dart';
import '../../../models/annonce_vente.dart';
import '../../../models/pagination.dart';
import '../../../models/portefeuille.dart';
import '../../../models/utilisateur.dart';
import '../../../models/wallet_with_transactions.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── COULEURS LOCALES ───────────────────────────────────────────────────

// Fond vert très pâle utilisé sur les "icon chips" verts des sections
// principales (Mon activité, Finance·wallet). Pas dans AppColors car
// usage très local.
const Color _kPrimarySoft = Color(0xFFE8F5E9);

// Radius :
// - cards de groupe : 14 (entre 12 standard et 16 "premium identité")
// - carte d'identité : 16
const BorderRadius _kBrGroup = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrIdentite = BorderRadius.all(Radius.circular(16));

// ─── AGRÉGAT DE DONNÉES ─────────────────────────────────────────────────

/// Données agrégées affichées sur le profil acheteur.
class _ProfilData {
  const _ProfilData({
    required this.user,
    required this.wallet,
    required this.mesDemandes,
    required this.favoris,
  });

  final Utilisateur? user;
  final Portefeuille? wallet;
  final List<AnnonceAchat> mesDemandes;
  final List<AnnonceVente> favoris;

  int get demandesActives => mesDemandes.where((d) => d.isActive).length;

  int get demandesArchivees => mesDemandes.length - demandesActives;
}

/// Provider FutureProvider.autoDispose agrégeant les 3 endpoints réseaux
/// utiles au profil acheteur. Les erreurs unitaires retombent sur des
/// valeurs neutres pour ne pas casser la page si UNE API échoue.
final _profilAcheteurDataProvider =
    FutureProvider.autoDispose<_ProfilData>((ref) async {
  final user = ref.watch(currentUserProvider);
  final marketSvc = ref.watch(marketplaceServiceProvider);
  final financeSvc = ref.watch(financeServiceProvider);

  final results = await Future.wait<Object?>([
    // 0 — wallet
    financeSvc.getWallet(limit: 1).then<Object?>((v) => v).catchError(
          (_) => null,
        ),
    // 1 — mes demandes d'achat (filtrage client-side sur buyerId)
    marketSvc.listAnnoncesAchat(limit: 50).then<Object?>((v) => v).catchError(
          (_) => const Paginated<AnnonceAchat>(
            data: [],
            total: 0,
            page: 1,
            limit: 0,
            totalPages: 0,
          ),
        ),
    // 2 — favoris (annonces de vente sauvegardées)
    marketSvc.listFavoris().then<Object?>((v) => v).catchError(
          (_) => const <AnnonceVente>[],
        ),
  ]);

  final walletRaw = results[0] as WalletWithTransactions?;
  final demandesPage = results[1] as Paginated<AnnonceAchat>;
  final favoris = results[2] as List<AnnonceVente>;

  // Filtre client-side : on ne garde que les demandes de cet utilisateur.
  final mesDemandes = user == null
      ? const <AnnonceAchat>[]
      : demandesPage.data.where((d) => d.buyerId == user.id).toList();

  return _ProfilData(
    user: user,
    wallet: walletRaw?.wallet,
    mesDemandes: mesDemandes,
    favoris: favoris,
  );
});

// ─── PAGE ───────────────────────────────────────────────────────────────

/// Onglet Profil de l'acheteur.
///
/// Reproduction fidèle de `mockups/acheteur_profil.html` :
/// carte identité, mon activité, finance (wallet/moyens/transactions),
/// préférences (favoris/adresses), paramètres, aide & légal, déconnexion.
///
/// Pattern iOS Settings : les rows ne montrent JAMAIS la valeur du champ.
/// Seule exception : le solde wallet à droite + sous-textes dynamiques
/// (X actives · Y archivées, X producteurs sauvegardés).
class ProfilAcheteurPage extends ConsumerWidget {
  const ProfilAcheteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(_profilAcheteurDataProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _AppBar(
              onSettings: () => _showSoon(context, 'Paramètres — à venir'),
            ),
            Expanded(
              child: asyncData.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le profil. $err',
                    onRetry: () =>
                        ref.invalidate(_profilAcheteurDataProvider),
                  ),
                ),
                data: (data) => _ProfilContent(
                  data: data,
                  onRefresh: () async {
                    ref.invalidate(_profilAcheteurDataProvider);
                    await ref.read(_profilAcheteurDataProvider.future);
                  },
                  onLogout: () =>
                      ref.read(authStateProvider.notifier).logout(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showSoon(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─── APP BAR CUSTOM ─────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH - 8,
        AppDimens.space16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mon profil',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              size: AppDimens.iconL,
              color: AppColors.text,
            ),
            onPressed: onSettings,
            tooltip: 'Paramètres',
          ),
        ],
      ),
    );
  }
}

// ─── CONTENU PRINCIPAL ──────────────────────────────────────────────────

class _ProfilContent extends StatelessWidget {
  const _ProfilContent({
    required this.data,
    required this.onRefresh,
    required this.onLogout,
  });

  final _ProfilData data;
  final Future<void> Function() onRefresh;
  final VoidCallback onLogout;

  void _showSoon(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = data.user;

    // Calcul sous-texte "X actives · Y archivées".
    final sousDemandes =
        '${data.demandesActives} active${data.demandesActives > 1 ? 's' : ''}'
        ' · '
        '${data.demandesArchivees} archivée${data.demandesArchivees > 1 ? 's' : ''}';

    // Sous-texte favoris (masqué si 0).
    final nbFav = data.favoris.length;
    final String? sousFavoris = nbFav > 0
        ? '$nbFav producteur${nbFav > 1 ? 's' : ''} sauvegardé${nbFav > 1 ? 's' : ''}'
        : null;

    // Wallet : valeur à droite uniquement si dispo.
    final String? walletTrailing = data.wallet != null
        ? '${NumberFormat('#,##0', 'fr_FR').format(data.wallet!.balance.round())} F'
        : null;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          AppDimens.space16,
          AppDimens.pagePaddingH,
          AppDimens.space16,
        ),
        children: [
          // 2. Carte d'identité
          _CarteIdentite(
            user: user,
            onModifier: () => _showSoon(context, 'Modifier profil — à venir'),
            onEditPhoto: () => _showSoon(context, 'Changer la photo — à venir'),
          ),
          AppDimens.vGap24,

          // 3. Section "Mon activité"
          _SectionGroup(
            title: 'Mon activité',
            children: [
              _RowTile(
                icon: Icons.business_outlined,
                iconGreen: true,
                label: 'Entreprise',
                onTap: () => _showSoon(context, 'Entreprise — à venir'),
              ),
              _RowTile(
                icon: Icons.receipt_long_outlined,
                iconGreen: true,
                label: 'RCCM',
                onTap: () => _showSoon(context, 'RCCM — à venir'),
              ),
              _RowTile(
                icon: Icons.location_on_outlined,
                iconGreen: true,
                label: "Zones d'achat",
                onTap: () => _showSoon(context, "Zones d'achat — à venir"),
              ),
              _RowTile(
                icon: Icons.shopping_cart_outlined,
                iconGreen: true,
                label: "Mes demandes d'achat",
                subtitle: sousDemandes,
                onTap: () => _showSoon(context, 'Mes demandes — à venir'),
              ),
            ],
          ),
          AppDimens.vGap16,

          // 4. Section "Finance"
          _SectionGroup(
            title: 'Finance',
            children: [
              _RowTile(
                icon: Icons.account_balance_wallet_outlined,
                iconGreen: true,
                label: 'Mon wallet',
                trailing: walletTrailing,
                onTap: () => _showSoon(context, 'Wallet — à venir'),
              ),
              _RowTile(
                icon: Icons.credit_card_outlined,
                label: 'Moyens de paiement',
                onTap: () =>
                    _showSoon(context, 'Moyens de paiement — à venir'),
              ),
              _RowTile(
                icon: Icons.show_chart,
                label: 'Mes transactions',
                onTap: () => _showSoon(context, 'Transactions — à venir'),
              ),
            ],
          ),
          AppDimens.vGap16,

          // 5. Section "Préférences"
          _SectionGroup(
            title: 'Préférences',
            children: [
              _RowTile(
                icon: Icons.favorite_border,
                label: 'Mes favoris',
                subtitle: sousFavoris,
                onTap: () => _showSoon(context, 'Favoris — à venir'),
              ),
              _RowTile(
                icon: Icons.location_on_outlined,
                label: 'Adresses de livraison',
                onTap: () => _showSoon(context, 'Adresses — à venir'),
              ),
            ],
          ),
          AppDimens.vGap16,

          // 6. Section "Paramètres"
          _SectionGroup(
            title: 'Paramètres',
            children: [
              _RowTile(
                icon: Icons.language,
                label: 'Langue',
                onTap: () => _showSoon(context, 'Langue — à venir'),
              ),
              _RowTile(
                icon: Icons.notifications_none,
                label: 'Notifications',
                onTap: () => _showSoon(context, 'Notifications — à venir'),
              ),
              _RowTile(
                icon: Icons.lock_outline,
                label: 'Sécurité (PIN, sessions)',
                onTap: () => _showSoon(context, 'Sécurité — à venir'),
              ),
            ],
          ),
          AppDimens.vGap16,

          // 7. Section "Aide & légal"
          _SectionGroup(
            title: 'Aide & légal',
            children: [
              _RowTile(
                icon: Icons.help_outline,
                label: "Centre d'aide",
                onTap: () => _showSoon(context, "Centre d'aide — à venir"),
              ),
              _RowTile(
                icon: Icons.description_outlined,
                label: 'Conditions & confidentialité',
                onTap: () => _showSoon(context, 'Conditions — à venir'),
              ),
            ],
          ),
          AppDimens.vGap16,

          // 8. Bouton "Se déconnecter"
          _BoutonDeconnexion(onTap: onLogout),
          AppDimens.vGap16,

          // 9. Footer légal
          const _FooterLegal(),
          AppDimens.vGap16,
        ],
      ),
    );
  }
}

// ─── CARTE D'IDENTITÉ ───────────────────────────────────────────────────

class _CarteIdentite extends StatelessWidget {
  const _CarteIdentite({
    required this.user,
    required this.onModifier,
    required this.onEditPhoto,
  });

  final Utilisateur? user;
  final VoidCallback onModifier;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    final nom = (user?.fullName?.trim().isNotEmpty ?? false)
        ? user!.fullName!.trim()
        : 'Acheteur';
    final initiales = _initiales(nom);
    final rating = user?.rating ?? 0;
    final ratingTxt = rating > 0 ? rating.toStringAsFixed(1) : '—';
    // L'API utilisateur n'expose pas de champ ville/région — on affiche "—"
    // tant que ce champ n'est pas dispo. Pas de mock data.
    const villeTxt = '—';

    return Container(
      padding: const EdgeInsets.all(AppDimens.space16 + 4), // 20
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrIdentite,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          _PhotoProfil(
            photoUrl: user?.photoUrl,
            initiales: initiales,
            onEdit: onEditPhoto,
          ),
          AppDimens.hGap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Acheteur · $villeTxt · ★ $ratingTxt',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppDimens.hGap8,
          InkWell(
            onTap: onModifier,
            borderRadius: BorderRadius.circular(AppDimens.radiusS),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
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

class _PhotoProfil extends StatelessWidget {
  const _PhotoProfil({
    required this.photoUrl,
    required this.initiales,
    required this.onEdit,
  });

  final String? photoUrl;
  final String initiales;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Photo ronde 72 (CachedNetworkImage si URL, sinon initiales).
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: (photoUrl != null && photoUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: photoUrl!,
                    fit: BoxFit.cover,
                    width: 72,
                    height: 72,
                    placeholder: (_, __) => _Initiales(initiales: initiales),
                    errorWidget: (_, __, ___) =>
                        _Initiales(initiales: initiales),
                  )
                : _Initiales(initiales: initiales),
          ),
          // Badge edit vert 24.
          Positioned(
            right: -2,
            bottom: -2,
            child: GestureDetector(
              onTap: onEdit,
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

class _Initiales extends StatelessWidget {
  const _Initiales({required this.initiales});

  final String initiales;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kPrimarySoft,
      alignment: Alignment.center,
      child: Text(
        initiales,
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
    );
  }
}

// ─── SECTION GROUP ──────────────────────────────────────────────────────

/// Bloc "titre uppercase + carte regroupant des rows".
class _SectionGroup extends StatelessWidget {
  const _SectionGroup({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Titre de section (uppercase, gris secondaire).
        Padding(
          padding: const EdgeInsets.only(
            left: 4,
            right: 4,
            bottom: AppDimens.space8,
          ),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        // Card englobante : bordure, radius 14, fond blanc, pas d'ombre.
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: _kBrGroup,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
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

// ─── ROW TILE (iOS Settings style) ──────────────────────────────────────

/// Row réutilisable : icône à gauche, label (+ sous-titre optionnel),
/// valeur à droite optionnelle (réservée au wallet) et chevron.
class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.iconGreen = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;

  /// Texte affiché à droite. RÉSERVÉ aux quelques cas où le mockup
  /// l'autorise (essentiellement le solde wallet).
  final String? trailing;

  /// Si `true`, l'icône utilise le fond vert pâle + couleur primaire,
  /// sinon le fond surfaceSoft + couleur texte secondaire.
  final bool iconGreen;

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
            // Icône dans un chip carré arrondi.
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconGreen ? _kPrimarySoft : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(AppDimens.radius),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: AppDimens.iconM,
                color: iconGreen ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            AppDimens.hGap12,
            // Label + sous-titre.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Valeur à droite (rare — wallet uniquement).
            if (trailing != null && trailing!.isNotEmpty) ...[
              AppDimens.hGap8,
              Text(
                trailing!,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
            ] else
              AppDimens.hGap8,
            // Chevron.
            const Icon(
              Icons.chevron_right,
              size: AppDimens.iconM,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BOUTON DÉCONNEXION ─────────────────────────────────────────────────

class _BoutonDeconnexion extends StatelessWidget {
  const _BoutonDeconnexion({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: _kBrGroup,
      child: InkWell(
        onTap: onTap,
        borderRadius: _kBrGroup,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
          decoration: BoxDecoration(
            borderRadius: _kBrGroup,
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
                size: AppDimens.iconM,
                color: AppColors.error,
              ),
              AppDimens.hGap8,
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

// ─── FOOTER LÉGAL ───────────────────────────────────────────────────────

class _FooterLegal extends StatelessWidget {
  const _FooterLegal();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'FarmCash · v1.0.0',
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            color: AppColors.textSubtle,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Made in Côte d\'Ivoire',
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            color: AppColors.textSubtle,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── HELPERS ────────────────────────────────────────────────────────────

/// Initiales (1–2 lettres) depuis un nom complet, pour le fallback photo.
String _initiales(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'[\s\-_]+'))
    ..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }
  if (trimmed.length == 1) return trimmed.toUpperCase();
  return trimmed.substring(0, 2).toUpperCase();
}
