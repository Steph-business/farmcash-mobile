// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ville.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Ville _$VilleFromJson(Map<String, dynamic> json) {
  return _Ville.fromJson(json);
}

/// @nodoc
mixin _$Ville {
  String get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String get regionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'regions_ci', fromJson: _regionNomFromMap)
  String? get regionNom => throw _privateConstructorUsedError;

  /// Serializes this Ville to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Ville
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VilleCopyWith<Ville> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VilleCopyWith<$Res> {
  factory $VilleCopyWith(Ville value, $Res Function(Ville) then) =
      _$VilleCopyWithImpl<$Res, Ville>;
  @useResult
  $Res call({
    String id,
    String nom,
    String regionId,
    @JsonKey(name: 'regions_ci', fromJson: _regionNomFromMap) String? regionNom,
  });
}

/// @nodoc
class _$VilleCopyWithImpl<$Res, $Val extends Ville>
    implements $VilleCopyWith<$Res> {
  _$VilleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Ville
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? regionId = null,
    Object? regionNom = freezed,
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
            regionId: null == regionId
                ? _value.regionId
                : regionId // ignore: cast_nullable_to_non_nullable
                      as String,
            regionNom: freezed == regionNom
                ? _value.regionNom
                : regionNom // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VilleImplCopyWith<$Res> implements $VilleCopyWith<$Res> {
  factory _$$VilleImplCopyWith(
    _$VilleImpl value,
    $Res Function(_$VilleImpl) then,
  ) = __$$VilleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nom,
    String regionId,
    @JsonKey(name: 'regions_ci', fromJson: _regionNomFromMap) String? regionNom,
  });
}

/// @nodoc
class __$$VilleImplCopyWithImpl<$Res>
    extends _$VilleCopyWithImpl<$Res, _$VilleImpl>
    implements _$$VilleImplCopyWith<$Res> {
  __$$VilleImplCopyWithImpl(
    _$VilleImpl _value,
    $Res Function(_$VilleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Ville
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? regionId = null,
    Object? regionNom = freezed,
  }) {
    return _then(
      _$VilleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        regionId: null == regionId
            ? _value.regionId
            : regionId // ignore: cast_nullable_to_non_nullable
                  as String,
        regionNom: freezed == regionNom
            ? _value.regionNom
            : regionNom // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VilleImpl extends _Ville {
  const _$VilleImpl({
    required this.id,
    required this.nom,
    required this.regionId,
    @JsonKey(name: 'regions_ci', fromJson: _regionNomFromMap) this.regionNom,
  }) : super._();

  factory _$VilleImpl.fromJson(Map<String, dynamic> json) =>
      _$$VilleImplFromJson(json);

  @override
  final String id;
  @override
  final String nom;
  @override
  final String regionId;
  @override
  @JsonKey(name: 'regions_ci', fromJson: _regionNomFromMap)
  final String? regionNom;

  @override
  String toString() {
    return 'Ville(id: $id, nom: $nom, regionId: $regionId, regionNom: $regionNom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VilleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.regionId, regionId) ||
                other.regionId == regionId) &&
            (identical(other.regionNom, regionNom) ||
                other.regionNom == regionNom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nom, regionId, regionNom);

  /// Create a copy of Ville
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VilleImplCopyWith<_$VilleImpl> get copyWith =>
      __$$VilleImplCopyWithImpl<_$VilleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VilleImplToJson(this);
  }
}

abstract class _Ville extends Ville {
  const factory _Ville({
    required final String id,
    required final String nom,
    required final String regionId,
    @JsonKey(name: 'regions_ci', fromJson: _regionNomFromMap)
    final String? regionNom,
  }) = _$VilleImpl;
  const _Ville._() : super._();

  factory _Ville.fromJson(Map<String, dynamic> json) = _$VilleImpl.fromJson;

  @override
  String get id;
  @override
  String get nom;
  @override
  String get regionId;
  @override
  @JsonKey(name: 'regions_ci', fromJson: _regionNomFromMap)
  String? get regionNom;

  /// Create a copy of Ville
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VilleImplCopyWith<_$VilleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
