// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_proxy_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhoneProxySessionImpl _$$PhoneProxySessionImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$PhoneProxySessionImpl',
  json,
  ($checkedConvert) {
    final val = _$PhoneProxySessionImpl(
      sessionId: $checkedConvert('session_id', (v) => v as String),
      proxyPhone: $checkedConvert('proxy_phone', (v) => v as String),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'sessionId': 'session_id',
    'proxyPhone': 'proxy_phone',
    'expiresAt': 'expires_at',
  },
);

Map<String, dynamic> _$$PhoneProxySessionImplToJson(
  _$PhoneProxySessionImpl instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'proxy_phone': instance.proxyPhone,
  'expires_at': instance.expiresAt.toIso8601String(),
};
