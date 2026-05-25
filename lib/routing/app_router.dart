import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─── Pages partagées (Messages & Notifications mutualisées par rôle) ────
import '../features/pages/_shared/aide_page.dart' as shared_aide;
import '../features/pages/_shared/conditions_page.dart' as shared_conditions;
import '../features/pages/_shared/conversation_detail_page.dart';
import '../features/pages/_shared/messages_page.dart';
import '../features/pages/_shared/notifications_page.dart';
import '../features/pages/_shared/parametres/langue_page.dart'
    as shared_langue;
import '../features/pages/_shared/parametres/moyens_paiement_page.dart'
    as shared_moyens_paiement;
import '../features/pages/_shared/parametres/notifications_preferences_page.dart'
    as shared_notifs_prefs;
import '../features/pages/_shared/parametres/securite_page.dart'
    as shared_securite;

// ─── Pages auth ─────────────────────────────────────────────────────────
import '../features/pages/authentification/bienvenue_page.dart';
import '../features/pages/authentification/choix_role_page.dart';
import '../features/pages/authentification/connexion_page.dart';
import '../features/pages/authentification/definir_pin_page.dart';
import '../features/pages/authentification/inscription_page.dart';
import '../features/pages/authentification/otp_page.dart';
import '../features/pages/authentification/pin_oublie_page.dart';
import '../features/pages/authentification/splash_page.dart';

// ─── Pages producteur ───────────────────────────────────────────────────
import '../features/pages/producteur/accueil_page.dart' as prod_accueil;
import '../features/pages/producteur/ai/actualites_page.dart'
    as prod_ai_actualites;
import '../features/pages/producteur/ai/analyse_plante_page.dart'
    as prod_ai_analyse;
import '../features/pages/producteur/ai/analyses_historique_page.dart'
    as prod_ai_historique;
import '../features/pages/producteur/ai/assistant_page.dart'
    as prod_ai_assistant;
import '../features/pages/producteur/ai/catalogue_traitements_page.dart'
    as prod_ai_catalogue;
import '../features/pages/producteur/aide_page.dart' as prod_aide;
import '../features/pages/producteur/commandes/commande_detail_page.dart';
import '../features/pages/producteur/commandes/commande_terminee_page.dart';
import '../features/pages/producteur/commandes/enlevement_qr_page.dart';
import '../features/pages/producteur/commandes_page.dart';
import '../features/pages/producteur/cooperative/cooperative_page.dart';
import '../features/pages/producteur/demandes/demande_achat_repondre_page.dart';
import '../features/pages/producteur/demandes/demandes_achat_page.dart';
import '../features/pages/producteur/documents_kyc_page.dart'
    as prod_kyc;
import '../features/pages/producteur/offres/offres_recues_page.dart';
import '../features/pages/producteur/parcelles/mes_parcelles_page.dart';
import '../features/pages/producteur/parcelles/parcelle_detail_page.dart';
import '../features/pages/producteur/profil_editer_page.dart'
    as prod_profil_editer;
import '../features/pages/producteur/profil_page.dart' as prod_profil;
import '../features/pages/producteur/profil_settings_page.dart'
    as prod_profil_settings;
import '../features/pages/producteur/publications/annonce_detail_page.dart';
import '../features/pages/producteur/publications/mes_publications_page.dart';
import '../features/pages/producteur/publications/prevision_detail_page.dart';
import '../features/pages/producteur/publications/publication_coop_detail_page.dart';
import '../features/pages/producteur/publier/creer_prevision_page.dart';
import '../features/pages/producteur/publier/parcelle_creer_page.dart';
import '../features/pages/producteur/publier/publier_annonce_page.dart';
import '../features/pages/producteur/sollicitations/sollicitation_repondre_page.dart';
import '../features/pages/producteur/sollicitations/sollicitations_recues_page.dart';
import '../features/pages/producteur/wallet/wallet_page.dart';
import '../features/pages/producteur/wallet/wallet_recharger_page.dart';
import '../features/pages/producteur/wallet/wallet_retirer_page.dart';

// ─── Pages acheteur ─────────────────────────────────────────────────────
import '../features/pages/acheteur/accueil_page.dart' as ach_accueil;
import '../features/pages/acheteur/adresses_livraison_page.dart';
import '../features/pages/acheteur/entreprise/mon_entreprise_page.dart';
import '../features/pages/acheteur/commande/choisir_transporteur_page.dart';
import '../features/pages/acheteur/commande/commande_detail_page.dart'
    as ach_cmd_detail;
import '../features/pages/acheteur/commande/commande_succes_page.dart';
import '../features/pages/acheteur/commande/evaluation_page.dart';
import '../features/pages/acheteur/commande/livraison_qr_page.dart';
import '../features/pages/acheteur/commande/livraison_tracking_page.dart';
import '../features/pages/acheteur/commande/paiement_commande_page.dart';
import '../features/pages/acheteur/commandes_page.dart';
import '../features/pages/acheteur/demandes/mes_demandes_page.dart';
import '../features/pages/acheteur/demandes/proposition_detail_page.dart';
import '../features/pages/acheteur/demandes/publier_demande_page.dart';
import '../features/pages/acheteur/favoris_page.dart';
import '../features/pages/acheteur/marche/annonce_detail_page.dart';
import '../features/pages/acheteur/marche/marche_page.dart';
import '../features/pages/acheteur/marche/prevision_detail_page.dart';
import '../features/pages/acheteur/marche/reservation_paiement_page.dart';
import '../features/pages/acheteur/marche/vendeur_detail_page.dart';
import '../features/pages/acheteur/mes_reservations_page.dart';
import '../features/pages/acheteur/panier_page.dart';
import '../features/pages/acheteur/profil_page.dart' as ach_profil;
import '../features/pages/acheteur/profil_settings_page.dart'
    as ach_profil_settings;
import '../features/pages/acheteur/wallet/wallet_page.dart'
    as ach_wallet;
import '../features/pages/acheteur/wallet/wallet_recharger_page.dart'
    as ach_wallet_recharger;
import '../features/pages/acheteur/wallet/wallet_retirer_page.dart'
    as ach_wallet_retirer;

