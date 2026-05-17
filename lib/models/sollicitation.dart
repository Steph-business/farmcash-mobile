import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'sollicitation.freezed.dart';
part 'sollicitation.g.dart';

/// Sollicitation multi-audience d'une coopérative pour mobiliser
/// MEMBRES / COOPS_VOISINES / INDEPENDANTS sur une annonce d'achat
/// trop grosse pour ses seuls stocks. Statuts : OPEN, CLOSED, FULFILLED.
@freezed
class Sollicitation with _$Sollicitation {
  const factory Sollicitation({
    required String id,
    @JsonKey(name: 'cooperative_id') required String cooperativeId,
    @JsonKey(name: 'annonce_achat_id') required String annonceAchatId,
    @JsonKey(name: 'initiated_by') String? initiatedBy,
    String? message,
    /// Audiences cochées à la création : MEMBRES, COOPS_VOISINES, INDEPENDANTS.
    @Default(<String>[]) List<String> audiences,
    @JsonKey(name: 'rayon_km') @FlexInt() @Default(50) int rayonKm,
    @JsonKey(name: 'quantite_cible_kg') @FlexDoubleN() double? quantiteCibleKg,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    /// OPEN | CLOSED | FULFILLED — laissé en String pour souplesse.
    @Default('OPEN') String status,
    @JsonKey(name: 'total_recipients') @FlexInt() @Default(0) int totalRecipients,
    @JsonKey(name: 'total_responses') @FlexInt() @Default(0) int totalResponses,
    @JsonKey(name: 'total_quantite_offerte')
    @FlexDouble()
    @Default(0)
    double totalQuantiteOfferte,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Sollicitation;

  factory Sollicitation.fromJson(Map<String, dynamic> json) =>
      _$SollicitationFromJson(json);
}

/// Ligne destinataire d'une sollicitation — une row par user ciblé.
/// `responseAction` ∈ {ACCEPTED, REJECTED, null} ; quantite_kg requise
/// si ACCEPTED.
@freezed
class SollicitationRecipient with _$SollicitationRecipient {
  const factory SollicitationRecipient({
    required String id,
    @JsonKey(name: 'sollicitation_id') required String sollicitationId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'audience_segment') required String audienceSegment,
    @JsonKey(name: 'cooperative_id') String? cooperativeId,
    @JsonKey(name: 'notification_id') String? notificationId,
    @JsonKey(name: 'sms_sent_at') DateTime? smsSentAt,
    @JsonKey(name: 'opened_at') DateTime? openedAt,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'response_action') String? responseAction,
    @JsonKey(name: 'response_quantite_kg')
    @FlexDoubleN()
    double? responseQuantiteKg,
  }) = _SollicitationRecipient;

  factory SollicitationRecipient.fromJson(Map<String, dynamic> json) =>
      _$SollicitationRecipientFromJson(json);
}
