import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/message.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kIncomingBubble = Color(0xFFF3F4F6);

/// Bulle de message dans une conversation chat.
///
/// Deux variantes :
///   • `BulleMessage(...)` — bulle confirmée (côté serveur) à partir d'un
///     [Message]. Le rendu varie selon `isMine` (couleur primary à droite
///     vs gris clair à gauche, coin inférieur biseauté côté émetteur).
///   • `BulleMessage.pending(...)` — bulle optimiste (affichée juste après
///     l'envoi, avant la confirmation serveur). Toujours à droite, opacité
///     réduite ; quand `failed == true`, ajoute une icône warning rouge
///     cliquable pour relancer l'envoi.
///
/// Une fois confirmée, le pending est retiré et la bulle réelle apparaît.
class BulleMessage extends StatelessWidget {
  const BulleMessage({
    required Message this.message,
    required this.isMine,
    super.key,
  })  : pendingContent = null,
        pendingFailed = false,
        onRetry = null;

  /// Bulle pour un message optimiste — affichée immédiatement après le
  /// clic "envoyer", avant la confirmation serveur. Trois états :
  ///   • pending (encore en cours d'envoi) : opacité 60% + horloge
  ///   • failed (serveur a rejeté) : icône warning rouge + tap pour retry
  const BulleMessage.pending({
    required String this.pendingContent,
    required this.pendingFailed,
    required this.onRetry,
    super.key,
  })  : message = null,
        isMine = true;

  final Message? message;
  final bool isMine;
  // Variant pending — utilisés uniquement si `message == null`.
  final String? pendingContent;
  final bool pendingFailed;
  final VoidCallback? onRetry;

  bool get _isPending => message == null;

  @override
  Widget build(BuildContext context) {
    if (_isPending) return _buildPending(context);
    return _buildConfirmed(context);
  }

  Widget _buildConfirmed(BuildContext context) {
    final msg = message!;
    final content = (msg.content ?? '').trim();
    final time = msg.createdAt != null
        ? DateFormat('HH:mm').format(msg.createdAt!.toLocal())
        : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primary : _kIncomingBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMine ? 12 : 2),
                  bottomRight: Radius.circular(isMine ? 2 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    content.isEmpty ? '(message vide)' : content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      color: isMine ? AppColors.onPrimary : AppColors.text,
                      height: 1.35,
                    ),
                  ),
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        color: isMine
                            ? AppColors.onPrimary.withValues(alpha: 0.85)
                            : AppColors.textSubtle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPending(BuildContext context) {
    final isFailed = pendingFailed;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isFailed)
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.error_outline,
                  size: 18,
                  color: AppColors.error,
                ),
              ),
            ),
          Flexible(
            child: Opacity(
              opacity: isFailed ? 0.55 : 0.7,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pendingContent ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        color: AppColors.onPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isFailed ? 'Échec' : 'Envoi…',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 10,
                            color: AppColors.onPrimary
                                .withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isFailed ? Icons.error_outline : Icons.schedule,
                          size: 11,
                          color:
                              AppColors.onPrimary.withValues(alpha: 0.85),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
