// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Lot _$LotFromJson(Map<String, dynamic> json) {
  return _Lot.fromJson(json);
}

/// @nodoc
mixin _$Lot {
  String get id => throw _privateConstructorUsedError;
  String get lotCode => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get produitId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get quantiteKg => throw _privateConstructorUsedError;
  String? get farmerId => throw _privateConstructorUsedError;
  String? get cooperativeId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ProductQuality.unknown)
  ProductQuality get qualite => throw _privateConstructorUsedError;
  DateTime? get dateRecolte => throw _privateConstructorUsedError;
  String? get blockchainTx => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Lot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Lot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LotCopyWith<Lot> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LotCopyWith<$Res> {
  factory $LotCopyWith(Lot value, $Res Function(Lot) then) =
      _$LotCopyWithImpl<$Res, Lot>;
  @useResult
  $Res call({
    String id,
    String lotCode,
    String type,
    String produitId,
    @FlexDouble() double quantiteKg,
    String? farmerId,
    String? cooperativeId,
    @JsonKey(unknownEnumValue: ProductQuality.unknown) ProductQuality qualite,
    DateTime? dateRecolte,
    String? blockchainTx,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$LotCopyWithImpl<$Res, $Val extends Lot> implements $LotCopyWith<$Res> {
  _$LotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lotCode = null,
    Object? type = null,
    Object? produitId = null,
    Object? quantiteKg = null,
    Object? farmerId = freezed,
    Object? cooperativeId = freezed,
    Object? qualite = null,
    Object? dateRecolte = freezed,
    Object? blockchainTx = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            lotCode: null == lotCode
                ? _value.lotCode
                : lotCode // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            produitId: null == produitId
                ? _value.produitId
                : produitId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantiteKg: null == quantiteKg
                ? _value.quantiteKg
                : quantiteKg // ignore: cast_nullable_to_non_nullable
                      as double,
            farmerId: freezed == farmerId
                ? _value.farmerId
                : farmerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            cooperativeId: freezed == cooperativeId
                ? _value.cooperativeId
                : cooperativeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            qualite: null == qualite
                ? _value.qualite
                : qualite // ignore: cast_nullable_to_non_nullable
                      as ProductQuality,
            dateRecolte: freezed == dateRecolte
                ? _value.dateRecolte
                : dateRecolte // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            blockchainTx: freezed == blockchainTx
                ? _value.blockchainTx
                : blockchainTx // ignore: cast_nullable_to_non_nullable
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
abstract class _$$LotImplCopyWith<$Res> implements $LotCopyWith<$Res> {
  factory _$$LotImplCopyWith(_$LotImpl value, $Res Function(_$LotImpl) then) =
      __$$LotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String lotCode,
    String type,
    String produitId,
    @FlexDouble() double quantiteKg,
    String? farmerId,
    String? cooperativeId,
    @JsonKey(unknownEnumValue: ProductQuality.unknown) ProductQuality qualite,
    DateTime? dateRecolte,
    String? blockchainTx,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$LotImplCopyWithImpl<$Res> extends _$LotCopyWithImpl<$Res, _$LotImpl>
    implements _$$LotImplCopyWith<$Res> {
  __$$LotImplCopyWithImpl(_$LotImpl _value, $Res Function(_$LotImpl) _then)
    : super(_value, _then);

  /// Create a copy of Lot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lotCode = null,
    Object? type = null,
    Object? produitId = null,
    Object? quantiteKg = null,
    Object? farmerId = freezed,
    Object? cooperativeId = freezed,
    Object? qualite = null,
    Object? dateRecolte = freezed,
    Object? blockchainTx = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$LotImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        lotCode: null == lotCode
            ? _value.lotCode
            : lotCode // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        produitId: null == produitId
            ? _value.produitId
            : produitId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantiteKg: null == quantiteKg
            ? _value.quantiteKg
            : quantiteKg // ignore: cast_nullable_to_non_nullable
                  as double,
        farmerId: freezed == farmerId
            ? _value.farmerId
            : farmerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        cooperativeId: freezed == cooperativeId
            ? _value.cooperativeId
            : cooperativeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        qualite: null == qualite
            ? _value.qualite
            : qualite // ignore: cast_nullable_to_non_nullable
                  as ProductQuality,
        dateRecolte: freezed == dateRecolte
            ? _value.dateRecolte
            : dateRecolte // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        blockchainTx: freezed == blockchainTx
            ? _value.blockchainTx
            : blockchainTx // ignore: cast_nullable_to_non_nullable
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
class _$LotImpl implements _Lot {
  const _$LotImpl({
    required this.id,
    required this.lotCode,
    this.type = 'INDIVIDUAL',
    required this.produitId,
    @FlexDouble() required this.quantiteKg,
    this.farmerId,
    this.cooperativeId,
    @JsonKey(unknownEnumValue: ProductQuality.unknown)
    this.qualite = ProductQuality.unknown,
    this.dateRecolte,
    this.blockchainTx,
    this.createdAt,
  });

  factory _$LotImpl.fromJson(Map<String, dynamic> json) =>
      _$$LotImplFromJson(json);

  @override
  final String id;
  @override
  final String lotCode;
  @override
  @JsonKey()
  final String type;
  @override
  final String produitId;
  @override
  @FlexDouble()
  final double quantiteKg;
  @override
  final String? farmerId;
  @override
  final String? cooperativeId;
  @override
  @JsonKey(unknownEnumValue: ProductQuality.unknown)
  final ProductQuality qualite;
  @override
  final DateTime? dateRecolte;
  @override
  final String? blockchainTx;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Lot(id: $id, lotCode: $lotCode, type: $type, produitId: $produitId, quantiteKg: $quantiteKg, farmerId: $farmerId, cooperativeId: $cooperativeId, qualite: $qualite, dateRecolte: $dateRecolte, blockchainTx: $blockchainTx, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lotCode, lotCode) || other.lotCode == lotCode) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            (identical(other.quantiteKg, quantiteKg) ||
                other.quantiteKg == quantiteKg) &&
            (identical(other.farmerId, farmerId) ||
                other.farmerId == farmerId) &&
            (identical(other.cooperativeId, cooperativeId) ||
                other.cooperativeId == cooperativeId) &&
            (identical(other.qualite, qualite) || other.qualite == qualite) &&
            (identical(other.dateRecolte, dateRecolte) ||
                other.dateRecolte == dateRecolte) &&
            (identical(other.blockchainTx, blockchainTx) ||
                other.blockchainTx == blockchainTx) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    lotCode,
    type,
    produitId,
    quantiteKg,
    farmerId,
    cooperativeId,
    qualite,
    dateRecolte,
    blockchainTx,
    createdAt,
  );

  /// Create a copy of Lot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LotImplCopyWith<_$LotImpl> get copyWith =>
      __$$LotImplCopyWithImpl<_$LotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LotImplToJson(this);
  }
}

abstract class _Lot implements Lot {
  const factory _Lot({
    required final String id,
    required final String lotCode,
    final String type,
    required final String produitId,
    @FlexDouble() required final double quantiteKg,
    final String? farmerId,
    final String? cooperativeId,
    @JsonKey(unknownEnumValue: ProductQuality.unknown)
    final ProductQuality qualite,
    final DateTime? dateRecolte,
    final String? blockchainTx,
    final DateTime? createdAt,
  }) = _$LotImpl;

  factory _Lot.fromJson(Map<String, dynamic> json) = _$LotImpl.fromJson;

  @override
  String get id;
  @override
  String get lotCode;
  @override
  String get type;
  @override
  String get produitId;
  @override
  @FlexDouble()
  double get quantiteKg;
  @override
  String? get farmerId;
  @override
  String? get cooperativeId;
  @override
  @JsonKey(unknownEnumValue: ProductQuality.unknown)
  ProductQuality get qualite;
  @override
  DateTime? get dateRecolte;
  @override
  String? get blockchainTx;
  @override
  DateTime? get createdAt;

  /// Create a copy of Lot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LotImplCopyWith<_$LotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Entrepot _$EntrepotFromJson(Map<String, dynamic> json) {
  return _Entrepot.fromJson(json);
}

/// @nodoc
mixin _$Entrepot {
  String get id => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  @FlexDouble()
  double get capaciteKg => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get lat => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get lng => throw _privateConstructorUsedError;
  bool get isRefrigere => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get temperatureMin => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get temperatureMax => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Entrepot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Entrepot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntrepotCopyWith<Entrepot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntrepotCopyWith<$Res> {
  factory $EntrepotCopyWith(Entrepot value, $Res Function(Entrepot) then) =
      _$EntrepotCopyWithImpl<$Res, Entrepot>;
  @useResult
  $Res call({
    String id,
    String ownerId,
    String nom,
    @FlexDouble() double capaciteKg,
    String? location,
    @FlexDoubleN() double? lat,
    @FlexDoubleN() double? lng,
    bool isRefrigere,
    @FlexDoubleN() double? temperatureMin,
    @FlexDoubleN() double? temperatureMax,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$EntrepotCopyWithImpl<$Res, $Val extends Entrepot>
    implements $EntrepotCopyWith<$Res> {
  _$EntrepotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Entrepot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? nom = null,
    Object? capaciteKg = null,
    Object? location = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? isRefrigere = null,
    Object? temperatureMin = freezed,
    Object? temperatureMax = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerId: null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String,
            nom: null == nom
                ? _value.nom
                : nom // ignore: cast_nullable_to_non_nullable
                      as String,
            capaciteKg: null == capaciteKg
                ? _value.capaciteKg
                : capaciteKg // ignore: cast_nullable_to_non_nullable
                      as double,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            lat: freezed == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double?,
            lng: freezed == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double?,
            isRefrigere: null == isRefrigere
                ? _value.isRefrigere
                : isRefrigere // ignore: cast_nullable_to_non_nullable
                      as bool,
            temperatureMin: freezed == temperatureMin
                ? _value.temperatureMin
                : temperatureMin // ignore: cast_nullable_to_non_nullable
                      as double?,
            temperatureMax: freezed == temperatureMax
                ? _value.temperatureMax
                : temperatureMax // ignore: cast_nullable_to_non_nullable
                      as double?,
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
abstract class _$$EntrepotImplCopyWith<$Res>
    implements $EntrepotCopyWith<$Res> {
  factory _$$EntrepotImplCopyWith(
    _$EntrepotImpl value,
    $Res Function(_$EntrepotImpl) then,
  ) = __$$EntrepotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String ownerId,
    String nom,
    @FlexDouble() double capaciteKg,
    String? location,
    @FlexDoubleN() double? lat,
    @FlexDoubleN() double? lng,
    bool isRefrigere,
    @FlexDoubleN() double? temperatureMin,
    @FlexDoubleN() double? temperatureMax,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$EntrepotImplCopyWithImpl<$Res>
    extends _$EntrepotCopyWithImpl<$Res, _$EntrepotImpl>
    implements _$$EntrepotImplCopyWith<$Res> {
  __$$EntrepotImplCopyWithImpl(
    _$EntrepotImpl _value,
    $Res Function(_$EntrepotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Entrepot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? nom = null,
    Object? capaciteKg = null,
    Object? location = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? isRefrigere = null,
    Object? temperatureMin = freezed,
    Object? temperatureMax = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$EntrepotImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        capaciteKg: null == capaciteKg
            ? _value.capaciteKg
            : capaciteKg // ignore: cast_nullable_to_non_nullable
                  as double,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        lat: freezed == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double?,
        lng: freezed == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double?,
        isRefrigere: null == isRefrigere
            ? _value.isRefrigere
            : isRefrigere // ignore: cast_nullable_to_non_nullable
                  as bool,
        temperatureMin: freezed == temperatureMin
            ? _value.temperatureMin
            : temperatureMin // ignore: cast_nullable_to_non_nullable
                  as double?,
        temperatureMax: freezed == temperatureMax
            ? _value.temperatureMax
            : temperatureMax // ignore: cast_nullable_to_non_nullable
                  as double?,
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
class _$EntrepotImpl implements _Entrepot {
  const _$EntrepotImpl({
    required this.id,
    required this.ownerId,
    required this.nom,
    @FlexDouble() required this.capaciteKg,
    this.location,
    @FlexDoubleN() this.lat,
    @FlexDoubleN() this.lng,
    this.isRefrigere = false,
    @FlexDoubleN() this.temperatureMin,
    @FlexDoubleN() this.temperatureMax,
    this.createdAt,
  });

  factory _$EntrepotImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntrepotImplFromJson(json);

  @override
  final String id;
  @override
  final String ownerId;
  @override
  final String nom;
  @override
  @FlexDouble()
  final double capaciteKg;
  @override
  final String? location;
  @override
  @FlexDoubleN()
  final double? lat;
  @override
  @FlexDoubleN()
  final double? lng;
  @override
  @JsonKey()
  final bool isRefrigere;
  @override
  @FlexDoubleN()
  final double? temperatureMin;
  @override
  @FlexDoubleN()
  final double? temperatureMax;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Entrepot(id: $id, ownerId: $ownerId, nom: $nom, capaciteKg: $capaciteKg, location: $location, lat: $lat, lng: $lng, isRefrigere: $isRefrigere, temperatureMin: $temperatureMin, temperatureMax: $temperatureMax, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntrepotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.capaciteKg, capaciteKg) ||
                other.capaciteKg == capaciteKg) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.isRefrigere, isRefrigere) ||
                other.isRefrigere == isRefrigere) &&
            (identical(other.temperatureMin, temperatureMin) ||
                other.temperatureMin == temperatureMin) &&
            (identical(other.temperatureMax, temperatureMax) ||
                other.temperatureMax == temperatureMax) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ownerId,
    nom,
    capaciteKg,
    location,
    lat,
    lng,
    isRefrigere,
    temperatureMin,
    temperatureMax,
    createdAt,
  );

  /// Create a copy of Entrepot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntrepotImplCopyWith<_$EntrepotImpl> get copyWith =>
      __$$EntrepotImplCopyWithImpl<_$EntrepotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntrepotImplToJson(this);
  }
}

abstract class _Entrepot implements Entrepot {
  const factory _Entrepot({
    required final String id,
    required final String ownerId,
    required final String nom,
    @FlexDouble() required final double capaciteKg,
    final String? location,
    @FlexDoubleN() final double? lat,
    @FlexDoubleN() final double? lng,
    final bool isRefrigere,
    @FlexDoubleN() final double? temperatureMin,
    @FlexDoubleN() final double? temperatureMax,
    final DateTime? createdAt,
  }) = _$EntrepotImpl;

  factory _Entrepot.fromJson(Map<String, dynamic> json) =
      _$EntrepotImpl.fromJson;

  @override
  String get id;
  @override
  String get ownerId;
  @override
  String get nom;
  @override
  @FlexDouble()
  double get capaciteKg;
  @override
  String? get location;
  @override
  @FlexDoubleN()
  double? get lat;
  @override
  @FlexDoubleN()
  double? get lng;
  @override
  bool get isRefrigere;
  @override
  @FlexDoubleN()
  double? get temperatureMin;
  @override
  @FlexDoubleN()
  double? get temperatureMax;
  @override
  DateTime? get createdAt;

  /// Create a copy of Entrepot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntrepotImplCopyWith<_$EntrepotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TraceabilityEvent _$TraceabilityEventFromJson(Map<String, dynamic> json) {
  return _TraceabilityEvent.fromJson(json);
}

/// @nodoc
mixin _$TraceabilityEvent {
  String get id => throw _privateConstructorUsedError;
  String get lotId => throw _privateConstructorUsedError;
  String get eventType => throw _privateConstructorUsedError;
  String? get actorId => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String? get blockchainTx => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TraceabilityEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TraceabilityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TraceabilityEventCopyWith<TraceabilityEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TraceabilityEventCopyWith<$Res> {
  factory $TraceabilityEventCopyWith(
    TraceabilityEvent value,
    $Res Function(TraceabilityEvent) then,
  ) = _$TraceabilityEventCopyWithImpl<$Res, TraceabilityEvent>;
  @useResult
  $Res call({
    String id,
    String lotId,
    String eventType,
    String? actorId,
    String? location,
    Map<String, dynamic>? metadata,
    String? blockchainTx,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$TraceabilityEventCopyWithImpl<$Res, $Val extends TraceabilityEvent>
    implements $TraceabilityEventCopyWith<$Res> {
  _$TraceabilityEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TraceabilityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lotId = null,
    Object? eventType = null,
    Object? actorId = freezed,
    Object? location = freezed,
    Object? metadata = freezed,
    Object? blockchainTx = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            lotId: null == lotId
                ? _value.lotId
                : lotId // ignore: cast_nullable_to_non_nullable
                      as String,
            eventType: null == eventType
                ? _value.eventType
                : eventType // ignore: cast_nullable_to_non_nullable
                      as String,
            actorId: freezed == actorId
                ? _value.actorId
                : actorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            blockchainTx: freezed == blockchainTx
                ? _value.blockchainTx
                : blockchainTx // ignore: cast_nullable_to_non_nullable
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
abstract class _$$TraceabilityEventImplCopyWith<$Res>
    implements $TraceabilityEventCopyWith<$Res> {
  factory _$$TraceabilityEventImplCopyWith(
    _$TraceabilityEventImpl value,
    $Res Function(_$TraceabilityEventImpl) then,
  ) = __$$TraceabilityEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String lotId,
    String eventType,
    String? actorId,
    String? location,
    Map<String, dynamic>? metadata,
    String? blockchainTx,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$TraceabilityEventImplCopyWithImpl<$Res>
    extends _$TraceabilityEventCopyWithImpl<$Res, _$TraceabilityEventImpl>
    implements _$$TraceabilityEventImplCopyWith<$Res> {
  __$$TraceabilityEventImplCopyWithImpl(
    _$TraceabilityEventImpl _value,
    $Res Function(_$TraceabilityEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TraceabilityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lotId = null,
    Object? eventType = null,
    Object? actorId = freezed,
    Object? location = freezed,
    Object? metadata = freezed,
    Object? blockchainTx = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TraceabilityEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        lotId: null == lotId
            ? _value.lotId
            : lotId // ignore: cast_nullable_to_non_nullable
                  as String,
        eventType: null == eventType
            ? _value.eventType
            : eventType // ignore: cast_nullable_to_non_nullable
                  as String,
        actorId: freezed == actorId
            ? _value.actorId
            : actorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        blockchainTx: freezed == blockchainTx
            ? _value.blockchainTx
            : blockchainTx // ignore: cast_nullable_to_non_nullable
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
class _$TraceabilityEventImpl implements _TraceabilityEvent {
  const _$TraceabilityEventImpl({
    required this.id,
    required this.lotId,
    required this.eventType,
    this.actorId,
    this.location,
    final Map<String, dynamic>? metadata,
    this.blockchainTx,
    this.createdAt,
  }) : _metadata = metadata;

  factory _$TraceabilityEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$TraceabilityEventImplFromJson(json);

  @override
  final String id;
  @override
  final String lotId;
  @override
  final String eventType;
  @override
  final String? actorId;
  @override
  final String? location;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? blockchainTx;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TraceabilityEvent(id: $id, lotId: $lotId, eventType: $eventType, actorId: $actorId, location: $location, metadata: $metadata, blockchainTx: $blockchainTx, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TraceabilityEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lotId, lotId) || other.lotId == lotId) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.actorId, actorId) || other.actorId == actorId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.blockchainTx, blockchainTx) ||
                other.blockchainTx == blockchainTx) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    lotId,
    eventType,
    actorId,
    location,
    const DeepCollectionEquality().hash(_metadata),
    blockchainTx,
    createdAt,
  );

  /// Create a copy of TraceabilityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TraceabilityEventImplCopyWith<_$TraceabilityEventImpl> get copyWith =>
      __$$TraceabilityEventImplCopyWithImpl<_$TraceabilityEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TraceabilityEventImplToJson(this);
  }
}

abstract class _TraceabilityEvent implements TraceabilityEvent {
  const factory _TraceabilityEvent({
    required final String id,
    required final String lotId,
    required final String eventType,
    final String? actorId,
    final String? location,
    final Map<String, dynamic>? metadata,
    final String? blockchainTx,
    final DateTime? createdAt,
  }) = _$TraceabilityEventImpl;

  factory _TraceabilityEvent.fromJson(Map<String, dynamic> json) =
      _$TraceabilityEventImpl.fromJson;

  @override
  String get id;
  @override
  String get lotId;
  @override
  String get eventType;
  @override
  String? get actorId;
  @override
  String? get location;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get blockchainTx;
  @override
  DateTime? get createdAt;

  /// Create a copy of TraceabilityEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TraceabilityEventImplCopyWith<_$TraceabilityEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
