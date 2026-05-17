// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phone_proxy_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PhoneProxySession _$PhoneProxySessionFromJson(Map<String, dynamic> json) {
  return _PhoneProxySession.fromJson(json);
}

/// @nodoc
mixin _$PhoneProxySession {
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'proxy_phone')
  String get proxyPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this PhoneProxySession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhoneProxySession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhoneProxySessionCopyWith<PhoneProxySession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhoneProxySessionCopyWith<$Res> {
  factory $PhoneProxySessionCopyWith(
    PhoneProxySession value,
    $Res Function(PhoneProxySession) then,
  ) = _$PhoneProxySessionCopyWithImpl<$Res, PhoneProxySession>;
  @useResult
  $Res call({
    @JsonKey(name: 'session_id') String sessionId,
    @JsonKey(name: 'proxy_phone') String proxyPhone,
    @JsonKey(name: 'expires_at') DateTime expiresAt,
  });
}

/// @nodoc
class _$PhoneProxySessionCopyWithImpl<$Res, $Val extends PhoneProxySession>
    implements $PhoneProxySessionCopyWith<$Res> {
  _$PhoneProxySessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhoneProxySession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? proxyPhone = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            proxyPhone: null == proxyPhone
                ? _value.proxyPhone
                : proxyPhone // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhoneProxySessionImplCopyWith<$Res>
    implements $PhoneProxySessionCopyWith<$Res> {
  factory _$$PhoneProxySessionImplCopyWith(
    _$PhoneProxySessionImpl value,
    $Res Function(_$PhoneProxySessionImpl) then,
  ) = __$$PhoneProxySessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'session_id') String sessionId,
    @JsonKey(name: 'proxy_phone') String proxyPhone,
    @JsonKey(name: 'expires_at') DateTime expiresAt,
  });
}

/// @nodoc
class __$$PhoneProxySessionImplCopyWithImpl<$Res>
    extends _$PhoneProxySessionCopyWithImpl<$Res, _$PhoneProxySessionImpl>
    implements _$$PhoneProxySessionImplCopyWith<$Res> {
  __$$PhoneProxySessionImplCopyWithImpl(
    _$PhoneProxySessionImpl _value,
    $Res Function(_$PhoneProxySessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhoneProxySession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? proxyPhone = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _$PhoneProxySessionImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        proxyPhone: null == proxyPhone
            ? _value.proxyPhone
            : proxyPhone // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PhoneProxySessionImpl implements _PhoneProxySession {
  const _$PhoneProxySessionImpl({
    @JsonKey(name: 'session_id') required this.sessionId,
    @JsonKey(name: 'proxy_phone') required this.proxyPhone,
    @JsonKey(name: 'expires_at') required this.expiresAt,
  });

  factory _$PhoneProxySessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhoneProxySessionImplFromJson(json);

  @override
  @JsonKey(name: 'session_id')
  final String sessionId;
  @override
  @JsonKey(name: 'proxy_phone')
  final String proxyPhone;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  @override
  String toString() {
    return 'PhoneProxySession(sessionId: $sessionId, proxyPhone: $proxyPhone, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhoneProxySessionImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.proxyPhone, proxyPhone) ||
                other.proxyPhone == proxyPhone) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, sessionId, proxyPhone, expiresAt);

  /// Create a copy of PhoneProxySession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhoneProxySessionImplCopyWith<_$PhoneProxySessionImpl> get copyWith =>
      __$$PhoneProxySessionImplCopyWithImpl<_$PhoneProxySessionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PhoneProxySessionImplToJson(this);
  }
}

abstract class _PhoneProxySession implements PhoneProxySession {
  const factory _PhoneProxySession({
    @JsonKey(name: 'session_id') required final String sessionId,
    @JsonKey(name: 'proxy_phone') required final String proxyPhone,
    @JsonKey(name: 'expires_at') required final DateTime expiresAt,
  }) = _$PhoneProxySessionImpl;

  factory _PhoneProxySession.fromJson(Map<String, dynamic> json) =
      _$PhoneProxySessionImpl.fromJson;

  @override
  @JsonKey(name: 'session_id')
  String get sessionId;
  @override
  @JsonKey(name: 'proxy_phone')
  String get proxyPhone;
  @override
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt;

  /// Create a copy of PhoneProxySession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhoneProxySessionImplCopyWith<_$PhoneProxySessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
