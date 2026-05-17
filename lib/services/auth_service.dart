import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api_client/api_client.dart';
import '../api_client/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';

/// Auth — inscription, OTP, login PIN, refresh, profil.
///
/// Persiste les tokens dans le secure storage et expose `currentUser` pour
/// hydrater le state au démarrage.
class AuthService {
  final ApiClient _api;
  final FlutterSecureStorage _storage;

  AuthService(this._api) : _storage = _api.storage;

  // ─── Lecture locale ──────────────────────────────────────────────────

  Future<bool> hasValidSession() async {
    final access = await _storage.read(key: AppConstants.accessTokenKey);
    return access != null && access.isNotEmpty;
  }

  Future<String?> readAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  Future<String?> readRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  // ─── Inscription / OTP ───────────────────────────────────────────────

  /// Crée un compte. Renvoie l'utilisateur + déclenche un OTP automatiquement
  /// selon le flux backend.
  ///
  /// Le DTO backend `InscriptionDto` n'accepte QUE les champs ci-dessous.
  /// Les détails de profil métier (région, superficie, RCCM, etc.) doivent
  /// être persistés ultérieurement — actuellement aucun endpoint backend
  /// dédié n'existe pour ces champs (voir TODO côté backend pour
  /// `POST /auth/profile/producteur` etc.).
  Future<Map<String, dynamic>> register({
    required String phone,
    required UserRole role,
    required String fullName,
    String? email,
    String? langue,
    String? defaultCooperativeId,
  }) async {
    return _api.post<Map<String, dynamic>>(
      ApiEndpoints.authRegister,
      body: {
        'phone': phone,
        'full_name': fullName,
        'role': role.apiValue,
        if (email != null && email.isNotEmpty) 'email': email,
        if (langue != null) 'langue': langue,
        if (defaultCooperativeId != null)
          'default_cooperative_id': defaultCooperativeId,
      },
      options: Options(extra: {'skipAuth': true}),
    );
  }

  /// Demande l'envoi d'un OTP. Le `purpose` distingue les flows backend
  /// (REGISTER, LOGIN, RESET_PIN) et conditionne l'éventuelle vérification
  /// de l'existence du compte côté serveur.
  Future<void> sendOtp({
    required String phone,
    required OtpPurpose purpose,
  }) async {
    await _api.post<dynamic>(
      ApiEndpoints.authSendOtp,
      body: {'phone': phone, 'purpose': purpose.apiValue},
      options: Options(extra: {'skipAuth': true}),
    );
  }

  /// Vérifie un OTP. Le champ backend s'appelle `code`, pas `otp`.
  /// Le `purpose` doit matcher celui passé à [sendOtp].
  Future<AuthTokens> verifyOtp({
    required String phone,
    required String code,
    required OtpPurpose purpose,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.authVerifyOtp,
      body: {
        'phone': phone,
        'code': code,
        'purpose': purpose.apiValue,
      },
      options: Options(extra: {'skipAuth': true}),
    );
    final tokens = AuthTokens.fromJson(json);
    await _persistTokens(tokens);
    return tokens;
  }

  // ─── Connexion PIN ───────────────────────────────────────────────────

  Future<AuthTokens> loginWithPin({
    required String phone,
    required String pin,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.authLoginPin,
      body: {'phone': phone, 'pin': pin},
      options: Options(extra: {'skipAuth': true}),
    );
    final tokens = AuthTokens.fromJson(json);
    await _persistTokens(tokens);
    // La réponse `login-pin` ne renvoie qu'un user minimal (id, full_name,
    // role, cooperative_id). On enrichit immédiatement avec `me()` pour
    // disposer du téléphone, email, wallet_balance, etc. — pratique pour
    // l'UI et coût marginal (1 round-trip).
    try {
      final fullUser = await me();
      return tokens.copyWith(user: fullUser);
    } catch (_) {
      // Best-effort : si /me échoue, on garde le user minimal.
      return tokens;
    }
  }

  // ─── Refresh / logout ────────────────────────────────────────────────

