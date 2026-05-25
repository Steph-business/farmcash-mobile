lib/
├── main.dart
├── app.dart
│
├── api_client/                          🇬🇧 standard
│   ├── api_client.dart
│   ├── api_endpoints.dart
│   ├── api_exception.dart
│   └── auth_interceptor.dart
│
├── services/                            🇬🇧 standard
│   ├── auth_service.dart
│   ├── marketplace_service.dart
│   ├── negotiation_service.dart
│   ├── orders_service.dart
│   ├── finance_service.dart
│   ├── logistics_service.dart
│   ├── messaging_service.dart
│   ├── notifications_service.dart
│   ├── ai_service.dart
│   ├── cooperatives_service.dart
│   └── oversight_service.dart
│
├── models/                              🇬🇧 dossier / 🇫🇷 fichiers
│   ├── utilisateur.dart
│   ├── annonce_vente.dart
│   ├── annonce_achat.dart
│   ├── publication_coop.dart
│   ├── commande.dart
│   ├── transaction.dart
│   ├── portefeuille.dart
│   ├── livraison.dart
│   ├── conversation.dart
│   ├── message.dart
│   ├── notification.dart
│   ├── analyse_plante.dart
│   ├── traitement.dart
│   ├── reservation.dart
│   ├── cooperative.dart
│   ├── membre_coop.dart
│   ├── avance_coop.dart
│   └── enums.dart
│
├── pages/                               🇫🇷 métier
│   │
│   ├── _shared/                         ← SHARED pages (chat, etc.)
│   │   ├── messages_page.dart           ← Liste conversations, identique tous rôles
│   │   ├── conversation_detail_page.dart
│   │   └── notifications_page.dart      ← Centre notifs, identique tous rôles
│   │
│   ├── authentification/                ← AUTH (inscription + connexion)
│   │   ├── splash_page.dart
│   │   ├── bienvenue_page.dart
│   │   ├── choix_role_page.dart
│   │   ├── inscription_page.dart
│   │   ├── otp_page.dart
│   │   ├── definir_pin_page.dart
│   │   ├── connexion_page.dart
│   │   └── pin_oublie_page.dart
│   │
│   ├── producteur/                      ← FARMER
│   │   ├── accueil_page.dart
│   │   ├── annonces_page.dart
│   │   ├── transactions_page.dart       (wallet producteur)
│   │   ├── profil_page.dart
│   │   ├── parcelles/
│   │   ├── publier/
│   │   ├── publications/
│   │   ├── commandes/
│   │   ├── sollicitations/
│   │   ├── offres/
│   │   ├── demandes/
│   │   ├── cooperative/
│   │   ├── ai/
│   │   └── wallet/
│   │
│   ├── acheteur/                        ← BUYER
│   │   ├── accueil_page.dart
│   │   ├── recherche_page.dart
│   │   ├── commandes_page.dart
│   │   ├── transactions_page.dart       (wallet acheteur)
│   │   ├── profil_page.dart
│   │   ├── marche/
│   │   ├── commande/
│   │   ├── demandes/
│   │   └── wallet/
│   │
│   ├── cooperative/                     ← COOP
│   │   ├── accueil_page.dart
│   │   ├── transactions_page.dart       (wallet coop)
│   │   ├── profil_page.dart
│   │   ├── membres/
│   │   ├── annonces/
│   │   ├── publications/
│   │   ├── sollicitations/
│   │   ├── finance/
│   │   ├── logistique/
│   │   └── stock/
│   │
│   └── transporteur/                    ← TRANSPORTER
│       ├── accueil_page.dart
│       ├── itineraires_page.dart
│       ├── transactions_page.dart       (wallet transporteur)
│       ├── profil_page.dart
│       ├── missions/
│       ├── confirmations/
│       └── wallet/
│
├── widgets/                             🇫🇷 métier
│   │
│   │  ╔═══════════════════════════════════════════════════════════════╗
│   │  ║  RÈGLE STRICTE — Toute page doit être COMPOSITION ONLY.       ║
│   │  ║  AUCUN `_PrivateWidget` substantiel inline dans une page.     ║
│   │  ║  Tous les widgets de détail VIVENT DANS widgets/...           ║
│   │  ║                                                                ║
│   │  ║  Les features COMMUNES (messages, notifications, auth)        ║
│   │  ║  sont des DOSSIERS SHARED top-level — JAMAIS dupliquées       ║
│   │  ║  par acteur.                                                   ║
│   │  ╚═══════════════════════════════════════════════════════════════╝
│   │
│   ├── communs/                         ← Widgets utilitaires shared
│   │   ├── bouton_principal.dart
│   │   ├── bouton_secondaire.dart
│   │   ├── chargement.dart
│   │   ├── vue_erreur.dart
│   │   ├── snackbars.dart
│   │   ├── section_titre.dart
│   │   ├── carte_argent_commande.dart
│   │   ├── suivi_commande.dart
│   │   ├── header_utilisateur.dart
│   │   ├── shell_layout.dart
│   │   ├── barre_navigation.dart
│   │   ├── bouton_ajout_central.dart
│   │   ├── badge_notification.dart
│   │   ├── tile_raccourci.dart
│   │   └── moyen_paiement_ajout_sheet.dart
│   │
│   ├── authentification/                ← SHARED (un seul dossier pour tous)
│   │   ├── carte_role.dart
│   │   ├── champ_telephone.dart
│   │   ├── saisie_otp.dart
│   │   ├── pave_pin.dart
│   │   ├── selecteur_coop.dart
│   │   └── selecteur_langue.dart
│   │
│   ├── messages/                        ← SHARED (chat — un seul dossier)
│   │   ├── tuile_conversation.dart      (item liste conversations)
│   │   ├── bulle_message.dart           (bubble du chat)
│   │   ├── entete_chat.dart             (header conversation)
│   │   ├── champ_saisie_message.dart
│   │   └── avatar_bot.dart              (distinguer IA vs humain)
│   │
│   ├── notifications/                   ← SHARED (centre notifs — un seul)
│   │   ├── tuile_notification.dart
│   │   ├── grouper_par_jour.dart
│   │   └── etat_vide_notif.dart
│   │
│   ├── producteur/                      ← Spécifique role farmer
│   │   ├── accueil/
│   │   ├── annonces/
│   │   ├── commandes/
│   │   ├── parcelles/
│   │   ├── publier/
│   │   ├── publications/
│   │   ├── sollicitations/
│   │   ├── ai/
│   │   ├── wallet/
│   │   ├── transactions/
│   │   └── profil/
│   │
│   ├── acheteur/                        ← Spécifique role buyer
│   │   ├── accueil/
│   │   ├── marche/
│   │   ├── commandes/
│   │   ├── recherche/
│   │   ├── demandes/
│   │   ├── wallet/
│   │   ├── transactions/
│   │   └── profil/
│   │
│   ├── cooperative/                     ← Spécifique role coop
│   │   ├── accueil/
│   │   ├── membres/
│   │   ├── annonces/
│   │   ├── publications/
│   │   ├── sollicitations/
│   │   ├── finance/
│   │   ├── logistique/
│   │   ├── stock/
│   │   ├── avances/
│   │   ├── transactions/
│   │   └── profil/
│   │
│   └── transporteur/                    ← Spécifique role transporter
│       ├── accueil/
│       ├── missions/
│       ├── itineraires/
│       ├── confirmations/
│       ├── wallet/
│       ├── transactions/
│       └── profil/
│
├── theme/                               🇬🇧 standard
│   ├── app_theme.dart
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   └── app_dimens.dart
│
├── routing/                             🇬🇧 standard
│   ├── app_router.dart
│   ├── route_names.dart
│   └── route_guards.dart
│
├── storage/                             🇬🇧 standard
│   ├── secure_storage.dart
│   └── prefs_storage.dart
│
├── utils/                               🇬🇧 standard
│   ├── validators.dart
│   ├── formatters.dart
│   ├── permissions.dart
│   └── debouncer.dart
│
├── constants/                           🇬🇧 standard
│   └── app_constants.dart
│
└── l10n/                                🇬🇧 standard (Flutter)
    ├── app_fr.arb
    └── app_en.arb


