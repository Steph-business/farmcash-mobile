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
  String? get vehicleType => throw _privateConstructorUsedError;
  @JsonKey(name: 'origin_zone')
  String? get origineZone => throw _privateConstructorUsedError;
  @JsonKey(name: 'destination_zone')
  String? get destinationZone => throw _privateConstructorUsedError;
  String? get pickupAddress => throw _privateConstructorUsedError;
  String? get deliveryAddress => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get prixDevis => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get prixFinal => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get quantiteKg => throw _privateConstructorUsedError;
  String? get photoPreuveUrl => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get pickupScannedAt => throw _privateConstructorUsedError;

  /// Champ joint `commandes_vente` quand le backend l'expose
  /// (notamment `GET /logistics/missions/available`).
  @JsonKey(
    name: 'commandes_vente',
    fromJson: _commandeApercuFromJson,
    toJson: _commandeApercuToJson,
  )
  CommandeApercu? get commande => throw _privateConstructorUsedError;

  /// Champ joint `users` (le transporteur assigné) quand le backend
  /// l'expose — notamment `GET /shipments/by-commande/:id`. Permet
  /// d'afficher nom + photo + rating sans appel supplémentaire.
  @JsonKey(
    name: 'users',
    fromJson: _transporterApercuFromJson,
    toJson: _transporterApercuToJson,
  )
  TransporterApercu? get transporter => throw _privateConstructorUsedError;

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
    String? vehicleType,
    @JsonKey(name: 'origin_zone') String? origineZone,
    @JsonKey(name: 'destination_zone') String? destinationZone,
    String? pickupAddress,
    String? deliveryAddress,
    @FlexDoubleN() double? prixDevis,
    @FlexDoubleN() double? prixFinal,
    @FlexDoubleN() double? quantiteKg,
    String? photoPreuveUrl,
    String? notes,
    DateTime? scheduledAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? pickupScannedAt,
    @JsonKey(
      name: 'commandes_vente',
      fromJson: _commandeApercuFromJson,
      toJson: _commandeApercuToJson,
    )
    CommandeApercu? commande,
    @JsonKey(
      name: 'users',
      fromJson: _transporterApercuFromJson,
      toJson: _transporterApercuToJson,
    )
    TransporterApercu? transporter,
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
    Object? vehicleType = freezed,
    Object? origineZone = freezed,
    Object? destinationZone = freezed,
    Object? pickupAddress = freezed,
    Object? deliveryAddress = freezed,
    Object? prixDevis = freezed,
    Object? prixFinal = freezed,
    Object? quantiteKg = freezed,
    Object? photoPreuveUrl = freezed,
    Object? notes = freezed,
    Object? scheduledAt = freezed,
    Object? deliveredAt = freezed,
    Object? createdAt = freezed,
    Object? pickupScannedAt = freezed,
    Object? commande = freezed,
    Object? transporter = freezed,
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
            vehicleType: freezed == vehicleType
                ? _value.vehicleType
                : vehicleType // ignore: cast_nullable_to_non_nullable
                      as String?,
            origineZone: freezed == origineZone
                ? _value.origineZone
                : origineZone // ignore: cast_nullable_to_non_nullable
                      as String?,
            destinationZone: freezed == destinationZone
                ? _value.destinationZone
                : destinationZone // ignore: cast_nullable_to_non_nullable
                      as String?,
            pickupAddress: freezed == pickupAddress
                ? _value.pickupAddress
                : pickupAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            deliveryAddress: freezed == deliveryAddress
                ? _value.deliveryAddress
                : deliveryAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            prixDevis: freezed == prixDevis
                ? _value.prixDevis
                : prixDevis // ignore: cast_nullable_to_non_nullable
                      as double?,
            prixFinal: freezed == prixFinal
                ? _value.prixFinal
                : prixFinal // ignore: cast_nullable_to_non_nullable
                      as double?,
            quantiteKg: freezed == quantiteKg
                ? _value.quantiteKg
                : quantiteKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            photoPreuveUrl: freezed == photoPreuveUrl
                ? _value.photoPreuveUrl
                : photoPreuveUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
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
            pickupScannedAt: freezed == pickupScannedAt
                ? _value.pickupScannedAt
                : pickupScannedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            commande: freezed == commande
                ? _value.commande
                : commande // ignore: cast_nullable_to_non_nullable
                      as CommandeApercu?,
            transporter: freezed == transporter
                ? _value.transporter
                : transporter // ignore: cast_nullable_to_non_nullable
                      as TransporterApercu?,
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
    String? vehicleType,
    @JsonKey(name: 'origin_zone') String? origineZone,
    @JsonKey(name: 'destination_zone') String? destinationZone,
    String? pickupAddress,
    String? deliveryAddress,
    @FlexDoubleN() double? prixDevis,
    @FlexDoubleN() double? prixFinal,
    @FlexDoubleN() double? quantiteKg,
    String? photoPreuveUrl,
    String? notes,
    DateTime? scheduledAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? pickupScannedAt,
    @JsonKey(
      name: 'commandes_vente',
      fromJson: _commandeApercuFromJson,
      toJson: _commandeApercuToJson,
    )
    CommandeApercu? commande,
    @JsonKey(
      name: 'users',
      fromJson: _transporterApercuFromJson,
      toJson: _transporterApercuToJson,
    )
    TransporterApercu? transporter,
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
    Object? vehicleType = freezed,
    Object? origineZone = freezed,
    Object? destinationZone = freezed,
    Object? pickupAddress = freezed,
    Object? deliveryAddress = freezed,
    Object? prixDevis = freezed,
    Object? prixFinal = freezed,
    Object? quantiteKg = freezed,
    Object? photoPreuveUrl = freezed,
    Object? notes = freezed,
    Object? scheduledAt = freezed,
    Object? deliveredAt = freezed,
    Object? createdAt = freezed,
    Object? pickupScannedAt = freezed,
    Object? commande = freezed,
    Object? transporter = freezed,
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
        vehicleType: freezed == vehicleType
            ? _value.vehicleType
            : vehicleType // ignore: cast_nullable_to_non_nullable
                  as String?,
        origineZone: freezed == origineZone
            ? _value.origineZone
            : origineZone // ignore: cast_nullable_to_non_nullable
                  as String?,
        destinationZone: freezed == destinationZone
            ? _value.destinationZone
            : destinationZone // ignore: cast_nullable_to_non_nullable
                  as String?,
        pickupAddress: freezed == pickupAddress
            ? _value.pickupAddress
            : pickupAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        deliveryAddress: freezed == deliveryAddress
            ? _value.deliveryAddress
            : deliveryAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        prixDevis: freezed == prixDevis
            ? _value.prixDevis
            : prixDevis // ignore: cast_nullable_to_non_nullable
                  as double?,
        prixFinal: freezed == prixFinal
            ? _value.prixFinal
            : prixFinal // ignore: cast_nullable_to_non_nullable
                  as double?,
        quantiteKg: freezed == quantiteKg
            ? _value.quantiteKg
            : quantiteKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        photoPreuveUrl: freezed == photoPreuveUrl
            ? _value.photoPreuveUrl
            : photoPreuveUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
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
        pickupScannedAt: freezed == pickupScannedAt
            ? _value.pickupScannedAt
            : pickupScannedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        commande: freezed == commande
            ? _value.commande
            : commande // ignore: cast_nullable_to_non_nullable
                  as CommandeApercu?,
        transporter: freezed == transporter
            ? _value.transporter
            : transporter // ignore: cast_nullable_to_non_nullable
                  as TransporterApercu?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LivraisonImpl extends _Livraison {
  const _$LivraisonImpl({
    required this.id,
    required this.commandeId,
    this.transporterId,
    @JsonKey(unknownEnumValue: ShipmentStatus.unknown)
    this.status = ShipmentStatus.unknown,
    this.vehicleType,
    @JsonKey(name: 'origin_zone') this.origineZone,
    @JsonKey(name: 'destination_zone') this.destinationZone,
    this.pickupAddress,
    this.deliveryAddress,
    @FlexDoubleN() this.prixDevis,
    @FlexDoubleN() this.prixFinal,
    @FlexDoubleN() this.quantiteKg,
    this.photoPreuveUrl,
    this.notes,
    this.scheduledAt,
    this.deliveredAt,
    this.createdAt,
    this.pickupScannedAt,
    @JsonKey(
      name: 'commandes_vente',
      fromJson: _commandeApercuFromJson,
      toJson: _commandeApercuToJson,
    )
    this.commande,
    @JsonKey(
      name: 'users',
      fromJson: _transporterApercuFromJson,
      toJson: _transporterApercuToJson,
    )
    this.transporter,
  }) : super._();

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
  final String? vehicleType;
  @override
  @JsonKey(name: 'origin_zone')
  final String? origineZone;
  @override
  @JsonKey(name: 'destination_zone')
  final String? destinationZone;
  @override
  final String? pickupAddress;
  @override
  final String? deliveryAddress;
  @override
  @FlexDoubleN()
  final double? prixDevis;
  @override
  @FlexDoubleN()
  final double? prixFinal;
  @override
  @FlexDoubleN()
  final double? quantiteKg;
  @override
  final String? photoPreuveUrl;
  @override
  final String? notes;
  @override
  final DateTime? scheduledAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? pickupScannedAt;

  /// Champ joint `commandes_vente` quand le backend l'expose
  /// (notamment `GET /logistics/missions/available`).
  @override
  @JsonKey(
    name: 'commandes_vente',
    fromJson: _commandeApercuFromJson,
    toJson: _commandeApercuToJson,
  )
  final CommandeApercu? commande;

  /// Champ joint `users` (le transporteur assigné) quand le backend
  /// l'expose — notamment `GET /shipments/by-commande/:id`. Permet
  /// d'afficher nom + photo + rating sans appel supplémentaire.
  @override
  @JsonKey(
    name: 'users',
    fromJson: _transporterApercuFromJson,
    toJson: _transporterApercuToJson,
  )
  final TransporterApercu? transporter;

  @override
  String toString() {
    return 'Livraison(id: $id, commandeId: $commandeId, transporterId: $transporterId, status: $status, vehicleType: $vehicleType, origineZone: $origineZone, destinationZone: $destinationZone, pickupAddress: $pickupAddress, deliveryAddress: $deliveryAddress, prixDevis: $prixDevis, prixFinal: $prixFinal, quantiteKg: $quantiteKg, photoPreuveUrl: $photoPreuveUrl, notes: $notes, scheduledAt: $scheduledAt, deliveredAt: $deliveredAt, createdAt: $createdAt, pickupScannedAt: $pickupScannedAt, commande: $commande, transporter: $transporter)';
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
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.origineZone, origineZone) ||
                other.origineZone == origineZone) &&
            (identical(other.destinationZone, destinationZone) ||
                other.destinationZone == destinationZone) &&
            (identical(other.pickupAddress, pickupAddress) ||
                other.pickupAddress == pickupAddress) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.prixDevis, prixDevis) ||
                other.prixDevis == prixDevis) &&
            (identical(other.prixFinal, prixFinal) ||
                other.prixFinal == prixFinal) &&
            (identical(other.quantiteKg, quantiteKg) ||
                other.quantiteKg == quantiteKg) &&
            (identical(other.photoPreuveUrl, photoPreuveUrl) ||
                other.photoPreuveUrl == photoPreuveUrl) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.pickupScannedAt, pickupScannedAt) ||
                other.pickupScannedAt == pickupScannedAt) &&
            (identical(other.commande, commande) ||
                other.commande == commande) &&
            (identical(other.transporter, transporter) ||
                other.transporter == transporter));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    commandeId,
    transporterId,
    status,
    vehicleType,
    origineZone,
    destinationZone,
    pickupAddress,
    deliveryAddress,
    prixDevis,
    prixFinal,
    quantiteKg,
    photoPreuveUrl,
    notes,
    scheduledAt,
    deliveredAt,
    createdAt,
    pickupScannedAt,
    commande,
    transporter,
  ]);

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

