import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Carte affichant le QR code de livraison et un **code court de
/// réception** (6 caractères) lisible par le transporteur d'un coup
/// d'œil — fini la longue ref `#ORD-1779742258490-77b4` illisible.
class CarteQrLivraison extends StatelessWidget {
  const CarteQrLivraison({
    required this.payload,
    required this.commandeRef,
    super.key,
  });

  /// Contenu du QR (URL deep-link `farmcash://commande/...`).
  final String payload;

  /// Code court à afficher sous le QR (ex. `4A1FBB`). Doit être déjà
  /// formaté côté appelant — la carte n'effectue aucune transformation.
  final String commandeRef;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: payload,
              size: 220,
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Code de réception',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSubtle,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Code court bien gros, monospace pour lisibilité maximale.
          Text(
            commandeRef,
            style: AppTextStyles.titleLarge.copyWith(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
