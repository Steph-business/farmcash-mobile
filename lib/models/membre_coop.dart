import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'utilisateur.dart';

part 'membre_coop.freezed.dart';
part 'membre_coop.g.dart';

@freezed
class MembreCoop with _$MembreCoop {
  const MembreCoop._();

  const factory MembreCoop({
    required String id,
    required String cooperativeId,
    required String userId,
    Utilisateur? user,
    @JsonKey(unknownEnumValue: CoopMemberRole.unknown)
    @Default(CoopMemberRole.membre)
    CoopMemberRole role,
    DateTime? joinedAt,
  }) = _MembreCoop;

  factory MembreCoop.fromJson(Map<String, dynamic> json) =>
      _$MembreCoopFromJson(json);

  String? get fullName => user?.fullName;
  String? get phone => user?.phone;
  String? get photoUrl => user?.photoUrl;
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
