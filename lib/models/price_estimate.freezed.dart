// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_estimate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PriceEstimate _$PriceEstimateFromJson(Map<String, dynamic> json) {
  return _PriceEstimate.fromJson(json);
}

/// @nodoc
mixin _$PriceEstimate {
  /// Prix médian observé sur la période (F CFA/kg).
  @JsonKey(name: 'median_kg')
  @FlexDoubleN()
  double? get medianKg => throw _privateConstructorUsedError;

  /// Prix minimum observé sur la période (F CFA/kg).
  @JsonKey(name: 'min_kg')
  @FlexDoubleN()
  double? get minKg => throw _privateConstructorUsedError;

  /// Prix maximum observé sur la période (F CFA/kg).
  @JsonKey(name: 'max_kg')
  @FlexDoubleN()
  double? get maxKg => throw _privateConstructorUsedError;

  /// Nombre de commandes utilisées pour calculer médian/min/max.
  @JsonKey(name: 'sample_size')
  @FlexInt()
  int get sampleSize => throw _privateConstructorUsedError;

  /// Fenêtre temporelle (en jours) considérée par le backend.
  @JsonKey(name: 'period_days')
  @FlexInt()
  int get periodDays => throw _privateConstructorUsedError;

  /// Vrai si la médiane est suffisamment fiable pour être affichée
  /// avec confiance (calculé côté backend selon `sampleSize`).
  @JsonKey(name: 'is_reliable')
  bool get isReliable => throw _privateConstructorUsedError;

  /// Origine du calcul (historique réel vs fallback catalogue).
  @JsonKey(name: 'source', unknownEnumValue: PriceSource.unknown)
  PriceSource get source => throw _privateConstructorUsedError;

  /// Nom lisible du produit (renvoyé pour affichage direct).
  @JsonKey(name: 'product_name')
  String? get productName => throw _privateConstructorUsedError;

  /// Serializes this PriceEstimate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceEstimate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceEstimateCopyWith<PriceEstimate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceEstimateCopyWith<$Res> {
  factory $PriceEstimateCopyWith(
    PriceEstimate value,
    $Res Function(PriceEstimate) then,
  ) = _$PriceEstimateCopyWithImpl<$Res, PriceEstimate>;
  @useResult
  $Res call({
    @JsonKey(name: 'median_kg') @FlexDoubleN() double? medianKg,
    @JsonKey(name: 'min_kg') @FlexDoubleN() double? minKg,
    @JsonKey(name: 'max_kg') @FlexDoubleN() double? maxKg,
    @JsonKey(name: 'sample_size') @FlexInt() int sampleSize,
    @JsonKey(name: 'period_days') @FlexInt() int periodDays,
    @JsonKey(name: 'is_reliable') bool isReliable,
    @JsonKey(name: 'source', unknownEnumValue: PriceSource.unknown)
    PriceSource source,
    @JsonKey(name: 'product_name') String? productName,
  });
}

/// @nodoc
class _$PriceEstimateCopyWithImpl<$Res, $Val extends PriceEstimate>
    implements $PriceEstimateCopyWith<$Res> {
  _$PriceEstimateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceEstimate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? medianKg = freezed,
    Object? minKg = freezed,
    Object? maxKg = freezed,
    Object? sampleSize = null,
    Object? periodDays = null,
    Object? isReliable = null,
    Object? source = null,
    Object? productName = freezed,
  }) {
    return _then(
      _value.copyWith(
            medianKg: freezed == medianKg
                ? _value.medianKg
                : medianKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            minKg: freezed == minKg
                ? _value.minKg
                : minKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            maxKg: freezed == maxKg
                ? _value.maxKg
                : maxKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            sampleSize: null == sampleSize
                ? _value.sampleSize
                : sampleSize // ignore: cast_nullable_to_non_nullable
                      as int,
            periodDays: null == periodDays
                ? _value.periodDays
                : periodDays // ignore: cast_nullable_to_non_nullable
                      as int,
            isReliable: null == isReliable
                ? _value.isReliable
                : isReliable // ignore: cast_nullable_to_non_nullable
                      as bool,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as PriceSource,
            productName: freezed == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PriceEstimateImplCopyWith<$Res>
    implements $PriceEstimateCopyWith<$Res> {
  factory _$$PriceEstimateImplCopyWith(
    _$PriceEstimateImpl value,
    $Res Function(_$PriceEstimateImpl) then,
  ) = __$$PriceEstimateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'median_kg') @FlexDoubleN() double? medianKg,
    @JsonKey(name: 'min_kg') @FlexDoubleN() double? minKg,
    @JsonKey(name: 'max_kg') @FlexDoubleN() double? maxKg,
    @JsonKey(name: 'sample_size') @FlexInt() int sampleSize,
    @JsonKey(name: 'period_days') @FlexInt() int periodDays,
    @JsonKey(name: 'is_reliable') bool isReliable,
    @JsonKey(name: 'source', unknownEnumValue: PriceSource.unknown)
    PriceSource source,
    @JsonKey(name: 'product_name') String? productName,
  });
}

