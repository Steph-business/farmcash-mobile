// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'produit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Produit _$ProduitFromJson(Map<String, dynamic> json) {
  return _Produit.fromJson(json);
}

/// @nodoc
mixin _$Produit {
  String get id => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String? get sousCategorieId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get prixMarcheMin => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get prixMarcheMax => throw _privateConstructorUsedError;
  bool get estSaisonnier => throw _privateConstructorUsedError;
  bool get estExportable => throw _privateConstructorUsedError;
  String? get iconUrl => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this Produit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Produit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProduitCopyWith<Produit> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProduitCopyWith<$Res> {
  factory $ProduitCopyWith(Produit value, $Res Function(Produit) then) =
      _$ProduitCopyWithImpl<$Res, Produit>;
  @useResult
  $Res call({
    String id,
    String slug,
    String nom,
    String? sousCategorieId,
    String? description,
    @FlexDoubleN() double? prixMarcheMin,
    @FlexDoubleN() double? prixMarcheMax,
    bool estSaisonnier,
    bool estExportable,
    String? iconUrl,
    String? imageUrl,
  });
}

/// @nodoc
class _$ProduitCopyWithImpl<$Res, $Val extends Produit>
    implements $ProduitCopyWith<$Res> {
  _$ProduitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Produit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? nom = null,
    Object? sousCategorieId = freezed,
    Object? description = freezed,
    Object? prixMarcheMin = freezed,
    Object? prixMarcheMax = freezed,
    Object? estSaisonnier = null,
    Object? estExportable = null,
    Object? iconUrl = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            nom: null == nom
                ? _value.nom
                : nom // ignore: cast_nullable_to_non_nullable
                      as String,
            sousCategorieId: freezed == sousCategorieId
                ? _value.sousCategorieId
                : sousCategorieId // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            prixMarcheMin: freezed == prixMarcheMin
                ? _value.prixMarcheMin
                : prixMarcheMin // ignore: cast_nullable_to_non_nullable
                      as double?,
            prixMarcheMax: freezed == prixMarcheMax
                ? _value.prixMarcheMax
                : prixMarcheMax // ignore: cast_nullable_to_non_nullable
                      as double?,
            estSaisonnier: null == estSaisonnier
                ? _value.estSaisonnier
                : estSaisonnier // ignore: cast_nullable_to_non_nullable
                      as bool,
            estExportable: null == estExportable
                ? _value.estExportable
                : estExportable // ignore: cast_nullable_to_non_nullable
                      as bool,
            iconUrl: freezed == iconUrl
                ? _value.iconUrl
                : iconUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProduitImplCopyWith<$Res> implements $ProduitCopyWith<$Res> {
  factory _$$ProduitImplCopyWith(
    _$ProduitImpl value,
    $Res Function(_$ProduitImpl) then,
  ) = __$$ProduitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String slug,
    String nom,
    String? sousCategorieId,
    String? description,
    @FlexDoubleN() double? prixMarcheMin,
    @FlexDoubleN() double? prixMarcheMax,
    bool estSaisonnier,
    bool estExportable,
    String? iconUrl,
    String? imageUrl,
  });
}

/// @nodoc
class __$$ProduitImplCopyWithImpl<$Res>
    extends _$ProduitCopyWithImpl<$Res, _$ProduitImpl>
    implements _$$ProduitImplCopyWith<$Res> {
  __$$ProduitImplCopyWithImpl(
    _$ProduitImpl _value,
    $Res Function(_$ProduitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Produit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? nom = null,
    Object? sousCategorieId = freezed,
    Object? description = freezed,
    Object? prixMarcheMin = freezed,
    Object? prixMarcheMax = freezed,
    Object? estSaisonnier = null,
    Object? estExportable = null,
    Object? iconUrl = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$ProduitImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        sousCategorieId: freezed == sousCategorieId
            ? _value.sousCategorieId
            : sousCategorieId // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        prixMarcheMin: freezed == prixMarcheMin
            ? _value.prixMarcheMin
            : prixMarcheMin // ignore: cast_nullable_to_non_nullable
                  as double?,
        prixMarcheMax: freezed == prixMarcheMax
            ? _value.prixMarcheMax
            : prixMarcheMax // ignore: cast_nullable_to_non_nullable
                  as double?,
        estSaisonnier: null == estSaisonnier
            ? _value.estSaisonnier
            : estSaisonnier // ignore: cast_nullable_to_non_nullable
                  as bool,
        estExportable: null == estExportable
            ? _value.estExportable
            : estExportable // ignore: cast_nullable_to_non_nullable
                  as bool,
        iconUrl: freezed == iconUrl
            ? _value.iconUrl
            : iconUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProduitImpl implements _Produit {
  const _$ProduitImpl({
    required this.id,
    required this.slug,
    required this.nom,
    this.sousCategorieId,
    this.description,
    @FlexDoubleN() this.prixMarcheMin,
    @FlexDoubleN() this.prixMarcheMax,
    this.estSaisonnier = false,
    this.estExportable = false,
    this.iconUrl,
    this.imageUrl,
  });

  factory _$ProduitImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProduitImplFromJson(json);

  @override
  final String id;
  @override
  final String slug;
  @override
  final String nom;
  @override
  final String? sousCategorieId;
  @override
  final String? description;
  @override
  @FlexDoubleN()
  final double? prixMarcheMin;
  @override
  @FlexDoubleN()
  final double? prixMarcheMax;
  @override
  @JsonKey()
  final bool estSaisonnier;
  @override
  @JsonKey()
  final bool estExportable;
  @override
  final String? iconUrl;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'Produit(id: $id, slug: $slug, nom: $nom, sousCategorieId: $sousCategorieId, description: $description, prixMarcheMin: $prixMarcheMin, prixMarcheMax: $prixMarcheMax, estSaisonnier: $estSaisonnier, estExportable: $estExportable, iconUrl: $iconUrl, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProduitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.sousCategorieId, sousCategorieId) ||
                other.sousCategorieId == sousCategorieId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.prixMarcheMin, prixMarcheMin) ||
                other.prixMarcheMin == prixMarcheMin) &&
            (identical(other.prixMarcheMax, prixMarcheMax) ||
                other.prixMarcheMax == prixMarcheMax) &&
            (identical(other.estSaisonnier, estSaisonnier) ||
                other.estSaisonnier == estSaisonnier) &&
            (identical(other.estExportable, estExportable) ||
                other.estExportable == estExportable) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    slug,
    nom,
    sousCategorieId,
    description,
    prixMarcheMin,
    prixMarcheMax,
    estSaisonnier,
    estExportable,
    iconUrl,
    imageUrl,
  );

  /// Create a copy of Produit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProduitImplCopyWith<_$ProduitImpl> get copyWith =>
      __$$ProduitImplCopyWithImpl<_$ProduitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProduitImplToJson(this);
  }
}

abstract class _Produit implements Produit {
  const factory _Produit({
    required final String id,
    required final String slug,
    required final String nom,
    final String? sousCategorieId,
    final String? description,
    @FlexDoubleN() final double? prixMarcheMin,
    @FlexDoubleN() final double? prixMarcheMax,
    final bool estSaisonnier,
    final bool estExportable,
    final String? iconUrl,
    final String? imageUrl,
  }) = _$ProduitImpl;

  factory _Produit.fromJson(Map<String, dynamic> json) = _$ProduitImpl.fromJson;

  @override
  String get id;
  @override
  String get slug;
  @override
  String get nom;
  @override
  String? get sousCategorieId;
  @override
  String? get description;
  @override
  @FlexDoubleN()
  double? get prixMarcheMin;
  @override
  @FlexDoubleN()
  double? get prixMarcheMax;
  @override
  bool get estSaisonnier;
  @override
  bool get estExportable;
  @override
  String? get iconUrl;
  @override
  String? get imageUrl;

  /// Create a copy of Produit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProduitImplCopyWith<_$ProduitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Categorie _$CategorieFromJson(Map<String, dynamic> json) {
  return _Categorie.fromJson(json);
}

