// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'avance_coop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AvanceCoop _$AvanceCoopFromJson(Map<String, dynamic> json) {
  return _AvanceCoop.fromJson(json);
}

/// @nodoc
mixin _$AvanceCoop {
  String get id => throw _privateConstructorUsedError;
  String get cooperativeId => throw _privateConstructorUsedError;
  String get farmerId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get amount => throw _privateConstructorUsedError;
  String? get annonceVenteId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: CoopAdvanceStatus.unknown)
  CoopAdvanceStatus get status => throw _privateConstructorUsedError;
  String? get motif => throw _privateConstructorUsedError;
  DateTime? get paidAt => throw _privateConstructorUsedError;
  DateTime? get reimbursedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AvanceCoop to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AvanceCoop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvanceCoopCopyWith<AvanceCoop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvanceCoopCopyWith<$Res> {
  factory $AvanceCoopCopyWith(
    AvanceCoop value,
    $Res Function(AvanceCoop) then,
  ) = _$AvanceCoopCopyWithImpl<$Res, AvanceCoop>;
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String farmerId,
    @FlexDouble() double amount,
    String? annonceVenteId,
    @JsonKey(unknownEnumValue: CoopAdvanceStatus.unknown)
    CoopAdvanceStatus status,
    String? motif,
    DateTime? paidAt,
    DateTime? reimbursedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$AvanceCoopCopyWithImpl<$Res, $Val extends AvanceCoop>
    implements $AvanceCoopCopyWith<$Res> {
  _$AvanceCoopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AvanceCoop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? farmerId = null,
    Object? amount = null,
    Object? annonceVenteId = freezed,
    Object? status = null,
    Object? motif = freezed,
    Object? paidAt = freezed,
    Object? reimbursedAt = freezed,
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
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            annonceVenteId: freezed == annonceVenteId
                ? _value.annonceVenteId
                : annonceVenteId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as CoopAdvanceStatus,
            motif: freezed == motif
                ? _value.motif
                : motif // ignore: cast_nullable_to_non_nullable
                      as String?,
            paidAt: freezed == paidAt
                ? _value.paidAt
                : paidAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            reimbursedAt: freezed == reimbursedAt
                ? _value.reimbursedAt
                : reimbursedAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AvanceCoopImplCopyWith<$Res>
    implements $AvanceCoopCopyWith<$Res> {
  factory _$$AvanceCoopImplCopyWith(
    _$AvanceCoopImpl value,
    $Res Function(_$AvanceCoopImpl) then,
  ) = __$$AvanceCoopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String cooperativeId,
    String farmerId,
    @FlexDouble() double amount,
    String? annonceVenteId,
    @JsonKey(unknownEnumValue: CoopAdvanceStatus.unknown)
    CoopAdvanceStatus status,
    String? motif,
    DateTime? paidAt,
    DateTime? reimbursedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$AvanceCoopImplCopyWithImpl<$Res>
    extends _$AvanceCoopCopyWithImpl<$Res, _$AvanceCoopImpl>
    implements _$$AvanceCoopImplCopyWith<$Res> {
  __$$AvanceCoopImplCopyWithImpl(
    _$AvanceCoopImpl _value,
    $Res Function(_$AvanceCoopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AvanceCoop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cooperativeId = null,
    Object? farmerId = null,
    Object? amount = null,
    Object? annonceVenteId = freezed,
    Object? status = null,
    Object? motif = freezed,
    Object? paidAt = freezed,
    Object? reimbursedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AvanceCoopImpl(
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
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        annonceVenteId: freezed == annonceVenteId
            ? _value.annonceVenteId
            : annonceVenteId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as CoopAdvanceStatus,
        motif: freezed == motif
            ? _value.motif
            : motif // ignore: cast_nullable_to_non_nullable
                  as String?,
        paidAt: freezed == paidAt
            ? _value.paidAt
            : paidAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        reimbursedAt: freezed == reimbursedAt
            ? _value.reimbursedAt
            : reimbursedAt // ignore: cast_nullable_to_non_nullable
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
class _$AvanceCoopImpl implements _AvanceCoop {
  const _$AvanceCoopImpl({
    required this.id,
    required this.cooperativeId,
    required this.farmerId,
    @FlexDouble() required this.amount,
    this.annonceVenteId,
    @JsonKey(unknownEnumValue: CoopAdvanceStatus.unknown)
    this.status = CoopAdvanceStatus.unknown,
    this.motif,
    this.paidAt,
    this.reimbursedAt,
    this.createdAt,
  });

  factory _$AvanceCoopImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvanceCoopImplFromJson(json);

  @override
  final String id;
  @override
  final String cooperativeId;
  @override
  final String farmerId;
  @override
  @FlexDouble()
  final double amount;
  @override
  final String? annonceVenteId;
  @override
  @JsonKey(unknownEnumValue: CoopAdvanceStatus.unknown)
  final CoopAdvanceStatus status;
  @override
  final String? motif;
  @override
  final DateTime? paidAt;
  @override
  final DateTime? reimbursedAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AvanceCoop(id: $id, cooperativeId: $cooperativeId, farmerId: $farmerId, amount: $amount, annonceVenteId: $annonceVenteId, status: $status, motif: $motif, paidAt: $paidAt, reimbursedAt: $reimbursedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvanceCoopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cooperativeId, cooperativeId) ||
                other.cooperativeId == cooperativeId) &&
            (identical(other.farmerId, farmerId) ||
                other.farmerId == farmerId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.annonceVenteId, annonceVenteId) ||
                other.annonceVenteId == annonceVenteId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.motif, motif) || other.motif == motif) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.reimbursedAt, reimbursedAt) ||
                other.reimbursedAt == reimbursedAt) &&
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
    amount,
    annonceVenteId,
    status,
    motif,
    paidAt,
    reimbursedAt,
    createdAt,
  );

  /// Create a copy of AvanceCoop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvanceCoopImplCopyWith<_$AvanceCoopImpl> get copyWith =>
      __$$AvanceCoopImplCopyWithImpl<_$AvanceCoopImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AvanceCoopImplToJson(this);
  }
}

abstract class _AvanceCoop implements AvanceCoop {
  const factory _AvanceCoop({
    required final String id,
    required final String cooperativeId,
    required final String farmerId,
    @FlexDouble() required final double amount,
    final String? annonceVenteId,
    @JsonKey(unknownEnumValue: CoopAdvanceStatus.unknown)
    final CoopAdvanceStatus status,
    final String? motif,
    final DateTime? paidAt,
    final DateTime? reimbursedAt,
    final DateTime? createdAt,
  }) = _$AvanceCoopImpl;

  factory _AvanceCoop.fromJson(Map<String, dynamic> json) =
      _$AvanceCoopImpl.fromJson;

  @override
  String get id;
  @override
  String get cooperativeId;
  @override
  String get farmerId;
  @override
  @FlexDouble()
  double get amount;
  @override
  String? get annonceVenteId;
  @override
  @JsonKey(unknownEnumValue: CoopAdvanceStatus.unknown)
  CoopAdvanceStatus get status;
  @override
  String? get motif;
  @override
  DateTime? get paidAt;
  @override
  DateTime? get reimbursedAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of AvanceCoop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvanceCoopImplCopyWith<_$AvanceCoopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
