// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pickup_qr_token.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PickupQrToken _$PickupQrTokenFromJson(Map<String, dynamic> json) {
  return _PickupQrToken.fromJson(json);
}

/// @nodoc
mixin _$PickupQrToken {
  String get token => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// TTL résiduel en secondes (info de confort pour l'UI).
  @JsonKey(name: 'ttl_seconds')
  int? get ttlSeconds => throw _privateConstructorUsedError;

  /// Serializes this PickupQrToken to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PickupQrToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PickupQrTokenCopyWith<PickupQrToken> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PickupQrTokenCopyWith<$Res> {
  factory $PickupQrTokenCopyWith(
    PickupQrToken value,
    $Res Function(PickupQrToken) then,
  ) = _$PickupQrTokenCopyWithImpl<$Res, PickupQrToken>;
  @useResult
  $Res call({
    String token,
    @JsonKey(name: 'expires_at') DateTime expiresAt,
    @JsonKey(name: 'ttl_seconds') int? ttlSeconds,
  });
}

/// @nodoc
class _$PickupQrTokenCopyWithImpl<$Res, $Val extends PickupQrToken>
    implements $PickupQrTokenCopyWith<$Res> {
  _$PickupQrTokenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PickupQrToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? expiresAt = null,
    Object? ttlSeconds = freezed,
  }) {
    return _then(
      _value.copyWith(
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ttlSeconds: freezed == ttlSeconds
                ? _value.ttlSeconds
                : ttlSeconds // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PickupQrTokenImplCopyWith<$Res>
    implements $PickupQrTokenCopyWith<$Res> {
  factory _$$PickupQrTokenImplCopyWith(
    _$PickupQrTokenImpl value,
    $Res Function(_$PickupQrTokenImpl) then,
  ) = __$$PickupQrTokenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String token,
    @JsonKey(name: 'expires_at') DateTime expiresAt,
    @JsonKey(name: 'ttl_seconds') int? ttlSeconds,
  });
}

/// @nodoc
class __$$PickupQrTokenImplCopyWithImpl<$Res>
    extends _$PickupQrTokenCopyWithImpl<$Res, _$PickupQrTokenImpl>
    implements _$$PickupQrTokenImplCopyWith<$Res> {
  __$$PickupQrTokenImplCopyWithImpl(
    _$PickupQrTokenImpl _value,
    $Res Function(_$PickupQrTokenImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PickupQrToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? expiresAt = null,
    Object? ttlSeconds = freezed,
  }) {
    return _then(
      _$PickupQrTokenImpl(
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ttlSeconds: freezed == ttlSeconds
            ? _value.ttlSeconds
            : ttlSeconds // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PickupQrTokenImpl implements _PickupQrToken {
  const _$PickupQrTokenImpl({
    required this.token,
    @JsonKey(name: 'expires_at') required this.expiresAt,
    @JsonKey(name: 'ttl_seconds') this.ttlSeconds,
  });

  factory _$PickupQrTokenImpl.fromJson(Map<String, dynamic> json) =>
      _$$PickupQrTokenImplFromJson(json);

  @override
  final String token;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  /// TTL résiduel en secondes (info de confort pour l'UI).
  @override
  @JsonKey(name: 'ttl_seconds')
  final int? ttlSeconds;

  @override
  String toString() {
    return 'PickupQrToken(token: $token, expiresAt: $expiresAt, ttlSeconds: $ttlSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PickupQrTokenImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.ttlSeconds, ttlSeconds) ||
                other.ttlSeconds == ttlSeconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, expiresAt, ttlSeconds);

  /// Create a copy of PickupQrToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PickupQrTokenImplCopyWith<_$PickupQrTokenImpl> get copyWith =>
      __$$PickupQrTokenImplCopyWithImpl<_$PickupQrTokenImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PickupQrTokenImplToJson(this);
  }
}

abstract class _PickupQrToken implements PickupQrToken {
  const factory _PickupQrToken({
    required final String token,
    @JsonKey(name: 'expires_at') required final DateTime expiresAt,
    @JsonKey(name: 'ttl_seconds') final int? ttlSeconds,
  }) = _$PickupQrTokenImpl;

  factory _PickupQrToken.fromJson(Map<String, dynamic> json) =
      _$PickupQrTokenImpl.fromJson;

  @override
  String get token;
  @override
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt;

  /// TTL résiduel en secondes (info de confort pour l'UI).
  @override
  @JsonKey(name: 'ttl_seconds')
  int? get ttlSeconds;

  /// Create a copy of PickupQrToken
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PickupQrTokenImplCopyWith<_$PickupQrTokenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
