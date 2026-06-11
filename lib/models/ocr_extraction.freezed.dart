// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_extraction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

IdentityCardExtraction _$IdentityCardExtractionFromJson(
  Map<String, dynamic> json,
) {
  return _IdentityCardExtraction.fromJson(json);
}

/// @nodoc
mixin _$IdentityCardExtraction {
  @JsonKey(name: 'full_name')
  String? get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'document_number')
  String? get documentNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'birth_date')
  String? get birthDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'birth_place')
  String? get birthPlace => throw _privateConstructorUsedError;
  @FlexDouble()
  double get confidence => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_text')
  String get rawText => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_mock')
  bool get isMock => throw _privateConstructorUsedError;

  /// Serializes this IdentityCardExtraction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IdentityCardExtraction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IdentityCardExtractionCopyWith<IdentityCardExtraction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdentityCardExtractionCopyWith<$Res> {
  factory $IdentityCardExtractionCopyWith(
    IdentityCardExtraction value,
    $Res Function(IdentityCardExtraction) then,
  ) = _$IdentityCardExtractionCopyWithImpl<$Res, IdentityCardExtraction>;
  @useResult
  $Res call({
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'document_number') String? documentNumber,
    @JsonKey(name: 'birth_date') String? birthDate,
    @JsonKey(name: 'birth_place') String? birthPlace,
    @FlexDouble() double confidence,
    @JsonKey(name: 'raw_text') String rawText,
    @JsonKey(name: 'is_mock') bool isMock,
  });
}

/// @nodoc
class _$IdentityCardExtractionCopyWithImpl<
  $Res,
  $Val extends IdentityCardExtraction
>
    implements $IdentityCardExtractionCopyWith<$Res> {
  _$IdentityCardExtractionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IdentityCardExtraction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = freezed,
    Object? documentNumber = freezed,
    Object? birthDate = freezed,
    Object? birthPlace = freezed,
    Object? confidence = null,
    Object? rawText = null,
    Object? isMock = null,
  }) {
    return _then(
      _value.copyWith(
            fullName: freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String?,
            documentNumber: freezed == documentNumber
                ? _value.documentNumber
                : documentNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            birthDate: freezed == birthDate
                ? _value.birthDate
                : birthDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            birthPlace: freezed == birthPlace
                ? _value.birthPlace
                : birthPlace // ignore: cast_nullable_to_non_nullable
                      as String?,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            rawText: null == rawText
                ? _value.rawText
                : rawText // ignore: cast_nullable_to_non_nullable
                      as String,
            isMock: null == isMock
                ? _value.isMock
                : isMock // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IdentityCardExtractionImplCopyWith<$Res>
    implements $IdentityCardExtractionCopyWith<$Res> {
  factory _$$IdentityCardExtractionImplCopyWith(
    _$IdentityCardExtractionImpl value,
    $Res Function(_$IdentityCardExtractionImpl) then,
  ) = __$$IdentityCardExtractionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'document_number') String? documentNumber,
    @JsonKey(name: 'birth_date') String? birthDate,
    @JsonKey(name: 'birth_place') String? birthPlace,
    @FlexDouble() double confidence,
    @JsonKey(name: 'raw_text') String rawText,
    @JsonKey(name: 'is_mock') bool isMock,
  });
}

