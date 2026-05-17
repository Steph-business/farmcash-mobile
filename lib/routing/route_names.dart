/// Noms et chemins de toutes les routes de l'app.
///
/// Toujours référencer via ces constantes — JAMAIS de string littérale dans
/// les `context.go(...)` / `context.push(...)`.
class RouteNames {
  RouteNames._();

  // ─── Démarrage ───────────────────────────────────────────────────────
  static const splash = 'splash';
  static const splashPath = '/';

  static const bienvenue = 'bienvenue';
  static const bienvenuePath = '/bienvenue';

  // ─── Authentification ────────────────────────────────────────────────
  static const connexion = 'connexion';
  static const connexionPath = '/connexion';

  static const choixRole = 'choix-role';
  static const choixRolePath = '/inscription/role';

  static const inscription = 'inscription';
  static const inscriptionPath = '/inscription';

  static const otp = 'otp';
  static const otpPath = '/otp';

  static const definirPin = 'definir-pin';
  static const definirPinPath = '/pin/definir';

  static const pinOublie = 'pin-oublie';
  static const pinOubliePath = '/pin/oublie';

  // ─── Home par rôle (racines des shells) ──────────────────────────────
  static const accueilProducteur = 'accueil-producteur';
  static const accueilProducteurPath = '/producteur';

  static const accueilAcheteur = 'accueil-acheteur';
  static const accueilAcheteurPath = '/acheteur';

  static const accueilCooperative = 'accueil-cooperative';
  static const accueilCooperativePath = '/cooperative';

  static const accueilTransporteur = 'accueil-transporteur';
  static const accueilTransporteurPath = '/transporteur';

  // ─── Onglets PRODUCTEUR ──────────────────────────────────────────────
  static const producteurMessagesPath = '/producteur/messages';
  static const producteurCommandesPath = '/producteur/commandes';
  static const producteurProfilPath = '/producteur/profil';
  // Sub-routes accessibles depuis le profil ou actions
  static const producteurAnnoncesPath = '/producteur/annonces';
  static const producteurTransactionsPath = '/producteur/transactions';
  // Flow "Publier une annonce" — déclenché par le FAB central producteur
  static const producteurPublierAnnonce = 'producteur-publier-annonce';
  static const producteurPublierAnnoncePath = '/producteur/publier-annonce';
  static const producteurCreerParcelle = 'producteur-creer-parcelle';
  static const producteurCreerParcellePath = '/producteur/parcelles/creer';
  static const producteurMesParcelles = 'producteur-mes-parcelles';
  static const producteurMesParcellesPath = '/producteur/parcelles';
  // Détail d'une parcelle (depuis "Mes parcelles" ou accueil)
  static const producteurParcelleDetail = 'producteur-parcelle-detail';
  static const producteurParcelleDetailPath = '/producteur/parcelles/:id';
  static String producteurParcelleDetailPathFor(String id) =>
      '/producteur/parcelles/$id';
  // Notifications (push depuis l'icône cloche du header)
  static const producteurNotifications = 'producteur-notifications';
  static const producteurNotificationsPath = '/producteur/notifications';
  // Mes publications (annonces + prévisions) — top-level
  static const producteurMesPublications = 'producteur-mes-publications';
  static const producteurMesPublicationsPath = '/producteur/mes-publications';
  // Détail d'une annonce (mon annonce)
  static const producteurAnnonceDetail = 'producteur-annonce-detail';
  static const producteurAnnonceDetailPath = '/producteur/annonces/:id';
  static String producteurAnnonceDetailPathFor(String id) =>
      '/producteur/annonces/$id';
  // Détail d'une prévision
  static const producteurPrevisionDetail = 'producteur-prevision-detail';
  static const producteurPrevisionDetailPath = '/producteur/previsions/:id';
  static String producteurPrevisionDetailPathFor(String id) =>
      '/producteur/previsions/$id';
  // Wallet (push hors shell — solde, transactions, retrait, recharge)
  static const producteurWallet = 'producteur-wallet';
  static const producteurWalletPath = '/producteur/wallet';
  static const producteurWalletRecharger = 'producteur-wallet-recharger';
  static const producteurWalletRechargerPath = '/producteur/wallet/recharger';
  static const producteurWalletRetirer = 'producteur-wallet-retirer';
  static const producteurWalletRetirerPath = '/producteur/wallet/retirer';
  // Détail d'une commande (push depuis la liste commandes)
  static const producteurCommandeDetail = 'producteur-commande-detail';
  static const producteurCommandeDetailPath = '/producteur/commandes/:id';
  static String producteurCommandeDetailPathFor(String id) =>
      '/producteur/commandes/$id';
  // Bordereau d'enlèvement QR (push depuis la commande quand prête)
  static const producteurCommandeEnlevementQr =
      'producteur-commande-enlevement-qr';
  static const producteurCommandeEnlevementQrPath =
      '/producteur/commandes/:id/enlevement-qr';
  static String producteurCommandeEnlevementQrPathFor(String id) =>
      '/producteur/commandes/$id/enlevement-qr';
  // Écran final "Commande livrée" — confirmation + QR de traçabilité
  static const producteurCommandeTerminee = 'producteur-commande-terminee';
  static const producteurCommandeTermineePath =
      '/producteur/commandes/:id/terminee';
  static String producteurCommandeTermineePathFor(String id) =>
      '/producteur/commandes/$id/terminee';
  // Sollicitations reçues de la coop
  static const producteurSollicitations = 'producteur-sollicitations';
  static const producteurSollicitationsPath = '/producteur/sollicitations';
  // Répondre à une sollicitation
  static const producteurSollicitationRepondre =
      'producteur-sollicitation-repondre';
  static const producteurSollicitationRepondrePath =
      '/producteur/sollicitations/:id/repondre';
  static String producteurSollicitationRepondrePathFor(String id) =>
      '/producteur/sollicitations/$id/repondre';
  // Demandes d'achat (acheteurs qui cherchent)
  static const producteurDemandesAchat = 'producteur-demandes-achat';
  static const producteurDemandesAchatPath = '/producteur/demandes-achat';
  // Répondre à une demande d'achat (faire une proposition)
  static const producteurDemandeAchatRepondre =
      'producteur-demande-achat-repondre';
  static const producteurDemandeAchatRepondrePath =
      '/producteur/demandes-achat/:id/repondre';
  static String producteurDemandeAchatRepondrePathFor(String id) =>
      '/producteur/demandes-achat/$id/repondre';

