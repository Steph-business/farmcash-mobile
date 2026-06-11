import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'enums.dart';

part 'utilisateur.freezed.dart';
part 'utilisateur.g.dart';

/// Utilisateur retourné par `/auth/me` et embarqué dans diverses réponses.
@freezed
class Utilisateur with _$Utilisateur {
  const factory Utilisateur({
    required String id,
    // `phone` est nullable car certaines réponses backend (ex: login-pin)
    // renvoient un user minimal sans le téléphone — il faut alors appeler
    // `/auth/me` pour récupérer la version complète.
    String? phone,
    @JsonKey(unknownEnumValue: UserRole.unknown)
    @Default(UserRole.unknown)
    UserRole role,
    String? fullName,
    String? photoUrl,
    String? email,
    @Default(false) bool isVerified,
    @Default(true) bool isActive,
    @FlexDouble() @Default(0.0) double rating,
    @FlexDouble() @Default(0.0) double walletBalance,
    String? cooperativeId,
    DateTime? createdAt,
    /// Flag explicite backend : `true` si le profil étendu rôle existe.
    /// Si `false` côté FARMER/BUYER/COOPERATIVE → l'utilisateur a un user
    /// mais sans son profil rôle (le push best-effort post-inscription a
    /// échoué). Le guard mobile route alors vers la page de complétion.
    /// Default `true` pour rétrocompat (endpoints qui ne renvoient pas
    /// ce flag — login-pin minimal, anciens caches).
    @JsonKey(name: 'has_role_profile') @Default(true) bool hasRoleProfile,
    /// Flag backend (`/auth/me`) : `true` si le profil rôle a TOUTES les
    /// informations essentielles renseignées. Si `false` côté FARMER /
    /// BUYER / COOPERATIVE → le guard force le wizard d'onboarding pour
    /// bloquer l'entrée dans l'app tant que les champs minimaux ne sont
    /// pas remplis (sinon écosystème pourri par des profils vides).
    /// Default `true` pour rétrocompat (endpoints minimaux + transporteur
    /// qui a son propre onboarding).
    @JsonKey(name: 'essential_fields_complete')
    @Default(true)
    bool essentialFieldsComplete,
  }) = _Utilisateur;

  factory Utilisateur.fromJson(Map<String, dynamic> json) =>
      _$UtilisateurFromJson(json);
}

/// Réponse de `/auth/verify-otp`, `/auth/login-pin`, `/auth/refresh`.
@freezed
class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
    Utilisateur? user,
    int? expiresIn,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}