// ─── Pages coopérative ──────────────────────────────────────────────────
import '../features/pages/cooperative/accueil_page.dart' as coop_accueil;
import '../features/pages/cooperative/adhesions_page.dart';
import '../features/pages/cooperative/collecte_page.dart';
import '../features/pages/cooperative/commission/commission_page.dart';
import '../features/pages/cooperative/documents_officiels/documents_officiels_page.dart';
import '../features/pages/cooperative/finance/distribution_confirmation_page.dart';
import '../features/pages/cooperative/finance/distribution_detail_page.dart';
import '../features/pages/cooperative/finance/payouts_page.dart';
import '../features/pages/cooperative/finance/wallet_page.dart'
    as coop_finance_wallet;
import '../features/pages/cooperative/identite/identite_coop_page.dart';
import '../features/pages/cooperative/inviter_farmer_page.dart';
import '../features/pages/cooperative/logistique/collecte_creer_page.dart';
import '../features/pages/cooperative/logistique/logistique_page.dart';
import '../features/pages/cooperative/logistique/transport_demande_page.dart';
import '../features/pages/cooperative/logistique/vehicule_ajouter_page.dart';
import '../features/pages/cooperative/marche_page.dart';
import '../features/pages/cooperative/membres/enregistrer_managed_page.dart';
import '../features/pages/cooperative/membres/membre_detail_page.dart';
import '../features/pages/cooperative/membres/verser_avance_page.dart';
import '../features/pages/cooperative/membres_page.dart';
import '../features/pages/cooperative/offres_recues_page.dart'
    as coop_offres;
import '../features/pages/cooperative/pesee_page.dart';
import '../features/pages/cooperative/previsions_membres_page.dart';
import '../features/pages/cooperative/profil_page.dart' as coop_profil;
import '../features/pages/cooperative/profil_settings_page.dart'
    as coop_profil_settings;
import '../features/pages/cooperative/publications/publication_creer_page.dart';
import '../features/pages/cooperative/sollicitations/sollicitation_creer_page.dart';
import '../features/pages/cooperative/sollicitations/sollicitation_suivi_page.dart';
import '../features/pages/cooperative/stock/reception_lot_page.dart';
import '../features/pages/cooperative/stock/stock_entrepot_page.dart';
import '../features/pages/cooperative/stock_page.dart';

// ─── Pages transporteur ─────────────────────────────────────────────────
import '../features/pages/transporteur/accueil_page.dart' as trans_accueil;
import '../features/pages/transporteur/confirmations/enlevement_confirme_page.dart';
import '../features/pages/transporteur/confirmations/livraison_confirme_page.dart';
import '../features/pages/transporteur/demande_detail_page.dart';
import '../features/pages/transporteur/demandes_entrantes_page.dart';
import '../features/pages/transporteur/itineraires_page.dart';
import '../features/pages/transporteur/mes_vehicules_page.dart';
import '../features/pages/transporteur/missions/mission_detail_page.dart';
import '../features/pages/transporteur/missions/mission_en_route_page.dart';
import '../features/pages/transporteur/missions/mission_evaluation_page.dart';
import '../features/pages/transporteur/missions/missions_historique_page.dart';
import '../features/pages/transporteur/missions_page.dart';
import '../features/pages/transporteur/profil_page.dart' as trans_profil;
import '../features/pages/transporteur/profil_settings_page.dart'
    as trans_profil_settings;
import '../features/pages/transporteur/scanner_page.dart';
import '../features/pages/transporteur/tarification/tarification_page.dart';
import '../features/pages/transporteur/vehicule_ajouter_page.dart';
import '../features/pages/transporteur/vehicule_creer_page.dart';
import '../features/pages/transporteur/wallet/wallet_page.dart'
    as trans_wallet;
import '../features/pages/transporteur/wallet/wallet_recharger_page.dart'
    as trans_wallet_recharger;
import '../features/pages/transporteur/wallet/wallet_retirer_page.dart'
    as trans_wallet_retirer;

import '../features/state/auth_state.dart';
import '../features/widgets/communs/barre_navigation.dart';
import '../features/widgets/communs/bouton_ajout_central.dart';
import '../features/widgets/communs/shell_layout.dart';
import '../models/enums.dart';
import 'route_guards.dart';
import 'route_names.dart';

