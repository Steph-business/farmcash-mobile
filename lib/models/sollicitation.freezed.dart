// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sollicitation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Sollicitation _$SollicitationFromJson(Map<String, dynamic> json) {
  return _Sollicitation.fromJson(json);
}

/// @nodoc
mixin _$Sollicitation {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'cooperative_id')
  String get cooperativeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'annonce_achat_id')
  String get annonceAchatId => throw _privateConstructorUsedError;
  @JsonKey(name: 'initiated_by')
  String? get initiatedBy => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Audiences cochées à la création : MEMBRES, COOPS_VOISINES, INDEPENDANTS.
  List<String> get audiences => throw _privateConstructorUsedError;
  @JsonKey(name: 'rayon_km')
  @FlexInt()
  int get rayonKm => throw _privateConstructorUsedError;
  @JsonKey(name: 'quantite_cible_kg')
  @FlexDoubleN()
  double? get quantiteCibleKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// OPEN | CLOSED | FULFILLED — laissé en String pour souplesse.
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_recipients')
  @FlexInt()
  int get totalRecipients => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_responses')
  @FlexInt()
  int get totalResponses => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_quantite_offerte')
  @FlexDouble()
  double get totalQuantiteOfferte => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Sollicitation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Sollicitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SollicitationCopyWith<Sollicitation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SollicitationCopyWith<$Res> {
  factory $SollicitationCopyWith(
    Sollicitation value,
    $Res Function(Sollicitation) then,
  ) = _$SollicitationCopyWithImpl<$Res, Sollicitation>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'cooperative_id') String cooperativeId,
    @JsonKey(name: 'annonce_achat_id') String annonceAchatId,
    @JsonKey(name: 'initiated_by') String? initiatedBy,
    String? message,
    List<String> audiences,
    @JsonKey(name: 'rayon_km') @FlexInt() int rayonKm,
    @JsonKey(name: 'quantite_cible_kg') @FlexDoubleN() double? quantiteCibleKg,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    String status,
    @JsonKey(name: 'total_recipients') @FlexInt() int totalRecipients,
    @JsonKey(name: 'total_responses') @FlexInt() int totalResponses,
    @JsonKey(name: 'total_quantite_offerte')
    @FlexDouble()
    double totalQuantiteOfferte,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$SollicitationCopyWithImpl<$Res, $Val extends Sollicitation>
    implements $SollicitationCopyWith<$Res> {
  _$SollicitationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Sollicitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? annonceAchatId = null,
    Object? initiatedBy = freezed,
    Object? message = freezed,
    Object? audiences = null,
    Object? rayonKm = null,
    Object? quantiteCibleKg = freezed,
    Object? expiresAt = freezed,
    Object? status = null,
    Object? totalRecipients = null,
    Object? totalResponses = null,
    Object? totalQuantiteOfferte = null,
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
            annonceAchatId: null == annonceAchatId
                ? _value.annonceAchatId
                : annonceAchatId // ignore: cast_nullable_to_non_nullable
                      as String,
            initiatedBy: freezed == initiatedBy
                ? _value.initiatedBy
                : initiatedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            audiences: null == audiences
                ? _value.audiences
                : audiences // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            rayonKm: null == rayonKm
                ? _value.rayonKm
                : rayonKm // ignore: cast_nullable_to_non_nullable
                      as int,
            quantiteCibleKg: freezed == quantiteCibleKg
                ? _value.quantiteCibleKg
                : quantiteCibleKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            totalRecipients: null == totalRecipients
                ? _value.totalRecipients
                : totalRecipients // ignore: cast_nullable_to_non_nullable
                      as int,
            totalResponses: null == totalResponses
                ? _value.totalResponses
                : totalResponses // ignore: cast_nullable_to_non_nullable
                      as int,
            totalQuantiteOfferte: null == totalQuantiteOfferte
                ? _value.totalQuantiteOfferte
                : totalQuantiteOfferte // ignore: cast_nullable_to_non_nullable
                      as double,
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
abstract class _$$SollicitationImplCopyWith<$Res>
    implements $SollicitationCopyWith<$Res> {
  factory _$$SollicitationImplCopyWith(
    _$SollicitationImpl value,
    $Res Function(_$SollicitationImpl) then,
  ) = __$$SollicitationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'cooperative_id') String cooperativeId,
    @JsonKey(name: 'annonce_achat_id') String annonceAchatId,
    @JsonKey(name: 'initiated_by') String? initiatedBy,
    String? message,
    List<String> audiences,
    @JsonKey(name: 'rayon_km') @FlexInt() int rayonKm,
    @JsonKey(name: 'quantite_cible_kg') @FlexDoubleN() double? quantiteCibleKg,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    String status,
    @JsonKey(name: 'total_recipients') @FlexInt() int totalRecipients,
    @JsonKey(name: 'total_responses') @FlexInt() int totalResponses,
    @JsonKey(name: 'total_quantite_offerte')
    @FlexDouble()
    double totalQuantiteOfferte,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$SollicitationImplCopyWithImpl<$Res>
    extends _$SollicitationCopyWithImpl<$Res, _$SollicitationImpl>
    implements _$$SollicitationImplCopyWith<$Res> {
  __$$SollicitationImplCopyWithImpl(
    _$SollicitationImpl _value,
    $Res Function(_$SollicitationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Sollicitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? annonceAchatId = null,
    Object? initiatedBy = freezed,
    Object? message = freezed,
    Object? audiences = null,
    Object? rayonKm = null,
    Object? quantiteCibleKg = freezed,
    Object? expiresAt = freezed,
    Object? status = null,
    Object? totalRecipients = null,
    Object? totalResponses = null,
    Object? totalQuantiteOfferte = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$SollicitationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        cooperativeId: null == cooperativeId
            ? _value.cooperativeId
            : cooperativeId // ignore: cast_nullable_to_non_nullable
                  as String,
        annonceAchatId: null == annonceAchatId
            ? _value.annonceAchatId
            : annonceAchatId // ignore: cast_nullable_to_non_nullable
                  as String,
        initiatedBy: freezed == initiatedBy
            ? _value.initiatedBy
            : initiatedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        audiences: null == audiences
            ? _value._audiences
            : audiences // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        rayonKm: null == rayonKm
            ? _value.rayonKm
            : rayonKm // ignore: cast_nullable_to_non_nullable
                  as int,
        quantiteCibleKg: freezed == quantiteCibleKg
            ? _value.quantiteCibleKg
            : quantiteCibleKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        totalRecipients: null == totalRecipients
            ? _value.totalRecipients
            : totalRecipients // ignore: cast_nullable_to_non_nullable
                  as int,
        totalResponses: null == totalResponses
            ? _value.totalResponses
            : totalResponses // ignore: cast_nullable_to_non_nullable
                  as int,
        totalQuantiteOfferte: null == totalQuantiteOfferte
            ? _value.totalQuantiteOfferte
            : totalQuantiteOfferte // ignore: cast_nullable_to_non_nullable
                  as double,
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
class _$SollicitationImpl implements _Sollicitation {
  const _$SollicitationImpl({
    required this.id,
    @JsonKey(name: 'cooperative_id') required this.cooperativeId,
    @JsonKey(name: 'annonce_achat_id') required this.annonceAchatId,
    @JsonKey(name: 'initiated_by') this.initiatedBy,
    this.message,
    final List<String> audiences = const <String>[],
    @JsonKey(name: 'rayon_km') @FlexInt() this.rayonKm = 50,
    @JsonKey(name: 'quantite_cible_kg') @FlexDoubleN() this.quantiteCibleKg,
    @JsonKey(name: 'expires_at') this.expiresAt,
    this.status = 'OPEN',
    @JsonKey(name: 'total_recipients') @FlexInt() this.totalRecipients = 0,
    @JsonKey(name: 'total_responses') @FlexInt() this.totalResponses = 0,
    @JsonKey(name: 'total_quantite_offerte')
    @FlexDouble()
    this.totalQuantiteOfferte = 0,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : _audiences = audiences;

  factory _$SollicitationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SollicitationImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'cooperative_id')
  final String cooperativeId;
  @override
  @JsonKey(name: 'annonce_achat_id')
  final String annonceAchatId;
  @override
  @JsonKey(name: 'initiated_by')
  final String? initiatedBy;
  @override
  final String? message;

  /// Audiences cochées à la création : MEMBRES, COOPS_VOISINES, INDEPENDANTS.
  final List<String> _audiences;

  /// Audiences cochées à la création : MEMBRES, COOPS_VOISINES, INDEPENDANTS.
  @override
  @JsonKey()
  List<String> get audiences {
    if (_audiences is EqualUnmodifiableListView) return _audiences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_audiences);
  }

  @override
  @JsonKey(name: 'rayon_km')
  @FlexInt()
  final int rayonKm;
  @override
  @JsonKey(name: 'quantite_cible_kg')
  @FlexDoubleN()
  final double? quantiteCibleKg;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  /// OPEN | CLOSED | FULFILLED — laissé en String pour souplesse.
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'total_recipients')
  @FlexInt()
  final int totalRecipients;
  @override
  @JsonKey(name: 'total_responses')
  @FlexInt()
  final int totalResponses;
  @override
  @JsonKey(name: 'total_quantite_offerte')
  @FlexDouble()
  final double totalQuantiteOfferte;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Sollicitation(id: $id, cooperativeId: $cooperativeId, annonceAchatId: $annonceAchatId, initiatedBy: $initiatedBy, message: $message, audiences: $audiences, rayonKm: $rayonKm, quantiteCibleKg: $quantiteCibleKg, expiresAt: $expiresAt, status: $status, totalRecipients: $totalRecipients, totalResponses: $totalResponses, totalQuantiteOfferte: $totalQuantiteOfferte, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SollicitationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cooperativeId, cooperativeId) ||
                other.cooperativeId == cooperativeId) &&
            (identical(other.annonceAchatId, annonceAchatId) ||
                other.annonceAchatId == annonceAchatId) &&
            (identical(other.initiatedBy, initiatedBy) ||
                other.initiatedBy == initiatedBy) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(
              other._audiences,
              _audiences,
            ) &&
            (identical(other.rayonKm, rayonKm) || other.rayonKm == rayonKm) &&
            (identical(other.quantiteCibleKg, quantiteCibleKg) ||
                other.quantiteCibleKg == quantiteCibleKg) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalRecipients, totalRecipients) ||
                other.totalRecipients == totalRecipients) &&
            (identical(other.totalResponses, totalResponses) ||
                other.totalResponses == totalResponses) &&
            (identical(other.totalQuantiteOfferte, totalQuantiteOfferte) ||
                other.totalQuantiteOfferte == totalQuantiteOfferte) &&
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
    annonceAchatId,
    initiatedBy,
    message,
    const DeepCollectionEquality().hash(_audiences),
    rayonKm,
    quantiteCibleKg,
    expiresAt,
    status,
    totalRecipients,
    totalResponses,
    totalQuantiteOfferte,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Sollicitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SollicitationImplCopyWith<_$SollicitationImpl> get copyWith =>
      __$$SollicitationImplCopyWithImpl<_$SollicitationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SollicitationImplToJson(this);
  }
}

