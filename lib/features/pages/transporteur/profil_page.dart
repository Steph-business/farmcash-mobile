import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../models/livraison.dart';
import '../../../models/portefeuille.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/profil/barre_superieure_profil.dart';
import '../../widgets/communs/profil/bouton_deconnexion_profil.dart';
import '../../widgets/communs/profil/carte_identite_profil.dart';
import '../../widgets/communs/profil/groupe_profil.dart';
import '../../widgets/communs/profil/photo_profil.dart';
import '../../widgets/communs/profil/pied_legal_profil.dart';
import '../../widgets/communs/profil/tuile_profil.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/transporteur/profil/ligne_stats_transporteur.dart';
import '../../widgets/transporteur/profil/sous_textes_profil_transporteur.dart';
import '../../widgets/transporteur/profil/switch_disponibilite_transporteur.dart';

/// Bundle de données chargées en parallèle pour le profil transporteur.
///
/// Chaque appel est tolérant : un service en échec retourne `null`/liste
/// vide. Les sections affichées restent visibles mais les sous-textes
/// dynamiques (compteurs) sont masqués si la donnée manque.
class _ProfilTransporteurData {
  final Portefeuille? wallet;
  final List<Livraison> missions;
  final List<TransporterRoute> routes;

  const _ProfilTransporteurData({
    required this.wallet,
    required this.missions,
    required this.routes,
  });

  /// Nombre de missions effectivement livrées.
  int get nbLivrees =>
      missions.where((m) => m.status == ShipmentStatus.delivered).length;

  /// Nombre d'itinéraires marqués actifs.
  int get nbItinerairesActifs => routes.where((r) => r.isActive).length;

  /// Nombre de zones uniques couvertes (union origine + destination).
  int get nbZonesUniques {
    final zones = <String>{};
    for (final r in routes) {
      final o = r.origineZone.trim();
      final d = r.destinationZone.trim();
      if (o.isNotEmpty) zones.add(o);
      if (d.isNotEmpty) zones.add(d);
    }
    return zones.length;
  }
}

/// Charge en parallèle wallet + routes + missions du transporteur.
final _profilTransporteurDataProvider =
    FutureProvider.autoDispose<_ProfilTransporteurData>((ref) async {
  final logistics = ref.watch(logisticsServiceProvider);
  final finance = ref.watch(financeServiceProvider);

  final results = await Future.wait<dynamic>([
    finance.getWallet().then<Object?>((v) => v).catchError((_) => null),
    logistics
        .listMyRoutes()
        .then<Object?>((v) => v)
        .catchError((_) => <TransporterRoute>[]),
    logistics
        .getAvailableMissions()
        .then<Object?>((v) => v)
        .catchError((_) => <Livraison>[]),
  ]);

  final walletBundle = results[0];
  final Portefeuille? wallet = walletBundle == null
      ? null
      : (walletBundle as dynamic).wallet as Portefeuille;
  final routes = (results[1] as List<TransporterRoute>?) ?? const [];
  final missions = (results[2] as List<Livraison>?) ?? const [];

  return _ProfilTransporteurData(
    wallet: wallet,
    missions: missions,
    routes: routes,
  );
});

