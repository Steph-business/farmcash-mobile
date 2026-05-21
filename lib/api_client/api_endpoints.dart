/// Toutes les routes du backend FarmCash.
///
/// Convention : les chemins ici N'incluent PAS le préfixe `/api` car
/// `Dio.options.baseUrl` est déjà configuré avec `<host>/api`.
///
/// Pour les paramètres dynamiques, utiliser les helpers (`orderById(id)`).
class ApiEndpoints {
  ApiEndpoints._();

  // ─── AUTH ────────────────────────────────────────────────────────────
  static const String authHealth = '/auth/health';
  static const String authRegister = '/auth/register';
  static const String authSendOtp = '/auth/send-otp';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authLoginPin = '/auth/login-pin';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authSetPin = '/auth/set-pin';
  static const String authChangePin = '/auth/change-pin';
  static const String authMe = '/auth/me';
  static const String authUpdateProfile = '/auth/profile/update';
  static const String authProfileProducteur = '/auth/profile/producteur';
  static const String authProfileAcheteur = '/auth/profile/acheteur';
  static const String authProfileCooperative = '/auth/profile/cooperative';
  static const String authProfileTransporteur = '/auth/profile/transporteur';
  static const String authDeviceToken = '/auth/device-token';

  // ─── KYC (justificatifs d'identité, parcelles, etc.) ─────────────────
  static const String authKycMy = '/auth/kyc/my';
  static const String authKycUpload = '/auth/kyc/upload';
  static String authKycById(String id) => '/auth/kyc/$id';

  // ─── BUYER ADRESSES de livraison ────────────────────────────────────
  static const String buyerAddresses = '/buyer/addresses';
  static String buyerAddressById(String id) => '/buyer/addresses/$id';

  // ─── LOGISTIQUE — véhicules du transporteur ─────────────────────────
  static const String vehiclesMy = '/logistics/vehicles/my';
  static const String vehicles = '/logistics/vehicles';
  static String vehicleById(String id) => '/logistics/vehicles/$id';

  // ─── LOGISTIQUE — missions acceptées du transporteur ────────────────
  static const String shipmentsMy = '/logistics/shipments/my';

  // ─── RÉSERVATIONS prévisions (acheteur) ─────────────────────────────
  static const String reservationsMy = '/marketplace/reservations/my';

  // ─── STOCKS — lots par entrepôt (FARMER + COOP) ─────────────────────
  static String entrepotLots(String entrepotId) =>
      '/marketplace/stocks/entrepots/$entrepotId/lots';

  // ─── SOLLICITATIONS — confirmation par la coop initiatrice ──────────
  static String sollicitationRecipientConfirm(
    String sollicitationId,
    String recipientId,
  ) =>
      '/coop/sollicitations/$sollicitationId/recipients/$recipientId/confirm';

  // ─── ÉVALUATION post-livraison (BUYER → TRANSPORTER) ───────────────
  static String shipmentEvaluation(String shipmentId) =>
      '/logistics/shipments/$shipmentId/evaluation';

  // ─── LOGISTIQUE COOP — parc véhicules ───────────────────────────────
  static const String coopVehicles = '/coop/logistics/vehicles';
  static String coopVehicleById(String id) => '/coop/logistics/vehicles/$id';

  // ─── LOGISTIQUE COOP — collectes internes ──────────────────────────
  static const String coopCollections = '/coop/logistics/collections';
  static String coopCollectionById(String id) =>
      '/coop/logistics/collections/$id';
  static String coopCollectionComplete(String id) =>
      '/coop/logistics/collections/$id/complete';

  // ─── MARKETPLACE — catalogue public ──────────────────────────────────
  static const String produits = '/marketplace/produits';
  static const String categories = '/marketplace/categories';
  static const String villes = '/marketplace/villes';

  // ─── MARKETPLACE — annonces vente ────────────────────────────────────
  static const String annoncesVente = '/marketplace/annonces/vente';
  static String annonceVenteById(String id) => '/marketplace/annonces/vente/$id';

  // ─── MARKETPLACE — annonces achat ────────────────────────────────────
  static const String annoncesAchat = '/marketplace/annonces/achat';
  static String annonceAchatById(String id) => '/marketplace/annonces/achat/$id';

  // ─── PANIER ──────────────────────────────────────────────────────────
  static const String panier = '/marketplace/panier';
  static const String panierAdd = '/marketplace/panier/add';
  static String panierItem(String itemId) => '/marketplace/panier/$itemId';

