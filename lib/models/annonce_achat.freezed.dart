// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'annonce_achat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnnonceAchat _$AnnonceAchatFromJson(Map<String, dynamic> json) {
  return _AnnonceAchat.fromJson(json);
}

/// @nodoc
mixin _$AnnonceAchat {
  String get id => throw _privateConstructorUsedError;
  String get buyerId => throw _privateConstructorUsedError;
  String get produitId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get quantiteKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get prixMaxKg => throw _privateConstructorUsedError;
  String? get regionId => throw _privateConstructorUsedError;
  String? get villeId => throw _privateConstructorUsedError;
  String? get titre => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Le backend renvoie `is_active` (bool), pas un statut enum.
  /// Une demande est "active" si l'acheteur cherche encore (≠ archivée).
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_audience', unknownEnumValue: BuyOfferAudience.unknown)
  BuyOfferAudience get audience => throw _privateConstructorUsedError;
  String? get targetCooperativeId => throw _privateConstructorUsedError;
  DateTime? get dateLimiteLivraison => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // ─── Champs joints ────────────────────────────────────────────────
  @JsonKey(name: 'produits_agricoles', fromJson: _nomFromMap, toJson: _nomToMap)
  String? get produitNom => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'users',
    fromJson: _buyerInfoFromJson,
    toJson: _buyerInfoToJson,
  )
  VendeurApercu? get buyer => throw _privateConstructorUsedError;
  @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
  String? get regionNom => throw _privateConstructorUsedError;

  /// Serializes this AnnonceAchat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnnonceAchat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnnonceAchatCopyWith<AnnonceAchat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnnonceAchatCopyWith<$Res> {
  factory $AnnonceAchatCopyWith(
    AnnonceAchat value,
    $Res Function(AnnonceAchat) then,
  ) = _$AnnonceAchatCopyWithImpl<$Res, AnnonceAchat>;
  @useResult
  $Res call({
    String id,
    String buyerId,
    String produitId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixMaxKg,
    String? regionId,
    String? villeId,
    String? titre,
    String? description,
    bool isActive,
    @JsonKey(
      name: 'target_audience',
      unknownEnumValue: BuyOfferAudience.unknown,
    )
    BuyOfferAudience audience,
    String? targetCooperativeId,
    DateTime? dateLimiteLivraison,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(
      name: 'produits_agricoles',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    String? produitNom,
    @JsonKey(
      name: 'users',
      fromJson: _buyerInfoFromJson,
      toJson: _buyerInfoToJson,
    )
    VendeurApercu? buyer,
    @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    String? regionNom,
  });
}

/// @nodoc
class _$AnnonceAchatCopyWithImpl<$Res, $Val extends AnnonceAchat>
    implements $AnnonceAchatCopyWith<$Res> {
  _$AnnonceAchatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnnonceAchat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? buyerId = null,
    Object? produitId = null,
    Object? quantiteKg = null,
    Object? prixMaxKg = null,
    Object? regionId = freezed,
    Object? villeId = freezed,
    Object? titre = freezed,
    Object? description = freezed,
    Object? isActive = null,
    Object? audience = null,
    Object? targetCooperativeId = freezed,
    Object? dateLimiteLivraison = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? produitNom = freezed,
    Object? buyer = freezed,
    Object? regionNom = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            buyerId: null == buyerId
                ? _value.buyerId
                : buyerId // ignore: cast_nullable_to_non_nullable
                      as String,
            produitId: null == produitId
                ? _value.produitId
                : produitId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantiteKg: null == quantiteKg
                ? _value.quantiteKg
                : quantiteKg // ignore: cast_nullable_to_non_nullable
                      as double,
            prixMaxKg: null == prixMaxKg
                ? _value.prixMaxKg
                : prixMaxKg // ignore: cast_nullable_to_non_nullable
                      as double,
            regionId: freezed == regionId
                ? _value.regionId
                : regionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            villeId: freezed == villeId
                ? _value.villeId
                : villeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            titre: freezed == titre
                ? _value.titre
                : titre // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            audience: null == audience
                ? _value.audience
                : audience // ignore: cast_nullable_to_non_nullable
                      as BuyOfferAudience,
            targetCooperativeId: freezed == targetCooperativeId
                ? _value.targetCooperativeId
                : targetCooperativeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateLimiteLivraison: freezed == dateLimiteLivraison
                ? _value.dateLimiteLivraison
                : dateLimiteLivraison // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            produitNom: freezed == produitNom
                ? _value.produitNom
                : produitNom // ignore: cast_nullable_to_non_nullable
                      as String?,
            buyer: freezed == buyer
                ? _value.buyer
                : buyer // ignore: cast_nullable_to_non_nullable
                      as VendeurApercu?,
            regionNom: freezed == regionNom
                ? _value.regionNom
                : regionNom // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnnonceAchatImplCopyWith<$Res>
    implements $AnnonceAchatCopyWith<$Res> {
  factory _$$AnnonceAchatImplCopyWith(
    _$AnnonceAchatImpl value,
    $Res Function(_$AnnonceAchatImpl) then,
  ) = __$$AnnonceAchatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String buyerId,
    String produitId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixMaxKg,
    String? regionId,
    String? villeId,
    String? titre,
    String? description,
    bool isActive,
    @JsonKey(
      name: 'target_audience',
      unknownEnumValue: BuyOfferAudience.unknown,
    )
    BuyOfferAudience audience,
    String? targetCooperativeId,
    DateTime? dateLimiteLivraison,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(
      name: 'produits_agricoles',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    String? produitNom,
    @JsonKey(
      name: 'users',
      fromJson: _buyerInfoFromJson,
      toJson: _buyerInfoToJson,
    )
    VendeurApercu? buyer,
    @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    String? regionNom,
  });
}