/// @nodoc
mixin _$Categorie {
  String get id => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String? get iconUrl => throw _privateConstructorUsedError;
  List<SousCategorie> get sousCategories => throw _privateConstructorUsedError;

  /// Serializes this Categorie to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Categorie
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategorieCopyWith<Categorie> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategorieCopyWith<$Res> {
  factory $CategorieCopyWith(Categorie value, $Res Function(Categorie) then) =
      _$CategorieCopyWithImpl<$Res, Categorie>;
  @useResult
  $Res call({
    String id,
    String slug,
    String nom,
    String? iconUrl,
    List<SousCategorie> sousCategories,
  });
}

/// @nodoc
class _$CategorieCopyWithImpl<$Res, $Val extends Categorie>
    implements $CategorieCopyWith<$Res> {
  _$CategorieCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Categorie
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? nom = null,
    Object? iconUrl = freezed,
    Object? sousCategories = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            nom: null == nom
                ? _value.nom
                : nom // ignore: cast_nullable_to_non_nullable
                      as String,
            iconUrl: freezed == iconUrl
                ? _value.iconUrl
                : iconUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            sousCategories: null == sousCategories
                ? _value.sousCategories
                : sousCategories // ignore: cast_nullable_to_non_nullable
                      as List<SousCategorie>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategorieImplCopyWith<$Res>
    implements $CategorieCopyWith<$Res> {
  factory _$$CategorieImplCopyWith(
    _$CategorieImpl value,
    $Res Function(_$CategorieImpl) then,
  ) = __$$CategorieImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String slug,
    String nom,
    String? iconUrl,
    List<SousCategorie> sousCategories,
  });
}

