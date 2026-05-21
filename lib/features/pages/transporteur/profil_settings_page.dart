import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/utilisateur.dart';
import '../../../models/vehicle.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';

// ─── COULEURS LOCALES ───────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// Radius cards des groupes (12 — iOS Settings style).
const BorderRadius _kBrGroup = BorderRadius.all(Radius.circular(12));

/// Bundle léger pour le sous-titre du hero (solde wallet + nb véhicules).
class _ProfilExtras {
  const _ProfilExtras({required this.solde, required this.vehicules});
  final double? solde;
  final List<Vehicle> vehicules;
}

final _profilExtrasProvider =
    FutureProvider.autoDispose<_ProfilExtras>((ref) async {
  final logistics = ref.watch(logisticsServiceProvider);
  final finance = ref.watch(financeServiceProvider);
  final results = await Future.wait<dynamic>([
    logistics
        .listMyVehicles()
        .then<Object?>((v) => v)
        .catchError((_) => <Vehicle>[]),
    finance.getWallet().then<Object?>((v) => v).catchError((_) => null),
  ]);
  final vehicules = (results[0] as List<Vehicle>?) ?? const <Vehicle>[];
  final walletBundle = results[1];
  final double? solde = walletBundle == null
      ? null
      : ((walletBundle as dynamic).wallet.balance as double);
  return _ProfilExtras(solde: solde, vehicules: vehicules);
});

