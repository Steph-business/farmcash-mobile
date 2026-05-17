import 'package:freezed_annotation/freezed_annotation.dart';

part 'pickup_qr_token.freezed.dart';
part 'pickup_qr_token.g.dart';

/// Token signé (HMAC) généré par le FARMER pour preuve d'enlèvement.
/// TTL court (15 min). Le transporteur scanne ce QR pour passer le
/// shipment en LOADING et libérer l'escrow PRODUCT automatiquement.
@freezed
class PickupQrToken with _$PickupQrToken {
  const factory PickupQrToken({
    required String token,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    /// TTL résiduel en secondes (info de confort pour l'UI).
    @JsonKey(name: 'ttl_seconds') int? ttlSeconds,
  }) = _PickupQrToken;

  factory PickupQrToken.fromJson(Map<String, dynamic> json) =>
      _$PickupQrTokenFromJson(json);
}