/// @nodoc
class __$$CategorieImplCopyWithImpl<$Res>
    extends _$CategorieCopyWithImpl<$Res, _$CategorieImpl>
    implements _$$CategorieImplCopyWith<$Res> {
  __$$CategorieImplCopyWithImpl(
    _$CategorieImpl _value,
    $Res Function(_$CategorieImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Categorie
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? nom = null,
    Object? iconUrl = freezed,
    Object? sousCategories = null,
  }) {
    return _then(
      _$CategorieImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        iconUrl: freezed == iconUrl
            ? _value.iconUrl
            : iconUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        sousCategories: null == sousCategories
            ? _value._sousCategories
            : sousCategories // ignore: cast_nullable_to_non_nullable
                  as List<SousCategorie>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CategorieImpl implements _Categorie {
  const _$CategorieImpl({
    required this.id,
    required this.slug,
    required this.nom,
    this.iconUrl,
    final List<SousCategorie> sousCategories = const <SousCategorie>[],
  }) : _sousCategories = sousCategories;

  factory _$CategorieImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategorieImplFromJson(json);

  @override
  final String id;
  @override
  final String slug;
  @override
  final String nom;
  @override
  final String? iconUrl;
  final List<SousCategorie> _sousCategories;
  @override
  @JsonKey()
  List<SousCategorie> get sousCategories {
    if (_sousCategories is EqualUnmodifiableListView) return _sousCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sousCategories);
  }

  @override
  String toString() {
    return 'Categorie(id: $id, slug: $slug, nom: $nom, iconUrl: $iconUrl, sousCategories: $sousCategories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategorieImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            const DeepCollectionEquality().equals(
              other._sousCategories,
              _sousCategories,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    slug,
    nom,
    iconUrl,
    const DeepCollectionEquality().hash(_sousCategories),
  );

  /// Create a copy of Categorie
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategorieImplCopyWith<_$CategorieImpl> get copyWith =>
      __$$CategorieImplCopyWithImpl<_$CategorieImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategorieImplToJson(this);
  }
}

abstract class _Categorie implements Categorie {
  const factory _Categorie({
    required final String id,
    required final String slug,
    required final String nom,
    final String? iconUrl,
    final List<SousCategorie> sousCategories,
  }) = _$CategorieImpl;

  factory _Categorie.fromJson(Map<String, dynamic> json) =
      _$CategorieImpl.fromJson;

  @override
  String get id;
  @override
  String get slug;
  @override
  String get nom;
  @override
  String? get iconUrl;
  @override
  List<SousCategorie> get sousCategories;

  /// Create a copy of Categorie
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategorieImplCopyWith<_$CategorieImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SousCategorie _$SousCategorieFromJson(Map<String, dynamic> json) {
  return _SousCategorie.fromJson(json);
}

/// @nodoc
mixin _$SousCategorie {
  String get id => throw _privateConstructorUsedError;
  String get categorieId => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;

  /// Serializes this SousCategorie to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SousCategorie
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SousCategorieCopyWith<SousCategorie> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SousCategorieCopyWith<$Res> {
  factory $SousCategorieCopyWith(
    SousCategorie value,
    $Res Function(SousCategorie) then,
  ) = _$SousCategorieCopyWithImpl<$Res, SousCategorie>;
  @useResult
  $Res call({String id, String categorieId, String slug, String nom});
}

/// @nodoc
class _$SousCategorieCopyWithImpl<$Res, $Val extends SousCategorie>
    implements $SousCategorieCopyWith<$Res> {
  _$SousCategorieCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SousCategorie
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categorieId = null,
    Object? slug = null,
    Object? nom = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            categorieId: null == categorieId
                ? _value.categorieId
                : categorieId // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            nom: null == nom
                ? _value.nom
                : nom // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SousCategorieImplCopyWith<$Res>
    implements $SousCategorieCopyWith<$Res> {
  factory _$$SousCategorieImplCopyWith(
    _$SousCategorieImpl value,
    $Res Function(_$SousCategorieImpl) then,
  ) = __$$SousCategorieImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String categorieId, String slug, String nom});
}

/// @nodoc
class __$$SousCategorieImplCopyWithImpl<$Res>
    extends _$SousCategorieCopyWithImpl<$Res, _$SousCategorieImpl>
    implements _$$SousCategorieImplCopyWith<$Res> {
  __$$SousCategorieImplCopyWithImpl(
    _$SousCategorieImpl _value,
    $Res Function(_$SousCategorieImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SousCategorie
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categorieId = null,
    Object? slug = null,
    Object? nom = null,
  }) {
    return _then(
      _$SousCategorieImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        categorieId: null == categorieId
            ? _value.categorieId
            : categorieId // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SousCategorieImpl implements _SousCategorie {
  const _$SousCategorieImpl({
    required this.id,
    required this.categorieId,
    required this.slug,
    required this.nom,
  });

  factory _$SousCategorieImpl.fromJson(Map<String, dynamic> json) =>
      _$$SousCategorieImplFromJson(json);

  @override
  final String id;
  @override
  final String categorieId;
  @override
  final String slug;
  @override
  final String nom;

  @override
  String toString() {
    return 'SousCategorie(id: $id, categorieId: $categorieId, slug: $slug, nom: $nom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SousCategorieImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categorieId, categorieId) ||
                other.categorieId == categorieId) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.nom, nom) || other.nom == nom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, categorieId, slug, nom);

  /// Create a copy of SousCategorie
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SousCategorieImplCopyWith<_$SousCategorieImpl> get copyWith =>
      __$$SousCategorieImplCopyWithImpl<_$SousCategorieImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SousCategorieImplToJson(this);
  }
}

abstract class _SousCategorie implements SousCategorie {
  const factory _SousCategorie({
    required final String id,
    required final String categorieId,
    required final String slug,
    required final String nom,
  }) = _$SousCategorieImpl;

  factory _SousCategorie.fromJson(Map<String, dynamic> json) =
      _$SousCategorieImpl.fromJson;

  @override
  String get id;
  @override
  String get categorieId;
  @override
  String get slug;
  @override
  String get nom;

  /// Create a copy of SousCategorie
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SousCategorieImplCopyWith<_$SousCategorieImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
