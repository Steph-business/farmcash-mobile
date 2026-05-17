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
│   ├── authentification/                ← AUTH (inscription + connexion)
│   │   ├── splash_page.dart             ← Démarrage logo
│   │   ├── bienvenue_page.dart          ← "Commencer" / "J'ai un compte"
│   │   ├── choix_role_page.dart         ← Producteur/Acheteur/Coop/Transporteur
│   │   ├── inscription_page.dart        ← Tel + nom (+ coop si producteur)
│   │   ├── otp_page.dart                ← Code SMS 6 chiffres
│   │   ├── definir_pin_page.dart        ← Création PIN
│   │   ├── connexion_page.dart          ← Login PIN (tel mémorisé)
│   │   └── pin_oublie_page.dart         ← Reset PIN via OTP
│   │
│   ├── producteur/                      ← FARMER
│   │   ├── accueil_page.dart
│   │   ├── annonces_page.dart
│   │   ├── messages_page.dart
│   │   ├── transactions_page.dart
│   │   └── profil_page.dart
│   │
│   ├── acheteur/                        ← BUYER
│   │   ├── accueil_page.dart
│   │   ├── recherche_page.dart
│   │   ├── commandes_page.dart
│   │   ├── messages_page.dart
│   │   ├── transactions_page.dart
│   │   └── profil_page.dart
│   │
│   ├── cooperative/                     ← COOP
│   │   ├── accueil_page.dart
│   │   ├── membres_page.dart
│   │   ├── annonces_page.dart
│   │   ├── publications_page.dart
│   │   ├── avances_page.dart
│   │   ├── messages_page.dart
│   │   ├── transactions_page.dart
│   │   └── profil_page.dart
│   │
│   └── transporteur/                    ← TRANSPORTER
│       ├── accueil_page.dart
│       ├── missions_page.dart
│       ├── itineraires_page.dart
│       ├── messages_page.dart
│       ├── transactions_page.dart
│       └── profil_page.dart
│
├── widgets/                             🇫🇷 métier
│   │
│   ├── authentification/                ← Widgets dédiés à l'auth
│   │   ├── carte_role.dart              ← Carte cliquable choix rôle
│   │   ├── champ_telephone.dart         ← Input +225 préfixé
│   │   ├── saisie_otp.dart              ← 6 cases auto-fill SMS
│   │   ├── pave_pin.dart                ← Pavé numérique custom
│   │   ├── selecteur_coop.dart          ← Autocomplete coop
│   │   └── selecteur_langue.dart        ← Fr/En
│   │
│   ├── communs/
│   │   ├── bouton_principal.dart
│   │   ├── bouton_secondaire.dart
│   │   ├── chargement.dart
│   │   ├── etat_vide.dart
│   │   ├── vue_erreur.dart
│   │   ├── champ_recherche.dart
│   │   ├── puce_statut.dart
│   │   └── snackbars.dart
│   │
│   ├── producteur/
│   │   ├── accueil/
│   │   │   ├── carte_kpi.dart
│   │   │   ├── graphique_revenus.dart
│   │   │   ├── banniere_alertes.dart
│   │   │   ├── liste_actions_attente.dart
│   │   │   └── action_rapide.dart
│   │   ├── annonces/
│   │   │   ├── carte_annonce.dart
│   │   │   ├── formulaire_annonce.dart
│   │   │   ├── selecteur_produit.dart
│   │   │   ├── selecteur_traitements.dart
│   │   │   ├── bascule_coop.dart
│   │   │   └── selecteur_coordonnees.dart
│   │   ├── messages/
│   │   │   ├── tuile_conversation.dart
│   │   │   └── bulle_message.dart
│   │   ├── transactions/
│   │   │   ├── carte_solde.dart
│   │   │   ├── tuile_transaction.dart
│   │   │   └── formulaire_retrait.dart
│   │   └── profil/
│   │       ├── selecteur_avatar.dart
│   │       └── parametres_producteur.dart
│   │
│   ├── acheteur/
│   │   ├── accueil/
│   │   │   ├── carte_annonce.dart
│   │   │   ├── barre_filtres.dart
│   │   │   └── puces_categories.dart
│   │   ├── recherche/
│   │   │   ├── filtres_recherche.dart
│   │   │   └── recherches_recentes.dart
│   │   ├── commandes/
│   │   │   ├── carte_commande.dart
│   │   │   ├── chronologie_statut.dart
│   │   │   └── suivi_livraison.dart
│   │   ├── messages/
│   │   ├── transactions/
│   │   └── profil/
│   │
│   ├── cooperative/
│   │   ├── accueil/
│   │   │   ├── kpi_coop.dart
│   │   │   ├── actions_attente.dart
│   │   │   └── top_contributeurs.dart
│   │   ├── membres/
│   │   │   ├── tuile_membre.dart
│   │   │   ├── carte_demande_adhesion.dart
│   │   │   └── formulaire_invitation.dart
│   │   ├── annonces/
│   │   │   ├── annonce_a_valider.dart
│   │   │   ├── feuille_validation.dart
│   │   │   └── formulaire_agregation.dart
│   │   ├── publications/
│   │   │   ├── carte_publication.dart
│   │   │   └── liste_contributeurs.dart
│   │   ├── avances/
│   │   │   ├── formulaire_avance.dart
│   │   │   └── tuile_avance.dart
│   │   ├── messages/
│   │   ├── transactions/
│   │   └── profil/
│   │
│   └── transporteur/
│       ├── accueil/
│       │   ├── carte_mission.dart
│       │   └── graphique_gains.dart
│       ├── missions/
│       │   ├── carte_suivi.dart
│       │   ├── bouton_statut.dart
│       │   └── camera_preuve_livraison.dart
│       ├── itineraires/
│       │   ├── carte_itineraire.dart
│       │   └── formulaire_itineraire.dart
│       ├── messages/
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