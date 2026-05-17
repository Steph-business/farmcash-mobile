import 'package:freezed_annotation/freezed_annotation.dart';

part 'phone_proxy_session.freezed.dart';
part 'phone_proxy_session.g.dart';

/// Session d'appel masqué (proxy Twilio) entre deux users FarmCash.
/// Le client compose `proxyPhone` (numéro Twilio) — le backend route
/// l'appel vers le callee tout en gardant les numéros réels masqués.
/// Réutilisable jusqu'à `expiresAt` (TTL 14j par défaut).
@freezed
class PhoneProxySession with _$PhoneProxySession {
  const factory PhoneProxySession({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'proxy_phone') required String proxyPhone,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
  }) = _PhoneProxySession;

  factory PhoneProxySession.fromJson(Map<String, dynamic> json) =>
      _$PhoneProxySessionFromJson(json);
}