  // ─── INTERACTIONS (favoris, avis, médias) ────────────────────────────
  static const String favoris = '/marketplace/interactions/favoris';
  static const String favorisToggle = '/marketplace/interactions/favoris/toggle';
  static const String avis = '/marketplace/interactions/avis';
  static String avisById(String id) => '/marketplace/interactions/avis/$id';
  static const String medias = '/marketplace/interactions/medias';
  static const String mediasUpload =
      '/marketplace/interactions/medias/upload';
  static String mediaById(String id) => '/marketplace/interactions/medias/$id';

  // ─── STOCKS ──────────────────────────────────────────────────────────
  static const String entrepots = '/marketplace/stocks/entrepots';
  static String entrepotById(String id) => '/marketplace/stocks/entrepots/$id';
  static const String lots = '/marketplace/stocks/lots';
  static String lotById(String id) => '/marketplace/stocks/lots/$id';

  // ─── AGRONOMIE ───────────────────────────────────────────────────────
  static const String parcelles = '/marketplace/agronomie/parcelles';
  static String parcelleById(String id) =>
      '/marketplace/agronomie/parcelles/$id';
  static const String cultures = '/marketplace/agronomie/cultures';
  static String cultureById(String id) =>
      '/marketplace/agronomie/cultures/$id';

  // ─── PRÉVISIONS ──────────────────────────────────────────────────────
  static const String previsions = '/marketplace/previsions';
  static const String previsionsReserver = '/marketplace/previsions/reserver';
  static String previsionConvert(String id) =>
      '/marketplace/previsions/$id/convert';

  // ─── ORDERS ──────────────────────────────────────────────────────────
  static const String orders = '/orders';
  static const String ordersMy = '/orders/my';
  static String orderById(String id) => '/orders/$id';
  static String orderStatus(String id) => '/orders/$id/status';
  /// Paie une commande déjà créée (typiquement issue d'une candidature ou
  /// proposition acceptée — la commande existe mais le payin n'a pas été
  /// déclenché à la création).
  static String orderPay(String id) => '/orders/$id/pay';
  static const String disputes = '/orders/disputes';
  static const String disputesMy = '/orders/disputes/my';
  static String disputeResolve(String id) => '/orders/disputes/$id/resolve';

  // ─── FINANCE ─────────────────────────────────────────────────────────
  static const String wallet = '/finance/wallet';
  static const String confirmDelivery = '/finance/confirm-delivery';
  static const String releaseEscrow = '/finance/release-escrow';
  static const String reconciliation = '/finance/reconciliation';
  static const String payout = '/finance/payout';
  static const String moyensPayement = '/finance/moyens-payement';
  static String moyenPayementById(String id) =>
      '/finance/moyens-payement/$id';
  static const String payoutBatches = '/finance/payout-batches';
  // Chantier 4 — Wallet topup Mobile Money (idempotent).
  static const String walletTopup = '/finance/wallet/topup';
  static String walletTopupStatus(String transactionId) =>
      '/finance/wallet/topup/$transactionId';

  // ─── LOGISTIQUE ──────────────────────────────────────────────────────
  static const String routesMy = '/logistics/routes/my';
  static const String routes = '/logistics/routes';
  static String routeById(String id) => '/logistics/routes/$id';
  static const String quotes = '/logistics/quotes';
  static const String missionsAvailable = '/logistics/missions/available';
  static String shipmentAccept(String id) => '/logistics/shipments/$id/accept';
  static String shipmentStartLoading(String id) =>
      '/logistics/shipments/$id/start-loading';
  static String shipmentTrack(String id) => '/logistics/shipments/$id/track';
  static String shipmentDeliver(String id) =>
      '/logistics/shipments/$id/deliver';
  static String shipmentCancel(String id) => '/logistics/shipments/$id/cancel';
  static String shipmentTracking(String id) =>
      '/logistics/shipments/$id/tracking';
  // Chantier 1 — Pickup QR : FARMER génère le token, TRANSPORTER scanne.
  static String shipmentQrToken(String id) =>
      '/logistics/shipments/$id/qr-token';
  static String shipmentScanPickup(String id) =>
      '/logistics/shipments/$id/scan-pickup';

  // ─── MESSAGING ───────────────────────────────────────────────────────
  static const String conversations = '/messaging/conversations';
  static String conversationMessages(String id) =>
      '/messaging/conversations/$id/messages';
  static String conversationRead(String id) =>
      '/messaging/conversations/$id/read';
  // Chantier 5 — Phone proxy (Twilio-backed). Pas de webhook côté mobile.
  static const String phoneProxy = '/messaging/phone-proxy';

