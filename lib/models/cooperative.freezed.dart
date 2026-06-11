// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cooperative.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Cooperative _$CooperativeFromJson(Map<String, dynamic> json) {
  return _Cooperative.fromJson(json);
}

/// @nodoc
mixin _$Cooperative {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String? get numeroAgrement => throw _privateConstructorUsedError;
  String? get regionId => throw _privateConstructorUsedError;
  String? get villeId => throw _privateConstructorUsedError;
  @FlexInt()
  int get nbMembres => throw _privateConstructorUsedError;
  List<String> get produits => throw _privateConstructorUsedError;
  @FlexDouble()
  double get commissionRate => throw _privateConstructorUsedError;
  bool get autoDistribute => throw _privateConstructorUsedError;
  String? get presidentId => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime? get createdAt =>
      throw _privateConstructorUsedError; // ─── Parrainage local (chantier 5) ────────────────────────────
  // Affiché côté acheteur quand les 3 champs sont remplis.
  String? get ambassadeurNom => throw _privateConstructorUsedError;
  String? get ambassadeurTitre => throw _privateConstructorUsedError;
  String? get ambassadeurOrganisation => throw _privateConstructorUsedError;
  DateTime? get ambassadeurValidatedAt => throw _privateConstructorUsedError;

  /// Serializes this Cooperative to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Cooperative
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CooperativeCopyWith<Cooperative> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CooperativeCopyWith<$Res> {
  factory $CooperativeCopyWith(
    Cooperative value,
    $Res Function(Cooperative) then,
  ) = _$CooperativeCopyWithImpl<$Res, Cooperative>;
  @useResult
  $Res call({
    String id,
    String userId,
    String nom,
    String? numeroAgrement,
    String? regionId,
    String? villeId,
    @FlexInt() int nbMembres,
    List<String> produits,
    @FlexDouble() double commissionRate,
    bool autoDistribute,
    String? presidentId,
    String? logoUrl,
    String? description,
    DateTime? createdAt,
    String? ambassadeurNom,
    String? ambassadeurTitre,
    String? ambassadeurOrganisation,
    DateTime? ambassadeurValidatedAt,
  });
}

/// @nodoc
class _$CooperativeCopyWithImpl<$Res, $Val extends Cooperative>
    implements $CooperativeCopyWith<$Res> {
  _$CooperativeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Cooperative
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? nom = null,
    Object? numeroAgrement = freezed,
    Object? regionId = freezed,
    Object? villeId = freezed,
    Object? nbMembres = null,
    Object? produits = null,
    Object? commissionRate = null,
    Object? autoDistribute = null,
    Object? presidentId = freezed,
    Object? logoUrl = freezed,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? ambassadeurNom = freezed,
    Object? ambassadeurTitre = freezed,
    Object? ambassadeurOrganisation = freezed,
    Object? ambassadeurValidatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            nom: null == nom
                ? _value.nom
                : nom // ignore: cast_nullable_to_non_nullable
                      as String,
            numeroAgrement: freezed == numeroAgrement
                ? _value.numeroAgrement
                : numeroAgrement // ignore: cast_nullable_to_non_nullable
                      as String?,
            regionId: freezed == regionId
                ? _value.regionId
                : regionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            villeId: freezed == villeId
                ? _value.villeId
                : villeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            nbMembres: null == nbMembres
                ? _value.nbMembres
                : nbMembres // ignore: cast_nullable_to_non_nullable
                      as int,
            produits: null == produits
                ? _value.produits
                : produits // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            commissionRate: null == commissionRate
                ? _value.commissionRate
                : commissionRate // ignore: cast_nullable_to_non_nullable
                      as double,
            autoDistribute: null == autoDistribute
                ? _value.autoDistribute
                : autoDistribute // ignore: cast_nullable_to_non_nullable
                      as bool,
            presidentId: freezed == presidentId
                ? _value.presidentId
                : presidentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            logoUrl: freezed == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            ambassadeurNom: freezed == ambassadeurNom
                ? _value.ambassadeurNom
                : ambassadeurNom // ignore: cast_nullable_to_non_nullable
                      as String?,
            ambassadeurTitre: freezed == ambassadeurTitre
                ? _value.ambassadeurTitre
                : ambassadeurTitre // ignore: cast_nullable_to_non_nullable
                      as String?,
            ambassadeurOrganisation: freezed == ambassadeurOrganisation
                ? _value.ambassadeurOrganisation
                : ambassadeurOrganisation // ignore: cast_nullable_to_non_nullable
                      as String?,
            ambassadeurValidatedAt: freezed == ambassadeurValidatedAt
                ? _value.ambassadeurValidatedAt
                : ambassadeurValidatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CooperativeImplCopyWith<$Res>
    implements $CooperativeCopyWith<$Res> {
  factory _$$CooperativeImplCopyWith(
    _$CooperativeImpl value,
    $Res Function(_$CooperativeImpl) then,
  ) = __$$CooperativeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String nom,
    String? numeroAgrement,
    String? regionId,
    String? villeId,
    @FlexInt() int nbMembres,
    List<String> produits,
    @FlexDouble() double commissionRate,
    bool autoDistribute,
    String? presidentId,
    String? logoUrl,
    String? description,
    DateTime? createdAt,
    String? ambassadeurNom,
    String? ambassadeurTitre,
    String? ambassadeurOrganisation,
    DateTime? ambassadeurValidatedAt,
  });
}

