// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coop_vehicle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CoopVehicle _$CoopVehicleFromJson(Map<String, dynamic> json) {
  return _CoopVehicle.fromJson(json);
}

/// @nodoc
mixin _$CoopVehicle {
  String get id => throw _privateConstructorUsedError;
  String get cooperativeId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get immatriculation => throw _privateConstructorUsedError;
  String? get marque => throw _privateConstructorUsedError;
  @FlexDouble()
  double get chargeMaxKg => throw _privateConstructorUsedError;
  String? get chauffeurNom => throw _privateConstructorUsedError;
  String? get chauffeurPhone => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CoopVehicle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoopVehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoopVehicleCopyWith<CoopVehicle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoopVehicleCopyWith<$Res> {
  factory $CoopVehicleCopyWith(
    CoopVehicle value,
    $Res Function(CoopVehicle) then,
  ) = _$CoopVehicleCopyWithImpl<$Res, CoopVehicle>;
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String type,
    String? immatriculation,
    String? marque,
    @FlexDouble() double chargeMaxKg,
    String? chauffeurNom,
    String? chauffeurPhone,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$CoopVehicleCopyWithImpl<$Res, $Val extends CoopVehicle>
    implements $CoopVehicleCopyWith<$Res> {
  _$CoopVehicleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoopVehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? type = null,
    Object? immatriculation = freezed,
    Object? marque = freezed,
    Object? chargeMaxKg = null,
    Object? chauffeurNom = freezed,
    Object? chauffeurPhone = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            immatriculation: freezed == immatriculation
                ? _value.immatriculation
                : immatriculation // ignore: cast_nullable_to_non_nullable
                      as String?,
            marque: freezed == marque
                ? _value.marque
                : marque // ignore: cast_nullable_to_non_nullable
                      as String?,
            chargeMaxKg: null == chargeMaxKg
                ? _value.chargeMaxKg
                : chargeMaxKg // ignore: cast_nullable_to_non_nullable
                      as double,
            chauffeurNom: freezed == chauffeurNom
                ? _value.chauffeurNom
                : chauffeurNom // ignore: cast_nullable_to_non_nullable
                      as String?,
            chauffeurPhone: freezed == chauffeurPhone
                ? _value.chauffeurPhone
                : chauffeurPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CoopVehicleImplCopyWith<$Res>
    implements $CoopVehicleCopyWith<$Res> {
  factory _$$CoopVehicleImplCopyWith(
    _$CoopVehicleImpl value,
    $Res Function(_$CoopVehicleImpl) then,
  ) = __$$CoopVehicleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String type,
    String? immatriculation,
    String? marque,
    @FlexDouble() double chargeMaxKg,
    String? chauffeurNom,
    String? chauffeurPhone,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$CoopVehicleImplCopyWithImpl<$Res>
    extends _$CoopVehicleCopyWithImpl<$Res, _$CoopVehicleImpl>
    implements _$$CoopVehicleImplCopyWith<$Res> {
  __$$CoopVehicleImplCopyWithImpl(
    _$CoopVehicleImpl _value,
    $Res Function(_$CoopVehicleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CoopVehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? type = null,
    Object? immatriculation = freezed,
    Object? marque = freezed,
    Object? chargeMaxKg = null,
    Object? chauffeurNom = freezed,
    Object? chauffeurPhone = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$CoopVehicleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        cooperativeId: null == cooperativeId
            ? _value.cooperativeId
            : cooperativeId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        immatriculation: freezed == immatriculation
            ? _value.immatriculation
            : immatriculation // ignore: cast_nullable_to_non_nullable
                  as String?,
        marque: freezed == marque
            ? _value.marque
            : marque // ignore: cast_nullable_to_non_nullable
                  as String?,
        chargeMaxKg: null == chargeMaxKg
            ? _value.chargeMaxKg
            : chargeMaxKg // ignore: cast_nullable_to_non_nullable
                  as double,
        chauffeurNom: freezed == chauffeurNom
            ? _value.chauffeurNom
            : chauffeurNom // ignore: cast_nullable_to_non_nullable
                  as String?,
        chauffeurPhone: freezed == chauffeurPhone
            ? _value.chauffeurPhone
            : chauffeurPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CoopVehicleImpl implements _CoopVehicle {
  const _$CoopVehicleImpl({
    required this.id,
    required this.cooperativeId,
    this.type = '',
    this.immatriculation,
    this.marque,
    @FlexDouble() this.chargeMaxKg = 0,
    this.chauffeurNom,
    this.chauffeurPhone,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory _$CoopVehicleImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoopVehicleImplFromJson(json);

  @override
  final String id;
  @override
  final String cooperativeId;
  @override
  @JsonKey()
  final String type;
  @override
  final String? immatriculation;
  @override
  final String? marque;
  @override
  @JsonKey()
  @FlexDouble()
  final double chargeMaxKg;
  @override
  final String? chauffeurNom;
  @override
  final String? chauffeurPhone;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'CoopVehicle(id: $id, cooperativeId: $cooperativeId, type: $type, immatriculation: $immatriculation, marque: $marque, chargeMaxKg: $chargeMaxKg, chauffeurNom: $chauffeurNom, chauffeurPhone: $chauffeurPhone, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoopVehicleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cooperativeId, cooperativeId) ||
                other.cooperativeId == cooperativeId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.immatriculation, immatriculation) ||
                other.immatriculation == immatriculation) &&
            (identical(other.marque, marque) || other.marque == marque) &&
            (identical(other.chargeMaxKg, chargeMaxKg) ||
                other.chargeMaxKg == chargeMaxKg) &&
            (identical(other.chauffeurNom, chauffeurNom) ||
                other.chauffeurNom == chauffeurNom) &&
            (identical(other.chauffeurPhone, chauffeurPhone) ||
                other.chauffeurPhone == chauffeurPhone) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
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
    cooperativeId,
    type,
    immatriculation,
    marque,
    chargeMaxKg,
    chauffeurNom,
    chauffeurPhone,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of CoopVehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoopVehicleImplCopyWith<_$CoopVehicleImpl> get copyWith =>
      __$$CoopVehicleImplCopyWithImpl<_$CoopVehicleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoopVehicleImplToJson(this);
  }
}

abstract class _CoopVehicle implements CoopVehicle {
  const factory _CoopVehicle({
    required final String id,
    required final String cooperativeId,
    final String type,
    final String? immatriculation,
    final String? marque,
    @FlexDouble() final double chargeMaxKg,
    final String? chauffeurNom,
    final String? chauffeurPhone,
    final bool isActive,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$CoopVehicleImpl;

  factory _CoopVehicle.fromJson(Map<String, dynamic> json) =
      _$CoopVehicleImpl.fromJson;

  @override
  String get id;
  @override
  String get cooperativeId;
  @override
  String get type;
  @override
  String? get immatriculation;
  @override
  String? get marque;
  @override
  @FlexDouble()
  double get chargeMaxKg;
  @override
  String? get chauffeurNom;
  @override
  String? get chauffeurPhone;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of CoopVehicle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoopVehicleImplCopyWith<_$CoopVehicleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
