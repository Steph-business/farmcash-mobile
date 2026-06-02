import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/wallet_with_transactions.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/profil_settings/bouton_deconnexion.dart';
import '../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../widgets/communs/profil_settings/groupe_settings.dart';
import '../../widgets/communs/profil_settings/hero_identite.dart';
import '../../widgets/communs/profil_settings/pied_version.dart';
import '../../widgets/communs/profil_settings/titre_section_settings.dart';
import '../../widgets/communs/profil_settings/tuile_settings.dart';
import '../../widgets/communs/snackbars.dart';

final _nf = NumberFormat('#,##0', 'fr_FR');

/// Charge le wallet (solde + escrow) en arrière-plan pour l'afficher dans
/// la section "Mon compte" sans bloquer la page si l'endpoint échoue.
final _walletInfoProvider =
    FutureProvider.autoDispose<WalletWithTransactions?>((ref) async {
  try {
    return await ref.read(financeServiceProvider).getWallet(limit: 1);
  } catch (_) {
    return null;
  }
});

/// Page Profil & paramètres acheteur — distincte de l'onglet `profil_page`.
///
/// Accessible via tap sur l'avatar du header (top-level push). Pattern
/// iOS Settings : sections empilées + rows icône/label/chevron, bouton
/// déconnexion rouge, footer version.
///
/// Reproduction fidèle de `mockups/acheteur/profil_settings.html`.
class ProfilSettingsAcheteurPage extends ConsumerWidget {
  /// Construit la page.
  const ProfilSettingsAcheteurPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final walletAsync = ref.watch(_walletInfoProvider);
    final walletSub = walletAsync.maybeWhen(
      data: (w) {
        if (w == null) return 'Solde, transactions, escrow';
        final solde = _nf.format(w.wallet.balance.round());
        final escrow = _nf.format(w.wallet.balanceEscrow.round());
        return '$solde F · $escrow F en escrow';
      },
      orElse: () => 'Solde, transactions, escrow',
    );

    final nom = user?.fullName?.trim();
    final nomAffiche = (nom != null && nom.isNotEmpty) ? nom : 'Acheteur';
    final membreDepuis = user?.createdAt != null
        ? 'membre depuis ${DateFormat('MMM y', 'fr_FR').format(user!.createdAt!)}'
        : null;
    final sousTitre = <String>[
      if (user?.phone != null) user!.phone!,
      if (membreDepuis != null) membreDepuis,
    ].join(' · ');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteProfilSettings(
              fallbackPath: RouteNames.acheteurProfilPath,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: [
                  HeroIdentite(
                    nom: nomAffiche,
                    initiales: initialesDepuisNom(nomAffiche),
                    photoUrl: user?.photoUrl,
                    sousTitre: sousTitre.isEmpty ? null : sousTitre,
                    onModifier: () =>
                        _showSoon(context, 'Modifier le profil — à venir'),
                  ),
                  const TitreSectionSettings('Mon compte'),
                  GroupeSettings(rows: [
                    TuileSettings(
                      icon: Icons.description_outlined,
                      iconGreen: true,
                      label: 'Informations légales',
                      sub: 'IFU & justificatifs',
                      onTap: () => _showSoon(
                        context,
                        'Informations légales — à venir',
                      ),
                    ),
                    TuileSettings(
                      icon: Icons.location_on_outlined,
                      iconGreen: true,
                      label: 'Adresses de livraison',
                      sub: 'Gérer mes adresses',
                      onTap: () => context
                          .push(RouteNames.acheteurAdressesLivraisonPath),
                    ),
                    TuileSettings(
                      icon: Icons.account_balance_wallet_outlined,
                      iconGreen: true,
                      label: 'Wallet',
                      sub: walletSub,
                      onTap: () =>
                          context.push(RouteNames.acheteurWalletPath),
                    ),
                  ]),
                  AppDimens.vGap24,
                  const TitreSectionSettings('Application'),
                  GroupeSettings(rows: [
                    TuileSettings(
                      icon: Icons.notifications_none,
                      label: 'Notifications',
                      onTap: () =>
                          _showSoon(context, 'Notifications — à venir'),
                    ),
                    TuileSettings(
                      icon: Icons.language,
                      label: 'Langue',
                      onTap: () => _showSoon(context, 'Langue — à venir'),
                    ),
                    TuileSettings(
                      icon: Icons.dark_mode_outlined,
                      label: 'Apparence',
                      onTap: () =>
                          _showSoon(context, 'Apparence — à venir'),
                    ),
                  ]),
                  AppDimens.vGap24,
                  const TitreSectionSettings('Support'),
                  GroupeSettings(rows: [
                    TuileSettings(
                      icon: Icons.help_outline,
                      label: "Centre d'aide",
                      onTap: () =>
                          _showSoon(context, "Centre d'aide — à venir"),
                    ),
                    TuileSettings(
                      icon: Icons.chat_outlined,
                      label: "Contacter l'équipe FarmCash",
                      onTap: () =>
                          _showSoon(context, 'Contact — à venir'),
                    ),
                    TuileSettings(
                      icon: Icons.description_outlined,
                      label: 'Conditions & confidentialité',
                      onTap: () =>
                          _showSoon(context, 'Conditions — à venir'),
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
          ],
        ),
      ),
    );
  }

  /// SnackBar « à venir » — délègue au helper unifié style apps pro
  /// (fond sombre + icône colorée).
  static void _showSoon(BuildContext context, String msg) {
    Snackbars.showInfo(context, msg);
  }
}
