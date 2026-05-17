// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$ConversationImpl',
      json,
      ($checkedConvert) {
        final val = _$ConversationImpl(
          id: $checkedConvert('id', (v) => v as String),
          type: $checkedConvert('type', (v) => v as String? ?? 'DIRECT'),
          isAiSession: $checkedConvert(
            'is_ai_session',
            (v) => v as bool? ?? false,
          ),
          participants: $checkedConvert(
            'participants',
            (v) =>
                (v as List<dynamic>?)
                    ?.map(
                      (e) => ConversationParticipant.fromJson(
                        e as Map<String, dynamic>,
                      ),
                    )
                    .toList() ??
                const <ConversationParticipant>[],
          ),
          lastMessage: $checkedConvert(
            'last_message',
            (v) =>
                v == null ? null : Message.fromJson(v as Map<String, dynamic>),
          ),
          unreadCount: $checkedConvert(
            'unread_count',
            (v) => (v as num?)?.toInt() ?? 0,
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'isAiSession': 'is_ai_session',
        'lastMessage': 'last_message',
        'unreadCount': 'unread_count',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'is_ai_session': instance.isAiSession,
      'participants': instance.participants,
      if (instance.lastMessage case final value?) 'last_message': value,
      'unread_count': instance.unreadCount,
      if (instance.createdAt?.toIso8601String() case final value?)
        'created_at': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updated_at': value,
    };

_$ConversationParticipantImpl _$$ConversationParticipantImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$ConversationParticipantImpl',
  json,
  ($checkedConvert) {
    final val = _$ConversationParticipantImpl(
      id: $checkedConvert('id', (v) => v as String),
      userId: $checkedConvert('user_id', (v) => v as String),
      user: $checkedConvert(
        'user',
        (v) =>
            v == null ? null : Utilisateur.fromJson(v as Map<String, dynamic>),
      ),
      joinedAt: $checkedConvert(
        'joined_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      lastReadAt: $checkedConvert(
        'last_read_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'userId': 'user_id',
    'joinedAt': 'joined_at',
    'lastReadAt': 'last_read_at',
  },
);

Map<String, dynamic> _$$ConversationParticipantImplToJson(
  _$ConversationParticipantImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  if (instance.user case final value?) 'user': value,
  if (instance.joinedAt?.toIso8601String() case final value?)
    'joined_at': value,
  if (instance.lastReadAt?.toIso8601String() case final value?)
    'last_read_at': value,
};
