// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'annonce_vente.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnnonceVente _$AnnonceVenteFromJson(Map<String, dynamic> json) {
  return _AnnonceVente.fromJson(json);
}

/// @nodoc
mixin _$AnnonceVente {
  String get id => throw _privateConstructorUsedError;
  String get farmerId => throw _privateConstructorUsedError;
  String get produitId => throw _privateConstructorUsedError;
  String get titre => throw _privateConstructorUsedError;
  @FlexDouble()
  double get quantiteKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get prixParKg => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get quantiteMinKg => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ProductQuality.unknown)
  ProductQuality get qualite => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<String> get certifications => throw _privateConstructorUsedError;
  String? get regionId => throw _privateConstructorUsedError;
  String? get villeId => throw _privateConstructorUsedError;
  String? get adresseDetail => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ProductStatus.unknown)
  ProductStatus get status => throw _privateConstructorUsedError;
  @FlexInt()
  int get viewsCount => throw _privateConstructorUsedError;
  String? get assignedToCooperativeId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: CoopAnnonceStatus.unknown)
  CoopAnnonceStatus? get coopStatus => throw _privateConstructorUsedError;

  /// Motif renseigné par la coopérative quand elle a refusé cette
  /// annonce (`coopStatus == REJECTED`). Renvoyé tel quel par Prisma
  /// dans la colonne `rejected_reason` — d'où le `@JsonKey(name:...)`.
  /// Affiché au producteur dans une bannière rouge soft pour qu'il
  /// sache quoi corriger avant de re-publier.
  @JsonKey(name: 'rejected_reason')
  String? get rejectedReason => throw _privateConstructorUsedError;

  /// Le backend renvoie les photos dans la table `medias` jointe :
  /// `medias: [{url, thumbnail_url}]`. On extrait l'URL utilisable et on
  /// retombe sur un `photos: [...]` plat utilisé par les widgets.
  /// Le `toJson` réémet `medias: [{url}]` pour rester symétrique côté API.
  @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
  List<String> get photos => throw _privateConstructorUsedError;
  DateTime? get disponibleJusqu => throw _privateConstructorUsedError;

  /// Date à laquelle le produit a été récolté — info de fraîcheur affichée
  /// aux acheteurs. Distincte de `disponibleJusqu` (durée de validité de
  /// l'offre côté producteur). Optionnelle.
  DateTime? get dateRecolte => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // ─── Champs joints (relations Prisma) ──────────────────────────────
  @JsonKey(name: 'produits_agricoles', fromJson: _nomFromMap, toJson: _nomToMap)
  String? get produitNom => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'users',
    fromJson: _vendeurInfoFromJson,
    toJson: _vendeurInfoToJson,
  )
  VendeurApercu? get vendeur => throw _privateConstructorUsedError;
  @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
  String? get regionNom => throw _privateConstructorUsedError;
  @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
  String? get villeNom => throw _privateConstructorUsedError;

  /// Traitements appliqués à la culture (relation jointe par le backend
  /// via `include: { annonce_vente_traitements: { include: { produits_traitement } } }`).
  /// Permet d'exposer la traçabilité "from-farm-to-fork" : type, dosage,
  /// date d'application, délai de carence. Vide si le producteur n'a
  /// rien déclaré.
  @JsonKey(
    name: 'annonce_vente_traitements',
    fromJson: _traitementsFromJson,
    toJson: _traitementsToJson,
  )
  List<AnnonceTraitement> get traitements => throw _privateConstructorUsedError;

  /// Serializes this AnnonceVente to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnnonceVente
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnnonceVenteCopyWith<AnnonceVente> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnnonceVenteCopyWith<$Res> {
  factory $AnnonceVenteCopyWith(
    AnnonceVente value,
    $Res Function(AnnonceVente) then,
  ) = _$AnnonceVenteCopyWithImpl<$Res, AnnonceVente>;
  @useResult
  $Res call({
    String id,
    String farmerId,
    String produitId,
    String titre,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixParKg,
    @FlexDoubleN() double? quantiteMinKg,
    @JsonKey(unknownEnumValue: ProductQuality.unknown) ProductQuality qualite,
    String? description,
    List<String> certifications,
    String? regionId,
    String? villeId,
    String? adresseDetail,
    @JsonKey(unknownEnumValue: ProductStatus.unknown) ProductStatus status,
    @FlexInt() int viewsCount,
    String? assignedToCooperativeId,
    @JsonKey(unknownEnumValue: CoopAnnonceStatus.unknown)
    CoopAnnonceStatus? coopStatus,
    @JsonKey(name: 'rejected_reason') String? rejectedReason,
    @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
    List<String> photos,
    DateTime? disponibleJusqu,
    DateTime? dateRecolte,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(
      name: 'produits_agricoles',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    String? produitNom,
    @JsonKey(
      name: 'users',
      fromJson: _vendeurInfoFromJson,
      toJson: _vendeurInfoToJson,
    )
    VendeurApercu? vendeur,
    @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    String? regionNom,
    @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    String? villeNom,
    @JsonKey(
      name: 'annonce_vente_traitements',
      fromJson: _traitementsFromJson,
      toJson: _traitementsToJson,
    )
    List<AnnonceTraitement> traitements,
  });
}

/// @nodoc
class _$AnnonceVenteCopyWithImpl<$Res, $Val extends AnnonceVente>
    implements $AnnonceVenteCopyWith<$Res> {
  _$AnnonceVenteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnnonceVente
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? farmerId = null,
    Object? produitId = null,
    Object? titre = null,
    Object? quantiteKg = null,
    Object? prixParKg = null,
    Object? quantiteMinKg = freezed,
    Object? qualite = null,
    Object? description = freezed,
    Object? certifications = null,
    Object? regionId = freezed,
    Object? villeId = freezed,
    Object? adresseDetail = freezed,
    Object? status = null,
    Object? viewsCount = null,
    Object? assignedToCooperativeId = freezed,
    Object? coopStatus = freezed,
    Object? rejectedReason = freezed,
    Object? photos = null,
    Object? disponibleJusqu = freezed,
    Object? dateRecolte = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? produitNom = freezed,
    Object? vendeur = freezed,
    Object? regionNom = freezed,
    Object? villeNom = freezed,
    Object? traitements = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            farmerId: null == farmerId
                ? _value.farmerId
                : farmerId // ignore: cast_nullable_to_non_nullable
                      as String,
            produitId: null == produitId
                ? _value.produitId
                : produitId // ignore: cast_nullable_to_non_nullable
                      as String,
            titre: null == titre
                ? _value.titre
                : titre // ignore: cast_nullable_to_non_nullable
                      as String,
            quantiteKg: null == quantiteKg
                ? _value.quantiteKg
                : quantiteKg // ignore: cast_nullable_to_non_nullable
                      as double,
            prixParKg: null == prixParKg
                ? _value.prixParKg
                : prixParKg // ignore: cast_nullable_to_non_nullable
                      as double,
            quantiteMinKg: freezed == quantiteMinKg
                ? _value.quantiteMinKg
                : quantiteMinKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            qualite: null == qualite
                ? _value.qualite
                : qualite // ignore: cast_nullable_to_non_nullable
                      as ProductQuality,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            certifications: null == certifications
                ? _value.certifications
                : certifications // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            regionId: freezed == regionId
                ? _value.regionId
                : regionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            villeId: freezed == villeId
                ? _value.villeId
                : villeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            adresseDetail: freezed == adresseDetail
                ? _value.adresseDetail
                : adresseDetail // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ProductStatus,
            viewsCount: null == viewsCount
                ? _value.viewsCount
                : viewsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            assignedToCooperativeId: freezed == assignedToCooperativeId
                ? _value.assignedToCooperativeId
                : assignedToCooperativeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            coopStatus: freezed == coopStatus
                ? _value.coopStatus
                : coopStatus // ignore: cast_nullable_to_non_nullable
                      as CoopAnnonceStatus?,
            rejectedReason: freezed == rejectedReason
                ? _value.rejectedReason
                : rejectedReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            photos: null == photos
                ? _value.photos
                : photos // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            disponibleJusqu: freezed == disponibleJusqu
                ? _value.disponibleJusqu
                : disponibleJusqu // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dateRecolte: freezed == dateRecolte
                ? _value.dateRecolte
                : dateRecolte // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            produitNom: freezed == produitNom
                ? _value.produitNom
                : produitNom // ignore: cast_nullable_to_non_nullable
                      as String?,
            vendeur: freezed == vendeur
                ? _value.vendeur
                : vendeur // ignore: cast_nullable_to_non_nullable
                      as VendeurApercu?,
            regionNom: freezed == regionNom
                ? _value.regionNom
                : regionNom // ignore: cast_nullable_to_non_nullable
                      as String?,
            villeNom: freezed == villeNom
                ? _value.villeNom
                : villeNom // ignore: cast_nullable_to_non_nullable
                      as String?,
            traitements: null == traitements
                ? _value.traitements
                : traitements // ignore: cast_nullable_to_non_nullable
                      as List<AnnonceTraitement>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnnonceVenteImplCopyWith<$Res>
    implements $AnnonceVenteCopyWith<$Res> {
  factory _$$AnnonceVenteImplCopyWith(
    _$AnnonceVenteImpl value,
    $Res Function(_$AnnonceVenteImpl) then,
  ) = __$$AnnonceVenteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String farmerId,
    String produitId,
    String titre,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixParKg,
    @FlexDoubleN() double? quantiteMinKg,
    @JsonKey(unknownEnumValue: ProductQuality.unknown) ProductQuality qualite,
    String? description,
    List<String> certifications,
    String? regionId,
    String? villeId,
    String? adresseDetail,
    @JsonKey(unknownEnumValue: ProductStatus.unknown) ProductStatus status,
    @FlexInt() int viewsCount,
    String? assignedToCooperativeId,
    @JsonKey(unknownEnumValue: CoopAnnonceStatus.unknown)
    CoopAnnonceStatus? coopStatus,
    @JsonKey(name: 'rejected_reason') String? rejectedReason,
    @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
    List<String> photos,
    DateTime? disponibleJusqu,
    DateTime? dateRecolte,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(
      name: 'produits_agricoles',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    String? produitNom,
    @JsonKey(
      name: 'users',
      fromJson: _vendeurInfoFromJson,
      toJson: _vendeurInfoToJson,
    )
    VendeurApercu? vendeur,
    @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    String? regionNom,
    @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    String? villeNom,
    @JsonKey(
      name: 'annonce_vente_traitements',
      fromJson: _traitementsFromJson,
      toJson: _traitementsToJson,
    )
    List<AnnonceTraitement> traitements,
  });
}

/// @nodoc
class __$$AnnonceVenteImplCopyWithImpl<$Res>
    extends _$AnnonceVenteCopyWithImpl<$Res, _$AnnonceVenteImpl>
    implements _$$AnnonceVenteImplCopyWith<$Res> {
  __$$AnnonceVenteImplCopyWithImpl(
    _$AnnonceVenteImpl _value,
    $Res Function(_$AnnonceVenteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnnonceVente
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? farmerId = null,
    Object? produitId = null,
    Object? titre = null,
    Object? quantiteKg = null,
    Object? prixParKg = null,
    Object? quantiteMinKg = freezed,
    Object? qualite = null,
    Object? description = freezed,
    Object? certifications = null,
    Object? regionId = freezed,
    Object? villeId = freezed,
    Object? adresseDetail = freezed,
    Object? status = null,
    Object? viewsCount = null,
    Object? assignedToCooperativeId = freezed,
    Object? coopStatus = freezed,
    Object? rejectedReason = freezed,
    Object? photos = null,
    Object? disponibleJusqu = freezed,
    Object? dateRecolte = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? produitNom = freezed,
    Object? vendeur = freezed,
    Object? regionNom = freezed,
    Object? villeNom = freezed,
    Object? traitements = null,
  }) {
    return _then(
      _$AnnonceVenteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        farmerId: null == farmerId
            ? _value.farmerId
            : farmerId // ignore: cast_nullable_to_non_nullable
                  as String,
        produitId: null == produitId
            ? _value.produitId
            : produitId // ignore: cast_nullable_to_non_nullable
                  as String,
        titre: null == titre
            ? _value.titre
            : titre // ignore: cast_nullable_to_non_nullable
                  as String,
        quantiteKg: null == quantiteKg
            ? _value.quantiteKg
            : quantiteKg // ignore: cast_nullable_to_non_nullable
                  as double,
        prixParKg: null == prixParKg
            ? _value.prixParKg
            : prixParKg // ignore: cast_nullable_to_non_nullable
                  as double,
        quantiteMinKg: freezed == quantiteMinKg
            ? _value.quantiteMinKg
            : quantiteMinKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        qualite: null == qualite
            ? _value.qualite
            : qualite // ignore: cast_nullable_to_non_nullable
                  as ProductQuality,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        certifications: null == certifications
            ? _value._certifications
            : certifications // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        regionId: freezed == regionId
            ? _value.regionId
            : regionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        villeId: freezed == villeId
            ? _value.villeId
            : villeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        adresseDetail: freezed == adresseDetail
            ? _value.adresseDetail
            : adresseDetail // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ProductStatus,
        viewsCount: null == viewsCount
            ? _value.viewsCount
            : viewsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        assignedToCooperativeId: freezed == assignedToCooperativeId
            ? _value.assignedToCooperativeId
            : assignedToCooperativeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        coopStatus: freezed == coopStatus
            ? _value.coopStatus
            : coopStatus // ignore: cast_nullable_to_non_nullable
                  as CoopAnnonceStatus?,
        rejectedReason: freezed == rejectedReason
            ? _value.rejectedReason
            : rejectedReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        photos: null == photos
            ? _value._photos
            : photos // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        disponibleJusqu: freezed == disponibleJusqu
            ? _value.disponibleJusqu
            : disponibleJusqu // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dateRecolte: freezed == dateRecolte
            ? _value.dateRecolte
            : dateRecolte // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        produitNom: freezed == produitNom
            ? _value.produitNom
            : produitNom // ignore: cast_nullable_to_non_nullable
                  as String?,
        vendeur: freezed == vendeur
            ? _value.vendeur
            : vendeur // ignore: cast_nullable_to_non_nullable
                  as VendeurApercu?,
        regionNom: freezed == regionNom
            ? _value.regionNom
            : regionNom // ignore: cast_nullable_to_non_nullable
                  as String?,
        villeNom: freezed == villeNom
            ? _value.villeNom
            : villeNom // ignore: cast_nullable_to_non_nullable
                  as String?,
        traitements: null == traitements
            ? _value._traitements
            : traitements // ignore: cast_nullable_to_non_nullable
                  as List<AnnonceTraitement>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnnonceVenteImpl extends _AnnonceVente {
  const _$AnnonceVenteImpl({
    required this.id,
    required this.farmerId,
    required this.produitId,
    required this.titre,
    @FlexDouble() required this.quantiteKg,
    @FlexDouble() required this.prixParKg,
    @FlexDoubleN() this.quantiteMinKg,
    @JsonKey(unknownEnumValue: ProductQuality.unknown)
    this.qualite = ProductQuality.unknown,
    this.description,
    final List<String> certifications = const <String>[],
    this.regionId,
    this.villeId,
    this.adresseDetail,
    @JsonKey(unknownEnumValue: ProductStatus.unknown)
    this.status = ProductStatus.unknown,
    @FlexInt() this.viewsCount = 0,
    this.assignedToCooperativeId,
    @JsonKey(unknownEnumValue: CoopAnnonceStatus.unknown) this.coopStatus,
    @JsonKey(name: 'rejected_reason') this.rejectedReason,
    @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
    final List<String> photos = const <String>[],
    this.disponibleJusqu,
    this.dateRecolte,
    this.createdAt,
    this.updatedAt,
    @JsonKey(
      name: 'produits_agricoles',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    this.produitNom,
    @JsonKey(
      name: 'users',
      fromJson: _vendeurInfoFromJson,
      toJson: _vendeurInfoToJson,
    )
    this.vendeur,
    @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    this.regionNom,
    @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    this.villeNom,
    @JsonKey(
      name: 'annonce_vente_traitements',
      fromJson: _traitementsFromJson,
      toJson: _traitementsToJson,
    )
    final List<AnnonceTraitement> traitements = const <AnnonceTraitement>[],
  }) : _certifications = certifications,
       _photos = photos,
       _traitements = traitements,
       super._();

  factory _$AnnonceVenteImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnnonceVenteImplFromJson(json);

  @override
  final String id;
  @override
  final String farmerId;
  @override
  final String produitId;
  @override
  final String titre;
  @override
  @FlexDouble()
  final double quantiteKg;
  @override
  @FlexDouble()
  final double prixParKg;
  @override
  @FlexDoubleN()
  final double? quantiteMinKg;
  @override
  @JsonKey(unknownEnumValue: ProductQuality.unknown)
  final ProductQuality qualite;
  @override
  final String? description;
  final List<String> _certifications;
  @override
  @JsonKey()
  List<String> get certifications {
    if (_certifications is EqualUnmodifiableListView) return _certifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_certifications);
  }

  @override
  final String? regionId;
  @override
  final String? villeId;
  @override
  final String? adresseDetail;
  @override
  @JsonKey(unknownEnumValue: ProductStatus.unknown)
  final ProductStatus status;
  @override
  @JsonKey()
  @FlexInt()
  final int viewsCount;
  @override
  final String? assignedToCooperativeId;
  @override
  @JsonKey(unknownEnumValue: CoopAnnonceStatus.unknown)
  final CoopAnnonceStatus? coopStatus;

  /// Motif renseigné par la coopérative quand elle a refusé cette
  /// annonce (`coopStatus == REJECTED`). Renvoyé tel quel par Prisma
  /// dans la colonne `rejected_reason` — d'où le `@JsonKey(name:...)`.
  /// Affiché au producteur dans une bannière rouge soft pour qu'il
  /// sache quoi corriger avant de re-publier.
  @override
  @JsonKey(name: 'rejected_reason')
  final String? rejectedReason;

  /// Le backend renvoie les photos dans la table `medias` jointe :
  /// `medias: [{url, thumbnail_url}]`. On extrait l'URL utilisable et on
  /// retombe sur un `photos: [...]` plat utilisé par les widgets.
  /// Le `toJson` réémet `medias: [{url}]` pour rester symétrique côté API.
  final List<String> _photos;

  /// Le backend renvoie les photos dans la table `medias` jointe :
  /// `medias: [{url, thumbnail_url}]`. On extrait l'URL utilisable et on
  /// retombe sur un `photos: [...]` plat utilisé par les widgets.
  /// Le `toJson` réémet `medias: [{url}]` pour rester symétrique côté API.
  @override
  @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  final DateTime? disponibleJusqu;

  /// Date à laquelle le produit a été récolté — info de fraîcheur affichée
  /// aux acheteurs. Distincte de `disponibleJusqu` (durée de validité de
  /// l'offre côté producteur). Optionnelle.
  @override
  final DateTime? dateRecolte;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  // ─── Champs joints (relations Prisma) ──────────────────────────────
  @override
  @JsonKey(name: 'produits_agricoles', fromJson: _nomFromMap, toJson: _nomToMap)
  final String? produitNom;
  @override
  @JsonKey(
    name: 'users',
    fromJson: _vendeurInfoFromJson,
    toJson: _vendeurInfoToJson,
  )
  final VendeurApercu? vendeur;
  @override
  @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
  final String? regionNom;
  @override
  @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
  final String? villeNom;

  /// Traitements appliqués à la culture (relation jointe par le backend
  /// via `include: { annonce_vente_traitements: { include: { produits_traitement } } }`).
  /// Permet d'exposer la traçabilité "from-farm-to-fork" : type, dosage,
  /// date d'application, délai de carence. Vide si le producteur n'a
  /// rien déclaré.
  final List<AnnonceTraitement> _traitements;

  /// Traitements appliqués à la culture (relation jointe par le backend
  /// via `include: { annonce_vente_traitements: { include: { produits_traitement } } }`).
  /// Permet d'exposer la traçabilité "from-farm-to-fork" : type, dosage,
  /// date d'application, délai de carence. Vide si le producteur n'a
  /// rien déclaré.
  @override
  @JsonKey(
    name: 'annonce_vente_traitements',
    fromJson: _traitementsFromJson,
    toJson: _traitementsToJson,
  )
  List<AnnonceTraitement> get traitements {
    if (_traitements is EqualUnmodifiableListView) return _traitements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_traitements);
  }

  @override
  String toString() {
    return 'AnnonceVente(id: $id, farmerId: $farmerId, produitId: $produitId, titre: $titre, quantiteKg: $quantiteKg, prixParKg: $prixParKg, quantiteMinKg: $quantiteMinKg, qualite: $qualite, description: $description, certifications: $certifications, regionId: $regionId, villeId: $villeId, adresseDetail: $adresseDetail, status: $status, viewsCount: $viewsCount, assignedToCooperativeId: $assignedToCooperativeId, coopStatus: $coopStatus, rejectedReason: $rejectedReason, photos: $photos, disponibleJusqu: $disponibleJusqu, dateRecolte: $dateRecolte, createdAt: $createdAt, updatedAt: $updatedAt, produitNom: $produitNom, vendeur: $vendeur, regionNom: $regionNom, villeNom: $villeNom, traitements: $traitements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnnonceVenteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.farmerId, farmerId) ||
                other.farmerId == farmerId) &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            (identical(other.titre, titre) || other.titre == titre) &&
            (identical(other.quantiteKg, quantiteKg) ||
                other.quantiteKg == quantiteKg) &&
            (identical(other.prixParKg, prixParKg) ||
                other.prixParKg == prixParKg) &&
            (identical(other.quantiteMinKg, quantiteMinKg) ||
                other.quantiteMinKg == quantiteMinKg) &&
            (identical(other.qualite, qualite) || other.qualite == qualite) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._certifications,
              _certifications,
            ) &&
            (identical(other.regionId, regionId) ||
                other.regionId == regionId) &&
            (identical(other.villeId, villeId) || other.villeId == villeId) &&
            (identical(other.adresseDetail, adresseDetail) ||
                other.adresseDetail == adresseDetail) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.viewsCount, viewsCount) ||
                other.viewsCount == viewsCount) &&
            (identical(
                  other.assignedToCooperativeId,
                  assignedToCooperativeId,
                ) ||
                other.assignedToCooperativeId == assignedToCooperativeId) &&
            (identical(other.coopStatus, coopStatus) ||
                other.coopStatus == coopStatus) &&
            (identical(other.rejectedReason, rejectedReason) ||
                other.rejectedReason == rejectedReason) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.disponibleJusqu, disponibleJusqu) ||
                other.disponibleJusqu == disponibleJusqu) &&
            (identical(other.dateRecolte, dateRecolte) ||
                other.dateRecolte == dateRecolte) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.produitNom, produitNom) ||
                other.produitNom == produitNom) &&
            (identical(other.vendeur, vendeur) || other.vendeur == vendeur) &&
            (identical(other.regionNom, regionNom) ||
                other.regionNom == regionNom) &&
            (identical(other.villeNom, villeNom) ||
                other.villeNom == villeNom) &&
            const DeepCollectionEquality().equals(
              other._traitements,
              _traitements,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    farmerId,
    produitId,
    titre,
    quantiteKg,
    prixParKg,
    quantiteMinKg,
    qualite,
    description,
    const DeepCollectionEquality().hash(_certifications),
    regionId,
    villeId,
    adresseDetail,
    status,
    viewsCount,
    assignedToCooperativeId,
    coopStatus,
    rejectedReason,
    const DeepCollectionEquality().hash(_photos),
    disponibleJusqu,
    dateRecolte,
    createdAt,
    updatedAt,
    produitNom,
    vendeur,
    regionNom,
    villeNom,
    const DeepCollectionEquality().hash(_traitements),
  ]);

  /// Create a copy of AnnonceVente
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnnonceVenteImplCopyWith<_$AnnonceVenteImpl> get copyWith =>
      __$$AnnonceVenteImplCopyWithImpl<_$AnnonceVenteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnnonceVenteImplToJson(this);
  }
}

