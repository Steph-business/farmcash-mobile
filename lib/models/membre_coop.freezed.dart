// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membre_coop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MembreCoop _$MembreCoopFromJson(Map<String, dynamic> json) {
  return _MembreCoop.fromJson(json);
}

/// @nodoc
mixin _$MembreCoop {
  String get id => throw _privateConstructorUsedError;
  String get cooperativeId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  Utilisateur? get user => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: CoopMemberRole.unknown)
  CoopMemberRole get role => throw _privateConstructorUsedError;
  DateTime? get joinedAt => throw _privateConstructorUsedError;

  /// Serializes this MembreCoop to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MembreCoop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembreCoopCopyWith<MembreCoop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembreCoopCopyWith<$Res> {
  factory $MembreCoopCopyWith(
    MembreCoop value,
    $Res Function(MembreCoop) then,
  ) = _$MembreCoopCopyWithImpl<$Res, MembreCoop>;
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String userId,
    Utilisateur? user,
    @JsonKey(unknownEnumValue: CoopMemberRole.unknown) CoopMemberRole role,
    DateTime? joinedAt,
  });

  $UtilisateurCopyWith<$Res>? get user;
}

/// @nodoc
class _$MembreCoopCopyWithImpl<$Res, $Val extends MembreCoop>
    implements $MembreCoopCopyWith<$Res> {
  _$MembreCoopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MembreCoop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? userId = null,
    Object? user = freezed,
    Object? role = null,
    Object? joinedAt = freezed,
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
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as Utilisateur?,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as CoopMemberRole,
            joinedAt: freezed == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of MembreCoop
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
abstract class _$$MembreCoopImplCopyWith<$Res>
    implements $MembreCoopCopyWith<$Res> {
  factory _$$MembreCoopImplCopyWith(
    _$MembreCoopImpl value,
    $Res Function(_$MembreCoopImpl) then,
  ) = __$$MembreCoopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String userId,
    Utilisateur? user,
    @JsonKey(unknownEnumValue: CoopMemberRole.unknown) CoopMemberRole role,
    DateTime? joinedAt,
  });

  @override
  $UtilisateurCopyWith<$Res>? get user;
}

