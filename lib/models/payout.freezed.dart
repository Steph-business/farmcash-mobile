// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PayoutBatch _$PayoutBatchFromJson(Map<String, dynamic> json) {
  return _PayoutBatch.fromJson(json);
}

/// @nodoc
mixin _$PayoutBatch {
  String get id => throw _privateConstructorUsedError;
  String get initiatorId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get totalAmount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<PayoutItem> get items => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this PayoutBatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayoutBatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayoutBatchCopyWith<PayoutBatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayoutBatchCopyWith<$Res> {
  factory $PayoutBatchCopyWith(
    PayoutBatch value,
    $Res Function(PayoutBatch) then,
  ) = _$PayoutBatchCopyWithImpl<$Res, PayoutBatch>;
  @useResult
  $Res call({
    String id,
    String initiatorId,
    @FlexDouble() double totalAmount,
    String status,
    List<PayoutItem> items,
    DateTime? createdAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$PayoutBatchCopyWithImpl<$Res, $Val extends PayoutBatch>
    implements $PayoutBatchCopyWith<$Res> {
  _$PayoutBatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayoutBatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initiatorId = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? items = null,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            initiatorId: null == initiatorId
                ? _value.initiatorId
                : initiatorId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<PayoutItem>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PayoutBatchImplCopyWith<$Res>
    implements $PayoutBatchCopyWith<$Res> {
  factory _$$PayoutBatchImplCopyWith(
    _$PayoutBatchImpl value,
    $Res Function(_$PayoutBatchImpl) then,
  ) = __$$PayoutBatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String initiatorId,
    @FlexDouble() double totalAmount,
    String status,
    List<PayoutItem> items,
    DateTime? createdAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$PayoutBatchImplCopyWithImpl<$Res>
    extends _$PayoutBatchCopyWithImpl<$Res, _$PayoutBatchImpl>
    implements _$$PayoutBatchImplCopyWith<$Res> {
  __$$PayoutBatchImplCopyWithImpl(
    _$PayoutBatchImpl _value,
    $Res Function(_$PayoutBatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PayoutBatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initiatorId = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? items = null,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$PayoutBatchImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        initiatorId: null == initiatorId
            ? _value.initiatorId
            : initiatorId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<PayoutItem>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PayoutBatchImpl implements _PayoutBatch {
  const _$PayoutBatchImpl({
    required this.id,
    required this.initiatorId,
    @FlexDouble() required this.totalAmount,
    this.status = 'PENDING',
    final List<PayoutItem> items = const <PayoutItem>[],
    this.createdAt,
    this.completedAt,
  }) : _items = items;

  factory _$PayoutBatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayoutBatchImplFromJson(json);

  @override
  final String id;
  @override
  final String initiatorId;
  @override
  @FlexDouble()
  final double totalAmount;
  @override
  @JsonKey()
  final String status;
  final List<PayoutItem> _items;
  @override
  @JsonKey()
  List<PayoutItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'PayoutBatch(id: $id, initiatorId: $initiatorId, totalAmount: $totalAmount, status: $status, items: $items, createdAt: $createdAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayoutBatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.initiatorId, initiatorId) ||
                other.initiatorId == initiatorId) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    initiatorId,
    totalAmount,
    status,
    const DeepCollectionEquality().hash(_items),
    createdAt,
    completedAt,
  );

  /// Create a copy of PayoutBatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayoutBatchImplCopyWith<_$PayoutBatchImpl> get copyWith =>
      __$$PayoutBatchImplCopyWithImpl<_$PayoutBatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayoutBatchImplToJson(this);
  }
}

abstract class _PayoutBatch implements PayoutBatch {
  const factory _PayoutBatch({
    required final String id,
    required final String initiatorId,
    @FlexDouble() required final double totalAmount,
    final String status,
    final List<PayoutItem> items,
    final DateTime? createdAt,
    final DateTime? completedAt,
  }) = _$PayoutBatchImpl;

  factory _PayoutBatch.fromJson(Map<String, dynamic> json) =
      _$PayoutBatchImpl.fromJson;

  @override
  String get id;
  @override
  String get initiatorId;
  @override
  @FlexDouble()
  double get totalAmount;
  @override
  String get status;
  @override
  List<PayoutItem> get items;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of PayoutBatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayoutBatchImplCopyWith<_$PayoutBatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PayoutItem _$PayoutItemFromJson(Map<String, dynamic> json) {
  return _PayoutItem.fromJson(json);
}

/// @nodoc
mixin _$PayoutItem {
  String get id => throw _privateConstructorUsedError;
  String get batchId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  @FlexDouble()
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MobileProvider.unknown)
  MobileProvider get provider => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this PayoutItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayoutItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayoutItemCopyWith<PayoutItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayoutItemCopyWith<$Res> {
  factory $PayoutItemCopyWith(
    PayoutItem value,
    $Res Function(PayoutItem) then,
  ) = _$PayoutItemCopyWithImpl<$Res, PayoutItem>;
  @useResult
  $Res call({
    String id,
    String batchId,
    String userId,
    @FlexDouble() double amount,
    @JsonKey(unknownEnumValue: MobileProvider.unknown) MobileProvider provider,
    String status,
    String? errorMessage,
  });
}

/// @nodoc
class _$PayoutItemCopyWithImpl<$Res, $Val extends PayoutItem>
    implements $PayoutItemCopyWith<$Res> {
  _$PayoutItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayoutItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? batchId = null,
    Object? userId = null,
    Object? amount = null,
    Object? provider = null,
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            batchId: null == batchId
                ? _value.batchId
                : batchId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as MobileProvider,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PayoutItemImplCopyWith<$Res>
    implements $PayoutItemCopyWith<$Res> {
  factory _$$PayoutItemImplCopyWith(
    _$PayoutItemImpl value,
    $Res Function(_$PayoutItemImpl) then,
  ) = __$$PayoutItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String batchId,
    String userId,
    @FlexDouble() double amount,
    @JsonKey(unknownEnumValue: MobileProvider.unknown) MobileProvider provider,
    String status,
    String? errorMessage,
  });
}

/// @nodoc
class __$$PayoutItemImplCopyWithImpl<$Res>
    extends _$PayoutItemCopyWithImpl<$Res, _$PayoutItemImpl>
    implements _$$PayoutItemImplCopyWith<$Res> {
  __$$PayoutItemImplCopyWithImpl(
    _$PayoutItemImpl _value,
    $Res Function(_$PayoutItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PayoutItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? batchId = null,
    Object? userId = null,
    Object? amount = null,
    Object? provider = null,
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$PayoutItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        batchId: null == batchId
            ? _value.batchId
            : batchId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as MobileProvider,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PayoutItemImpl implements _PayoutItem {
  const _$PayoutItemImpl({
    required this.id,
    required this.batchId,
    required this.userId,
    @FlexDouble() required this.amount,
    @JsonKey(unknownEnumValue: MobileProvider.unknown)
    this.provider = MobileProvider.unknown,
    this.status = 'PENDING',
    this.errorMessage,
  });

  factory _$PayoutItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayoutItemImplFromJson(json);

  @override
  final String id;
  @override
  final String batchId;
  @override
  final String userId;
  @override
  @FlexDouble()
  final double amount;
  @override
  @JsonKey(unknownEnumValue: MobileProvider.unknown)
  final MobileProvider provider;
  @override
  @JsonKey()
  final String status;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PayoutItem(id: $id, batchId: $batchId, userId: $userId, amount: $amount, provider: $provider, status: $status, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayoutItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    batchId,
    userId,
    amount,
    provider,
    status,
    errorMessage,
  );

  /// Create a copy of PayoutItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayoutItemImplCopyWith<_$PayoutItemImpl> get copyWith =>
      __$$PayoutItemImplCopyWithImpl<_$PayoutItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayoutItemImplToJson(this);
  }
}

abstract class _PayoutItem implements PayoutItem {
  const factory _PayoutItem({
    required final String id,
    required final String batchId,
    required final String userId,
    @FlexDouble() required final double amount,
    @JsonKey(unknownEnumValue: MobileProvider.unknown)
    final MobileProvider provider,
    final String status,
    final String? errorMessage,
  }) = _$PayoutItemImpl;

  factory _PayoutItem.fromJson(Map<String, dynamic> json) =
      _$PayoutItemImpl.fromJson;

  @override
  String get id;
  @override
  String get batchId;
  @override
  String get userId;
  @override
  @FlexDouble()
  double get amount;
  @override
  @JsonKey(unknownEnumValue: MobileProvider.unknown)
  MobileProvider get provider;
  @override
  String get status;
  @override
  String? get errorMessage;

  /// Create a copy of PayoutItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayoutItemImplCopyWith<_$PayoutItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