/// Page Profil & paramètres transporteur — distincte de l'onglet `profil_page`.
///
/// Accessible via tap sur l'avatar du header (top-level push). Pattern
/// iOS Settings : hero avatar + sections empilées + rows icône/label/chevron,
/// bouton déconnexion rouge, footer version.
class ProfilSettingsTransporteurPage extends ConsumerWidget {
  const ProfilSettingsTransporteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final extrasAsync = ref.watch(_profilExtrasProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => ref.invalidate(_profilExtrasProvider),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePaddingH,
                    0,
                    AppDimens.pagePaddingH,
                    AppDimens.space24,
                  ),
                  children: [
                    // 1. Hero — avatar + nom + meta + rating
                    _Hero(user: user, extras: extrasAsync.value),

                    // 2. Section "Mes véhicules" (liste compacte)
                    const _SectionTitle('Mes véhicules'),
                    _Group(rows: _vehiculesRows(context, extrasAsync.value)),
                    AppDimens.vGap24,

                    // 3. Section "Mon activité"
                    const _SectionTitle('Mon activité'),
                    _Group(rows: [
                      _RowTile(
                        icon: Icons.alt_route,
                        label: 'Mes itinéraires',
                        onTap: () => context.push(
                          RouteNames.transporteurItinerairesPath,
                        ),
                      ),
                      _RowTile(
                        icon: Icons.history,
                        label: 'Historique des missions',
                        onTap: () => context.push(
                          RouteNames.transporteurMissionsHistoriquePath,
                        ),
                      ),
                    ]),
                    AppDimens.vGap24,

                    // 4. Section "Mon compte"
                    const _SectionTitle('Mon compte'),
                    _Group(rows: [
                      _RowTile(
                        icon: Icons.account_balance_wallet_outlined,
                        iconGreen: true,
                        label: extrasAsync.value?.solde != null
                            ? 'Wallet · ${_nf.format(extrasAsync.value!.solde!.round())} F'
                            : 'Wallet',
                        onTap: () =>
                            context.push(RouteNames.transporteurWalletPath),
                      ),
                      _RowTile(
                        icon: Icons.receipt_long_outlined,
                        label: 'Mes transactions',
                        onTap: () => context.push(
                          RouteNames.transporteurTransactionsPath,
                        ),
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
                    ]),
                    AppDimens.vGap24,

                    // 6. Bouton "Se déconnecter"
                    _LogoutButton(
                      onTap: () async {
                        await ref.read(authStateProvider.notifier).logout();
                        if (context.mounted) {
                          context.go(RouteNames.bienvenuePath);
                        }
                      },
                    ),
                    AppDimens.vGap16,

                    const _FooterVersion(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _vehiculesRows(BuildContext context, _ProfilExtras? extras) {
    final vehicules = extras?.vehicules ?? const <Vehicle>[];
    final rows = <Widget>[];
    for (final v in vehicules.take(2)) {
      rows.add(_VehiculeRow(
        vehicule: v,
        onTap: () =>
            context.push(RouteNames.transporteurMesVehiculesPath),
      ));
    }
    rows.add(_AddRow(
      label: vehicules.isEmpty
          ? 'Ajouter mon premier véhicule'
          : 'Voir / ajouter un véhicule',
      onTap: () => context.push(
        vehicules.isEmpty
            ? RouteNames.transporteurVehiculeCreerPath
            : RouteNames.transporteurMesVehiculesPath,
      ),
    ));
    return rows;
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

// ─── Hero : avatar + nom + meta + rating ────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.user, required this.extras});

  final Utilisateur? user;
  final _ProfilExtras? extras;

  @override
  Widget build(BuildContext context) {
    final nom = user?.fullName?.trim().isNotEmpty == true
        ? user!.fullName!.trim()
        : (user?.phone ?? 'Transporteur');
    final rating = user?.rating ?? 0;
    final photoUrl = user?.photoUrl;
    final vehicules = extras?.vehicules ?? const <Vehicle>[];
    final meta = vehicules.isEmpty
        ? 'Aucun véhicule enregistré'
        : vehicules
            .take(2)
            .map((v) => v.marque?.trim().isNotEmpty == true
                ? v.marque!.trim()
                : (v.type.isNotEmpty ? v.type : 'Véhicule'))
            .join(' · ');

    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.space8, bottom: 20),
      child: Column(
        children: [
          // Avatar rond 88
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
            child: photoUrl != null && photoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: _kPrimarySoft),
                    errorWidget: (_, _, _) => _Initiales(nom: nom),
                  )
                : _Initiales(nom: nom),
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
            meta,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (rating > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '★ ${rating.toStringAsFixed(1).replaceAll('.', ',')}',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Initiales extends StatelessWidget {
  const _Initiales({required this.nom});
  final String nom;
  @override
  Widget build(BuildContext context) {
    final initiales = _toInitiales(nom);
    return Center(
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

  String _toInitiales(String n) {
    final parts = n.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final first = parts.first;
      return first.isEmpty ? '?' : first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
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

// ─── Group ──────────────────────────────────────────────────────────────

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

// ─── RowTile ────────────────────────────────────────────────────────────

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

// ─── Vehicule row (vraies données du véhicule) ──────────────────────────

class _VehiculeRow extends StatelessWidget {
  const _VehiculeRow({required this.vehicule, required this.onTap});

  final Vehicle vehicule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titre = vehicule.marque?.trim().isNotEmpty == true
        ? vehicule.marque!.trim()
        : (vehicule.type.isNotEmpty ? vehicule.type : 'Véhicule');
    final sous = [
      if (vehicule.chargeMaxKg > 0)
        '${_nf.format(vehicule.chargeMaxKg.round())} kg utiles',
      if (vehicule.immatriculation?.trim().isNotEmpty == true)
        vehicule.immatriculation!.trim(),
    ].join(' · ');
    final photo = vehicule.photoUrl;
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
              child: photo != null && photo.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photo,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: _kPrimarySoft),
                      errorWidget: (_, _, _) => const Icon(
                        Icons.local_shipping_outlined,
                        size: 22,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.local_shipping_outlined,
                      size: 22,
                      color: AppColors.primary,
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
                  if (sous.isNotEmpty) ...[
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

// ─── Add row ────────────────────────────────────────────────────────────

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

// ─── Bouton "Se déconnecter" ────────────────────────────────────────────

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

final _nf = NumberFormat('#,##0', 'fr_FR');
