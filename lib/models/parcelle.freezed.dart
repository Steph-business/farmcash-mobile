// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parcelle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Parcelle _$ParcelleFromJson(Map<String, dynamic> json) {
  return _Parcelle.fromJson(json);
}

/// @nodoc
mixin _$Parcelle {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get superficieHa => throw _privateConstructorUsedError;
  String? get produitId => throw _privateConstructorUsedError;
  List<GeoPoint> get contour => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Parcelle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Parcelle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParcelleCopyWith<Parcelle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParcelleCopyWith<$Res> {
  factory $ParcelleCopyWith(Parcelle value, $Res Function(Parcelle) then) =
      _$ParcelleCopyWithImpl<$Res, Parcelle>;
  @useResult
  $Res call({
    String id,
    String userId,
    String nom,
    @FlexDoubleN() double? superficieHa,
    String? produitId,
    List<GeoPoint> contour,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$ParcelleCopyWithImpl<$Res, $Val extends Parcelle>
    implements $ParcelleCopyWith<$Res> {
  _$ParcelleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Parcelle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? nom = null,
    Object? superficieHa = freezed,
    Object? produitId = freezed,
    Object? contour = null,
    Object? createdAt = freezed,
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
            superficieHa: freezed == superficieHa
                ? _value.superficieHa
                : superficieHa // ignore: cast_nullable_to_non_nullable
                      as double?,
            produitId: freezed == produitId
                ? _value.produitId
                : produitId // ignore: cast_nullable_to_non_nullable
                      as String?,
            contour: null == contour
                ? _value.contour
                : contour // ignore: cast_nullable_to_non_nullable
                      as List<GeoPoint>,
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
abstract class _$$ParcelleImplCopyWith<$Res>
    implements $ParcelleCopyWith<$Res> {
  factory _$$ParcelleImplCopyWith(
    _$ParcelleImpl value,
    $Res Function(_$ParcelleImpl) then,
  ) = __$$ParcelleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String nom,
    @FlexDoubleN() double? superficieHa,
    String? produitId,
    List<GeoPoint> contour,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$ParcelleImplCopyWithImpl<$Res>
    extends _$ParcelleCopyWithImpl<$Res, _$ParcelleImpl>
    implements _$$ParcelleImplCopyWith<$Res> {
  __$$ParcelleImplCopyWithImpl(
    _$ParcelleImpl _value,
    $Res Function(_$ParcelleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Parcelle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? nom = null,
    Object? superficieHa = freezed,
    Object? produitId = freezed,
    Object? contour = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ParcelleImpl(
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
        superficieHa: freezed == superficieHa
            ? _value.superficieHa
            : superficieHa // ignore: cast_nullable_to_non_nullable
                  as double?,
        produitId: freezed == produitId
            ? _value.produitId
            : produitId // ignore: cast_nullable_to_non_nullable
                  as String?,
        contour: null == contour
            ? _value._contour
            : contour // ignore: cast_nullable_to_non_nullable
                  as List<GeoPoint>,
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
class _$ParcelleImpl implements _Parcelle {
  const _$ParcelleImpl({
    required this.id,
    required this.userId,
    required this.nom,
    @FlexDoubleN() this.superficieHa,
    this.produitId,
    final List<GeoPoint> contour = const <GeoPoint>[],
    this.createdAt,
  }) : _contour = contour;

  factory _$ParcelleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParcelleImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String nom;
  @override
  @FlexDoubleN()
  final double? superficieHa;
  @override
  final String? produitId;
  final List<GeoPoint> _contour;
  @override
  @JsonKey()
  List<GeoPoint> get contour {
    if (_contour is EqualUnmodifiableListView) return _contour;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contour);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Parcelle(id: $id, userId: $userId, nom: $nom, superficieHa: $superficieHa, produitId: $produitId, contour: $contour, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParcelleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.superficieHa, superficieHa) ||
                other.superficieHa == superficieHa) &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            const DeepCollectionEquality().equals(other._contour, _contour) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    nom,
    superficieHa,
    produitId,
    const DeepCollectionEquality().hash(_contour),
    createdAt,
  );

  /// Create a copy of Parcelle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParcelleImplCopyWith<_$ParcelleImpl> get copyWith =>
      __$$ParcelleImplCopyWithImpl<_$ParcelleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParcelleImplToJson(this);
  }
}

abstract class _Parcelle implements Parcelle {
  const factory _Parcelle({
    required final String id,
    required final String userId,
    required final String nom,
    @FlexDoubleN() final double? superficieHa,
    final String? produitId,
    final List<GeoPoint> contour,
    final DateTime? createdAt,
  }) = _$ParcelleImpl;

  factory _Parcelle.fromJson(Map<String, dynamic> json) =
      _$ParcelleImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get nom;
  @override
  @FlexDoubleN()
  double? get superficieHa;
  @override
  String? get produitId;
  @override
  List<GeoPoint> get contour;
  @override
  DateTime? get createdAt;

  /// Create a copy of Parcelle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParcelleImplCopyWith<_$ParcelleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GeoPoint _$GeoPointFromJson(Map<String, dynamic> json) {
  return _GeoPoint.fromJson(json);
}

/// @nodoc
mixin _$GeoPoint {
  @FlexDouble()
  double get lat => throw _privateConstructorUsedError;
  @FlexDouble()
  double get lng => throw _privateConstructorUsedError;

  /// Serializes this GeoPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeoPointCopyWith<GeoPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeoPointCopyWith<$Res> {
  factory $GeoPointCopyWith(GeoPoint value, $Res Function(GeoPoint) then) =
      _$GeoPointCopyWithImpl<$Res, GeoPoint>;
  @useResult
  $Res call({@FlexDouble() double lat, @FlexDouble() double lng});
}

/// @nodoc
class _$GeoPointCopyWithImpl<$Res, $Val extends GeoPoint>
    implements $GeoPointCopyWith<$Res> {
  _$GeoPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lat = null, Object? lng = null}) {
    return _then(
      _value.copyWith(
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GeoPointImplCopyWith<$Res>
    implements $GeoPointCopyWith<$Res> {
  factory _$$GeoPointImplCopyWith(
    _$GeoPointImpl value,
    $Res Function(_$GeoPointImpl) then,
  ) = __$$GeoPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@FlexDouble() double lat, @FlexDouble() double lng});
}

/// @nodoc
class __$$GeoPointImplCopyWithImpl<$Res>
    extends _$GeoPointCopyWithImpl<$Res, _$GeoPointImpl>
    implements _$$GeoPointImplCopyWith<$Res> {
  __$$GeoPointImplCopyWithImpl(
    _$GeoPointImpl _value,
    $Res Function(_$GeoPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lat = null, Object? lng = null}) {
    return _then(
      _$GeoPointImpl(
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GeoPointImpl implements _GeoPoint {
  const _$GeoPointImpl({
    @FlexDouble() required this.lat,
    @FlexDouble() required this.lng,
  });

  factory _$GeoPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeoPointImplFromJson(json);

  @override
  @FlexDouble()
  final double lat;
  @override
  @FlexDouble()
  final double lng;

  @override
  String toString() {
    return 'GeoPoint(lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeoPointImpl &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lng);

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeoPointImplCopyWith<_$GeoPointImpl> get copyWith =>
      __$$GeoPointImplCopyWithImpl<_$GeoPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeoPointImplToJson(this);
  }
}

abstract class _GeoPoint implements GeoPoint {
  const factory _GeoPoint({
    @FlexDouble() required final double lat,
    @FlexDouble() required final double lng,
  }) = _$GeoPointImpl;

  factory _GeoPoint.fromJson(Map<String, dynamic> json) =
      _$GeoPointImpl.fromJson;

  @override
  @FlexDouble()
  double get lat;
  @override
  @FlexDouble()
  double get lng;

  /// Create a copy of GeoPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeoPointImplCopyWith<_$GeoPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Culture _$CultureFromJson(Map<String, dynamic> json) {
  return _Culture.fromJson(json);
}

/// @nodoc
mixin _$Culture {
  String get id => throw _privateConstructorUsedError;

  /// Nullable côté DB (peuvent exister des cultures historiques sans
  /// parcelle), même si toutes les nouvelles cultures en auront une.
  String? get parcelleId => throw _privateConstructorUsedError;
  String get produitId => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get superficieHa => throw _privateConstructorUsedError;
  DateTime? get dateSemis => throw _privateConstructorUsedError;
  DateTime? get dateRecoltePrevue => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get quantiteEstimeeKg => throw _privateConstructorUsedError;
  String? get statut => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Le back renvoie `produits_agricoles: { nom: "Maïs grain blanc" }`.
  /// On aplatit via le converter pour exposer `produitNom` directement.
  @JsonKey(name: 'produits_agricoles', fromJson: _produitNomFromMap)
  String? get produitNom => throw _privateConstructorUsedError;

  /// Serializes this Culture to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Culture
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CultureCopyWith<Culture> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CultureCopyWith<$Res> {
  factory $CultureCopyWith(Culture value, $Res Function(Culture) then) =
      _$CultureCopyWithImpl<$Res, Culture>;
  @useResult
  $Res call({
    String id,
    String? parcelleId,
    String produitId,
    @FlexDoubleN() double? superficieHa,
    DateTime? dateSemis,
    DateTime? dateRecoltePrevue,
    @FlexDoubleN() double? quantiteEstimeeKg,
    String? statut,
    DateTime? createdAt,
    @JsonKey(name: 'produits_agricoles', fromJson: _produitNomFromMap)
    String? produitNom,
  });
}

/// @nodoc
class _$CultureCopyWithImpl<$Res, $Val extends Culture>
    implements $CultureCopyWith<$Res> {
  _$CultureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Culture
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? parcelleId = freezed,
    Object? produitId = null,
    Object? superficieHa = freezed,
    Object? dateSemis = freezed,
    Object? dateRecoltePrevue = freezed,
    Object? quantiteEstimeeKg = freezed,
    Object? statut = freezed,
    Object? createdAt = freezed,
    Object? produitNom = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            parcelleId: freezed == parcelleId
                ? _value.parcelleId
                : parcelleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            produitId: null == produitId
                ? _value.produitId
                : produitId // ignore: cast_nullable_to_non_nullable
                      as String,
            superficieHa: freezed == superficieHa
                ? _value.superficieHa
                : superficieHa // ignore: cast_nullable_to_non_nullable
                      as double?,
            dateSemis: freezed == dateSemis
                ? _value.dateSemis
                : dateSemis // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dateRecoltePrevue: freezed == dateRecoltePrevue
                ? _value.dateRecoltePrevue
                : dateRecoltePrevue // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            quantiteEstimeeKg: freezed == quantiteEstimeeKg
                ? _value.quantiteEstimeeKg
                : quantiteEstimeeKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            statut: freezed == statut
                ? _value.statut
                : statut // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            produitNom: freezed == produitNom
                ? _value.produitNom
                : produitNom // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CultureImplCopyWith<$Res> implements $CultureCopyWith<$Res> {
  factory _$$CultureImplCopyWith(
    _$CultureImpl value,
    $Res Function(_$CultureImpl) then,
  ) = __$$CultureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? parcelleId,
    String produitId,
    @FlexDoubleN() double? superficieHa,
    DateTime? dateSemis,
    DateTime? dateRecoltePrevue,
    @FlexDoubleN() double? quantiteEstimeeKg,
    String? statut,
    DateTime? createdAt,
    @JsonKey(name: 'produits_agricoles', fromJson: _produitNomFromMap)
    String? produitNom,
  });
}

/// @nodoc
class __$$CultureImplCopyWithImpl<$Res>
    extends _$CultureCopyWithImpl<$Res, _$CultureImpl>
    implements _$$CultureImplCopyWith<$Res> {
  __$$CultureImplCopyWithImpl(
    _$CultureImpl _value,
    $Res Function(_$CultureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Culture
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? parcelleId = freezed,
    Object? produitId = null,
    Object? superficieHa = freezed,
    Object? dateSemis = freezed,
    Object? dateRecoltePrevue = freezed,
    Object? quantiteEstimeeKg = freezed,
    Object? statut = freezed,
    Object? createdAt = freezed,
    Object? produitNom = freezed,
  }) {
    return _then(
      _$CultureImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        parcelleId: freezed == parcelleId
            ? _value.parcelleId
            : parcelleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        produitId: null == produitId
            ? _value.produitId
            : produitId // ignore: cast_nullable_to_non_nullable
                  as String,
        superficieHa: freezed == superficieHa
            ? _value.superficieHa
            : superficieHa // ignore: cast_nullable_to_non_nullable
                  as double?,
        dateSemis: freezed == dateSemis
            ? _value.dateSemis
            : dateSemis // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dateRecoltePrevue: freezed == dateRecoltePrevue
            ? _value.dateRecoltePrevue
            : dateRecoltePrevue // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        quantiteEstimeeKg: freezed == quantiteEstimeeKg
            ? _value.quantiteEstimeeKg
            : quantiteEstimeeKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        statut: freezed == statut
            ? _value.statut
            : statut // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        produitNom: freezed == produitNom
            ? _value.produitNom
            : produitNom // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CultureImpl extends _Culture {
  const _$CultureImpl({
    required this.id,
    this.parcelleId,
    required this.produitId,
    @FlexDoubleN() this.superficieHa,
    this.dateSemis,
    this.dateRecoltePrevue,
    @FlexDoubleN() this.quantiteEstimeeKg,
    this.statut,
    this.createdAt,
    @JsonKey(name: 'produits_agricoles', fromJson: _produitNomFromMap)
    this.produitNom,
  }) : super._();

  factory _$CultureImpl.fromJson(Map<String, dynamic> json) =>
      _$$CultureImplFromJson(json);

  @override
  final String id;

  /// Nullable côté DB (peuvent exister des cultures historiques sans
  /// parcelle), même si toutes les nouvelles cultures en auront une.
  @override
  final String? parcelleId;
  @override
  final String produitId;
  @override
  @FlexDoubleN()
  final double? superficieHa;
  @override
  final DateTime? dateSemis;
  @override
  final DateTime? dateRecoltePrevue;
  @override
  @FlexDoubleN()
  final double? quantiteEstimeeKg;
  @override
  final String? statut;
  @override
  final DateTime? createdAt;

  /// Le back renvoie `produits_agricoles: { nom: "Maïs grain blanc" }`.
  /// On aplatit via le converter pour exposer `produitNom` directement.
  @override
  @JsonKey(name: 'produits_agricoles', fromJson: _produitNomFromMap)
  final String? produitNom;

  @override
  String toString() {
    return 'Culture(id: $id, parcelleId: $parcelleId, produitId: $produitId, superficieHa: $superficieHa, dateSemis: $dateSemis, dateRecoltePrevue: $dateRecoltePrevue, quantiteEstimeeKg: $quantiteEstimeeKg, statut: $statut, createdAt: $createdAt, produitNom: $produitNom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CultureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.parcelleId, parcelleId) ||
                other.parcelleId == parcelleId) &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            (identical(other.superficieHa, superficieHa) ||
                other.superficieHa == superficieHa) &&
            (identical(other.dateSemis, dateSemis) ||
                other.dateSemis == dateSemis) &&
            (identical(other.dateRecoltePrevue, dateRecoltePrevue) ||
                other.dateRecoltePrevue == dateRecoltePrevue) &&
            (identical(other.quantiteEstimeeKg, quantiteEstimeeKg) ||
                other.quantiteEstimeeKg == quantiteEstimeeKg) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.produitNom, produitNom) ||
                other.produitNom == produitNom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    parcelleId,
    produitId,
    superficieHa,
    dateSemis,
    dateRecoltePrevue,
    quantiteEstimeeKg,
    statut,
    createdAt,
    produitNom,
  );

  /// Create a copy of Culture
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CultureImplCopyWith<_$CultureImpl> get copyWith =>
      __$$CultureImplCopyWithImpl<_$CultureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CultureImplToJson(this);
  }
}

abstract class _Culture extends Culture {
  const factory _Culture({
    required final String id,
    final String? parcelleId,
    required final String produitId,
    @FlexDoubleN() final double? superficieHa,
    final DateTime? dateSemis,
    final DateTime? dateRecoltePrevue,
    @FlexDoubleN() final double? quantiteEstimeeKg,
    final String? statut,
    final DateTime? createdAt,
    @JsonKey(name: 'produits_agricoles', fromJson: _produitNomFromMap)
    final String? produitNom,
  }) = _$CultureImpl;
  const _Culture._() : super._();

  factory _Culture.fromJson(Map<String, dynamic> json) = _$CultureImpl.fromJson;

  @override
  String get id;

  /// Nullable côté DB (peuvent exister des cultures historiques sans
  /// parcelle), même si toutes les nouvelles cultures en auront une.
  @override
  String? get parcelleId;
  @override
  String get produitId;
  @override
  @FlexDoubleN()
  double? get superficieHa;
  @override
  DateTime? get dateSemis;
  @override
  DateTime? get dateRecoltePrevue;
  @override
  @FlexDoubleN()
  double? get quantiteEstimeeKg;
  @override
  String? get statut;
  @override
  DateTime? get createdAt;

  /// Le back renvoie `produits_agricoles: { nom: "Maïs grain blanc" }`.
  /// On aplatit via le converter pour exposer `produitNom` directement.
  @override
  @JsonKey(name: 'produits_agricoles', fromJson: _produitNomFromMap)
  String? get produitNom;

  /// Create a copy of Culture
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CultureImplCopyWith<_$CultureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
