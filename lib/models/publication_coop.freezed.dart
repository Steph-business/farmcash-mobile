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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PublicationCoopImpl implements _PublicationCoop {
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
  }) : _photos = photos;

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

  @override
  String toString() {
    return 'PublicationCoop(id: $id, cooperativeId: $cooperativeId, produitId: $produitId, titre: $titre, quantiteKg: $quantiteKg, prixParKg: $prixParKg, qualite: $qualite, description: $description, photos: $photos, status: $status, nbContributeurs: $nbContributeurs, createdAt: $createdAt, updatedAt: $updatedAt)';
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
                other.updatedAt == updatedAt));
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

abstract class _PublicationCoop implements PublicationCoop {
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
  }) = _$PublicationCoopImpl;

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

  /// Create a copy of PublicationCoop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicationCoopImplCopyWith<_$PublicationCoopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoopContribution _$CoopContributionFromJson(Map<String, dynamic> json) {
  return _CoopContribution.fromJson(json);
}

/// @nodoc
mixin _$CoopContribution {
  String get userId => throw _privateConstructorUsedError;
  String get annonceId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get quantiteKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get partPourcent => throw _privateConstructorUsedError;
  @FlexDouble()
  double get revenuProjete => throw _privateConstructorUsedError;
  Utilisateur? get user => throw _privateConstructorUsedError;

  /// Serializes this CoopContribution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoopContribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoopContributionCopyWith<CoopContribution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoopContributionCopyWith<$Res> {
  factory $CoopContributionCopyWith(
    CoopContribution value,
    $Res Function(CoopContribution) then,
  ) = _$CoopContributionCopyWithImpl<$Res, CoopContribution>;
  @useResult
  $Res call({
    String userId,
    String annonceId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double partPourcent,
    @FlexDouble() double revenuProjete,
    Utilisateur? user,
  });

  $UtilisateurCopyWith<$Res>? get user;
}

/// @nodoc
class _$CoopContributionCopyWithImpl<$Res, $Val extends CoopContribution>
    implements $CoopContributionCopyWith<$Res> {
  _$CoopContributionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoopContribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? annonceId = null,
    Object? quantiteKg = null,
    Object? partPourcent = null,
    Object? revenuProjete = null,
    Object? user = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            annonceId: null == annonceId
                ? _value.annonceId
                : annonceId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantiteKg: null == quantiteKg
                ? _value.quantiteKg
                : quantiteKg // ignore: cast_nullable_to_non_nullable
                      as double,
            partPourcent: null == partPourcent
                ? _value.partPourcent
                : partPourcent // ignore: cast_nullable_to_non_nullable
                      as double,
            revenuProjete: null == revenuProjete
                ? _value.revenuProjete
                : revenuProjete // ignore: cast_nullable_to_non_nullable
                      as double,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as Utilisateur?,
          )
          as $Val,
    );
  }

  /// Create a copy of CoopContribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UtilisateurCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UtilisateurCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CoopContributionImplCopyWith<$Res>
    implements $CoopContributionCopyWith<$Res> {
  factory _$$CoopContributionImplCopyWith(
    _$CoopContributionImpl value,
    $Res Function(_$CoopContributionImpl) then,
  ) = __$$CoopContributionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String annonceId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double partPourcent,
    @FlexDouble() double revenuProjete,
    Utilisateur? user,
  });

  @override
  $UtilisateurCopyWith<$Res>? get user;
}

/// @nodoc
class __$$CoopContributionImplCopyWithImpl<$Res>
    extends _$CoopContributionCopyWithImpl<$Res, _$CoopContributionImpl>
    implements _$$CoopContributionImplCopyWith<$Res> {
  __$$CoopContributionImplCopyWithImpl(
    _$CoopContributionImpl _value,
    $Res Function(_$CoopContributionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CoopContribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? annonceId = null,
    Object? quantiteKg = null,
    Object? partPourcent = null,
    Object? revenuProjete = null,
    Object? user = freezed,
  }) {
    return _then(
      _$CoopContributionImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        annonceId: null == annonceId
            ? _value.annonceId
            : annonceId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantiteKg: null == quantiteKg
            ? _value.quantiteKg
            : quantiteKg // ignore: cast_nullable_to_non_nullable
                  as double,
        partPourcent: null == partPourcent
            ? _value.partPourcent
            : partPourcent // ignore: cast_nullable_to_non_nullable
                  as double,
        revenuProjete: null == revenuProjete
            ? _value.revenuProjete
            : revenuProjete // ignore: cast_nullable_to_non_nullable
                  as double,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as Utilisateur?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CoopContributionImpl extends _CoopContribution {
  const _$CoopContributionImpl({
    required this.userId,
    required this.annonceId,
    @FlexDouble() required this.quantiteKg,
    @FlexDouble() required this.partPourcent,
    @FlexDouble() required this.revenuProjete,
    this.user,
  }) : super._();

  factory _$CoopContributionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoopContributionImplFromJson(json);

  @override
  final String userId;
  @override
  final String annonceId;
  @override
  @FlexDouble()
  final double quantiteKg;
  @override
  @FlexDouble()
  final double partPourcent;
  @override
  @FlexDouble()
  final double revenuProjete;
  @override
  final Utilisateur? user;

  @override
  String toString() {
    return 'CoopContribution(userId: $userId, annonceId: $annonceId, quantiteKg: $quantiteKg, partPourcent: $partPourcent, revenuProjete: $revenuProjete, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoopContributionImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.annonceId, annonceId) ||
                other.annonceId == annonceId) &&
            (identical(other.quantiteKg, quantiteKg) ||
                other.quantiteKg == quantiteKg) &&
            (identical(other.partPourcent, partPourcent) ||
                other.partPourcent == partPourcent) &&
            (identical(other.revenuProjete, revenuProjete) ||
                other.revenuProjete == revenuProjete) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    annonceId,
    quantiteKg,
    partPourcent,
    revenuProjete,
    user,
  );

  /// Create a copy of CoopContribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoopContributionImplCopyWith<_$CoopContributionImpl> get copyWith =>
      __$$CoopContributionImplCopyWithImpl<_$CoopContributionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CoopContributionImplToJson(this);
  }
}

abstract class _CoopContribution extends CoopContribution {
  const factory _CoopContribution({
    required final String userId,
    required final String annonceId,
    @FlexDouble() required final double quantiteKg,
    @FlexDouble() required final double partPourcent,
    @FlexDouble() required final double revenuProjete,
    final Utilisateur? user,
  }) = _$CoopContributionImpl;
  const _CoopContribution._() : super._();

  factory _CoopContribution.fromJson(Map<String, dynamic> json) =
      _$CoopContributionImpl.fromJson;

  @override
  String get userId;
  @override
  String get annonceId;
  @override
  @FlexDouble()
  double get quantiteKg;
  @override
  @FlexDouble()
  double get partPourcent;
  @override
  @FlexDouble()
  double get revenuProjete;
  @override
  Utilisateur? get user;

  /// Create a copy of CoopContribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoopContributionImplCopyWith<_$CoopContributionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
