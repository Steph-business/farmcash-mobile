import 'package:flutter/material.dart';

import '../../../models/conversation.dart';
import '../../../models/enums.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import 'avatar_conversation.dart';
import 'chip_role.dart';
import 'messages_helpers.dart';
import 'messages_types.dart';

/// Tuile conversation polymorphe — choisit le rendu adapté au rôle viewer.
///
/// Cette tuile route vers l'un des 3 layouts internes :
/// - acheteur : chip rôle À CÔTÉ du nom, badge unread en colonne droite.
/// - coopérative : avatar nu (pas de chip), badge unread inline.
/// - farmer / transporter : chip rôle posé BAS-DROITE de l'avatar.
///
/// La séparation par rôle est faite ici plutôt qu'à l'appelant pour que
/// `MessagesPage` ne connaisse qu'une seule API.
class TuileConversation extends StatelessWidget {
  const TuileConversation({
    required this.conv,
    required this.currentUserId,
    required this.isLast,
    required this.onTap,
    required this.role,
    super.key,
  });

  final Conversation conv;
  final String? currentUserId;
  final bool isLast;
  final VoidCallback onTap;
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final other = otherParticipant(conv, currentUserId);
    final role = otherRole(conv, currentUserId);
    switch (this.role) {
      case UserRole.buyer:
        return _TuileAcheteur(
          conv: conv,
          other: other,
          otherRole: role,
          currentUserId: currentUserId,
          isLast: isLast,
          onTap: onTap,
        );
      case UserRole.cooperative:
        return _TuileCooperative(
          conv: conv,
          other: other,
          currentUserId: currentUserId,
          isLast: isLast,
          onTap: onTap,
        );
      case UserRole.transporter:
        return _TuileAvecChipAvatar(
          conv: conv,
          other: other,
          otherRole: role,
          currentUserId: currentUserId,
          isLast: isLast,
          onTap: onTap,
          chipBuilder: ({Key? key, required RoleInterlocuteur role}) =>
              ChipRoleTransporteur(key: key, role: role),
        );
      case UserRole.farmer:
      default:
        return _TuileAvecChipAvatar(
          conv: conv,
          other: other,
          otherRole: role,
          currentUserId: currentUserId,
          isLast: isLast,
          onTap: onTap,
          chipBuilder: ({Key? key, required RoleInterlocuteur role}) =>
              ChipRoleProducteur(key: key, role: role),
        );
    }
  }
}

/// Corps "titre + heure / dernier message + badge unread" — partagé par
/// les variantes producteur / transporteur / coopérative. Ne gère pas
/// l'avatar ni le chip rôle (calés par le parent).
class _CorpsConversation extends StatelessWidget {
  const _CorpsConversation({required this.conv, required this.currentUserId});

  final Conversation conv;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final name = otherName(conv, currentUserId);
    final lastMsg = conv.lastMessage?.content ?? '';
    final time = formatTime(
      conv.lastMessage?.createdAt ?? conv.updatedAt ?? conv.createdAt,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              time,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                color: AppColors.textSubtle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: Text(
                lastMsg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (conv.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${conv.unreadCount}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Variante producteur/transporteur : chip rôle en overlay BAS-DROITE
/// de l'avatar. Le builder du chip est injecté par le parent pour
/// pouvoir alterner les palettes selon le rôle viewer.
class _TuileAvecChipAvatar extends StatelessWidget {
  const _TuileAvecChipAvatar({
    required this.conv,
    required this.other,
    required this.otherRole,
    required this.currentUserId,
    required this.isLast,
    required this.onTap,
    required this.chipBuilder,
  });

  final Conversation conv;
  final ConversationParticipant? other;
  final RoleInterlocuteur? otherRole;
  final String? currentUserId;
  final bool isLast;
  final VoidCallback onTap;
  final Widget Function({Key? key, required RoleInterlocuteur role})
      chipBuilder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AvatarConversation(
                    participant: other,
                    fallbackName: otherName(conv, currentUserId),
                    isAi: conv.isAiSession,
                  ),
                  // Chip rôle masqué pour les conversations IA (l'IA n'a
                  // pas de rôle métier ; le smart_toy_outlined suffit).
                  if (otherRole != null && !conv.isAiSession)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: chipBuilder(role: otherRole!),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CorpsConversation(
                conv: conv,
                currentUserId: currentUserId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Variante coop : avatar nu sans chip rôle, corps inline standard.
class _TuileCooperative extends StatelessWidget {
  const _TuileCooperative({
    required this.conv,
    required this.other,
    required this.currentUserId,
    required this.isLast,
    required this.onTap,
  });

  final Conversation conv;
  final ConversationParticipant? other;
  final String? currentUserId;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            AvatarConversation(
              participant: other,
              fallbackName: otherName(conv, currentUserId),
              isAi: conv.isAiSession,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CorpsConversation(
                conv: conv,
                currentUserId: currentUserId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Variante acheteur : chip rôle À CÔTÉ du nom (inline), badge unread
/// dans une colonne séparée à droite (sous l'horodatage).
class _TuileAcheteur extends StatelessWidget {
  const _TuileAcheteur({
    required this.conv,
    required this.other,
    required this.otherRole,
    required this.currentUserId,
    required this.isLast,
    required this.onTap,
  });

  final Conversation conv;
  final ConversationParticipant? other;
  final RoleInterlocuteur? otherRole;
  final String? currentUserId;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = otherName(conv, currentUserId);
    final lastMsg = conv.lastMessage?.content ?? '';
    final time = formatTime(
      conv.lastMessage?.createdAt ?? conv.updatedAt ?? conv.createdAt,
    );
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            AvatarConversation(
              participant: other,
              fallbackName: name,
              isAi: conv.isAiSession,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      if (otherRole != null) ...[
                        const SizedBox(width: 6),
                        ChipRoleAcheteur(role: otherRole!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSubtle,
                  ),
                ),
                if (conv.unreadCount > 0) ...[
                  const SizedBox(height: 5),
                  Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${conv.unreadCount}',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
