// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PayoutBatchImpl _$$PayoutBatchImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$PayoutBatchImpl',
      json,
      ($checkedConvert) {
        final val = _$PayoutBatchImpl(
          id: $checkedConvert('id', (v) => v as String),
          initiatorId: $checkedConvert('initiator_id', (v) => v as String),
          totalAmount: $checkedConvert(
            'total_amount',
            (v) => const FlexDouble().fromJson(v),
          ),
          status: $checkedConvert('status', (v) => v as String? ?? 'PENDING'),
          items: $checkedConvert(
            'items',
            (v) =>
                (v as List<dynamic>?)
                    ?.map((e) => PayoutItem.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                const <PayoutItem>[],
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          completedAt: $checkedConvert(
            'completed_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'initiatorId': 'initiator_id',
        'totalAmount': 'total_amount',
        'createdAt': 'created_at',
        'completedAt': 'completed_at',
      },
    );

Map<String, dynamic> _$$PayoutBatchImplToJson(_$PayoutBatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'initiator_id': instance.initiatorId,
      if (const FlexDouble().toJson(instance.totalAmount) case final value?)
        'total_amount': value,
      'status': instance.status,
      'items': instance.items,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      if (instance.completedAt?.toIso8601String() case final value?)
        'completed_at': value,
    };

_$PayoutItemImpl _$$PayoutItemImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$PayoutItemImpl',
      json,
      ($checkedConvert) {
        final val = _$PayoutItemImpl(
          id: $checkedConvert('id', (v) => v as String),
          batchId: $checkedConvert('batch_id', (v) => v as String),
          userId: $checkedConvert('user_id', (v) => v as String),
          amount: $checkedConvert(
            'amount',
            (v) => const FlexDouble().fromJson(v),
          ),
          provider: $checkedConvert(
            'provider',
            (v) =>
                $enumDecodeNullable(
                  _$MobileProviderEnumMap,
                  v,
                  unknownValue: MobileProvider.unknown,
                ) ??
                MobileProvider.unknown,
          ),
          status: $checkedConvert('status', (v) => v as String? ?? 'PENDING'),
          errorMessage: $checkedConvert('error_message', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'batchId': 'batch_id',
        'userId': 'user_id',
        'errorMessage': 'error_message',
      },
    );

Map<String, dynamic> _$$PayoutItemImplToJson(_$PayoutItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'batch_id': instance.batchId,
      'user_id': instance.userId,
      if (const FlexDouble().toJson(instance.amount) case final value?)
        'amount': value,
      'provider': _$MobileProviderEnumMap[instance.provider]!,
      'status': instance.status,
      if (instance.errorMessage case final value?) 'error_message': value,
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
