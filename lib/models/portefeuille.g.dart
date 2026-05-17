// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portefeuille.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PortefeuilleImpl _$$PortefeuilleImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$PortefeuilleImpl',
      json,
      ($checkedConvert) {
        final val = _$PortefeuilleImpl(
          id: $checkedConvert('id', (v) => v as String? ?? ''),
          userId: $checkedConvert('user_id', (v) => v as String? ?? ''),
          currency: $checkedConvert('currency', (v) => v as String? ?? 'XOF'),
          balance: $checkedConvert(
            'balance',
            (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
          ),
          balanceEscrow: $checkedConvert(
            'balance_escrow',
            (v) => v == null ? 0.0 : const FlexDouble().fromJson(v),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'userId': 'user_id',
        'balanceEscrow': 'balance_escrow',
      },
    );

Map<String, dynamic> _$$PortefeuilleImplToJson(_$PortefeuilleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'currency': instance.currency,
      if (const FlexDouble().toJson(instance.balance) case final value?)
        'balance': value,
      if (const FlexDouble().toJson(instance.balanceEscrow) case final value?)
        'balance_escrow': value,
    };

_$MoyenPayementImpl _$$MoyenPayementImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$MoyenPayementImpl',
  json,
  ($checkedConvert) {
    final val = _$MoyenPayementImpl(
      id: $checkedConvert('id', (v) => v as String),
      userId: $checkedConvert('user_id', (v) => v as String),
      provider: $checkedConvert('provider', (v) => v as String? ?? 'UNKNOWN'),
      phoneDisplay: $checkedConvert('phone_display', (v) => v as String? ?? ''),
      isDefault: $checkedConvert('is_default', (v) => v as bool? ?? false),
      isActive: $checkedConvert('is_active', (v) => v as bool? ?? true),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'userId': 'user_id',
    'phoneDisplay': 'phone_display',
    'isDefault': 'is_default',
    'isActive': 'is_active',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$MoyenPayementImplToJson(_$MoyenPayementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'provider': instance.provider,
      'phone_display': instance.phoneDisplay,
      'is_default': instance.isDefault,
      'is_active': instance.isActive,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };
