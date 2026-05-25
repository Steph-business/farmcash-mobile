import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// Message dans une conversation.
///
/// **`senderId` est nullable** : le backend autorise `sender_id = null`
/// pour les messages système (annonces, notifications de workflow,
/// messages générés par l'IA). Avant ce changement, `Message.fromJson`
/// crashait avec `type 'Null' is not a subtype of type 'String'` dès
/// qu'une conversation contenait un message système, ce qui faisait
/// échouer toute la page chat avec un "Chargement échoué" générique.
@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    String? senderId,
    String? content,
    String? mediaUrl,
    String? mediaType,
    @Default(false) bool isRead,
    DateTime? createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
