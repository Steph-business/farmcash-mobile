import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/route_names.dart';
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

/// Page Profil & paramètres producteur — distincte de l'onglet `profil_page`.
///
/// Accessible via tap sur l'icône Paramètres (top-level push). Pattern iOS
/// Settings : sections empilées + rows icône/label/chevron, bouton
/// déconnexion rouge, footer version.
class ProfilSettingsProducteurPage extends ConsumerWidget {
  /// Construit la page.
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
            const EnteteProfilSettings(
              fallbackPath: RouteNames.producteurProfilPath,
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
                    nom: nom,
                    initiales: initialesDepuisNom(user?.fullName),
                    photoUrl: user?.photoUrl,
                    sousTitre: 'Producteur',
                    onModifier: () => context.push(
                      RouteNames.producteurProfilEditerPath,
                    ),
                  ),
                  const TitreSectionSettings('Mon compte'),
                  GroupeSettings(rows: [
                    TuileSettings(
                      icon: Icons.person_outline,
                      iconGreen: true,
                      label: 'Mes informations',
                      sub: 'Nom, téléphone, ville',
                      onTap: () => context.push(
                        RouteNames.producteurProfilEditerPath,
                      ),
                    ),
                    TuileSettings(
                      icon: Icons.description_outlined,
                      iconGreen: true,
                      label: 'Documents (KYC)',
                      sub: 'CNI, photos exploitation',
                      onTap: () => context.push(
                        RouteNames.producteurDocumentsKycPath,
                      ),
                    ),
                    TuileSettings(
                      icon: Icons.account_balance_wallet_outlined,
                      iconGreen: true,
                      label: 'Wallet',
                      sub: 'Solde et transactions',
                      onTap: () =>
                          context.push(RouteNames.producteurWalletPath),
                    ),
                  ]),
                  AppDimens.vGap24,
                  const TitreSectionSettings('Application'),
                  GroupeSettings(rows: [
                    TuileSettings(
                      icon: Icons.notifications_none,
                      label: 'Notifications',
                      onTap: () => Snackbars.showInfo(
                        context,
                        'Notifications — à venir',
                      ),
                    ),
                    TuileSettings(
                      icon: Icons.language,
                      label: 'Langue',
                      sub: 'Français',
                      onTap: () =>
                          Snackbars.showInfo(context, 'Langue — à venir'),
                    ),
                    TuileSettings(
                      icon: Icons.lock_outline,
                      label: 'Sécurité (PIN, sessions)',
                      onTap: () =>
                          Snackbars.showInfo(context, 'Sécurité — à venir'),
                    ),
                  ]),
                  AppDimens.vGap24,
                  const TitreSectionSettings('Support'),
                  GroupeSettings(rows: [
                    TuileSettings(
                      icon: Icons.help_outline,
                      label: "Centre d'aide",
                      onTap: () =>
                          context.push(RouteNames.producteurAidePath),
                    ),
                    TuileSettings(
                      icon: Icons.description_outlined,
                      label: 'Conditions & confidentialité',
                      onTap: () => Snackbars.showInfo(
                        context,
                        'Conditions & confidentialité — à venir',
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
                  const PiedVersion(texte: 'FarmCash · v1.0.0'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
