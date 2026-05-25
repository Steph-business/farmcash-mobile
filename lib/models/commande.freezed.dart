// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commande.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Commande _$CommandeFromJson(Map<String, dynamic> json) {
  return _Commande.fromJson(json);
}

/// @nodoc
mixin _$Commande {
  String get id => throw _privateConstructorUsedError;
  String get reference => throw _privateConstructorUsedError;
  String get buyerId => throw _privateConstructorUsedError;
  String get sellerId => throw _privateConstructorUsedError;
  String get annonceId => throw _privateConstructorUsedError;

  /// Identifiant du lot physique livré (rempli quand le vendeur lie la
  /// commande à un lot tracé). Sert à charger la traçabilité publique
  /// `/ai/traceability/:lotId` côté acheteur.
  String? get lotId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get quantiteKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get prixUnitaireKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get montantTotal => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: OrderStatus.unknown)
  OrderStatus get status => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MobileProvider.unknown)
  MobileProvider? get paymentProvider => throw _privateConstructorUsedError;
  bool get escrowReleased => throw _privateConstructorUsedError;
  String? get livraisonAdresse => throw _privateConstructorUsedError;
  DateTime? get livraisonDate => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // ─── Champs joints (depuis getOrderById backend) ──────────────────
  // Le backend renvoie le buyer/seller via `include:` Prisma. On les
  // aplatit ici en fields plats lisibles directement par l'UI. `null`
  // si la jointure n'a pas été demandée (ex. ancien endpoint list).
  @JsonKey(readValue: _readBuyerName)
  String? get buyerName => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readBuyerPhoto)
  String? get buyerPhotoUrl => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readSellerName)
  String? get sellerName => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readSellerPhoto)
  String? get sellerPhotoUrl => throw _privateConstructorUsedError;

  /// Serializes this Commande to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Commande
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommandeCopyWith<Commande> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommandeCopyWith<$Res> {
  factory $CommandeCopyWith(Commande value, $Res Function(Commande) then) =
      _$CommandeCopyWithImpl<$Res, Commande>;
  @useResult
  $Res call({
    String id,
    String reference,
    String buyerId,
    String sellerId,
    String annonceId,
    String? lotId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixUnitaireKg,
    @FlexDouble() double montantTotal,
    @JsonKey(unknownEnumValue: OrderStatus.unknown) OrderStatus status,
    @JsonKey(unknownEnumValue: MobileProvider.unknown)
    MobileProvider? paymentProvider,
    bool escrowReleased,
    String? livraisonAdresse,
    DateTime? livraisonDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(readValue: _readBuyerName) String? buyerName,
    @JsonKey(readValue: _readBuyerPhoto) String? buyerPhotoUrl,
    @JsonKey(readValue: _readSellerName) String? sellerName,
    @JsonKey(readValue: _readSellerPhoto) String? sellerPhotoUrl,
  });
}