/// @nodoc
class __$$IdentityCardExtractionImplCopyWithImpl<$Res>
    extends
        _$IdentityCardExtractionCopyWithImpl<$Res, _$IdentityCardExtractionImpl>
    implements _$$IdentityCardExtractionImplCopyWith<$Res> {
  __$$IdentityCardExtractionImplCopyWithImpl(
    _$IdentityCardExtractionImpl _value,
    $Res Function(_$IdentityCardExtractionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IdentityCardExtraction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = freezed,
    Object? documentNumber = freezed,
    Object? birthDate = freezed,
    Object? birthPlace = freezed,
    Object? confidence = null,
    Object? rawText = null,
    Object? isMock = null,
  }) {
    return _then(
      _$IdentityCardExtractionImpl(
        fullName: freezed == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String?,
        documentNumber: freezed == documentNumber
            ? _value.documentNumber
            : documentNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        birthDate: freezed == birthDate
            ? _value.birthDate
            : birthDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        birthPlace: freezed == birthPlace
            ? _value.birthPlace
            : birthPlace // ignore: cast_nullable_to_non_nullable
                  as String?,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        rawText: null == rawText
            ? _value.rawText
            : rawText // ignore: cast_nullable_to_non_nullable
                  as String,
        isMock: null == isMock
            ? _value.isMock
            : isMock // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IdentityCardExtractionImpl implements _IdentityCardExtraction {
  const _$IdentityCardExtractionImpl({
    @JsonKey(name: 'full_name') this.fullName,
    @JsonKey(name: 'document_number') this.documentNumber,
    @JsonKey(name: 'birth_date') this.birthDate,
    @JsonKey(name: 'birth_place') this.birthPlace,
    @FlexDouble() this.confidence = 0.0,
    @JsonKey(name: 'raw_text') this.rawText = '',
    @JsonKey(name: 'is_mock') this.isMock = false,
  });

  factory _$IdentityCardExtractionImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdentityCardExtractionImplFromJson(json);

  @override
  @JsonKey(name: 'full_name')
  final String? fullName;
  @override
  @JsonKey(name: 'document_number')
  final String? documentNumber;
  @override
  @JsonKey(name: 'birth_date')
  final String? birthDate;
  @override
  @JsonKey(name: 'birth_place')
  final String? birthPlace;
  @override
  @JsonKey()
  @FlexDouble()
  final double confidence;
  @override
  @JsonKey(name: 'raw_text')
  final String rawText;
  @override
  @JsonKey(name: 'is_mock')
  final bool isMock;

  @override
  String toString() {
    return 'IdentityCardExtraction(fullName: $fullName, documentNumber: $documentNumber, birthDate: $birthDate, birthPlace: $birthPlace, confidence: $confidence, rawText: $rawText, isMock: $isMock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdentityCardExtractionImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.documentNumber, documentNumber) ||
                other.documentNumber == documentNumber) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.birthPlace, birthPlace) ||
                other.birthPlace == birthPlace) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.rawText, rawText) || other.rawText == rawText) &&
            (identical(other.isMock, isMock) || other.isMock == isMock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    fullName,
    documentNumber,
    birthDate,
    birthPlace,
    confidence,
    rawText,
    isMock,
  );

  /// Create a copy of IdentityCardExtraction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IdentityCardExtractionImplCopyWith<_$IdentityCardExtractionImpl>
  get copyWith =>
      __$$IdentityCardExtractionImplCopyWithImpl<_$IdentityCardExtractionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$IdentityCardExtractionImplToJson(this);
  }
}

abstract class _IdentityCardExtraction implements IdentityCardExtraction {
  const factory _IdentityCardExtraction({
    @JsonKey(name: 'full_name') final String? fullName,
    @JsonKey(name: 'document_number') final String? documentNumber,
    @JsonKey(name: 'birth_date') final String? birthDate,
    @JsonKey(name: 'birth_place') final String? birthPlace,
    @FlexDouble() final double confidence,
    @JsonKey(name: 'raw_text') final String rawText,
    @JsonKey(name: 'is_mock') final bool isMock,
  }) = _$IdentityCardExtractionImpl;

  factory _IdentityCardExtraction.fromJson(Map<String, dynamic> json) =
      _$IdentityCardExtractionImpl.fromJson;

