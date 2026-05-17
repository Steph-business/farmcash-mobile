// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topup_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TopupWalletResponse _$TopupWalletResponseFromJson(Map<String, dynamic> json) {
  return _TopupWalletResponse.fromJson(json);
}

/// @nodoc
mixin _$TopupWalletResponse {
  @JsonKey(name: 'transaction_id')
  String get transactionId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'provider_ref')
  String? get providerRef => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_balance')
  @FlexDoubleN()
  double? get newBalance => throw _privateConstructorUsedError;

  /// Serializes this TopupWalletResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TopupWalletResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopupWalletResponseCopyWith<TopupWalletResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopupWalletResponseCopyWith<$Res> {
  factory $TopupWalletResponseCopyWith(
    TopupWalletResponse value,
    $Res Function(TopupWalletResponse) then,
  ) = _$TopupWalletResponseCopyWithImpl<$Res, TopupWalletResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'transaction_id') String transactionId,
    String status,
    @JsonKey(name: 'provider_ref') String? providerRef,
    @JsonKey(name: 'new_balance') @FlexDoubleN() double? newBalance,
  });
}

/// @nodoc
class _$TopupWalletResponseCopyWithImpl<$Res, $Val extends TopupWalletResponse>
    implements $TopupWalletResponseCopyWith<$Res> {
  _$TopupWalletResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopupWalletResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionId = null,
    Object? status = null,
    Object? providerRef = freezed,
    Object? newBalance = freezed,
  }) {
    return _then(
      _value.copyWith(
            transactionId: null == transactionId
                ? _value.transactionId
                : transactionId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            providerRef: freezed == providerRef
                ? _value.providerRef
                : providerRef // ignore: cast_nullable_to_non_nullable
                      as String?,
            newBalance: freezed == newBalance
                ? _value.newBalance
                : newBalance // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TopupWalletResponseImplCopyWith<$Res>
    implements $TopupWalletResponseCopyWith<$Res> {
  factory _$$TopupWalletResponseImplCopyWith(
    _$TopupWalletResponseImpl value,
    $Res Function(_$TopupWalletResponseImpl) then,
  ) = __$$TopupWalletResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'transaction_id') String transactionId,
    String status,
    @JsonKey(name: 'provider_ref') String? providerRef,
    @JsonKey(name: 'new_balance') @FlexDoubleN() double? newBalance,
  });
}

/// @nodoc
class __$$TopupWalletResponseImplCopyWithImpl<$Res>
    extends _$TopupWalletResponseCopyWithImpl<$Res, _$TopupWalletResponseImpl>
    implements _$$TopupWalletResponseImplCopyWith<$Res> {
  __$$TopupWalletResponseImplCopyWithImpl(
    _$TopupWalletResponseImpl _value,
    $Res Function(_$TopupWalletResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TopupWalletResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionId = null,
    Object? status = null,
    Object? providerRef = freezed,
    Object? newBalance = freezed,
  }) {
    return _then(
      _$TopupWalletResponseImpl(
        transactionId: null == transactionId
            ? _value.transactionId
            : transactionId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        providerRef: freezed == providerRef
            ? _value.providerRef
            : providerRef // ignore: cast_nullable_to_non_nullable
                  as String?,
        newBalance: freezed == newBalance
            ? _value.newBalance
            : newBalance // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TopupWalletResponseImpl implements _TopupWalletResponse {
  const _$TopupWalletResponseImpl({
    @JsonKey(name: 'transaction_id') required this.transactionId,
    required this.status,
    @JsonKey(name: 'provider_ref') this.providerRef,
    @JsonKey(name: 'new_balance') @FlexDoubleN() this.newBalance,
  });

  factory _$TopupWalletResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopupWalletResponseImplFromJson(json);

  @override
  @JsonKey(name: 'transaction_id')
  final String transactionId;
  @override
  final String status;
  @override
  @JsonKey(name: 'provider_ref')
  final String? providerRef;
  @override
  @JsonKey(name: 'new_balance')
  @FlexDoubleN()
  final double? newBalance;

  @override
  String toString() {
    return 'TopupWalletResponse(transactionId: $transactionId, status: $status, providerRef: $providerRef, newBalance: $newBalance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopupWalletResponseImpl &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.providerRef, providerRef) ||
                other.providerRef == providerRef) &&
            (identical(other.newBalance, newBalance) ||
                other.newBalance == newBalance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, transactionId, status, providerRef, newBalance);

  /// Create a copy of TopupWalletResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopupWalletResponseImplCopyWith<_$TopupWalletResponseImpl> get copyWith =>
      __$$TopupWalletResponseImplCopyWithImpl<_$TopupWalletResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TopupWalletResponseImplToJson(this);
  }
}

abstract class _TopupWalletResponse implements TopupWalletResponse {
  const factory _TopupWalletResponse({
    @JsonKey(name: 'transaction_id') required final String transactionId,
    required final String status,
    @JsonKey(name: 'provider_ref') final String? providerRef,
    @JsonKey(name: 'new_balance') @FlexDoubleN() final double? newBalance,
  }) = _$TopupWalletResponseImpl;

  factory _TopupWalletResponse.fromJson(Map<String, dynamic> json) =
      _$TopupWalletResponseImpl.fromJson;

  @override
  @JsonKey(name: 'transaction_id')
  String get transactionId;
  @override
  String get status;
  @override
  @JsonKey(name: 'provider_ref')
  String? get providerRef;
  @override
  @JsonKey(name: 'new_balance')
  @FlexDoubleN()
  double? get newBalance;

  /// Create a copy of TopupWalletResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopupWalletResponseImplCopyWith<_$TopupWalletResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
