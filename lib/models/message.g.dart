// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$MessageImpl',
      json,
      ($checkedConvert) {
        final val = _$MessageImpl(
          id: $checkedConvert('id', (v) => v as String),
          conversationId: $checkedConvert(
            'conversation_id',
            (v) => v as String?,
          ),
          senderId: $checkedConvert('sender_id', (v) => v as String?),
          content: $checkedConvert('content', (v) => v as String?),
          mediaUrl: $checkedConvert('media_url', (v) => v as String?),
          mediaType: $checkedConvert('media_type', (v) => v as String?),
          isRead: $checkedConvert('is_read', (v) => v as bool? ?? false),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'conversationId': 'conversation_id',
        'senderId': 'sender_id',
        'mediaUrl': 'media_url',
        'mediaType': 'media_type',
        'isRead': 'is_read',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.conversationId case final value?) 'conversation_id': value,
      if (instance.senderId case final value?) 'sender_id': value,
      if (instance.content case final value?) 'content': value,
      if (instance.mediaUrl case final value?) 'media_url': value,
      if (instance.mediaType case final value?) 'media_type': value,
      'is_read': instance.isRead,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
    };
