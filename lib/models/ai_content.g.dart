// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsItemImpl _$$NewsItemImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$NewsItemImpl',
      json,
      ($checkedConvert) {
        final val = _$NewsItemImpl(
          id: $checkedConvert('id', (v) => v as String),
          titre: $checkedConvert('titre', (v) => v as String? ?? ''),
          resume: $checkedConvert('resume', (v) => v as String?),
          body: $checkedConvert('body', (v) => v as String?),
          imageUrl: $checkedConvert('image_url', (v) => v as String?),
          targetRoles: $checkedConvert(
            'target_roles',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const <String>[],
          ),
          isActive: $checkedConvert('is_active', (v) => v as bool? ?? true),
          publishedAt: $checkedConvert(
            'published_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'imageUrl': 'image_url',
        'targetRoles': 'target_roles',
        'isActive': 'is_active',
        'publishedAt': 'published_at',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$$NewsItemImplToJson(_$NewsItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titre': instance.titre,
      if (instance.resume case final value?) 'resume': value,
      if (instance.body case final value?) 'body': value,
      if (instance.imageUrl case final value?) 'image_url': value,
      'target_roles': instance.targetRoles,
      'is_active': instance.isActive,
      if (instance.publishedAt?.toIso8601String() case final value?)
        'published_at': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };

_$AiInsightsImpl _$$AiInsightsImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$AiInsightsImpl', json, ($checkedConvert) {
  final val = _$AiInsightsImpl(
    tendances: $checkedConvert(
      'tendances',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => AiInsightItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AiInsightItem>[],
    ),
    alertes: $checkedConvert(
      'alertes',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => AiInsightItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AiInsightItem>[],
    ),
    opportunites: $checkedConvert(
      'opportunites',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => AiInsightItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AiInsightItem>[],
    ),
  );
  return val;
});

Map<String, dynamic> _$$AiInsightsImplToJson(_$AiInsightsImpl instance) =>
    <String, dynamic>{
      'tendances': instance.tendances,
      'alertes': instance.alertes,
      'opportunites': instance.opportunites,
    };

_$AiInsightItemImpl _$$AiInsightItemImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$AiInsightItemImpl', json, ($checkedConvert) {
      final val = _$AiInsightItemImpl(
        id: $checkedConvert('id', (v) => v as String? ?? ''),
        type: $checkedConvert('type', (v) => v as String? ?? ''),
        titre: $checkedConvert('titre', (v) => v as String? ?? ''),
        body: $checkedConvert('body', (v) => v as String?),
        severity: $checkedConvert('severity', (v) => v as String?),
        data: $checkedConvert('data', (v) => v as Map<String, dynamic>?),
        createdAt: $checkedConvert(
          'created_at',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'createdAt': 'created_at'});

Map<String, dynamic> _$$AiInsightItemImplToJson(_$AiInsightItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'titre': instance.titre,
      if (instance.body case final value?) 'body': value,
      if (instance.severity case final value?) 'severity': value,
      if (instance.data case final value?) 'data': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };

_$AiChatMessageImpl _$$AiChatMessageImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$AiChatMessageImpl', json, ($checkedConvert) {
      final val = _$AiChatMessageImpl(
        id: $checkedConvert('id', (v) => v as String? ?? ''),
        role: $checkedConvert('role', (v) => v as String? ?? 'assistant'),
        content: $checkedConvert('content', (v) => v as String? ?? ''),
        createdAt: $checkedConvert(
          'created_at',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'createdAt': 'created_at'});

Map<String, dynamic> _$$AiChatMessageImplToJson(_$AiChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'content': instance.content,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };
