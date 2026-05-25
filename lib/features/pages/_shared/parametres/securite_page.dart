import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/parametres/tuile_session_active.dart';
import '../../../widgets/communs/parametres/tuile_toggle_settings.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/profil_settings/groupe_settings.dart';
import '../../../widgets/communs/profil_settings/titre_section_settings.dart';
import '../../../widgets/communs/profil_settings/tuile_settings.dart';
import '../../../widgets/communs/snackbars.dart';

/// Page Sécurité partagée — code PIN, biométrie, sessions actives.
///
/// Le code PIN renvoie vers le flow existant `pin/definir`. La biométrie
/// est une préférence locale (pas encore câblée à `local_auth`). Les
/// sessions affichent un mock pour l'instant — l'endpoint backend manque.
class SecuritePage extends ConsumerStatefulWidget {
  /// Construit la page Sécurité.
  const SecuritePage({super.key, required this.fallbackPath});

  /// Chemin de repli si la pile de navigation est vide (deep link).
  final String fallbackPath;

  @override
  ConsumerState<SecuritePage> createState() => _SecuritePageState();
}

class _SecuritePageState extends ConsumerState<SecuritePage> {
  bool _biometrieActivee = false;
  bool _verrouAuLancement = true;
  bool _confirmerPaiements = true;

  void _snackInfo(String message) {
    if (!mounted) return;
    Snackbars.showInfo(context, message);
  }

  Future<void> _deconnecterToutesSessions() async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnecter tous les appareils ?'),
        content: const Text(
          'Tu seras déconnecté de tous les appareils (y compris celui-ci). '
          'Tu devras te reconnecter avec ton code PIN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Tout déconnecter'),
          ),
        ],
      ),
    );

    if (confirmer != true || !mounted) return;
    await ref.read(authStateProvider.notifier).logout();
    if (!mounted) return;
    context.go(RouteNames.bienvenuePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteProfilSettings(
              fallbackPath: widget.fallbackPath,
              titre: 'Sécurité',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  AppDimens.space8,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: [
                  // 1 — Section authentification
                  const TitreSectionSettings('Authentification'),
                  GroupeSettings(
                    rows: [
                      TuileSettings(
                        icon: Icons.pin_outlined,
                        label: 'Modifier mon code PIN',
                        sub: 'Code à 4-6 chiffres',
                        iconGreen: true,
                        onTap: () => context.push(RouteNames.definirPinPath),
                      ),
                      TuileSettings(
                        icon: Icons.help_outline,
                        label: 'PIN oublié',
                        sub: 'Réinitialiser via OTP',
                        onTap: () => context.push(RouteNames.pinOubliePath),
                      ),
                      TuileToggleSettings(
                        icone: Icons.fingerprint,
                        label: 'Déverrouillage biométrique',
                        sousTitre: 'Empreinte ou visage',
                        valeur: _biometrieActivee,
                        iconeVerte: true,
                        onChanged: (v) {
                          setState(() => _biometrieActivee = v);
                          _snackInfo(
                            v
                                ? 'Biométrie activée'
                                : 'Biométrie désactivée',
                          );
                        },
                      ),
                    ],
                  ),
                  AppDimens.vGap24,

                  // 2 — Section préférences
                  const TitreSectionSettings('Préférences'),
                  GroupeSettings(
                    rows: [
                      TuileToggleSettings(
                        icone: Icons.lock_clock_outlined,
                        label: 'Verrouiller au lancement',
                        sousTitre: 'Demander le PIN à chaque ouverture',
                        valeur: _verrouAuLancement,
                        onChanged: (v) =>
                            setState(() => _verrouAuLancement = v),
                      ),
                      TuileToggleSettings(
                        icone: Icons.payments_outlined,
                        label: 'Confirmer chaque paiement',
                        sousTitre: 'Demander le PIN avant chaque achat',
                        valeur: _confirmerPaiements,
                        onChanged: (v) =>
                            setState(() => _confirmerPaiements = v),
                      ),
                    ],
                  ),
                  AppDimens.vGap24,

                  // 3 — Section sessions actives
                  const TitreSectionSettings('Sessions actives'),
                  GroupeSettings(
                    rows: [
                      TuileSessionActive(
                        icone: Icons.smartphone,
                        appareil: 'Cet appareil',
                        localisation: 'Abidjan, CI',
                        dernierAcces: 'À l\'instant',
                        estCetAppareil: true,
                        onDeconnecter: () {},
                      ),
                      TuileSessionActive(
                        icone: Icons.tablet_android,
                        appareil: 'Tablette',
                        localisation: 'Abidjan, CI',
                        dernierAcces: 'Il y a 2 jours',
                        estCetAppareil: false,
                        onDeconnecter: () => _snackInfo(
                          'Déconnexion de session — à venir',
                        ),
                      ),
                    ],
                  ),
                  AppDimens.vGap16,
                  Text(
                    'Une session est créée à chaque fois que tu te connectes '
                    'sur un nouvel appareil. Déconnecte-toi des appareils '
                    'que tu n\'utilises plus.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  AppDimens.vGap24,

                  // 4 — Bouton "Tout déconnecter"
                  _BoutonDangerSecurite(
                    label: 'Déconnecter tous les appareils',
                    onTap: _deconnecterToutesSessions,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoutonDangerSecurite extends StatelessWidget {
  const _BoutonDangerSecurite({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brCard,
      child: Container(
        height: AppDimens.buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.4),
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