abstract class _AnnonceVente extends AnnonceVente {
  const factory _AnnonceVente({
    required final String id,
    required final String farmerId,
    required final String produitId,
    required final String titre,
    @FlexDouble() required final double quantiteKg,
    @FlexDouble() required final double prixParKg,
    @FlexDoubleN() final double? quantiteMinKg,
    @JsonKey(unknownEnumValue: ProductQuality.unknown)
    final ProductQuality qualite,
    final String? description,
    final List<String> certifications,
    final String? regionId,
    final String? villeId,
    final String? adresseDetail,
    @JsonKey(unknownEnumValue: ProductStatus.unknown)
    final ProductStatus status,
    @FlexInt() final int viewsCount,
    final String? assignedToCooperativeId,
    @JsonKey(unknownEnumValue: CoopAnnonceStatus.unknown)
    final CoopAnnonceStatus? coopStatus,
    @JsonKey(name: 'rejected_reason') final String? rejectedReason,
    @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
    final List<String> photos,
    final DateTime? disponibleJusqu,
    final DateTime? dateRecolte,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    @JsonKey(
      name: 'produits_agricoles',
      fromJson: _nomFromMap,
      toJson: _nomToMap,
    )
    final String? produitNom,
    @JsonKey(
      name: 'users',
      fromJson: _vendeurInfoFromJson,
      toJson: _vendeurInfoToJson,
    )
    final VendeurApercu? vendeur,
    @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    final String? regionNom,
    @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
    final String? villeNom,
    @JsonKey(
      name: 'annonce_vente_traitements',
      fromJson: _traitementsFromJson,
      toJson: _traitementsToJson,
    )
    final List<AnnonceTraitement> traitements,
  }) = _$AnnonceVenteImpl;
  const _AnnonceVente._() : super._();