  @override
  @JsonKey(name: 'full_name')
  String? get fullName;
  @override
  @JsonKey(name: 'document_number')
  String? get documentNumber;
  @override
  @JsonKey(name: 'birth_date')
  String? get birthDate;
  @override
  @JsonKey(name: 'birth_place')
  String? get birthPlace;
  @override
  @FlexDouble()
  double get confidence;
  @override
  @JsonKey(name: 'raw_text')
  String get rawText;
  @override
  @JsonKey(name: 'is_mock')
  bool get isMock;

  /// Create a copy of IdentityCardExtraction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IdentityCardExtractionImplCopyWith<_$IdentityCardExtractionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

RccmExtraction _$RccmExtractionFromJson(Map<String, dynamic> json) {
  return _RccmExtraction.fromJson(json);
}

/// @nodoc
mixin _$RccmExtraction {
  @JsonKey(name: 'company_name')
  String? get companyName => throw _privateConstructorUsedError;
  @JsonKey(name: 'rccm_number')
  String? get rccmNumber => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get activity => throw _privateConstructorUsedError;
  @FlexDouble()
  double get confidence => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_text')
  String get rawText => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_mock')
  bool get isMock => throw _privateConstructorUsedError;

  /// Serializes this RccmExtraction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RccmExtraction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RccmExtractionCopyWith<RccmExtraction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RccmExtractionCopyWith<$Res> {
  factory $RccmExtractionCopyWith(
    RccmExtraction value,
    $Res Function(RccmExtraction) then,
  ) = _$RccmExtractionCopyWithImpl<$Res, RccmExtraction>;
  @useResult
  $Res call({
    @JsonKey(name: 'company_name') String? companyName,
    @JsonKey(name: 'rccm_number') String? rccmNumber,
    String? address,
    String? activity,
    @FlexDouble() double confidence,
    @JsonKey(name: 'raw_text') String rawText,
    @JsonKey(name: 'is_mock') bool isMock,
  });
}

/// @nodoc
class _$RccmExtractionCopyWithImpl<$Res, $Val extends RccmExtraction>
    implements $RccmExtractionCopyWith<$Res> {
  _$RccmExtractionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RccmExtraction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyName = freezed,
    Object? rccmNumber = freezed,
    Object? address = freezed,
    Object? activity = freezed,
    Object? confidence = null,
    Object? rawText = null,
    Object? isMock = null,
  }) {
    return _then(
      _value.copyWith(
            companyName: freezed == companyName
                ? _value.companyName
                : companyName // ignore: cast_nullable_to_non_nullable
                      as String?,
            rccmNumber: freezed == rccmNumber
                ? _value.rccmNumber
                : rccmNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            activity: freezed == activity
                ? _value.activity
                : activity // ignore: cast_nullable_to_non_nullable
                      as String?,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            rawText: null == rawText
                ? _value.rawText
                : rawText // ignore: cast_nullable_to_non_nullable
                      as String,
            isMock: null == isMock
                ? _value.isMock
                : isMock // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RccmExtractionImplCopyWith<$Res>
    implements $RccmExtractionCopyWith<$Res> {
  factory _$$RccmExtractionImplCopyWith(
    _$RccmExtractionImpl value,
    $Res Function(_$RccmExtractionImpl) then,
  ) = __$$RccmExtractionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'company_name') String? companyName,
    @JsonKey(name: 'rccm_number') String? rccmNumber,
    String? address,
    String? activity,
    @FlexDouble() double confidence,
    @JsonKey(name: 'raw_text') String rawText,
    @JsonKey(name: 'is_mock') bool isMock,
  });
}

