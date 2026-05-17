// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livraison.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Livraison _$LivraisonFromJson(Map<String, dynamic> json) {
  return _Livraison.fromJson(json);
}

/// @nodoc
mixin _$Livraison {
  String get id => throw _privateConstructorUsedError;
  String get commandeId => throw _privateConstructorUsedError;
  String? get transporterId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ShipmentStatus.unknown)
  ShipmentStatus get status => throw _privateConstructorUsedError;
  String? get pickupLocation => throw _privateConstructorUsedError;
  String? get deliveryLocation => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get pickupLat => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get pickupLng => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get deliveryLat => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get deliveryLng => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get prixDevis => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get prixFinal => throw _privateConstructorUsedError;
  String? get photoPreuveUrl => throw _privateConstructorUsedError;
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Livraison to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Livraison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LivraisonCopyWith<Livraison> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LivraisonCopyWith<$Res> {
  factory $LivraisonCopyWith(Livraison value, $Res Function(Livraison) then) =
      _$LivraisonCopyWithImpl<$Res, Livraison>;
  @useResult
  $Res call({
    String id,
    String commandeId,
    String? transporterId,
    @JsonKey(unknownEnumValue: ShipmentStatus.unknown) ShipmentStatus status,
    String? pickupLocation,
    String? deliveryLocation,
    @FlexDoubleN() double? pickupLat,
    @FlexDoubleN() double? pickupLng,
    @FlexDoubleN() double? deliveryLat,
    @FlexDoubleN() double? deliveryLng,
    @FlexDoubleN() double? prixDevis,
    @FlexDoubleN() double? prixFinal,
    String? photoPreuveUrl,
    DateTime? scheduledAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$LivraisonCopyWithImpl<$Res, $Val extends Livraison>
    implements $LivraisonCopyWith<$Res> {
  _$LivraisonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Livraison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? commandeId = null,
    Object? transporterId = freezed,
    Object? status = null,
    Object? pickupLocation = freezed,
    Object? deliveryLocation = freezed,
    Object? pickupLat = freezed,
    Object? pickupLng = freezed,
    Object? deliveryLat = freezed,
    Object? deliveryLng = freezed,
    Object? prixDevis = freezed,
    Object? prixFinal = freezed,
    Object? photoPreuveUrl = freezed,
    Object? scheduledAt = freezed,
    Object? deliveredAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            commandeId: null == commandeId
                ? _value.commandeId
                : commandeId // ignore: cast_nullable_to_non_nullable
                      as String,
            transporterId: freezed == transporterId
                ? _value.transporterId
                : transporterId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ShipmentStatus,
            pickupLocation: freezed == pickupLocation
                ? _value.pickupLocation
                : pickupLocation // ignore: cast_nullable_to_non_nullable
                      as String?,
            deliveryLocation: freezed == deliveryLocation
                ? _value.deliveryLocation
                : deliveryLocation // ignore: cast_nullable_to_non_nullable
                      as String?,
            pickupLat: freezed == pickupLat
                ? _value.pickupLat
                : pickupLat // ignore: cast_nullable_to_non_nullable
                      as double?,
            pickupLng: freezed == pickupLng
                ? _value.pickupLng
                : pickupLng // ignore: cast_nullable_to_non_nullable
                      as double?,
            deliveryLat: freezed == deliveryLat
                ? _value.deliveryLat
                : deliveryLat // ignore: cast_nullable_to_non_nullable
                      as double?,
            deliveryLng: freezed == deliveryLng
                ? _value.deliveryLng
                : deliveryLng // ignore: cast_nullable_to_non_nullable
                      as double?,
            prixDevis: freezed == prixDevis
                ? _value.prixDevis
                : prixDevis // ignore: cast_nullable_to_non_nullable
                      as double?,
            prixFinal: freezed == prixFinal
                ? _value.prixFinal
                : prixFinal // ignore: cast_nullable_to_non_nullable
                      as double?,
            photoPreuveUrl: freezed == photoPreuveUrl
                ? _value.photoPreuveUrl
                : photoPreuveUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            scheduledAt: freezed == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deliveredAt: freezed == deliveredAt
                ? _value.deliveredAt
                : deliveredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$LivraisonImplCopyWith<$Res>
    implements $LivraisonCopyWith<$Res> {
  factory _$$LivraisonImplCopyWith(
    _$LivraisonImpl value,
    $Res Function(_$LivraisonImpl) then,
  ) = __$$LivraisonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String commandeId,
    String? transporterId,
    @JsonKey(unknownEnumValue: ShipmentStatus.unknown) ShipmentStatus status,
    String? pickupLocation,
    String? deliveryLocation,
    @FlexDoubleN() double? pickupLat,
    @FlexDoubleN() double? pickupLng,
    @FlexDoubleN() double? deliveryLat,
    @FlexDoubleN() double? deliveryLng,
    @FlexDoubleN() double? prixDevis,
    @FlexDoubleN() double? prixFinal,
    String? photoPreuveUrl,
    DateTime? scheduledAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$LivraisonImplCopyWithImpl<$Res>
    extends _$LivraisonCopyWithImpl<$Res, _$LivraisonImpl>
    implements _$$LivraisonImplCopyWith<$Res> {
  __$$LivraisonImplCopyWithImpl(
    _$LivraisonImpl _value,
    $Res Function(_$LivraisonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Livraison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? commandeId = null,
    Object? transporterId = freezed,
    Object? status = null,
    Object? pickupLocation = freezed,
    Object? deliveryLocation = freezed,
    Object? pickupLat = freezed,
    Object? pickupLng = freezed,
    Object? deliveryLat = freezed,
    Object? deliveryLng = freezed,
    Object? prixDevis = freezed,
    Object? prixFinal = freezed,
    Object? photoPreuveUrl = freezed,
    Object? scheduledAt = freezed,
    Object? deliveredAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$LivraisonImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        commandeId: null == commandeId
            ? _value.commandeId
            : commandeId // ignore: cast_nullable_to_non_nullable
                  as String,
        transporterId: freezed == transporterId
            ? _value.transporterId
            : transporterId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ShipmentStatus,
        pickupLocation: freezed == pickupLocation
            ? _value.pickupLocation
            : pickupLocation // ignore: cast_nullable_to_non_nullable
                  as String?,
        deliveryLocation: freezed == deliveryLocation
            ? _value.deliveryLocation
            : deliveryLocation // ignore: cast_nullable_to_non_nullable
                  as String?,
        pickupLat: freezed == pickupLat
            ? _value.pickupLat
            : pickupLat // ignore: cast_nullable_to_non_nullable
                  as double?,
        pickupLng: freezed == pickupLng
            ? _value.pickupLng
            : pickupLng // ignore: cast_nullable_to_non_nullable
                  as double?,
        deliveryLat: freezed == deliveryLat
            ? _value.deliveryLat
            : deliveryLat // ignore: cast_nullable_to_non_nullable
                  as double?,
        deliveryLng: freezed == deliveryLng
            ? _value.deliveryLng
            : deliveryLng // ignore: cast_nullable_to_non_nullable
                  as double?,
        prixDevis: freezed == prixDevis
            ? _value.prixDevis
            : prixDevis // ignore: cast_nullable_to_non_nullable
                  as double?,
        prixFinal: freezed == prixFinal
            ? _value.prixFinal
            : prixFinal // ignore: cast_nullable_to_non_nullable
                  as double?,
        photoPreuveUrl: freezed == photoPreuveUrl
            ? _value.photoPreuveUrl
            : photoPreuveUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        scheduledAt: freezed == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deliveredAt: freezed == deliveredAt
            ? _value.deliveredAt
            : deliveredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$LivraisonImpl implements _Livraison {
  const _$LivraisonImpl({
    required this.id,
    required this.commandeId,
    this.transporterId,
    @JsonKey(unknownEnumValue: ShipmentStatus.unknown)
    this.status = ShipmentStatus.unknown,
    this.pickupLocation,
    this.deliveryLocation,
    @FlexDoubleN() this.pickupLat,
    @FlexDoubleN() this.pickupLng,
    @FlexDoubleN() this.deliveryLat,
    @FlexDoubleN() this.deliveryLng,
    @FlexDoubleN() this.prixDevis,
    @FlexDoubleN() this.prixFinal,
    this.photoPreuveUrl,
    this.scheduledAt,
    this.deliveredAt,
    this.createdAt,
  });

  factory _$LivraisonImpl.fromJson(Map<String, dynamic> json) =>
      _$$LivraisonImplFromJson(json);

  @override
  final String id;
  @override
  final String commandeId;
  @override
  final String? transporterId;
  @override
  @JsonKey(unknownEnumValue: ShipmentStatus.unknown)
  final ShipmentStatus status;
  @override
  final String? pickupLocation;
  @override
  final String? deliveryLocation;
  @override
  @FlexDoubleN()
  final double? pickupLat;
  @override
  @FlexDoubleN()
  final double? pickupLng;
  @override
  @FlexDoubleN()
  final double? deliveryLat;
  @override
  @FlexDoubleN()
  final double? deliveryLng;
  @override
  @FlexDoubleN()
  final double? prixDevis;
  @override
  @FlexDoubleN()
  final double? prixFinal;
  @override
  final String? photoPreuveUrl;
  @override
  final DateTime? scheduledAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Livraison(id: $id, commandeId: $commandeId, transporterId: $transporterId, status: $status, pickupLocation: $pickupLocation, deliveryLocation: $deliveryLocation, pickupLat: $pickupLat, pickupLng: $pickupLng, deliveryLat: $deliveryLat, deliveryLng: $deliveryLng, prixDevis: $prixDevis, prixFinal: $prixFinal, photoPreuveUrl: $photoPreuveUrl, scheduledAt: $scheduledAt, deliveredAt: $deliveredAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LivraisonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.commandeId, commandeId) ||
                other.commandeId == commandeId) &&
            (identical(other.transporterId, transporterId) ||
                other.transporterId == transporterId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pickupLocation, pickupLocation) ||
                other.pickupLocation == pickupLocation) &&
            (identical(other.deliveryLocation, deliveryLocation) ||
                other.deliveryLocation == deliveryLocation) &&
            (identical(other.pickupLat, pickupLat) ||
                other.pickupLat == pickupLat) &&
            (identical(other.pickupLng, pickupLng) ||
                other.pickupLng == pickupLng) &&
            (identical(other.deliveryLat, deliveryLat) ||
                other.deliveryLat == deliveryLat) &&
            (identical(other.deliveryLng, deliveryLng) ||
                other.deliveryLng == deliveryLng) &&
            (identical(other.prixDevis, prixDevis) ||
                other.prixDevis == prixDevis) &&
            (identical(other.prixFinal, prixFinal) ||
                other.prixFinal == prixFinal) &&
            (identical(other.photoPreuveUrl, photoPreuveUrl) ||
                other.photoPreuveUrl == photoPreuveUrl) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    commandeId,
    transporterId,
    status,
    pickupLocation,
    deliveryLocation,
    pickupLat,
    pickupLng,
    deliveryLat,
    deliveryLng,
    prixDevis,
    prixFinal,
    photoPreuveUrl,
    scheduledAt,
    deliveredAt,
    createdAt,
  );

  /// Create a copy of Livraison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LivraisonImplCopyWith<_$LivraisonImpl> get copyWith =>
      __$$LivraisonImplCopyWithImpl<_$LivraisonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LivraisonImplToJson(this);
  }
}

abstract class _Livraison implements Livraison {
  const factory _Livraison({
    required final String id,
    required final String commandeId,
    final String? transporterId,
    @JsonKey(unknownEnumValue: ShipmentStatus.unknown)
    final ShipmentStatus status,
    final String? pickupLocation,
    final String? deliveryLocation,
    @FlexDoubleN() final double? pickupLat,
    @FlexDoubleN() final double? pickupLng,
    @FlexDoubleN() final double? deliveryLat,
    @FlexDoubleN() final double? deliveryLng,
    @FlexDoubleN() final double? prixDevis,
    @FlexDoubleN() final double? prixFinal,
    final String? photoPreuveUrl,
    final DateTime? scheduledAt,
    final DateTime? deliveredAt,
    final DateTime? createdAt,
  }) = _$LivraisonImpl;

  factory _Livraison.fromJson(Map<String, dynamic> json) =
      _$LivraisonImpl.fromJson;

  @override
  String get id;
  @override
  String get commandeId;
  @override
  String? get transporterId;
  @override
  @JsonKey(unknownEnumValue: ShipmentStatus.unknown)
  ShipmentStatus get status;
  @override
  String? get pickupLocation;
  @override
  String? get deliveryLocation;
  @override
  @FlexDoubleN()
  double? get pickupLat;
  @override
  @FlexDoubleN()
  double? get pickupLng;
  @override
  @FlexDoubleN()
  double? get deliveryLat;
  @override
  @FlexDoubleN()
  double? get deliveryLng;
  @override
  @FlexDoubleN()
  double? get prixDevis;
  @override
  @FlexDoubleN()
  double? get prixFinal;
  @override
  String? get photoPreuveUrl;
  @override
  DateTime? get scheduledAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of Livraison
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LivraisonImplCopyWith<_$LivraisonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TransporterRoute _$TransporterRouteFromJson(Map<String, dynamic> json) {
  return _TransporterRoute.fromJson(json);
}

/// @nodoc
mixin _$TransporterRoute {
  String get id => throw _privateConstructorUsedError;
  String get transporterId => throw _privateConstructorUsedError;
  String get origineVilleId => throw _privateConstructorUsedError;
  String get destinationVilleId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get capaciteKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get prixParKm => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get prixForfait => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TransporterRoute to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransporterRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransporterRouteCopyWith<TransporterRoute> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransporterRouteCopyWith<$Res> {
  factory $TransporterRouteCopyWith(
    TransporterRoute value,
    $Res Function(TransporterRoute) then,
  ) = _$TransporterRouteCopyWithImpl<$Res, TransporterRoute>;
  @useResult
  $Res call({
    String id,
    String transporterId,
    String origineVilleId,
    String destinationVilleId,
    @FlexDouble() double capaciteKg,
    @FlexDouble() double prixParKm,
    @FlexDoubleN() double? prixForfait,
    bool isActive,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$TransporterRouteCopyWithImpl<$Res, $Val extends TransporterRoute>
    implements $TransporterRouteCopyWith<$Res> {
  _$TransporterRouteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransporterRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transporterId = null,
    Object? origineVilleId = null,
    Object? destinationVilleId = null,
    Object? capaciteKg = null,
    Object? prixParKm = null,
    Object? prixForfait = freezed,
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
            origineVilleId: null == origineVilleId
                ? _value.origineVilleId
                : origineVilleId // ignore: cast_nullable_to_non_nullable
                      as String,
            destinationVilleId: null == destinationVilleId
                ? _value.destinationVilleId
                : destinationVilleId // ignore: cast_nullable_to_non_nullable
                      as String,
            capaciteKg: null == capaciteKg
                ? _value.capaciteKg
                : capaciteKg // ignore: cast_nullable_to_non_nullable
                      as double,
            prixParKm: null == prixParKm
                ? _value.prixParKm
                : prixParKm // ignore: cast_nullable_to_non_nullable
                      as double,
            prixForfait: freezed == prixForfait
                ? _value.prixForfait
                : prixForfait // ignore: cast_nullable_to_non_nullable
                      as double?,
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
abstract class _$$TransporterRouteImplCopyWith<$Res>
    implements $TransporterRouteCopyWith<$Res> {
  factory _$$TransporterRouteImplCopyWith(
    _$TransporterRouteImpl value,
    $Res Function(_$TransporterRouteImpl) then,
  ) = __$$TransporterRouteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String transporterId,
    String origineVilleId,
    String destinationVilleId,
    @FlexDouble() double capaciteKg,
    @FlexDouble() double prixParKm,
    @FlexDoubleN() double? prixForfait,
    bool isActive,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$TransporterRouteImplCopyWithImpl<$Res>
    extends _$TransporterRouteCopyWithImpl<$Res, _$TransporterRouteImpl>
    implements _$$TransporterRouteImplCopyWith<$Res> {
  __$$TransporterRouteImplCopyWithImpl(
    _$TransporterRouteImpl _value,
    $Res Function(_$TransporterRouteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransporterRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transporterId = null,
    Object? origineVilleId = null,
    Object? destinationVilleId = null,
    Object? capaciteKg = null,
    Object? prixParKm = null,
    Object? prixForfait = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TransporterRouteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        transporterId: null == transporterId
            ? _value.transporterId
            : transporterId // ignore: cast_nullable_to_non_nullable
                  as String,
        origineVilleId: null == origineVilleId
            ? _value.origineVilleId
            : origineVilleId // ignore: cast_nullable_to_non_nullable
                  as String,
        destinationVilleId: null == destinationVilleId
            ? _value.destinationVilleId
            : destinationVilleId // ignore: cast_nullable_to_non_nullable
                  as String,
        capaciteKg: null == capaciteKg
            ? _value.capaciteKg
            : capaciteKg // ignore: cast_nullable_to_non_nullable
                  as double,
        prixParKm: null == prixParKm
            ? _value.prixParKm
            : prixParKm // ignore: cast_nullable_to_non_nullable
                  as double,
        prixForfait: freezed == prixForfait
            ? _value.prixForfait
            : prixForfait // ignore: cast_nullable_to_non_nullable
                  as double?,
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
class _$TransporterRouteImpl implements _TransporterRoute {
  const _$TransporterRouteImpl({
    required this.id,
    required this.transporterId,
    required this.origineVilleId,
    required this.destinationVilleId,
    @FlexDouble() required this.capaciteKg,
    @FlexDouble() required this.prixParKm,
    @FlexDoubleN() this.prixForfait,
    this.isActive = true,
    this.createdAt,
  });

  factory _$TransporterRouteImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransporterRouteImplFromJson(json);

  @override
  final String id;
  @override
  final String transporterId;
  @override
  final String origineVilleId;
  @override
  final String destinationVilleId;
  @override
  @FlexDouble()
  final double capaciteKg;
  @override
  @FlexDouble()
  final double prixParKm;
  @override
  @FlexDoubleN()
  final double? prixForfait;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TransporterRoute(id: $id, transporterId: $transporterId, origineVilleId: $origineVilleId, destinationVilleId: $destinationVilleId, capaciteKg: $capaciteKg, prixParKm: $prixParKm, prixForfait: $prixForfait, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransporterRouteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transporterId, transporterId) ||
                other.transporterId == transporterId) &&
            (identical(other.origineVilleId, origineVilleId) ||
                other.origineVilleId == origineVilleId) &&
            (identical(other.destinationVilleId, destinationVilleId) ||
                other.destinationVilleId == destinationVilleId) &&
            (identical(other.capaciteKg, capaciteKg) ||
                other.capaciteKg == capaciteKg) &&
            (identical(other.prixParKm, prixParKm) ||
                other.prixParKm == prixParKm) &&
            (identical(other.prixForfait, prixForfait) ||
                other.prixForfait == prixForfait) &&
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
    origineVilleId,
    destinationVilleId,
    capaciteKg,
    prixParKm,
    prixForfait,
    isActive,
    createdAt,
  );

  /// Create a copy of TransporterRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransporterRouteImplCopyWith<_$TransporterRouteImpl> get copyWith =>
      __$$TransporterRouteImplCopyWithImpl<_$TransporterRouteImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TransporterRouteImplToJson(this);
  }
}

abstract class _TransporterRoute implements TransporterRoute {
  const factory _TransporterRoute({
    required final String id,
    required final String transporterId,
    required final String origineVilleId,
    required final String destinationVilleId,
    @FlexDouble() required final double capaciteKg,
    @FlexDouble() required final double prixParKm,
    @FlexDoubleN() final double? prixForfait,
    final bool isActive,
    final DateTime? createdAt,
  }) = _$TransporterRouteImpl;

  factory _TransporterRoute.fromJson(Map<String, dynamic> json) =
      _$TransporterRouteImpl.fromJson;

  @override
  String get id;
  @override
  String get transporterId;
  @override
  String get origineVilleId;
  @override
  String get destinationVilleId;
  @override
  @FlexDouble()
  double get capaciteKg;
  @override
  @FlexDouble()
  double get prixParKm;
  @override
  @FlexDoubleN()
  double? get prixForfait;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;

  /// Create a copy of TransporterRoute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransporterRouteImplCopyWith<_$TransporterRouteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrackingEvent _$TrackingEventFromJson(Map<String, dynamic> json) {
  return _TrackingEvent.fromJson(json);
}

/// @nodoc
mixin _$TrackingEvent {
  String get id => throw _privateConstructorUsedError;
  String get shipmentId => throw _privateConstructorUsedError;
  TrackingLocation? get location => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TrackingEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrackingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackingEventCopyWith<TrackingEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackingEventCopyWith<$Res> {
  factory $TrackingEventCopyWith(
    TrackingEvent value,
    $Res Function(TrackingEvent) then,
  ) = _$TrackingEventCopyWithImpl<$Res, TrackingEvent>;
  @useResult
  $Res call({
    String id,
    String shipmentId,
    TrackingLocation? location,
    String? status,
    DateTime? createdAt,
  });

  $TrackingLocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$TrackingEventCopyWithImpl<$Res, $Val extends TrackingEvent>
    implements $TrackingEventCopyWith<$Res> {
  _$TrackingEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackingEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shipmentId = null,
    Object? location = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            shipmentId: null == shipmentId
                ? _value.shipmentId
                : shipmentId // ignore: cast_nullable_to_non_nullable
                      as String,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as TrackingLocation?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of TrackingEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrackingLocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $TrackingLocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrackingEventImplCopyWith<$Res>
    implements $TrackingEventCopyWith<$Res> {
  factory _$$TrackingEventImplCopyWith(
    _$TrackingEventImpl value,
    $Res Function(_$TrackingEventImpl) then,
  ) = __$$TrackingEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String shipmentId,
    TrackingLocation? location,
    String? status,
    DateTime? createdAt,
  });

  @override
  $TrackingLocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$TrackingEventImplCopyWithImpl<$Res>
    extends _$TrackingEventCopyWithImpl<$Res, _$TrackingEventImpl>
    implements _$$TrackingEventImplCopyWith<$Res> {
  __$$TrackingEventImplCopyWithImpl(
    _$TrackingEventImpl _value,
    $Res Function(_$TrackingEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrackingEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shipmentId = null,
    Object? location = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TrackingEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        shipmentId: null == shipmentId
            ? _value.shipmentId
            : shipmentId // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as TrackingLocation?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
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
class _$TrackingEventImpl extends _TrackingEvent {
  const _$TrackingEventImpl({
    required this.id,
    required this.shipmentId,
    this.location,
    this.status,
    this.createdAt,
  }) : super._();

  factory _$TrackingEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackingEventImplFromJson(json);

  @override
  final String id;
  @override
  final String shipmentId;
  @override
  final TrackingLocation? location;
  @override
  final String? status;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TrackingEvent(id: $id, shipmentId: $shipmentId, location: $location, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackingEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shipmentId, shipmentId) ||
                other.shipmentId == shipmentId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, shipmentId, location, status, createdAt);

  /// Create a copy of TrackingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackingEventImplCopyWith<_$TrackingEventImpl> get copyWith =>
      __$$TrackingEventImplCopyWithImpl<_$TrackingEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrackingEventImplToJson(this);
  }
}

abstract class _TrackingEvent extends TrackingEvent {
  const factory _TrackingEvent({
    required final String id,
    required final String shipmentId,
    final TrackingLocation? location,
    final String? status,
    final DateTime? createdAt,
  }) = _$TrackingEventImpl;
  const _TrackingEvent._() : super._();

  factory _TrackingEvent.fromJson(Map<String, dynamic> json) =
      _$TrackingEventImpl.fromJson;

  @override
  String get id;
  @override
  String get shipmentId;
  @override
  TrackingLocation? get location;
  @override
  String? get status;
  @override
  DateTime? get createdAt;

  /// Create a copy of TrackingEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackingEventImplCopyWith<_$TrackingEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrackingLocation _$TrackingLocationFromJson(Map<String, dynamic> json) {
  return _TrackingLocation.fromJson(json);
}

/// @nodoc
mixin _$TrackingLocation {
  @FlexDoubleN()
  double? get lat => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get lng => throw _privateConstructorUsedError;

  /// Serializes this TrackingLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrackingLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackingLocationCopyWith<TrackingLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackingLocationCopyWith<$Res> {
  factory $TrackingLocationCopyWith(
    TrackingLocation value,
    $Res Function(TrackingLocation) then,
  ) = _$TrackingLocationCopyWithImpl<$Res, TrackingLocation>;
  @useResult
  $Res call({@FlexDoubleN() double? lat, @FlexDoubleN() double? lng});
}

/// @nodoc
class _$TrackingLocationCopyWithImpl<$Res, $Val extends TrackingLocation>
    implements $TrackingLocationCopyWith<$Res> {
  _$TrackingLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackingLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lat = freezed, Object? lng = freezed}) {
    return _then(
      _value.copyWith(
            lat: freezed == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double?,
            lng: freezed == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrackingLocationImplCopyWith<$Res>
    implements $TrackingLocationCopyWith<$Res> {
  factory _$$TrackingLocationImplCopyWith(
    _$TrackingLocationImpl value,
    $Res Function(_$TrackingLocationImpl) then,
  ) = __$$TrackingLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@FlexDoubleN() double? lat, @FlexDoubleN() double? lng});
}

/// @nodoc
class __$$TrackingLocationImplCopyWithImpl<$Res>
    extends _$TrackingLocationCopyWithImpl<$Res, _$TrackingLocationImpl>
    implements _$$TrackingLocationImplCopyWith<$Res> {
  __$$TrackingLocationImplCopyWithImpl(
    _$TrackingLocationImpl _value,
    $Res Function(_$TrackingLocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrackingLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lat = freezed, Object? lng = freezed}) {
    return _then(
      _$TrackingLocationImpl(
        lat: freezed == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double?,
        lng: freezed == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrackingLocationImpl implements _TrackingLocation {
  const _$TrackingLocationImpl({
    @FlexDoubleN() this.lat,
    @FlexDoubleN() this.lng,
  });

  factory _$TrackingLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackingLocationImplFromJson(json);

  @override
  @FlexDoubleN()
  final double? lat;
  @override
  @FlexDoubleN()
  final double? lng;

  @override
  String toString() {
    return 'TrackingLocation(lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackingLocationImpl &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lng);

  /// Create a copy of TrackingLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackingLocationImplCopyWith<_$TrackingLocationImpl> get copyWith =>
      __$$TrackingLocationImplCopyWithImpl<_$TrackingLocationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TrackingLocationImplToJson(this);
  }
}

abstract class _TrackingLocation implements TrackingLocation {
  const factory _TrackingLocation({
    @FlexDoubleN() final double? lat,
    @FlexDoubleN() final double? lng,
  }) = _$TrackingLocationImpl;

  factory _TrackingLocation.fromJson(Map<String, dynamic> json) =
      _$TrackingLocationImpl.fromJson;

  @override
  @FlexDoubleN()
  double? get lat;
  @override
  @FlexDoubleN()
  double? get lng;

  /// Create a copy of TrackingLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackingLocationImplCopyWith<_$TrackingLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
