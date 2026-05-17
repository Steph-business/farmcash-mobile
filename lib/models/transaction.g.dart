// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$TransactionImpl',
      json,
      ($checkedConvert) {
        final val = _$TransactionImpl(
          id: $checkedConvert('id', (v) => v as String),
          userId: $checkedConvert('user_id', (v) => v as String),
          type: $checkedConvert('type', (v) => v as String? ?? 'UNKNOWN'),
          montant: $checkedConvert(
            'montant',
            (v) => const FlexDouble().fromJson(v),
          ),
          status: $checkedConvert('status', (v) => v as String? ?? 'PENDING'),
          commandeId: $checkedConvert('commande_id', (v) => v as String?),
          balanceAvant: $checkedConvert(
            'balance_avant',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          balanceApres: $checkedConvert(
            'balance_apres',
            (v) => const FlexDoubleN().fromJson(v),
          ),
          provider: $checkedConvert(
            'provider',
            (v) => $enumDecodeNullable(
              _$MobileProviderEnumMap,
              v,
              unknownValue: MobileProvider.unknown,
            ),
          ),
          reference: $checkedConvert('reference', (v) => v as String?),
          description: $checkedConvert('description', (v) => v as String?),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'userId': 'user_id',
        'commandeId': 'commande_id',
        'balanceAvant': 'balance_avant',
        'balanceApres': 'balance_apres',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': instance.type,
      if (const FlexDouble().toJson(instance.montant) case final value?)
        'montant': value,
      'status': instance.status,
      if (instance.commandeId case final value?) 'commande_id': value,
      if (const FlexDoubleN().toJson(instance.balanceAvant) case final value?)
        'balance_avant': value,
      if (const FlexDoubleN().toJson(instance.balanceApres) case final value?)
        'balance_apres': value,
      if (_$MobileProviderEnumMap[instance.provider] case final value?)
        'provider': value,
      if (instance.reference case final value?) 'reference': value,
      if (instance.description case final value?) 'description': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };

const _$MobileProviderEnumMap = {
  MobileProvider.orangeMoney: 'ORANGE_MONEY',
  MobileProvider.mtnMomo: 'MTN_MOMO',
  MobileProvider.wave: 'WAVE',
  MobileProvider.moov: 'MOOV',
  MobileProvider.virement: 'VIREMENT',
  MobileProvider.wallet: 'WALLET',
  MobileProvider.unknown: 'UNKNOWN',
};
