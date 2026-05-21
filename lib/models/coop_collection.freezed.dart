// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coop_collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CoopCollection _$CoopCollectionFromJson(Map<String, dynamic> json) {
  return _CoopCollection.fromJson(json);
}

/// @nodoc
mixin _$CoopCollection {
  String get id => throw _privateConstructorUsedError;
  String get cooperativeId => throw _privateConstructorUsedError;
  String get farmerId => throw _privateConstructorUsedError;
  String? get annonceVenteId => throw _privateConstructorUsedError;
  String? get vehicleId => throw _privateConstructorUsedError;
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  String get pickupAddress => throw _privateConstructorUsedError;
  @FlexDouble()
  double get quantitePrevueKg => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Jointures Prisma (back retourne `users` pour le farmer).
  @JsonKey(name: 'users')
  Utilisateur? get farmer => throw _privateConstructorUsedError;

  /// Serializes this CoopCollection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoopCollection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoopCollectionCopyWith<CoopCollection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoopCollectionCopyWith<$Res> {
  factory $CoopCollectionCopyWith(
    CoopCollection value,
    $Res Function(CoopCollection) then,
  ) = _$CoopCollectionCopyWithImpl<$Res, CoopCollection>;
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String farmerId,
    String? annonceVenteId,
    String? vehicleId,
    DateTime? scheduledAt,
    String pickupAddress,
    @FlexDouble() double quantitePrevueKg,
    String status,
    String? notes,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(name: 'users') Utilisateur? farmer,
  });

  $UtilisateurCopyWith<$Res>? get farmer;
}

