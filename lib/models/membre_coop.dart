import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'utilisateur.dart';

part 'membre_coop.freezed.dart';
part 'membre_coop.g.dart';

@freezed
class MembreCoop with _$MembreCoop {
  const MembreCoop._();

  /// Membre d'une coopérative.
  ///
  /// Un membre peut être :
  ///   • **autonome** — le farmer a un compte avec téléphone et se connecte
  ///     à l'app (`managedByCoopId` est null) ;
  ///   • **géré** — créé directement par la coop sans téléphone
  ///     (`managedByCoopId` pointe vers la coop qui le gère). La coop
  ///     publie alors les annonces au nom du farmer via `act_as_farmer_id`.
  ///
  /// Le champ [phone] est aussi exposé à plat pour distinguer
  /// rapidement géré vs autonome sans avoir à charger l'objet `user`.
  const factory MembreCoop({
    required String id,
    required String cooperativeId,
    required String userId,
    Utilisateur? user,
    @JsonKey(unknownEnumValue: CoopMemberRole.unknown)
    @Default(CoopMemberRole.membre)
    CoopMemberRole role,
    DateTime? joinedAt,
    /// Téléphone du membre (plat) — null pour les farmers gérés.
    /// Si présent, on privilégie `user?.phone` ; sinon on fallback ici.
    @JsonKey(name: 'phone') String? phoneFlat,
    /// Id de la coopérative qui gère ce farmer s'il n'a pas de téléphone.
    /// Null = farmer autonome.
    @JsonKey(name: 'managed_by_coop_id') String? managedByCoopId,
  }) = _MembreCoop;

  factory MembreCoop.fromJson(Map<String, dynamic> json) =>
      _$MembreCoopFromJson(json);

  String? get fullName => user?.fullName;
  String? get phone => user?.phone ?? phoneFlat;
  String? get photoUrl => user?.photoUrl;

  /// `true` si ce membre est géré par la coop (pas de téléphone, pas de
  /// compte connectable). La coop publie au nom du farmer.
  bool get estGere => managedByCoopId != null;
}

/// Demande FARMER → COOP pour rejoindre.
@freezed
class CoopJoinRequest with _$CoopJoinRequest {
  const factory CoopJoinRequest({
    required String id,
    required String cooperativeId,
    required String farmerId,
    @Default('PENDING') String status,
    String? message,
    DateTime? createdAt,
  }) = _CoopJoinRequest;

  factory CoopJoinRequest.fromJson(Map<String, dynamic> json) =>
      _$CoopJoinRequestFromJson(json);
}

/// Invitation COOP → FARMER (par téléphone).
@freezed
class CoopInvitation with _$CoopInvitation {
  const factory CoopInvitation({
    required String id,
    required String cooperativeId,
    @Default('') String phone,
    @Default('PENDING') String status,
    String? message,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) = _CoopInvitation;

  factory CoopInvitation.fromJson(Map<String, dynamic> json) =>
      _$CoopInvitationFromJson(json);
}
