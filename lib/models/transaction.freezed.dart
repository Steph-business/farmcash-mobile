// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @FlexDouble()
  double get montant => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get commandeId => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get balanceAvant => throw _privateConstructorUsedError;
  @FlexDoubleN()
  double? get balanceApres => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MobileProvider.unknown)
  MobileProvider? get provider => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
    Transaction value,
    $Res Function(Transaction) then,
  ) = _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call({
    String id,
    String userId,
    String type,
    @FlexDouble() double montant,
    String status,
    String? commandeId,
    @FlexDoubleN() double? balanceAvant,
    @FlexDoubleN() double? balanceApres,
    @JsonKey(unknownEnumValue: MobileProvider.unknown) MobileProvider? provider,
    String? reference,
    String? description,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? montant = null,
    Object? status = null,
    Object? commandeId = freezed,
    Object? balanceAvant = freezed,
    Object? balanceApres = freezed,
    Object? provider = freezed,
    Object? reference = freezed,
    Object? description = freezed,
    Object? createdAt = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            montant: null == montant
                ? _value.montant
                : montant // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            commandeId: freezed == commandeId
                ? _value.commandeId
                : commandeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            balanceAvant: freezed == balanceAvant
                ? _value.balanceAvant
                : balanceAvant // ignore: cast_nullable_to_non_nullable
                      as double?,
            balanceApres: freezed == balanceApres
                ? _value.balanceApres
                : balanceApres // ignore: cast_nullable_to_non_nullable
                      as double?,
            provider: freezed == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as MobileProvider?,
            reference: freezed == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
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
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
    _$TransactionImpl value,
    $Res Function(_$TransactionImpl) then,
  ) = __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String type,
    @FlexDouble() double montant,
    String status,
    String? commandeId,
    @FlexDoubleN() double? balanceAvant,
    @FlexDoubleN() double? balanceApres,
    @JsonKey(unknownEnumValue: MobileProvider.unknown) MobileProvider? provider,
    String? reference,
    String? description,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
    _$TransactionImpl _value,
    $Res Function(_$TransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? montant = null,
    Object? status = null,
    Object? commandeId = freezed,
    Object? balanceAvant = freezed,
    Object? balanceApres = freezed,
    Object? provider = freezed,
    Object? reference = freezed,
    Object? description = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        montant: null == montant
            ? _value.montant
            : montant // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        commandeId: freezed == commandeId
            ? _value.commandeId
            : commandeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        balanceAvant: freezed == balanceAvant
            ? _value.balanceAvant
            : balanceAvant // ignore: cast_nullable_to_non_nullable
                  as double?,
        balanceApres: freezed == balanceApres
            ? _value.balanceApres
            : balanceApres // ignore: cast_nullable_to_non_nullable
                  as double?,
        provider: freezed == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as MobileProvider?,
        reference: freezed == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
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
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl({
    required this.id,
    required this.userId,
    this.type = 'UNKNOWN',
    @FlexDouble() required this.montant,
    this.status = 'PENDING',
    this.commandeId,
    @FlexDoubleN() this.balanceAvant,
    @FlexDoubleN() this.balanceApres,
    @JsonKey(unknownEnumValue: MobileProvider.unknown) this.provider,
    this.reference,
    this.description,
    this.createdAt,
  });

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @JsonKey()
  final String type;
  @override
  @FlexDouble()
  final double montant;
  @override
  @JsonKey()
  final String status;
  @override
  final String? commandeId;
  @override
  @FlexDoubleN()
  final double? balanceAvant;
  @override
  @FlexDoubleN()
  final double? balanceApres;
  @override
  @JsonKey(unknownEnumValue: MobileProvider.unknown)
  final MobileProvider? provider;
  @override
  final String? reference;
  @override
  final String? description;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Transaction(id: $id, userId: $userId, type: $type, montant: $montant, status: $status, commandeId: $commandeId, balanceAvant: $balanceAvant, balanceApres: $balanceApres, provider: $provider, reference: $reference, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.montant, montant) || other.montant == montant) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.commandeId, commandeId) ||
                other.commandeId == commandeId) &&
            (identical(other.balanceAvant, balanceAvant) ||
                other.balanceAvant == balanceAvant) &&
            (identical(other.balanceApres, balanceApres) ||
                other.balanceApres == balanceApres) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    type,
    montant,
    status,
    commandeId,
    balanceAvant,
    balanceApres,
    provider,
    reference,
    description,
    createdAt,
  );

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(this);
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction({
    required final String id,
    required final String userId,
    final String type,
    @FlexDouble() required final double montant,
    final String status,
    final String? commandeId,
    @FlexDoubleN() final double? balanceAvant,
    @FlexDoubleN() final double? balanceApres,
    @JsonKey(unknownEnumValue: MobileProvider.unknown)
    final MobileProvider? provider,
    final String? reference,
    final String? description,
    final DateTime? createdAt,
  }) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get type;
  @override
  @FlexDouble()
  double get montant;
  @override
  String get status;
  @override
  String? get commandeId;
  @override
  @FlexDoubleN()
  double? get balanceAvant;
  @override
  @FlexDoubleN()
  double? get balanceApres;
  @override
  @JsonKey(unknownEnumValue: MobileProvider.unknown)
  MobileProvider? get provider;
  @override
  String? get reference;
  @override
  String? get description;
  @override
  DateTime? get createdAt;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