/// @nodoc
class __$$CooperativeImplCopyWithImpl<$Res>
    extends _$CooperativeCopyWithImpl<$Res, _$CooperativeImpl>
    implements _$$CooperativeImplCopyWith<$Res> {
  __$$CooperativeImplCopyWithImpl(
    _$CooperativeImpl _value,
    $Res Function(_$CooperativeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Cooperative
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? nom = null,
    Object? numeroAgrement = freezed,
    Object? regionId = freezed,
    Object? villeId = freezed,
    Object? nbMembres = null,
    Object? produits = null,
    Object? commissionRate = null,
    Object? autoDistribute = null,
    Object? presidentId = freezed,
    Object? logoUrl = freezed,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? ambassadeurNom = freezed,
    Object? ambassadeurTitre = freezed,
    Object? ambassadeurOrganisation = freezed,
    Object? ambassadeurValidatedAt = freezed,
  }) {
    return _then(
      _$CooperativeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        numeroAgrement: freezed == numeroAgrement
            ? _value.numeroAgrement
            : numeroAgrement // ignore: cast_nullable_to_non_nullable
                  as String?,
        regionId: freezed == regionId
            ? _value.regionId
            : regionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        villeId: freezed == villeId
            ? _value.villeId
            : villeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        nbMembres: null == nbMembres
            ? _value.nbMembres
            : nbMembres // ignore: cast_nullable_to_non_nullable
                  as int,
        produits: null == produits
            ? _value._produits
            : produits // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        commissionRate: null == commissionRate
            ? _value.commissionRate
            : commissionRate // ignore: cast_nullable_to_non_nullable
                  as double,
        autoDistribute: null == autoDistribute
            ? _value.autoDistribute
            : autoDistribute // ignore: cast_nullable_to_non_nullable
                  as bool,
        presidentId: freezed == presidentId
            ? _value.presidentId
            : presidentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        logoUrl: freezed == logoUrl
            ? _value.logoUrl
            : logoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        ambassadeurNom: freezed == ambassadeurNom
            ? _value.ambassadeurNom
            : ambassadeurNom // ignore: cast_nullable_to_non_nullable
                  as String?,
        ambassadeurTitre: freezed == ambassadeurTitre
            ? _value.ambassadeurTitre
            : ambassadeurTitre // ignore: cast_nullable_to_non_nullable
                  as String?,
        ambassadeurOrganisation: freezed == ambassadeurOrganisation
            ? _value.ambassadeurOrganisation
            : ambassadeurOrganisation // ignore: cast_nullable_to_non_nullable
                  as String?,
        ambassadeurValidatedAt: freezed == ambassadeurValidatedAt
            ? _value.ambassadeurValidatedAt
            : ambassadeurValidatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CooperativeImpl implements _Cooperative {
  const _$CooperativeImpl({
    required this.id,
    required this.userId,
    required this.nom,
    this.numeroAgrement,
    this.regionId,
    this.villeId,
    @FlexInt() this.nbMembres = 0,
    final List<String> produits = const <String>[],
    @FlexDouble() this.commissionRate = 0.0,
    this.autoDistribute = false,
    this.presidentId,
    this.logoUrl,
    this.description,
    this.createdAt,
    this.ambassadeurNom,
    this.ambassadeurTitre,
    this.ambassadeurOrganisation,
    this.ambassadeurValidatedAt,
  }) : _produits = produits;

  factory _$CooperativeImpl.fromJson(Map<String, dynamic> json) =>
      _$$CooperativeImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String nom;
  @override
  final String? numeroAgrement;
  @override
  final String? regionId;
  @override
  final String? villeId;
  @override
  @JsonKey()
  @FlexInt()
  final int nbMembres;
  final List<String> _produits;
  @override
  @JsonKey()
  List<String> get produits {
    if (_produits is EqualUnmodifiableListView) return _produits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_produits);
  }

  @override
  @JsonKey()
  @FlexDouble()
  final double commissionRate;
  @override
  @JsonKey()
  final bool autoDistribute;
  @override
  final String? presidentId;
  @override
  final String? logoUrl;
  @override
  final String? description;
  @override
  final DateTime? createdAt;
  // ─── Parrainage local (chantier 5) ────────────────────────────
  // Affiché côté acheteur quand les 3 champs sont remplis.
  @override
  final String? ambassadeurNom;
  @override
  final String? ambassadeurTitre;
  @override
  final String? ambassadeurOrganisation;
  @override
  final DateTime? ambassadeurValidatedAt;

  @override
  String toString() {
    return 'Cooperative(id: $id, userId: $userId, nom: $nom, numeroAgrement: $numeroAgrement, regionId: $regionId, villeId: $villeId, nbMembres: $nbMembres, produits: $produits, commissionRate: $commissionRate, autoDistribute: $autoDistribute, presidentId: $presidentId, logoUrl: $logoUrl, description: $description, createdAt: $createdAt, ambassadeurNom: $ambassadeurNom, ambassadeurTitre: $ambassadeurTitre, ambassadeurOrganisation: $ambassadeurOrganisation, ambassadeurValidatedAt: $ambassadeurValidatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CooperativeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.numeroAgrement, numeroAgrement) ||
                other.numeroAgrement == numeroAgrement) &&
            (identical(other.regionId, regionId) ||
                other.regionId == regionId) &&
            (identical(other.villeId, villeId) || other.villeId == villeId) &&
            (identical(other.nbMembres, nbMembres) ||
                other.nbMembres == nbMembres) &&
            const DeepCollectionEquality().equals(other._produits, _produits) &&
            (identical(other.commissionRate, commissionRate) ||
                other.commissionRate == commissionRate) &&
            (identical(other.autoDistribute, autoDistribute) ||
                other.autoDistribute == autoDistribute) &&
            (identical(other.presidentId, presidentId) ||
                other.presidentId == presidentId) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.ambassadeurNom, ambassadeurNom) ||
                other.ambassadeurNom == ambassadeurNom) &&
            (identical(other.ambassadeurTitre, ambassadeurTitre) ||
                other.ambassadeurTitre == ambassadeurTitre) &&
            (identical(
                  other.ambassadeurOrganisation,
                  ambassadeurOrganisation,
                ) ||
                other.ambassadeurOrganisation == ambassadeurOrganisation) &&
            (identical(other.ambassadeurValidatedAt, ambassadeurValidatedAt) ||
                other.ambassadeurValidatedAt == ambassadeurValidatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    nom,
    numeroAgrement,
    regionId,
    villeId,
    nbMembres,
    const DeepCollectionEquality().hash(_produits),
    commissionRate,
    autoDistribute,
    presidentId,
    logoUrl,
    description,
    createdAt,
    ambassadeurNom,
    ambassadeurTitre,
    ambassadeurOrganisation,
    ambassadeurValidatedAt,
  );

  /// Create a copy of Cooperative
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CooperativeImplCopyWith<_$CooperativeImpl> get copyWith =>
      __$$CooperativeImplCopyWithImpl<_$CooperativeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CooperativeImplToJson(this);
  }
}

