// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kyc_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

KycDocument _$KycDocumentFromJson(Map<String, dynamic> json) {
  return _KycDocument.fromJson(json);
}

/// @nodoc
mixin _$KycDocument {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get docType => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  DateTime? get uploadedAt => throw _privateConstructorUsedError;
  DateTime? get validatedAt => throw _privateConstructorUsedError;
  String? get validatedBy => throw _privateConstructorUsedError;

  /// Serializes this KycDocument to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KycDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KycDocumentCopyWith<KycDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KycDocumentCopyWith<$Res> {
  factory $KycDocumentCopyWith(
    KycDocument value,
    $Res Function(KycDocument) then,
  ) = _$KycDocumentCopyWithImpl<$Res, KycDocument>;
  @useResult
  $Res call({
    String id,
    String userId,
    String docType,
    String url,
    String status,
    String? rejectionReason,
    DateTime? uploadedAt,
    DateTime? validatedAt,
    String? validatedBy,
  });
}

/// @nodoc
class _$KycDocumentCopyWithImpl<$Res, $Val extends KycDocument>
    implements $KycDocumentCopyWith<$Res> {
  _$KycDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KycDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? docType = null,
    Object? url = null,
    Object? status = null,
    Object? rejectionReason = freezed,
    Object? uploadedAt = freezed,
    Object? validatedAt = freezed,
    Object? validatedBy = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            docType: null == docType
                ? _value.docType
                : docType // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            rejectionReason: freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            uploadedAt: freezed == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            validatedAt: freezed == validatedAt
                ? _value.validatedAt
                : validatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            validatedBy: freezed == validatedBy
                ? _value.validatedBy
                : validatedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KycDocumentImplCopyWith<$Res>
    implements $KycDocumentCopyWith<$Res> {
  factory _$$KycDocumentImplCopyWith(
    _$KycDocumentImpl value,
    $Res Function(_$KycDocumentImpl) then,
  ) = __$$KycDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String docType,
    String url,
    String status,
    String? rejectionReason,
    DateTime? uploadedAt,
    DateTime? validatedAt,
    String? validatedBy,
  });
}

/// @nodoc
class __$$KycDocumentImplCopyWithImpl<$Res>
    extends _$KycDocumentCopyWithImpl<$Res, _$KycDocumentImpl>
    implements _$$KycDocumentImplCopyWith<$Res> {
  __$$KycDocumentImplCopyWithImpl(
    _$KycDocumentImpl _value,
    $Res Function(_$KycDocumentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KycDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? docType = null,
    Object? url = null,
    Object? status = null,
    Object? rejectionReason = freezed,
    Object? uploadedAt = freezed,
    Object? validatedAt = freezed,
    Object? validatedBy = freezed,
  }) {
    return _then(
      _$KycDocumentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        docType: null == docType
            ? _value.docType
            : docType // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        rejectionReason: freezed == rejectionReason
            ? _value.rejectionReason
            : rejectionReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        uploadedAt: freezed == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        validatedAt: freezed == validatedAt
            ? _value.validatedAt
            : validatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        validatedBy: freezed == validatedBy
            ? _value.validatedBy
            : validatedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KycDocumentImpl implements _KycDocument {
  const _$KycDocumentImpl({
    required this.id,
    required this.userId,
    this.docType = '',
    this.url = '',
    this.status = 'PENDING',
    this.rejectionReason,
    this.uploadedAt,
    this.validatedAt,
    this.validatedBy,
  });

  factory _$KycDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$KycDocumentImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @JsonKey()
  final String docType;
  @override
  @JsonKey()
  final String url;
  @override
  @JsonKey()
  final String status;
  @override
  final String? rejectionReason;
  @override
  final DateTime? uploadedAt;
  @override
  final DateTime? validatedAt;
  @override
  final String? validatedBy;

  @override
  String toString() {
    return 'KycDocument(id: $id, userId: $userId, docType: $docType, url: $url, status: $status, rejectionReason: $rejectionReason, uploadedAt: $uploadedAt, validatedAt: $validatedAt, validatedBy: $validatedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KycDocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.docType, docType) || other.docType == docType) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            (identical(other.validatedAt, validatedAt) ||
                other.validatedAt == validatedAt) &&
            (identical(other.validatedBy, validatedBy) ||
                other.validatedBy == validatedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    docType,
    url,
    status,
    rejectionReason,
    uploadedAt,
    validatedAt,
    validatedBy,
  );

  /// Create a copy of KycDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KycDocumentImplCopyWith<_$KycDocumentImpl> get copyWith =>
      __$$KycDocumentImplCopyWithImpl<_$KycDocumentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KycDocumentImplToJson(this);
  }
}

abstract class _KycDocument implements KycDocument {
  const factory _KycDocument({
    required final String id,
    required final String userId,
    final String docType,
    final String url,
    final String status,
    final String? rejectionReason,
    final DateTime? uploadedAt,
    final DateTime? validatedAt,
    final String? validatedBy,
  }) = _$KycDocumentImpl;

  factory _KycDocument.fromJson(Map<String, dynamic> json) =
      _$KycDocumentImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get docType;
  @override
  String get url;
  @override
  String get status;
  @override
  String? get rejectionReason;
  @override
  DateTime? get uploadedAt;
  @override
  DateTime? get validatedAt;
  @override
  String? get validatedBy;

  /// Create a copy of KycDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KycDocumentImplCopyWith<_$KycDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
