import 'package:freezed_annotation/freezed_annotation.dart';

import 'message.dart';
import 'utilisateur.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
class Conversation with _$Conversation {
  const Conversation._();

  const factory Conversation({
    required String id,
    @Default('DIRECT') String type,
    @Default(false) bool isAiSession,
    @Default(<ConversationParticipant>[])
    List<ConversationParticipant> participants,
    Message? lastMessage,
    @Default(0) int unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  List<String> get participantIds =>
      participants.map((p) => p.userId).toList();
}

@freezed
class ConversationParticipant with _$ConversationParticipant {
  const ConversationParticipant._();

  const factory ConversationParticipant({
    required String id,
    required String userId,
    Utilisateur? user,
    DateTime? joinedAt,
    DateTime? lastReadAt,
  }) = _ConversationParticipant;

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) =>
      _$ConversationParticipantFromJson(json);

  String? get fullName => user?.fullName;
  String? get photoUrl => user?.photoUrl;
}
