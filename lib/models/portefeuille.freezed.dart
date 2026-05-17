// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'portefeuille.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Portefeuille _$PortefeuilleFromJson(Map<String, dynamic> json) {
  return _Portefeuille.fromJson(json);
}

/// @nodoc
mixin _$Portefeuille {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  @FlexDouble()
  double get balance => throw _privateConstructorUsedError;
  @FlexDouble()
  double get balanceEscrow => throw _privateConstructorUsedError;

  /// Serializes this Portefeuille to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Portefeuille
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PortefeuilleCopyWith<Portefeuille> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PortefeuilleCopyWith<$Res> {
  factory $PortefeuilleCopyWith(
    Portefeuille value,
    $Res Function(Portefeuille) then,
  ) = _$PortefeuilleCopyWithImpl<$Res, Portefeuille>;
  @useResult
  $Res call({
    String id,
    String userId,
    String currency,
    @FlexDouble() double balance,
    @FlexDouble() double balanceEscrow,
  });
}

/// @nodoc
class _$PortefeuilleCopyWithImpl<$Res, $Val extends Portefeuille>
    implements $PortefeuilleCopyWith<$Res> {
  _$PortefeuilleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Portefeuille
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? currency = null,
    Object? balance = null,
    Object? balanceEscrow = null,
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
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            balance: null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                      as double,
            balanceEscrow: null == balanceEscrow
                ? _value.balanceEscrow
                : balanceEscrow // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PortefeuilleImplCopyWith<$Res>
    implements $PortefeuilleCopyWith<$Res> {
  factory _$$PortefeuilleImplCopyWith(
    _$PortefeuilleImpl value,
    $Res Function(_$PortefeuilleImpl) then,
  ) = __$$PortefeuilleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String currency,
    @FlexDouble() double balance,
    @FlexDouble() double balanceEscrow,
  });
}

/// @nodoc
class __$$PortefeuilleImplCopyWithImpl<$Res>
    extends _$PortefeuilleCopyWithImpl<$Res, _$PortefeuilleImpl>
    implements _$$PortefeuilleImplCopyWith<$Res> {
  __$$PortefeuilleImplCopyWithImpl(
    _$PortefeuilleImpl _value,
    $Res Function(_$PortefeuilleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Portefeuille
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? currency = null,
    Object? balance = null,
    Object? balanceEscrow = null,
  }) {
    return _then(
      _$PortefeuilleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        balance: null == balance
            ? _value.balance
            : balance // ignore: cast_nullable_to_non_nullable
                  as double,
        balanceEscrow: null == balanceEscrow
            ? _value.balanceEscrow
            : balanceEscrow // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PortefeuilleImpl extends _Portefeuille {
  const _$PortefeuilleImpl({
    this.id = '',
    this.userId = '',
    this.currency = 'XOF',
    @FlexDouble() this.balance = 0.0,
    @FlexDouble() this.balanceEscrow = 0.0,
  }) : super._();

  factory _$PortefeuilleImpl.fromJson(Map<String, dynamic> json) =>
      _$$PortefeuilleImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String userId;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  @FlexDouble()
  final double balance;
  @override
  @JsonKey()
  @FlexDouble()
  final double balanceEscrow;

  @override
  String toString() {
    return 'Portefeuille(id: $id, userId: $userId, currency: $currency, balance: $balance, balanceEscrow: $balanceEscrow)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PortefeuilleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.balanceEscrow, balanceEscrow) ||
                other.balanceEscrow == balanceEscrow));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, currency, balance, balanceEscrow);

  /// Create a copy of Portefeuille
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PortefeuilleImplCopyWith<_$PortefeuilleImpl> get copyWith =>
      __$$PortefeuilleImplCopyWithImpl<_$PortefeuilleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PortefeuilleImplToJson(this);
  }
}

abstract class _Portefeuille extends Portefeuille {
  const factory _Portefeuille({
    final String id,
    final String userId,
    final String currency,
    @FlexDouble() final double balance,
    @FlexDouble() final double balanceEscrow,
  }) = _$PortefeuilleImpl;
  const _Portefeuille._() : super._();

  factory _Portefeuille.fromJson(Map<String, dynamic> json) =
      _$PortefeuilleImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get currency;
  @override
  @FlexDouble()
  double get balance;
  @override
  @FlexDouble()
  double get balanceEscrow;