/// @nodoc
class _$CommandeCopyWithImpl<$Res, $Val extends Commande>
    implements $CommandeCopyWith<$Res> {
  _$CommandeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Commande
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = null,
    Object? buyerId = null,
    Object? sellerId = null,
    Object? annonceId = null,
    Object? lotId = freezed,
    Object? quantiteKg = null,
    Object? prixUnitaireKg = null,
    Object? montantTotal = null,
    Object? status = null,
    Object? paymentProvider = freezed,
    Object? escrowReleased = null,
    Object? livraisonAdresse = freezed,
    Object? livraisonDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? buyerName = freezed,
    Object? buyerPhotoUrl = freezed,
    Object? sellerName = freezed,
    Object? sellerPhotoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            reference: null == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as String,
            buyerId: null == buyerId
                ? _value.buyerId
                : buyerId // ignore: cast_nullable_to_non_nullable
                      as String,
            sellerId: null == sellerId
                ? _value.sellerId
                : sellerId // ignore: cast_nullable_to_non_nullable
                      as String,
            annonceId: null == annonceId
                ? _value.annonceId
                : annonceId // ignore: cast_nullable_to_non_nullable
                      as String,
            lotId: freezed == lotId
                ? _value.lotId
                : lotId // ignore: cast_nullable_to_non_nullable
                      as String?,
            quantiteKg: null == quantiteKg
                ? _value.quantiteKg
                : quantiteKg // ignore: cast_nullable_to_non_nullable
                      as double,
            prixUnitaireKg: null == prixUnitaireKg
                ? _value.prixUnitaireKg
                : prixUnitaireKg // ignore: cast_nullable_to_non_nullable
                      as double,
            montantTotal: null == montantTotal
                ? _value.montantTotal
                : montantTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OrderStatus,
            paymentProvider: freezed == paymentProvider
                ? _value.paymentProvider
                : paymentProvider // ignore: cast_nullable_to_non_nullable
                      as MobileProvider?,
            escrowReleased: null == escrowReleased
                ? _value.escrowReleased
                : escrowReleased // ignore: cast_nullable_to_non_nullable
                      as bool,
            livraisonAdresse: freezed == livraisonAdresse
                ? _value.livraisonAdresse
                : livraisonAdresse // ignore: cast_nullable_to_non_nullable
                      as String?,
            livraisonDate: freezed == livraisonDate
                ? _value.livraisonDate
                : livraisonDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            buyerName: freezed == buyerName
                ? _value.buyerName
                : buyerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            buyerPhotoUrl: freezed == buyerPhotoUrl
                ? _value.buyerPhotoUrl
                : buyerPhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            sellerName: freezed == sellerName
                ? _value.sellerName
                : sellerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            sellerPhotoUrl: freezed == sellerPhotoUrl
                ? _value.sellerPhotoUrl
                : sellerPhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommandeImplCopyWith<$Res>
    implements $CommandeCopyWith<$Res> {
  factory _$$CommandeImplCopyWith(
    _$CommandeImpl value,
    $Res Function(_$CommandeImpl) then,
  ) = __$$CommandeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String reference,
    String buyerId,
    String sellerId,
    String annonceId,
    String? lotId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixUnitaireKg,
    @FlexDouble() double montantTotal,
    @JsonKey(unknownEnumValue: OrderStatus.unknown) OrderStatus status,
    @JsonKey(unknownEnumValue: MobileProvider.unknown)
    MobileProvider? paymentProvider,
    bool escrowReleased,
    String? livraisonAdresse,
    DateTime? livraisonDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(readValue: _readBuyerName) String? buyerName,
    @JsonKey(readValue: _readBuyerPhoto) String? buyerPhotoUrl,
    @JsonKey(readValue: _readSellerName) String? sellerName,
    @JsonKey(readValue: _readSellerPhoto) String? sellerPhotoUrl,
  });
}