  // ─── NÉGOCIATION ─────────────────────────────────────────────────────
  static const String candidatures = '/negotiation/candidatures';
  static String candidatureTraiter(String id) =>
      '/negotiation/candidatures/$id/traiter';
  static String candidatureMessages(String id) =>
      '/negotiation/candidatures/$id/messages';
  static const String propositions = '/negotiation/propositions';
  static String propositionTraiter(String id) =>
      '/negotiation/propositions/$id/traiter';
  static String propositionMessages(String id) =>
      '/negotiation/propositions/$id/messages';
  static const String contreOffresCoop = '/negotiation/contre-offres-coop';
  static String contreOffreCoopTraiter(String id) =>
      '/negotiation/contre-offres-coop/$id/traiter';
  static String contreOffreCoopMessages(String id) =>
      '/negotiation/contre-offres-coop/$id/messages';

  // ─── NOTIFICATIONS ───────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationsStream = '/notifications/stream';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationById(String id) => '/notifications/$id';

  // ─── COOPERATIVES — public ───────────────────────────────────────────
  static const String cooperatives = '/cooperatives';
  static String cooperativeById(String id) => '/cooperatives/$id';
  static const String publicationsCoopList = '/cooperatives/publications/list';
  static String publicationCoopById(String id) =>
      '/cooperatives/publications/$id';

  // ─── COOP MANAGEMENT (rôle COOP) ─────────────────────────────────────
  static const String coopProfile = '/coop/profile';
  static const String coopJoinRequests = '/coop/join-requests';
  static String coopJoinRequestHandle(String id) =>
      '/coop/join-requests/$id/handle';
  static const String coopInvitations = '/coop/invitations';
  static const String coopInvitationsMy = '/coop/invitations/my';
  static String coopInvitationHandle(String id) =>
      '/coop/invitations/$id/handle';
  static const String coopMembers = '/coop/members';
  static String coopMemberById(String memberUserId) =>
      '/coop/members/$memberUserId';
  static String coopMemberRole(String memberUserId) =>
      '/coop/members/$memberUserId/role';
  static const String coopAnnoncesVenteAssigned =
      '/coop/annonces-vente/assigned';
  static String coopAnnonceVenteValidate(String id) =>
      '/coop/annonces-vente/$id/validate';
  static String coopAnnonceVenteReject(String id) =>
      '/coop/annonces-vente/$id/reject';
  static const String coopAnnoncesAchatIncoming =
      '/coop/annonces-achat/incoming';
  static const String coopPrevisionsAssigned = '/coop/previsions/assigned';
  static String coopPrevisionValidate(String id) =>
      '/coop/previsions/$id/validate';
  static String coopPrevisionReject(String id) =>
      '/coop/previsions/$id/reject';
  static const String coopPublicationsAggregate =
      '/coop/publications/aggregate';
  static String coopPublicationContributions(String id) =>
      '/coop/publications/$id/contributions';
  static String coopPublicationDistribute(String id) =>
      '/coop/publications/$id/distribute';
  static const String coopMyAnnonces = '/coop/my-annonces';
  static String coopMyAnnonceContext(String id) =>
      '/coop/my-annonces/$id/context';
  static const String coopAdvances = '/coop/advances';
  static String coopAdvancesByAnnonce(String annonceId) =>
      '/coop/advances/by-annonce/$annonceId';
  static const String coopPublications = '/coop/publications';
  static String coopPublicationById(String id) => '/coop/publications/$id';
  // Chantier 2 — Sollicitations multi-audience (MEMBRES/COOPS_VOISINES/INDEPENDANTS).
  static const String sollicitations = '/coop/sollicitations';
  static String sollicitationById(String id) => '/coop/sollicitations/$id';
  static String sollicitationRespond(String id) =>
      '/coop/sollicitations/$id/respond';
  static String sollicitationClose(String id) =>
      '/coop/sollicitations/$id/close';

  // ─── IA ──────────────────────────────────────────────────────────────
  static const String aiHealth = '/ai/health';
  static const String plantAnalyses = '/ai/plant-analyses';
  static String plantAnalysisById(String id) => '/ai/plant-analyses/$id';
  static const String treatments = '/ai/treatments';
  static String treatmentsForAnalysis(String analysisId) =>
      '/ai/treatments/for-analysis/$analysisId';
  static const String treatmentsSearch = '/ai/treatments/search';
  static String treatmentById(String id) => '/ai/treatments/$id';
  static String traceability(String lotId) => '/ai/traceability/$lotId';
  static const String assistantChat = '/ai/assistant/chat';
  static const String assistantHistory = '/ai/assistant/history';
  static const String assistantReset = '/ai/assistant/reset';
  static const String insightsMy = '/ai/insights/my';
  static const String news = '/ai/news';
  static String newsById(String id) => '/ai/news/$id';
  static const String adminNews = '/ai/admin/news';
}
