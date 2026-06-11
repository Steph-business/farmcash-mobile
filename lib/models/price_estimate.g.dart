// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_estimate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PriceEstimateImpl _$$PriceEstimateImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$PriceEstimateImpl',
  json,
  ($checkedConvert) {
    final val = _$PriceEstimateImpl(
      medianKg: $checkedConvert(
        'median_kg',
        (v) => const FlexDoubleN().fromJson(v),
      ),
      minKg: $checkedConvert('min_kg', (v) => const FlexDoubleN().fromJson(v)),
      maxKg: $checkedConvert('max_kg', (v) => const FlexDoubleN().fromJson(v)),
      sampleSize: $checkedConvert(
        'sample_size',
        (v) => v == null ? 0 : const FlexInt().fromJson(v),
      ),
      periodDays: $checkedConvert(
        'period_days',
        (v) => v == null ? 90 : const FlexInt().fromJson(v),
      ),
      isReliable: $checkedConvert('is_reliable', (v) => v as bool? ?? false),
      source: $checkedConvert(
        'source',
        (v) =>
            $enumDecodeNullable(
              _$PriceSourceEnumMap,
              v,
              unknownValue: PriceSource.unknown,
            ) ??
            PriceSource.unknown,
      ),
      productName: $checkedConvert('product_name', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'medianKg': 'median_kg',
    'minKg': 'min_kg',
    'maxKg': 'max_kg',
    'sampleSize': 'sample_size',
    'periodDays': 'period_days',
    'isReliable': 'is_reliable',
    'productName': 'product_name',
  },
);

Map<String, dynamic> _$$PriceEstimateImplToJson(_$PriceEstimateImpl instance) =>
    <String, dynamic>{
      if (const FlexDoubleN().toJson(instance.medianKg) case final value?)
        'median_kg': value,
      if (const FlexDoubleN().toJson(instance.minKg) case final value?)
        'min_kg': value,
      if (const FlexDoubleN().toJson(instance.maxKg) case final value?)
        'max_kg': value,
      if (const FlexInt().toJson(instance.sampleSize) case final value?)
        'sample_size': value,
      if (const FlexInt().toJson(instance.periodDays) case final value?)
        'period_days': value,
      'is_reliable': instance.isReliable,
      'source': _$PriceSourceEnumMap[instance.source]!,
      if (instance.productName case final value?) 'product_name': value,
    };

const _$PriceSourceEnumMap = {
  PriceSource.history: 'history',
  PriceSource.catalog: 'catalog',
  PriceSource.none: 'none',
  PriceSource.unknown: 'UNKNOWN',
};