abstract class _Livraison extends Livraison {
  const factory _Livraison({
    required final String id,
    required final String commandeId,
    final String? transporterId,
    @JsonKey(unknownEnumValue: ShipmentStatus.unknown)
    final ShipmentStatus status,
    final String? vehicleType,
    @JsonKey(name: 'origin_zone') final String? origineZone,
    @JsonKey(name: 'destination_zone') final String? destinationZone,
    final String? pickupAddress,
    final String? deliveryAddress,
    @FlexDoubleN() final double? prixDevis,
    @FlexDoubleN() final double? prixFinal,
    @FlexDoubleN() final double? quantiteKg,
    final String? photoPreuveUrl,
    final String? notes,
    final DateTime? scheduledAt,
    final DateTime? deliveredAt,
    final DateTime? createdAt,
    final DateTime? pickupScannedAt,
    @JsonKey(
      name: 'commandes_vente',
      fromJson: _commandeApercuFromJson,
      toJson: _commandeApercuToJson,
    )
    final CommandeApercu? commande,
    @JsonKey(
      name: 'users',
      fromJson: _transporterApercuFromJson,
      toJson: _transporterApercuToJson,
    )
    final TransporterApercu? transporter,
  }) = _$LivraisonImpl;
  const _Livraison._() : super._();

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
  String? get vehicleType;
  @override
  @JsonKey(name: 'origin_zone')
  String? get origineZone;
  @override
  @JsonKey(name: 'destination_zone')
  String? get destinationZone;
  @override
  String? get pickupAddress;
  @override
  String? get deliveryAddress;
  @override
  @FlexDoubleN()
  double? get prixDevis;
  @override
  @FlexDoubleN()
  double? get prixFinal;
  @override
  @FlexDoubleN()
  double? get quantiteKg;
  @override
  String? get photoPreuveUrl;
  @override
  String? get notes;
  @override
  DateTime? get scheduledAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get pickupScannedAt;

