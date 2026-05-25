import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/livraison.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Carte mission côté transporteur — alignée sur le design « marketplace
/// card » des autres rôles (acheteur, producteur). Hiérarchie d'info :
///
/// ```
/// ┌──────────────────────────────────────────────┐
/// │ [SK]  Stephy K.                  Détails ›   │  ← émetteur de la commande
/// │       Abidjan → Bouaké                       │
/// ├──────────────────────────────────────────────┤
/// │ FCFA 15.000                   Wallet FC │    │  ← prix total mission
/// │ Quantité            ·       850 kg           │
/// │ Statut transaction  ·       Acceptée         │
/// └──────────────────────────────────────────────┘
/// ```
///
/// Le prix est le **devis transporteur** (ce que le transporteur va
/// toucher pour ce trajet). Le statut suit le `ShipmentStatus`.
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
    final ref = mission.reference ??
        mission.commandeId.substring(0, 6).toUpperCase();
    final itineraire = mission.itineraireLabel ??
        '${mission.pickupAddress ?? '—'} → ${mission.deliveryAddress ?? '—'}';
    final qte = mission.quantiteKg != null
        ? '${_nf.format(mission.quantiteKg!.round())} kg'
        : '—';
    final prix = mission.prixDevis ?? mission.prixFinal;
    final prixLabel = prix != null ? _nf.format(prix.round()) : 'À fixer';

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar avec icône camion (le transporteur n'a pas
                      // forcément le nom de l'acheteur dans le payload
                      // mission — on utilise une icône thématique).
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
                            Text(
                              'Mission #$ref',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              itineraire,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'FCFA ',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  TextSpan(
                                    text: prixLabel,
                                    style: AppTextStyles.headlineSmall
                                        .copyWith(
                                      fontFamily: 'Poppins',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.text,
                                      letterSpacing: -0.5,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const _ChipPaiement(label: 'Wallet FarmCash'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _Ligne(label: 'Quantité', valeur: qte),
                      const SizedBox(height: 6),
                      _Ligne(
                        label: 'Programmation',
                        valeur: _scheduleLabel(mission),
                      ),
                      const SizedBox(height: 6),
                      _StatutLigne(status: mission.status),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

class _ChipPaiement extends StatelessWidget {
  const _ChipPaiement({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({required this.label, required this.valeur});

  final String label;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          valeur,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

class _StatutLigne extends StatelessWidget {
  const _StatutLigne({required this.status});
  final ShipmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _spec(status);
    return Row(
      children: [
        Expanded(
          child: Text(
            'Statut transaction',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  (String, Color) _spec(ShipmentStatus s) {
    switch (s) {
      case ShipmentStatus.requested:
        return ('À accepter', const Color(0xFFB45309));
      case ShipmentStatus.accepted:
        return ('Acceptée', AppColors.primary);
      case ShipmentStatus.loading:
        return ('Chargement', AppColors.primary);
      case ShipmentStatus.inTransit:
        return ('En transit', AppColors.primary);
      case ShipmentStatus.delivered:
        return ('Livrée', AppColors.primary);
      case ShipmentStatus.cancelled:
        return ('Annulée', AppColors.textSecondary);
      case ShipmentStatus.unknown:
        return ('—', AppColors.textSubtle);
    }
  }
}