abstract class _Sollicitation implements Sollicitation {
  const factory _Sollicitation({
    required final String id,
    @JsonKey(name: 'cooperative_id') required final String cooperativeId,
    @JsonKey(name: 'annonce_achat_id') required final String annonceAchatId,
    @JsonKey(name: 'initiated_by') final String? initiatedBy,
    final String? message,
    final List<String> audiences,
    @JsonKey(name: 'rayon_km') @FlexInt() final int rayonKm,
    @JsonKey(name: 'quantite_cible_kg')
    @FlexDoubleN()
    final double? quantiteCibleKg,
    @JsonKey(name: 'expires_at') final DateTime? expiresAt,
    final String status,
    @JsonKey(name: 'total_recipients') @FlexInt() final int totalRecipients,
    @JsonKey(name: 'total_responses') @FlexInt() final int totalResponses,
    @JsonKey(name: 'total_quantite_offerte')
    @FlexDouble()
    final double totalQuantiteOfferte,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$SollicitationImpl;

  factory _Sollicitation.fromJson(Map<String, dynamic> json) =
      _$SollicitationImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'cooperative_id')
  String get cooperativeId;
  @override
  @JsonKey(name: 'annonce_achat_id')
  String get annonceAchatId;
  @override
  @JsonKey(name: 'initiated_by')
  String? get initiatedBy;
  @override
  String? get message;

  /// Audiences cochées à la création : MEMBRES, COOPS_VOISINES, INDEPENDANTS.
  @override
  List<String> get audiences;
  @override
  @JsonKey(name: 'rayon_km')
  @FlexInt()
  int get rayonKm;
  @override
  @JsonKey(name: 'quantite_cible_kg')
  @FlexDoubleN()
  double? get quantiteCibleKg;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;

  /// OPEN | CLOSED | FULFILLED — laissé en String pour souplesse.
  @override
  String get status;
  @override
  @JsonKey(name: 'total_recipients')
  @FlexInt()
  int get totalRecipients;
  @override
  @JsonKey(name: 'total_responses')
  @FlexInt()
  int get totalResponses;
  @override
  @JsonKey(name: 'total_quantite_offerte')
  @FlexDouble()
  double get totalQuantiteOfferte;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Sollicitation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SollicitationImplCopyWith<_$SollicitationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SollicitationRecipient _$SollicitationRecipientFromJson(
  Map<String, dynamic> json,
) {
  return _SollicitationRecipient.fromJson(json);
}

/// @nodoc
mixin _$SollicitationRecipient {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'sollicitation_id')
  String get sollicitationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'audience_segment')
  String get audienceSegment => throw _privateConstructorUsedError;
  @JsonKey(name: 'cooperative_id')
  String? get cooperativeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'notification_id')
  String? get notificationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'sms_sent_at')
  DateTime? get smsSentAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'opened_at')
  DateTime? get openedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'responded_at')
  DateTime? get respondedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'response_action')
  String? get responseAction => throw _privateConstructorUsedError;
  @JsonKey(name: 'response_quantite_kg')
  @FlexDoubleN()
  double? get responseQuantiteKg => throw _privateConstructorUsedError;

  /// Serializes this SollicitationRecipient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SollicitationRecipient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SollicitationRecipientCopyWith<SollicitationRecipient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SollicitationRecipientCopyWith<$Res> {
  factory $SollicitationRecipientCopyWith(
    SollicitationRecipient value,
    $Res Function(SollicitationRecipient) then,
  ) = _$SollicitationRecipientCopyWithImpl<$Res, SollicitationRecipient>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'sollicitation_id') String sollicitationId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'audience_segment') String audienceSegment,
    @JsonKey(name: 'cooperative_id') String? cooperativeId,
    @JsonKey(name: 'notification_id') String? notificationId,
    @JsonKey(name: 'sms_sent_at') DateTime? smsSentAt,
    @JsonKey(name: 'opened_at') DateTime? openedAt,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'response_action') String? responseAction,
    @JsonKey(name: 'response_quantite_kg')
    @FlexDoubleN()
    double? responseQuantiteKg,
  });
}

