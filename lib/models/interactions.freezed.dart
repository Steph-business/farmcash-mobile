// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interactions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Avis _$AvisFromJson(Map<String, dynamic> json) {
  return _Avis.fromJson(json);
}

/// @nodoc
mixin _$Avis {
  String get id => throw _privateConstructorUsedError;
  String get reviewerId => throw _privateConstructorUsedError;
  String get reviewedUserId => throw _privateConstructorUsedError;
  String get contextType => throw _privateConstructorUsedError;
  String? get contextId => throw _privateConstructorUsedError;
  int get note => throw _privateConstructorUsedError;
  String? get commentaire => throw _privateConstructorUsedError;
  Utilisateur? get reviewer => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Avis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Avis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvisCopyWith<Avis> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvisCopyWith<$Res> {
  factory $AvisCopyWith(Avis value, $Res Function(Avis) then) =
      _$AvisCopyWithImpl<$Res, Avis>;
  @useResult
  $Res call({
    String id,
    String reviewerId,
    String reviewedUserId,
    String contextType,
    String? contextId,
    int note,
    String? commentaire,
    Utilisateur? reviewer,
    DateTime? createdAt,
  });

  $UtilisateurCopyWith<$Res>? get reviewer;
}

/// @nodoc
class _$AvisCopyWithImpl<$Res, $Val extends Avis>
    implements $AvisCopyWith<$Res> {
  _$AvisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Avis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reviewerId = null,
    Object? reviewedUserId = null,
    Object? contextType = null,
    Object? contextId = freezed,
    Object? note = null,
    Object? commentaire = freezed,
    Object? reviewer = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            reviewerId: null == reviewerId
                ? _value.reviewerId
                : reviewerId // ignore: cast_nullable_to_non_nullable
                      as String,
            reviewedUserId: null == reviewedUserId
                ? _value.reviewedUserId
                : reviewedUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            contextType: null == contextType
                ? _value.contextType
                : contextType // ignore: cast_nullable_to_non_nullable
                      as String,
            contextId: freezed == contextId
                ? _value.contextId
                : contextId // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as int,
            commentaire: freezed == commentaire
                ? _value.commentaire
                : commentaire // ignore: cast_nullable_to_non_nullable
                      as String?,
            reviewer: freezed == reviewer
                ? _value.reviewer
                : reviewer // ignore: cast_nullable_to_non_nullable
                      as Utilisateur?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of Avis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UtilisateurCopyWith<$Res>? get reviewer {
    if (_value.reviewer == null) {
      return null;
    }

    return $UtilisateurCopyWith<$Res>(_value.reviewer!, (value) {
      return _then(_value.copyWith(reviewer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AvisImplCopyWith<$Res> implements $AvisCopyWith<$Res> {
  factory _$$AvisImplCopyWith(
    _$AvisImpl value,
    $Res Function(_$AvisImpl) then,
  ) = __$$AvisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String reviewerId,
    String reviewedUserId,
    String contextType,
    String? contextId,
    int note,
    String? commentaire,
    Utilisateur? reviewer,
    DateTime? createdAt,
  });

  @override
  $UtilisateurCopyWith<$Res>? get reviewer;
}

/// @nodoc
class __$$AvisImplCopyWithImpl<$Res>
    extends _$AvisCopyWithImpl<$Res, _$AvisImpl>
    implements _$$AvisImplCopyWith<$Res> {
  __$$AvisImplCopyWithImpl(_$AvisImpl _value, $Res Function(_$AvisImpl) _then)
    : super(_value, _then);

  /// Create a copy of Avis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reviewerId = null,
    Object? reviewedUserId = null,
    Object? contextType = null,
    Object? contextId = freezed,
    Object? note = null,
    Object? commentaire = freezed,
    Object? reviewer = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AvisImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        reviewerId: null == reviewerId
            ? _value.reviewerId
            : reviewerId // ignore: cast_nullable_to_non_nullable
                  as String,
        reviewedUserId: null == reviewedUserId
            ? _value.reviewedUserId
            : reviewedUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        contextType: null == contextType
            ? _value.contextType
            : contextType // ignore: cast_nullable_to_non_nullable
                  as String,
        contextId: freezed == contextId
            ? _value.contextId
            : contextId // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as int,
        commentaire: freezed == commentaire
            ? _value.commentaire
            : commentaire // ignore: cast_nullable_to_non_nullable
                  as String?,
        reviewer: freezed == reviewer
            ? _value.reviewer
            : reviewer // ignore: cast_nullable_to_non_nullable
                  as Utilisateur?,
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
class _$AvisImpl extends _Avis {
  const _$AvisImpl({
    required this.id,
    required this.reviewerId,
    required this.reviewedUserId,
    this.contextType = '',
    this.contextId,
    this.note = 0,
    this.commentaire,
    this.reviewer,
    this.createdAt,
  }) : super._();

  factory _$AvisImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvisImplFromJson(json);

  @override
  final String id;
  @override
  final String reviewerId;
  @override
  final String reviewedUserId;
  @override
  @JsonKey()
  final String contextType;
  @override
  final String? contextId;
  @override
  @JsonKey()
  final int note;
  @override
  final String? commentaire;
  @override
  final Utilisateur? reviewer;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Avis(id: $id, reviewerId: $reviewerId, reviewedUserId: $reviewedUserId, contextType: $contextType, contextId: $contextId, note: $note, commentaire: $commentaire, reviewer: $reviewer, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvisImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reviewerId, reviewerId) ||
                other.reviewerId == reviewerId) &&
            (identical(other.reviewedUserId, reviewedUserId) ||
                other.reviewedUserId == reviewedUserId) &&
            (identical(other.contextType, contextType) ||
                other.contextType == contextType) &&
            (identical(other.contextId, contextId) ||
                other.contextId == contextId) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.commentaire, commentaire) ||
                other.commentaire == commentaire) &&
            (identical(other.reviewer, reviewer) ||
                other.reviewer == reviewer) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    reviewerId,
    reviewedUserId,
    contextType,
    contextId,
    note,
    commentaire,
    reviewer,
    createdAt,
  );

  /// Create a copy of Avis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvisImplCopyWith<_$AvisImpl> get copyWith =>
      __$$AvisImplCopyWithImpl<_$AvisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AvisImplToJson(this);
  }
}

abstract class _Avis extends Avis {
  const factory _Avis({
    required final String id,
    required final String reviewerId,
    required final String reviewedUserId,
    final String contextType,
    final String? contextId,
    final int note,
    final String? commentaire,
    final Utilisateur? reviewer,
    final DateTime? createdAt,
  }) = _$AvisImpl;
  const _Avis._() : super._();

  factory _Avis.fromJson(Map<String, dynamic> json) = _$AvisImpl.fromJson;

  @override
  String get id;
  @override
  String get reviewerId;
  @override
  String get reviewedUserId;
  @override
  String get contextType;
  @override
  String? get contextId;
  @override
  int get note;
  @override
  String? get commentaire;
  @override
  Utilisateur? get reviewer;
  @override
  DateTime? get createdAt;

  /// Create a copy of Avis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvisImplCopyWith<_$AvisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Favori _$FavoriFromJson(Map<String, dynamic> json) {
  return _Favori.fromJson(json);
}

/// @nodoc
mixin _$Favori {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get annonceId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Favori to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Favori
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FavoriCopyWith<Favori> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FavoriCopyWith<$Res> {
  factory $FavoriCopyWith(Favori value, $Res Function(Favori) then) =
      _$FavoriCopyWithImpl<$Res, Favori>;
  @useResult
  $Res call({String id, String userId, String annonceId, DateTime? createdAt});
}

/// @nodoc
class _$FavoriCopyWithImpl<$Res, $Val extends Favori>
    implements $FavoriCopyWith<$Res> {
  _$FavoriCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Favori
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? annonceId = null,
    Object? createdAt = freezed,
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
            annonceId: null == annonceId
                ? _value.annonceId
                : annonceId // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$FavoriImplCopyWith<$Res> implements $FavoriCopyWith<$Res> {
  factory _$$FavoriImplCopyWith(
    _$FavoriImpl value,
    $Res Function(_$FavoriImpl) then,
  ) = __$$FavoriImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String userId, String annonceId, DateTime? createdAt});
}