/// @nodoc
class __$$PriceEstimateImplCopyWithImpl<$Res>
    extends _$PriceEstimateCopyWithImpl<$Res, _$PriceEstimateImpl>
    implements _$$PriceEstimateImplCopyWith<$Res> {
  __$$PriceEstimateImplCopyWithImpl(
    _$PriceEstimateImpl _value,
    $Res Function(_$PriceEstimateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PriceEstimate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? medianKg = freezed,
    Object? minKg = freezed,
    Object? maxKg = freezed,
    Object? sampleSize = null,
    Object? periodDays = null,
    Object? isReliable = null,
    Object? source = null,
    Object? productName = freezed,
  }) {
    return _then(
      _$PriceEstimateImpl(
        medianKg: freezed == medianKg
            ? _value.medianKg
            : medianKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        minKg: freezed == minKg
            ? _value.minKg
            : minKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        maxKg: freezed == maxKg
            ? _value.maxKg
            : maxKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        sampleSize: null == sampleSize
            ? _value.sampleSize
            : sampleSize // ignore: cast_nullable_to_non_nullable
                  as int,
        periodDays: null == periodDays
            ? _value.periodDays
            : periodDays // ignore: cast_nullable_to_non_nullable
                  as int,
        isReliable: null == isReliable
            ? _value.isReliable
            : isReliable // ignore: cast_nullable_to_non_nullable
                  as bool,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as PriceSource,
        productName: freezed == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceEstimateImpl extends _PriceEstimate {
  const _$PriceEstimateImpl({
    @JsonKey(name: 'median_kg') @FlexDoubleN() this.medianKg,
    @JsonKey(name: 'min_kg') @FlexDoubleN() this.minKg,
    @JsonKey(name: 'max_kg') @FlexDoubleN() this.maxKg,
    @JsonKey(name: 'sample_size') @FlexInt() this.sampleSize = 0,
    @JsonKey(name: 'period_days') @FlexInt() this.periodDays = 90,
    @JsonKey(name: 'is_reliable') this.isReliable = false,
    @JsonKey(name: 'source', unknownEnumValue: PriceSource.unknown)
    this.source = PriceSource.unknown,
    @JsonKey(name: 'product_name') this.productName,
  }) : super._();

  factory _$PriceEstimateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceEstimateImplFromJson(json);

  /// Prix médian observé sur la période (F CFA/kg).
  @override
  @JsonKey(name: 'median_kg')
  @FlexDoubleN()
  final double? medianKg;

  /// Prix minimum observé sur la période (F CFA/kg).
  @override
  @JsonKey(name: 'min_kg')
  @FlexDoubleN()
  final double? minKg;

  /// Prix maximum observé sur la période (F CFA/kg).
  @override
  @JsonKey(name: 'max_kg')
  @FlexDoubleN()
  final double? maxKg;

  /// Nombre de commandes utilisées pour calculer médian/min/max.
  @override
  @JsonKey(name: 'sample_size')
  @FlexInt()
  final int sampleSize;

  /// Fenêtre temporelle (en jours) considérée par le backend.
  @override
  @JsonKey(name: 'period_days')
  @FlexInt()
  final int periodDays;

  /// Vrai si la médiane est suffisamment fiable pour être affichée
  /// avec confiance (calculé côté backend selon `sampleSize`).
  @override
  @JsonKey(name: 'is_reliable')
  final bool isReliable;

  /// Origine du calcul (historique réel vs fallback catalogue).
  @override
  @JsonKey(name: 'source', unknownEnumValue: PriceSource.unknown)
  final PriceSource source;

  /// Nom lisible du produit (renvoyé pour affichage direct).
  @override
  @JsonKey(name: 'product_name')
  final String? productName;

  @override
  String toString() {
    return 'PriceEstimate(medianKg: $medianKg, minKg: $minKg, maxKg: $maxKg, sampleSize: $sampleSize, periodDays: $periodDays, isReliable: $isReliable, source: $source, productName: $productName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceEstimateImpl &&
            (identical(other.medianKg, medianKg) ||
                other.medianKg == medianKg) &&
            (identical(other.minKg, minKg) || other.minKg == minKg) &&
            (identical(other.maxKg, maxKg) || other.maxKg == maxKg) &&
            (identical(other.sampleSize, sampleSize) ||
                other.sampleSize == sampleSize) &&
            (identical(other.periodDays, periodDays) ||
                other.periodDays == periodDays) &&
            (identical(other.isReliable, isReliable) ||
                other.isReliable == isReliable) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.productName, productName) ||
                other.productName == productName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    medianKg,
    minKg,
    maxKg,
    sampleSize,
    periodDays,
    isReliable,
    source,
    productName,
  );

  /// Create a copy of PriceEstimate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceEstimateImplCopyWith<_$PriceEstimateImpl> get copyWith =>
      __$$PriceEstimateImplCopyWithImpl<_$PriceEstimateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceEstimateImplToJson(this);
  }
}

abstract class _PriceEstimate extends PriceEstimate {
  const factory _PriceEstimate({
    @JsonKey(name: 'median_kg') @FlexDoubleN() final double? medianKg,
    @JsonKey(name: 'min_kg') @FlexDoubleN() final double? minKg,
    @JsonKey(name: 'max_kg') @FlexDoubleN() final double? maxKg,
    @JsonKey(name: 'sample_size') @FlexInt() final int sampleSize,
    @JsonKey(name: 'period_days') @FlexInt() final int periodDays,
    @JsonKey(name: 'is_reliable') final bool isReliable,
    @JsonKey(name: 'source', unknownEnumValue: PriceSource.unknown)
    final PriceSource source,
    @JsonKey(name: 'product_name') final String? productName,
  }) = _$PriceEstimateImpl;
  const _PriceEstimate._() : super._();

  factory _PriceEstimate.fromJson(Map<String, dynamic> json) =
      _$PriceEstimateImpl.fromJson;

  /// Prix médian observé sur la période (F CFA/kg).
  @override
  @JsonKey(name: 'median_kg')
  @FlexDoubleN()
  double? get medianKg;

  /// Prix minimum observé sur la période (F CFA/kg).
  @override
  @JsonKey(name: 'min_kg')
  @FlexDoubleN()
  double? get minKg;

  /// Prix maximum observé sur la période (F CFA/kg).
  @override
  @JsonKey(name: 'max_kg')
  @FlexDoubleN()
  double? get maxKg;

  /// Nombre de commandes utilisées pour calculer médian/min/max.
  @override
  @JsonKey(name: 'sample_size')
  @FlexInt()
  int get sampleSize;

  /// Fenêtre temporelle (en jours) considérée par le backend.
  @override
  @JsonKey(name: 'period_days')
  @FlexInt()
  int get periodDays;

  /// Vrai si la médiane est suffisamment fiable pour être affichée
  /// avec confiance (calculé côté backend selon `sampleSize`).
  @override
  @JsonKey(name: 'is_reliable')
  bool get isReliable;

  /// Origine du calcul (historique réel vs fallback catalogue).
  @override
  @JsonKey(name: 'source', unknownEnumValue: PriceSource.unknown)
  PriceSource get source;

  /// Nom lisible du produit (renvoyé pour affichage direct).
  @override
  @JsonKey(name: 'product_name')
  String? get productName;

  /// Create a copy of PriceEstimate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceEstimateImplCopyWith<_$PriceEstimateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
