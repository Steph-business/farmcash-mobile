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
const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarn = Color(0xFFB45309);

// Radius cards des groupes (12 — iOS Settings style).
const BorderRadius _kBrGroup = BorderRadius.all(Radius.circular(12));

// Avatar transporteur — portrait Unsplash conforme à la maquette.
const String _kAvatarUrl =
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
    '?w=300&h=300&fit=crop&auto=format';

// Photo de la vignette du véhicule (Toyota Hilux).
const String _kVehiculeThumbUrl =
    'https://images.unsplash.com/photo-1599045118108-bf9954418b76'
    '?w=200&h=200&fit=crop&auto=format';

// Nom et identité — alignés sur la maquette (transporteur voit FULL ses
// infos personnelles + son client final voit le nom complet conformément
// à la règle 3 du chantier 3).
const String _kNom = 'Yao Brou';
const String _kMeta = 'Camion 3 tonnes · Toyota Hilux 2018 · 2345 AB 01';

/// Page Profil & paramètres transporteur — distincte de l'onglet `profil_page`.
///
/// Accessible via tap sur l'avatar du header (top-level push). Pattern
/// iOS Settings : hero avatar + sections empilées + rows icône/label/chevron,
/// bouton déconnexion rouge, footer version.
///
/// Reproduction fidèle de `mockups/transporteur/profil_settings.html`.
class ProfilSettingsTransporteurPage extends ConsumerWidget {
  const ProfilSettingsTransporteurPage({super.key});

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
                  // 1. Hero — avatar + nom + meta + rating + bouton Modifier
                  _Hero(
                    onModifier: () =>
                        _showSoon(context, 'Modifier le profil — à venir'),
                  ),

                  // 2. Section "Mes véhicules"
                  const _SectionTitle('Mes véhicules'),
                  _Group(rows: [
                    _VehiculeRow(
                      photoUrl: _kVehiculeThumbUrl,
                      titre: 'Toyota Hilux',
                      sous: '1 200 kg utiles · 2345 AB 01',
                      onTap: () =>
                          _showSoon(context, 'Détail véhicule — à venir'),
                    ),
                    _AddRow(
                      label: 'Ajouter un véhicule',
                      onTap: () => _showSoon(
                        context,
                        'Ajouter un véhicule — à venir',
                      ),
                    ),
                  ]),
                  AppDimens.vGap24,

                  // 3. Section "Mes documents"
                  const _SectionTitle('Mes documents'),
                  _Group(rows: [
                    _DocRow(
                      icon: Icons.description_outlined,
                      label: 'Carte grise',
                      chipLabel: 'Validée',
                      chipKind: _ChipKind.ok,
                      onTap: () =>
                          _showSoon(context, 'Carte grise — à venir'),
                    ),
                    _DocRow(
                      icon: Icons.credit_card_outlined,
                      label: 'Permis de conduire',
                      chipLabel: 'Validée',
                      chipKind: _ChipKind.ok,
                      onTap: () =>
                          _showSoon(context, 'Permis — à venir'),
                    ),
                    _DocRow(
                      icon: Icons.shield_outlined,
                      label: 'Assurance véhicule',
                      chipLabel: 'Expire dans 23j',
                      chipKind: _ChipKind.warn,
                      onTap: () =>
                          _showSoon(context, 'Assurance — à venir'),
                    ),
                  ]),
                  AppDimens.vGap24,

                  // 4. Section "Mon compte"
                  const _SectionTitle('Mon compte'),
                  _Group(rows: [
                    _RowTile(
                      icon: Icons.account_balance_wallet_outlined,
                      iconGreen: true,
                      label: 'Wallet',
                      onTap: () =>
                          _showSoon(context, 'Wallet — à venir'),
                    ),
                    _RowTile(
                      icon: Icons.credit_card_outlined,
                      label: 'Informations bancaires',
                      onTap: () => _showSoon(
                        context,
                        'Informations bancaires — à venir',
                      ),
                    ),
                    _RowTile(
                      icon: Icons.place_outlined,
                      label: 'Zones de couverture',
                      onTap: () =>
                          _showSoon(context, 'Zones de couverture — à venir'),
                    ),
                  ]),
                  AppDimens.vGap24,

                  // 5. Section "Application"
                  const _SectionTitle('Application'),
                  _Group(rows: [
                    _RowTile(
                      icon: Icons.notifications_none,
                      label: 'Notifications',
                      onTap: () => context.push(
                        RouteNames.transporteurNotificationsPath,
                      ),
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

                  // 6. Section "Support"
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
                      label: 'Contact',
                      onTap: () =>
                          _showSoon(context, 'Contact — à venir'),
                    ),
                    _RowTile(
                      icon: Icons.description_outlined,
                      label: 'CGU',
                      onTap: () => _showSoon(context, 'CGU — à venir'),
                    ),
                  ]),
                  AppDimens.vGap24,

                  // 7. Bouton "Se déconnecter" (texte rouge centré)
                  _LogoutButton(
                    onTap: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) {
                        context.go(RouteNames.bienvenuePath);
                      }
                    },
                  ),
                  AppDimens.vGap16,

                  // 8. Footer version
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
                : context.go(RouteNames.accueilTransporteurPath),
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

// ─── Hero : avatar + nom + meta + rating + bouton "Modifier" ────────────

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
              placeholder: (_, _) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, _, _) => Center(
                child: Text(
                  'YB',
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
            _kMeta,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '★ 4.8',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '·',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '142 livraisons',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
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
                'Modifier',
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
    this.iconGreen = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
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
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

// ─── Vehicule row (photo 60×60 + texte + bouton "Voir") ─────────────────

class _VehiculeRow extends StatelessWidget {
  const _VehiculeRow({
    required this.photoUrl,
    required this.titre,
    required this.sous,
    required this.onTap,
  });

  final String photoUrl;
  final String titre;
  final String sous;
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => const ColoredBox(color: _kPrimarySoft),
                errorWidget: (_, _, _) =>
                    const ColoredBox(color: _kPrimarySoft),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sous,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Voir',
              style: AppTextStyles.link.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add row (lien vert "+ Ajouter un véhicule") ────────────────────────

class _AddRow extends StatelessWidget {
  const _AddRow({required this.label, required this.onTap});

  final String label;
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
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Doc row (icône + label + chip statut) ──────────────────────────────

enum _ChipKind { ok, warn }

class _DocRow extends StatelessWidget {
  const _DocRow({
    required this.icon,
    required this.label,
    required this.chipLabel,
    required this.chipKind,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String chipLabel;
  final _ChipKind chipKind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (chipBg, chipFg) = switch (chipKind) {
      _ChipKind.ok => (_kPrimarySoft, AppColors.primary),
      _ChipKind.warn => (_kWarnSoft, _kWarn),
    };
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
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: chipBg, width: AppDimens.borderThin),
              ),
              child: Text(
                chipLabel,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: chipFg,
                ),
              ),
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

