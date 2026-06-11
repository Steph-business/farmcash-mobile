import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';

/// Légal & confidentialité — suppression de compte, export de données,
/// enregistrement du consentement CGU/Privacy.
///
/// Couvre les obligations Apple/Google Play et la loi ivoirienne 2013-450
/// sur la protection des données personnelles. Le backend gère un
/// soft-delete 30 jours : l'utilisateur peut annuler sa demande pendant
/// cette période.
class LegalService {
  final ApiClient _api;

  LegalService(this._api);

  // ─── Suppression de compte (soft-delete 30 jours) ───────────────────

  /// Demande la suppression du compte. Côté backend : marque le compte
  /// comme `deletion_requested_at = now()` ; un cron purge réellement les
  /// données 30 jours plus tard. L'utilisateur peut annuler entre-temps.
  ///
  /// Échoue (4xx) si commandes en cours, escrow non libéré, etc. — le
  /// message backend doit alors s'afficher dans la snackbar UI.
  Future<Map<String, dynamic>> requestAccountDeletion() async {
    return _api.delete<Map<String, dynamic>>(
      ApiEndpoints.authAccountDelete,
    );
  }

  /// Annule une demande de suppression encore dans la fenêtre des 30
  /// jours. Réactive le compte sans perte de données.
  Future<Map<String, dynamic>> cancelAccountDeletion() async {
    return _api.post<Map<String, dynamic>>(
      ApiEndpoints.authAccountCancelDeletion,
    );
  }

  // ─── Export RGPD-like (toutes mes données en JSON) ──────────────────

  /// Récupère un dump JSON de toutes les données personnelles du user :
  /// profil, commandes, transactions, KYC, etc. Le mobile copie le
  /// contenu dans le presse-papier (ou propose un partage si dispo).
  Future<Map<String, dynamic>> exportAccountData() async {
    return _api.get<Map<String, dynamic>>(
      ApiEndpoints.authAccountExport,
    );
  }

  // ─── Consentement CGU / Politique de Confidentialité ────────────────

  /// Enregistre l'acceptation d'une version donnée des CGU et/ou de la
  /// Politique de Confidentialité. À appeler au premier lancement (modal
  /// bloquant) ou quand une nouvelle version est publiée.
  Future<Map<String, dynamic>> recordConsent({
    String? termsVersion,
    String? privacyVersion,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiEndpoints.authAccountConsent,
      body: {
        if (termsVersion != null) 'terms_version': termsVersion,
        if (privacyVersion != null) 'privacy_version': privacyVersion,
      },
    );
  }

  /// Lit l'état actuel du consentement (versions acceptées + dates).
  /// Permet au bandeau de consentement de savoir si une nouvelle
  /// acceptation est requise.
  Future<Map<String, dynamic>> getConsentStatus() async {
    return _api.get<Map<String, dynamic>>(
      ApiEndpoints.authAccountConsent,
    );
  }
}