/// @nodoc
class _$SollicitationRecipientCopyWithImpl<
  $Res,
  $Val extends SollicitationRecipient
>
    implements $SollicitationRecipientCopyWith<$Res> {
  _$SollicitationRecipientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SollicitationRecipient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sollicitationId = null,
    Object? userId = null,
    Object? audienceSegment = null,
    Object? cooperativeId = freezed,
    Object? notificationId = freezed,
    Object? smsSentAt = freezed,
    Object? openedAt = freezed,
    Object? respondedAt = freezed,
    Object? responseAction = freezed,
    Object? responseQuantiteKg = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sollicitationId: null == sollicitationId
                ? _value.sollicitationId
                : sollicitationId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            audienceSegment: null == audienceSegment
                ? _value.audienceSegment
                : audienceSegment // ignore: cast_nullable_to_non_nullable
                      as String,
            cooperativeId: freezed == cooperativeId
                ? _value.cooperativeId
                : cooperativeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            notificationId: freezed == notificationId
                ? _value.notificationId
                : notificationId // ignore: cast_nullable_to_non_nullable
                      as String?,
            smsSentAt: freezed == smsSentAt
                ? _value.smsSentAt
                : smsSentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            openedAt: freezed == openedAt
                ? _value.openedAt
                : openedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            respondedAt: freezed == respondedAt
                ? _value.respondedAt
                : respondedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            responseAction: freezed == responseAction
                ? _value.responseAction
                : responseAction // ignore: cast_nullable_to_non_nullable
                      as String?,
            responseQuantiteKg: freezed == responseQuantiteKg
                ? _value.responseQuantiteKg
                : responseQuantiteKg // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SollicitationRecipientImplCopyWith<$Res>
    implements $SollicitationRecipientCopyWith<$Res> {
  factory _$$SollicitationRecipientImplCopyWith(
    _$SollicitationRecipientImpl value,
    $Res Function(_$SollicitationRecipientImpl) then,
  ) = __$$SollicitationRecipientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'sollicitation_id') String sollicitationId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'audience_segment') String audienceSegment,
    @JsonKey(name: 'cooperative_id') String? cooperativeId,
    @JsonKey(name: 'notification_id') String? notificationId,
    @JsonKey(name: 'sms_sent_at') DateTime? smsSentAt,
    @JsonKey(name: 'opened_at') DateTime? openedAt,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'response_action') String? responseAction,
    @JsonKey(name: 'response_quantite_kg')
    @FlexDoubleN()
    double? responseQuantiteKg,
  });
}

