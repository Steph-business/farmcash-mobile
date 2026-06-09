// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publication_coop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PublicationCoop _$PublicationCoopFromJson(Map<String, dynamic> json) {
  return _PublicationCoop.fromJson(json);
}

/// @nodoc
mixin _$PublicationCoop {
  String get id => throw _privateConstructorUsedError;
  String get cooperativeId => throw _privateConstructorUsedError;
  String get produitId => throw _privateConstructorUsedError;
  String get titre => throw _privateConstructorUsedError;
  @FlexDouble()
  double get quantiteKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get prixParKg => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ProductQuality.unknown)
  ProductQuality get qualite => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
  List<String> get photos => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ProductStatus.unknown)
  ProductStatus get status => throw _privateConstructorUsedError;
  int get nbContributeurs => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Dates de récolte des annonces du lot agrégé, parsées depuis
  /// `publication_contributions[].annonces_vente.date_recolte`.
  /// Liste plate triée croissant. Vide si le backend ne joint pas ou
  /// si aucune contribution n'a renseigné `date_recolte`.
  /// Utilisée par les getters `dateRecolteMin/Max` ci-dessous pour
  /// afficher « Récolté entre le X et le Y » côté acheteur (signal
  /// de fraîcheur clé pour produits frais).
  @JsonKey(
    name: 'publication_contributions',
    fromJson: _datesRecolteFromContribs,
    toJson: _datesRecolteToJson,
  )
  List<DateTime> get datesRecolteAnnonces => throw _privateConstructorUsedError;

  /// Serializes this PublicationCoop to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PublicationCoop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicationCoopCopyWith<PublicationCoop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicationCoopCopyWith<$Res> {
  factory $PublicationCoopCopyWith(
    PublicationCoop value,
    $Res Function(PublicationCoop) then,
  ) = _$PublicationCoopCopyWithImpl<$Res, PublicationCoop>;
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String produitId,
    String titre,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixParKg,
    @JsonKey(unknownEnumValue: ProductQuality.unknown) ProductQuality qualite,
    String? description,
    @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
    List<String> photos,
    @JsonKey(unknownEnumValue: ProductStatus.unknown) ProductStatus status,
    int nbContributeurs,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(
      name: 'publication_contributions',
      fromJson: _datesRecolteFromContribs,
      toJson: _datesRecolteToJson,
    )
    List<DateTime> datesRecolteAnnonces,
  });
}

/// @nodoc
class _$PublicationCoopCopyWithImpl<$Res, $Val extends PublicationCoop>
    implements $PublicationCoopCopyWith<$Res> {
  _$PublicationCoopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicationCoop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? produitId = null,
    Object? titre = null,
    Object? quantiteKg = null,
    Object? prixParKg = null,
    Object? qualite = null,
    Object? description = freezed,
    Object? photos = null,
    Object? status = null,
    Object? nbContributeurs = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? datesRecolteAnnonces = null,
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
            qualite: null == qualite
                ? _value.qualite
                : qualite // ignore: cast_nullable_to_non_nullable
                      as ProductQuality,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            photos: null == photos
                ? _value.photos
                : photos // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ProductStatus,
            nbContributeurs: null == nbContributeurs
                ? _value.nbContributeurs
                : nbContributeurs // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            datesRecolteAnnonces: null == datesRecolteAnnonces
                ? _value.datesRecolteAnnonces
                : datesRecolteAnnonces // ignore: cast_nullable_to_non_nullable
                      as List<DateTime>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PublicationCoopImplCopyWith<$Res>
    implements $PublicationCoopCopyWith<$Res> {
  factory _$$PublicationCoopImplCopyWith(
    _$PublicationCoopImpl value,
    $Res Function(_$PublicationCoopImpl) then,
  ) = __$$PublicationCoopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String produitId,
    String titre,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixParKg,
    @JsonKey(unknownEnumValue: ProductQuality.unknown) ProductQuality qualite,
    String? description,
    @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
    List<String> photos,
    @JsonKey(unknownEnumValue: ProductStatus.unknown) ProductStatus status,
    int nbContributeurs,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(
      name: 'publication_contributions',
      fromJson: _datesRecolteFromContribs,
      toJson: _datesRecolteToJson,
    )
    List<DateTime> datesRecolteAnnonces,
  });
}

