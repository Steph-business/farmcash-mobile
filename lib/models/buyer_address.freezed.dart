// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buyer_address.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BuyerAddress _$BuyerAddressFromJson(Map<String, dynamic> json) {
  return _BuyerAddress.fromJson(json);
}

/// @nodoc
mixin _$BuyerAddress {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get libelle => throw _privateConstructorUsedError;
  String get contactNom => throw _privateConstructorUsedError;
  String get contactPhone => throw _privateConstructorUsedError;
  String get adresseComplete => throw _privateConstructorUsedError;
  String? get villeId => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get lat => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get lng => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
  String? get villeNom => throw _privateConstructorUsedError;

  /// Serializes this BuyerAddress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BuyerAddress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BuyerAddressCopyWith<BuyerAddress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuyerAddressCopyWith<$Res> {
  factory $BuyerAddressCopyWith(
    BuyerAddress value,
    $Res Function(BuyerAddress) then,
  ) = _$BuyerAddressCopyWithImpl<$Res, BuyerAddress>;
  @useResult
  $Res call({
    String id,
    String userId,
    String libelle,
    String contactNom,
    String contactPhone,
    String adresseComplete,
    String? villeId,
    @FlexDoubleN() double? lat,
    @FlexDoubleN() double? lng,
    bool isDefault,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    String? villeNom,
  });
}

/// @nodoc
class _$BuyerAddressCopyWithImpl<$Res, $Val extends BuyerAddress>
    implements $BuyerAddressCopyWith<$Res> {
  _$BuyerAddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BuyerAddress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? libelle = null,
    Object? contactNom = null,
    Object? contactPhone = null,
    Object? adresseComplete = null,
    Object? villeId = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? isDefault = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? villeNom = freezed,
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
            libelle: null == libelle
                ? _value.libelle
                : libelle // ignore: cast_nullable_to_non_nullable
                      as String,
            contactNom: null == contactNom
                ? _value.contactNom
                : contactNom // ignore: cast_nullable_to_non_nullable
                      as String,
            contactPhone: null == contactPhone
                ? _value.contactPhone
                : contactPhone // ignore: cast_nullable_to_non_nullable
                      as String,
            adresseComplete: null == adresseComplete
                ? _value.adresseComplete
                : adresseComplete // ignore: cast_nullable_to_non_nullable
                      as String,
            villeId: freezed == villeId
                ? _value.villeId
                : villeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            lat: freezed == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double?,
            lng: freezed == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double?,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            villeNom: freezed == villeNom
                ? _value.villeNom
                : villeNom // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BuyerAddressImplCopyWith<$Res>
    implements $BuyerAddressCopyWith<$Res> {
  factory _$$BuyerAddressImplCopyWith(
    _$BuyerAddressImpl value,
    $Res Function(_$BuyerAddressImpl) then,
  ) = __$$BuyerAddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String libelle,
    String contactNom,
    String contactPhone,
    String adresseComplete,
    String? villeId,
    @FlexDoubleN() double? lat,
    @FlexDoubleN() double? lng,
    bool isDefault,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    String? villeNom,
  });
}

/// @nodoc
class __$$BuyerAddressImplCopyWithImpl<$Res>
    extends _$BuyerAddressCopyWithImpl<$Res, _$BuyerAddressImpl>
    implements _$$BuyerAddressImplCopyWith<$Res> {
  __$$BuyerAddressImplCopyWithImpl(
    _$BuyerAddressImpl _value,
    $Res Function(_$BuyerAddressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BuyerAddress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? libelle = null,
    Object? contactNom = null,
    Object? contactPhone = null,
    Object? adresseComplete = null,
    Object? villeId = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? isDefault = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? villeNom = freezed,
  }) {
    return _then(
      _$BuyerAddressImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        libelle: null == libelle
            ? _value.libelle
            : libelle // ignore: cast_nullable_to_non_nullable
                  as String,
        contactNom: null == contactNom
            ? _value.contactNom
            : contactNom // ignore: cast_nullable_to_non_nullable
                  as String,
        contactPhone: null == contactPhone
            ? _value.contactPhone
            : contactPhone // ignore: cast_nullable_to_non_nullable
                  as String,
        adresseComplete: null == adresseComplete
            ? _value.adresseComplete
            : adresseComplete // ignore: cast_nullable_to_non_nullable
                  as String,
        villeId: freezed == villeId
            ? _value.villeId
            : villeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        lat: freezed == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double?,
        lng: freezed == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double?,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        villeNom: freezed == villeNom
            ? _value.villeNom
            : villeNom // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BuyerAddressImpl extends _BuyerAddress {
  const _$BuyerAddressImpl({
    required this.id,
    required this.userId,
    required this.libelle,
    this.contactNom = '',
    this.contactPhone = '',
    this.adresseComplete = '',
    this.villeId,
    @FlexDoubleN() this.lat,
    @FlexDoubleN() this.lng,
    this.isDefault = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    this.villeNom,
  }) : super._();

  factory _$BuyerAddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuyerAddressImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String libelle;
  @override
  @JsonKey()
  final String contactNom;
  @override
  @JsonKey()
  final String contactPhone;
  @override
  @JsonKey()
  final String adresseComplete;
  @override
  final String? villeId;
  @override
  @FlexDoubleN()
  final double? lat;
  @override
  @FlexDoubleN()
  final double? lng;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
  final String? villeNom;

  @override
  String toString() {
    return 'BuyerAddress(id: $id, userId: $userId, libelle: $libelle, contactNom: $contactNom, contactPhone: $contactPhone, adresseComplete: $adresseComplete, villeId: $villeId, lat: $lat, lng: $lng, isDefault: $isDefault, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, villeNom: $villeNom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuyerAddressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.libelle, libelle) || other.libelle == libelle) &&
            (identical(other.contactNom, contactNom) ||
                other.contactNom == contactNom) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.adresseComplete, adresseComplete) ||
                other.adresseComplete == adresseComplete) &&
            (identical(other.villeId, villeId) || other.villeId == villeId) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.villeNom, villeNom) ||
                other.villeNom == villeNom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    libelle,
    contactNom,
    contactPhone,
    adresseComplete,
    villeId,
    lat,
    lng,
    isDefault,
    isActive,
    createdAt,
    updatedAt,
    villeNom,
  );

  /// Create a copy of BuyerAddress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BuyerAddressImplCopyWith<_$BuyerAddressImpl> get copyWith =>
      __$$BuyerAddressImplCopyWithImpl<_$BuyerAddressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuyerAddressImplToJson(this);
  }
}

abstract class _BuyerAddress extends BuyerAddress {
  const factory _BuyerAddress({
    required final String id,
    required final String userId,
    required final String libelle,
    final String contactNom,
    final String contactPhone,
    final String adresseComplete,
    final String? villeId,
    @FlexDoubleN() final double? lat,
    @FlexDoubleN() final double? lng,
    final bool isDefault,
    final bool isActive,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    final String? villeNom,
  }) = _$BuyerAddressImpl;
  const _BuyerAddress._() : super._();

  factory _BuyerAddress.fromJson(Map<String, dynamic> json) =
      _$BuyerAddressImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get libelle;
  @override
  String get contactNom;
  @override
  String get contactPhone;
  @override
  String get adresseComplete;
  @override
  String? get villeId;
  @override
  @FlexDoubleN()
  double? get lat;
  @override
  @FlexDoubleN()
  double? get lng;
  @override
  bool get isDefault;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
  String? get villeNom;

  /// Create a copy of BuyerAddress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BuyerAddressImplCopyWith<_$BuyerAddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
