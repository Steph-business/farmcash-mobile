import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'publication_coop_constants.dart';

/// Carte de statut d'une publication coop : icone circulaire coloree +
/// libelle gras + sous-titre explicatif. Trois etats supportes : en
/// cours (jaune), publie (vert), vendu (vert).
class StatusCardPublicationCoop extends StatelessWidget {
  const StatusCardPublicationCoop({required this.status, super.key});

  final PubStatusPublicationCoop status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label, icon) = switch (status) {
      PubStatusPublicationCoop.enCours => (
          kWarnSoftPublicationCoop,
          kWarnPublicationCoop,
          'En cours',
          Icons.schedule_outlined,
        ),
      PubStatusPublicationCoop.publie => (
          kPrimarySoftPublicationCoop,
          AppColors.primary,
          'Publié',
          Icons.campaign_outlined,
        ),
      PubStatusPublicationCoop.vendu => (
          kPrimarySoftPublicationCoop,
          AppColors.primary,
          'Vendu',
          Icons.check_circle_outline,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: kBrCardPublicationCoop,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: fg),
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
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _sousTitreFor(status),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _sousTitreFor(PubStatusPublicationCoop s) {
    switch (s) {
      case PubStatusPublicationCoop.enCours:
        return 'Les contributions des membres se rassemblent';
      case PubStatusPublicationCoop.publie:
        return 'L\'annonce est visible sur le marché';
      case PubStatusPublicationCoop.vendu:
        return 'Lot vendu, payout en préparation';
    }
  }
}