/// @nodoc
class __$$AnnonceAchatImplCopyWithImpl<$Res>
    extends _$AnnonceAchatCopyWithImpl<$Res, _$AnnonceAchatImpl>
    implements _$$AnnonceAchatImplCopyWith<$Res> {
  __$$AnnonceAchatImplCopyWithImpl(
    _$AnnonceAchatImpl _value,
    $Res Function(_$AnnonceAchatImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnnonceAchat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? buyerId = null,
    Object? produitId = null,
    Object? quantiteKg = null,
    Object? prixMaxKg = null,
    Object? regionId = freezed,
    Object? villeId = freezed,
    Object? titre = freezed,
    Object? description = freezed,
    Object? isActive = null,
    Object? audience = null,
    Object? targetCooperativeId = freezed,
    Object? dateLimiteLivraison = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? produitNom = freezed,
    Object? buyer = freezed,
    Object? regionNom = freezed,
  }) {
    return _then(
      _$AnnonceAchatImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        buyerId: null == buyerId
            ? _value.buyerId
            : buyerId // ignore: cast_nullable_to_non_nullable
                  as String,
        produitId: null == produitId
            ? _value.produitId
            : produitId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantiteKg: null == quantiteKg
            ? _value.quantiteKg
            : quantiteKg // ignore: cast_nullable_to_non_nullable
                  as double,
        prixMaxKg: null == prixMaxKg
            ? _value.prixMaxKg
            : prixMaxKg // ignore: cast_nullable_to_non_nullable
                  as double,
        regionId: freezed == regionId
            ? _value.regionId
            : regionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        villeId: freezed == villeId
            ? _value.villeId
            : villeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        titre: freezed == titre
            ? _value.titre
            : titre // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        audience: null == audience
            ? _value.audience
            : audience // ignore: cast_nullable_to_non_nullable
                  as BuyOfferAudience,
        targetCooperativeId: freezed == targetCooperativeId
            ? _value.targetCooperativeId
            : targetCooperativeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateLimiteLivraison: freezed == dateLimiteLivraison
            ? _value.dateLimiteLivraison
            : dateLimiteLivraison // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        produitNom: freezed == produitNom
            ? _value.produitNom
            : produitNom // ignore: cast_nullable_to_non_nullable
                  as String?,
        buyer: freezed == buyer
            ? _value.buyer
            : buyer // ignore: cast_nullable_to_non_nullable
                  as VendeurApercu?,
        regionNom: freezed == regionNom
            ? _value.regionNom
            : regionNom // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnnonceAchatImpl extends _AnnonceAchat {
  const _$AnnonceAchatImpl({
    required this.id,
    required this.buyerId,
    required this.produitId,
    @FlexDouble() required this.quantiteKg,
    @FlexDouble() required this.prixMaxKg,
    this.regionId,
    this.villeId,
    this.titre,
    this.description,
    this.isActive = true,
    @JsonKey(
      name: 'target_audience',
      unknownEnumValue: BuyOfferAudience.unknown,
    )
    this.audience = BuyOfferAudience.unknown,
    this.targetCooperativeId,
    this.dateLimiteLivraison,
    this.createdAt,
    this.updatedAt,
    @JsonKey(
      name: 'produits_agricoles',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    this.produitNom,
    @JsonKey(
      name: 'users',
      fromJson: _buyerInfoFromJson,
      toJson: _buyerInfoToJson,
    )
    this.buyer,
    @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    this.regionNom,
  }) : super._();

  factory _$AnnonceAchatImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnnonceAchatImplFromJson(json);

  @override
  final String id;
  @override
  final String buyerId;
  @override
  final String produitId;
  @override
  @FlexDouble()
  final double quantiteKg;
  @override
  @FlexDouble()
  final double prixMaxKg;
  @override
  final String? regionId;
  @override
  final String? villeId;
  @override
  final String? titre;
  @override
  final String? description;

  /// Le backend renvoie `is_active` (bool), pas un statut enum.
  /// Une demande est "active" si l'acheteur cherche encore (≠ archivée).
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey(name: 'target_audience', unknownEnumValue: BuyOfferAudience.unknown)
  final BuyOfferAudience audience;
  @override
  final String? targetCooperativeId;
  @override
  final DateTime? dateLimiteLivraison;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  // ─── Champs joints ────────────────────────────────────────────────
  @override
  @JsonKey(name: 'produits_agricoles', fromJson: _nomFromMap, toJson: _nomToMap)
  final String? produitNom;
  @override
  @JsonKey(
    name: 'users',
    fromJson: _buyerInfoFromJson,
    toJson: _buyerInfoToJson,
  )
  final VendeurApercu? buyer;
  @override
  @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
  final String? regionNom;

  @override
  String toString() {
    return 'AnnonceAchat(id: $id, buyerId: $buyerId, produitId: $produitId, quantiteKg: $quantiteKg, prixMaxKg: $prixMaxKg, regionId: $regionId, villeId: $villeId, titre: $titre, description: $description, isActive: $isActive, audience: $audience, targetCooperativeId: $targetCooperativeId, dateLimiteLivraison: $dateLimiteLivraison, createdAt: $createdAt, updatedAt: $updatedAt, produitNom: $produitNom, buyer: $buyer, regionNom: $regionNom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnnonceAchatImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.buyerId, buyerId) || other.buyerId == buyerId) &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            (identical(other.quantiteKg, quantiteKg) ||
                other.quantiteKg == quantiteKg) &&
            (identical(other.prixMaxKg, prixMaxKg) ||
                other.prixMaxKg == prixMaxKg) &&
            (identical(other.regionId, regionId) ||
                other.regionId == regionId) &&
            (identical(other.villeId, villeId) || other.villeId == villeId) &&
            (identical(other.titre, titre) || other.titre == titre) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.audience, audience) ||
                other.audience == audience) &&
            (identical(other.targetCooperativeId, targetCooperativeId) ||
                other.targetCooperativeId == targetCooperativeId) &&
            (identical(other.dateLimiteLivraison, dateLimiteLivraison) ||
                other.dateLimiteLivraison == dateLimiteLivraison) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.produitNom, produitNom) ||
                other.produitNom == produitNom) &&
            (identical(other.buyer, buyer) || other.buyer == buyer) &&
            (identical(other.regionNom, regionNom) ||
                other.regionNom == regionNom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    buyerId,
    produitId,
    quantiteKg,
    prixMaxKg,
    regionId,
    villeId,
    titre,
    description,
    isActive,
    audience,
    targetCooperativeId,
    dateLimiteLivraison,
    createdAt,
    updatedAt,
    produitNom,
    buyer,
    regionNom,
  );

  /// Create a copy of AnnonceAchat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnnonceAchatImplCopyWith<_$AnnonceAchatImpl> get copyWith =>
      __$$AnnonceAchatImplCopyWithImpl<_$AnnonceAchatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnnonceAchatImplToJson(this);
  }
}