/// Onglet Profil du transporteur — fidèle reproduction de
/// `mockups/transporteur_profil.html`. Sections label-only (icône + label
/// + chevron) : un tap déclenche un SnackBar "à venir" pour V1, sauf le
/// wallet qui affiche le montant.
class ProfilTransporteurPage extends ConsumerWidget {
  /// Crée la page profil transporteur.
  const ProfilTransporteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_profilTransporteurDataProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BarreSuperieureProfil(
              onParametres: () =>
                  context.push(RouteNames.transporteurProfilSettingsPath),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger le profil.',
                    onRetry: () =>
                        ref.invalidate(_profilTransporteurDataProvider),
                  ),
                ),
                data: (data) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async =>
                      ref.invalidate(_profilTransporteurDataProvider),
                  child: _ContenuProfilTransporteur(
                    data: data,
                    user: user,
                    onLogout: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) {
                        context.go(RouteNames.bienvenuePath);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CONTENU ─────────────────────────────────────────────────────────────

class _ContenuProfilTransporteur extends StatelessWidget {
  const _ContenuProfilTransporteur({
    required this.data,
    required this.user,
    required this.onLogout,
  });

  final _ProfilTransporteurData data;
  final dynamic user; // Utilisateur? — getters dynamiques tolérants
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final balance = data.wallet?.balance ?? 0;
    final devise = data.wallet?.currency ?? 'XOF';
    final rating = (user?.rating as double?) ?? 0;
    final fullName = (user?.fullName as String?)?.trim();
    final nom = (fullName == null || fullName.isEmpty)
        ? 'Transporteur'
        : fullName;
    final nbZones = data.nbZonesUniques;
    final nbItineraires = data.nbItinerairesActifs;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        // 1. Carte d'identité
        CarteIdentiteProfil(
          nom: nom,
          initiales: initialesProfilDepuisNom(fullName),
          photoUrl: user?.photoUrl as String?,
          sousLigne: sousLigneIdentiteTransporteur(rating: rating),
          onModifier: () =>
              _snack(context, 'Modification du profil — à venir'),
          onEditPhoto: () =>
              _snack(context, 'Modifier la photo — à venir'),
        ),
        AppDimens.vGap24,

        // 2. Stats
        LigneStatsTransporteur(
          livrees: data.nbLivrees,
          gainsFormates: formatCompactTransporteur(balance),
          tauxSucces: kTauxSuccesStatiqueTransporteur,
        ),
        AppDimens.vGap24,

        // 3. Mon véhicule — chaque entrée ouvre la liste "Mes véhicules"
        GroupeProfil(
          titre: 'Mon véhicule',
          enfants: [
            TuileProfil(
              icone: Icons.local_shipping_outlined,
              accent: true,
              label: 'Type de véhicule',
              onTap: () =>
                  context.push(RouteNames.transporteurMesVehiculesPath),
            ),
            TuileProfil(
              icone: Icons.confirmation_number_outlined,
              accent: true,
              label: 'Immatriculation',
              onTap: () =>
                  context.push(RouteNames.transporteurMesVehiculesPath),
            ),
            TuileProfil(
              icone: Icons.inventory_2_outlined,
              accent: true,
              label: 'Capacité & volume',
              onTap: () =>
                  context.push(RouteNames.transporteurMesVehiculesPath),
            ),
            TuileProfil(
              icone: Icons.badge_outlined,
              accent: true,
              label: 'Numéro de permis',
              onTap: () =>
                  context.push(RouteNames.transporteurProfilSettingsPath),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 4. Tarification & zones
        GroupeProfil(
          titre: 'Tarification & zones',
          enfants: [
            TuileProfil(
              icone: Icons.attach_money,
              label: 'Tarif par kg',
              onTap: () =>
                  context.push(RouteNames.transporteurTarificationPath),
            ),
            TuileProfil(
              icone: Icons.timelapse,
              label: 'Tarif minimum',
              onTap: () =>
                  context.push(RouteNames.transporteurTarificationPath),
            ),
            TuileProfil(
              icone: Icons.location_on_outlined,
              label: 'Zones couvertes',
              sousTitre: nbZones > 0
                  ? '$nbZones zone${nbZones > 1 ? 's' : ''}'
                  : null,
              onTap: () =>
                  context.push(RouteNames.transporteurTarificationPath),
            ),
            TuileProfil(
              icone: Icons.alt_route,
              label: 'Mes itinéraires',
              sousTitre: nbItineraires > 0
                  ? '$nbItineraires actif${nbItineraires > 1 ? 's' : ''}'
                  : null,
              onTap: () =>
                  context.push(RouteNames.transporteurItinerairesPath),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 5. Disponibilité (ligne avec switch)
        GroupeProfil(
          titre: 'Disponibilité',
          enfants: [
            TuileProfil(
              icone: Icons.event_available,
              label: 'Disponible pour livrer',
              sousTitre: 'Les missions arrivent',
              trailingWidget: SwitchDisponibiliteTransporteur(
                onTap: () => _snack(
                  context,
                  'Changement de disponibilité — à venir',
                ),
              ),
              montrerChevron: false,
            ),
          ],
        ),
        AppDimens.vGap16,

        // 6. Finance
        GroupeProfil(
          titre: 'Finance',
          enfants: [
            TuileProfil(
              icone: Icons.account_balance_wallet_outlined,
              accent: true,
              label: 'Mon wallet',
              trailingWidget: Padding(
                padding: const EdgeInsets.only(right: AppDimens.space8),
                child: Text(
                  formatMontantTransporteur(balance, devise),
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              onTap: () =>
                  context.push(RouteNames.transporteurWalletPath),
            ),
            TuileProfil(
              icone: Icons.credit_card_outlined,
              label: 'Moyens de paiement',
              onTap: () => context.push(RouteNames.moyensPaiementPath),
            ),
            TuileProfil(
              icone: Icons.show_chart,
              label: 'Mes transactions',
              onTap: () =>
                  context.push(RouteNames.transporteurWalletPath),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 7. Paramètres
        GroupeProfil(
          titre: 'Paramètres',
          enfants: [
            TuileProfil(
              icone: Icons.language,
              label: 'Langue',
              onTap: () => context.push(RouteNames.languePath),
            ),
            TuileProfil(
              icone: Icons.notifications_none,
              label: 'Notifications',
              onTap: () =>
                  context.push(RouteNames.notificationsPreferencesPath),
            ),
            TuileProfil(
              icone: Icons.lock_outline,
              label: 'Sécurité (PIN, sessions)',
              onTap: () => context.push(RouteNames.securitePath),
            ),
          ],
        ),
        AppDimens.vGap16,

        // 8. Aide & légal
        GroupeProfil(
          titre: 'Aide & légal',
          enfants: [
            TuileProfil(
              icone: Icons.help_outline,
              label: "Centre d'aide",
              onTap: () => context.push(RouteNames.aidePath),
            ),
            TuileProfil(
              icone: Icons.description_outlined,
              label: 'Conditions & confidentialité',
              onTap: () => context.push(RouteNames.conditionsPath),
            ),
          ],
        ),
        AppDimens.vGap8,

        // 9. Bouton "Se déconnecter"
        BoutonDeconnexionProfil(onTap: onLogout),
        AppDimens.vGap16,

        // 10. Footer légal
        const PiedLegalProfil(),
      ],
    );
  }
}

/// SnackBar discrète "à venir".
void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