/// @nodoc
class __$$RccmExtractionImplCopyWithImpl<$Res>
    extends _$RccmExtractionCopyWithImpl<$Res, _$RccmExtractionImpl>
    implements _$$RccmExtractionImplCopyWith<$Res> {
  __$$RccmExtractionImplCopyWithImpl(
    _$RccmExtractionImpl _value,
    $Res Function(_$RccmExtractionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RccmExtraction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyName = freezed,
    Object? rccmNumber = freezed,
    Object? address = freezed,
    Object? activity = freezed,
    Object? confidence = null,
    Object? rawText = null,
    Object? isMock = null,
  }) {
    return _then(
      _$RccmExtractionImpl(
        companyName: freezed == companyName
            ? _value.companyName
            : companyName // ignore: cast_nullable_to_non_nullable
                  as String?,
        rccmNumber: freezed == rccmNumber
            ? _value.rccmNumber
            : rccmNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        activity: freezed == activity
            ? _value.activity
            : activity // ignore: cast_nullable_to_non_nullable
                  as String?,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        rawText: null == rawText
            ? _value.rawText
            : rawText // ignore: cast_nullable_to_non_nullable
                  as String,
        isMock: null == isMock
            ? _value.isMock
            : isMock // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RccmExtractionImpl implements _RccmExtraction {
  const _$RccmExtractionImpl({
    @JsonKey(name: 'company_name') this.companyName,
    @JsonKey(name: 'rccm_number') this.rccmNumber,
    this.address,
    this.activity,
    @FlexDouble() this.confidence = 0.0,
    @JsonKey(name: 'raw_text') this.rawText = '',
    @JsonKey(name: 'is_mock') this.isMock = false,
  });

  factory _$RccmExtractionImpl.fromJson(Map<String, dynamic> json) =>
      _$$RccmExtractionImplFromJson(json);

  @override
  @JsonKey(name: 'company_name')
  final String? companyName;
  @override
  @JsonKey(name: 'rccm_number')
  final String? rccmNumber;
  @override
  final String? address;
  @override
  final String? activity;
  @override
  @JsonKey()
  @FlexDouble()
  final double confidence;
  @override
  @JsonKey(name: 'raw_text')
  final String rawText;
  @override
  @JsonKey(name: 'is_mock')
  final bool isMock;

  @override
  String toString() {
    return 'RccmExtraction(companyName: $companyName, rccmNumber: $rccmNumber, address: $address, activity: $activity, confidence: $confidence, rawText: $rawText, isMock: $isMock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RccmExtractionImpl &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.rccmNumber, rccmNumber) ||
                other.rccmNumber == rccmNumber) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.activity, activity) ||
                other.activity == activity) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.rawText, rawText) || other.rawText == rawText) &&
            (identical(other.isMock, isMock) || other.isMock == isMock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    companyName,
    rccmNumber,
    address,
    activity,
    confidence,
    rawText,
    isMock,
  );

  /// Create a copy of RccmExtraction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RccmExtractionImplCopyWith<_$RccmExtractionImpl> get copyWith =>
      __$$RccmExtractionImplCopyWithImpl<_$RccmExtractionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RccmExtractionImplToJson(this);
  }
}

abstract class _RccmExtraction implements RccmExtraction {
  const factory _RccmExtraction({
    @JsonKey(name: 'company_name') final String? companyName,
    @JsonKey(name: 'rccm_number') final String? rccmNumber,
    final String? address,
    final String? activity,
    @FlexDouble() final double confidence,
    @JsonKey(name: 'raw_text') final String rawText,
    @JsonKey(name: 'is_mock') final bool isMock,
  }) = _$RccmExtractionImpl;

  factory _RccmExtraction.fromJson(Map<String, dynamic> json) =
      _$RccmExtractionImpl.fromJson;

  @override
  @JsonKey(name: 'company_name')
  String? get companyName;
  @override
  @JsonKey(name: 'rccm_number')
  String? get rccmNumber;
  @override
  String? get address;
  @override
  String? get activity;
  @override
  @FlexDouble()
  double get confidence;
  @override
  @JsonKey(name: 'raw_text')
  String get rawText;
  @override
  @JsonKey(name: 'is_mock')
  bool get isMock;

  /// Create a copy of RccmExtraction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RccmExtractionImplCopyWith<_$RccmExtractionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