/// GoRouter principal. Auth flat en haut, puis 4 shells (un par rôle)
/// avec `StatefulShellRoute.indexedStack` pour préserver l'état des
/// onglets et garder la bottom nav persistante.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthListenable(ref);

  // Navigators dédiés pour bien séparer les piles auth ↔ rôles.
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splashPath,
    debugLogDiagnostics: false,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      return authRedirect(state, auth);
    },
    routes: [
      // ─── Démarrage + Auth (hors shell) ─────────────────────────────
      GoRoute(
        path: RouteNames.splashPath,
        name: RouteNames.splash,
        builder: (_, _) => const SplashPage(),
      ),
      // ─── Chat conversation détail (partagée par les 4 rôles) ───────
      // On utilise `pageBuilder` au lieu de `builder` pour fournir une
      // `MaterialPage` avec une `ValueKey` unique par conversationId.
      // Sinon Flutter Navigator détecte un duplicate-key (NavigatorState
      // assertion `!keyReservation.contains(key)`) quand la même route
      // est repush rapidement (cas du tap rapide depuis Messages →
      // commande détail → re-tap). `parentNavigatorKey` a été retiré
      // car il causait justement le conflit avec le rootNavigatorKey
      // partagé du GoRouter principal.
      GoRoute(
        path: RouteNames.chatDetailPath,
        name: RouteNames.chatDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialPage<void>(
            key: ValueKey('chat-$id'),
            child: ConversationDetailPage(conversationId: id),
          );
        },
      ),
      // ─── Pages partagées paramètres / aide / conditions ────────────
      // Routes top-level non préfixées par rôle (le contenu détecte le
      // rôle via `currentUserProvider` quand nécessaire). Le fallback du
      // bouton retour pointe sur la racine du rôle courant — calculé à
      // la volée depuis `authStateProvider`.
      GoRoute(
        path: RouteNames.languePath,
        name: RouteNames.langue,
        builder: (context, _) => shared_langue.LanguePage(
          fallbackPath: _homePathPourRoleCourant(context),
        ),
      ),
      GoRoute(
        path: RouteNames.securitePath,
        name: RouteNames.securite,
        builder: (context, _) => shared_securite.SecuritePage(
          fallbackPath: _homePathPourRoleCourant(context),
        ),
      ),
      GoRoute(
        path: RouteNames.notificationsPreferencesPath,
        name: RouteNames.notificationsPreferences,
        builder: (context, _) =>
            shared_notifs_prefs.NotificationsPreferencesPage(
          fallbackPath: _homePathPourRoleCourant(context),
        ),
      ),
      GoRoute(
        path: RouteNames.aidePath,
        name: RouteNames.aide,
        builder: (context, _) => shared_aide.AidePartageePage(
          fallbackPath: _homePathPourRoleCourant(context),
        ),
      ),
      GoRoute(
        path: RouteNames.conditionsPath,
        name: RouteNames.conditions,
        builder: (context, _) => shared_conditions.ConditionsPage(
          fallbackPath: _homePathPourRoleCourant(context),
        ),
      ),
      GoRoute(
        path: RouteNames.moyensPaiementPath,
        name: RouteNames.moyensPaiement,
        builder: (context, _) => shared_moyens_paiement.MoyensPaiementPage(
          fallbackPath: _homePathPourRoleCourant(context),
        ),
      ),

      // ─── Pages métier acheteur (push hors shell, ajoutées récemment) ──
      GoRoute(
        path: RouteNames.acheteurMonEntreprisePath,
        name: RouteNames.acheteurMonEntreprise,
        builder: (_, _) => const MonEntrepriseAcheteurPage(),
      ),

      // ─── Pages métier coopérative (push hors shell, ajoutées récemment) ─
      GoRoute(
        path: RouteNames.cooperativeIdentitePath,
        name: RouteNames.cooperativeIdentite,
        builder: (_, _) => const IdentiteCoopPage(),
      ),
      GoRoute(
        path: RouteNames.cooperativeCommissionPath,
        name: RouteNames.cooperativeCommission,
        builder: (_, _) => const CommissionCoopPage(),
      ),
      GoRoute(
        path: RouteNames.cooperativeDocumentsOfficielsPath,
        name: RouteNames.cooperativeDocumentsOfficiels,
        builder: (_, _) => const DocumentsOfficielsCoopPage(),
      ),

      // ─── Pages métier transporteur (push hors shell, ajoutées récemment) ─
      GoRoute(
        path: RouteNames.transporteurTarificationPath,
        name: RouteNames.transporteurTarification,
        builder: (_, _) => const TarificationTransporteurPage(),
      ),
      GoRoute(
        path: RouteNames.bienvenuePath,
        name: RouteNames.bienvenue,
        builder: (_, _) => const BienvenuePage(),
      ),
      GoRoute(
        path: RouteNames.connexionPath,
        name: RouteNames.connexion,
        builder: (_, _) => const ConnexionPage(),
      ),
      GoRoute(
        path: RouteNames.choixRolePath,
        name: RouteNames.choixRole,
        builder: (_, _) => const ChoixRolePage(),
      ),
      GoRoute(
        path: RouteNames.inscriptionPath,
        name: RouteNames.inscription,
        builder: (_, state) {
          final roleApi = state.uri.queryParameters['role'];
          return InscriptionPage(roleApiValue: roleApi);
        },
      ),
      GoRoute(
        path: RouteNames.otpPath,
        name: RouteNames.otp,
        builder: (_, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          final purpose = state.uri.queryParameters['purpose'] ?? 'register';
          return OtpPage(phone: phone, purpose: purpose);
        },
      ),
      GoRoute(
        path: RouteNames.definirPinPath,
        name: RouteNames.definirPin,
        builder: (_, _) => const DefinirPinPage(),
      ),
      GoRoute(
        path: RouteNames.pinOubliePath,
        name: RouteNames.pinOublie,
        builder: (_, _) => const PinOubliePage(),
      ),

      // ─── SHELL PRODUCTEUR ─────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellLayout(
          navigationShell: shell,
          items: _producteurItems,
          centralButton: BoutonAjoutCentral(
            onTap: () => _menuProducteur(context),
            semanticsLabel: 'Publier',
          ),
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.accueilProducteurPath,
              builder: (_, _) => const prod_accueil.AccueilPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.producteurMessagesPath,
              builder: (_, _) => const MessagesPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.producteurCommandesPath,
              builder: (_, _) => const CommandesProducteurPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.producteurProfilPath,
              builder: (_, _) => const prod_profil.ProfilProducteurPage(),
            ),
          ]),
        ],
      ),

      // ─── SHELL ACHETEUR ───────────────────────────────────────────
      // 5 onglets égaux, pas de FAB. Le panier est accessible via une
      // icône dans le header (push d'une route top-level dédiée).
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellLayout(
          navigationShell: shell,
          items: _acheteurItems,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.accueilAcheteurPath,
              builder: (_, _) => const ach_accueil.AccueilPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.acheteurMarchePath,
              builder: (_, _) => const MarchePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.acheteurMessagesPath,
              builder: (_, _) => const MessagesPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.acheteurCommandesPath,
              builder: (_, _) => const CommandesAcheteurPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.acheteurProfilPath,
              builder: (_, _) => const ach_profil.ProfilAcheteurPage(),
            ),
          ]),
        ],
      ),

      // ─── Panier acheteur (hors shell — page push avec back button) ─
      GoRoute(
        path: RouteNames.acheteurPanierPath,
        builder: (_, _) => const PanierAcheteurPage(),
      ),

      // ─── Flow Marché acheteur (push hors shell) ────────────────────
      GoRoute(
        path: RouteNames.acheteurAnnonceDetailPath,
        name: RouteNames.acheteurAnnonceDetail,
        builder: (_, state) => AnnonceDetailAcheteurPage(
          annonceId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.acheteurPrevisionDetailPath,
        name: RouteNames.acheteurPrevisionDetail,
        builder: (_, state) => PrevisionDetailAcheteurPage(
          previsionId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.acheteurReservationPaiementPath,
        name: RouteNames.acheteurReservationPaiement,
        builder: (_, state) => ReservationPaiementPage(
          previsionId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.acheteurMesReservationsPath,
        name: RouteNames.acheteurMesReservations,
        builder: (_, _) => const MesReservationsAcheteurPage(),
      ),

      // ─── Acheteur — Profil public d'un vendeur (push hors shell) ───
      GoRoute(
        path: RouteNames.acheteurVendeurDetailPath,
        name: RouteNames.acheteurVendeurDetail,
        builder: (_, state) => VendeurDetailPage(
          farmerId: state.pathParameters['farmerId'] ?? '',
        ),
      ),

      // ─── Flow Demandes acheteur (publier + lister + propositions) ──
      GoRoute(
        path: RouteNames.acheteurDemandePublierPath,
        name: RouteNames.acheteurDemandePublier,
        builder: (_, _) => const PublierDemandePage(),
      ),
      GoRoute(
        path: RouteNames.acheteurDemandesPath,
        name: RouteNames.acheteurDemandes,
        builder: (_, _) => const MesDemandesAcheteurPage(),
      ),
      GoRoute(
        path: RouteNames.acheteurPropositionsRecuesPath,
        name: RouteNames.acheteurPropositionsRecues,
        builder: (_, state) => PropositionDetailAcheteurPage(
          demandeId: state.pathParameters['id'] ?? '',
        ),
      ),

      // ─── Flow Commande acheteur — choisir transporteur ─────────────
      GoRoute(
        path: RouteNames.acheteurChoisirTransporteurPath,
        name: RouteNames.acheteurChoisirTransporteur,
        builder: (_, state) {
          final extra = state.extra;
          String? origineZone;
          String? destinationZone;
          double? quantiteKg;
          if (extra is Map) {
            final raw = extra['origineZone'];
            if (raw is String && raw.isNotEmpty) origineZone = raw;
            final dest = extra['destinationZone'];
            if (dest is String && dest.isNotEmpty) destinationZone = dest;
            final qte = extra['quantiteKg'];
            if (qte is num) quantiteKg = qte.toDouble();
          }
          return ChoisirTransporteurPage(
            origineZone: origineZone,
            destinationZone: destinationZone,
            quantiteKg: quantiteKg,
          );
        },
      ),

      // ─── Flow Commande acheteur (paiement → succès → détail → QR) ──
      GoRoute(
        path: RouteNames.acheteurPaiementCommandePath,
        name: RouteNames.acheteurPaiementCommande,
        builder: (_, state) {
          final extra = state.extra;
          int? quantiteKg;
          if (extra is Map && extra['quantiteKg'] is int) {
            quantiteKg = extra['quantiteKg'] as int;
          }
          return PaiementCommandePage(
            annonceId: state.pathParameters['id'] ?? '',
            quantiteKgInitiale: quantiteKg,
          );
        },
      ),
      GoRoute(
        path: RouteNames.acheteurCommandeSuccesPath,
        name: RouteNames.acheteurCommandeSucces,
        builder: (_, state) => CommandeSuccesPage(
          commandeId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.acheteurCommandeDetailPath,
        name: RouteNames.acheteurCommandeDetail,
        builder: (_, state) => ach_cmd_detail.CommandeDetailAcheteurPage(
          commandeId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.acheteurLivraisonQrPath,
        name: RouteNames.acheteurLivraisonQr,
        builder: (_, state) => LivraisonQrPage(
          commandeId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.acheteurLivraisonTrackingPath,
        name: RouteNames.acheteurLivraisonTracking,
        builder: (_, state) => LivraisonTrackingPage(
          commandeId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.acheteurCommandeEvaluationPath,
        name: RouteNames.acheteurCommandeEvaluation,
        builder: (_, state) => EvaluationTransportPage(
          commandeId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.acheteurNotificationsPath,
        name: RouteNames.acheteurNotifications,
        builder: (_, _) => const NotificationsPage(),
      ),

      // ─── Flow Wallet acheteur (hors shell) ─────────────────────────
      GoRoute(
        path: RouteNames.acheteurWalletPath,
        name: RouteNames.acheteurWallet,
        builder: (_, _) => const ach_wallet.WalletAcheteurPage(),
      ),
      GoRoute(
        path: RouteNames.acheteurWalletRechargerPath,
        name: RouteNames.acheteurWalletRecharger,
        builder: (_, _) =>
            const ach_wallet_recharger.WalletRechargerAcheteurPage(),
      ),
      GoRoute(
        path: RouteNames.acheteurWalletRetirerPath,
        name: RouteNames.acheteurWalletRetirer,
        builder: (_, _) =>
            const ach_wallet_retirer.WalletRetirerAcheteurPage(),
      ),

      // ─── Profil & paramètres acheteur (hors shell) ─────────────────
      GoRoute(
        path: RouteNames.acheteurProfilSettingsPath,
        name: RouteNames.acheteurProfilSettings,
        builder: (_, _) =>
            const ach_profil_settings.ProfilSettingsAcheteurPage(),
      ),

      // ─── Acheteur — Adresses de livraison (push hors shell) ────────
      GoRoute(
        path: RouteNames.acheteurAdressesLivraisonPath,
        name: RouteNames.acheteurAdressesLivraison,
        builder: (_, _) => const AdressesLivraisonAcheteurPage(),
      ),

      // ─── Acheteur — Mes favoris (push hors shell) ──────────────────
      GoRoute(
        path: RouteNames.acheteurFavorisPath,
        name: RouteNames.acheteurFavoris,
        builder: (_, _) => const FavorisAcheteurPage(),
      ),

      // ─── Profil coop (hors shell — pas d'onglet profil côté coop) ──
      GoRoute(
        path: RouteNames.cooperativeProfilPath,
        builder: (_, _) => const coop_profil.ProfilCooperativePage(),
      ),

      // ─── Coopérative — pages top-level hors shell ──────────────────
      GoRoute(
        path: RouteNames.cooperativeMessagesPath,
        name: RouteNames.cooperativeMessages,
        builder: (_, _) => const MessagesPage(),
      ),
      GoRoute(
        path: RouteNames.cooperativeNotificationsPath,
        name: RouteNames.cooperativeNotifications,
        builder: (_, _) => const NotificationsPage(),
      ),
      GoRoute(
        path: RouteNames.cooperativeProfilSettingsPath,
        name: RouteNames.cooperativeProfilSettings,
        builder: (_, _) =>
            const coop_profil_settings.ProfilSettingsCooperativePage(),
      ),
      GoRoute(
        path: RouteNames.cooperativeAdhesionsPath,
        name: RouteNames.cooperativeAdhesions,
        builder: (_, _) => const AdhesionsCooperativePage(),
      ),
      GoRoute(
        path: RouteNames.cooperativeMembreDetailPath,
        name: RouteNames.cooperativeMembreDetail,
        builder: (_, state) => MembreDetailPage(
          membreId: state.pathParameters['id'] ?? '',
        ),
      ),
      // ─── Coopérative — Stock : détail entrepôt + réception ─────────
      GoRoute(
        path: RouteNames.cooperativeStockEntrepotPath,
        name: RouteNames.cooperativeStockEntrepot,
        builder: (_, state) => StockEntrepotPage(
          entrepotId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.cooperativeStockReceptionPath,
        name: RouteNames.cooperativeStockReception,
        builder: (_, _) => const ReceptionLotPage(),
      ),
      // ─── Coopérative — Collecte du jour + pesée ────────────────────
      GoRoute(
        path: RouteNames.cooperativeCollectePath,
        name: RouteNames.cooperativeCollecte,
        builder: (_, _) => const CollecteCooperativePage(),
      ),
      GoRoute(
        path: RouteNames.cooperativePeseePath,
        name: RouteNames.cooperativePesee,
        builder: (_, state) => PeseePage(
          livraisonId: state.pathParameters['id'] ?? '',
        ),
      ),
      // ─── Coopérative — Inviter un farmer ───────────────────────────
      GoRoute(
        path: RouteNames.cooperativeInviterFarmerPath,
        name: RouteNames.cooperativeInviterFarmer,
        builder: (_, _) => const InviterFarmerPage(),
      ),

      // ─── Coopérative — Enregistrer un farmer géré (sans téléphone) ─
      GoRoute(
        path: RouteNames.cooperativeMembreEnregistrerPath,
        name: RouteNames.cooperativeMembreEnregistrer,
        builder: (_, _) => const EnregistrerManagedPage(),
      ),

      // ─── Coopérative — Finance (wallet, payouts, avances) ──────────
      GoRoute(
        path: RouteNames.cooperativeWalletPath,
        name: RouteNames.cooperativeWallet,
        builder: (_, _) => const coop_finance_wallet.WalletCooperativePage(),
      ),
      GoRoute(
        path: RouteNames.cooperativePayoutsPath,
        name: RouteNames.cooperativePayouts,
        builder: (_, _) => const PayoutsCooperativePage(),
      ),
      GoRoute(
        path: RouteNames.cooperativePayoutDetailPath,
        name: RouteNames.cooperativePayoutDetail,
        builder: (_, state) => DistributionDetailPage(
          payoutId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.cooperativePayoutConfirmationPath,
        name: RouteNames.cooperativePayoutConfirmation,
        builder: (_, state) => DistributionConfirmationPage(
          payoutId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.cooperativeVerserAvancePath,
        name: RouteNames.cooperativeVerserAvance,
        builder: (_, state) {
          final m = state.uri.queryParameters['membreId'];
          return VerserAvancePage(membreIdInitial: m);
        },
      ),

      // ─── Coopérative — Marché (publication, offres, sollicit., prévisions) ─
      GoRoute(
        path: RouteNames.cooperativePublicationCreerPath,
        name: RouteNames.cooperativePublicationCreer,
        builder: (_, _) => const PublicationCreerPage(),
      ),
      GoRoute(
        path: RouteNames.cooperativeOffresRecuesPath,
        name: RouteNames.cooperativeOffresRecues,
        builder: (_, _) => const coop_offres.OffresRecuesPage(),
      ),
      GoRoute(
        path: RouteNames.cooperativeSollicitationCreerPath,
        name: RouteNames.cooperativeSollicitationCreer,
        builder: (_, state) {
          // L'`offreId` peut arriver soit en query (ancienne route), soit
          // en `extra` (depuis la page Offres reçues, qui le pousse
          // directement).
          String? offreId = state.uri.queryParameters['offreId'];
          final extra = state.extra;
          if (offreId == null && extra is Map && extra['offreId'] is String) {
            offreId = extra['offreId'] as String;
          }
          return SollicitationCreerPage(offreId: offreId);
        },
      ),
      GoRoute(
        path: RouteNames.cooperativeSollicitationSuiviPath,
        name: RouteNames.cooperativeSollicitationSuivi,
        builder: (_, state) => SollicitationSuiviPage(
          sollicitationId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.cooperativePrevisionsMembresPath,
        name: RouteNames.cooperativePrevisionsMembres,
        builder: (_, _) => const PrevisionsMembresPage(),
      ),

      // ─── Coopérative — Logistique (parc, collectes, transports) ────
      GoRoute(
        path: RouteNames.cooperativeLogistiquePath,
        name: RouteNames.cooperativeLogistique,
        builder: (_, _) => const LogistiqueCooperativePage(),
      ),
      GoRoute(
        path: RouteNames.cooperativeTransportDemandePath,
        name: RouteNames.cooperativeTransportDemande,
        builder: (_, _) => const TransportDemandePage(),
      ),
      GoRoute(
        path: RouteNames.cooperativeVehiculeAjouterPath,
        name: RouteNames.cooperativeVehiculeAjouter,
        builder: (_, _) => const VehiculeAjouterCooperativePage(),
      ),
      GoRoute(
        path: RouteNames.cooperativeCollecteCreerPath,
        name: RouteNames.cooperativeCollecteCreer,
        builder: (_, _) => const CollecteCreerPage(),
      ),

      // ─── Flow producteur "Publier" (hors shell, push depuis FAB) ───
      // 2 routes : la page principale + la création de parcelle qu'on
      // ouvre en amont si l'utilisateur n'en a aucune.
      GoRoute(
        path: RouteNames.producteurPublierAnnoncePath,
        name: RouteNames.producteurPublierAnnonce,
        builder: (_, _) => const PublierAnnoncePage(),
      ),
      GoRoute(
        path: RouteNames.producteurCreerParcellePath,
        name: RouteNames.producteurCreerParcelle,
        builder: (_, _) => const ParcelleCreerPage(),
      ),
      GoRoute(
        // Créer une prévision de récolte. Le retour `pop(true)` signale
        // un succès à la page liste qui doit refresh son provider.
        path: RouteNames.producteurCreerPrevisionPath,
        name: RouteNames.producteurCreerPrevision,
        builder: (_, _) => const CreerPrevisionPage(),
      ),
      GoRoute(
        path: RouteNames.producteurMesParcellesPath,
        name: RouteNames.producteurMesParcelles,
        builder: (_, _) => const MesParcellesPage(),
      ),
      GoRoute(
        path: RouteNames.producteurParcelleDetailPath,
        name: RouteNames.producteurParcelleDetail,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return ParcelleDetailPage(parcelleId: id);
        },
      ),
      GoRoute(
        path: RouteNames.producteurNotificationsPath,
        name: RouteNames.producteurNotifications,
        builder: (_, _) => const NotificationsPage(),
        // Note: la page partagée détecte automatiquement le rôle (farmer)
        // via currentUserProvider et applique mocks + header producteur.
      ),
      GoRoute(
        path: RouteNames.producteurMesPublicationsPath,
        name: RouteNames.producteurMesPublications,
        builder: (_, _) => const MesPublicationsPage(),
      ),
      GoRoute(
        path: RouteNames.producteurAnnonceDetailPath,
        name: RouteNames.producteurAnnonceDetail,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return AnnonceDetailPage(annonceId: id);
        },
      ),
      GoRoute(
        path: RouteNames.producteurPrevisionDetailPath,
        name: RouteNames.producteurPrevisionDetail,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return PrevisionDetailPage(previsionId: id);
        },
      ),
      GoRoute(
        path: RouteNames.producteurWalletPath,
        name: RouteNames.producteurWallet,
        builder: (_, _) => const WalletPage(),
      ),
      GoRoute(
        path: RouteNames.producteurWalletRechargerPath,
        name: RouteNames.producteurWalletRecharger,
        builder: (_, _) => const WalletRechargerPage(),
      ),
      GoRoute(
        path: RouteNames.producteurWalletRetirerPath,
        name: RouteNames.producteurWalletRetirer,
        builder: (_, _) => const WalletRetirerPage(),
      ),
      GoRoute(
        path: RouteNames.producteurCommandeDetailPath,
        name: RouteNames.producteurCommandeDetail,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return CommandeDetailPage(commandeId: id);
        },
      ),
      GoRoute(
        path: RouteNames.producteurCommandeEnlevementQrPath,
        name: RouteNames.producteurCommandeEnlevementQr,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return EnlevementQrPage(commandeId: id);
        },
      ),
      GoRoute(
        path: RouteNames.producteurCommandeTermineePath,
        name: RouteNames.producteurCommandeTerminee,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return CommandeTermineePage(commandeId: id);
        },
      ),
      GoRoute(
        path: RouteNames.producteurSollicitationsPath,
        name: RouteNames.producteurSollicitations,
        builder: (_, _) => const SollicitationsRecuesPage(),
      ),
      GoRoute(
        path: RouteNames.producteurSollicitationRepondrePath,
        name: RouteNames.producteurSollicitationRepondre,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return SollicitationRepondrePage(sollicitationId: id);
        },
      ),
      GoRoute(
        path: RouteNames.producteurDemandesAchatPath,
        name: RouteNames.producteurDemandesAchat,
        builder: (_, _) => const DemandesAchatPage(),
      ),
      GoRoute(
        path: RouteNames.producteurDemandeAchatRepondrePath,
        name: RouteNames.producteurDemandeAchatRepondre,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return DemandeAchatRepondrePage(demandeId: id);
        },
      ),
      // ─── Producteur — Offres reçues (push hors shell) ──────────────
      GoRoute(
        path: RouteNames.producteurOffresRecuesPath,
        name: RouteNames.producteurOffresRecues,
        builder: (_, _) => const OffresRecuesPage(),
      ),
      // ─── Producteur — Aperçu de la coopérative (push hors shell) ───
      GoRoute(
        path: RouteNames.producteurCooperativePath,
        name: RouteNames.producteurCooperative,
        builder: (_, _) => const CooperativePage(),
      ),
      // ─── Producteur — Détail publication coop (push hors shell) ────
      GoRoute(
        path: RouteNames.producteurPublicationCoopDetailPath,
        name: RouteNames.producteurPublicationCoopDetail,
        builder: (_, state) => PublicationCoopDetailPage(
          id: state.pathParameters['id'] ?? '',
        ),
      ),
      // ─── Producteur — Profil & paramètres (push hors shell) ────────
      GoRoute(
        path: RouteNames.producteurProfilSettingsPath,
        name: RouteNames.producteurProfilSettings,
        builder: (_, _) =>
            const prod_profil_settings.ProfilSettingsProducteurPage(),
      ),
      // ─── Producteur — Édition du profil (push hors shell) ──────────
      GoRoute(
        path: RouteNames.producteurProfilEditerPath,
        name: RouteNames.producteurProfilEditer,
        builder: (_, _) => const prod_profil_editer.ProfilEditerPage(),
      ),
      // ─── Producteur — Documents KYC (push hors shell) ──────────────
      GoRoute(
        path: RouteNames.producteurDocumentsKycPath,
        name: RouteNames.producteurDocumentsKyc,
        builder: (_, _) => const prod_kyc.DocumentsKycPage(),
      ),
      // ─── Producteur — Centre d'aide (push hors shell) ──────────────
      GoRoute(
        path: RouteNames.producteurAidePath,
        name: RouteNames.producteurAide,
        builder: (_, _) => const prod_aide.AidePage(),
      ),

      // ─── Producteur — Outils IA (push hors shell) ──────────────────
      GoRoute(
        path: RouteNames.producteurAiAnalysePlantePath,
        name: RouteNames.producteurAiAnalysePlante,
        builder: (_, _) => const prod_ai_analyse.AnalysePlantePage(),
      ),
      GoRoute(
        path: RouteNames.producteurAiAnalysesHistoriquePath,
        name: RouteNames.producteurAiAnalysesHistorique,
        builder: (_, _) => const prod_ai_historique.AnalysesHistoriquePage(),
      ),
      GoRoute(
        path: RouteNames.producteurAiAssistantPath,
        name: RouteNames.producteurAiAssistant,
        builder: (_, _) => const prod_ai_assistant.AssistantPage(),
      ),
      GoRoute(
        path: RouteNames.producteurAiActualitesPath,
        name: RouteNames.producteurAiActualites,
        builder: (_, _) => const prod_ai_actualites.ActualitesPage(),
      ),
      GoRoute(
        path: RouteNames.producteurAiActualiteDetailPath,
        name: RouteNames.producteurAiActualiteDetail,
        builder: (_, state) => prod_ai_actualites.ActualiteDetailPage(
          id: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.producteurAiCatalogueTraitementsPath,
        name: RouteNames.producteurAiCatalogueTraitements,
        builder: (_, _) =>
            const prod_ai_catalogue.CatalogueTraitementsPage(),
      ),

      // ─── SHELL COOPÉRATIVE ────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellLayout(
          navigationShell: shell,
          items: _cooperativeItems,
          centralButton: BoutonAjoutCentral(
            onTap: () => _menuCooperative(context),
            semanticsLabel: 'Publier',
          ),
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.accueilCooperativePath,
              builder: (_, _) => const coop_accueil.AccueilPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.cooperativeMembresPath,
              builder: (_, _) => const MembresCooperativePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.cooperativeStockPath,
              builder: (_, _) => const StockCooperativePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.cooperativeMarchePath,
              builder: (_, _) => const MarcheCooperativePage(),
            ),
          ]),
        ],
      ),

      // ─── Transporteur — Flow mission (push hors shell) ─────────────
      // Routes littérales avant routes paramétrées (historique avant /:id).
      GoRoute(
        path: RouteNames.transporteurMissionsHistoriquePath,
        name: RouteNames.transporteurMissionsHistorique,
        builder: (_, _) => const MissionsHistoriquePage(),
      ),
      GoRoute(
        path: RouteNames.transporteurMissionDetailPath,
        name: RouteNames.transporteurMissionDetail,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return MissionDetailPage(missionId: id);
        },
      ),
      GoRoute(
        path: RouteNames.transporteurMissionEnRoutePath,
        name: RouteNames.transporteurMissionEnRoute,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return MissionEnRoutePage(missionId: id);
        },
      ),
      GoRoute(
        path: RouteNames.transporteurMissionEvaluationPath,
        name: RouteNames.transporteurMissionEvaluation,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return MissionEvaluationPage(missionId: id);
        },
      ),
      GoRoute(
        path: RouteNames.transporteurScannerPath,
        name: RouteNames.transporteurScanner,
        builder: (_, _) => const ScannerPage(),
      ),
      GoRoute(
        path: RouteNames.transporteurEnlevementConfirmePath,
        name: RouteNames.transporteurEnlevementConfirme,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return EnlevementConfirmePage(missionId: id);
        },
      ),
      GoRoute(
        path: RouteNames.transporteurLivraisonConfirmePath,
        name: RouteNames.transporteurLivraisonConfirme,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return LivraisonConfirmePage(missionId: id);
        },
      ),

      // ─── Transporteur — Demandes entrantes (push hors shell) ───────
      GoRoute(
        path: RouteNames.transporteurDemandesEntrantesPath,
        name: RouteNames.transporteurDemandesEntrantes,
        builder: (_, _) => const DemandesEntrantesTransporteurPage(),
      ),
      GoRoute(
        path: RouteNames.transporteurDemandeDetailPath,
        name: RouteNames.transporteurDemandeDetail,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return DemandeDetailPage(demandeId: id);
        },
      ),

      // ─── Transporteur — Itinéraires (push hors shell, plus en onglet) ─
      GoRoute(
        path: RouteNames.transporteurItinerairesPath,
        builder: (_, _) => const ItinerairesTransporteurPage(),
      ),

      // ─── Transporteur — Notifications (push hors shell) ────────────
      GoRoute(
        path: RouteNames.transporteurNotificationsPath,
        name: RouteNames.transporteurNotifications,
        builder: (_, _) => const NotificationsPage(),
      ),

      // ─── Transporteur — Profil & paramètres (push hors shell) ──────
      GoRoute(
        path: RouteNames.transporteurProfilSettingsPath,
        name: RouteNames.transporteurProfilSettings,
        builder: (_, _) =>
            const trans_profil_settings.ProfilSettingsTransporteurPage(),
      ),

      // ─── Transporteur — Wallet (push hors shell) ───────────────────
      GoRoute(
        path: RouteNames.transporteurWalletPath,
        name: RouteNames.transporteurWallet,
        builder: (_, _) => const trans_wallet.WalletTransporteurPage(),
      ),
      GoRoute(
        path: RouteNames.transporteurWalletRechargerPath,
        name: RouteNames.transporteurWalletRecharger,
        builder: (_, _) =>
            const trans_wallet_recharger.WalletRechargerTransporteurPage(),
      ),
      GoRoute(
        path: RouteNames.transporteurWalletRetirerPath,
        name: RouteNames.transporteurWalletRetirer,
        builder: (_, _) =>
            const trans_wallet_retirer.WalletRetirerTransporteurPage(),
      ),

      // ─── Transporteur — Ajouter mon véhicule (push hors shell) ─────
      // Historiquement nommée "vehicule-ajouter" mais crée en réalité un
      // itinéraire (route transporteur).
      GoRoute(
        path: RouteNames.transporteurVehiculeAjouterPath,
        name: RouteNames.transporteurVehiculeAjouter,
        builder: (_, _) => const VehiculeAjouterTransporteurPage(),
      ),

      // ─── Transporteur — Créer un véhicule (POST /logistics/vehicles) ─
      GoRoute(
        path: RouteNames.transporteurVehiculeCreerPath,
        name: RouteNames.transporteurVehiculeCreer,
        builder: (_, _) => const VehiculeCreerPage(),
      ),

      // ─── Transporteur — Mes véhicules (liste, push hors shell) ─────
      GoRoute(
        path: RouteNames.transporteurMesVehiculesPath,
        name: RouteNames.transporteurMesVehicules,
        builder: (_, _) => const MesVehiculesPage(),
      ),

      // ─── SHELL TRANSPORTEUR ───────────────────────────────────────
      // 4 onglets : Accueil / Missions / Messages / Profil. Pas de FAB.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellLayout(
          navigationShell: shell,
          items: _transporteurItems,
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.accueilTransporteurPath,
              builder: (_, _) => const trans_accueil.AccueilPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.transporteurMissionsPath,
              builder: (_, _) => const MissionsTransporteurPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.transporteurMessagesPath,
              name: RouteNames.transporteurMessages,
              builder: (_, _) => const MessagesPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.transporteurProfilPath,
              builder: (_, _) => const trans_profil.ProfilTransporteurPage(),
            ),
          ]),
        ],
      ),
    ],
  );
});

