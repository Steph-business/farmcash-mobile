import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/reservation_acheteur_info.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/chargement.dart';

/// Section « Acheteurs qui ont réservé » sur la page détail d'une
/// prévision producteur. Affiche jusqu'à N lignes acheteur → quantité,
/// statut, fraîcheur. Gère loading / erreur / vide proprement.
///
/// La donnée est fetchée par la page parent (un FutureProvider family)
/// et passée ici via [async] — la section ne sait rien du fetch lui-même
/// (pure présentation).
class SectionReservationsPrevision extends StatelessWidget {
  const SectionReservationsPrevision({
    super.key,
    required this.async,
    required this.onRetry,
  });

  final AsyncValue<List<ReservationAcheteurInfo>> async;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.pagePaddingH,
        vertical: 6,
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Entete(count: async.valueOrNull?.length),
          const SizedBox(height: 8),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Chargement(size: 18),
            ),
            error: (_, _) => _LigneErreur(onRetry: onRetry),
            data: (items) => items.isEmpty
                ? const _LigneVide()
                : Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            thickness: 0.6,
                            color: AppColors.border,
                          ),
                        _LigneAcheteur(reservation: items[i]),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Sous-widgets internes ───────────────────────────────────────

class _Entete extends StatelessWidget {
  const _Entete({this.count});
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.people_alt_outlined,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Acheteurs qui ont réservé',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ),
        if (count != null && count! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _LigneAcheteur extends StatelessWidget {
  const _LigneAcheteur({required this.reservation});
  final ReservationAcheteurInfo reservation;

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    final nom = (r.acheteurNom?.trim().isNotEmpty ?? false)
        ? r.acheteurNom!.trim()
        : 'Acheteur';
    final qte = NumberFormat('#,##0', 'fr_FR').format(r.quantiteKg.round());
    final relatif = _formatRelatif(r.createdAt) ?? '—';
    final (badgeBg, badgeColor, badgeText) = _badgeStatus(r.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _AvatarAcheteur(nom: nom, photoUrl: r.acheteurPhotoUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$qte kg · $relatif',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar acheteur : photo réseau si dispo, sinon monogramme (1ère lettre).
class _AvatarAcheteur extends StatelessWidget {
  const _AvatarAcheteur({required this.nom, this.photoUrl});
  final String nom;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final initiale = nom.trim().isEmpty
        ? '?'
        : nom.trim().characters.first.toUpperCase();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: (photoUrl != null && photoUrl!.startsWith('http'))
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              width: 36,
              height: 36,
              errorBuilder: (_, _, _) => _initialeFallback(initiale),
            )
          : _initialeFallback(initiale),
    );
  }

  Widget _initialeFallback(String initiale) => Text(
        initiale,
        style: AppTextStyles.titleSmall.copyWith(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      );
}

class _LigneVide extends StatelessWidget {
  const _LigneVide();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const Icon(
            Icons.hourglass_empty_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Aucune réservation pour le moment.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LigneErreur extends StatelessWidget {
  const _LigneErreur({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Impossible de charger les réservations.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers privés ──────────────────────────────────────────────

(Color, Color, String) _badgeStatus(String status) {
  switch (status.toUpperCase()) {
    case 'CONFIRMED':
      return (
        AppColors.primary.withValues(alpha: 0.12),
        AppColors.primary,
        'Confirmée',
      );
    case 'CANCELLED':
      return (
        AppColors.error.withValues(alpha: 0.12),
        AppColors.error,
        'Annulée',
      );
    case 'PENDING':
    default:
      // Ambre : en attente, à surveiller.
      return (
        const Color(0xFFB45309).withValues(alpha: 0.12),
        const Color(0xFFB45309),
        'En attente',
      );
  }
}

String? _formatRelatif(DateTime? d) {
  if (d == null) return null;
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'à l’instant';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
  final semaines = (diff.inDays / 7).floor();
  if (semaines < 5) return 'il y a $semaines sem';
  return 'il y a ${(diff.inDays / 30).floor()} mois';
}
