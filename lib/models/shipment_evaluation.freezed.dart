// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shipment_evaluation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShipmentEvaluation _$ShipmentEvaluationFromJson(Map<String, dynamic> json) {
  return _ShipmentEvaluation.fromJson(json);
}

/// @nodoc
mixin _$ShipmentEvaluation {
  String get id => throw _privateConstructorUsedError;
  String get reviewerId => throw _privateConstructorUsedError;
  String get reviewedUserId => throw _privateConstructorUsedError;
  int get note => throw _privateConstructorUsedError;
  String? get commentaire => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ShipmentEvaluation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShipmentEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShipmentEvaluationCopyWith<ShipmentEvaluation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShipmentEvaluationCopyWith<$Res> {
  factory $ShipmentEvaluationCopyWith(
    ShipmentEvaluation value,
    $Res Function(ShipmentEvaluation) then,
  ) = _$ShipmentEvaluationCopyWithImpl<$Res, ShipmentEvaluation>;
  @useResult
  $Res call({
    String id,
    String reviewerId,
    String reviewedUserId,
    int note,
    String? commentaire,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$ShipmentEvaluationCopyWithImpl<$Res, $Val extends ShipmentEvaluation>
    implements $ShipmentEvaluationCopyWith<$Res> {
  _$ShipmentEvaluationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShipmentEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reviewerId = null,
    Object? reviewedUserId = null,
    Object? note = null,
    Object? commentaire = freezed,
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
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as int,
            commentaire: freezed == commentaire
                ? _value.commentaire
                : commentaire // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ShipmentEvaluationImplCopyWith<$Res>
    implements $ShipmentEvaluationCopyWith<$Res> {
  factory _$$ShipmentEvaluationImplCopyWith(
    _$ShipmentEvaluationImpl value,
    $Res Function(_$ShipmentEvaluationImpl) then,
  ) = __$$ShipmentEvaluationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String reviewerId,
    String reviewedUserId,
    int note,
    String? commentaire,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$ShipmentEvaluationImplCopyWithImpl<$Res>
    extends _$ShipmentEvaluationCopyWithImpl<$Res, _$ShipmentEvaluationImpl>
    implements _$$ShipmentEvaluationImplCopyWith<$Res> {
  __$$ShipmentEvaluationImplCopyWithImpl(
    _$ShipmentEvaluationImpl _value,
    $Res Function(_$ShipmentEvaluationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShipmentEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reviewerId = null,
    Object? reviewedUserId = null,
    Object? note = null,
    Object? commentaire = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ShipmentEvaluationImpl(
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
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as int,
        commentaire: freezed == commentaire
            ? _value.commentaire
            : commentaire // ignore: cast_nullable_to_non_nullable
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
class _$ShipmentEvaluationImpl implements _ShipmentEvaluation {
  const _$ShipmentEvaluationImpl({
    required this.id,
    required this.reviewerId,
    required this.reviewedUserId,
    this.note = 0,
    this.commentaire,
    this.createdAt,
  });

  factory _$ShipmentEvaluationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShipmentEvaluationImplFromJson(json);

  @override
  final String id;
  @override
  final String reviewerId;
  @override
  final String reviewedUserId;
  @override
  @JsonKey()
  final int note;
  @override
  final String? commentaire;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ShipmentEvaluation(id: $id, reviewerId: $reviewerId, reviewedUserId: $reviewedUserId, note: $note, commentaire: $commentaire, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShipmentEvaluationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reviewerId, reviewerId) ||
                other.reviewerId == reviewerId) &&
            (identical(other.reviewedUserId, reviewedUserId) ||
                other.reviewedUserId == reviewedUserId) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.commentaire, commentaire) ||
                other.commentaire == commentaire) &&
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
    note,
    commentaire,
    createdAt,
  );

  /// Create a copy of ShipmentEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShipmentEvaluationImplCopyWith<_$ShipmentEvaluationImpl> get copyWith =>
      __$$ShipmentEvaluationImplCopyWithImpl<_$ShipmentEvaluationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShipmentEvaluationImplToJson(this);
  }
}

abstract class _ShipmentEvaluation implements ShipmentEvaluation {
  const factory _ShipmentEvaluation({
    required final String id,
    required final String reviewerId,
    required final String reviewedUserId,
    final int note,
    final String? commentaire,
    final DateTime? createdAt,
  }) = _$ShipmentEvaluationImpl;

  factory _ShipmentEvaluation.fromJson(Map<String, dynamic> json) =
      _$ShipmentEvaluationImpl.fromJson;

  @override
  String get id;
  @override
  String get reviewerId;
  @override
  String get reviewedUserId;
  @override
  int get note;
  @override
  String? get commentaire;
  @override
  DateTime? get createdAt;

  /// Create a copy of ShipmentEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShipmentEvaluationImplCopyWith<_$ShipmentEvaluationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
