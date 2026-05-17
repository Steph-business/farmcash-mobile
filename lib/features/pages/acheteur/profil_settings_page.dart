import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';

// ─── COULEURS LOCALES ───────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// Radius cards des groupes (12 — iOS Settings style).
const BorderRadius _kBrGroup = BorderRadius.all(Radius.circular(12));

// Avatar acheteur (portrait Unsplash conforme à la maquette).
const String _kAvatarUrl =
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2'
    '?w=300&h=300&fit=crop&auto=format';

// Nom acheteur — TRONQUÉ « Marie Y. » partout (anti-contournement spec).
const String _kNom = 'Marie Y.';

/// Page Profil & paramètres acheteur — distincte de l'onglet `profil_page`.
///
/// Accessible via tap sur l'avatar du header (top-level push). Pattern
/// iOS Settings : sections empilées + rows icône/label/chevron, bouton
/// déconnexion rouge, footer version.
///
/// Reproduction fidèle de `mockups/acheteur/profil_settings.html`.
class ProfilSettingsAcheteurPage extends ConsumerWidget {
  const ProfilSettingsAcheteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: [
                  // 1. Hero — avatar + nom tronqué + meta + bouton Modifier
                  _Hero(
                    onModifier: () =>
                        _showSoon(context, 'Modifier le profil — à venir'),
                  ),

                  // 2. Section "Mon compte"
                  const _SectionTitle('Mon compte'),
                  _Group(rows: [
                    _RowTile(
                      icon: Icons.description_outlined,
                      iconGreen: true,
                      label: 'Informations légales',
                      sub: 'IFU & justificatifs',
                      onTap: () => _showSoon(
                        context,
                        'Informations légales — à venir',
                      ),
                    ),
                    _RowTile(
                      icon: Icons.location_on_outlined,
                      iconGreen: true,
                      label: 'Adresses de livraison',
                      sub: '2 adresses enregistrées',
                      onTap: () =>
                          _showSoon(context, 'Adresses — à venir'),
                    ),
                    _RowTile(
                      icon: Icons.account_balance_wallet_outlined,
                      iconGreen: true,
                      label: 'Wallet',
                      sub: '245 800 F · 175 000 F en escrow',
                      onTap: () =>
                          context.push(RouteNames.acheteurWalletPath),
                    ),
                  ]),
                  AppDimens.vGap24,

                  // 3. Section "Application"
                  const _SectionTitle('Application'),
                  _Group(rows: [
                    _RowTile(
                      icon: Icons.notifications_none,
                      label: 'Notifications',
                      onTap: () =>
                          _showSoon(context, 'Notifications — à venir'),
                    ),
                    _RowTile(
                      icon: Icons.language,
                      label: 'Langue',
                      onTap: () => _showSoon(context, 'Langue — à venir'),
                    ),
                    _RowTile(
                      icon: Icons.dark_mode_outlined,
                      label: 'Apparence',
                      onTap: () =>
                          _showSoon(context, 'Apparence — à venir'),
                    ),
                  ]),
                  AppDimens.vGap24,

                  // 4. Section "Support"
                  const _SectionTitle('Support'),
                  _Group(rows: [
                    _RowTile(
                      icon: Icons.help_outline,
                      label: "Centre d'aide",
                      onTap: () =>
                          _showSoon(context, "Centre d'aide — à venir"),
                    ),
                    _RowTile(
                      icon: Icons.chat_outlined,
                      label: "Contacter l'équipe FarmCash",
                      onTap: () =>
                          _showSoon(context, 'Contact — à venir'),
                    ),
                    _RowTile(
                      icon: Icons.description_outlined,
                      label: 'Conditions & confidentialité',
                      onTap: () =>
                          _showSoon(context, 'Conditions — à venir'),
                    ),
                  ]),
                  AppDimens.vGap24,

                  // 5. Bouton "Se déconnecter" (texte rouge centré)
                  _LogoutButton(
                    onTap: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) {
                        context.go(RouteNames.bienvenuePath);
                      }
                    },
                  ),
                  AppDimens.vGap16,

                  // 6. Footer version
                  const _FooterVersion(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showSoon(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.acheteurProfilPath),
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
              'Profil & paramètres',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}

// ─── Hero : avatar + nom + meta + bouton "Modifier le profil" ───────────

class _Hero extends StatelessWidget {
  const _Hero({required this.onModifier});

  final VoidCallback onModifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.space8, bottom: 20),
      child: Column(
        children: [
          // Avatar rond 88 (portrait Unsplash).
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: _kAvatarUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, __, ___) => Center(
                child: Text(
                  'MY',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _kNom,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Restaurant Le Baoulé · Cocody',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'membre depuis fév 2026',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onModifier,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                'Modifier le profil',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section title ───────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
        right: 4,
        bottom: 6,
        top: AppDimens.space12,
      ),
      child: Text(
        label,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }
}

// ─── Group (card englobante avec divider entre rows) ────────────────────

class _Group extends StatelessWidget {
  const _Group({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

// ─── RowTile (iOS Settings style — icône carrée + label + sub + chevron) ─

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.icon,
    required this.label,
    this.sub,
    this.iconGreen = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? sub;
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconGreen ? _kPrimarySoft : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 18,
                color: iconGreen ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            AppDimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sub != null && sub!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
      ),
    );
  }
}

// ─── Bouton "Se déconnecter" (texte rouge centré, bordure rouge) ────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: _kBrGroup,
            border: Border.all(
              color: AppColors.error,
              width: AppDimens.borderThin,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'Se déconnecter',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Footer version ──────────────────────────────────────────────────────

class _FooterVersion extends StatelessWidget {
  const _FooterVersion();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'FarmCash mobile · v0.4.2',
        textAlign: TextAlign.center,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          color: AppColors.textSubtle,
        ),
      ),
    );
  }
}

