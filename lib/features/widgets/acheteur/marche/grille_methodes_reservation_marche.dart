import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Methodes de paiement supportees pour la reservation marche.
enum MethodePaiementReservation { wallet, om, mtn, carte }

/// Specification visuelle d'une methode de paiement.
class SpecMethodeReservation {
  const SpecMethodeReservation({
    required this.method,
    required this.short,
    required this.name,
    required this.color,
    this.dark = false,
  });

  final MethodePaiementReservation method;
  final String short;
  final String name;
  final Color color;
  final bool dark;
}

/// Liste des methodes disponibles dans la grille.
const List<SpecMethodeReservation> kMethodesReservation = [
  SpecMethodeReservation(
    method: MethodePaiementReservation.wallet,
    short: 'FC',
    name: 'Solde wallet',
    color: AppColors.primary,
  ),
  SpecMethodeReservation(
    method: MethodePaiementReservation.om,
    short: 'OM',
    name: 'Orange Money',
    color: Color(0xFFFF6B00),
  ),
  SpecMethodeReservation(
    method: MethodePaiementReservation.mtn,
    short: 'MTN',
    name: 'MTN MoMo',
    color: Color(0xFFFFCC00),
    dark: true,
  ),
  SpecMethodeReservation(
    method: MethodePaiementReservation.carte,
    short: 'CB',
    name: 'Carte bancaire',
    color: Color(0xFF1E40AF),
  ),
];

/// Grille 2x2 de selection de la methode de paiement.
class GrilleMethodesReservationMarche extends StatelessWidget {
  const GrilleMethodesReservationMarche({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final MethodePaiementReservation selected;
  final ValueChanged<MethodePaiementReservation> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 96,
      ),
      itemCount: kMethodesReservation.length,
      itemBuilder: (context, i) {
        final spec = kMethodesReservation[i];
        final active = spec.method == selected;
        return InkWell(
          onTap: () => onSelect(spec.method),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active ? _kPrimarySoft : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: spec.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        spec.short,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: spec.dark ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        spec.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }
}