/// @nodoc
class __$$CommandeImplCopyWithImpl<$Res>
    extends _$CommandeCopyWithImpl<$Res, _$CommandeImpl>
    implements _$$CommandeImplCopyWith<$Res> {
  __$$CommandeImplCopyWithImpl(
    _$CommandeImpl _value,
    $Res Function(_$CommandeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Commande
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = null,
    Object? buyerId = null,
    Object? sellerId = null,
    Object? annonceId = null,
    Object? lotId = freezed,
    Object? quantiteKg = null,
    Object? prixUnitaireKg = null,
    Object? montantTotal = null,
    Object? status = null,
    Object? paymentProvider = freezed,
    Object? escrowReleased = null,
    Object? livraisonAdresse = freezed,
    Object? livraisonDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? buyerName = freezed,
    Object? buyerPhotoUrl = freezed,
    Object? sellerName = freezed,
    Object? sellerPhotoUrl = freezed,
  }) {
    return _then(
      _$CommandeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        reference: null == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String,
        buyerId: null == buyerId
            ? _value.buyerId
            : buyerId // ignore: cast_nullable_to_non_nullable
                  as String,
        sellerId: null == sellerId
            ? _value.sellerId
            : sellerId // ignore: cast_nullable_to_non_nullable
                  as String,
        annonceId: null == annonceId
            ? _value.annonceId
            : annonceId // ignore: cast_nullable_to_non_nullable
                  as String,
        lotId: freezed == lotId
            ? _value.lotId
            : lotId // ignore: cast_nullable_to_non_nullable
                  as String?,
        quantiteKg: null == quantiteKg
            ? _value.quantiteKg
            : quantiteKg // ignore: cast_nullable_to_non_nullable
                  as double,
        prixUnitaireKg: null == prixUnitaireKg
            ? _value.prixUnitaireKg
            : prixUnitaireKg // ignore: cast_nullable_to_non_nullable
                  as double,
        montantTotal: null == montantTotal
            ? _value.montantTotal
            : montantTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OrderStatus,
        paymentProvider: freezed == paymentProvider
            ? _value.paymentProvider
            : paymentProvider // ignore: cast_nullable_to_non_nullable
                  as MobileProvider?,
        escrowReleased: null == escrowReleased
            ? _value.escrowReleased
            : escrowReleased // ignore: cast_nullable_to_non_nullable
                  as bool,
        livraisonAdresse: freezed == livraisonAdresse
            ? _value.livraisonAdresse
            : livraisonAdresse // ignore: cast_nullable_to_non_nullable
                  as String?,
        livraisonDate: freezed == livraisonDate
            ? _value.livraisonDate
            : livraisonDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        buyerName: freezed == buyerName
            ? _value.buyerName
            : buyerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        buyerPhotoUrl: freezed == buyerPhotoUrl
            ? _value.buyerPhotoUrl
            : buyerPhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        sellerName: freezed == sellerName
            ? _value.sellerName
            : sellerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        sellerPhotoUrl: freezed == sellerPhotoUrl
            ? _value.sellerPhotoUrl
            : sellerPhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommandeImpl implements _Commande {
  const _$CommandeImpl({
    required this.id,
    this.reference = '',
    required this.buyerId,
    required this.sellerId,
    required this.annonceId,
    this.lotId,
    @FlexDouble() required this.quantiteKg,
    @FlexDouble() required this.prixUnitaireKg,
    @FlexDouble() required this.montantTotal,
    @JsonKey(unknownEnumValue: OrderStatus.unknown)
    this.status = OrderStatus.unknown,
    @JsonKey(unknownEnumValue: MobileProvider.unknown) this.paymentProvider,
    this.escrowReleased = false,
    this.livraisonAdresse,
    this.livraisonDate,
    this.createdAt,
    this.updatedAt,
    @JsonKey(readValue: _readBuyerName) this.buyerName,
    @JsonKey(readValue: _readBuyerPhoto) this.buyerPhotoUrl,
    @JsonKey(readValue: _readSellerName) this.sellerName,
    @JsonKey(readValue: _readSellerPhoto) this.sellerPhotoUrl,
  });

  factory _$CommandeImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommandeImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String reference;
  @override
  final String buyerId;
  @override
  final String sellerId;
  @override
  final String annonceId;

  /// Identifiant du lot physique livré (rempli quand le vendeur lie la
  /// commande à un lot tracé). Sert à charger la traçabilité publique
  /// `/ai/traceability/:lotId` côté acheteur.
  @override
  final String? lotId;
  @override
  @FlexDouble()
  final double quantiteKg;
  @override
  @FlexDouble()
  final double prixUnitaireKg;
  @override
  @FlexDouble()
  final double montantTotal;
  @override
  @JsonKey(unknownEnumValue: OrderStatus.unknown)
  final OrderStatus status;
  @override
  @JsonKey(unknownEnumValue: MobileProvider.unknown)
  final MobileProvider? paymentProvider;
  @override
  @JsonKey()
  final bool escrowReleased;
  @override
  final String? livraisonAdresse;
  @override
  final DateTime? livraisonDate;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  // ─── Champs joints (depuis getOrderById backend) ──────────────────
  // Le backend renvoie le buyer/seller via `include:` Prisma. On les
  // aplatit ici en fields plats lisibles directement par l'UI. `null`
  // si la jointure n'a pas été demandée (ex. ancien endpoint list).
  @override
  @JsonKey(readValue: _readBuyerName)
  final String? buyerName;
  @override
  @JsonKey(readValue: _readBuyerPhoto)
  final String? buyerPhotoUrl;
  @override
  @JsonKey(readValue: _readSellerName)
  final String? sellerName;
  @override
  @JsonKey(readValue: _readSellerPhoto)
  final String? sellerPhotoUrl;

  @override
  String toString() {
    return 'Commande(id: $id, reference: $reference, buyerId: $buyerId, sellerId: $sellerId, annonceId: $annonceId, lotId: $lotId, quantiteKg: $quantiteKg, prixUnitaireKg: $prixUnitaireKg, montantTotal: $montantTotal, status: $status, paymentProvider: $paymentProvider, escrowReleased: $escrowReleased, livraisonAdresse: $livraisonAdresse, livraisonDate: $livraisonDate, createdAt: $createdAt, updatedAt: $updatedAt, buyerName: $buyerName, buyerPhotoUrl: $buyerPhotoUrl, sellerName: $sellerName, sellerPhotoUrl: $sellerPhotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommandeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.buyerId, buyerId) || other.buyerId == buyerId) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.annonceId, annonceId) ||
                other.annonceId == annonceId) &&
            (identical(other.lotId, lotId) || other.lotId == lotId) &&
            (identical(other.quantiteKg, quantiteKg) ||
                other.quantiteKg == quantiteKg) &&
            (identical(other.prixUnitaireKg, prixUnitaireKg) ||
                other.prixUnitaireKg == prixUnitaireKg) &&
            (identical(other.montantTotal, montantTotal) ||
                other.montantTotal == montantTotal) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentProvider, paymentProvider) ||
                other.paymentProvider == paymentProvider) &&
            (identical(other.escrowReleased, escrowReleased) ||
                other.escrowReleased == escrowReleased) &&
            (identical(other.livraisonAdresse, livraisonAdresse) ||
                other.livraisonAdresse == livraisonAdresse) &&
            (identical(other.livraisonDate, livraisonDate) ||
                other.livraisonDate == livraisonDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.buyerName, buyerName) ||
                other.buyerName == buyerName) &&
            (identical(other.buyerPhotoUrl, buyerPhotoUrl) ||
                other.buyerPhotoUrl == buyerPhotoUrl) &&
            (identical(other.sellerName, sellerName) ||
                other.sellerName == sellerName) &&
            (identical(other.sellerPhotoUrl, sellerPhotoUrl) ||
                other.sellerPhotoUrl == sellerPhotoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    reference,
    buyerId,
    sellerId,
    annonceId,
    lotId,
    quantiteKg,
    prixUnitaireKg,
    montantTotal,
    status,
    paymentProvider,
    escrowReleased,
    livraisonAdresse,
    livraisonDate,
    createdAt,
    updatedAt,
    buyerName,
    buyerPhotoUrl,
    sellerName,
    sellerPhotoUrl,
  ]);

  /// Create a copy of Commande
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommandeImplCopyWith<_$CommandeImpl> get copyWith =>
      __$$CommandeImplCopyWithImpl<_$CommandeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommandeImplToJson(this);
  }
}