/// @nodoc
class _$CoopCollectionCopyWithImpl<$Res, $Val extends CoopCollection>
    implements $CoopCollectionCopyWith<$Res> {
  _$CoopCollectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoopCollection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? farmerId = null,
    Object? annonceVenteId = freezed,
    Object? vehicleId = freezed,
    Object? scheduledAt = freezed,
    Object? pickupAddress = null,
    Object? quantitePrevueKg = null,
    Object? status = null,
    Object? notes = freezed,
    Object? completedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? farmer = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            cooperativeId: null == cooperativeId
                ? _value.cooperativeId
                : cooperativeId // ignore: cast_nullable_to_non_nullable
                      as String,
            farmerId: null == farmerId
                ? _value.farmerId
                : farmerId // ignore: cast_nullable_to_non_nullable
                      as String,
            annonceVenteId: freezed == annonceVenteId
                ? _value.annonceVenteId
                : annonceVenteId // ignore: cast_nullable_to_non_nullable
                      as String?,
            vehicleId: freezed == vehicleId
                ? _value.vehicleId
                : vehicleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            scheduledAt: freezed == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            pickupAddress: null == pickupAddress
                ? _value.pickupAddress
                : pickupAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            quantitePrevueKg: null == quantitePrevueKg
                ? _value.quantitePrevueKg
                : quantitePrevueKg // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            farmer: freezed == farmer
                ? _value.farmer
                : farmer // ignore: cast_nullable_to_non_nullable
                      as Utilisateur?,
          )
          as $Val,
    );
  }

  /// Create a copy of CoopCollection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UtilisateurCopyWith<$Res>? get farmer {
    if (_value.farmer == null) {
      return null;
    }

    return $UtilisateurCopyWith<$Res>(_value.farmer!, (value) {
      return _then(_value.copyWith(farmer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CoopCollectionImplCopyWith<$Res>
    implements $CoopCollectionCopyWith<$Res> {
  factory _$$CoopCollectionImplCopyWith(
    _$CoopCollectionImpl value,
    $Res Function(_$CoopCollectionImpl) then,
  ) = __$$CoopCollectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String farmerId,
    String? annonceVenteId,
    String? vehicleId,
    DateTime? scheduledAt,
    String pickupAddress,
    @FlexDouble() double quantitePrevueKg,
    String status,
    String? notes,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(name: 'users') Utilisateur? farmer,
  });

  @override
  $UtilisateurCopyWith<$Res>? get farmer;
}

/// @nodoc
class __$$CoopCollectionImplCopyWithImpl<$Res>
    extends _$CoopCollectionCopyWithImpl<$Res, _$CoopCollectionImpl>
    implements _$$CoopCollectionImplCopyWith<$Res> {
  __$$CoopCollectionImplCopyWithImpl(
    _$CoopCollectionImpl _value,
    $Res Function(_$CoopCollectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CoopCollection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? farmerId = null,
    Object? annonceVenteId = freezed,
    Object? vehicleId = freezed,
    Object? scheduledAt = freezed,
    Object? pickupAddress = null,
    Object? quantitePrevueKg = null,
    Object? status = null,
    Object? notes = freezed,
    Object? completedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? farmer = freezed,
  }) {
    return _then(
      _$CoopCollectionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        cooperativeId: null == cooperativeId
            ? _value.cooperativeId
            : cooperativeId // ignore: cast_nullable_to_non_nullable
                  as String,
        farmerId: null == farmerId
            ? _value.farmerId
            : farmerId // ignore: cast_nullable_to_non_nullable
                  as String,
        annonceVenteId: freezed == annonceVenteId
            ? _value.annonceVenteId
            : annonceVenteId // ignore: cast_nullable_to_non_nullable
                  as String?,
        vehicleId: freezed == vehicleId
            ? _value.vehicleId
            : vehicleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        scheduledAt: freezed == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        pickupAddress: null == pickupAddress
            ? _value.pickupAddress
            : pickupAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        quantitePrevueKg: null == quantitePrevueKg
            ? _value.quantitePrevueKg
            : quantitePrevueKg // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        farmer: freezed == farmer
            ? _value.farmer
            : farmer // ignore: cast_nullable_to_non_nullable
                  as Utilisateur?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CoopCollectionImpl extends _CoopCollection {
  const _$CoopCollectionImpl({
    required this.id,
    required this.cooperativeId,
    required this.farmerId,
    this.annonceVenteId,
    this.vehicleId,
    this.scheduledAt,
    this.pickupAddress = '',
    @FlexDouble() this.quantitePrevueKg = 0,
    this.status = 'PLANNED',
    this.notes,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    @JsonKey(name: 'users') this.farmer,
  }) : super._();

  factory _$CoopCollectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoopCollectionImplFromJson(json);

  @override
  final String id;
  @override
  final String cooperativeId;
  @override
  final String farmerId;
  @override
  final String? annonceVenteId;
  @override
  final String? vehicleId;
  @override
  final DateTime? scheduledAt;
  @override
  @JsonKey()
  final String pickupAddress;
  @override
  @JsonKey()
  @FlexDouble()
  final double quantitePrevueKg;
  @override
  @JsonKey()
  final String status;
  @override
  final String? notes;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Jointures Prisma (back retourne `users` pour le farmer).
  @override
  @JsonKey(name: 'users')
  final Utilisateur? farmer;

  @override
  String toString() {
    return 'CoopCollection(id: $id, cooperativeId: $cooperativeId, farmerId: $farmerId, annonceVenteId: $annonceVenteId, vehicleId: $vehicleId, scheduledAt: $scheduledAt, pickupAddress: $pickupAddress, quantitePrevueKg: $quantitePrevueKg, status: $status, notes: $notes, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt, farmer: $farmer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoopCollectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cooperativeId, cooperativeId) ||
                other.cooperativeId == cooperativeId) &&
            (identical(other.farmerId, farmerId) ||
                other.farmerId == farmerId) &&
            (identical(other.annonceVenteId, annonceVenteId) ||
                other.annonceVenteId == annonceVenteId) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.pickupAddress, pickupAddress) ||
                other.pickupAddress == pickupAddress) &&
            (identical(other.quantitePrevueKg, quantitePrevueKg) ||
                other.quantitePrevueKg == quantitePrevueKg) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.farmer, farmer) || other.farmer == farmer));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    cooperativeId,
    farmerId,
    annonceVenteId,
    vehicleId,
    scheduledAt,
    pickupAddress,
    quantitePrevueKg,
    status,
    notes,
    completedAt,
    createdAt,
    updatedAt,
    farmer,
  );

  /// Create a copy of CoopCollection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoopCollectionImplCopyWith<_$CoopCollectionImpl> get copyWith =>
      __$$CoopCollectionImplCopyWithImpl<_$CoopCollectionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CoopCollectionImplToJson(this);
  }
}

abstract class _CoopCollection extends CoopCollection {
  const factory _CoopCollection({
    required final String id,
    required final String cooperativeId,
    required final String farmerId,
    final String? annonceVenteId,
    final String? vehicleId,
    final DateTime? scheduledAt,
    final String pickupAddress,
    @FlexDouble() final double quantitePrevueKg,
    final String status,
    final String? notes,
    final DateTime? completedAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    @JsonKey(name: 'users') final Utilisateur? farmer,
  }) = _$CoopCollectionImpl;
  const _CoopCollection._() : super._();

  factory _CoopCollection.fromJson(Map<String, dynamic> json) =
      _$CoopCollectionImpl.fromJson;

  @override
  String get id;
  @override
  String get cooperativeId;
  @override
  String get farmerId;
  @override
  String? get annonceVenteId;
  @override
  String? get vehicleId;
  @override
  DateTime? get scheduledAt;
  @override
  String get pickupAddress;
  @override
  @FlexDouble()
  double get quantitePrevueKg;
  @override
  String get status;
  @override
  String? get notes;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Jointures Prisma (back retourne `users` pour le farmer).
  @override
  @JsonKey(name: 'users')
  Utilisateur? get farmer;

  /// Create a copy of CoopCollection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoopCollectionImplCopyWith<_$CoopCollectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
