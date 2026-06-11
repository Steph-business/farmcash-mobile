// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'matching.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MatchingOpportunity _$MatchingOpportunityFromJson(Map<String, dynamic> json) {
  return _MatchingOpportunity.fromJson(json);
}

/// @nodoc
mixin _$MatchingOpportunity {
  @JsonKey(name: 'annonce_id')
  String get annonceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'buyer_name')
  String get buyerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'produit_nom')
  String get produitNom => throw _privateConstructorUsedError;
  @JsonKey(name: 'quantite_kg')
  @FlexDouble()
  double get quantiteKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_max_kg')
  @FlexDouble()
  double get prixMaxKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'region_name')
  String? get regionName => throw _privateConstructorUsedError;
  @JsonKey(name: 'match_score')
  @FlexInt()
  int get matchScore => throw _privateConstructorUsedError;

  /// Serializes this MatchingOpportunity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchingOpportunity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchingOpportunityCopyWith<MatchingOpportunity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchingOpportunityCopyWith<$Res> {
  factory $MatchingOpportunityCopyWith(
    MatchingOpportunity value,
    $Res Function(MatchingOpportunity) then,
  ) = _$MatchingOpportunityCopyWithImpl<$Res, MatchingOpportunity>;
  @useResult
  $Res call({
    @JsonKey(name: 'annonce_id') String annonceId,
    @JsonKey(name: 'buyer_name') String buyerName,
    @JsonKey(name: 'produit_nom') String produitNom,
    @JsonKey(name: 'quantite_kg') @FlexDouble() double quantiteKg,
    @JsonKey(name: 'prix_max_kg') @FlexDouble() double prixMaxKg,
    @JsonKey(name: 'region_name') String? regionName,
    @JsonKey(name: 'match_score') @FlexInt() int matchScore,
  });
}

/// @nodoc
class _$MatchingOpportunityCopyWithImpl<$Res, $Val extends MatchingOpportunity>
    implements $MatchingOpportunityCopyWith<$Res> {
  _$MatchingOpportunityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchingOpportunity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? annonceId = null,
    Object? buyerName = null,
    Object? produitNom = null,
    Object? quantiteKg = null,
    Object? prixMaxKg = null,
    Object? regionName = freezed,
    Object? matchScore = null,
  }) {
    return _then(
      _value.copyWith(
            annonceId: null == annonceId
                ? _value.annonceId
                : annonceId // ignore: cast_nullable_to_non_nullable
                      as String,
            buyerName: null == buyerName
                ? _value.buyerName
                : buyerName // ignore: cast_nullable_to_non_nullable
                      as String,
            produitNom: null == produitNom
                ? _value.produitNom
                : produitNom // ignore: cast_nullable_to_non_nullable
                      as String,
            quantiteKg: null == quantiteKg
                ? _value.quantiteKg
                : quantiteKg // ignore: cast_nullable_to_non_nullable
                      as double,
            prixMaxKg: null == prixMaxKg
                ? _value.prixMaxKg
                : prixMaxKg // ignore: cast_nullable_to_non_nullable
                      as double,
            regionName: freezed == regionName
                ? _value.regionName
                : regionName // ignore: cast_nullable_to_non_nullable
                      as String?,
            matchScore: null == matchScore
                ? _value.matchScore
                : matchScore // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchingOpportunityImplCopyWith<$Res>
    implements $MatchingOpportunityCopyWith<$Res> {
  factory _$$MatchingOpportunityImplCopyWith(
    _$MatchingOpportunityImpl value,
    $Res Function(_$MatchingOpportunityImpl) then,
  ) = __$$MatchingOpportunityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'annonce_id') String annonceId,
    @JsonKey(name: 'buyer_name') String buyerName,
    @JsonKey(name: 'produit_nom') String produitNom,
    @JsonKey(name: 'quantite_kg') @FlexDouble() double quantiteKg,
    @JsonKey(name: 'prix_max_kg') @FlexDouble() double prixMaxKg,
    @JsonKey(name: 'region_name') String? regionName,
    @JsonKey(name: 'match_score') @FlexInt() int matchScore,
  });
}