/// @nodoc
class __$$SollicitationRecipientImplCopyWithImpl<$Res>
    extends
        _$SollicitationRecipientCopyWithImpl<$Res, _$SollicitationRecipientImpl>
    implements _$$SollicitationRecipientImplCopyWith<$Res> {
  __$$SollicitationRecipientImplCopyWithImpl(
    _$SollicitationRecipientImpl _value,
    $Res Function(_$SollicitationRecipientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SollicitationRecipient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sollicitationId = null,
    Object? userId = null,
    Object? audienceSegment = null,
    Object? cooperativeId = freezed,
    Object? notificationId = freezed,
    Object? smsSentAt = freezed,
    Object? openedAt = freezed,
    Object? respondedAt = freezed,
    Object? responseAction = freezed,
    Object? responseQuantiteKg = freezed,
  }) {
    return _then(
      _$SollicitationRecipientImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sollicitationId: null == sollicitationId
            ? _value.sollicitationId
            : sollicitationId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        audienceSegment: null == audienceSegment
            ? _value.audienceSegment
            : audienceSegment // ignore: cast_nullable_to_non_nullable
                  as String,
        cooperativeId: freezed == cooperativeId
            ? _value.cooperativeId
            : cooperativeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        notificationId: freezed == notificationId
            ? _value.notificationId
            : notificationId // ignore: cast_nullable_to_non_nullable
                  as String?,
        smsSentAt: freezed == smsSentAt
            ? _value.smsSentAt
            : smsSentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        openedAt: freezed == openedAt
            ? _value.openedAt
            : openedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        respondedAt: freezed == respondedAt
            ? _value.respondedAt
            : respondedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        responseAction: freezed == responseAction
            ? _value.responseAction
            : responseAction // ignore: cast_nullable_to_non_nullable
                  as String?,
        responseQuantiteKg: freezed == responseQuantiteKg
            ? _value.responseQuantiteKg
            : responseQuantiteKg // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SollicitationRecipientImpl implements _SollicitationRecipient {
  const _$SollicitationRecipientImpl({
    required this.id,
    @JsonKey(name: 'sollicitation_id') required this.sollicitationId,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'audience_segment') required this.audienceSegment,
    @JsonKey(name: 'cooperative_id') this.cooperativeId,
    @JsonKey(name: 'notification_id') this.notificationId,
    @JsonKey(name: 'sms_sent_at') this.smsSentAt,
    @JsonKey(name: 'opened_at') this.openedAt,
    @JsonKey(name: 'responded_at') this.respondedAt,
    @JsonKey(name: 'response_action') this.responseAction,
    @JsonKey(name: 'response_quantite_kg')
    @FlexDoubleN()
    this.responseQuantiteKg,
  });

  factory _$SollicitationRecipientImpl.fromJson(Map<String, dynamic> json) =>
      _$$SollicitationRecipientImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'sollicitation_id')
  final String sollicitationId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'audience_segment')
  final String audienceSegment;
  @override
  @JsonKey(name: 'cooperative_id')
  final String? cooperativeId;
  @override
  @JsonKey(name: 'notification_id')
  final String? notificationId;
  @override
  @JsonKey(name: 'sms_sent_at')
  final DateTime? smsSentAt;
  @override
  @JsonKey(name: 'opened_at')
  final DateTime? openedAt;
  @override
  @JsonKey(name: 'responded_at')
  final DateTime? respondedAt;
  @override
  @JsonKey(name: 'response_action')
  final String? responseAction;
  @override
  @JsonKey(name: 'response_quantite_kg')
  @FlexDoubleN()
  final double? responseQuantiteKg;

  @override
  String toString() {
    return 'SollicitationRecipient(id: $id, sollicitationId: $sollicitationId, userId: $userId, audienceSegment: $audienceSegment, cooperativeId: $cooperativeId, notificationId: $notificationId, smsSentAt: $smsSentAt, openedAt: $openedAt, respondedAt: $respondedAt, responseAction: $responseAction, responseQuantiteKg: $responseQuantiteKg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SollicitationRecipientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sollicitationId, sollicitationId) ||
                other.sollicitationId == sollicitationId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.audienceSegment, audienceSegment) ||
                other.audienceSegment == audienceSegment) &&
            (identical(other.cooperativeId, cooperativeId) ||
                other.cooperativeId == cooperativeId) &&
            (identical(other.notificationId, notificationId) ||
                other.notificationId == notificationId) &&
            (identical(other.smsSentAt, smsSentAt) ||
                other.smsSentAt == smsSentAt) &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt) &&
            (identical(other.responseAction, responseAction) ||
                other.responseAction == responseAction) &&
            (identical(other.responseQuantiteKg, responseQuantiteKg) ||
                other.responseQuantiteKg == responseQuantiteKg));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sollicitationId,
    userId,
    audienceSegment,
    cooperativeId,
    notificationId,
    smsSentAt,
    openedAt,
    respondedAt,
    responseAction,
    responseQuantiteKg,
  );

  /// Create a copy of SollicitationRecipient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SollicitationRecipientImplCopyWith<_$SollicitationRecipientImpl>
  get copyWith =>
      __$$SollicitationRecipientImplCopyWithImpl<_$SollicitationRecipientImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SollicitationRecipientImplToJson(this);
  }
}

