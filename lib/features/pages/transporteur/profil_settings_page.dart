import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/vehicle.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/profil_settings/bouton_deconnexion.dart';
import '../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../widgets/communs/profil_settings/groupe_settings.dart';
import '../../widgets/communs/profil_settings/hero_identite.dart';
import '../../widgets/communs/profil_settings/pied_version.dart';
import '../../widgets/communs/profil_settings/titre_section_settings.dart';
import '../../widgets/communs/profil_settings/tuile_settings.dart';

final _nf = NumberFormat('#,##0', 'fr_FR');

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
  /// Construit la page.
  const ProfilSettingsTransporteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final extrasAsync = ref.watch(_profilExtrasProvider);
    final extras = extrasAsync.value;
    final nom = user?.fullName?.trim().isNotEmpty == true
        ? user!.fullName!.trim()
        : (user?.phone ?? 'Transporteur');
    final vehicules = extras?.vehicules ?? const <Vehicle>[];
    final meta = vehicules.isEmpty
        ? 'Aucun véhicule enregistré'
        : vehicules
            .take(2)
            .map((v) => v.marque?.trim().isNotEmpty == true
                ? v.marque!.trim()
                : (v.type.isNotEmpty ? v.type : 'Véhicule'))
            .join(' · ');
    final rating = user?.rating ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteProfilSettings(
              fallbackPath: RouteNames.accueilTransporteurPath,
            ),
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
                    HeroIdentite(
                      nom: nom,
                      initiales: initialesDepuisNom(nom),
                      photoUrl: user?.photoUrl,
                      sousTitre: meta,
                      extraDessousSousTitre: rating > 0
                          ? Row(
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
                            )
                          : null,
                    ),
                    const TitreSectionSettings('Mes véhicules'),
                    GroupeSettings(rows: _vehiculesRows(context, extras)),
                    AppDimens.vGap24,
                    const TitreSectionSettings('Mon activité'),
                    GroupeSettings(rows: [
                      TuileSettings(
                        icon: Icons.alt_route,
                        label: 'Mes itinéraires',
                        onTap: () => context.push(
                          RouteNames.transporteurItinerairesPath,
                        ),
                      ),
                      TuileSettings(
                        icon: Icons.history,
                        label: 'Historique des missions',
                        onTap: () => context.push(
                          RouteNames.transporteurMissionsHistoriquePath,
                        ),
                      ),
                    ]),
                    AppDimens.vGap24,
                    const TitreSectionSettings('Mon compte'),
                    GroupeSettings(rows: [
                      TuileSettings(
                        icon: Icons.account_balance_wallet_outlined,
                        iconGreen: true,
                        label: extras?.solde != null
                            ? 'Wallet · ${_nf.format(extras!.solde!.round())} F'
                            : 'Wallet',
                        onTap: () =>
                            context.push(RouteNames.transporteurWalletPath),
                      ),
                      TuileSettings(
                        icon: Icons.receipt_long_outlined,
                        label: 'Mes transactions',
                        onTap: () => context.push(
                          RouteNames.transporteurTransactionsPath,
                        ),
                      ),
                    ]),
                    AppDimens.vGap24,
                    const TitreSectionSettings('Application'),
                    GroupeSettings(rows: [
                      TuileSettings(
                        icon: Icons.notifications_none,
                        label: 'Notifications',
                        onTap: () => context.push(
                          RouteNames.transporteurNotificationsPath,
                        ),
                      ),
                    ]),
                    AppDimens.vGap24,
                    BoutonDeconnexion(
                      onTap: () async {
                        await ref.read(authStateProvider.notifier).logout();
                        if (context.mounted) {
                          context.go(RouteNames.bienvenuePath);
                        }
                      },
                    ),
                    AppDimens.vGap16,
                    const PiedVersion(),
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

/// Ligne véhicule spécifique au transporteur : vignette photo + marque +
/// charge utile + immatriculation + lien "Voir".
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
                color: kHeroPrimarySoft,
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
                          const ColoredBox(color: kHeroPrimarySoft),
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

/// Ligne "Ajouter un véhicule" — icône `+` verte + libellé en vert.
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
                color: kHeroPrimarySoft,
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
