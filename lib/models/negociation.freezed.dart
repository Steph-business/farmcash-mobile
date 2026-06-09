// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'negociation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Candidature _$CandidatureFromJson(Map<String, dynamic> json) {
  return _Candidature.fromJson(json);
}

/// @nodoc
mixin _$Candidature {
  String get id => throw _privateConstructorUsedError;
  String get annonceId => throw _privateConstructorUsedError;
  String get buyerId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get quantiteKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get prixProposeKg => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
  NegotiationStatus get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Candidature to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Candidature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CandidatureCopyWith<Candidature> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CandidatureCopyWith<$Res> {
  factory $CandidatureCopyWith(
    Candidature value,
    $Res Function(Candidature) then,
  ) = _$CandidatureCopyWithImpl<$Res, Candidature>;
  @useResult
  $Res call({
    String id,
    String annonceId,
    String buyerId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    NegotiationStatus status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$CandidatureCopyWithImpl<$Res, $Val extends Candidature>
    implements $CandidatureCopyWith<$Res> {
  _$CandidatureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Candidature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? annonceId = null,
    Object? buyerId = null,
    Object? quantiteKg = null,
    Object? prixProposeKg = null,
    Object? status = null,
    Object? message = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            annonceId: null == annonceId
                ? _value.annonceId
                : annonceId // ignore: cast_nullable_to_non_nullable
                      as String,
            buyerId: null == buyerId
                ? _value.buyerId
                : buyerId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantiteKg: null == quantiteKg
                ? _value.quantiteKg
                : quantiteKg // ignore: cast_nullable_to_non_nullable
                      as double,
            prixProposeKg: null == prixProposeKg
                ? _value.prixProposeKg
                : prixProposeKg // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as NegotiationStatus,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CandidatureImplCopyWith<$Res>
    implements $CandidatureCopyWith<$Res> {
  factory _$$CandidatureImplCopyWith(
    _$CandidatureImpl value,
    $Res Function(_$CandidatureImpl) then,
  ) = __$$CandidatureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String annonceId,
    String buyerId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    NegotiationStatus status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$CandidatureImplCopyWithImpl<$Res>
    extends _$CandidatureCopyWithImpl<$Res, _$CandidatureImpl>
    implements _$$CandidatureImplCopyWith<$Res> {
  __$$CandidatureImplCopyWithImpl(
    _$CandidatureImpl _value,
    $Res Function(_$CandidatureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Candidature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? annonceId = null,
    Object? buyerId = null,
    Object? quantiteKg = null,
    Object? prixProposeKg = null,
    Object? status = null,
    Object? message = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$CandidatureImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        annonceId: null == annonceId
            ? _value.annonceId
            : annonceId // ignore: cast_nullable_to_non_nullable
                  as String,
        buyerId: null == buyerId
            ? _value.buyerId
            : buyerId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantiteKg: null == quantiteKg
            ? _value.quantiteKg
            : quantiteKg // ignore: cast_nullable_to_non_nullable
                  as double,
        prixProposeKg: null == prixProposeKg
            ? _value.prixProposeKg
            : prixProposeKg // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as NegotiationStatus,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CandidatureImpl implements _Candidature {
  const _$CandidatureImpl({
    required this.id,
    required this.annonceId,
    required this.buyerId,
    @FlexDouble() required this.quantiteKg,
    @FlexDouble() required this.prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    this.status = NegotiationStatus.unknown,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  factory _$CandidatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$CandidatureImplFromJson(json);

  @override
  final String id;
  @override
  final String annonceId;
  @override
  final String buyerId;
  @override
  @FlexDouble()
  final double quantiteKg;
  @override
  @FlexDouble()
  final double prixProposeKg;
  @override
  @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
  final NegotiationStatus status;
  @override
  final String? message;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Candidature(id: $id, annonceId: $annonceId, buyerId: $buyerId, quantiteKg: $quantiteKg, prixProposeKg: $prixProposeKg, status: $status, message: $message, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CandidatureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.annonceId, annonceId) ||
                other.annonceId == annonceId) &&
            (identical(other.buyerId, buyerId) || other.buyerId == buyerId) &&
            (identical(other.quantiteKg, quantiteKg) ||
                other.quantiteKg == quantiteKg) &&
            (identical(other.prixProposeKg, prixProposeKg) ||
                other.prixProposeKg == prixProposeKg) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    annonceId,
    buyerId,
    quantiteKg,
    prixProposeKg,
    status,
    message,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Candidature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CandidatureImplCopyWith<_$CandidatureImpl> get copyWith =>
      __$$CandidatureImplCopyWithImpl<_$CandidatureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CandidatureImplToJson(this);
  }
}

abstract class _Candidature implements Candidature {
  const factory _Candidature({
    required final String id,
    required final String annonceId,
    required final String buyerId,
    @FlexDouble() required final double quantiteKg,
    @FlexDouble() required final double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    final NegotiationStatus status,
    final String? message,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$CandidatureImpl;

  factory _Candidature.fromJson(Map<String, dynamic> json) =
      _$CandidatureImpl.fromJson;

  @override
  String get id;
  @override
  String get annonceId;
  @override
  String get buyerId;
  @override
  @FlexDouble()
  double get quantiteKg;
  @override
  @FlexDouble()
  double get prixProposeKg;
  @override
  @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
  NegotiationStatus get status;
  @override
  String? get message;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Candidature
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CandidatureImplCopyWith<_$CandidatureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Proposition _$PropositionFromJson(Map<String, dynamic> json) {
  return _Proposition.fromJson(json);
}

/// @nodoc
mixin _$Proposition {
  String get id => throw _privateConstructorUsedError;
  String get annonceAchatId => throw _privateConstructorUsedError;
  String get vendeurId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get quantiteKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get prixProposeKg => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
  NegotiationStatus get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Vendeur joint backend (nom, rôle, photo, rating + coop si applicable).
  /// Permet au mobile de basculer en mode « Garanties coop » dès que
  /// `vendeur?.cooperative != null`.
  @JsonKey(name: 'users', fromJson: _vendeurFromJson, toJson: _vendeurToJson)
  VendeurProposition? get vendeur => throw _privateConstructorUsedError;

  /// Serializes this Proposition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Proposition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PropositionCopyWith<Proposition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PropositionCopyWith<$Res> {
  factory $PropositionCopyWith(
    Proposition value,
    $Res Function(Proposition) then,
  ) = _$PropositionCopyWithImpl<$Res, Proposition>;
  @useResult
  $Res call({
    String id,
    String annonceAchatId,
    String vendeurId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    NegotiationStatus status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(name: 'users', fromJson: _vendeurFromJson, toJson: _vendeurToJson)
    VendeurProposition? vendeur,
  });
}

/// @nodoc
class _$PropositionCopyWithImpl<$Res, $Val extends Proposition>
    implements $PropositionCopyWith<$Res> {
  _$PropositionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Proposition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? annonceAchatId = null,
    Object? vendeurId = null,
    Object? quantiteKg = null,
    Object? prixProposeKg = null,
    Object? status = null,
    Object? message = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? vendeur = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            annonceAchatId: null == annonceAchatId
                ? _value.annonceAchatId
                : annonceAchatId // ignore: cast_nullable_to_non_nullable
                      as String,
            vendeurId: null == vendeurId
                ? _value.vendeurId
                : vendeurId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantiteKg: null == quantiteKg
                ? _value.quantiteKg
                : quantiteKg // ignore: cast_nullable_to_non_nullable
                      as double,
            prixProposeKg: null == prixProposeKg
                ? _value.prixProposeKg
                : prixProposeKg // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as NegotiationStatus,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            vendeur: freezed == vendeur
                ? _value.vendeur
                : vendeur // ignore: cast_nullable_to_non_nullable
                      as VendeurProposition?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PropositionImplCopyWith<$Res>
    implements $PropositionCopyWith<$Res> {
  factory _$$PropositionImplCopyWith(
    _$PropositionImpl value,
    $Res Function(_$PropositionImpl) then,
  ) = __$$PropositionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String annonceAchatId,
    String vendeurId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    NegotiationStatus status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(name: 'users', fromJson: _vendeurFromJson, toJson: _vendeurToJson)
    VendeurProposition? vendeur,
  });
}

/// @nodoc
class __$$PropositionImplCopyWithImpl<$Res>
    extends _$PropositionCopyWithImpl<$Res, _$PropositionImpl>
    implements _$$PropositionImplCopyWith<$Res> {
  __$$PropositionImplCopyWithImpl(
    _$PropositionImpl _value,
    $Res Function(_$PropositionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Proposition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? annonceAchatId = null,
    Object? vendeurId = null,
    Object? quantiteKg = null,
    Object? prixProposeKg = null,
    Object? status = null,
    Object? message = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? vendeur = freezed,
  }) {
    return _then(
      _$PropositionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        annonceAchatId: null == annonceAchatId
            ? _value.annonceAchatId
            : annonceAchatId // ignore: cast_nullable_to_non_nullable
                  as String,
        vendeurId: null == vendeurId
            ? _value.vendeurId
            : vendeurId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantiteKg: null == quantiteKg
            ? _value.quantiteKg
            : quantiteKg // ignore: cast_nullable_to_non_nullable
                  as double,
        prixProposeKg: null == prixProposeKg
            ? _value.prixProposeKg
            : prixProposeKg // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as NegotiationStatus,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        vendeur: freezed == vendeur
            ? _value.vendeur
            : vendeur // ignore: cast_nullable_to_non_nullable
                  as VendeurProposition?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PropositionImpl extends _Proposition {
  const _$PropositionImpl({
    required this.id,
    required this.annonceAchatId,
    required this.vendeurId,
    @FlexDouble() required this.quantiteKg,
    @FlexDouble() required this.prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    this.status = NegotiationStatus.unknown,
    this.message,
    this.createdAt,
    this.updatedAt,
    @JsonKey(name: 'users', fromJson: _vendeurFromJson, toJson: _vendeurToJson)
    this.vendeur,
  }) : super._();

  factory _$PropositionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PropositionImplFromJson(json);

  @override
  final String id;
  @override
  final String annonceAchatId;
  @override
  final String vendeurId;
  @override
  @FlexDouble()
  final double quantiteKg;
  @override
  @FlexDouble()
  final double prixProposeKg;
  @override
  @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
  final NegotiationStatus status;
  @override
  final String? message;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Vendeur joint backend (nom, rôle, photo, rating + coop si applicable).
  /// Permet au mobile de basculer en mode « Garanties coop » dès que
  /// `vendeur?.cooperative != null`.
  @override
  @JsonKey(name: 'users', fromJson: _vendeurFromJson, toJson: _vendeurToJson)
  final VendeurProposition? vendeur;

  @override
  String toString() {
    return 'Proposition(id: $id, annonceAchatId: $annonceAchatId, vendeurId: $vendeurId, quantiteKg: $quantiteKg, prixProposeKg: $prixProposeKg, status: $status, message: $message, createdAt: $createdAt, updatedAt: $updatedAt, vendeur: $vendeur)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PropositionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.annonceAchatId, annonceAchatId) ||
                other.annonceAchatId == annonceAchatId) &&
            (identical(other.vendeurId, vendeurId) ||
                other.vendeurId == vendeurId) &&
            (identical(other.quantiteKg, quantiteKg) ||
                other.quantiteKg == quantiteKg) &&
            (identical(other.prixProposeKg, prixProposeKg) ||
                other.prixProposeKg == prixProposeKg) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.vendeur, vendeur) || other.vendeur == vendeur));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    annonceAchatId,
    vendeurId,
    quantiteKg,
    prixProposeKg,
    status,
    message,
    createdAt,
    updatedAt,
    vendeur,
  );

  /// Create a copy of Proposition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PropositionImplCopyWith<_$PropositionImpl> get copyWith =>
      __$$PropositionImplCopyWithImpl<_$PropositionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PropositionImplToJson(this);
  }
}

abstract class _Proposition extends Proposition {
  const factory _Proposition({
    required final String id,
    required final String annonceAchatId,
    required final String vendeurId,
    @FlexDouble() required final double quantiteKg,
    @FlexDouble() required final double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    final NegotiationStatus status,
    final String? message,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    @JsonKey(name: 'users', fromJson: _vendeurFromJson, toJson: _vendeurToJson)
    final VendeurProposition? vendeur,
  }) = _$PropositionImpl;
  const _Proposition._() : super._();

  factory _Proposition.fromJson(Map<String, dynamic> json) =
      _$PropositionImpl.fromJson;

  @override
  String get id;
  @override
  String get annonceAchatId;
  @override
  String get vendeurId;
  @override
  @FlexDouble()
  double get quantiteKg;
  @override
  @FlexDouble()
  double get prixProposeKg;
  @override
  @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
  NegotiationStatus get status;
  @override
  String? get message;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Vendeur joint backend (nom, rôle, photo, rating + coop si applicable).
  /// Permet au mobile de basculer en mode « Garanties coop » dès que
  /// `vendeur?.cooperative != null`.
  @override
  @JsonKey(name: 'users', fromJson: _vendeurFromJson, toJson: _vendeurToJson)
  VendeurProposition? get vendeur;

  /// Create a copy of Proposition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PropositionImplCopyWith<_$PropositionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TraitementNegociationResultat _$TraitementNegociationResultatFromJson(
  Map<String, dynamic> json,
) {
  return _TraitementNegociationResultat.fromJson(json);
}

/// @nodoc
mixin _$TraitementNegociationResultat {
  String get message => throw _privateConstructorUsedError;
  String? get commandeId => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;

  /// Serializes this TraitementNegociationResultat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TraitementNegociationResultat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TraitementNegociationResultatCopyWith<TraitementNegociationResultat>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TraitementNegociationResultatCopyWith<$Res> {
  factory $TraitementNegociationResultatCopyWith(
    TraitementNegociationResultat value,
    $Res Function(TraitementNegociationResultat) then,
  ) =
      _$TraitementNegociationResultatCopyWithImpl<
        $Res,
        TraitementNegociationResultat
      >;
  @useResult
  $Res call({String message, String? commandeId, String? reference});
}

/// @nodoc
class _$TraitementNegociationResultatCopyWithImpl<
  $Res,
  $Val extends TraitementNegociationResultat
>
    implements $TraitementNegociationResultatCopyWith<$Res> {
  _$TraitementNegociationResultatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TraitementNegociationResultat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? commandeId = freezed,
    Object? reference = freezed,
  }) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            commandeId: freezed == commandeId
                ? _value.commandeId
                : commandeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            reference: freezed == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TraitementNegociationResultatImplCopyWith<$Res>
    implements $TraitementNegociationResultatCopyWith<$Res> {
  factory _$$TraitementNegociationResultatImplCopyWith(
    _$TraitementNegociationResultatImpl value,
    $Res Function(_$TraitementNegociationResultatImpl) then,
  ) = __$$TraitementNegociationResultatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? commandeId, String? reference});
}

/// @nodoc
class __$$TraitementNegociationResultatImplCopyWithImpl<$Res>
    extends
        _$TraitementNegociationResultatCopyWithImpl<
          $Res,
          _$TraitementNegociationResultatImpl
        >
    implements _$$TraitementNegociationResultatImplCopyWith<$Res> {
  __$$TraitementNegociationResultatImplCopyWithImpl(
    _$TraitementNegociationResultatImpl _value,
    $Res Function(_$TraitementNegociationResultatImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TraitementNegociationResultat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? commandeId = freezed,
    Object? reference = freezed,
  }) {
    return _then(
      _$TraitementNegociationResultatImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        commandeId: freezed == commandeId
            ? _value.commandeId
            : commandeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        reference: freezed == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TraitementNegociationResultatImpl
    implements _TraitementNegociationResultat {
  const _$TraitementNegociationResultatImpl({
    this.message = '',
    this.commandeId,
    this.reference,
  });

  factory _$TraitementNegociationResultatImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$TraitementNegociationResultatImplFromJson(json);

  @override
  @JsonKey()
  final String message;
  @override
  final String? commandeId;
  @override
  final String? reference;

  @override
  String toString() {
    return 'TraitementNegociationResultat(message: $message, commandeId: $commandeId, reference: $reference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TraitementNegociationResultatImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.commandeId, commandeId) ||
                other.commandeId == commandeId) &&
            (identical(other.reference, reference) ||
                other.reference == reference));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, commandeId, reference);

  /// Create a copy of TraitementNegociationResultat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TraitementNegociationResultatImplCopyWith<
    _$TraitementNegociationResultatImpl
  >
  get copyWith =>
      __$$TraitementNegociationResultatImplCopyWithImpl<
        _$TraitementNegociationResultatImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TraitementNegociationResultatImplToJson(this);
  }
}

abstract class _TraitementNegociationResultat
    implements TraitementNegociationResultat {
  const factory _TraitementNegociationResultat({
    final String message,
    final String? commandeId,
    final String? reference,
  }) = _$TraitementNegociationResultatImpl;

  factory _TraitementNegociationResultat.fromJson(Map<String, dynamic> json) =
      _$TraitementNegociationResultatImpl.fromJson;

  @override
  String get message;
  @override
  String? get commandeId;
  @override
  String? get reference;

  /// Create a copy of TraitementNegociationResultat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TraitementNegociationResultatImplCopyWith<
    _$TraitementNegociationResultatImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

ContreOffreCoop _$ContreOffreCoopFromJson(Map<String, dynamic> json) {
  return _ContreOffreCoop.fromJson(json);
}

/// @nodoc
mixin _$ContreOffreCoop {
  String get id => throw _privateConstructorUsedError;
  String get publicationCoopId => throw _privateConstructorUsedError;
  String get buyerId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get quantiteKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get prixProposeKg => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
  NegotiationStatus get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ContreOffreCoop to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContreOffreCoop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContreOffreCoopCopyWith<ContreOffreCoop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContreOffreCoopCopyWith<$Res> {
  factory $ContreOffreCoopCopyWith(
    ContreOffreCoop value,
    $Res Function(ContreOffreCoop) then,
  ) = _$ContreOffreCoopCopyWithImpl<$Res, ContreOffreCoop>;
  @useResult
  $Res call({
    String id,
    String publicationCoopId,
    String buyerId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    NegotiationStatus status,
    String? message,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$ContreOffreCoopCopyWithImpl<$Res, $Val extends ContreOffreCoop>
    implements $ContreOffreCoopCopyWith<$Res> {
  _$ContreOffreCoopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContreOffreCoop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? publicationCoopId = null,
    Object? buyerId = null,
    Object? quantiteKg = null,
    Object? prixProposeKg = null,
    Object? status = null,
    Object? message = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            publicationCoopId: null == publicationCoopId
                ? _value.publicationCoopId
                : publicationCoopId // ignore: cast_nullable_to_non_nullable
                      as String,
            buyerId: null == buyerId
                ? _value.buyerId
                : buyerId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantiteKg: null == quantiteKg
                ? _value.quantiteKg
                : quantiteKg // ignore: cast_nullable_to_non_nullable
                      as double,
            prixProposeKg: null == prixProposeKg
                ? _value.prixProposeKg
                : prixProposeKg // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as NegotiationStatus,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ContreOffreCoopImplCopyWith<$Res>
    implements $ContreOffreCoopCopyWith<$Res> {
  factory _$$ContreOffreCoopImplCopyWith(
    _$ContreOffreCoopImpl value,
    $Res Function(_$ContreOffreCoopImpl) then,
  ) = __$$ContreOffreCoopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String publicationCoopId,
    String buyerId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    NegotiationStatus status,
    String? message,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$ContreOffreCoopImplCopyWithImpl<$Res>
    extends _$ContreOffreCoopCopyWithImpl<$Res, _$ContreOffreCoopImpl>
    implements _$$ContreOffreCoopImplCopyWith<$Res> {
  __$$ContreOffreCoopImplCopyWithImpl(
    _$ContreOffreCoopImpl _value,
    $Res Function(_$ContreOffreCoopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ContreOffreCoop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? publicationCoopId = null,
    Object? buyerId = null,
    Object? quantiteKg = null,
    Object? prixProposeKg = null,
    Object? status = null,
    Object? message = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ContreOffreCoopImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        publicationCoopId: null == publicationCoopId
            ? _value.publicationCoopId
            : publicationCoopId // ignore: cast_nullable_to_non_nullable
                  as String,
        buyerId: null == buyerId
            ? _value.buyerId
            : buyerId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantiteKg: null == quantiteKg
            ? _value.quantiteKg
            : quantiteKg // ignore: cast_nullable_to_non_nullable
                  as double,
        prixProposeKg: null == prixProposeKg
            ? _value.prixProposeKg
            : prixProposeKg // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as NegotiationStatus,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContreOffreCoopImpl implements _ContreOffreCoop {
  const _$ContreOffreCoopImpl({
    required this.id,
    required this.publicationCoopId,
    required this.buyerId,
    @FlexDouble() required this.quantiteKg,
    @FlexDouble() required this.prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    this.status = NegotiationStatus.unknown,
    this.message,
    this.createdAt,
  });

  factory _$ContreOffreCoopImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContreOffreCoopImplFromJson(json);

  @override
  final String id;
  @override
  final String publicationCoopId;
  @override
  final String buyerId;
  @override
  @FlexDouble()
  final double quantiteKg;
  @override
  @FlexDouble()
  final double prixProposeKg;
  @override
  @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
  final NegotiationStatus status;
  @override
  final String? message;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ContreOffreCoop(id: $id, publicationCoopId: $publicationCoopId, buyerId: $buyerId, quantiteKg: $quantiteKg, prixProposeKg: $prixProposeKg, status: $status, message: $message, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContreOffreCoopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.publicationCoopId, publicationCoopId) ||
                other.publicationCoopId == publicationCoopId) &&
            (identical(other.buyerId, buyerId) || other.buyerId == buyerId) &&
            (identical(other.quantiteKg, quantiteKg) ||
                other.quantiteKg == quantiteKg) &&
            (identical(other.prixProposeKg, prixProposeKg) ||
                other.prixProposeKg == prixProposeKg) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    publicationCoopId,
    buyerId,
    quantiteKg,
    prixProposeKg,
    status,
    message,
    createdAt,
  );

  /// Create a copy of ContreOffreCoop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContreOffreCoopImplCopyWith<_$ContreOffreCoopImpl> get copyWith =>
      __$$ContreOffreCoopImplCopyWithImpl<_$ContreOffreCoopImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ContreOffreCoopImplToJson(this);
  }
}

abstract class _ContreOffreCoop implements ContreOffreCoop {
  const factory _ContreOffreCoop({
    required final String id,
    required final String publicationCoopId,
    required final String buyerId,
    @FlexDouble() required final double quantiteKg,
    @FlexDouble() required final double prixProposeKg,
    @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
    final NegotiationStatus status,
    final String? message,
    final DateTime? createdAt,
  }) = _$ContreOffreCoopImpl;

  factory _ContreOffreCoop.fromJson(Map<String, dynamic> json) =
      _$ContreOffreCoopImpl.fromJson;

  @override
  String get id;
  @override
  String get publicationCoopId;
  @override
  String get buyerId;
  @override
  @FlexDouble()
  double get quantiteKg;
  @override
  @FlexDouble()
  double get prixProposeKg;
  @override
  @JsonKey(unknownEnumValue: NegotiationStatus.unknown)
  NegotiationStatus get status;
  @override
  String? get message;
  @override
  DateTime? get createdAt;

  /// Create a copy of ContreOffreCoop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContreOffreCoopImplCopyWith<_$ContreOffreCoopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
