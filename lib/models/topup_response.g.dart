// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topup_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopupWalletResponseImpl _$$TopupWalletResponseImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$TopupWalletResponseImpl',
  json,
  ($checkedConvert) {
    final val = _$TopupWalletResponseImpl(
      transactionId: $checkedConvert('transaction_id', (v) => v as String),
      status: $checkedConvert('status', (v) => v as String),
      providerRef: $checkedConvert('provider_ref', (v) => v as String?),
      newBalance: $checkedConvert(
        'new_balance',
        (v) => const FlexDoubleN().fromJson(v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'transactionId': 'transaction_id',
    'providerRef': 'provider_ref',
    'newBalance': 'new_balance',
  },
);

Map<String, dynamic> _$$TopupWalletResponseImplToJson(
  _$TopupWalletResponseImpl instance,
) => <String, dynamic>{
  'transaction_id': instance.transactionId,
  'status': instance.status,
  if (instance.providerRef case final value?) 'provider_ref': value,
  if (const FlexDoubleN().toJson(instance.newBalance) case final value?)
    'new_balance': value,
};
