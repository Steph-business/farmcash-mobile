// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_qr_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PickupQrTokenImpl _$$PickupQrTokenImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$PickupQrTokenImpl',
  json,
  ($checkedConvert) {
    final val = _$PickupQrTokenImpl(
      token: $checkedConvert('token', (v) => v as String),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => DateTime.parse(v as String),
      ),
      ttlSeconds: $checkedConvert('ttl_seconds', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {'expiresAt': 'expires_at', 'ttlSeconds': 'ttl_seconds'},
);

Map<String, dynamic> _$$PickupQrTokenImplToJson(_$PickupQrTokenImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'expires_at': instance.expiresAt.toIso8601String(),
      if (instance.ttlSeconds case final value?) 'ttl_seconds': value,
    };