  // ─── Onglets ACHETEUR ────────────────────────────────────────────────
  static const acheteurMessagesPath = '/acheteur/messages';
  static const acheteurPanierPath = '/acheteur/panier';
  static const acheteurCommandesPath = '/acheteur/commandes';
  static const acheteurProfilPath = '/acheteur/profil';
  // Sub-routes
  static const acheteurRecherchePath = '/acheteur/recherche';
  static const acheteurTransactionsPath = '/acheteur/transactions';
  // Flow Marché acheteur — onglet bottom-nav + détails + flow réservation prévision
  static const acheteurMarche = 'acheteur-marche';
  static const acheteurMarchePath = '/acheteur/marche';
  static const acheteurAnnonceDetail = 'acheteur-annonce-detail';
  static const acheteurAnnonceDetailPath = '/acheteur/annonces/:id';
  static String acheteurAnnonceDetailPathFor(String id) =>
      '/acheteur/annonces/$id';
  static const acheteurPrevisionDetail = 'acheteur-prevision-detail';
  static const acheteurPrevisionDetailPath = '/acheteur/previsions/:id';
  static String acheteurPrevisionDetailPathFor(String id) =>
      '/acheteur/previsions/$id';
  static const acheteurReservationPaiement = 'acheteur-reservation-paiement';
  static const acheteurReservationPaiementPath =
      '/acheteur/previsions/:id/reserver';
  static String acheteurReservationPaiementPathFor(String id) =>
      '/acheteur/previsions/$id/reserver';
  static const acheteurMesReservations = 'acheteur-mes-reservations';
  static const acheteurMesReservationsPath = '/acheteur/reservations';
  // Flow Demandes acheteur (publier + lister + propositions reçues)
  static const acheteurDemandes = 'acheteur-demandes';
  static const acheteurDemandesPath = '/acheteur/demandes';
  static const acheteurDemandePublier = 'acheteur-demande-publier';
  static const acheteurDemandePublierPath = '/acheteur/demandes/publier';
  static const acheteurPropositionsRecues = 'acheteur-propositions-recues';
  static const acheteurPropositionsRecuesPath =
      '/acheteur/demandes/:id/propositions';
  static String acheteurPropositionsRecuesPathFor(String id) =>
      '/acheteur/demandes/$id/propositions';
  // Flow Commande acheteur — choisir transporteur (depuis le paiement)
  static const acheteurChoisirTransporteur = 'acheteur-choisir-transporteur';
  static const acheteurChoisirTransporteurPath =
      '/acheteur/transporteurs/choisir';
  // Flow Commande acheteur — paiement → succès → détail → QR livraison
  static const acheteurPaiementCommande = 'acheteur-paiement-commande';
  static const acheteurPaiementCommandePath =
      '/acheteur/annonces/:id/paiement';
  static String acheteurPaiementCommandePathFor(String id) =>
      '/acheteur/annonces/$id/paiement';
  static const acheteurCommandeSucces = 'acheteur-commande-succes';
  static const acheteurCommandeSuccesPath = '/acheteur/commandes/:id/succes';
  static String acheteurCommandeSuccesPathFor(String id) =>
      '/acheteur/commandes/$id/succes';
  static const acheteurCommandeDetail = 'acheteur-commande-detail';
  static const acheteurCommandeDetailPath = '/acheteur/commandes/:id';
  static String acheteurCommandeDetailPathFor(String id) =>
      '/acheteur/commandes/$id';
  static const acheteurLivraisonQr = 'acheteur-livraison-qr';
  static const acheteurLivraisonQrPath =
      '/acheteur/commandes/:id/livraison-qr';
  static String acheteurLivraisonQrPathFor(String id) =>
      '/acheteur/commandes/$id/livraison-qr';
  static const acheteurNotifications = 'acheteur-notifications';
  static const acheteurNotificationsPath = '/acheteur/notifications';
  // Flow Wallet acheteur (push hors shell — solde, transactions, retrait, recharge)
  static const acheteurWallet = 'acheteur-wallet';
  static const acheteurWalletPath = '/acheteur/wallet';
  static const acheteurWalletRecharger = 'acheteur-wallet-recharger';
  static const acheteurWalletRechargerPath = '/acheteur/wallet/recharger';
  static const acheteurWalletRetirer = 'acheteur-wallet-retirer';
  static const acheteurWalletRetirerPath = '/acheteur/wallet/retirer';
  // Page profil & paramètres (push top-level, accessible depuis l'avatar header)
  static const acheteurProfilSettings = 'acheteur-profil-settings';
  static const acheteurProfilSettingsPath = '/acheteur/profil-settings';

