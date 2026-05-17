// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analyse_plante.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnalysePlante _$AnalysePlanteFromJson(Map<String, dynamic> json) {
  return _AnalysePlante.fromJson(json);
}

/// @nodoc
mixin _$AnalysePlante {
  String get id => throw _privateConstructorUsedError;
  String get farmerId => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String? get parcelleId => throw _privateConstructorUsedError;
  String? get diseaseDetected => throw _privateConstructorUsedError;
  String? get riskLevel => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get confidenceScore => throw _privateConstructorUsedError;
  String? get recommendations => throw _privateConstructorUsedError;
  List<String> get treatmentIds => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AnalysePlante to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnalysePlante
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnalysePlanteCopyWith<AnalysePlante> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalysePlanteCopyWith<$Res> {
  factory $AnalysePlanteCopyWith(
    AnalysePlante value,
    $Res Function(AnalysePlante) then,
  ) = _$AnalysePlanteCopyWithImpl<$Res, AnalysePlante>;
  @useResult
  $Res call({
    String id,
    String farmerId,
    String imageUrl,
    String? parcelleId,
    String? diseaseDetected,
    String? riskLevel,
    @FlexDoubleN() double? confidenceScore,
    String? recommendations,
    List<String> treatmentIds,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$AnalysePlanteCopyWithImpl<$Res, $Val extends AnalysePlante>
    implements $AnalysePlanteCopyWith<$Res> {
  _$AnalysePlanteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnalysePlante
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? farmerId = null,
    Object? imageUrl = null,
    Object? parcelleId = freezed,
    Object? diseaseDetected = freezed,
    Object? riskLevel = freezed,
    Object? confidenceScore = freezed,
    Object? recommendations = freezed,
    Object? treatmentIds = null,
    Object? createdAt = freezed,
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
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            parcelleId: freezed == parcelleId
                ? _value.parcelleId
                : parcelleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            diseaseDetected: freezed == diseaseDetected
                ? _value.diseaseDetected
                : diseaseDetected // ignore: cast_nullable_to_non_nullable
                      as String?,
            riskLevel: freezed == riskLevel
                ? _value.riskLevel
                : riskLevel // ignore: cast_nullable_to_non_nullable
                      as String?,
            confidenceScore: freezed == confidenceScore
                ? _value.confidenceScore
                : confidenceScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            recommendations: freezed == recommendations
                ? _value.recommendations
                : recommendations // ignore: cast_nullable_to_non_nullable
                      as String?,
            treatmentIds: null == treatmentIds
                ? _value.treatmentIds
                : treatmentIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
abstract class _$$AnalysePlanteImplCopyWith<$Res>
    implements $AnalysePlanteCopyWith<$Res> {
  factory _$$AnalysePlanteImplCopyWith(
    _$AnalysePlanteImpl value,
    $Res Function(_$AnalysePlanteImpl) then,
  ) = __$$AnalysePlanteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String farmerId,
    String imageUrl,
    String? parcelleId,
    String? diseaseDetected,
    String? riskLevel,
    @FlexDoubleN() double? confidenceScore,
    String? recommendations,
    List<String> treatmentIds,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$AnalysePlanteImplCopyWithImpl<$Res>
    extends _$AnalysePlanteCopyWithImpl<$Res, _$AnalysePlanteImpl>
    implements _$$AnalysePlanteImplCopyWith<$Res> {
  __$$AnalysePlanteImplCopyWithImpl(
    _$AnalysePlanteImpl _value,
    $Res Function(_$AnalysePlanteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnalysePlante
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? farmerId = null,
    Object? imageUrl = null,
    Object? parcelleId = freezed,
    Object? diseaseDetected = freezed,
    Object? riskLevel = freezed,
    Object? confidenceScore = freezed,
    Object? recommendations = freezed,
    Object? treatmentIds = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AnalysePlanteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        farmerId: null == farmerId
            ? _value.farmerId
            : farmerId // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        parcelleId: freezed == parcelleId
            ? _value.parcelleId
            : parcelleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        diseaseDetected: freezed == diseaseDetected
            ? _value.diseaseDetected
            : diseaseDetected // ignore: cast_nullable_to_non_nullable
                  as String?,
        riskLevel: freezed == riskLevel
            ? _value.riskLevel
            : riskLevel // ignore: cast_nullable_to_non_nullable
                  as String?,
        confidenceScore: freezed == confidenceScore
            ? _value.confidenceScore
            : confidenceScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        recommendations: freezed == recommendations
            ? _value.recommendations
            : recommendations // ignore: cast_nullable_to_non_nullable
                  as String?,
        treatmentIds: null == treatmentIds
            ? _value._treatmentIds
            : treatmentIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
class _$AnalysePlanteImpl implements _AnalysePlante {
  const _$AnalysePlanteImpl({
    required this.id,
    required this.farmerId,
    this.imageUrl = '',
    this.parcelleId,
    this.diseaseDetected,
    this.riskLevel,
    @FlexDoubleN() this.confidenceScore,
    this.recommendations,
    final List<String> treatmentIds = const <String>[],
    this.createdAt,
  }) : _treatmentIds = treatmentIds;

  factory _$AnalysePlanteImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalysePlanteImplFromJson(json);

  @override
  final String id;
  @override
  final String farmerId;
  @override
  @JsonKey()
  final String imageUrl;
  @override
  final String? parcelleId;
  @override
  final String? diseaseDetected;
  @override
  final String? riskLevel;
  @override
  @FlexDoubleN()
  final double? confidenceScore;
  @override
  final String? recommendations;
  final List<String> _treatmentIds;
  @override
  @JsonKey()
  List<String> get treatmentIds {
    if (_treatmentIds is EqualUnmodifiableListView) return _treatmentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_treatmentIds);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AnalysePlante(id: $id, farmerId: $farmerId, imageUrl: $imageUrl, parcelleId: $parcelleId, diseaseDetected: $diseaseDetected, riskLevel: $riskLevel, confidenceScore: $confidenceScore, recommendations: $recommendations, treatmentIds: $treatmentIds, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalysePlanteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.farmerId, farmerId) ||
                other.farmerId == farmerId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.parcelleId, parcelleId) ||
                other.parcelleId == parcelleId) &&
            (identical(other.diseaseDetected, diseaseDetected) ||
                other.diseaseDetected == diseaseDetected) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            (identical(other.recommendations, recommendations) ||
                other.recommendations == recommendations) &&
            const DeepCollectionEquality().equals(
              other._treatmentIds,
              _treatmentIds,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    farmerId,
    imageUrl,
    parcelleId,
    diseaseDetected,
    riskLevel,
    confidenceScore,
    recommendations,
    const DeepCollectionEquality().hash(_treatmentIds),
    createdAt,
  );

  /// Create a copy of AnalysePlante
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalysePlanteImplCopyWith<_$AnalysePlanteImpl> get copyWith =>
      __$$AnalysePlanteImplCopyWithImpl<_$AnalysePlanteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalysePlanteImplToJson(this);
  }
}

abstract class _AnalysePlante implements AnalysePlante {
  const factory _AnalysePlante({
    required final String id,
    required final String farmerId,
    final String imageUrl,
    final String? parcelleId,
    final String? diseaseDetected,
    final String? riskLevel,
    @FlexDoubleN() final double? confidenceScore,
    final String? recommendations,
    final List<String> treatmentIds,
    final DateTime? createdAt,
  }) = _$AnalysePlanteImpl;

  factory _AnalysePlante.fromJson(Map<String, dynamic> json) =
      _$AnalysePlanteImpl.fromJson;

  @override
  String get id;
  @override
  String get farmerId;
  @override
  String get imageUrl;
  @override
  String? get parcelleId;
  @override
  String? get diseaseDetected;
  @override
  String? get riskLevel;
  @override
  @FlexDoubleN()
  double? get confidenceScore;
  @override
  String? get recommendations;
  @override
  List<String> get treatmentIds;
  @override
  DateTime? get createdAt;

  /// Create a copy of AnalysePlante
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalysePlanteImplCopyWith<_$AnalysePlanteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
