import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte mission côté transporteur — design simplifié, aligné sur les
/// cartes acheteur/producteur. Hiérarchie : l'itinéraire (QUOI faire),
/// la quantité (combien transporter), puis montant + statut.
///
/// ```
/// ┌──────────────────────────────────────────────┐
/// │ [🚚]  Abidjan → Bouaké            Détails ›  │
/// │       850 kg · 14 mai 09:00                  │
/// ├──────────────────────────────────────────────┤
/// │ 15 000 FCFA                  ● En transit    │
/// ├ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
/// │ → À récupérer chez le producteur             │
/// └──────────────────────────────────────────────┘
/// ```
///
/// Le prix affiché est le **devis transporteur** (ce qu'il va toucher
/// pour ce trajet, brut). Couleurs de statut alignées sur les autres
/// rôles : BLEU = à accepter / accepté, ORANGE = en route, VERT = livré.
class CarteMissionListe extends StatelessWidget {
  const CarteMissionListe({
    super.key,
    required this.mission,
    required this.onTap,
  });

  final Livraison mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itineraire = mission.itineraireLabel ??
        '${mission.pickupAddress ?? '—'} → ${mission.deliveryAddress ?? '—'}';
    final qte = mission.quantiteKg != null
        ? '${_nf.format(mission.quantiteKg!.round())} kg'
        : '—';
    final prix = mission.prixDevis ?? mission.prixFinal;
    final prixLabel = prix != null ? _nf.format(prix.round()) : 'À fixer';
    final schedule = _scheduleLabel(mission);
    final sousLigne = schedule == '—' ? qte : '$qte · $schedule';
    final action = _actionRequise(mission.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header : icône camion + itinéraire (titre) + qté/heure
                // (sous-ligne) + lien Détails.
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ligne 1 : QUOI faire (itinéraire)
                            Text(
                              itineraire,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Ligne 2 : COMBIEN / QUAND
                            Text(
                              sousLigne,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _LienDetails(),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: AppDimens.borderThin,
                  color: AppColors.border,
                ),
                // Ligne unique : montant devis + chip statut.
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: prixLabel,
                                style: AppTextStyles.headlineSmall.copyWith(
                                  fontFamily: 'Poppins',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                  letterSpacing: -0.3,
                                  height: 1.0,
                                ),
                              ),
                              TextSpan(
                                text: ' FCFA',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ChipStatut(status: mission.status),
                    ],
                  ),
                ),
                if (action != null) _BandeauAction(message: action),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Action contextuelle attendue côté transporteur.
  String? _actionRequise(ShipmentStatus s) {
    switch (s) {
      case ShipmentStatus.requested:
        return 'À accepter ou refuser';
      case ShipmentStatus.accepted:
        return 'À récupérer chez le producteur';
      case ShipmentStatus.loading:
        return 'Chargement en cours';
      case ShipmentStatus.inTransit:
        return 'En transit — confirmer la livraison';
      default:
        return null;
    }
  }

  String _scheduleLabel(Livraison m) {
    final df = DateFormat('d MMM HH:mm', 'fr_FR');
    if (m.scheduledAt != null) return df.format(m.scheduledAt!);
    if (m.createdAt != null) return df.format(m.createdAt!);
    return '—';
  }
}

class _LienDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Détails',
          style: AppTextStyles.button.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 2),
        const Icon(
          Icons.chevron_right,
          size: 18,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

/// Chip statut compact partagé visuellement avec les cartes acheteur et
/// producteur. Couleurs progressives :
/// - 🔵 Bleu : à accepter / acceptée (en attente d'action transporteur)
/// - 🟠 Orange : chargement / en transit (transporteur en mouvement)
/// - 🟢 Vert : livrée (mission terminée)
/// - ⚪ Gris : annulée / inconnu
class _ChipStatut extends StatelessWidget {
  const _ChipStatut({required this.status});
  final ShipmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, fond) = _spec(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, Color) _spec(ShipmentStatus s) {
    const bleu = Color(0xFF1E40AF);
    const fondBleu = Color(0xFFDBEAFE);
    const orange = Color(0xFFB45309);
    const fondOrange = Color(0xFFFFF3CD);
    const fondVert = Color(0xFFE8F5E9);
    const fondGris = AppColors.surfaceSoft;
    switch (s) {
      case ShipmentStatus.requested:
        return ('À accepter', bleu, fondBleu);
      case ShipmentStatus.accepted:
        return ('Acceptée', bleu, fondBleu);
      case ShipmentStatus.loading:
        return ('Chargement', orange, fondOrange);
      case ShipmentStatus.inTransit:
        return ('En transit', orange, fondOrange);
      case ShipmentStatus.delivered:
        return ('Livrée', AppColors.primary, fondVert);
      case ShipmentStatus.cancelled:
        return ('Annulée', AppColors.textSecondary, fondGris);
      case ShipmentStatus.unknown:
        return ('—', AppColors.textSubtle, fondGris);
    }
  }
}

class _BandeauAction extends StatelessWidget {
  const _BandeauAction({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8E1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_circle_right_outlined,
            size: 16,
            color: Color(0xFFB45309),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