/// @nodoc
class __$$FavoriImplCopyWithImpl<$Res>
    extends _$FavoriCopyWithImpl<$Res, _$FavoriImpl>
    implements _$$FavoriImplCopyWith<$Res> {
  __$$FavoriImplCopyWithImpl(
    _$FavoriImpl _value,
    $Res Function(_$FavoriImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Favori
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? annonceId = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$FavoriImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        annonceId: null == annonceId
            ? _value.annonceId
            : annonceId // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$FavoriImpl implements _Favori {
  const _$FavoriImpl({
    required this.id,
    required this.userId,
    required this.annonceId,
    this.createdAt,
  });

  factory _$FavoriImpl.fromJson(Map<String, dynamic> json) =>
      _$$FavoriImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String annonceId;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Favori(id: $id, userId: $userId, annonceId: $annonceId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FavoriImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.annonceId, annonceId) ||
                other.annonceId == annonceId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, annonceId, createdAt);

  /// Create a copy of Favori
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FavoriImplCopyWith<_$FavoriImpl> get copyWith =>
      __$$FavoriImplCopyWithImpl<_$FavoriImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FavoriImplToJson(this);
  }
}

abstract class _Favori implements Favori {
  const factory _Favori({
    required final String id,
    required final String userId,
    required final String annonceId,
    final DateTime? createdAt,
  }) = _$FavoriImpl;