abstract class _SollicitationRecipient implements SollicitationRecipient {
  const factory _SollicitationRecipient({
    required final String id,
    @JsonKey(name: 'sollicitation_id') required final String sollicitationId,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'audience_segment') required final String audienceSegment,
    @JsonKey(name: 'cooperative_id') final String? cooperativeId,
    @JsonKey(name: 'notification_id') final String? notificationId,
    @JsonKey(name: 'sms_sent_at') final DateTime? smsSentAt,
    @JsonKey(name: 'opened_at') final DateTime? openedAt,
    @JsonKey(name: 'responded_at') final DateTime? respondedAt,
    @JsonKey(name: 'response_action') final String? responseAction,
    @JsonKey(name: 'response_quantite_kg')
    @FlexDoubleN()
    final double? responseQuantiteKg,
  }) = _$SollicitationRecipientImpl;

  factory _SollicitationRecipient.fromJson(Map<String, dynamic> json) =
      _$SollicitationRecipientImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'sollicitation_id')
  String get sollicitationId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'audience_segment')
  String get audienceSegment;
  @override
  @JsonKey(name: 'cooperative_id')
  String? get cooperativeId;
  @override
  @JsonKey(name: 'notification_id')
  String? get notificationId;
  @override
  @JsonKey(name: 'sms_sent_at')
  DateTime? get smsSentAt;
  @override
  @JsonKey(name: 'opened_at')
  DateTime? get openedAt;
  @override
  @JsonKey(name: 'responded_at')
  DateTime? get respondedAt;
  @override
  @JsonKey(name: 'response_action')
  String? get responseAction;
  @override
  @JsonKey(name: 'response_quantite_kg')
  @FlexDoubleN()
  double? get responseQuantiteKg;

  /// Create a copy of SollicitationRecipient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SollicitationRecipientImplCopyWith<_$SollicitationRecipientImpl>
  get copyWith => throw _privateConstructorUsedError;
}
