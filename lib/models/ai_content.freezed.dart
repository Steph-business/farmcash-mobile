// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NewsItem _$NewsItemFromJson(Map<String, dynamic> json) {
  return _NewsItem.fromJson(json);
}

/// @nodoc
mixin _$NewsItem {
  String get id => throw _privateConstructorUsedError;
  String get titre => throw _privateConstructorUsedError;
  String? get resume => throw _privateConstructorUsedError;
  String? get body => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String> get targetRoles => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get publishedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this NewsItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsItemCopyWith<NewsItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsItemCopyWith<$Res> {
  factory $NewsItemCopyWith(NewsItem value, $Res Function(NewsItem) then) =
      _$NewsItemCopyWithImpl<$Res, NewsItem>;
  @useResult
  $Res call({
    String id,
    String titre,
    String? resume,
    String? body,
    String? imageUrl,
    List<String> targetRoles,
    bool isActive,
    DateTime? publishedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$NewsItemCopyWithImpl<$Res, $Val extends NewsItem>
    implements $NewsItemCopyWith<$Res> {
  _$NewsItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titre = null,
    Object? resume = freezed,
    Object? body = freezed,
    Object? imageUrl = freezed,
    Object? targetRoles = null,
    Object? isActive = null,
    Object? publishedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            titre: null == titre
                ? _value.titre
                : titre // ignore: cast_nullable_to_non_nullable
                      as String,
            resume: freezed == resume
                ? _value.resume
                : resume // ignore: cast_nullable_to_non_nullable
                      as String?,
            body: freezed == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetRoles: null == targetRoles
                ? _value.targetRoles
                : targetRoles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            publishedAt: freezed == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$NewsItemImplCopyWith<$Res>
    implements $NewsItemCopyWith<$Res> {
  factory _$$NewsItemImplCopyWith(
    _$NewsItemImpl value,
    $Res Function(_$NewsItemImpl) then,
  ) = __$$NewsItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String titre,
    String? resume,
    String? body,
    String? imageUrl,
    List<String> targetRoles,
    bool isActive,
    DateTime? publishedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$NewsItemImplCopyWithImpl<$Res>
    extends _$NewsItemCopyWithImpl<$Res, _$NewsItemImpl>
    implements _$$NewsItemImplCopyWith<$Res> {
  __$$NewsItemImplCopyWithImpl(
    _$NewsItemImpl _value,
    $Res Function(_$NewsItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titre = null,
    Object? resume = freezed,
    Object? body = freezed,
    Object? imageUrl = freezed,
    Object? targetRoles = null,
    Object? isActive = null,
    Object? publishedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$NewsItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        titre: null == titre
            ? _value.titre
            : titre // ignore: cast_nullable_to_non_nullable
                  as String,
        resume: freezed == resume
            ? _value.resume
            : resume // ignore: cast_nullable_to_non_nullable
                  as String?,
        body: freezed == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetRoles: null == targetRoles
            ? _value._targetRoles
            : targetRoles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        publishedAt: freezed == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
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
class _$NewsItemImpl implements _NewsItem {
  const _$NewsItemImpl({
    required this.id,
    this.titre = '',
    this.resume,
    this.body,
    this.imageUrl,
    final List<String> targetRoles = const <String>[],
    this.isActive = true,
    this.publishedAt,
    this.createdAt,
  }) : _targetRoles = targetRoles;

  factory _$NewsItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String titre;
  @override
  final String? resume;
  @override
  final String? body;
  @override
  final String? imageUrl;
  final List<String> _targetRoles;
  @override
  @JsonKey()
  List<String> get targetRoles {
    if (_targetRoles is EqualUnmodifiableListView) return _targetRoles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetRoles);
  }

  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? publishedAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'NewsItem(id: $id, titre: $titre, resume: $resume, body: $body, imageUrl: $imageUrl, targetRoles: $targetRoles, isActive: $isActive, publishedAt: $publishedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.titre, titre) || other.titre == titre) &&
            (identical(other.resume, resume) || other.resume == resume) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(
              other._targetRoles,
              _targetRoles,
            ) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    titre,
    resume,
    body,
    imageUrl,
    const DeepCollectionEquality().hash(_targetRoles),
    isActive,
    publishedAt,
    createdAt,
  );

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsItemImplCopyWith<_$NewsItemImpl> get copyWith =>
      __$$NewsItemImplCopyWithImpl<_$NewsItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsItemImplToJson(this);
  }
}

abstract class _NewsItem implements NewsItem {
  const factory _NewsItem({
    required final String id,
    final String titre,
    final String? resume,
    final String? body,
    final String? imageUrl,
    final List<String> targetRoles,
    final bool isActive,
    final DateTime? publishedAt,
    final DateTime? createdAt,
  }) = _$NewsItemImpl;

  factory _NewsItem.fromJson(Map<String, dynamic> json) =
      _$NewsItemImpl.fromJson;

  @override
  String get id;
  @override
  String get titre;
  @override
  String? get resume;
  @override
  String? get body;
  @override
  String? get imageUrl;
  @override
  List<String> get targetRoles;
  @override
  bool get isActive;
  @override
  DateTime? get publishedAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsItemImplCopyWith<_$NewsItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiInsights _$AiInsightsFromJson(Map<String, dynamic> json) {
  return _AiInsights.fromJson(json);
}

/// @nodoc
mixin _$AiInsights {
  List<AiInsightItem> get tendances => throw _privateConstructorUsedError;
  List<AiInsightItem> get alertes => throw _privateConstructorUsedError;
  List<AiInsightItem> get opportunites => throw _privateConstructorUsedError;

  /// Serializes this AiInsights to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiInsights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiInsightsCopyWith<AiInsights> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiInsightsCopyWith<$Res> {
  factory $AiInsightsCopyWith(
    AiInsights value,
    $Res Function(AiInsights) then,
  ) = _$AiInsightsCopyWithImpl<$Res, AiInsights>;
  @useResult
  $Res call({
    List<AiInsightItem> tendances,
    List<AiInsightItem> alertes,
    List<AiInsightItem> opportunites,
  });
}

/// @nodoc
class _$AiInsightsCopyWithImpl<$Res, $Val extends AiInsights>
    implements $AiInsightsCopyWith<$Res> {
  _$AiInsightsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiInsights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tendances = null,
    Object? alertes = null,
    Object? opportunites = null,
  }) {
    return _then(
      _value.copyWith(
            tendances: null == tendances
                ? _value.tendances
                : tendances // ignore: cast_nullable_to_non_nullable
                      as List<AiInsightItem>,
            alertes: null == alertes
                ? _value.alertes
                : alertes // ignore: cast_nullable_to_non_nullable
                      as List<AiInsightItem>,
            opportunites: null == opportunites
                ? _value.opportunites
                : opportunites // ignore: cast_nullable_to_non_nullable
                      as List<AiInsightItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiInsightsImplCopyWith<$Res>
    implements $AiInsightsCopyWith<$Res> {
  factory _$$AiInsightsImplCopyWith(
    _$AiInsightsImpl value,
    $Res Function(_$AiInsightsImpl) then,
  ) = __$$AiInsightsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<AiInsightItem> tendances,
    List<AiInsightItem> alertes,
    List<AiInsightItem> opportunites,
  });
}

/// @nodoc
class __$$AiInsightsImplCopyWithImpl<$Res>
    extends _$AiInsightsCopyWithImpl<$Res, _$AiInsightsImpl>
    implements _$$AiInsightsImplCopyWith<$Res> {
  __$$AiInsightsImplCopyWithImpl(
    _$AiInsightsImpl _value,
    $Res Function(_$AiInsightsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiInsights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tendances = null,
    Object? alertes = null,
    Object? opportunites = null,
  }) {
    return _then(
      _$AiInsightsImpl(
        tendances: null == tendances
            ? _value._tendances
            : tendances // ignore: cast_nullable_to_non_nullable
                  as List<AiInsightItem>,
        alertes: null == alertes
            ? _value._alertes
            : alertes // ignore: cast_nullable_to_non_nullable
                  as List<AiInsightItem>,
        opportunites: null == opportunites
            ? _value._opportunites
            : opportunites // ignore: cast_nullable_to_non_nullable
                  as List<AiInsightItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiInsightsImpl implements _AiInsights {
  const _$AiInsightsImpl({
    final List<AiInsightItem> tendances = const <AiInsightItem>[],
    final List<AiInsightItem> alertes = const <AiInsightItem>[],
    final List<AiInsightItem> opportunites = const <AiInsightItem>[],
  }) : _tendances = tendances,
       _alertes = alertes,
       _opportunites = opportunites;

  factory _$AiInsightsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiInsightsImplFromJson(json);

  final List<AiInsightItem> _tendances;
  @override
  @JsonKey()
  List<AiInsightItem> get tendances {
    if (_tendances is EqualUnmodifiableListView) return _tendances;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tendances);
  }

  final List<AiInsightItem> _alertes;
  @override
  @JsonKey()
  List<AiInsightItem> get alertes {
    if (_alertes is EqualUnmodifiableListView) return _alertes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alertes);
  }

  final List<AiInsightItem> _opportunites;
  @override
  @JsonKey()
  List<AiInsightItem> get opportunites {
    if (_opportunites is EqualUnmodifiableListView) return _opportunites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_opportunites);
  }

  @override
  String toString() {
    return 'AiInsights(tendances: $tendances, alertes: $alertes, opportunites: $opportunites)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiInsightsImpl &&
            const DeepCollectionEquality().equals(
              other._tendances,
              _tendances,
            ) &&
            const DeepCollectionEquality().equals(other._alertes, _alertes) &&
            const DeepCollectionEquality().equals(
              other._opportunites,
              _opportunites,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_tendances),
    const DeepCollectionEquality().hash(_alertes),
    const DeepCollectionEquality().hash(_opportunites),
  );

  /// Create a copy of AiInsights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiInsightsImplCopyWith<_$AiInsightsImpl> get copyWith =>
      __$$AiInsightsImplCopyWithImpl<_$AiInsightsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiInsightsImplToJson(this);
  }
}

abstract class _AiInsights implements AiInsights {
  const factory _AiInsights({
    final List<AiInsightItem> tendances,
    final List<AiInsightItem> alertes,
    final List<AiInsightItem> opportunites,
  }) = _$AiInsightsImpl;

  factory _AiInsights.fromJson(Map<String, dynamic> json) =
      _$AiInsightsImpl.fromJson;

  @override
  List<AiInsightItem> get tendances;
  @override
  List<AiInsightItem> get alertes;
  @override
  List<AiInsightItem> get opportunites;

  /// Create a copy of AiInsights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiInsightsImplCopyWith<_$AiInsightsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiInsightItem _$AiInsightItemFromJson(Map<String, dynamic> json) {
  return _AiInsightItem.fromJson(json);
}

/// @nodoc
mixin _$AiInsightItem {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get titre => throw _privateConstructorUsedError;
  String? get body => throw _privateConstructorUsedError;
  String? get severity => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AiInsightItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiInsightItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiInsightItemCopyWith<AiInsightItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiInsightItemCopyWith<$Res> {
  factory $AiInsightItemCopyWith(
    AiInsightItem value,
    $Res Function(AiInsightItem) then,
  ) = _$AiInsightItemCopyWithImpl<$Res, AiInsightItem>;
  @useResult
  $Res call({
    String id,
    String type,
    String titre,
    String? body,
    String? severity,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$AiInsightItemCopyWithImpl<$Res, $Val extends AiInsightItem>
    implements $AiInsightItemCopyWith<$Res> {
  _$AiInsightItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiInsightItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? titre = null,
    Object? body = freezed,
    Object? severity = freezed,
    Object? data = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            titre: null == titre
                ? _value.titre
                : titre // ignore: cast_nullable_to_non_nullable
                      as String,
            body: freezed == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String?,
            severity: freezed == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as String?,
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
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
abstract class _$$AiInsightItemImplCopyWith<$Res>
    implements $AiInsightItemCopyWith<$Res> {
  factory _$$AiInsightItemImplCopyWith(
    _$AiInsightItemImpl value,
    $Res Function(_$AiInsightItemImpl) then,
  ) = __$$AiInsightItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    String titre,
    String? body,
    String? severity,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$AiInsightItemImplCopyWithImpl<$Res>
    extends _$AiInsightItemCopyWithImpl<$Res, _$AiInsightItemImpl>
    implements _$$AiInsightItemImplCopyWith<$Res> {
  __$$AiInsightItemImplCopyWithImpl(
    _$AiInsightItemImpl _value,
    $Res Function(_$AiInsightItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiInsightItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? titre = null,
    Object? body = freezed,
    Object? severity = freezed,
    Object? data = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AiInsightItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        titre: null == titre
            ? _value.titre
            : titre // ignore: cast_nullable_to_non_nullable
                  as String,
        body: freezed == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String?,
        severity: freezed == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as String?,
        data: freezed == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
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
class _$AiInsightItemImpl implements _AiInsightItem {
  const _$AiInsightItemImpl({
    this.id = '',
    this.type = '',
    this.titre = '',
    this.body,
    this.severity,
    final Map<String, dynamic>? data,
    this.createdAt,
  }) : _data = data;

  factory _$AiInsightItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiInsightItemImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String titre;
  @override
  final String? body;
  @override
  final String? severity;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AiInsightItem(id: $id, type: $type, titre: $titre, body: $body, severity: $severity, data: $data, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiInsightItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.titre, titre) || other.titre == titre) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    titre,
    body,
    severity,
    const DeepCollectionEquality().hash(_data),
    createdAt,
  );

  /// Create a copy of AiInsightItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiInsightItemImplCopyWith<_$AiInsightItemImpl> get copyWith =>
      __$$AiInsightItemImplCopyWithImpl<_$AiInsightItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiInsightItemImplToJson(this);
  }
}

abstract class _AiInsightItem implements AiInsightItem {
  const factory _AiInsightItem({
    final String id,
    final String type,
    final String titre,
    final String? body,
    final String? severity,
    final Map<String, dynamic>? data,
    final DateTime? createdAt,
  }) = _$AiInsightItemImpl;

  factory _AiInsightItem.fromJson(Map<String, dynamic> json) =
      _$AiInsightItemImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get titre;
  @override
  String? get body;
  @override
  String? get severity;
  @override
  Map<String, dynamic>? get data;
  @override
  DateTime? get createdAt;

  /// Create a copy of AiInsightItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiInsightItemImplCopyWith<_$AiInsightItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiChatMessage _$AiChatMessageFromJson(Map<String, dynamic> json) {
  return _AiChatMessage.fromJson(json);
}

/// @nodoc
mixin _$AiChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AiChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiChatMessageCopyWith<AiChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiChatMessageCopyWith<$Res> {
  factory $AiChatMessageCopyWith(
    AiChatMessage value,
    $Res Function(AiChatMessage) then,
  ) = _$AiChatMessageCopyWithImpl<$Res, AiChatMessage>;
  @useResult
  $Res call({String id, String role, String content, DateTime? createdAt});
}

/// @nodoc
class _$AiChatMessageCopyWithImpl<$Res, $Val extends AiChatMessage>
    implements $AiChatMessageCopyWith<$Res> {
  _$AiChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$AiChatMessageImplCopyWith<$Res>
    implements $AiChatMessageCopyWith<$Res> {
  factory _$$AiChatMessageImplCopyWith(
    _$AiChatMessageImpl value,
    $Res Function(_$AiChatMessageImpl) then,
  ) = __$$AiChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String role, String content, DateTime? createdAt});
}

/// @nodoc
class __$$AiChatMessageImplCopyWithImpl<$Res>
    extends _$AiChatMessageCopyWithImpl<$Res, _$AiChatMessageImpl>
    implements _$$AiChatMessageImplCopyWith<$Res> {
  __$$AiChatMessageImplCopyWithImpl(
    _$AiChatMessageImpl _value,
    $Res Function(_$AiChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$AiChatMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$AiChatMessageImpl implements _AiChatMessage {
  const _$AiChatMessageImpl({
    this.id = '',
    this.role = 'assistant',
    this.content = '',
    this.createdAt,
  });

  factory _$AiChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiChatMessageImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey()
  final String content;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AiChatMessage(id: $id, role: $role, content: $content, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, role, content, createdAt);

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiChatMessageImplCopyWith<_$AiChatMessageImpl> get copyWith =>
      __$$AiChatMessageImplCopyWithImpl<_$AiChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiChatMessageImplToJson(this);
  }
}

abstract class _AiChatMessage implements AiChatMessage {
  const factory _AiChatMessage({
    final String id,
    final String role,
    final String content,
    final DateTime? createdAt,
  }) = _$AiChatMessageImpl;

  factory _AiChatMessage.fromJson(Map<String, dynamic> json) =
      _$AiChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get role;
  @override
  String get content;
  @override
  DateTime? get createdAt;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiChatMessageImplCopyWith<_$AiChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
