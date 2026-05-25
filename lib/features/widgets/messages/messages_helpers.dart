import 'package:intl/intl.dart';

import '../../../models/conversation.dart';
import '../../../models/enums.dart';
import 'messages_types.dart';

/// Helpers de transformation Conversation → données UI.
///
/// Mutualisés entre la page Messages et les widgets extraits
/// (`TuileConversation`, `CorpsConversation`, etc.). Pure functions —
/// pas d'état, pas de side-effect.

/// Retourne le participant autre que [currentUserId]. Si la conversation
/// est dégradée (1 seul participant ou auto-conv), on retombe sur le
/// premier participant connu.
ConversationParticipant? otherParticipant(
  Conversation conv,
  String? currentUserId,
) {
  if (conv.participants.isEmpty) return null;
  if (currentUserId == null) return conv.participants.first;
  return conv.participants.firstWhere(
    (p) => p.userId != currentUserId,
    orElse: () => conv.participants.first,
  );
}

/// Nom affiché de l'autre côté. Pour les conversations IA
/// (`isAiSession == true`), on retourne "Assistant agronomique" — pas
/// le `fullName` d'un participant (l'IA n'est pas dans la table users).
/// Fallback "Utilisateur" pour ne jamais afficher de chaîne vide.
String otherName(Conversation conv, String? currentUserId) {
  if (conv.isAiSession) return 'Assistant agronomique';
  final p = otherParticipant(conv, currentUserId);
  final name = p?.fullName?.trim();
  if (name == null || name.isEmpty) return 'Utilisateur';
  return name;
}

/// Mappe [UserRole] (backend) sur [RoleInterlocuteur] (couleurs UI).
RoleInterlocuteur? otherRole(Conversation conv, String? currentUserId) {
  final p = otherParticipant(conv, currentUserId);
  final role = p?.user?.role;
  switch (role) {
    case UserRole.farmer:
      return RoleInterlocuteur.farmer;
    case UserRole.buyer:
      return RoleInterlocuteur.acheteur;
    case UserRole.cooperative:
      return RoleInterlocuteur.coop;
    case UserRole.transporter:
      return RoleInterlocuteur.transport;
    default:
      return null;
  }
}

/// Format court "10:24" / "hier" / "2j" / "10 mai".
String formatTime(DateTime? when) {
  if (when == null) return '';
  final now = DateTime.now();
  final local = when.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final whenDay = DateTime(local.year, local.month, local.day);
  final diffDays = today.difference(whenDay).inDays;
  if (diffDays == 0) {
    return DateFormat('HH:mm').format(local);
  }
  if (diffDays == 1) return 'hier';
  if (diffDays < 7) return '${diffDays}j';
  return DateFormat('d MMM', 'fr_FR').format(local);
}

/// Retourne 1 ou 2 lettres d'initiales à partir d'un nom.
///
/// "Jean Dupont" → "JD", "Marie" → "MA", "" → "?".
String initiales(String s) {
  final t = s.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}