  /// Champ joint `commandes_vente` quand le backend l'expose
  /// (notamment `GET /logistics/missions/available`).
  @override
  @JsonKey(
    name: 'commandes_vente',
    fromJson: _commandeApercuFromJson,
    toJson: _commandeApercuToJson,
  )
  CommandeApercu? get commande;

  /// Champ joint `users` (le transporteur assigné) quand le backend
  /// l'expose — notamment `GET /shipments/by-commande/:id`. Permet
  /// d'afficher nom + photo + rating sans appel supplémentaire.
  @override
  @JsonKey(
    name: 'users',
    fromJson: _transporterApercuFromJson,
    toJson: _transporterApercuToJson,
  )
  TransporterApercu? get transporter;

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
  @JsonKey(name: 'origin_zone')
  String get origineZone => throw _privateConstructorUsedError;
  @JsonKey(name: 'destination_zone')
  String get destinationZone => throw _privateConstructorUsedError;
  @FlexDouble()
  double get capaciteMaxKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get tarifKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get tarifMinimum => throw _privateConstructorUsedError;
  String? get delaiTypique => throw _privateConstructorUsedError;
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
    @JsonKey(name: 'origin_zone') String origineZone,
    @JsonKey(name: 'destination_zone') String destinationZone,
    @FlexDouble() double capaciteMaxKg,
    @FlexDouble() double tarifKg,
    @FlexDouble() double tarifMinimum,
    String? delaiTypique,
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
    Object? origineZone = null,
    Object? destinationZone = null,
    Object? capaciteMaxKg = null,
    Object? tarifKg = null,
    Object? tarifMinimum = null,
    Object? delaiTypique = freezed,
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
            origineZone: null == origineZone
                ? _value.origineZone
                : origineZone // ignore: cast_nullable_to_non_nullable
                      as String,
            destinationZone: null == destinationZone
                ? _value.destinationZone
                : destinationZone // ignore: cast_nullable_to_non_nullable
                      as String,
            capaciteMaxKg: null == capaciteMaxKg
                ? _value.capaciteMaxKg
                : capaciteMaxKg // ignore: cast_nullable_to_non_nullable
                      as double,
            tarifKg: null == tarifKg
                ? _value.tarifKg
                : tarifKg // ignore: cast_nullable_to_non_nullable
                      as double,
            tarifMinimum: null == tarifMinimum
                ? _value.tarifMinimum
                : tarifMinimum // ignore: cast_nullable_to_non_nullable
                      as double,
            delaiTypique: freezed == delaiTypique
                ? _value.delaiTypique
                : delaiTypique // ignore: cast_nullable_to_non_nullable
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
    @JsonKey(name: 'origin_zone') String origineZone,
    @JsonKey(name: 'destination_zone') String destinationZone,
    @FlexDouble() double capaciteMaxKg,
    @FlexDouble() double tarifKg,
    @FlexDouble() double tarifMinimum,
    String? delaiTypique,
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
    Object? origineZone = null,
    Object? destinationZone = null,
    Object? capaciteMaxKg = null,
    Object? tarifKg = null,
    Object? tarifMinimum = null,
    Object? delaiTypique = freezed,
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
        origineZone: null == origineZone
            ? _value.origineZone
            : origineZone // ignore: cast_nullable_to_non_nullable
                  as String,
        destinationZone: null == destinationZone
            ? _value.destinationZone
            : destinationZone // ignore: cast_nullable_to_non_nullable
                  as String,
        capaciteMaxKg: null == capaciteMaxKg
            ? _value.capaciteMaxKg
            : capaciteMaxKg // ignore: cast_nullable_to_non_nullable
                  as double,
        tarifKg: null == tarifKg
            ? _value.tarifKg
            : tarifKg // ignore: cast_nullable_to_non_nullable
                  as double,
        tarifMinimum: null == tarifMinimum
            ? _value.tarifMinimum
            : tarifMinimum // ignore: cast_nullable_to_non_nullable
                  as double,
        delaiTypique: freezed == delaiTypique
            ? _value.delaiTypique
            : delaiTypique // ignore: cast_nullable_to_non_nullable
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
class _$TransporterRouteImpl implements _TransporterRoute {
  const _$TransporterRouteImpl({
    required this.id,
    required this.transporterId,
    @JsonKey(name: 'origin_zone') required this.origineZone,
    @JsonKey(name: 'destination_zone') required this.destinationZone,
    @FlexDouble() required this.capaciteMaxKg,
    @FlexDouble() required this.tarifKg,
    @FlexDouble() this.tarifMinimum = 0,
    this.delaiTypique,
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
  @JsonKey(name: 'origin_zone')
  final String origineZone;
  @override
  @JsonKey(name: 'destination_zone')
  final String destinationZone;
  @override
  @FlexDouble()
  final double capaciteMaxKg;
  @override
  @FlexDouble()
  final double tarifKg;
  @override
  @JsonKey()
  @FlexDouble()
  final double tarifMinimum;
  @override
  final String? delaiTypique;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TransporterRoute(id: $id, transporterId: $transporterId, origineZone: $origineZone, destinationZone: $destinationZone, capaciteMaxKg: $capaciteMaxKg, tarifKg: $tarifKg, tarifMinimum: $tarifMinimum, delaiTypique: $delaiTypique, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransporterRouteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transporterId, transporterId) ||
                other.transporterId == transporterId) &&
            (identical(other.origineZone, origineZone) ||
                other.origineZone == origineZone) &&
            (identical(other.destinationZone, destinationZone) ||
                other.destinationZone == destinationZone) &&
            (identical(other.capaciteMaxKg, capaciteMaxKg) ||
                other.capaciteMaxKg == capaciteMaxKg) &&
            (identical(other.tarifKg, tarifKg) || other.tarifKg == tarifKg) &&
            (identical(other.tarifMinimum, tarifMinimum) ||
                other.tarifMinimum == tarifMinimum) &&
            (identical(other.delaiTypique, delaiTypique) ||
                other.delaiTypique == delaiTypique) &&
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
    origineZone,
    destinationZone,
    capaciteMaxKg,
    tarifKg,
    tarifMinimum,
    delaiTypique,
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
    @JsonKey(name: 'origin_zone') required final String origineZone,
    @JsonKey(name: 'destination_zone') required final String destinationZone,
    @FlexDouble() required final double capaciteMaxKg,
    @FlexDouble() required final double tarifKg,
    @FlexDouble() final double tarifMinimum,
    final String? delaiTypique,
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
  @JsonKey(name: 'origin_zone')
  String get origineZone;
  @override
  @JsonKey(name: 'destination_zone')
  String get destinationZone;
  @override
  @FlexDouble()
  double get capaciteMaxKg;
  @override
  @FlexDouble()
  double get tarifKg;
  @override
  @FlexDouble()
  double get tarifMinimum;
  @override
  String? get delaiTypique;
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

TransportQuote _$TransportQuoteFromJson(Map<String, dynamic> json) {
  return _TransportQuote.fromJson(json);
}

/// @nodoc
mixin _$TransportQuote {
  String get routeId => throw _privateConstructorUsedError;
  String get transporterId => throw _privateConstructorUsedError;
  String get transporterName => throw _privateConstructorUsedError;
  @FlexDouble()
  double get rating => throw _privateConstructorUsedError;
  @FlexDouble()
  double get tarifTotal => throw _privateConstructorUsedError;
  String? get delaiTypique => throw _privateConstructorUsedError;

  /// Serializes this TransportQuote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransportQuote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransportQuoteCopyWith<TransportQuote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransportQuoteCopyWith<$Res> {
  factory $TransportQuoteCopyWith(
    TransportQuote value,
    $Res Function(TransportQuote) then,
  ) = _$TransportQuoteCopyWithImpl<$Res, TransportQuote>;
  @useResult
  $Res call({
    String routeId,
    String transporterId,
    String transporterName,
    @FlexDouble() double rating,
    @FlexDouble() double tarifTotal,
    String? delaiTypique,
  });
}

/// @nodoc
class _$TransportQuoteCopyWithImpl<$Res, $Val extends TransportQuote>
    implements $TransportQuoteCopyWith<$Res> {
  _$TransportQuoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransportQuote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routeId = null,
    Object? transporterId = null,
    Object? transporterName = null,
    Object? rating = null,
    Object? tarifTotal = null,
    Object? delaiTypique = freezed,
  }) {
    return _then(
      _value.copyWith(
            routeId: null == routeId
                ? _value.routeId
                : routeId // ignore: cast_nullable_to_non_nullable
                      as String,
            transporterId: null == transporterId
                ? _value.transporterId
                : transporterId // ignore: cast_nullable_to_non_nullable
                      as String,
            transporterName: null == transporterName
                ? _value.transporterName
                : transporterName // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
            tarifTotal: null == tarifTotal
                ? _value.tarifTotal
                : tarifTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            delaiTypique: freezed == delaiTypique
                ? _value.delaiTypique
                : delaiTypique // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransportQuoteImplCopyWith<$Res>
    implements $TransportQuoteCopyWith<$Res> {
  factory _$$TransportQuoteImplCopyWith(
    _$TransportQuoteImpl value,
    $Res Function(_$TransportQuoteImpl) then,
  ) = __$$TransportQuoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String routeId,
    String transporterId,
    String transporterName,
    @FlexDouble() double rating,
    @FlexDouble() double tarifTotal,
    String? delaiTypique,
  });
}

/// @nodoc
class __$$TransportQuoteImplCopyWithImpl<$Res>
    extends _$TransportQuoteCopyWithImpl<$Res, _$TransportQuoteImpl>
    implements _$$TransportQuoteImplCopyWith<$Res> {
  __$$TransportQuoteImplCopyWithImpl(
    _$TransportQuoteImpl _value,
    $Res Function(_$TransportQuoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransportQuote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routeId = null,
    Object? transporterId = null,
    Object? transporterName = null,
    Object? rating = null,
    Object? tarifTotal = null,
    Object? delaiTypique = freezed,
  }) {
    return _then(
      _$TransportQuoteImpl(
        routeId: null == routeId
            ? _value.routeId
            : routeId // ignore: cast_nullable_to_non_nullable
                  as String,
        transporterId: null == transporterId
            ? _value.transporterId
            : transporterId // ignore: cast_nullable_to_non_nullable
                  as String,
        transporterName: null == transporterName
            ? _value.transporterName
            : transporterName // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
        tarifTotal: null == tarifTotal
            ? _value.tarifTotal
            : tarifTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        delaiTypique: freezed == delaiTypique
            ? _value.delaiTypique
            : delaiTypique // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TransportQuoteImpl implements _TransportQuote {
  const _$TransportQuoteImpl({
    required this.routeId,
    required this.transporterId,
    this.transporterName = '',
    @FlexDouble() this.rating = 0,
    @FlexDouble() required this.tarifTotal,
    this.delaiTypique,
  });

  factory _$TransportQuoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransportQuoteImplFromJson(json);

  @override
  final String routeId;
  @override
  final String transporterId;
  @override
  @JsonKey()
  final String transporterName;
  @override
  @JsonKey()
  @FlexDouble()
  final double rating;
  @override
  @FlexDouble()
  final double tarifTotal;
  @override
  final String? delaiTypique;

  @override
  String toString() {
    return 'TransportQuote(routeId: $routeId, transporterId: $transporterId, transporterName: $transporterName, rating: $rating, tarifTotal: $tarifTotal, delaiTypique: $delaiTypique)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransportQuoteImpl &&
            (identical(other.routeId, routeId) || other.routeId == routeId) &&
            (identical(other.transporterId, transporterId) ||
                other.transporterId == transporterId) &&
            (identical(other.transporterName, transporterName) ||
                other.transporterName == transporterName) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.tarifTotal, tarifTotal) ||
                other.tarifTotal == tarifTotal) &&
            (identical(other.delaiTypique, delaiTypique) ||
                other.delaiTypique == delaiTypique));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    routeId,
    transporterId,
    transporterName,
    rating,
    tarifTotal,
    delaiTypique,
  );

  /// Create a copy of TransportQuote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransportQuoteImplCopyWith<_$TransportQuoteImpl> get copyWith =>
      __$$TransportQuoteImplCopyWithImpl<_$TransportQuoteImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TransportQuoteImplToJson(this);
  }
}

abstract class _TransportQuote implements TransportQuote {
  const factory _TransportQuote({
    required final String routeId,
    required final String transporterId,
    final String transporterName,
    @FlexDouble() final double rating,
    @FlexDouble() required final double tarifTotal,
    final String? delaiTypique,
  }) = _$TransportQuoteImpl;

  factory _TransportQuote.fromJson(Map<String, dynamic> json) =
      _$TransportQuoteImpl.fromJson;

  @override
  String get routeId;
  @override
  String get transporterId;
  @override
  String get transporterName;
  @override
  @FlexDouble()
  double get rating;
  @override
  @FlexDouble()
  double get tarifTotal;
  @override
  String? get delaiTypique;

  /// Create a copy of TransportQuote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransportQuoteImplCopyWith<_$TransportQuoteImpl> get copyWith =>
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
  String? get note => throw _privateConstructorUsedError;
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
    String? note,
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
    Object? note = freezed,
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
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
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
    String? note,
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
    Object? note = freezed,
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
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
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
    this.note,
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
  final String? note;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TrackingEvent(id: $id, shipmentId: $shipmentId, location: $location, status: $status, note: $note, createdAt: $createdAt)';
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
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    shipmentId,
    location,
    status,
    note,
    createdAt,
  );

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
    final String? note,
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
  String? get note;
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
