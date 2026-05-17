// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'panier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Panier _$PanierFromJson(Map<String, dynamic> json) {
  return _Panier.fromJson(json);
}

/// @nodoc
mixin _$Panier {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  List<PanierItem> get items => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Panier to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Panier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PanierCopyWith<Panier> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PanierCopyWith<$Res> {
  factory $PanierCopyWith(Panier value, $Res Function(Panier) then) =
      _$PanierCopyWithImpl<$Res, Panier>;
  @useResult
  $Res call({
    String id,
    String userId,
    List<PanierItem> items,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$PanierCopyWithImpl<$Res, $Val extends Panier>
    implements $PanierCopyWith<$Res> {
  _$PanierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Panier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? items = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<PanierItem>,
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
abstract class _$$PanierImplCopyWith<$Res> implements $PanierCopyWith<$Res> {
  factory _$$PanierImplCopyWith(
    _$PanierImpl value,
    $Res Function(_$PanierImpl) then,
  ) = __$$PanierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    List<PanierItem> items,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$PanierImplCopyWithImpl<$Res>
    extends _$PanierCopyWithImpl<$Res, _$PanierImpl>
    implements _$$PanierImplCopyWith<$Res> {
  __$$PanierImplCopyWithImpl(
    _$PanierImpl _value,
    $Res Function(_$PanierImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Panier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? items = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$PanierImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<PanierItem>,
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
class _$PanierImpl extends _Panier {
  const _$PanierImpl({
    this.id = '',
    this.userId = '',
    final List<PanierItem> items = const <PanierItem>[],
    this.updatedAt,
  }) : _items = items,
       super._();

  factory _$PanierImpl.fromJson(Map<String, dynamic> json) =>
      _$$PanierImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String userId;
  final List<PanierItem> _items;
  @override
  @JsonKey()
  List<PanierItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Panier(id: $id, userId: $userId, items: $items, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PanierImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    const DeepCollectionEquality().hash(_items),
    updatedAt,
  );

  /// Create a copy of Panier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PanierImplCopyWith<_$PanierImpl> get copyWith =>
      __$$PanierImplCopyWithImpl<_$PanierImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PanierImplToJson(this);
  }
}

abstract class _Panier extends Panier {
  const factory _Panier({
    final String id,
    final String userId,
    final List<PanierItem> items,
    final DateTime? updatedAt,
  }) = _$PanierImpl;
  const _Panier._() : super._();

  factory _Panier.fromJson(Map<String, dynamic> json) = _$PanierImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  List<PanierItem> get items;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Panier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PanierImplCopyWith<_$PanierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PanierItem _$PanierItemFromJson(Map<String, dynamic> json) {
  return _PanierItem.fromJson(json);
}

/// @nodoc
mixin _$PanierItem {
  String get id => throw _privateConstructorUsedError;
  String get panierId => throw _privateConstructorUsedError;
  String get annonceId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get quantiteKg => throw _privateConstructorUsedError;
  @FlexDouble()
  double get prixUnitaire => throw _privateConstructorUsedError;
  AnnonceVente? get annonce => throw _privateConstructorUsedError;

  /// Serializes this PanierItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PanierItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PanierItemCopyWith<PanierItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PanierItemCopyWith<$Res> {
  factory $PanierItemCopyWith(
    PanierItem value,
    $Res Function(PanierItem) then,
  ) = _$PanierItemCopyWithImpl<$Res, PanierItem>;
  @useResult
  $Res call({
    String id,
    String panierId,
    String annonceId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixUnitaire,
    AnnonceVente? annonce,
  });

  $AnnonceVenteCopyWith<$Res>? get annonce;
}

/// @nodoc
class _$PanierItemCopyWithImpl<$Res, $Val extends PanierItem>
    implements $PanierItemCopyWith<$Res> {
  _$PanierItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PanierItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? panierId = null,
    Object? annonceId = null,
    Object? quantiteKg = null,
    Object? prixUnitaire = null,
    Object? annonce = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            panierId: null == panierId
                ? _value.panierId
                : panierId // ignore: cast_nullable_to_non_nullable
                      as String,
            annonceId: null == annonceId
                ? _value.annonceId
                : annonceId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantiteKg: null == quantiteKg
                ? _value.quantiteKg
                : quantiteKg // ignore: cast_nullable_to_non_nullable
                      as double,
            prixUnitaire: null == prixUnitaire
                ? _value.prixUnitaire
                : prixUnitaire // ignore: cast_nullable_to_non_nullable
                      as double,
            annonce: freezed == annonce
                ? _value.annonce
                : annonce // ignore: cast_nullable_to_non_nullable
                      as AnnonceVente?,
          )
          as $Val,
    );
  }

  /// Create a copy of PanierItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnnonceVenteCopyWith<$Res>? get annonce {
    if (_value.annonce == null) {
      return null;
    }

    return $AnnonceVenteCopyWith<$Res>(_value.annonce!, (value) {
      return _then(_value.copyWith(annonce: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PanierItemImplCopyWith<$Res>
    implements $PanierItemCopyWith<$Res> {
  factory _$$PanierItemImplCopyWith(
    _$PanierItemImpl value,
    $Res Function(_$PanierItemImpl) then,
  ) = __$$PanierItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String panierId,
    String annonceId,
    @FlexDouble() double quantiteKg,
    @FlexDouble() double prixUnitaire,
    AnnonceVente? annonce,
  });

  @override
  $AnnonceVenteCopyWith<$Res>? get annonce;
}

/// @nodoc
class __$$PanierItemImplCopyWithImpl<$Res>
    extends _$PanierItemCopyWithImpl<$Res, _$PanierItemImpl>
    implements _$$PanierItemImplCopyWith<$Res> {
  __$$PanierItemImplCopyWithImpl(
    _$PanierItemImpl _value,
    $Res Function(_$PanierItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PanierItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? panierId = null,
    Object? annonceId = null,
    Object? quantiteKg = null,
    Object? prixUnitaire = null,
    Object? annonce = freezed,
  }) {
    return _then(
      _$PanierItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        panierId: null == panierId
            ? _value.panierId
            : panierId // ignore: cast_nullable_to_non_nullable
                  as String,
        annonceId: null == annonceId
            ? _value.annonceId
            : annonceId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantiteKg: null == quantiteKg
            ? _value.quantiteKg
            : quantiteKg // ignore: cast_nullable_to_non_nullable
                  as double,
        prixUnitaire: null == prixUnitaire
            ? _value.prixUnitaire
            : prixUnitaire // ignore: cast_nullable_to_non_nullable
                  as double,
        annonce: freezed == annonce
            ? _value.annonce
            : annonce // ignore: cast_nullable_to_non_nullable
                  as AnnonceVente?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PanierItemImpl extends _PanierItem {
  const _$PanierItemImpl({
    required this.id,
    this.panierId = '',
    required this.annonceId,
    @FlexDouble() required this.quantiteKg,
    @FlexDouble() required this.prixUnitaire,
    this.annonce,
  }) : super._();

  factory _$PanierItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PanierItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String panierId;
  @override
  final String annonceId;
  @override
  @FlexDouble()
  final double quantiteKg;
  @override
  @FlexDouble()
  final double prixUnitaire;
  @override
  final AnnonceVente? annonce;

  @override
  String toString() {
    return 'PanierItem(id: $id, panierId: $panierId, annonceId: $annonceId, quantiteKg: $quantiteKg, prixUnitaire: $prixUnitaire, annonce: $annonce)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PanierItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.panierId, panierId) ||
                other.panierId == panierId) &&
            (identical(other.annonceId, annonceId) ||
                other.annonceId == annonceId) &&
            (identical(other.quantiteKg, quantiteKg) ||
                other.quantiteKg == quantiteKg) &&
            (identical(other.prixUnitaire, prixUnitaire) ||
                other.prixUnitaire == prixUnitaire) &&
            (identical(other.annonce, annonce) || other.annonce == annonce));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    panierId,
    annonceId,
    quantiteKg,
    prixUnitaire,
    annonce,
  );

  /// Create a copy of PanierItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PanierItemImplCopyWith<_$PanierItemImpl> get copyWith =>
      __$$PanierItemImplCopyWithImpl<_$PanierItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PanierItemImplToJson(this);
  }
}

abstract class _PanierItem extends PanierItem {
  const factory _PanierItem({
    required final String id,
    final String panierId,
    required final String annonceId,
    @FlexDouble() required final double quantiteKg,
    @FlexDouble() required final double prixUnitaire,
    final AnnonceVente? annonce,
  }) = _$PanierItemImpl;
  const _PanierItem._() : super._();

  factory _PanierItem.fromJson(Map<String, dynamic> json) =
      _$PanierItemImpl.fromJson;

  @override
  String get id;
  @override
  String get panierId;
  @override
  String get annonceId;
  @override
  @FlexDouble()
  double get quantiteKg;
  @override
  @FlexDouble()
  double get prixUnitaire;
  @override
  AnnonceVente? get annonce;

  /// Create a copy of PanierItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PanierItemImplCopyWith<_$PanierItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
