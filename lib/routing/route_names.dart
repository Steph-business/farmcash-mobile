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

  /// Page de récupération : user authentifié SANS profil rôle (cas rare
  /// où le push best-effort post-PIN a échoué). Le guard auth y redirige
  /// pour éviter un crash dans les écrans qui supposent un profil joint.
  static const completerProfil = 'completer-profil';
  static const completerProfilPath = '/completer-profil';

  // ─── Onboarding obligatoire post-inscription ─────────────────────────
  // Wizards forcés par le guard auth quand le backend signale via
  // `essential_fields_complete == false` que le profil rôle existe mais
  // que les champs essentiels (région, cultures, zones, agrément…) ne
  // sont pas remplis. L'app cible des paysans peu tech / partiellement
  // analphabètes — on ne peut pas les laisser entrer dans l'app sans
  // collecter ces données minimales, sinon l'écosystème se pourrit de
  // profils vides.
  static const onboardingProducteur = 'onboarding-producteur';
  static const onboardingProducteurPath = '/onboarding/producteur';

  static const onboardingAcheteur = 'onboarding-acheteur';
  static const onboardingAcheteurPath = '/onboarding/acheteur';

  static const onboardingCooperative = 'onboarding-cooperative';
  static const onboardingCooperativePath = '/onboarding/cooperative';

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
  // Détail d'une conversation (chat 1-1 ou groupe). Partagée par les
  // 4 rôles → route top-level. `:id` = `conversationId` UUID.
  static const chatDetail = 'chat-detail';
  static const chatDetailPath = '/chat/:id';
  static String chatDetailPathFor(String convId) => '/chat/$convId';

  static const producteurPublierAnnonce = 'producteur-publier-annonce';
  static const producteurPublierAnnoncePath = '/producteur/publier-annonce';
  static const producteurAnnonceExpress = 'producteur-annonce-express';
  static const producteurAnnonceExpressPath = '/producteur/publier-annonce/express';
  // Créer une prévision de récolte (≠ annonce de vente). Le producteur
  // annonce une récolte à venir ; les acheteurs réservent une part avec
  // acompte. Accessible depuis l'onglet Prévisions de "Mes publications".
  static const producteurCreerPrevision = 'producteur-creer-prevision';
  static const producteurCreerPrevisionPath = '/producteur/previsions/creer';
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
  // Offres reçues sur mes annonces (propositions pending)
  static const producteurOffresRecues = 'producteur-offres-recues';
  static const producteurOffresRecuesPath = '/producteur/offres-recues';
  // Détail/discussion sur une offre reçue (candidature ou proposition).
  // L'id identifie la candidature OU la proposition ; le kind (kind=cand|prop)
  // est passé en query pour router vers le bon endpoint backend.
  static const producteurOffreDiscussion = 'producteur-offre-discussion';
  static const producteurOffreDiscussionPath =
      '/producteur/offres-recues/:id/discussion';
  static String producteurOffreDiscussionPathFor(String id, {required String kind}) =>
      '/producteur/offres-recues/$id/discussion?kind=$kind';
  // Réservations reçues sur mes prévisions de récolte — vue agrégée.
  static const producteurReservationsRecues = 'producteur-reservations-recues';
  static const producteurReservationsRecuesPath =
      '/producteur/reservations-recues';
  // Aperçu de ma coopérative (vue côté membre)
  static const producteurCooperative = 'producteur-cooperative';
  static const producteurCooperativePath = '/producteur/cooperative';
  // Détail d'une publication coop (publication agrégée par la coop)
  static const producteurPublicationCoopDetail =
      'producteur-publication-coop-detail';
  static const producteurPublicationCoopDetailPath =
      '/producteur/publications-coop/:id';
  static String producteurPublicationCoopDetailPathFor(String id) =>
      '/producteur/publications-coop/$id';
  // Mes ventes coop — historique des contributions du producteur aux
  // publications agrégées par sa coopérative (qte contribuée, statut,
  // net reçu après distribution).
  static const producteurVentesCoop = 'producteur-ventes-coop';
  static const producteurVentesCoopPath = '/producteur/ventes-coop';
  // Trouver une coopérative — annuaire public, recherche + filtre, tap
  // → demander à rejoindre. Utilisé quand le producteur n'est rattaché
  // à aucune coop (état vide « Ma coopérative »).
  static const producteurTrouverCoop = 'producteur-trouver-coop';
  static const producteurTrouverCoopPath = '/producteur/trouver-coop';
  // Mes demandes d'adhésion en cours (PENDING / ACCEPTED / REJECTED)
  // + invitations reçues par téléphone (acceptable / refusable).
  static const producteurInvitationsCoop = 'producteur-invitations-coop';
  static const producteurInvitationsCoopPath = '/producteur/invitations-coop';
  // Profil & paramètres (push top-level — pattern iOS Settings)
  static const producteurProfilSettings = 'producteur-profil-settings';
  static const producteurProfilSettingsPath =
      '/producteur/profil-settings';
  // Édition du profil (formulaire info perso)
  static const producteurProfilEditer = 'producteur-profil-editer';
  static const producteurProfilEditerPath = '/producteur/profil/editer';
  // Documents KYC (justificatifs : CNI, photo exploitation, etc.)
  static const producteurDocumentsKyc = 'producteur-documents-kyc';
  static const producteurDocumentsKycPath = '/producteur/documents-kyc';
  // Centre d'aide (FAQ + contact)
  static const producteurAide = 'producteur-aide';
  static const producteurAidePath = '/producteur/aide';
  // Opportunités matching intelligent — demandes d'achat qui matchent les
  // cultures déclarées du producteur connecté. Accessible depuis le CTA
  // « Voir toutes les opportunités » sur l'accueil.
  static const producteurOpportunites = 'producteur-opportunites';
  static const producteurOpportunitesPath = '/producteur/opportunites';

  // ─── Outils IA producteur (push hors shell) ──────────────────────────
  // Diagnostiquer une plante (photo → maladie + traitements)
  static const producteurAiAnalysePlante = 'producteur-ai-analyse-plante';
  static const producteurAiAnalysePlantePath =
      '/producteur/ai/analyse-plante';
  // Historique des analyses passées
  static const producteurAiAnalysesHistorique =
      'producteur-ai-analyses-historique';
  static const producteurAiAnalysesHistoriquePath = '/producteur/ai/analyses';
  // Assistant conversationnel agronomique
  static const producteurAiAssistant = 'producteur-ai-assistant';
  static const producteurAiAssistantPath = '/producteur/ai/assistant';
  // Feed d'actualités filtrées
  static const producteurAiActualites = 'producteur-ai-actualites';
  static const producteurAiActualitesPath = '/producteur/ai/actualites';
  // Détail d'une actualité
  static const producteurAiActualiteDetail =
      'producteur-ai-actualite-detail';
  static const producteurAiActualiteDetailPath =
      '/producteur/ai/actualites/:id';
  static String producteurAiActualiteDetailPathFor(String id) =>
      '/producteur/ai/actualites/$id';
  // Référentiel des traitements
  static const producteurAiCatalogueTraitements =
      'producteur-ai-catalogue-traitements';
  static const producteurAiCatalogueTraitementsPath =
      '/producteur/ai/catalogue-traitements';

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
  // Détail d'une publication coop côté acheteur — vue achat (qte + prix
  // + garanties coop + intervalle récolte). Distincte du détail annonce
  // solo car la mécanique d'achat passe par publications_stock_coop.
  static const acheteurPublicationCoopDetail =
      'acheteur-publication-coop-detail';
  static const acheteurPublicationCoopDetailPath =
      '/acheteur/publications-coop/:id';
  static String acheteurPublicationCoopDetailPathFor(String id) =>
      '/acheteur/publications-coop/$id';
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
  // Page autonome « Négociations » accessible depuis la tuile sur
  // l'accueil. Reprend le contenu de l'ancien onglet « Négociations »
  // dans Mes commandes (sorti pour clarification conceptuelle :
  // une négociation n'est pas encore une commande).
  static const acheteurNegociations = 'acheteur-negociations';
  static const acheteurNegociationsPath = '/acheteur/negociations';
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
  // Tracking position transporteur en temps réel (push depuis le suivi)
  static const acheteurLivraisonTracking = 'acheteur-livraison-tracking';
  static const acheteurLivraisonTrackingPath =
      '/acheteur/commandes/:id/tracking';
  static String acheteurLivraisonTrackingPathFor(String id) =>
      '/acheteur/commandes/$id/tracking';
  // Évaluation du transport après livraison (push depuis le détail commande)
  static const acheteurCommandeEvaluation = 'acheteur-commande-evaluation';
  static const acheteurCommandeEvaluationPath =
      '/acheteur/commandes/:id/evaluation';
  static String acheteurCommandeEvaluationPathFor(String id) =>
      '/acheteur/commandes/$id/evaluation';
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
  // Adresses de livraison (push depuis profil + panier + paiement)
  static const acheteurAdressesLivraison = 'acheteur-adresses-livraison';
  static const acheteurAdressesLivraisonPath =
      '/acheteur/adresses-livraison';
  // Mes favoris (annonces sauvegardées, push depuis profil)
  static const acheteurFavoris = 'acheteur-favoris';
  static const acheteurFavorisPath = '/acheteur/favoris';
  // Profil public d'un vendeur (producteur ou coop) — vue acheteur,
  // info masquée par data masking selon partage de coop (PARTIAL/FULL).
  static const acheteurVendeurDetail = 'acheteur-vendeur-detail';
  static const acheteurVendeurDetailPath = '/acheteur/vendeurs/:farmerId';
  static String acheteurVendeurDetailPathFor(String farmerId) =>
      '/acheteur/vendeurs/$farmerId';

  // ─── Onglets COOPÉRATIVE ─────────────────────────────────────────────
  static const cooperativeMembres = 'cooperative-membres';
  static const cooperativeMembresPath = '/cooperative/membres';
  static const cooperativeStockPath = '/cooperative/stock';
  static const cooperativeMarchePath = '/cooperative/marche';
  // Sub-routes (accessibles via header avatar / actions)
  static const cooperativeProfilPath = '/cooperative/profil';
  static const cooperativeMessages = 'cooperative-messages';
  static const cooperativeMessagesPath = '/cooperative/messages';
  // ⚠️ `cooperativeAvancesPath` retiré 2026-06-06 — constante orpheline
  // sans GoRoute (404 « no routes for location »). La page « Verser une
  // avance » (cooperativeVerserAvancePath) est l'écran principal — tous
  // les call sites doivent pointer dessus directement.
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
  // Enregistrer un farmer géré (sans téléphone) — saisie en présentiel par
  // la coop d'un producteur sans smartphone. La coop publiera ensuite les
  // annonces au nom du farmer via `act_as_farmer_id`.
  static const cooperativeMembreEnregistrer = 'cooperative-membre-enregistrer';
  static const cooperativeMembreEnregistrerPath =
      '/cooperative/membres/enregistrer';
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
  // Détail d'une publication coop (vue COOP propriétaire : stats,
  // commandes reçues, action « fermer la publication »). Distinct de la
  // vue PRODUCTEUR/membre, qui montre la quote-part du membre dans
  // l'agrégat.
  static const cooperativePublicationCoopDetail =
      'cooperative-publication-coop-detail';
  static const cooperativePublicationCoopDetailPath =
      '/cooperative/publications/:id';
  static String cooperativePublicationCoopDetailPathFor(String id) =>
      '/cooperative/publications/$id';
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
  // Planifier une collecte interne (membre → coop)
  static const cooperativeCollecteCreer = 'cooperative-collecte-creer';
  static const cooperativeCollecteCreerPath = '/cooperative/collectes/creer';

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
  // Ajouter un itinéraire (push top-level — historiquement nommé
  // "vehicule-ajouter" car la maquette posait la route comme une
  // caractéristique du véhicule, mais c'est bien une route au sens
  // backend qui se crée ici).
  static const transporteurVehiculeAjouter = 'transporteur-vehicule-ajouter';
  static const transporteurVehiculeAjouterPath =
      '/transporteur/vehicule-ajouter';
  // Créer un véhicule (POST /logistics/vehicles) — distinct de l'itinéraire
  static const transporteurVehiculeCreer = 'transporteur-vehicule-creer';
  static const transporteurVehiculeCreerPath =
      '/transporteur/vehicules/creer';
  // Mes véhicules — liste (push depuis profil settings / profil)
  static const transporteurMesVehicules = 'transporteur-mes-vehicules';
  static const transporteurMesVehiculesPath = '/transporteur/vehicules';
  // Mes documents officiels (permis + carte grise) — push depuis profil.
  static const transporteurMesDocuments = 'transporteur-mes-documents';
  static const transporteurMesDocumentsPath = '/transporteur/documents';
  // Historique des missions terminées (push depuis l'onglet Missions)
  static const transporteurMissionsHistorique =
      'transporteur-missions-historique';
  static const transporteurMissionsHistoriquePath =
      '/transporteur/missions/historique';
  // Détail d'une demande entrante avant acceptation (push depuis la liste)
  static const transporteurDemandeDetail = 'transporteur-demande-detail';
  static const transporteurDemandeDetailPath =
      '/transporteur/demandes-entrantes/:id';
  static String transporteurDemandeDetailPathFor(String id) =>
      '/transporteur/demandes-entrantes/$id';
  // Évaluation après livraison confirmée (push depuis livraison_confirme)
  static const transporteurMissionEvaluation =
      'transporteur-mission-evaluation';
  static const transporteurMissionEvaluationPath =
      '/transporteur/missions/:id/evaluation';
  static String transporteurMissionEvaluationPathFor(String id) =>
      '/transporteur/missions/$id/evaluation';

  // ─── Pages partagées (paramètres, aide, conditions) ──────────────────
  // Mutualisées entre les 4 rôles — pas de préfixe de rôle dans le path,
  // le contenu détecte le rôle via `currentUserProvider` si besoin.
  static const langue = 'langue';
  static const languePath = '/parametres/langue';

  static const securite = 'securite';
  static const securitePath = '/parametres/securite';

  static const notificationsPreferences = 'notifications-preferences';
  static const notificationsPreferencesPath = '/parametres/notifications';

  static const aide = 'aide';
  static const aidePath = '/aide';

  static const conditions = 'conditions';
  static const conditionsPath = '/conditions';

  static const moyensPaiement = 'moyens-paiement';
  static const moyensPaiementPath = '/parametres/moyens-paiement';

  // Signaler un problème (ouvre un litige) — partagé acheteur / vendeur,
  // le contenu de la page détecte le rôle pour adapter les motifs.
  static const signalerProbleme = 'signaler-probleme';
  static const signalerProblemePath = '/litige/:id';
  static String signalerProblemePathFor(String commandeId) =>
      '/litige/$commandeId';

  // ─── Pages métier acheteur (push hors shell) ─────────────────────────
  // Identité business — consolide entreprise/RCCM/zones d'achat en une
  // seule page éditable.
  static const acheteurMonEntreprise = 'acheteur-mon-entreprise';
  static const acheteurMonEntreprisePath = '/acheteur/mon-entreprise';

  // Plans d'approvisionnement B2B (chantier 2)
  static const acheteurMesPlans = 'acheteur-mes-plans';
  static const acheteurMesPlansPath = '/acheteur/plans';
  static const acheteurCreerPlan = 'acheteur-creer-plan';
  static const acheteurCreerPlanPath = '/acheteur/plans/creer';
  static const acheteurDetailPlan = 'acheteur-detail-plan';
  static String acheteurDetailPlanPathFor(String id) =>
      '/acheteur/plans/$id';

  // ─── Pages métier coopérative (push hors shell) ──────────────────────
  // Mes commandes coop — suivi des ventes directes (coop est vendeuse
  // sur ses propres publications).
  static const cooperativeCommandes = 'cooperative-commandes';
  static const cooperativeCommandesPath = '/cooperative/commandes';

  static const cooperativeIdentite = 'cooperative-identite';
  static const cooperativeIdentitePath = '/cooperative/identite';

  static const cooperativeCommission = 'cooperative-commission';
  static const cooperativeCommissionPath = '/cooperative/commission';

  static const cooperativeDocumentsOfficiels =
      'cooperative-documents-officiels';
  static const cooperativeDocumentsOfficielsPath =
      '/cooperative/documents-officiels';

  // Contre-offres reçues par la coop sur ses publications (BUYER → COOP).
  // Page de gestion : liste filtrable + actions Accepter/Rejeter/Contre-proposer.
  static const cooperativeContreOffresRecues =
      'cooperative-contre-offres-recues';
  static const cooperativeContreOffresRecuesPath =
      '/cooperative/contre-offres-recues';

  // Plans d'approvisionnement B2B (chantier 2) — côté fournisseur.
  static const cooperativePlansPublics = 'cooperative-plans-publics';
  static const cooperativePlansPublicsPath = '/cooperative/plans-b2b';
  static const cooperativeMesContratsB2B = 'cooperative-mes-contrats-b2b';
  static const cooperativeMesContratsB2BPath =
      '/cooperative/contrats-b2b';

  // ─── Pages métier transporteur (push hors shell) ─────────────────────
  static const transporteurTarification = 'transporteur-tarification';
  static const transporteurTarificationPath =
      '/transporteur/tarification';
}