/// @nodoc
class __$$MatchingOpportunityImplCopyWithImpl<$Res>
    extends _$MatchingOpportunityCopyWithImpl<$Res, _$MatchingOpportunityImpl>
    implements _$$MatchingOpportunityImplCopyWith<$Res> {
  __$$MatchingOpportunityImplCopyWithImpl(
    _$MatchingOpportunityImpl _value,
    $Res Function(_$MatchingOpportunityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchingOpportunity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? annonceId = null,
    Object? buyerName = null,
    Object? produitNom = null,
    Object? quantiteKg = null,
    Object? prixMaxKg = null,
    Object? regionName = freezed,
    Object? matchScore = null,
  }) {
    return _then(
      _$MatchingOpportunityImpl(
        annonceId: null == annonceId
            ? _value.annonceId
            : annonceId // ignore: cast_nullable_to_non_nullable
                  as String,
        buyerName: null == buyerName
            ? _value.buyerName
            : buyerName // ignore: cast_nullable_to_non_nullable
                  as String,
        produitNom: null == produitNom
            ? _value.produitNom
            : produitNom // ignore: cast_nullable_to_non_nullable
                  as String,
        quantiteKg: null == quantiteKg
            ? _value.quantiteKg
            : quantiteKg // ignore: cast_nullable_to_non_nullable
                  as double,
        prixMaxKg: null == prixMaxKg
            ? _value.prixMaxKg
            : prixMaxKg // ignore: cast_nullable_to_non_nullable
                  as double,
        regionName: freezed == regionName
            ? _value.regionName
            : regionName // ignore: cast_nullable_to_non_nullable
                  as String?,
        matchScore: null == matchScore
            ? _value.matchScore
            : matchScore // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchingOpportunityImpl implements _MatchingOpportunity {
  const _$MatchingOpportunityImpl({
    @JsonKey(name: 'annonce_id') required this.annonceId,
    @JsonKey(name: 'buyer_name') required this.buyerName,
    @JsonKey(name: 'produit_nom') required this.produitNom,
    @JsonKey(name: 'quantite_kg') @FlexDouble() this.quantiteKg = 0.0,
    @JsonKey(name: 'prix_max_kg') @FlexDouble() this.prixMaxKg = 0.0,
    @JsonKey(name: 'region_name') this.regionName,
    @JsonKey(name: 'match_score') @FlexInt() this.matchScore = 0,
  });

  factory _$MatchingOpportunityImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchingOpportunityImplFromJson(json);

  @override
  @JsonKey(name: 'annonce_id')
  final String annonceId;
  @override
  @JsonKey(name: 'buyer_name')
  final String buyerName;
  @override
  @JsonKey(name: 'produit_nom')
  final String produitNom;
  @override
  @JsonKey(name: 'quantite_kg')
  @FlexDouble()
  final double quantiteKg;
  @override
  @JsonKey(name: 'prix_max_kg')
  @FlexDouble()
  final double prixMaxKg;
  @override
  @JsonKey(name: 'region_name')
  final String? regionName;
  @override
  @JsonKey(name: 'match_score')
  @FlexInt()
  final int matchScore;

  @override
  String toString() {
    return 'MatchingOpportunity(annonceId: $annonceId, buyerName: $buyerName, produitNom: $produitNom, quantiteKg: $quantiteKg, prixMaxKg: $prixMaxKg, regionName: $regionName, matchScore: $matchScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchingOpportunityImpl &&
            (identical(other.annonceId, annonceId) ||
                other.annonceId == annonceId) &&
            (identical(other.buyerName, buyerName) ||
                other.buyerName == buyerName) &&
            (identical(other.produitNom, produitNom) ||
                other.produitNom == produitNom) &&
            (identical(other.quantiteKg, quantiteKg) ||
                other.quantiteKg == quantiteKg) &&
            (identical(other.prixMaxKg, prixMaxKg) ||
                other.prixMaxKg == prixMaxKg) &&
            (identical(other.regionName, regionName) ||
                other.regionName == regionName) &&
            (identical(other.matchScore, matchScore) ||
                other.matchScore == matchScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    annonceId,
    buyerName,
    produitNom,
    quantiteKg,
    prixMaxKg,
    regionName,
    matchScore,
  );

  /// Create a copy of MatchingOpportunity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchingOpportunityImplCopyWith<_$MatchingOpportunityImpl> get copyWith =>
      __$$MatchingOpportunityImplCopyWithImpl<_$MatchingOpportunityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchingOpportunityImplToJson(this);
  }
}

abstract class _MatchingOpportunity implements MatchingOpportunity {
  const factory _MatchingOpportunity({
    @JsonKey(name: 'annonce_id') required final String annonceId,
    @JsonKey(name: 'buyer_name') required final String buyerName,
    @JsonKey(name: 'produit_nom') required final String produitNom,
    @JsonKey(name: 'quantite_kg') @FlexDouble() final double quantiteKg,
    @JsonKey(name: 'prix_max_kg') @FlexDouble() final double prixMaxKg,
    @JsonKey(name: 'region_name') final String? regionName,
    @JsonKey(name: 'match_score') @FlexInt() final int matchScore,
  }) = _$MatchingOpportunityImpl;

  factory _MatchingOpportunity.fromJson(Map<String, dynamic> json) =
      _$MatchingOpportunityImpl.fromJson;

  @override
  @JsonKey(name: 'annonce_id')
  String get annonceId;
  @override
  @JsonKey(name: 'buyer_name')
  String get buyerName;
  @override
  @JsonKey(name: 'produit_nom')
  String get produitNom;
  @override
  @JsonKey(name: 'quantite_kg')
  @FlexDouble()
  double get quantiteKg;
  @override
  @JsonKey(name: 'prix_max_kg')
  @FlexDouble()
  double get prixMaxKg;
  @override
  @JsonKey(name: 'region_name')
  String? get regionName;
  @override
  @JsonKey(name: 'match_score')
  @FlexInt()
  int get matchScore;

  /// Create a copy of MatchingOpportunity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchingOpportunityImplCopyWith<_$MatchingOpportunityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchedSupplier _$MatchedSupplierFromJson(Map<String, dynamic> json) {
  return _MatchedSupplier.fromJson(json);
}

/// @nodoc
mixin _$MatchedSupplier {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'region_id')
  String? get regionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'region_name')
  String? get regionName => throw _privateConstructorUsedError;
  @JsonKey(name: 'distance_km')
  @FlexDoubleN()
  double? get distanceKm => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_active_annonce')
  bool get hasActiveAnnonce => throw _privateConstructorUsedError;
  @JsonKey(name: 'declared_in_cultures')
  bool get declaredInCultures => throw _privateConstructorUsedError;
  @JsonKey(name: 'match_score')
  @FlexInt()
  int get matchScore => throw _privateConstructorUsedError;

  /// Serializes this MatchedSupplier to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchedSupplier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchedSupplierCopyWith<MatchedSupplier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchedSupplierCopyWith<$Res> {
  factory $MatchedSupplierCopyWith(
    MatchedSupplier value,
    $Res Function(MatchedSupplier) then,
  ) = _$MatchedSupplierCopyWithImpl<$Res, MatchedSupplier>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'full_name') String fullName,
    @JsonKey(name: 'region_id') String? regionId,
    @JsonKey(name: 'region_name') String? regionName,
    @JsonKey(name: 'distance_km') @FlexDoubleN() double? distanceKm,
    @JsonKey(name: 'has_active_annonce') bool hasActiveAnnonce,
    @JsonKey(name: 'declared_in_cultures') bool declaredInCultures,
    @JsonKey(name: 'match_score') @FlexInt() int matchScore,
  });
}