  factory _AnnonceVente.fromJson(Map<String, dynamic> json) =
      _$AnnonceVenteImpl.fromJson;

  @override
  String get id;
  @override
  String get farmerId;
  @override
  String get produitId;
  @override
  String get titre;
  @override
  @FlexDouble()
  double get quantiteKg;
  @override
  @FlexDouble()
  double get prixParKg;
  @override
  @FlexDoubleN()
  double? get quantiteMinKg;
  @override
  @JsonKey(unknownEnumValue: ProductQuality.unknown)
  ProductQuality get qualite;
  @override
  String? get description;
  @override
  List<String> get certifications;
  @override
  String? get regionId;
  @override
  String? get villeId;
  @override
  String? get adresseDetail;
  @override
  @JsonKey(unknownEnumValue: ProductStatus.unknown)
  ProductStatus get status;
  @override
  @FlexInt()
  int get viewsCount;
  @override
  String? get assignedToCooperativeId;
  @override
  @JsonKey(unknownEnumValue: CoopAnnonceStatus.unknown)
  CoopAnnonceStatus? get coopStatus;

  /// Motif renseigné par la coopérative quand elle a refusé cette
  /// annonce (`coopStatus == REJECTED`). Renvoyé tel quel par Prisma
  /// dans la colonne `rejected_reason` — d'où le `@JsonKey(name:...)`.
  /// Affiché au producteur dans une bannière rouge soft pour qu'il
  /// sache quoi corriger avant de re-publier.
  @override
  @JsonKey(name: 'rejected_reason')
  String? get rejectedReason;

