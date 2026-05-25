import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/parametres/tuile_toggle_settings.dart';
import '../../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../../widgets/communs/profil_settings/groupe_settings.dart';
import '../../../widgets/communs/profil_settings/titre_section_settings.dart';
import '../../../widgets/communs/snackbars.dart';

/// État local des préférences notifications.
///
/// Pour V1 c'est purement client-side (pas de sync backend) — chaque toggle
/// déclenche un snackbar de confirmation. À câbler à une route
/// `/users/me/notification-preferences` plus tard.
class _PrefsState {
  const _PrefsState({
    this.pushGlobal = true,
    this.emailGlobal = true,
    this.smsGlobal = false,
    this.commandes = true,
    this.paiements = true,
    this.marche = true,
    this.messages = true,
    this.coop = true,
    this.securite = true,
    this.marketing = false,
    this.modeNuit = false,
  });

  final bool pushGlobal;
  final bool emailGlobal;
  final bool smsGlobal;
  final bool commandes;
  final bool paiements;
  final bool marche;
  final bool messages;
  final bool coop;
  final bool securite;
  final bool marketing;
  final bool modeNuit;

  _PrefsState copyWith({
    bool? pushGlobal,
    bool? emailGlobal,
    bool? smsGlobal,
    bool? commandes,
    bool? paiements,
    bool? marche,
    bool? messages,
    bool? coop,
    bool? securite,
    bool? marketing,
    bool? modeNuit,
  }) {
    return _PrefsState(
      pushGlobal: pushGlobal ?? this.pushGlobal,
      emailGlobal: emailGlobal ?? this.emailGlobal,
      smsGlobal: smsGlobal ?? this.smsGlobal,
      commandes: commandes ?? this.commandes,
      paiements: paiements ?? this.paiements,
      marche: marche ?? this.marche,
      messages: messages ?? this.messages,
      coop: coop ?? this.coop,
      securite: securite ?? this.securite,
      marketing: marketing ?? this.marketing,
      modeNuit: modeNuit ?? this.modeNuit,
    );
  }
}

final _prefsNotifsProvider =
    StateProvider<_PrefsState>((ref) => const _PrefsState());

/// Page Préférences notifications partagée — distincte du centre de
/// notifications (qui liste les notifs reçues).
///
/// Trois sections :
/// 1. Canaux globaux (push / email / SMS)
/// 2. Catégories (commandes, paiements, marché, messages, coop, sécurité)
/// 3. Divers (marketing, mode nuit)
class NotificationsPreferencesPage extends ConsumerWidget {
  /// Construit la page Préférences notifications.
  const NotificationsPreferencesPage({super.key, required this.fallbackPath});

  /// Chemin de repli si la pile de navigation est vide (deep link).
  final String fallbackPath;

  void _snack(BuildContext context, String label, bool valeur) {
    Snackbars.showInfo(
      context,
      '$label ${valeur ? "activé" : "désactivé"}',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(_prefsNotifsProvider);
    final notifier = ref.read(_prefsNotifsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteProfilSettings(
              fallbackPath: fallbackPath,
              titre: 'Notifications',
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
                  Text(
                    'Choisis comment et quand recevoir des notifications.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  AppDimens.vGap16,

                  // Canaux globaux
                  const TitreSectionSettings('Canaux'),
                  GroupeSettings(
                    rows: [
                      TuileToggleSettings(
                        icone: Icons.notifications_active_outlined,
                        label: 'Push (notifications mobiles)',
                        sousTitre:
                            'Alertes instantanées sur ton téléphone',
                        valeur: prefs.pushGlobal,
                        iconeVerte: true,
                        onChanged: (v) {
                          notifier.state = prefs.copyWith(pushGlobal: v);
                          _snack(context, 'Notifications push', v);
                        },
                      ),
                      TuileToggleSettings(
                        icone: Icons.mail_outline,
                        label: 'Email',
                        sousTitre: 'Récap quotidien + alertes importantes',
                        valeur: prefs.emailGlobal,
                        onChanged: (v) {
                          notifier.state = prefs.copyWith(emailGlobal: v);
                          _snack(context, 'Notifications email', v);
                        },
                      ),
                      TuileToggleSettings(
                        icone: Icons.sms_outlined,
                        label: 'SMS',
                        sousTitre: 'Uniquement pour les opérations critiques',
                        valeur: prefs.smsGlobal,
                        onChanged: (v) {
                          notifier.state = prefs.copyWith(smsGlobal: v);
                          _snack(context, 'Notifications SMS', v);
                        },
                      ),
                    ],
                  ),
                  AppDimens.vGap24,

                  // Catégories
                  const TitreSectionSettings('Catégories'),
                  GroupeSettings(
                    rows: [
                      TuileToggleSettings(
                        icone: Icons.receipt_long_outlined,
                        label: 'Commandes & livraisons',
                        valeur: prefs.commandes,
                        onChanged: (v) =>
                            notifier.state = prefs.copyWith(commandes: v),
                      ),
                      TuileToggleSettings(
                        icone: Icons.account_balance_wallet_outlined,
                        label: 'Paiements & wallet',
                        valeur: prefs.paiements,
                        onChanged: (v) =>
                            notifier.state = prefs.copyWith(paiements: v),
                      ),
                      TuileToggleSettings(
                        icone: Icons.storefront_outlined,
                        label: 'Marché & opportunités',
                        valeur: prefs.marche,
                        onChanged: (v) =>
                            notifier.state = prefs.copyWith(marche: v),
                      ),
                      TuileToggleSettings(
                        icone: Icons.chat_bubble_outline,
                        label: 'Messages',
                        valeur: prefs.messages,
                        onChanged: (v) =>
                            notifier.state = prefs.copyWith(messages: v),
                      ),
                      TuileToggleSettings(
                        icone: Icons.groups_outlined,
                        label: 'Coopérative',
                        valeur: prefs.coop,
                        onChanged: (v) =>
                            notifier.state = prefs.copyWith(coop: v),
                      ),
                      TuileToggleSettings(
                        icone: Icons.shield_outlined,
                        label: 'Sécurité',
                        sousTitre: 'Recommandé · ne peut pas être désactivé',
                        valeur: prefs.securite,
                        onChanged: (_) => Snackbars.showInfo(
                          context,
                          'Les alertes de sécurité ne peuvent pas être '
                          'désactivées.',
                        ),
                      ),
                    ],
                  ),
                  AppDimens.vGap24,

                  // Divers
                  const TitreSectionSettings('Divers'),
                  GroupeSettings(
                    rows: [
                      TuileToggleSettings(
                        icone: Icons.local_offer_outlined,
                        label: 'Promotions & nouveautés',
                        sousTitre: 'Offres FarmCash et partenaires',
                        valeur: prefs.marketing,
                        onChanged: (v) =>
                            notifier.state = prefs.copyWith(marketing: v),
                      ),
                      TuileToggleSettings(
                        icone: Icons.dark_mode_outlined,
                        label: 'Mode nuit',
                        sousTitre: 'Ne pas notifier entre 22h et 7h',
                        valeur: prefs.modeNuit,
                        onChanged: (v) =>
                            notifier.state = prefs.copyWith(modeNuit: v),
                      ),
                    ],
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
