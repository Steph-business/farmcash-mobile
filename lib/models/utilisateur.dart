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
