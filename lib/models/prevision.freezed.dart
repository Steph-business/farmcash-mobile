// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prevision.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Prevision _$PrevisionFromJson(Map<String, dynamic> json) {
  return _Prevision.fromJson(json);
}

/// @nodoc
mixin _$Prevision {
  String get id => throw _privateConstructorUsedError;
  String get farmerId => throw _privateConstructorUsedError;
  String get produitId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get quantitePrevKg => throw _privateConstructorUsedError;
  String? get parcelleId => throw _privateConstructorUsedError;
  DateTime? get dateRecoltePrev => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get prixCibleKg => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: PrevisionStatus.unknown)
  PrevisionStatus get status => throw _privateConstructorUsedError;
  String? get assignedToCooperativeId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Prevision to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Prevision
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrevisionCopyWith<Prevision> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrevisionCopyWith<$Res> {
  factory $PrevisionCopyWith(Prevision value, $Res Function(Prevision) then) =
      _$PrevisionCopyWithImpl<$Res, Prevision>;
  @useResult
  $Res call({
    String id,
    String farmerId,
    String produitId,
    @FlexDouble() double quantitePrevKg,
    String? parcelleId,
    DateTime? dateRecoltePrev,
    @FlexDoubleN() double? prixCibleKg,
    @JsonKey(unknownEnumValue: PrevisionStatus.unknown) PrevisionStatus status,
    String? assignedToCooperativeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$PrevisionCopyWithImpl<$Res, $Val extends Prevision>
    implements $PrevisionCopyWith<$Res> {
  _$PrevisionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Prevision
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? farmerId = null,
    Object? produitId = null,
    Object? quantitePrevKg = null,
    Object? parcelleId = freezed,
    Object? dateRecoltePrev = freezed,
    Object? prixCibleKg = freezed,
    Object? status = null,
    Object? assignedToCooperativeId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            farmerId: null == farmerId
                ? _value.farmerId
                : farmerId // ignore: cast_nullable_to_non_nullable
                      as String,
            produitId: null == produitId
                ? _value.produitId
                : produitId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantitePrevKg: null == quantitePrevKg
                ? _value.quantitePrevKg
                : quantitePrevKg // ignore: cast_nullable_to_non_nullable
                      as double,
            parcelleId: freezed == parcelleId
                ? _value.parcelleId
                : parcelleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateRecoltePrev: freezed == dateRecoltePrev
                ? _value.dateRecoltePrev
                : dateRecoltePrev // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            prixCibleKg: freezed == prixCibleKg
                ? _value.prixCibleKg
                : prixCibleKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PrevisionStatus,
            assignedToCooperativeId: freezed == assignedToCooperativeId
                ? _value.assignedToCooperativeId
                : assignedToCooperativeId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$PrevisionImplCopyWith<$Res>
    implements $PrevisionCopyWith<$Res> {
  factory _$$PrevisionImplCopyWith(
    _$PrevisionImpl value,
    $Res Function(_$PrevisionImpl) then,
  ) = __$$PrevisionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String farmerId,
    String produitId,
    @FlexDouble() double quantitePrevKg,
    String? parcelleId,
    DateTime? dateRecoltePrev,
    @FlexDoubleN() double? prixCibleKg,
    @JsonKey(unknownEnumValue: PrevisionStatus.unknown) PrevisionStatus status,
    String? assignedToCooperativeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$PrevisionImplCopyWithImpl<$Res>
    extends _$PrevisionCopyWithImpl<$Res, _$PrevisionImpl>
    implements _$$PrevisionImplCopyWith<$Res> {
  __$$PrevisionImplCopyWithImpl(
    _$PrevisionImpl _value,
    $Res Function(_$PrevisionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Prevision
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? farmerId = null,
    Object? produitId = null,
    Object? quantitePrevKg = null,
    Object? parcelleId = freezed,
    Object? dateRecoltePrev = freezed,
    Object? prixCibleKg = freezed,
    Object? status = null,
    Object? assignedToCooperativeId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$PrevisionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        farmerId: null == farmerId
            ? _value.farmerId
            : farmerId // ignore: cast_nullable_to_non_nullable
                  as String,
        produitId: null == produitId
            ? _value.produitId
            : produitId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantitePrevKg: null == quantitePrevKg
            ? _value.quantitePrevKg
            : quantitePrevKg // ignore: cast_nullable_to_non_nullable
                  as double,
        parcelleId: freezed == parcelleId
            ? _value.parcelleId
            : parcelleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateRecoltePrev: freezed == dateRecoltePrev
            ? _value.dateRecoltePrev
            : dateRecoltePrev // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        prixCibleKg: freezed == prixCibleKg
            ? _value.prixCibleKg
            : prixCibleKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PrevisionStatus,
        assignedToCooperativeId: freezed == assignedToCooperativeId
            ? _value.assignedToCooperativeId
            : assignedToCooperativeId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$PrevisionImpl implements _Prevision {
  const _$PrevisionImpl({
    required this.id,
    required this.farmerId,
    required this.produitId,
    @FlexDouble() required this.quantitePrevKg,
    this.parcelleId,
    this.dateRecoltePrev,
    @FlexDoubleN() this.prixCibleKg,
    @JsonKey(unknownEnumValue: PrevisionStatus.unknown)
    this.status = PrevisionStatus.unknown,
    this.assignedToCooperativeId,
    this.createdAt,
    this.updatedAt,
  });

  factory _$PrevisionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrevisionImplFromJson(json);

  @override
  final String id;
  @override
  final String farmerId;
  @override
  final String produitId;
  @override
  @FlexDouble()
  final double quantitePrevKg;
  @override
  final String? parcelleId;
  @override
  final DateTime? dateRecoltePrev;
  @override
  @FlexDoubleN()
  final double? prixCibleKg;
  @override
  @JsonKey(unknownEnumValue: PrevisionStatus.unknown)
  final PrevisionStatus status;
  @override
  final String? assignedToCooperativeId;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Prevision(id: $id, farmerId: $farmerId, produitId: $produitId, quantitePrevKg: $quantitePrevKg, parcelleId: $parcelleId, dateRecoltePrev: $dateRecoltePrev, prixCibleKg: $prixCibleKg, status: $status, assignedToCooperativeId: $assignedToCooperativeId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrevisionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.farmerId, farmerId) ||
                other.farmerId == farmerId) &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            (identical(other.quantitePrevKg, quantitePrevKg) ||
                other.quantitePrevKg == quantitePrevKg) &&
            (identical(other.parcelleId, parcelleId) ||
                other.parcelleId == parcelleId) &&
            (identical(other.dateRecoltePrev, dateRecoltePrev) ||
                other.dateRecoltePrev == dateRecoltePrev) &&
            (identical(other.prixCibleKg, prixCibleKg) ||
                other.prixCibleKg == prixCibleKg) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(
                  other.assignedToCooperativeId,
                  assignedToCooperativeId,
                ) ||
                other.assignedToCooperativeId == assignedToCooperativeId) &&
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
    farmerId,
    produitId,
    quantitePrevKg,
    parcelleId,
    dateRecoltePrev,
    prixCibleKg,
    status,
    assignedToCooperativeId,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Prevision
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrevisionImplCopyWith<_$PrevisionImpl> get copyWith =>
      __$$PrevisionImplCopyWithImpl<_$PrevisionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrevisionImplToJson(this);
  }
}

abstract class _Prevision implements Prevision {
  const factory _Prevision({
    required final String id,
    required final String farmerId,
    required final String produitId,
    @FlexDouble() required final double quantitePrevKg,
    final String? parcelleId,
    final DateTime? dateRecoltePrev,
    @FlexDoubleN() final double? prixCibleKg,
    @JsonKey(unknownEnumValue: PrevisionStatus.unknown)
    final PrevisionStatus status,
    final String? assignedToCooperativeId,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$PrevisionImpl;

  factory _Prevision.fromJson(Map<String, dynamic> json) =
      _$PrevisionImpl.fromJson;

  @override
  String get id;
  @override
  String get farmerId;
  @override
  String get produitId;
  @override
  @FlexDouble()
  double get quantitePrevKg;
  @override
  String? get parcelleId;
  @override
  DateTime? get dateRecoltePrev;
  @override
  @FlexDoubleN()
  double? get prixCibleKg;
  @override
  @JsonKey(unknownEnumValue: PrevisionStatus.unknown)
  PrevisionStatus get status;
  @override
  String? get assignedToCooperativeId;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Prevision
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrevisionImplCopyWith<_$PrevisionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