// ─── Items bottom nav par rôle ───────────────────────────────────────────

const _producteurItems = [
  ItemNavigation(label: 'Accueil', icon: Icons.home_outlined, iconSelected: Icons.home),
  ItemNavigation(label: 'Messages', icon: Icons.chat_bubble_outline, iconSelected: Icons.chat_bubble),
  ItemNavigation(label: 'Commandes', icon: Icons.receipt_long_outlined, iconSelected: Icons.receipt_long),
  ItemNavigation(label: 'Profil', icon: Icons.person_outline, iconSelected: Icons.person),
];

const _acheteurItems = [
  ItemNavigation(label: 'Accueil', icon: Icons.home_outlined, iconSelected: Icons.home),
  ItemNavigation(label: 'Marché', icon: Icons.storefront_outlined, iconSelected: Icons.storefront),
  ItemNavigation(label: 'Messages', icon: Icons.chat_bubble_outline, iconSelected: Icons.chat_bubble),
  ItemNavigation(label: 'Commandes', icon: Icons.receipt_long_outlined, iconSelected: Icons.receipt_long),
  ItemNavigation(label: 'Profil', icon: Icons.person_outline, iconSelected: Icons.person),
];

const _cooperativeItems = [
  ItemNavigation(label: 'Accueil', icon: Icons.home_outlined, iconSelected: Icons.home),
  ItemNavigation(label: 'Membres', icon: Icons.groups_outlined, iconSelected: Icons.groups),
  ItemNavigation(label: 'Stock', icon: Icons.inventory_2_outlined, iconSelected: Icons.inventory_2),
  ItemNavigation(label: 'Marché', icon: Icons.storefront_outlined, iconSelected: Icons.storefront),
];