  // ─── Onglets COOPÉRATIVE ─────────────────────────────────────────────
  static const cooperativeMembresPath = '/cooperative/membres';
  static const cooperativeStockPath = '/cooperative/stock';
  static const cooperativeMarchePath = '/cooperative/marche';
  // Sub-routes (accessibles via header avatar / actions)
  static const cooperativeProfilPath = '/cooperative/profil';
  static const cooperativeMessages = 'cooperative-messages';
  static const cooperativeMessagesPath = '/cooperative/messages';
  static const cooperativeAvancesPath = '/cooperative/avances';
  static const cooperativeTransactionsPath = '/cooperative/transactions';
  // Notifications (push depuis l'icône cloche du header)
  static const cooperativeNotifications = 'cooperative-notifications';
  static const cooperativeNotificationsPath = '/cooperative/notifications';
  // Profil & paramètres (push top-level — pattern iOS Settings)
  static const cooperativeProfilSettings = 'cooperative-profil-settings';
  static const cooperativeProfilSettingsPath =
      '/cooperative/profil-settings';
  // Demandes d'adhésion à valider (push depuis l'accueil / membres)
  static const cooperativeAdhesions = 'cooperative-adhesions';
  static const cooperativeAdhesionsPath = '/cooperative/adhesions';
  // Détail d'un membre de la coop (full info — règle 3b chantier 3)
  static const cooperativeMembreDetail = 'cooperative-membre-detail';
  static const cooperativeMembreDetailPath = '/cooperative/membres/:id';
  static String cooperativeMembreDetailPathFor(String id) =>
      '/cooperative/membres/$id';
  // Détail d'un entrepôt (lots stockés + capacité + bouton réception)
  static const cooperativeStockEntrepot = 'cooperative-stock-entrepot';
  static const cooperativeStockEntrepotPath =
      '/cooperative/stock/entrepots/:id';
  static String cooperativeStockEntrepotPathFor(String id) =>
      '/cooperative/stock/entrepots/$id';
  // Réception d'un nouveau lot (push depuis un entrepôt)
  static const cooperativeStockReception = 'cooperative-stock-reception';
  static const cooperativeStockReceptionPath = '/cooperative/stock/reception';
  // Collecte du jour (liste des livraisons farmers à venir)
  static const cooperativeCollecte = 'cooperative-collecte';
  static const cooperativeCollectePath = '/cooperative/collecte';
  // Pesée d'une livraison farmer (push depuis la collecte)
  static const cooperativePesee = 'cooperative-pesee';
  static const cooperativePeseePath = '/cooperative/livraisons/:id/peser';
  static String cooperativePeseePathFor(String id) =>
      '/cooperative/livraisons/$id/peser';
  // Inviter un farmer (push depuis l'onglet membres)
  static const cooperativeInviterFarmer = 'cooperative-inviter-farmer';
  static const cooperativeInviterFarmerPath = '/cooperative/inviter-farmer';
  // Finance coop — wallet (solde + transactions)
  static const cooperativeWallet = 'cooperative-wallet';
  static const cooperativeWalletPath = '/cooperative/wallet';
  // Finance coop — distributions à faire (liste payouts)
  static const cooperativePayouts = 'cooperative-payouts';
  static const cooperativePayoutsPath = '/cooperative/payouts';
  // Détail d'une distribution (répartition entre contributeurs)
  static const cooperativePayoutDetail = 'cooperative-payout-detail';
  static const cooperativePayoutDetailPath = '/cooperative/payouts/:id';
  static String cooperativePayoutDetailPathFor(String id) =>
      '/cooperative/payouts/$id';
  // Confirmation d'une distribution effectuée
  static const cooperativePayoutConfirmation =
      'cooperative-payout-confirmation';
  static const cooperativePayoutConfirmationPath =
      '/cooperative/payouts/:id/confirmation';
  static String cooperativePayoutConfirmationPathFor(String id) =>
      '/cooperative/payouts/$id/confirmation';
  // Verser une avance à un membre
  static const cooperativeVerserAvance = 'cooperative-verser-avance';
  static const cooperativeVerserAvancePath = '/cooperative/verser-avance';
  // Publier sur le marché coop (formulaire 2 étapes, accessible via FAB)
  static const cooperativePublicationCreer = 'cooperative-publication-creer';
  static const cooperativePublicationCreerPath =
      '/cooperative/publications/creer';
  // Offres d'achat reçues (acheteurs côté coop)
  static const cooperativeOffresRecues = 'cooperative-offres-recues';
  static const cooperativeOffresRecuesPath = '/cooperative/offres-recues';
  // Solliciter ses fournisseurs (membres, autres coops, indépendants)
  static const cooperativeSollicitationCreer =
      'cooperative-sollicitation-creer';
  static const cooperativeSollicitationCreerPath =
      '/cooperative/sollicitations/creer';
  // Suivi d'une sollicitation envoyée (engagements, progression)
  static const cooperativeSollicitationSuivi =
      'cooperative-sollicitation-suivi';
  static const cooperativeSollicitationSuiviPath =
      '/cooperative/sollicitations/:id/suivi';
  static String cooperativeSollicitationSuiviPathFor(String id) =>
      '/cooperative/sollicitations/$id/suivi';
  // Prévisions des membres (agrégation par produit)
  static const cooperativePrevisionsMembres =
      'cooperative-previsions-membres';
  static const cooperativePrevisionsMembresPath =
      '/cooperative/previsions-membres';
  // Logistique coop — parc, collectes, transferts, livraisons acheteurs
  static const cooperativeLogistique = 'cooperative-logistique';
  static const cooperativeLogistiquePath = '/cooperative/logistique';
  // Demander un transport (push depuis transfert "Trouver")
  static const cooperativeTransportDemande = 'cooperative-transport-demande';
  static const cooperativeTransportDemandePath =
      '/cooperative/transport-demande';
  // Ajouter un véhicule à la flotte coop (push depuis "Mon parc")
  static const cooperativeVehiculeAjouter = 'cooperative-vehicule-ajouter';
  static const cooperativeVehiculeAjouterPath =
      '/cooperative/vehicule-ajouter';

