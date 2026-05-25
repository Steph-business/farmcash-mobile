import 'package:flutter/material.dart';

import '../../../../models/models.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'adresses_livraison_constants.dart';

/// Carte affichant une adresse de livraison enregistrée — icône + libellé +
/// chip "Par défaut" + lignes adresse/contact + boutons d'action en bas.
class CarteAdresseLivraison extends StatelessWidget {
  const CarteAdresseLivraison({
    required this.adresse,
    required this.busy,
    required this.onDefinirParDefaut,
    required this.onSupprimer,
    super.key,
  });

  final BuyerAddress adresse;
  final bool busy;
  final VoidCallback onDefinirParDefaut;
  final VoidCallback onSupprimer;

  @override
  Widget build(BuildContext context) {
    final adresseComplete = adresse.adresseComplete.trim();
    final ville = adresse.villeNom?.trim();
    final adresseDisplay = [
      if (adresseComplete.isNotEmpty) adresseComplete,
      if (ville != null && ville.isNotEmpty) ville,
    ].join(' · ');
    final contactNom = adresse.contactNom.trim();
    final contactPhone = adresse.contactPhone.trim();
    final contactDisplay = [
      if (contactNom.isNotEmpty) contactNom,
      if (contactPhone.isNotEmpty) contactPhone,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: adresse.isDefault ? AppColors.primary : AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kAdressesLivraisonPrimarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            adresse.libelle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        if (adresse.isDefault) ...[
                          const SizedBox(width: 8),
                          const _ChipDefautAdresse(),
                        ],
                      ],
                    ),
                    if (adresseDisplay.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        adresseDisplay,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (contactDisplay.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        contactDisplay,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (!adresse.isDefault)
                _LinkActionAdresse(
                  label: busy ? '…' : 'Définir par défaut',
                  onTap: busy ? null : onDefinirParDefaut,
                  color: AppColors.primary,
                ),
              if (!adresse.isDefault) const SizedBox(width: 16),
              _LinkActionAdresse(
                label: busy ? '…' : 'Supprimer',
                onTap: busy ? null : onSupprimer,
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chip "Par défaut" affichée à côté du libellé d'une adresse marquée.
class _ChipDefautAdresse extends StatelessWidget {
  const _ChipDefautAdresse();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kAdressesLivraisonPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Par défaut',
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Lien d'action discret en bas d'une carte adresse — gris quand `onTap`
/// est null (état désactivé pendant une opération en cours).
class _LinkActionAdresse extends StatelessWidget {
  const _LinkActionAdresse({
    required this.label,
    required this.onTap,
    required this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onTap == null ? AppColors.textSubtle : color,
          ),
        ),
      ),
    );
  }
}
