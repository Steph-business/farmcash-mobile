import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/section_titre.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Section « Mon QR de réception » côté acheteur — encart cliquable
/// posé sur la page détail commande qui pousse vers la page plein écran
/// affichant le QR. À montrer au transporteur lors de la livraison pour
/// confirmer la réception (déclenche `DELIVERY_CONFIRMED` côté backend
/// et libère l'escrow au vendeur).
class SectionQr extends StatelessWidget {
  const SectionQr({
    required this.commandeId,
    super.key,
  });

  /// ID de la commande dont on affiche le QR. Pousse vers la route
  /// `acheteurLivraisonQrPathFor(id)`.
  final String commandeId;

  @override
  Widget build(BuildContext context) {
    return SectionTitre(
      titre: 'Mon QR de réception',
      child: InkWell(
        onTap: () => context.push(
          RouteNames.acheteurLivraisonQrPathFor(commandeId),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.qr_code_2,
                  size: 22,
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
                      'Afficher mon QR',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'À montrer au transporteur',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