# ═══════════════════════════════════════════════════════════════════════
# RÈGLES STRICTES
# ═══════════════════════════════════════════════════════════════════════

## 1. Pages = composition only

Toute page (`pages/.../*_page.dart`) doit assembler des widgets importés
depuis `widgets/...`. AUCUNE classe `_PrivateWidget` substantielle ne
doit vivre inline dans une page.

Acceptable inline dans une page :
- micro-helpers de moins de ~20 lignes (1 petit conteneur, 1 row simple)
- providers Riverpod scoped à la page

Inacceptable inline dans une page :
- sections complètes (header, hero, sticky buttons, sections de contenu)
- timelines, listes, cards composées
- dialogs ouverts depuis la page (extraire en fonction libre)
- toute classe `_Widget` qui dépasse ~30 lignes

## 2. Features communes = dossier SHARED top-level

Les features ci-dessous sont **identiques pour tous les rôles** et
DOIVENT vivre dans un dossier partagé top-level — JAMAIS dupliquées
par acteur :

- `widgets/messages/` (chat / conversations)
- `widgets/notifications/` (centre notifs)
- `widgets/authentification/` (login / signup / OTP / PIN)
- `widgets/communs/` (utilitaires : bouton, snackbar, chargement, etc.)

Idem côté pages : `pages/_shared/messages_page.dart` est partagée par
tous les rôles. Le routing utilise simplement la même page derrière
des routes différentes (`/acheteur/messages`, `/producteur/messages`,
etc.) — c'est juste un chemin, pas un dupliqué.

## 3. Features par acteur

Tout ce qui est métier-spécifique au rôle vit dans `widgets/<acteur>/<feature>/` :
- `accueil/` (KPI différents par rôle)
- `marche/` (acheteur uniquement)
- `parcelles/` (producteur uniquement)
- `missions/` (transporteur uniquement)
- `membres/` (coopérative uniquement)
- `profil/` (champs différents par rôle — KYC farmer ≠ adresse buyer)

## 4. Convention de nommage

- Fichiers : `snake_case.dart`, en français quand naturel
  (`carte_argent_commande.dart`, `section_acheteur.dart`).
- Classes publiques exportées : `PascalCase` français
  (`CarteArgentCommande`, `SectionAcheteur`, `ActionsCommandeProducteur`).
- Classes internes au fichier (privées) : `_PascalCase` avec underscore
  (`_BadgePartage`, `_BoutonConfirmer`).
- Doc-comment `///` au-dessus de CHAQUE classe publique exportée,
  expliquant le rôle du widget et où il est utilisé.

## 5. Process avant chaque modif de page

1. Si tu touches une page existante avec des `_PrivateWidget` inline
   substantiels → corrige la dette technique AVANT d'ajouter ton code.
2. Si tu crées un widget : décide s'il est partagé (messages/notifs/auth
   → shared top-level) ou métier-spécifique (`widgets/<acteur>/<feat>/`).
3. Une page neuve qui dépasse 200 lignes a probablement violé la règle —
   relire et extraire.