  /// Create a copy of Portefeuille
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PortefeuilleImplCopyWith<_$PortefeuilleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MoyenPayement _$MoyenPayementFromJson(Map<String, dynamic> json) {
  return _MoyenPayement.fromJson(json);
}

/// @nodoc
mixin _$MoyenPayement {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  String get phoneDisplay => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MoyenPayement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MoyenPayement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MoyenPayementCopyWith<MoyenPayement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MoyenPayementCopyWith<$Res> {
  factory $MoyenPayementCopyWith(
    MoyenPayement value,
    $Res Function(MoyenPayement) then,
  ) = _$MoyenPayementCopyWithImpl<$Res, MoyenPayement>;
  @useResult
  $Res call({
    String id,
    String userId,
    String provider,
    String phoneDisplay,
    bool isDefault,
    bool isActive,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$MoyenPayementCopyWithImpl<$Res, $Val extends MoyenPayement>
    implements $MoyenPayementCopyWith<$Res> {
  _$MoyenPayementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MoyenPayement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? provider = null,
    Object? phoneDisplay = null,
    Object? isDefault = null,
    Object? isActive = null,
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
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneDisplay: null == phoneDisplay
                ? _value.phoneDisplay
                : phoneDisplay // ignore: cast_nullable_to_non_nullable
                      as String,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$MoyenPayementImplCopyWith<$Res>
    implements $MoyenPayementCopyWith<$Res> {
  factory _$$MoyenPayementImplCopyWith(
    _$MoyenPayementImpl value,
    $Res Function(_$MoyenPayementImpl) then,
  ) = __$$MoyenPayementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String provider,
    String phoneDisplay,
    bool isDefault,
    bool isActive,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$MoyenPayementImplCopyWithImpl<$Res>
    extends _$MoyenPayementCopyWithImpl<$Res, _$MoyenPayementImpl>
    implements _$$MoyenPayementImplCopyWith<$Res> {
  __$$MoyenPayementImplCopyWithImpl(
    _$MoyenPayementImpl _value,
    $Res Function(_$MoyenPayementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MoyenPayement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? provider = null,
    Object? phoneDisplay = null,
    Object? isDefault = null,
    Object? isActive = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$MoyenPayementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneDisplay: null == phoneDisplay
            ? _value.phoneDisplay
            : phoneDisplay // ignore: cast_nullable_to_non_nullable
                  as String,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$MoyenPayementImpl implements _MoyenPayement {
  const _$MoyenPayementImpl({
    required this.id,
    required this.userId,
    this.provider = 'UNKNOWN',
    this.phoneDisplay = '',
    this.isDefault = false,
    this.isActive = true,
    this.createdAt,
  });

  factory _$MoyenPayementImpl.fromJson(Map<String, dynamic> json) =>
      _$$MoyenPayementImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @JsonKey()
  final String provider;
  @override
  @JsonKey()
  final String phoneDisplay;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'MoyenPayement(id: $id, userId: $userId, provider: $provider, phoneDisplay: $phoneDisplay, isDefault: $isDefault, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MoyenPayementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.phoneDisplay, phoneDisplay) ||
                other.phoneDisplay == phoneDisplay) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    provider,
    phoneDisplay,
    isDefault,
    isActive,
    createdAt,
  );

  /// Create a copy of MoyenPayement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MoyenPayementImplCopyWith<_$MoyenPayementImpl> get copyWith =>
      __$$MoyenPayementImplCopyWithImpl<_$MoyenPayementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MoyenPayementImplToJson(this);
  }
}

abstract class _MoyenPayement implements MoyenPayement {
  const factory _MoyenPayement({
    required final String id,
    required final String userId,
    final String provider,
    final String phoneDisplay,
    final bool isDefault,
    final bool isActive,
    final DateTime? createdAt,
  }) = _$MoyenPayementImpl;

  factory _MoyenPayement.fromJson(Map<String, dynamic> json) =
      _$MoyenPayementImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get provider;
  @override
  String get phoneDisplay;
  @override
  bool get isDefault;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;

  /// Create a copy of MoyenPayement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MoyenPayementImplCopyWith<_$MoyenPayementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
