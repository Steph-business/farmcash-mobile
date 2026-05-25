import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard = BorderRadius.all(Radius.circular(12));

/// Carte de statut affichée tout en haut du détail mission. Présente une
/// icône camion + un libellé/sous-libellé contextualisé par
/// [ShipmentStatus] (demande, acceptée, en route, livrée, etc.).
class CarteStatutMission extends StatelessWidget {
  const CarteStatutMission({required this.status, super.key});
  final ShipmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, sub) = _spec();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: _kBrCard,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _spec() {
    switch (status) {
      case ShipmentStatus.requested:
        return ('Demande en attente', 'Accepte-la pour démarrer la mission');
      case ShipmentStatus.accepted:
        return ('Acceptée', 'Va sur place pour scanner le QR producteur');
      case ShipmentStatus.loading:
        return ('Enlèvement en cours', 'Chargement chez le vendeur');
      case ShipmentStatus.inTransit:
        return ('En route', 'Bonne route vers le destinataire');
      case ShipmentStatus.delivered:
        return ('Livrée', 'En attente de confirmation acheteur');
      case ShipmentStatus.cancelled:
        return ('Annulée', '—');
      case ShipmentStatus.unknown:
        return ('Mission', '—');
    }
  }
}