/// @nodoc
class _$MatchedSupplierCopyWithImpl<$Res, $Val extends MatchedSupplier>
    implements $MatchedSupplierCopyWith<$Res> {
  _$MatchedSupplierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchedSupplier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? fullName = null,
    Object? regionId = freezed,
    Object? regionName = freezed,
    Object? distanceKm = freezed,
    Object? hasActiveAnnonce = null,
    Object? declaredInCultures = null,
    Object? matchScore = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            regionId: freezed == regionId
                ? _value.regionId
                : regionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            regionName: freezed == regionName
                ? _value.regionName
                : regionName // ignore: cast_nullable_to_non_nullable
                      as String?,
            distanceKm: freezed == distanceKm
                ? _value.distanceKm
                : distanceKm // ignore: cast_nullable_to_non_nullable
                      as double?,
            hasActiveAnnonce: null == hasActiveAnnonce
                ? _value.hasActiveAnnonce
                : hasActiveAnnonce // ignore: cast_nullable_to_non_nullable
                      as bool,
            declaredInCultures: null == declaredInCultures
                ? _value.declaredInCultures
                : declaredInCultures // ignore: cast_nullable_to_non_nullable
                      as bool,
            matchScore: null == matchScore
                ? _value.matchScore
                : matchScore // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchedSupplierImplCopyWith<$Res>
    implements $MatchedSupplierCopyWith<$Res> {
  factory _$$MatchedSupplierImplCopyWith(
    _$MatchedSupplierImpl value,
    $Res Function(_$MatchedSupplierImpl) then,
  ) = __$$MatchedSupplierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'full_name') String fullName,
    @JsonKey(name: 'region_id') String? regionId,
    @JsonKey(name: 'region_name') String? regionName,
    @JsonKey(name: 'distance_km') @FlexDoubleN() double? distanceKm,
    @JsonKey(name: 'has_active_annonce') bool hasActiveAnnonce,
    @JsonKey(name: 'declared_in_cultures') bool declaredInCultures,
    @JsonKey(name: 'match_score') @FlexInt() int matchScore,
  });
}