const _transporteurItems = [
  ItemNavigation(label: 'Accueil', icon: Icons.home_outlined, iconSelected: Icons.home),
  ItemNavigation(label: 'Missions', icon: Icons.local_shipping_outlined, iconSelected: Icons.local_shipping),
  ItemNavigation(label: 'Messages', icon: Icons.chat_bubble_outline, iconSelected: Icons.chat_bubble),
  ItemNavigation(label: 'Profil', icon: Icons.person_outline, iconSelected: Icons.person),
];

// ─── Actions FAB par rôle (placeholders pour l'instant) ──────────────────

void _menuProducteur(BuildContext context) {
  showMenuActions(
    context,
    title: 'Publier',
    actions: [
      MenuAction(
        icon: Icons.campaign_outlined,
        label: 'Annonce de vente',
        subtitle: 'Vendre une récolte disponible maintenant',
        // showMenuActions pop déjà le bottom sheet avant d'appeler onTap.
        onTap: () => context.push(RouteNames.producteurPublierAnnoncePath),
      ),
      MenuAction(
        icon: Icons.calendar_today_outlined,
        label: 'Prévision de récolte',
        subtitle: 'Annoncer une récolte à venir',
        // Push vers la vraie page CreerPrevisionPage (route ajoutée dans
        // une PR précédente). Le toast "à venir" trompait les producteurs.
        onTap: () => context.push(RouteNames.producteurCreerPrevisionPath),
      ),
    ],
  );
}