  /// Le backend renvoie les photos dans la table `medias` jointe :
  /// `medias: [{url, thumbnail_url}]`. On extrait l'URL utilisable et on
  /// retombe sur un `photos: [...]` plat utilisé par les widgets.
  /// Le `toJson` réémet `medias: [{url}]` pour rester symétrique côté API.
  @override
  @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
  List<String> get photos;
  @override
  DateTime? get disponibleJusqu;

  /// Date à laquelle le produit a été récolté — info de fraîcheur affichée
  /// aux acheteurs. Distincte de `disponibleJusqu` (durée de validité de
  /// l'offre côté producteur). Optionnelle.
  @override
  DateTime? get dateRecolte;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // ─── Champs joints (relations Prisma) ──────────────────────────────
  @override
  @JsonKey(name: 'produits_agricoles', fromJson: _nomFromMap, toJson: _nomToMap)
  String? get produitNom;
  @override
  @JsonKey(
    name: 'users',
    fromJson: _vendeurInfoFromJson,
    toJson: _vendeurInfoToJson,
  )
  VendeurApercu? get vendeur;
  @override
  @JsonKey(name: 'regions_ci', fromJson: _nomFromMap, toJson: _nomToMap)
  String? get regionNom;
  @override
  @JsonKey(name: 'villes_ci', fromJson: _nomFromMap, toJson: _nomToMap)
  String? get villeNom;

  /// Traitements appliqués à la culture (relation jointe par le backend
  /// via `include: { annonce_vente_traitements: { include: { produits_traitement } } }`).
  /// Permet d'exposer la traçabilité "from-farm-to-fork" : type, dosage,
  /// date d'application, délai de carence. Vide si le producteur n'a
  /// rien déclaré.
  @override
  @JsonKey(
    name: 'annonce_vente_traitements',
    fromJson: _traitementsFromJson,
    toJson: _traitementsToJson,
  )
  List<AnnonceTraitement> get traitements;

  /// Create a copy of AnnonceVente
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnnonceVenteImplCopyWith<_$AnnonceVenteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