  factory _Favori.fromJson(Map<String, dynamic> json) = _$FavoriImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get annonceId;
  @override
  DateTime? get createdAt;

  /// Create a copy of Favori
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FavoriImplCopyWith<_$FavoriImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Media _$MediaFromJson(Map<String, dynamic> json) {
  return _Media.fromJson(json);
}

/// @nodoc
mixin _$Media {
  String get id => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String? get annonceId => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Media to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MediaCopyWith<Media> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaCopyWith<$Res> {
  factory $MediaCopyWith(Media value, $Res Function(Media) then) =
      _$MediaCopyWithImpl<$Res, Media>;
  @useResult
  $Res call({
    String id,
    String ownerId,
    String url,
    String? annonceId,
    String? type,
    int position,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$MediaCopyWithImpl<$Res, $Val extends Media>
    implements $MediaCopyWith<$Res> {
  _$MediaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? url = null,
    Object? annonceId = freezed,
    Object? type = freezed,
    Object? position = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerId: null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            annonceId: freezed == annonceId
                ? _value.annonceId
                : annonceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$MediaImplCopyWith<$Res> implements $MediaCopyWith<$Res> {
  factory _$$MediaImplCopyWith(
    _$MediaImpl value,
    $Res Function(_$MediaImpl) then,
  ) = __$$MediaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String ownerId,
    String url,
    String? annonceId,
    String? type,
    int position,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$MediaImplCopyWithImpl<$Res>
    extends _$MediaCopyWithImpl<$Res, _$MediaImpl>
    implements _$$MediaImplCopyWith<$Res> {
  __$$MediaImplCopyWithImpl(
    _$MediaImpl _value,
    $Res Function(_$MediaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? url = null,
    Object? annonceId = freezed,
    Object? type = freezed,
    Object? position = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$MediaImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        annonceId: freezed == annonceId
            ? _value.annonceId
            : annonceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$MediaImpl implements _Media {
  const _$MediaImpl({
    required this.id,
    required this.ownerId,
    this.url = '',
    this.annonceId,
    this.type,
    this.position = 0,
    this.createdAt,
  });

  factory _$MediaImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaImplFromJson(json);

  @override
  final String id;
  @override
  final String ownerId;
  @override
  @JsonKey()
  final String url;
  @override
  final String? annonceId;
  @override
  final String? type;
  @override
  @JsonKey()
  final int position;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Media(id: $id, ownerId: $ownerId, url: $url, annonceId: $annonceId, type: $type, position: $position, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.annonceId, annonceId) ||
                other.annonceId == annonceId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ownerId,
    url,
    annonceId,
    type,
    position,
    createdAt,
  );

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaImplCopyWith<_$MediaImpl> get copyWith =>
      __$$MediaImplCopyWithImpl<_$MediaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaImplToJson(this);
  }
}

abstract class _Media implements Media {
  const factory _Media({
    required final String id,
    required final String ownerId,
    final String url,
    final String? annonceId,
    final String? type,
    final int position,
    final DateTime? createdAt,
  }) = _$MediaImpl;

  factory _Media.fromJson(Map<String, dynamic> json) = _$MediaImpl.fromJson;

  @override
  String get id;
  @override
  String get ownerId;
  @override
  String get url;
  @override
  String? get annonceId;
  @override
  String? get type;
  @override
  int get position;
  @override
  DateTime? get createdAt;

  /// Create a copy of Media
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MediaImplCopyWith<_$MediaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