/// @nodoc
class __$$PublicationCoopImplCopyWithImpl<$Res>
    extends _$PublicationCoopCopyWithImpl<$Res, _$PublicationCoopImpl>
    implements _$$PublicationCoopImplCopyWith<$Res> {
  __$$PublicationCoopImplCopyWithImpl(
    _$PublicationCoopImpl _value,
    $Res Function(_$PublicationCoopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PublicationCoop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? produitId = null,
    Object? titre = null,
    Object? quantiteKg = null,
    Object? prixParKg = null,
    Object? qualite = null,
    Object? description = freezed,
    Object? photos = null,
    Object? status = null,
    Object? nbContributeurs = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? datesRecolteAnnonces = null,
  }) {
    return _then(
      _$PublicationCoopImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        cooperativeId: null == cooperativeId
            ? _value.cooperativeId
            : cooperativeId // ignore: cast_nullable_to_non_nullable
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
        qualite: null == qualite
            ? _value.qualite
            : qualite // ignore: cast_nullable_to_non_nullable
                  as ProductQuality,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        photos: null == photos
            ? _value._photos
            : photos // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ProductStatus,
        nbContributeurs: null == nbContributeurs
            ? _value.nbContributeurs
            : nbContributeurs // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        datesRecolteAnnonces: null == datesRecolteAnnonces
            ? _value._datesRecolteAnnonces
            : datesRecolteAnnonces // ignore: cast_nullable_to_non_nullable
                  as List<DateTime>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PublicationCoopImpl extends _PublicationCoop {
  const _$PublicationCoopImpl({
    required this.id,
    required this.cooperativeId,
    required this.produitId,
    required this.titre,
    @FlexDouble() required this.quantiteKg,
    @FlexDouble() required this.prixParKg,
    @JsonKey(unknownEnumValue: ProductQuality.unknown)
    this.qualite = ProductQuality.unknown,
    this.description,
    @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
    final List<String> photos = const <String>[],
    @JsonKey(unknownEnumValue: ProductStatus.unknown)
    this.status = ProductStatus.unknown,
    this.nbContributeurs = 0,
    this.createdAt,
    this.updatedAt,
    @JsonKey(
      name: 'publication_contributions',
      fromJson: _datesRecolteFromContribs,
      toJson: _datesRecolteToJson,
    )
    final List<DateTime> datesRecolteAnnonces = const <DateTime>[],
  }) : _photos = photos,
       _datesRecolteAnnonces = datesRecolteAnnonces,
       super._();

  factory _$PublicationCoopImpl.fromJson(Map<String, dynamic> json) =>
      _$$PublicationCoopImplFromJson(json);

  @override
  final String id;
  @override
  final String cooperativeId;
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
  @JsonKey(unknownEnumValue: ProductQuality.unknown)
  final ProductQuality qualite;
  @override
  final String? description;
  final List<String> _photos;
  @override
  @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  @JsonKey(unknownEnumValue: ProductStatus.unknown)
  final ProductStatus status;
  @override
  @JsonKey()
  final int nbContributeurs;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Dates de récolte des annonces du lot agrégé, parsées depuis
  /// `publication_contributions[].annonces_vente.date_recolte`.
  /// Liste plate triée croissant. Vide si le backend ne joint pas ou
  /// si aucune contribution n'a renseigné `date_recolte`.
  /// Utilisée par les getters `dateRecolteMin/Max` ci-dessous pour
  /// afficher « Récolté entre le X et le Y » côté acheteur (signal
  /// de fraîcheur clé pour produits frais).
  final List<DateTime> _datesRecolteAnnonces;

  /// Dates de récolte des annonces du lot agrégé, parsées depuis
  /// `publication_contributions[].annonces_vente.date_recolte`.
  /// Liste plate triée croissant. Vide si le backend ne joint pas ou
  /// si aucune contribution n'a renseigné `date_recolte`.
  /// Utilisée par les getters `dateRecolteMin/Max` ci-dessous pour
  /// afficher « Récolté entre le X et le Y » côté acheteur (signal
  /// de fraîcheur clé pour produits frais).
  @override
  @JsonKey(
    name: 'publication_contributions',
    fromJson: _datesRecolteFromContribs,
    toJson: _datesRecolteToJson,
  )
  List<DateTime> get datesRecolteAnnonces {
    if (_datesRecolteAnnonces is EqualUnmodifiableListView)
      return _datesRecolteAnnonces;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_datesRecolteAnnonces);
  }

  @override
  String toString() {
    return 'PublicationCoop(id: $id, cooperativeId: $cooperativeId, produitId: $produitId, titre: $titre, quantiteKg: $quantiteKg, prixParKg: $prixParKg, qualite: $qualite, description: $description, photos: $photos, status: $status, nbContributeurs: $nbContributeurs, createdAt: $createdAt, updatedAt: $updatedAt, datesRecolteAnnonces: $datesRecolteAnnonces)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicationCoopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cooperativeId, cooperativeId) ||
                other.cooperativeId == cooperativeId) &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            (identical(other.titre, titre) || other.titre == titre) &&
            (identical(other.quantiteKg, quantiteKg) ||
                other.quantiteKg == quantiteKg) &&
            (identical(other.prixParKg, prixParKg) ||
                other.prixParKg == prixParKg) &&
            (identical(other.qualite, qualite) || other.qualite == qualite) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.nbContributeurs, nbContributeurs) ||
                other.nbContributeurs == nbContributeurs) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(
              other._datesRecolteAnnonces,
              _datesRecolteAnnonces,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    cooperativeId,
    produitId,
    titre,
    quantiteKg,
    prixParKg,
    qualite,
    description,
    const DeepCollectionEquality().hash(_photos),
    status,
    nbContributeurs,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_datesRecolteAnnonces),
  );

  /// Create a copy of PublicationCoop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicationCoopImplCopyWith<_$PublicationCoopImpl> get copyWith =>
      __$$PublicationCoopImplCopyWithImpl<_$PublicationCoopImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicationCoopImplToJson(this);
  }
}

