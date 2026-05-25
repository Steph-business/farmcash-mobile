import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../models/conversation.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import 'messages_helpers.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Avatar 48×48 d'une conversation.
///
/// Cas couverts :
/// - [isAi] vrai → icône `smart_toy_outlined` vert sur fond `_kPrimarySoft`.
/// - photo distante → [CachedNetworkImage] avec fallback initiales en erreur.
/// - pas de photo → bloc d'initiales basé sur [fallbackName].
class AvatarConversation extends StatelessWidget {
  const AvatarConversation({
    required this.participant,
    required this.fallbackName,
    this.isAi = false,
    super.key,
  });

  final ConversationParticipant? participant;
  final String fallbackName;

  /// Si vrai → on remplace l'image/initiales par une icône `smart_toy`
  /// verte (visuel "bot"). Permet à la liste des conversations de
  /// distinguer immédiatement les sessions IA des conversations humaines.
  final bool isAi;

  @override
  Widget build(BuildContext context) {
    if (isAi) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _kPrimarySoft,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.smart_toy_outlined,
          size: 24,
          color: AppColors.primary,
        ),
      );
    }
    final url = participant?.photoUrl;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, _, _) => AvatarInitiales(name: fallbackName),
            )
          : AvatarInitiales(name: fallbackName),
    );
  }
}

/// Bloc d'initiales centrées — utilisé en fallback par
/// [AvatarConversation] quand il n'y a pas de photo.
class AvatarInitiales extends StatelessWidget {
  const AvatarInitiales({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initiales(name),
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
