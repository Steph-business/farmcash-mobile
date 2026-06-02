import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/cooperative.dart';
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

/// Provider qui charge le profil public de la coop courante.
/// Pas d'endpoint "ma coop" — on passe par `getPublic(cooperativeId)`.
final _myCoopProvider = FutureProvider.autoDispose<Cooperative?>((ref) async {
  final user = ref.watch(currentUserProvider);
  final coopId = user?.cooperativeId;
  if (coopId == null || coopId.isEmpty) return null;
  return ref.read(cooperativesServiceProvider).getPublic(coopId);
});

/// Page Profil & paramètres coopérative — pattern iOS Settings.
///
/// Reproduction fidèle de `mockups/cooperative/profil_settings.html` :
/// hero logo + nom + meta + bouton Modifier, 3 sections empilées
/// (Informations légales / Application / Support), bouton rouge
/// déconnexion, footer version.
class ProfilSettingsCooperativePage extends ConsumerWidget {
  /// Construit la page.
  const ProfilSettingsCooperativePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coopAsync = ref.watch(_myCoopProvider);
    final coop = coopAsync.maybeWhen(data: (c) => c, orElse: () => null);
    final loading = coopAsync.isLoading;
    final nomCoop =
        coop?.nom ?? (loading ? 'Chargement…' : 'Coopérative inconnue');
    final metaParts = <String>[
      if (coop != null && coop.nbMembres > 0)
        '${coop.nbMembres} membre${coop.nbMembres > 1 ? 's' : ''}',
      if (coop?.numeroAgrement != null && coop!.numeroAgrement!.isNotEmpty)
        'Agrément ${coop.numeroAgrement}',
      if (coop?.createdAt != null)
        'Créée ${DateFormat('MM/yyyy').format(coop!.createdAt!.toLocal())}',
    ];
    final metaLabel = metaParts.isEmpty ? null : metaParts.join(' · ');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteProfilSettings(
              fallbackPath: RouteNames.accueilCooperativePath,
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
                    nom: nomCoop,
                    initiales: _initialesCoop(nomCoop),
                    photoUrl: coop?.logoUrl,
                    sousTitre: metaLabel,
                    onModifier: () =>
                        _showSoon(context, 'Modifier le profil — à venir'),
                  ),
                  const TitreSectionSettings('Informations légales'),
                  GroupeSettings(rows: [
                    TuileSettings(
                      icon: Icons.verified_user_outlined,
                      iconGreen: true,
                      label: 'Numéro RCCM',
                      onTap: () =>
                          _showSoon(context, 'Numéro RCCM — à venir'),
                    ),
                    TuileSettings(
                      icon: Icons.credit_card_outlined,
                      iconGreen: true,
                      label: 'Compte bancaire (IBAN)',
                      onTap: () => _showSoon(context, 'IBAN — à venir'),
                    ),
                    TuileSettings(
                      icon: Icons.location_on_outlined,
                      iconGreen: true,
                      label: 'Adresse du siège',
                      onTap: () =>
                          _showSoon(context, 'Adresse — à venir'),
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
                      label: 'Apparence (mode sombre)',
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

/// Calcule les initiales (2 lettres max) à partir du nom de la coop —
/// gère séparateurs espace / tiret / underscore. Fallback "CA".
String _initialesCoop(String nom) {
  final t = nom.trim();
  if (t.isEmpty) return 'CA';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length >= 2) return t.substring(0, 2).toUpperCase();
  return t.toUpperCase();
}
