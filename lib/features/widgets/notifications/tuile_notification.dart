import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/notification.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

// ─── Couleurs accent (conformes aux mockups) ────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFEF3C7);
const Color _kWarn = Color(0xFFB45309);
const Color _kInfoSoft = Color(0xFFDBEAFE);
const Color _kInfo = Color(0xFF1D4ED8);

/// Type sémantique pour piloter la couleur de la bulle d'icône.
enum _NotifKind { primary, warn, info }

/// Mappe le `type` backend (cf. `NotificationType` côté NestJS) sur
/// l'emoji affiché dans la bulle et la couleur sémantique. `data` n'est
/// pas consulté ici — c'est un fallback visuel cohérent par catégorie.
({String emoji, _NotifKind kind}) _visualForType(String type) {
  switch (type) {
    case 'ORDER':
    case 'ORDER_FROM_NEGOTIATION':
      return (emoji: '🛒', kind: _NotifKind.primary);
    case 'PAYMENT':
    case 'WALLET_CREDITED':
    case 'WALLET_TOPUP_SUCCESS':
      return (emoji: '💰', kind: _NotifKind.primary);
    case 'SHIPMENT':
    case 'SHIPMENT_ACCEPTED':
      return (emoji: '🚚', kind: _NotifKind.primary);
    case 'PICKUP_CONFIRMED':
      return (emoji: '📦', kind: _NotifKind.primary);
    case 'NEGOTIATION':
      return (emoji: '🤝', kind: _NotifKind.primary);
    case 'MESSAGE':
      return (emoji: '💬', kind: _NotifKind.info);
    case 'MARKETPLACE':
      return (emoji: '🛍️', kind: _NotifKind.primary);
    case 'COOP_JOIN_ACCEPTED':
      return (emoji: '✅', kind: _NotifKind.primary);
    case 'COOP_JOIN_REJECTED':
      return (emoji: '⛔', kind: _NotifKind.warn);
    case 'COOP_SOLLICITATION_RESPONSE':
    case 'COOP_SOLLICITATION_FULFILLED':
      return (emoji: '🌾', kind: _NotifKind.primary);
    case 'SYSTEM':
      return (emoji: '🔔', kind: _NotifKind.info);
    default:
      return (emoji: '🔔', kind: _NotifKind.info);
  }
}

/// Formate `createdAt` en libellé court ("il y a 8 min", "hier",
/// "10 mai") — calque l'esthétique des anciens mocks.
String _formatTemps(DateTime? when) {
  if (when == null) return '';
  final now = DateTime.now();
  final diff = now.difference(when);
  if (diff.inMinutes < 1) return "à l'instant";
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
  if (diff.inDays == 1) return 'hier';
  if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
  return DateFormat('d MMM', 'fr_FR').format(when);
}

/// Tuile individuelle d'une notification dans la liste.
///
/// Rend :
/// - une pastille primaire à gauche si non lue,
/// - une bulle d'icône (carrée bordée pour l'acheteur, ronde colorée
///   pour les autres) avec un emoji déterminé par [AppNotification.type],
/// - le titre, le corps et un libellé temporel court.
///
/// Le fond peut être plein (`primary-soft`) pour les rôles acheteur /
/// coopérative / transporteur lorsque [highlightFullBg] est vrai et que
/// la notification n'est pas lue ; pour le producteur seul le
/// pastille + bulle s'éclairent.
///
/// La séparation visuelle inférieure disparaît pour la dernière tuile
/// ([isLast] == true).
class TuileNotification extends StatelessWidget {
  const TuileNotification({
    required this.notif,
    required this.isLast,
    required this.onTap,
    required this.highlightFullBg,
    required this.layoutForAcheteur,
    super.key,
  });

  final AppNotification notif;
  final bool isLast;
  final VoidCallback onTap;
  final bool highlightFullBg;
  final bool layoutForAcheteur;

  Color _bubbleBg(_NotifKind kind) {
    switch (kind) {
      case _NotifKind.primary:
        return _kPrimarySoft;
      case _NotifKind.warn:
        return _kWarnSoft;
      case _NotifKind.info:
        return _kInfoSoft;
    }
  }

  Color _bubbleFg(_NotifKind kind) {
    switch (kind) {
      case _NotifKind.primary:
        return AppColors.primary;
      case _NotifKind.warn:
        return _kWarn;
      case _NotifKind.info:
        return _kInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visual = _visualForType(notif.type);
    final unread = !notif.isRead;

    // Bulle blanche pour notifs primary unread sur fond plein (lisibilité).
    final bubbleBg = highlightFullBg &&
            unread &&
            visual.kind == _NotifKind.primary
        ? AppColors.background
        : _bubbleBg(visual.kind);

    final usePadHorizontal = layoutForAcheteur ? 20.0 : 6.0;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: highlightFullBg && unread
            ? _kPrimarySoft
            : AppColors.background,
        padding: EdgeInsets.symmetric(
          vertical: 14,
          horizontal: highlightFullBg ? usePadHorizontal : 0,
        ),
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 10,
              child: unread
                  ? Container(
                      margin: EdgeInsets.only(
                        top: layoutForAcheteur ? 8 : 10,
                      ),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: layoutForAcheteur ? 4 : 2),
            // Acheteur a une bulle carrée bordée ; les autres ronde colorée.
            if (layoutForAcheteur)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  visual.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bubbleBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  visual.emoji,
                  style: TextStyle(fontSize: 18, color: _bubbleFg(visual.kind)),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notif.titre.isEmpty ? 'Notification' : notif.titre,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: layoutForAcheteur ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  if ((notif.body ?? '').isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      notif.body!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: layoutForAcheteur ? 1.4 : 1.35,
                      ),
                    ),
                  ],
                  SizedBox(height: layoutForAcheteur ? 5 : 4),
                  Text(
                    _formatTemps(notif.createdAt),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
