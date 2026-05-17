// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'traitement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Traitement _$TraitementFromJson(Map<String, dynamic> json) {
  return _Traitement.fromJson(json);
}

/// @nodoc
mixin _$Traitement {
  String get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get mode => throw _privateConstructorUsedError;
  String? get dosage => throw _privateConstructorUsedError;
  List<String> get maladies => throw _privateConstructorUsedError;
  List<String> get produits => throw _privateConstructorUsedError;
  bool get isBio => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get prixIndicatif => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Traitement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Traitement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TraitementCopyWith<Traitement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TraitementCopyWith<$Res> {
  factory $TraitementCopyWith(
    Traitement value,
    $Res Function(Traitement) then,
  ) = _$TraitementCopyWithImpl<$Res, Traitement>;
  @useResult
  $Res call({
    String id,
    String nom,
    String? description,
    String? type,
    String? mode,
    String? dosage,
    List<String> maladies,
    List<String> produits,
    bool isBio,
    @FlexDoubleN() double? prixIndicatif,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$TraitementCopyWithImpl<$Res, $Val extends Traitement>
    implements $TraitementCopyWith<$Res> {
  _$TraitementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Traitement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? description = freezed,
    Object? type = freezed,
    Object? mode = freezed,
    Object? dosage = freezed,
    Object? maladies = null,
    Object? produits = null,
    Object? isBio = null,
    Object? prixIndicatif = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nom: null == nom
                ? _value.nom
                : nom // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            mode: freezed == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as String?,
            dosage: freezed == dosage
                ? _value.dosage
                : dosage // ignore: cast_nullable_to_non_nullable
                      as String?,
            maladies: null == maladies
                ? _value.maladies
                : maladies // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            produits: null == produits
                ? _value.produits
                : produits // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isBio: null == isBio
                ? _value.isBio
                : isBio // ignore: cast_nullable_to_non_nullable
                      as bool,
            prixIndicatif: freezed == prixIndicatif
                ? _value.prixIndicatif
                : prixIndicatif // ignore: cast_nullable_to_non_nullable
                      as double?,
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
abstract class _$$TraitementImplCopyWith<$Res>
    implements $TraitementCopyWith<$Res> {
  factory _$$TraitementImplCopyWith(
    _$TraitementImpl value,
    $Res Function(_$TraitementImpl) then,
  ) = __$$TraitementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nom,
    String? description,
    String? type,
    String? mode,
    String? dosage,
    List<String> maladies,
    List<String> produits,
    bool isBio,
    @FlexDoubleN() double? prixIndicatif,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$TraitementImplCopyWithImpl<$Res>
    extends _$TraitementCopyWithImpl<$Res, _$TraitementImpl>
    implements _$$TraitementImplCopyWith<$Res> {
  __$$TraitementImplCopyWithImpl(
    _$TraitementImpl _value,
    $Res Function(_$TraitementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Traitement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? description = freezed,
    Object? type = freezed,
    Object? mode = freezed,
    Object? dosage = freezed,
    Object? maladies = null,
    Object? produits = null,
    Object? isBio = null,
    Object? prixIndicatif = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TraitementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        mode: freezed == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as String?,
        dosage: freezed == dosage
            ? _value.dosage
            : dosage // ignore: cast_nullable_to_non_nullable
                  as String?,
        maladies: null == maladies
            ? _value._maladies
            : maladies // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        produits: null == produits
            ? _value._produits
            : produits // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isBio: null == isBio
            ? _value.isBio
            : isBio // ignore: cast_nullable_to_non_nullable
                  as bool,
        prixIndicatif: freezed == prixIndicatif
            ? _value.prixIndicatif
            : prixIndicatif // ignore: cast_nullable_to_non_nullable
                  as double?,
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
class _$TraitementImpl implements _Traitement {
  const _$TraitementImpl({
    required this.id,
    required this.nom,
    this.description,
    this.type,
    this.mode,
    this.dosage,
    final List<String> maladies = const <String>[],
    final List<String> produits = const <String>[],
    this.isBio = false,
    @FlexDoubleN() this.prixIndicatif,
    this.createdAt,
  }) : _maladies = maladies,
       _produits = produits;

  factory _$TraitementImpl.fromJson(Map<String, dynamic> json) =>
      _$$TraitementImplFromJson(json);

  @override
  final String id;
  @override
  final String nom;
  @override
  final String? description;
  @override
  final String? type;
  @override
  final String? mode;
  @override
  final String? dosage;
  final List<String> _maladies;
  @override
  @JsonKey()
  List<String> get maladies {
    if (_maladies is EqualUnmodifiableListView) return _maladies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_maladies);
  }

  final List<String> _produits;
  @override
  @JsonKey()
  List<String> get produits {
    if (_produits is EqualUnmodifiableListView) return _produits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_produits);
  }

  @override
  @JsonKey()
  final bool isBio;
  @override
  @FlexDoubleN()
  final double? prixIndicatif;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Traitement(id: $id, nom: $nom, description: $description, type: $type, mode: $mode, dosage: $dosage, maladies: $maladies, produits: $produits, isBio: $isBio, prixIndicatif: $prixIndicatif, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TraitementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            const DeepCollectionEquality().equals(other._maladies, _maladies) &&
            const DeepCollectionEquality().equals(other._produits, _produits) &&
            (identical(other.isBio, isBio) || other.isBio == isBio) &&
            (identical(other.prixIndicatif, prixIndicatif) ||
                other.prixIndicatif == prixIndicatif) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nom,
    description,
    type,
    mode,
    dosage,
    const DeepCollectionEquality().hash(_maladies),
    const DeepCollectionEquality().hash(_produits),
    isBio,
    prixIndicatif,
    createdAt,
  );

  /// Create a copy of Traitement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TraitementImplCopyWith<_$TraitementImpl> get copyWith =>
      __$$TraitementImplCopyWithImpl<_$TraitementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TraitementImplToJson(this);
  }
}

abstract class _Traitement implements Traitement {
  const factory _Traitement({
    required final String id,
    required final String nom,
    final String? description,
    final String? type,
    final String? mode,
    final String? dosage,
    final List<String> maladies,
    final List<String> produits,
    final bool isBio,
    @FlexDoubleN() final double? prixIndicatif,
    final DateTime? createdAt,
  }) = _$TraitementImpl;

  factory _Traitement.fromJson(Map<String, dynamic> json) =
      _$TraitementImpl.fromJson;

  @override
  String get id;
  @override
  String get nom;
  @override
  String? get description;
  @override
  String? get type;
  @override
  String? get mode;
  @override
  String? get dosage;
  @override
  List<String> get maladies;
  @override
  List<String> get produits;
  @override
  bool get isBio;
  @override
  @FlexDoubleN()
  double? get prixIndicatif;
  @override
  DateTime? get createdAt;

  /// Create a copy of Traitement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TraitementImplCopyWith<_$TraitementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