abstract class _Commande implements Commande {
  const factory _Commande({
    required final String id,
    final String reference,
    required final String buyerId,
    required final String sellerId,
    required final String annonceId,
    final String? lotId,
    @FlexDouble() required final double quantiteKg,
    @FlexDouble() required final double prixUnitaireKg,
    @FlexDouble() required final double montantTotal,
    @JsonKey(unknownEnumValue: OrderStatus.unknown) final OrderStatus status,
    @JsonKey(unknownEnumValue: MobileProvider.unknown)
    final MobileProvider? paymentProvider,
    final bool escrowReleased,
    final String? livraisonAdresse,
    final DateTime? livraisonDate,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    @JsonKey(readValue: _readBuyerName) final String? buyerName,
    @JsonKey(readValue: _readBuyerPhoto) final String? buyerPhotoUrl,
    @JsonKey(readValue: _readSellerName) final String? sellerName,
    @JsonKey(readValue: _readSellerPhoto) final String? sellerPhotoUrl,
  }) = _$CommandeImpl;

  factory _Commande.fromJson(Map<String, dynamic> json) =
      _$CommandeImpl.fromJson;

  @override
  String get id;
  @override
  String get reference;
  @override
  String get buyerId;
  @override
  String get sellerId;
  @override
  String get annonceId;

  /// Identifiant du lot physique livré (rempli quand le vendeur lie la
  /// commande à un lot tracé). Sert à charger la traçabilité publique
  /// `/ai/traceability/:lotId` côté acheteur.
  @override
  String? get lotId;
  @override
  @FlexDouble()
  double get quantiteKg;
  @override
  @FlexDouble()
  double get prixUnitaireKg;
  @override
  @FlexDouble()
  double get montantTotal;
  @override
  @JsonKey(unknownEnumValue: OrderStatus.unknown)
  OrderStatus get status;
  @override
  @JsonKey(unknownEnumValue: MobileProvider.unknown)
  MobileProvider? get paymentProvider;
  @override
  bool get escrowReleased;
  @override
  String? get livraisonAdresse;
  @override
  DateTime? get livraisonDate;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // ─── Champs joints (depuis getOrderById backend) ──────────────────
  // Le backend renvoie le buyer/seller via `include:` Prisma. On les
  // aplatit ici en fields plats lisibles directement par l'UI. `null`
  // si la jointure n'a pas été demandée (ex. ancien endpoint list).
  @override
  @JsonKey(readValue: _readBuyerName)
  String? get buyerName;
  @override
  @JsonKey(readValue: _readBuyerPhoto)
  String? get buyerPhotoUrl;
  @override
  @JsonKey(readValue: _readSellerName)
  String? get sellerName;
  @override
  @JsonKey(readValue: _readSellerPhoto)
  String? get sellerPhotoUrl;