abstract class _Cooperative implements Cooperative {
  const factory _Cooperative({
    required final String id,
    required final String userId,
    required final String nom,
    final String? numeroAgrement,
    final String? regionId,
    final String? villeId,
    @FlexInt() final int nbMembres,
    final List<String> produits,
    @FlexDouble() final double commissionRate,
    final bool autoDistribute,
    final String? presidentId,
    final String? logoUrl,
    final String? description,
    final DateTime? createdAt,
    final String? ambassadeurNom,
    final String? ambassadeurTitre,
    final String? ambassadeurOrganisation,
    final DateTime? ambassadeurValidatedAt,
  }) = _$CooperativeImpl;

  factory _Cooperative.fromJson(Map<String, dynamic> json) =
      _$CooperativeImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get nom;
  @override
  String? get numeroAgrement;
  @override
  String? get regionId;
  @override
  String? get villeId;
  @override
  @FlexInt()
  int get nbMembres;
  @override
  List<String> get produits;
  @override
  @FlexDouble()
  double get commissionRate;
  @override
  bool get autoDistribute;
  @override
  String? get presidentId;
  @override
  String? get logoUrl;
  @override
  String? get description;
  @override
  DateTime? get createdAt; // ─── Parrainage local (chantier 5) ────────────────────────────
  // Affiché côté acheteur quand les 3 champs sont remplis.
  @override
  String? get ambassadeurNom;
  @override
  String? get ambassadeurTitre;
  @override
  String? get ambassadeurOrganisation;
  @override
  DateTime? get ambassadeurValidatedAt;

  /// Create a copy of Cooperative
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CooperativeImplCopyWith<_$CooperativeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
