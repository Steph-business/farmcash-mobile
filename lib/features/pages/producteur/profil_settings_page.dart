import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/snackbars.dart';

// ─── COULEURS LOCALES ───────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const BorderRadius _kBrGroup = BorderRadius.all(Radius.circular(12));

/// Page Profil & paramètres producteur — distincte de l'onglet `profil_page`.
///
/// Accessible via tap sur l'icône Paramètres (top-level push). Pattern iOS
/// Settings : sections empilées + rows icône/label/chevron, bouton
/// déconnexion rouge, footer version.
class ProfilSettingsProducteurPage extends ConsumerWidget {
  const ProfilSettingsProducteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final nom = user?.fullName?.trim().isNotEmpty == true
        ? user!.fullName!.trim()
        : 'Producteur';

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
                  // 1. Hero — avatar + nom + bouton Modifier
                  _Hero(
                    nom: nom,
                    initials: _initiales(user?.fullName),
                    onModifier: () => context.push(
                      RouteNames.producteurProfilEditerPath,
                    ),
                  ),

                  // 2. Section "Mon compte"
                  const _SectionTitle('Mon compte'),
                  _Group(rows: [
                    _RowTile(
                      icon: Icons.person_outline,
                      iconGreen: true,
                      label: 'Mes informations',
                      sub: 'Nom, téléphone, ville',
                      onTap: () => context.push(
                        RouteNames.producteurProfilEditerPath,
                      ),
                    ),
                    _RowTile(
                      icon: Icons.description_outlined,
                      iconGreen: true,
                      label: 'Documents (KYC)',
                      sub: 'CNI, photos exploitation',
                      onTap: () => context.push(
                        RouteNames.producteurDocumentsKycPath,
                      ),
                    ),
                    _RowTile(
                      icon: Icons.account_balance_wallet_outlined,
                      iconGreen: true,
                      label: 'Wallet',
                      sub: 'Solde et transactions',
                      onTap: () =>
                          context.push(RouteNames.producteurWalletPath),
                    ),
                  ]),
                  AppDimens.vGap24,

                  // 3. Section "Application"
                  const _SectionTitle('Application'),
                  _Group(rows: [
                    _RowTile(
                      icon: Icons.notifications_none,
                      label: 'Notifications',
                      onTap: () => Snackbars.showInfo(
                        context,
                        'Notifications — à venir',
                      ),
                    ),
                    _RowTile(
                      icon: Icons.language,
                      label: 'Langue',
                      sub: 'Français',
                      onTap: () =>
                          Snackbars.showInfo(context, 'Langue — à venir'),
                    ),
                    _RowTile(
                      icon: Icons.lock_outline,
                      label: 'Sécurité (PIN, sessions)',
                      onTap: () =>
                          Snackbars.showInfo(context, 'Sécurité — à venir'),
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
                          context.push(RouteNames.producteurAidePath),
                    ),
                    _RowTile(
                      icon: Icons.description_outlined,
                      label: 'Conditions & confidentialité',
                      onTap: () => Snackbars.showInfo(
                        context,
                        'Conditions & confidentialité — à venir',
                      ),
                    ),
                  ]),
                  AppDimens.vGap24,

                  // 5. Bouton "Se déconnecter"
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
}

String _initiales(String? fullName) {
  if (fullName == null || fullName.trim().isEmpty) return '?';
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
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
                : context.go(RouteNames.producteurProfilPath),
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

// ─── Hero ────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({
    required this.nom,
    required this.initials,
    required this.onModifier,
  });

  final String nom;
  final String initials;
  final VoidCallback onModifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.space8, bottom: 20),
      child: Column(
        children: [
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
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nom,
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
            'Producteur',
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

// ─── Group ───────────────────────────────────────────────────────────────

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

// ─── RowTile ─────────────────────────────────────────────────────────────

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

// ─── Logout ──────────────────────────────────────────────────────────────

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

// ─── Footer ──────────────────────────────────────────────────────────────

class _FooterVersion extends StatelessWidget {
  const _FooterVersion();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'FarmCash · v1.0.0',
        textAlign: TextAlign.center,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          color: AppColors.textSubtle,
        ),
      ),
    );
  }
}