  /// Create a copy of Commande
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommandeImplCopyWith<_$CommandeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Dispute _$DisputeFromJson(Map<String, dynamic> json) {
  return _Dispute.fromJson(json);
}

/// @nodoc
mixin _$Dispute {
  String get id => throw _privateConstructorUsedError;
  String get commandeId => throw _privateConstructorUsedError;
  String get openedById => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get motif => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get resolution => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;

  /// Serializes this Dispute to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DisputeCopyWith<Dispute> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisputeCopyWith<$Res> {
  factory $DisputeCopyWith(Dispute value, $Res Function(Dispute) then) =
      _$DisputeCopyWithImpl<$Res, Dispute>;
  @useResult
  $Res call({
    String id,
    String commandeId,
    String openedById,
    String status,
    String? motif,
    String? description,
    String? resolution,
    DateTime? createdAt,
    DateTime? resolvedAt,
  });
}

/// @nodoc
class _$DisputeCopyWithImpl<$Res, $Val extends Dispute>
    implements $DisputeCopyWith<$Res> {
  _$DisputeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? commandeId = null,
    Object? openedById = null,
    Object? status = null,
    Object? motif = freezed,
    Object? description = freezed,
    Object? resolution = freezed,
    Object? createdAt = freezed,
    Object? resolvedAt = freezed,
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
            openedById: null == openedById
                ? _value.openedById
                : openedById // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            motif: freezed == motif
                ? _value.motif
                : motif // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolution: freezed == resolution
                ? _value.resolution
                : resolution // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            resolvedAt: freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DisputeImplCopyWith<$Res> implements $DisputeCopyWith<$Res> {
  factory _$$DisputeImplCopyWith(
    _$DisputeImpl value,
    $Res Function(_$DisputeImpl) then,
  ) = __$$DisputeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String commandeId,
    String openedById,
    String status,
    String? motif,
    String? description,
    String? resolution,
    DateTime? createdAt,
    DateTime? resolvedAt,
  });
}

/// @nodoc
class __$$DisputeImplCopyWithImpl<$Res>
    extends _$DisputeCopyWithImpl<$Res, _$DisputeImpl>
    implements _$$DisputeImplCopyWith<$Res> {
  __$$DisputeImplCopyWithImpl(
    _$DisputeImpl _value,
    $Res Function(_$DisputeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? commandeId = null,
    Object? openedById = null,
    Object? status = null,
    Object? motif = freezed,
    Object? description = freezed,
    Object? resolution = freezed,
    Object? createdAt = freezed,
    Object? resolvedAt = freezed,
  }) {
    return _then(
      _$DisputeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        commandeId: null == commandeId
            ? _value.commandeId
            : commandeId // ignore: cast_nullable_to_non_nullable
                  as String,
        openedById: null == openedById
            ? _value.openedById
            : openedById // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        motif: freezed == motif
            ? _value.motif
            : motif // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolution: freezed == resolution
            ? _value.resolution
            : resolution // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        resolvedAt: freezed == resolvedAt
            ? _value.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DisputeImpl implements _Dispute {
  const _$DisputeImpl({
    required this.id,
    required this.commandeId,
    required this.openedById,
    this.status = 'OPEN',
    this.motif,
    this.description,
    this.resolution,
    this.createdAt,
    this.resolvedAt,
  });

  factory _$DisputeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DisputeImplFromJson(json);

  @override
  final String id;
  @override
  final String commandeId;
  @override
  final String openedById;
  @override
  @JsonKey()
  final String status;
  @override
  final String? motif;
  @override
  final String? description;
  @override
  final String? resolution;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? resolvedAt;

  @override
  String toString() {
    return 'Dispute(id: $id, commandeId: $commandeId, openedById: $openedById, status: $status, motif: $motif, description: $description, resolution: $resolution, createdAt: $createdAt, resolvedAt: $resolvedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisputeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.commandeId, commandeId) ||
                other.commandeId == commandeId) &&
            (identical(other.openedById, openedById) ||
                other.openedById == openedById) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.motif, motif) || other.motif == motif) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    commandeId,
    openedById,
    status,
    motif,
    description,
    resolution,
    createdAt,
    resolvedAt,
  );

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisputeImplCopyWith<_$DisputeImpl> get copyWith =>
      __$$DisputeImplCopyWithImpl<_$DisputeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisputeImplToJson(this);
  }
}

abstract class _Dispute implements Dispute {
  const factory _Dispute({
    required final String id,
    required final String commandeId,
    required final String openedById,
    final String status,
    final String? motif,
    final String? description,
    final String? resolution,
    final DateTime? createdAt,
    final DateTime? resolvedAt,
  }) = _$DisputeImpl;

  factory _Dispute.fromJson(Map<String, dynamic> json) = _$DisputeImpl.fromJson;

  @override
  String get id;
  @override
  String get commandeId;
  @override
  String get openedById;
  @override
  String get status;
  @override
  String? get motif;
  @override
  String? get description;
  @override
  String? get resolution;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get resolvedAt;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisputeImplCopyWith<_$DisputeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