void _menuCooperative(BuildContext context) {
  showMenuActions(
    context,
    title: 'Publier',
    actions: [
      MenuAction(
        icon: Icons.campaign_outlined,
        label: 'Publier sur le marché',
        subtitle: 'Nouveau lot direct depuis le stock coop',
        onTap: () => _stubAction(context, 'Publication directe'),
      ),
      MenuAction(
        icon: Icons.calendar_today_outlined,
        label: 'Publier une prévision',
        subtitle: 'Agréger les prévisions des membres',
        onTap: () => _stubAction(context, 'Prévision coop'),
      ),
    ],
  );
}

void _stubAction(BuildContext context, String label) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$label — à venir'),
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Retourne le chemin d'accueil du rôle de l'utilisateur courant. Utilisé
/// comme fallback du bouton retour des pages partagées (paramètres, aide,
/// conditions) quand la pile de navigation est vide (deep link direct).
/// Fallback ultime : la page bienvenue.
String _homePathPourRoleCourant(BuildContext context) {
  final container = ProviderScope.containerOf(context, listen: false);
  final role = container.read(authStateProvider).user?.role;
  switch (role) {
    case UserRole.farmer:
      return RouteNames.accueilProducteurPath;
    case UserRole.buyer:
      return RouteNames.accueilAcheteurPath;
    case UserRole.cooperative:
      return RouteNames.accueilCooperativePath;
    case UserRole.transporter:
      return RouteNames.accueilTransporteurPath;
    default:
      return RouteNames.bienvenuePath;
  }
}

/// Listenable interne qui déclenche un re-redirect quand l'auth change.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen(authStateProvider, (_, _) => notifyListeners());
  }
  final Ref _ref;
}