  /// Force un refresh (rarement utile : l'interceptor le fait automatiquement
  /// sur 401).
  Future<AuthTokens> refresh() async {
    final refreshToken = await readRefreshToken();
    if (refreshToken == null) {
      throw StateError('No refresh token stored');
    }
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.authRefresh,
      body: {'refresh_token': refreshToken},
      options: Options(extra: {'skipAuth': true}),
    );
    final tokens = AuthTokens.fromJson(json);
    await _persistTokens(tokens);
    return tokens;
  }

  /// Déconnexion. Si [everywhere] est vrai, révoque toutes les sessions.
  Future<void> logout({bool everywhere = false}) async {
    final refreshToken = await readRefreshToken();
    try {
      await _api.post<dynamic>(
        ApiEndpoints.authLogout,
        body: {
          if (refreshToken != null) 'refresh_token': refreshToken,
          if (everywhere) 'everywhere': true,
        },
      );
    } finally {
      await clearLocalSession();
    }
  }

  Future<void> clearLocalSession() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.currentUserKey);
  }

  // ─── PIN ─────────────────────────────────────────────────────────────

  /// Définit le PIN initial. Le backend exige aussi `pin_confirm` pour
  /// éviter une saisie unique erronée — on passe la même valeur deux fois
  /// si le formulaire n'a qu'un seul champ.
  Future<void> setPin({
    required String pin,
    required String pinConfirm,
  }) async {
    await _api.post<dynamic>(
      ApiEndpoints.authSetPin,
      body: {'pin': pin, 'pin_confirm': pinConfirm},
    );
  }

  Future<void> changePin({
    required String oldPin,
    required String newPin,
    required String newPinConfirm,
  }) async {
    await _api.post<dynamic>(
      ApiEndpoints.authChangePin,
      body: {
        'old_pin': oldPin,
        'new_pin': newPin,
        'new_pin_confirm': newPinConfirm,
      },
    );
  }

  // ─── Profil ──────────────────────────────────────────────────────────

  Future<Utilisateur> me() async {
    final json = await _api.get<Map<String, dynamic>>(ApiEndpoints.authMe);
    return Utilisateur.fromJson(json);
  }

  Future<Utilisateur> updateProfile({
    String? fullName,
    String? email,
    String? photoUrl,
    Map<String, dynamic>? extra,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.authUpdateProfile,
      body: {
        if (fullName != null) 'full_name': fullName,
        if (email != null) 'email': email,
        if (photoUrl != null) 'photo_url': photoUrl,
        if (extra != null) ...extra,
      },
    );
    return Utilisateur.fromJson(json);
  }

  /// Met à jour le profil étendu selon le rôle.
  ///
  /// - `FARMER` → `POST /auth/profile/producteur`
  /// - `BUYER` → `POST /auth/profile/acheteur`
  /// - `COOPERATIVE` → `POST /auth/profile/cooperative`
  /// - `TRANSPORTER` → `POST /auth/profile/transporteur`
  /// - `EXPORTER` / `ADMIN` : pas de profil étendu mobile → no-op.
  ///
  /// Auth requise — donc à appeler APRÈS verifyOtp + setPin.
  Future<void> updateRoleProfile({
    required UserRole role,
    required Map<String, dynamic> profile,
  }) async {
    if (profile.isEmpty) return;
    final String endpoint;
    switch (role) {
      case UserRole.farmer:
        endpoint = ApiEndpoints.authProfileProducteur;
        break;
      case UserRole.buyer:
        endpoint = ApiEndpoints.authProfileAcheteur;
        break;
      case UserRole.cooperative:
        endpoint = ApiEndpoints.authProfileCooperative;
        break;
      case UserRole.transporter:
        endpoint = ApiEndpoints.authProfileTransporteur;
        break;
      case UserRole.exporter:
      case UserRole.admin:
      case UserRole.unknown:
        return;
    }
    await _api.post<dynamic>(endpoint, body: profile);
  }

  Future<void> registerDeviceToken({
    required String token,
    String? platform,
  }) async {
    await _api.post<dynamic>(
      ApiEndpoints.authDeviceToken,
      body: {
        'token': token,
        if (platform != null) 'platform': platform,
      },
    );
  }

  // ─── Private ─────────────────────────────────────────────────────────

  Future<void> _persistTokens(AuthTokens tokens) async {
    await _storage.write(
      key: AppConstants.accessTokenKey,
      value: tokens.accessToken,
    );
    await _storage.write(
      key: AppConstants.refreshTokenKey,
      value: tokens.refreshToken,
    );
  }
}