abstract class _PublicationCoop extends PublicationCoop {
  const factory _PublicationCoop({
    required final String id,
    required final String cooperativeId,
    required final String produitId,
    required final String titre,
    @FlexDouble() required final double quantiteKg,
    @FlexDouble() required final double prixParKg,
    @JsonKey(unknownEnumValue: ProductQuality.unknown)
    final ProductQuality qualite,
    final String? description,
    @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
    final List<String> photos,
    @JsonKey(unknownEnumValue: ProductStatus.unknown)
    final ProductStatus status,
    final int nbContributeurs,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    @JsonKey(
      name: 'publication_contributions',
      fromJson: _datesRecolteFromContribs,
      toJson: _datesRecolteToJson,
    )
    final List<DateTime> datesRecolteAnnonces,
  }) = _$PublicationCoopImpl;
  const _PublicationCoop._() : super._();

  factory _PublicationCoop.fromJson(Map<String, dynamic> json) =
      _$PublicationCoopImpl.fromJson;

  @override
  String get id;
  @override
  String get cooperativeId;
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
  @JsonKey(unknownEnumValue: ProductQuality.unknown)
  ProductQuality get qualite;
  @override
  String? get description;
  @override
  @JsonKey(name: 'medias', fromJson: mediasToPhotos, toJson: photosToMedias)
  List<String> get photos;
  @override
  @JsonKey(unknownEnumValue: ProductStatus.unknown)
  ProductStatus get status;
  @override
  int get nbContributeurs;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Dates de récolte des annonces du lot agrégé, parsées depuis
  /// `publication_contributions[].annonces_vente.date_recolte`.
  /// Liste plate triée croissant. Vide si le backend ne joint pas ou
  /// si aucune contribution n'a renseigné `date_recolte`.
  /// Utilisée par les getters `dateRecolteMin/Max` ci-dessous pour
  /// afficher « Récolté entre le X et le Y » côté acheteur (signal
  /// de fraîcheur clé pour produits frais).
  @override
  @JsonKey(
    name: 'publication_contributions',
    fromJson: _datesRecolteFromContribs,
    toJson: _datesRecolteToJson,
  )
  List<DateTime> get datesRecolteAnnonces;

  /// Create a copy of PublicationCoop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicationCoopImplCopyWith<_$PublicationCoopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
