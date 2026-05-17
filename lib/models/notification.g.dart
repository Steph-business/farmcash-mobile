// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  r'_$AppNotificationImpl',
  json,
  ($checkedConvert) {
    final val = _$AppNotificationImpl(
      id: $checkedConvert('id', (v) => v as String),
      userId: $checkedConvert('user_id', (v) => v as String),
      type: $checkedConvert('type', (v) => v as String? ?? 'GENERIC'),
      titre: $checkedConvert('titre', (v) => v as String? ?? ''),
      body: $checkedConvert('body', (v) => v as String?),
      isRead: $checkedConvert('is_read', (v) => v as bool? ?? false),
      data: $checkedConvert('data', (v) => v as Map<String, dynamic>?),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'userId': 'user_id',
    'isRead': 'is_read',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$$AppNotificationImplToJson(
  _$AppNotificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'type': instance.type,
  'titre': instance.titre,
  if (instance.body case final value?) 'body': value,
  'is_read': instance.isRead,
  if (instance.data case final value?) 'data': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'created_at': value,
};
