// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'utilisateur.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Utilisateur _$UtilisateurFromJson(Map<String, dynamic> json) {
  return _Utilisateur.fromJson(json);
}

/// @nodoc
mixin _$Utilisateur {
  String get id =>
      throw _privateConstructorUsedError; // `phone` est nullable car certaines réponses backend (ex: login-pin)
  // renvoient un user minimal sans le téléphone — il faut alors appeler
  // `/auth/me` pour récupérer la version complète.
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: UserRole.unknown)
  UserRole get role => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  @FlexDouble()
  double get rating => throw _privateConstructorUsedError;
  @FlexDouble()
  double get walletBalance => throw _privateConstructorUsedError;
  String? get cooperativeId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Utilisateur to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Utilisateur
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UtilisateurCopyWith<Utilisateur> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UtilisateurCopyWith<$Res> {
  factory $UtilisateurCopyWith(
    Utilisateur value,
    $Res Function(Utilisateur) then,
  ) = _$UtilisateurCopyWithImpl<$Res, Utilisateur>;
  @useResult
  $Res call({
    String id,
    String? phone,
    @JsonKey(unknownEnumValue: UserRole.unknown) UserRole role,
    String? fullName,
    String? photoUrl,
    String? email,
    bool isVerified,
    bool isActive,
    @FlexDouble() double rating,
    @FlexDouble() double walletBalance,
    String? cooperativeId,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$UtilisateurCopyWithImpl<$Res, $Val extends Utilisateur>
    implements $UtilisateurCopyWith<$Res> {
  _$UtilisateurCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Utilisateur
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = freezed,
    Object? role = null,
    Object? fullName = freezed,
    Object? photoUrl = freezed,
    Object? email = freezed,
    Object? isVerified = null,
    Object? isActive = null,
    Object? rating = null,
    Object? walletBalance = null,
    Object? cooperativeId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as UserRole,
            fullName: freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
            walletBalance: null == walletBalance
                ? _value.walletBalance
                : walletBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            cooperativeId: freezed == cooperativeId
                ? _value.cooperativeId
                : cooperativeId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$UtilisateurImplCopyWith<$Res>
    implements $UtilisateurCopyWith<$Res> {
  factory _$$UtilisateurImplCopyWith(
    _$UtilisateurImpl value,
    $Res Function(_$UtilisateurImpl) then,
  ) = __$$UtilisateurImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? phone,
    @JsonKey(unknownEnumValue: UserRole.unknown) UserRole role,
    String? fullName,
    String? photoUrl,
    String? email,
    bool isVerified,
    bool isActive,
    @FlexDouble() double rating,
    @FlexDouble() double walletBalance,
    String? cooperativeId,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$UtilisateurImplCopyWithImpl<$Res>
    extends _$UtilisateurCopyWithImpl<$Res, _$UtilisateurImpl>
    implements _$$UtilisateurImplCopyWith<$Res> {
  __$$UtilisateurImplCopyWithImpl(
    _$UtilisateurImpl _value,
    $Res Function(_$UtilisateurImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Utilisateur
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = freezed,
    Object? role = null,
    Object? fullName = freezed,
    Object? photoUrl = freezed,
    Object? email = freezed,
    Object? isVerified = null,
    Object? isActive = null,
    Object? rating = null,
    Object? walletBalance = null,
    Object? cooperativeId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$UtilisateurImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as UserRole,
        fullName: freezed == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
        walletBalance: null == walletBalance
            ? _value.walletBalance
            : walletBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        cooperativeId: freezed == cooperativeId
            ? _value.cooperativeId
            : cooperativeId // ignore: cast_nullable_to_non_nullable
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
class _$UtilisateurImpl implements _Utilisateur {
  const _$UtilisateurImpl({
    required this.id,
    this.phone,
    @JsonKey(unknownEnumValue: UserRole.unknown) this.role = UserRole.unknown,
    this.fullName,
    this.photoUrl,
    this.email,
    this.isVerified = false,
    this.isActive = true,
    @FlexDouble() this.rating = 0.0,
    @FlexDouble() this.walletBalance = 0.0,
    this.cooperativeId,
    this.createdAt,
  });

  factory _$UtilisateurImpl.fromJson(Map<String, dynamic> json) =>
      _$$UtilisateurImplFromJson(json);

  @override
  final String id;
  // `phone` est nullable car certaines réponses backend (ex: login-pin)
  // renvoient un user minimal sans le téléphone — il faut alors appeler
  // `/auth/me` pour récupérer la version complète.
  @override
  final String? phone;
  @override
  @JsonKey(unknownEnumValue: UserRole.unknown)
  final UserRole role;
  @override
  final String? fullName;
  @override
  final String? photoUrl;
  @override
  final String? email;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  @FlexDouble()
  final double rating;
  @override
  @JsonKey()
  @FlexDouble()
  final double walletBalance;
  @override
  final String? cooperativeId;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Utilisateur(id: $id, phone: $phone, role: $role, fullName: $fullName, photoUrl: $photoUrl, email: $email, isVerified: $isVerified, isActive: $isActive, rating: $rating, walletBalance: $walletBalance, cooperativeId: $cooperativeId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UtilisateurImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.walletBalance, walletBalance) ||
                other.walletBalance == walletBalance) &&
            (identical(other.cooperativeId, cooperativeId) ||
                other.cooperativeId == cooperativeId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    phone,
    role,
    fullName,
    photoUrl,
    email,
    isVerified,
    isActive,
    rating,
    walletBalance,
    cooperativeId,
    createdAt,
  );

  /// Create a copy of Utilisateur
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UtilisateurImplCopyWith<_$UtilisateurImpl> get copyWith =>
      __$$UtilisateurImplCopyWithImpl<_$UtilisateurImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UtilisateurImplToJson(this);
  }
}

abstract class _Utilisateur implements Utilisateur {
  const factory _Utilisateur({
    required final String id,
    final String? phone,
    @JsonKey(unknownEnumValue: UserRole.unknown) final UserRole role,
    final String? fullName,
    final String? photoUrl,
    final String? email,
    final bool isVerified,
    final bool isActive,
    @FlexDouble() final double rating,
    @FlexDouble() final double walletBalance,
    final String? cooperativeId,
    final DateTime? createdAt,
  }) = _$UtilisateurImpl;

  factory _Utilisateur.fromJson(Map<String, dynamic> json) =
      _$UtilisateurImpl.fromJson;

  @override
  String get id; // `phone` est nullable car certaines réponses backend (ex: login-pin)
  // renvoient un user minimal sans le téléphone — il faut alors appeler
  // `/auth/me` pour récupérer la version complète.
  @override
  String? get phone;
  @override
  @JsonKey(unknownEnumValue: UserRole.unknown)
  UserRole get role;
  @override
  String? get fullName;
  @override
  String? get photoUrl;
  @override
  String? get email;
  @override
  bool get isVerified;
  @override
  bool get isActive;
  @override
  @FlexDouble()
  double get rating;
  @override
  @FlexDouble()
  double get walletBalance;
  @override
  String? get cooperativeId;
  @override
  DateTime? get createdAt;

  /// Create a copy of Utilisateur
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UtilisateurImplCopyWith<_$UtilisateurImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) {
  return _AuthTokens.fromJson(json);
}

/// @nodoc
mixin _$AuthTokens {
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  Utilisateur? get user => throw _privateConstructorUsedError;
  int? get expiresIn => throw _privateConstructorUsedError;

  /// Serializes this AuthTokens to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthTokens
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthTokensCopyWith<AuthTokens> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthTokensCopyWith<$Res> {
  factory $AuthTokensCopyWith(
    AuthTokens value,
    $Res Function(AuthTokens) then,
  ) = _$AuthTokensCopyWithImpl<$Res, AuthTokens>;
  @useResult
  $Res call({
    String accessToken,
    String refreshToken,
    Utilisateur? user,
    int? expiresIn,
  });

  $UtilisateurCopyWith<$Res>? get user;
}

/// @nodoc
class _$AuthTokensCopyWithImpl<$Res, $Val extends AuthTokens>
    implements $AuthTokensCopyWith<$Res> {
  _$AuthTokensCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthTokens
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? user = freezed,
    Object? expiresIn = freezed,
  }) {
    return _then(
      _value.copyWith(
            accessToken: null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String,
            refreshToken: null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as Utilisateur?,
            expiresIn: freezed == expiresIn
                ? _value.expiresIn
                : expiresIn // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthTokens
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
abstract class _$$AuthTokensImplCopyWith<$Res>
    implements $AuthTokensCopyWith<$Res> {
  factory _$$AuthTokensImplCopyWith(
    _$AuthTokensImpl value,
    $Res Function(_$AuthTokensImpl) then,
  ) = __$$AuthTokensImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String accessToken,
    String refreshToken,
    Utilisateur? user,
    int? expiresIn,
  });

  @override
  $UtilisateurCopyWith<$Res>? get user;
}

/// @nodoc
class __$$AuthTokensImplCopyWithImpl<$Res>
    extends _$AuthTokensCopyWithImpl<$Res, _$AuthTokensImpl>
    implements _$$AuthTokensImplCopyWith<$Res> {
  __$$AuthTokensImplCopyWithImpl(
    _$AuthTokensImpl _value,
    $Res Function(_$AuthTokensImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthTokens
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? user = freezed,
    Object? expiresIn = freezed,
  }) {
    return _then(
      _$AuthTokensImpl(
        accessToken: null == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshToken: null == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as Utilisateur?,
        expiresIn: freezed == expiresIn
            ? _value.expiresIn
            : expiresIn // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthTokensImpl implements _AuthTokens {
  const _$AuthTokensImpl({
    required this.accessToken,
    required this.refreshToken,
    this.user,
    this.expiresIn,
  });

  factory _$AuthTokensImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthTokensImplFromJson(json);

  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final Utilisateur? user;
  @override
  final int? expiresIn;

  @override
  String toString() {
    return 'AuthTokens(accessToken: $accessToken, refreshToken: $refreshToken, user: $user, expiresIn: $expiresIn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthTokensImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, accessToken, refreshToken, user, expiresIn);

  /// Create a copy of AuthTokens
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthTokensImplCopyWith<_$AuthTokensImpl> get copyWith =>
      __$$AuthTokensImplCopyWithImpl<_$AuthTokensImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthTokensImplToJson(this);
  }
}

abstract class _AuthTokens implements AuthTokens {
  const factory _AuthTokens({
    required final String accessToken,
    required final String refreshToken,
    final Utilisateur? user,
    final int? expiresIn,
  }) = _$AuthTokensImpl;

  factory _AuthTokens.fromJson(Map<String, dynamic> json) =
      _$AuthTokensImpl.fromJson;

  @override
  String get accessToken;
  @override
  String get refreshToken;
  @override
  Utilisateur? get user;
  @override
  int? get expiresIn;

  /// Create a copy of AuthTokens
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthTokensImplCopyWith<_$AuthTokensImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