abstract class _AnnonceAchat extends AnnonceAchat {
  const factory _AnnonceAchat({
    required final String id,
    required final String buyerId,
    required final String produitId,
    @FlexDouble() required final double quantiteKg,
    @FlexDouble() required final double prixMaxKg,
    final String? regionId,
    final String? villeId,
    final String? titre,
    final String? description,
    final bool isActive,
    @JsonKey(
      name: 'target_audience',
      unknownEnumValue: BuyOfferAudience.unknown,
    )
    final BuyOfferAudience audience,
    final String? targetCooperativeId,
    final DateTime? dateLimiteLivraison,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    @JsonKey(
      name: 'produits_agricoles',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    final String? produitNom,
    @JsonKey(
      name: 'users',
      fromJson: _buyerInfoFromJson,
      toJson: _buyerInfoToJson,
    )
    final VendeurApercu? buyer,
    @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    final String? regionNom,
  }) = _$AnnonceAchatImpl;
  const _AnnonceAchat._() : super._();

  factory _AnnonceAchat.fromJson(Map<String, dynamic> json) =
      _$AnnonceAchatImpl.fromJson;

  @override
  String get id;
  @override
  String get buyerId;
  @override
  String get produitId;
  @override
  @FlexDouble()
  double get quantiteKg;
  @override
  @FlexDouble()
  double get prixMaxKg;
  @override
  String? get regionId;
  @override
  String? get villeId;
  @override
  String? get titre;
  @override
  String? get description;

  /// Le backend renvoie `is_active` (bool), pas un statut enum.
  /// Une demande est "active" si l'acheteur cherche encore (≠ archivée).
  @override
  bool get isActive;
  @override
  @JsonKey(name: 'target_audience', unknownEnumValue: BuyOfferAudience.unknown)
  BuyOfferAudience get audience;
  @override
  String? get targetCooperativeId;
  @override
  DateTime? get dateLimiteLivraison;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // ─── Champs joints ────────────────────────────────────────────────
  @override
  @JsonKey(name: 'produits_agricoles', fromJson: _nomFromMap, toJson: _nomToMap)
  String? get produitNom;
  @override
  @JsonKey(
    name: 'users',
    fromJson: _buyerInfoFromJson,
    toJson: _buyerInfoToJson,
  )
  VendeurApercu? get buyer;
  @override
  @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
  String? get regionNom;

  /// Create a copy of AnnonceAchat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnnonceAchatImplCopyWith<_$AnnonceAchatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