/// @nodoc
class __$$MembreCoopImplCopyWithImpl<$Res>
    extends _$MembreCoopCopyWithImpl<$Res, _$MembreCoopImpl>
    implements _$$MembreCoopImplCopyWith<$Res> {
  __$$MembreCoopImplCopyWithImpl(
    _$MembreCoopImpl _value,
    $Res Function(_$MembreCoopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MembreCoop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? userId = null,
    Object? user = freezed,
    Object? role = null,
    Object? joinedAt = freezed,
  }) {
    return _then(
      _$MembreCoopImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        cooperativeId: null == cooperativeId
            ? _value.cooperativeId
            : cooperativeId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as Utilisateur?,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as CoopMemberRole,
        joinedAt: freezed == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MembreCoopImpl extends _MembreCoop {
  const _$MembreCoopImpl({
    required this.id,
    required this.cooperativeId,
    required this.userId,
    this.user,
    @JsonKey(unknownEnumValue: CoopMemberRole.unknown)
    this.role = CoopMemberRole.membre,
    this.joinedAt,
  }) : super._();

  factory _$MembreCoopImpl.fromJson(Map<String, dynamic> json) =>
      _$$MembreCoopImplFromJson(json);

  @override
  final String id;
  @override
  final String cooperativeId;
  @override
  final String userId;
  @override
  final Utilisateur? user;
  @override
  @JsonKey(unknownEnumValue: CoopMemberRole.unknown)
  final CoopMemberRole role;
  @override
  final DateTime? joinedAt;

  @override
  String toString() {
    return 'MembreCoop(id: $id, cooperativeId: $cooperativeId, userId: $userId, user: $user, role: $role, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembreCoopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cooperativeId, cooperativeId) ||
                other.cooperativeId == cooperativeId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, cooperativeId, userId, user, role, joinedAt);

  /// Create a copy of MembreCoop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembreCoopImplCopyWith<_$MembreCoopImpl> get copyWith =>
      __$$MembreCoopImplCopyWithImpl<_$MembreCoopImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MembreCoopImplToJson(this);
  }
}

abstract class _MembreCoop extends MembreCoop {
  const factory _MembreCoop({
    required final String id,
    required final String cooperativeId,
    required final String userId,
    final Utilisateur? user,
    @JsonKey(unknownEnumValue: CoopMemberRole.unknown)
    final CoopMemberRole role,
    final DateTime? joinedAt,
  }) = _$MembreCoopImpl;
  const _MembreCoop._() : super._();

  factory _MembreCoop.fromJson(Map<String, dynamic> json) =
      _$MembreCoopImpl.fromJson;

  @override
  String get id;
  @override
  String get cooperativeId;
  @override
  String get userId;
  @override
  Utilisateur? get user;
  @override
  @JsonKey(unknownEnumValue: CoopMemberRole.unknown)
  CoopMemberRole get role;
  @override
  DateTime? get joinedAt;

  /// Create a copy of MembreCoop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembreCoopImplCopyWith<_$MembreCoopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoopJoinRequest _$CoopJoinRequestFromJson(Map<String, dynamic> json) {
  return _CoopJoinRequest.fromJson(json);
}

/// @nodoc
mixin _$CoopJoinRequest {
  String get id => throw _privateConstructorUsedError;
  String get cooperativeId => throw _privateConstructorUsedError;
  String get farmerId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CoopJoinRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoopJoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoopJoinRequestCopyWith<CoopJoinRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoopJoinRequestCopyWith<$Res> {
  factory $CoopJoinRequestCopyWith(
    CoopJoinRequest value,
    $Res Function(CoopJoinRequest) then,
  ) = _$CoopJoinRequestCopyWithImpl<$Res, CoopJoinRequest>;
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String farmerId,
    String status,
    String? message,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$CoopJoinRequestCopyWithImpl<$Res, $Val extends CoopJoinRequest>
    implements $CoopJoinRequestCopyWith<$Res> {
  _$CoopJoinRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoopJoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? farmerId = null,
    Object? status = null,
    Object? message = freezed,
    Object? createdAt = freezed,
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
            farmerId: null == farmerId
                ? _value.farmerId
                : farmerId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CoopJoinRequestImplCopyWith<$Res>
    implements $CoopJoinRequestCopyWith<$Res> {
  factory _$$CoopJoinRequestImplCopyWith(
    _$CoopJoinRequestImpl value,
    $Res Function(_$CoopJoinRequestImpl) then,
  ) = __$$CoopJoinRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String farmerId,
    String status,
    String? message,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$CoopJoinRequestImplCopyWithImpl<$Res>
    extends _$CoopJoinRequestCopyWithImpl<$Res, _$CoopJoinRequestImpl>
    implements _$$CoopJoinRequestImplCopyWith<$Res> {
  __$$CoopJoinRequestImplCopyWithImpl(
    _$CoopJoinRequestImpl _value,
    $Res Function(_$CoopJoinRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CoopJoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? farmerId = null,
    Object? status = null,
    Object? message = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$CoopJoinRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        cooperativeId: null == cooperativeId
            ? _value.cooperativeId
            : cooperativeId // ignore: cast_nullable_to_non_nullable
                  as String,
        farmerId: null == farmerId
            ? _value.farmerId
            : farmerId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
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
class _$CoopJoinRequestImpl implements _CoopJoinRequest {
  const _$CoopJoinRequestImpl({
    required this.id,
    required this.cooperativeId,
    required this.farmerId,
    this.status = 'PENDING',
    this.message,
    this.createdAt,
  });

  factory _$CoopJoinRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoopJoinRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String cooperativeId;
  @override
  final String farmerId;
  @override
  @JsonKey()
  final String status;
  @override
  final String? message;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CoopJoinRequest(id: $id, cooperativeId: $cooperativeId, farmerId: $farmerId, status: $status, message: $message, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoopJoinRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cooperativeId, cooperativeId) ||
                other.cooperativeId == cooperativeId) &&
            (identical(other.farmerId, farmerId) ||
                other.farmerId == farmerId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    cooperativeId,
    farmerId,
    status,
    message,
    createdAt,
  );

  /// Create a copy of CoopJoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoopJoinRequestImplCopyWith<_$CoopJoinRequestImpl> get copyWith =>
      __$$CoopJoinRequestImplCopyWithImpl<_$CoopJoinRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CoopJoinRequestImplToJson(this);
  }
}

abstract class _CoopJoinRequest implements CoopJoinRequest {
  const factory _CoopJoinRequest({
    required final String id,
    required final String cooperativeId,
    required final String farmerId,
    final String status,
    final String? message,
    final DateTime? createdAt,
  }) = _$CoopJoinRequestImpl;

  factory _CoopJoinRequest.fromJson(Map<String, dynamic> json) =
      _$CoopJoinRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get cooperativeId;
  @override
  String get farmerId;
  @override
  String get status;
  @override
  String? get message;
  @override
  DateTime? get createdAt;

  /// Create a copy of CoopJoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoopJoinRequestImplCopyWith<_$CoopJoinRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoopInvitation _$CoopInvitationFromJson(Map<String, dynamic> json) {
  return _CoopInvitation.fromJson(json);
}

/// @nodoc
mixin _$CoopInvitation {
  String get id => throw _privateConstructorUsedError;
  String get cooperativeId => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CoopInvitation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoopInvitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoopInvitationCopyWith<CoopInvitation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoopInvitationCopyWith<$Res> {
  factory $CoopInvitationCopyWith(
    CoopInvitation value,
    $Res Function(CoopInvitation) then,
  ) = _$CoopInvitationCopyWithImpl<$Res, CoopInvitation>;
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String phone,
    String status,
    String? message,
    DateTime? expiresAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$CoopInvitationCopyWithImpl<$Res, $Val extends CoopInvitation>
    implements $CoopInvitationCopyWith<$Res> {
  _$CoopInvitationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoopInvitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? phone = null,
    Object? status = null,
    Object? message = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = freezed,
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
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$CoopInvitationImplCopyWith<$Res>
    implements $CoopInvitationCopyWith<$Res> {
  factory _$$CoopInvitationImplCopyWith(
    _$CoopInvitationImpl value,
    $Res Function(_$CoopInvitationImpl) then,
  ) = __$$CoopInvitationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String phone,
    String status,
    String? message,
    DateTime? expiresAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$CoopInvitationImplCopyWithImpl<$Res>
    extends _$CoopInvitationCopyWithImpl<$Res, _$CoopInvitationImpl>
    implements _$$CoopInvitationImplCopyWith<$Res> {
  __$$CoopInvitationImplCopyWithImpl(
    _$CoopInvitationImpl _value,
    $Res Function(_$CoopInvitationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CoopInvitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? phone = null,
    Object? status = null,
    Object? message = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$CoopInvitationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        cooperativeId: null == cooperativeId
            ? _value.cooperativeId
            : cooperativeId // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$CoopInvitationImpl implements _CoopInvitation {
  const _$CoopInvitationImpl({
    required this.id,
    required this.cooperativeId,
    this.phone = '',
    this.status = 'PENDING',
    this.message,
    this.expiresAt,
    this.createdAt,
  });

  factory _$CoopInvitationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoopInvitationImplFromJson(json);

  @override
  final String id;
  @override
  final String cooperativeId;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String status;
  @override
  final String? message;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CoopInvitation(id: $id, cooperativeId: $cooperativeId, phone: $phone, status: $status, message: $message, expiresAt: $expiresAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoopInvitationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cooperativeId, cooperativeId) ||
                other.cooperativeId == cooperativeId) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    cooperativeId,
    phone,
    status,
    message,
    expiresAt,
    createdAt,
  );

  /// Create a copy of CoopInvitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoopInvitationImplCopyWith<_$CoopInvitationImpl> get copyWith =>
      __$$CoopInvitationImplCopyWithImpl<_$CoopInvitationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CoopInvitationImplToJson(this);
  }
}

abstract class _CoopInvitation implements CoopInvitation {
  const factory _CoopInvitation({
    required final String id,
    required final String cooperativeId,
    final String phone,
    final String status,
    final String? message,
    final DateTime? expiresAt,
    final DateTime? createdAt,
  }) = _$CoopInvitationImpl;

  factory _CoopInvitation.fromJson(Map<String, dynamic> json) =
      _$CoopInvitationImpl.fromJson;

  @override
  String get id;
  @override
  String get cooperativeId;
  @override
  String get phone;
  @override
  String get status;
  @override
  String? get message;
  @override
  DateTime? get expiresAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of CoopInvitation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoopInvitationImplCopyWith<_$CoopInvitationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
