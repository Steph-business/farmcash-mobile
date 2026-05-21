// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Vehicle _$VehicleFromJson(Map<String, dynamic> json) {
  return _Vehicle.fromJson(json);
}

/// @nodoc
mixin _$Vehicle {
  String get id => throw _privateConstructorUsedError;
  String get transporterId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get immatriculation => throw _privateConstructorUsedError;
  String? get marque => throw _privateConstructorUsedError;
  @FlexDouble()
  double get chargeMaxKg => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get volumeM3 => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Vehicle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VehicleCopyWith<Vehicle> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehicleCopyWith<$Res> {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) then) =
      _$VehicleCopyWithImpl<$Res, Vehicle>;
  @useResult
  $Res call({
    String id,
    String transporterId,
    String type,
    String? immatriculation,
    String? marque,
    @FlexDouble() double chargeMaxKg,
    @FlexDoubleN() double? volumeM3,
    String? photoUrl,
    bool isActive,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$VehicleCopyWithImpl<$Res, $Val extends Vehicle>
    implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transporterId = null,
    Object? type = null,
    Object? immatriculation = freezed,
    Object? marque = freezed,
    Object? chargeMaxKg = null,
    Object? volumeM3 = freezed,
    Object? photoUrl = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            transporterId: null == transporterId
                ? _value.transporterId
                : transporterId // ignore: cast_nullable_to_non_nullable
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
            volumeM3: freezed == volumeM3
                ? _value.volumeM3
                : volumeM3 // ignore: cast_nullable_to_non_nullable
                      as double?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$VehicleImplCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$$VehicleImplCopyWith(
    _$VehicleImpl value,
    $Res Function(_$VehicleImpl) then,
  ) = __$$VehicleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String transporterId,
    String type,
    String? immatriculation,
    String? marque,
    @FlexDouble() double chargeMaxKg,
    @FlexDoubleN() double? volumeM3,
    String? photoUrl,
    bool isActive,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$VehicleImplCopyWithImpl<$Res>
    extends _$VehicleCopyWithImpl<$Res, _$VehicleImpl>
    implements _$$VehicleImplCopyWith<$Res> {
  __$$VehicleImplCopyWithImpl(
    _$VehicleImpl _value,
    $Res Function(_$VehicleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transporterId = null,
    Object? type = null,
    Object? immatriculation = freezed,
    Object? marque = freezed,
    Object? chargeMaxKg = null,
    Object? volumeM3 = freezed,
    Object? photoUrl = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$VehicleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        transporterId: null == transporterId
            ? _value.transporterId
            : transporterId // ignore: cast_nullable_to_non_nullable
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
        volumeM3: freezed == volumeM3
            ? _value.volumeM3
            : volumeM3 // ignore: cast_nullable_to_non_nullable
                  as double?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$VehicleImpl implements _Vehicle {
  const _$VehicleImpl({
    required this.id,
    required this.transporterId,
    this.type = '',
    this.immatriculation,
    this.marque,
    @FlexDouble() this.chargeMaxKg = 0,
    @FlexDoubleN() this.volumeM3,
    this.photoUrl,
    this.isActive = true,
    this.createdAt,
  });

  factory _$VehicleImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehicleImplFromJson(json);

  @override
  final String id;
  @override
  final String transporterId;
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
  @FlexDoubleN()
  final double? volumeM3;
  @override
  final String? photoUrl;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Vehicle(id: $id, transporterId: $transporterId, type: $type, immatriculation: $immatriculation, marque: $marque, chargeMaxKg: $chargeMaxKg, volumeM3: $volumeM3, photoUrl: $photoUrl, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transporterId, transporterId) ||
                other.transporterId == transporterId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.immatriculation, immatriculation) ||
                other.immatriculation == immatriculation) &&
            (identical(other.marque, marque) || other.marque == marque) &&
            (identical(other.chargeMaxKg, chargeMaxKg) ||
                other.chargeMaxKg == chargeMaxKg) &&
            (identical(other.volumeM3, volumeM3) ||
                other.volumeM3 == volumeM3) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    transporterId,
    type,
    immatriculation,
    marque,
    chargeMaxKg,
    volumeM3,
    photoUrl,
    isActive,
    createdAt,
  );

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VehicleImplCopyWith<_$VehicleImpl> get copyWith =>
      __$$VehicleImplCopyWithImpl<_$VehicleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VehicleImplToJson(this);
  }
}

abstract class _Vehicle implements Vehicle {
  const factory _Vehicle({
    required final String id,
    required final String transporterId,
    final String type,
    final String? immatriculation,
    final String? marque,
    @FlexDouble() final double chargeMaxKg,
    @FlexDoubleN() final double? volumeM3,
    final String? photoUrl,
    final bool isActive,
    final DateTime? createdAt,
  }) = _$VehicleImpl;

  factory _Vehicle.fromJson(Map<String, dynamic> json) = _$VehicleImpl.fromJson;

  @override
  String get id;
  @override
  String get transporterId;
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
  @FlexDoubleN()
  double? get volumeM3;
  @override
  String? get photoUrl;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VehicleImplCopyWith<_$VehicleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
