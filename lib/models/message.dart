import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// Message dans une conversation OU dans une négociation.
///
/// **`conversationId` est nullable** : le backend renvoie `null` pour
/// les messages liés à une négociation (proposition / candidature /
/// contre-offre) — ces messages sont rattachés à `proposition_id` ou
/// `candidature_id` côté DB, pas à une `conversation_id`. Avant ce
/// changement, `Message.fromJson` crashait avec `type 'Null' is not a
/// subtype of type 'String'` dès qu'on chargeait la discussion d'une
/// proposition.
///
/// **`senderId` est nullable** : le backend autorise `sender_id = null`
/// pour les messages système (annonces, notifications de workflow,
/// messages générés par l'IA).
@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    String? conversationId,
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