  // ─── Onglets TRANSPORTEUR ────────────────────────────────────────────
  static const transporteurMissionsPath = '/transporteur/missions';
  static const transporteurItinerairesPath = '/transporteur/itineraires';
  static const transporteurProfilPath = '/transporteur/profil';
  // Sub-routes
  static const transporteurMessagesPath = '/transporteur/messages';
  static const transporteurTransactionsPath = '/transporteur/transactions';
  // Détail d'une mission (push depuis la liste missions)
  static const transporteurMissionDetail = 'transporteur-mission-detail';
  static const transporteurMissionDetailPath = '/transporteur/missions/:id';
  static String transporteurMissionDetailPathFor(String id) =>
      '/transporteur/missions/$id';
  // Mission en route (push depuis Démarrer la mission)
  static const transporteurMissionEnRoute = 'transporteur-mission-en-route';
  static const transporteurMissionEnRoutePath =
      '/transporteur/missions/:id/en-route';
  static String transporteurMissionEnRoutePathFor(String id) =>
      '/transporteur/missions/$id/en-route';
  // Scanner QR (top-level, plein écran, pas d'helper d'id)
  static const transporteurScanner = 'transporteur-scanner';
  static const transporteurScannerPath = '/transporteur/scanner';
  // Confirmation d'enlèvement (push après scan QR producteur)
  static const transporteurEnlevementConfirme =
      'transporteur-enlevement-confirme';
  static const transporteurEnlevementConfirmePath =
      '/transporteur/missions/:id/enlevement-confirme';
  static String transporteurEnlevementConfirmePathFor(String id) =>
      '/transporteur/missions/$id/enlevement-confirme';
  // Confirmation de livraison (push après scan QR acheteur)
  static const transporteurLivraisonConfirme =
      'transporteur-livraison-confirme';
  static const transporteurLivraisonConfirmePath =
      '/transporteur/missions/:id/livraison-confirme';
  static String transporteurLivraisonConfirmePathFor(String id) =>
      '/transporteur/missions/$id/livraison-confirme';
  // Demandes de transport entrantes (push depuis l'onglet missions)
  static const transporteurDemandesEntrantes =
      'transporteur-demandes-entrantes';
  static const transporteurDemandesEntrantesPath =
      '/transporteur/demandes-entrantes';
  // Messages du transporteur (push top-level — pattern messages)
  static const transporteurMessages = 'transporteur-messages';
  // Notifications du transporteur (push depuis l'icône cloche du header)
  static const transporteurNotifications = 'transporteur-notifications';
  static const transporteurNotificationsPath =
      '/transporteur/notifications';
  // Profil & paramètres transporteur (push top-level — pattern iOS Settings)
  static const transporteurProfilSettings = 'transporteur-profil-settings';
  static const transporteurProfilSettingsPath =
      '/transporteur/profil-settings';
  // Wallet transporteur (push hors shell — solde, transactions, retrait, recharge)
  static const transporteurWallet = 'transporteur-wallet';
  static const transporteurWalletPath = '/transporteur/wallet';
  static const transporteurWalletRecharger = 'transporteur-wallet-recharger';
  static const transporteurWalletRechargerPath =
      '/transporteur/wallet/recharger';
  static const transporteurWalletRetirer = 'transporteur-wallet-retirer';
  static const transporteurWalletRetirerPath = '/transporteur/wallet/retirer';
  // Ajouter mon véhicule (push top-level depuis profil settings)
  static const transporteurVehiculeAjouter = 'transporteur-vehicule-ajouter';
  static const transporteurVehiculeAjouterPath =
      '/transporteur/vehicule-ajouter';
}