/// @nodoc
class __$$MatchedSupplierImplCopyWithImpl<$Res>
    extends _$MatchedSupplierCopyWithImpl<$Res, _$MatchedSupplierImpl>
    implements _$$MatchedSupplierImplCopyWith<$Res> {
  __$$MatchedSupplierImplCopyWithImpl(
    _$MatchedSupplierImpl _value,
    $Res Function(_$MatchedSupplierImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchedSupplier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? fullName = null,
    Object? regionId = freezed,
    Object? regionName = freezed,
    Object? distanceKm = freezed,
    Object? hasActiveAnnonce = null,
    Object? declaredInCultures = null,
    Object? matchScore = null,
  }) {
    return _then(
      _$MatchedSupplierImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        regionId: freezed == regionId
            ? _value.regionId
            : regionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        regionName: freezed == regionName
            ? _value.regionName
            : regionName // ignore: cast_nullable_to_non_nullable
                  as String?,
        distanceKm: freezed == distanceKm
            ? _value.distanceKm
            : distanceKm // ignore: cast_nullable_to_non_nullable
                  as double?,
        hasActiveAnnonce: null == hasActiveAnnonce
            ? _value.hasActiveAnnonce
            : hasActiveAnnonce // ignore: cast_nullable_to_non_nullable
                  as bool,
        declaredInCultures: null == declaredInCultures
            ? _value.declaredInCultures
            : declaredInCultures // ignore: cast_nullable_to_non_nullable
                  as bool,
        matchScore: null == matchScore
            ? _value.matchScore
            : matchScore // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchedSupplierImpl implements _MatchedSupplier {
  const _$MatchedSupplierImpl({
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'full_name') required this.fullName,
    @JsonKey(name: 'region_id') this.regionId,
    @JsonKey(name: 'region_name') this.regionName,
    @JsonKey(name: 'distance_km') @FlexDoubleN() this.distanceKm,
    @JsonKey(name: 'has_active_annonce') this.hasActiveAnnonce = false,
    @JsonKey(name: 'declared_in_cultures') this.declaredInCultures = false,
    @JsonKey(name: 'match_score') @FlexInt() this.matchScore = 0,
  });

  factory _$MatchedSupplierImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchedSupplierImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'region_id')
  final String? regionId;
  @override
  @JsonKey(name: 'region_name')
  final String? regionName;
  @override
  @JsonKey(name: 'distance_km')
  @FlexDoubleN()
  final double? distanceKm;
  @override
  @JsonKey(name: 'has_active_annonce')
  final bool hasActiveAnnonce;
  @override
  @JsonKey(name: 'declared_in_cultures')
  final bool declaredInCultures;
  @override
  @JsonKey(name: 'match_score')
  @FlexInt()
  final int matchScore;

  @override
  String toString() {
    return 'MatchedSupplier(userId: $userId, fullName: $fullName, regionId: $regionId, regionName: $regionName, distanceKm: $distanceKm, hasActiveAnnonce: $hasActiveAnnonce, declaredInCultures: $declaredInCultures, matchScore: $matchScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchedSupplierImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.regionId, regionId) ||
                other.regionId == regionId) &&
            (identical(other.regionName, regionName) ||
                other.regionName == regionName) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.hasActiveAnnonce, hasActiveAnnonce) ||
                other.hasActiveAnnonce == hasActiveAnnonce) &&
            (identical(other.declaredInCultures, declaredInCultures) ||
                other.declaredInCultures == declaredInCultures) &&
            (identical(other.matchScore, matchScore) ||
                other.matchScore == matchScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    fullName,
    regionId,
    regionName,
    distanceKm,
    hasActiveAnnonce,
    declaredInCultures,
    matchScore,
  );

  /// Create a copy of MatchedSupplier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchedSupplierImplCopyWith<_$MatchedSupplierImpl> get copyWith =>
      __$$MatchedSupplierImplCopyWithImpl<_$MatchedSupplierImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchedSupplierImplToJson(this);
  }
}

abstract class _MatchedSupplier implements MatchedSupplier {
  const factory _MatchedSupplier({
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'full_name') required final String fullName,
    @JsonKey(name: 'region_id') final String? regionId,
    @JsonKey(name: 'region_name') final String? regionName,
    @JsonKey(name: 'distance_km') @FlexDoubleN() final double? distanceKm,
    @JsonKey(name: 'has_active_annonce') final bool hasActiveAnnonce,
    @JsonKey(name: 'declared_in_cultures') final bool declaredInCultures,
    @JsonKey(name: 'match_score') @FlexInt() final int matchScore,
  }) = _$MatchedSupplierImpl;

  factory _MatchedSupplier.fromJson(Map<String, dynamic> json) =
      _$MatchedSupplierImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'region_id')
  String? get regionId;
  @override
  @JsonKey(name: 'region_name')
  String? get regionName;
  @override
  @JsonKey(name: 'distance_km')
  @FlexDoubleN()
  double? get distanceKm;
  @override
  @JsonKey(name: 'has_active_annonce')
  bool get hasActiveAnnonce;
  @override
  @JsonKey(name: 'declared_in_cultures')
  bool get declaredInCultures;
  @override
  @JsonKey(name: 'match_score')
  @FlexInt()
  int get matchScore;

  /// Create a copy of MatchedSupplier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchedSupplierImplCopyWith<_$MatchedSupplierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
