import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Un choix de moyen de paiement présenté dans la grille (badge couleur
/// + nom court). Le wallet a un sous-titre dynamique (solde dispo).
class ChoixPaiement {
  const ChoixPaiement({
    required this.provider,
    required this.court,
    required this.nom,
    required this.couleur,
    this.fonce = false,
  });
  final MobileProvider provider;
  final String court;
  final String nom;
  final Color couleur;
  final bool fonce;
}

/// Liste figée des moyens disponibles. Le wallet est en premier car
/// recommandé (paiement instantané sans frais externes).
const List<ChoixPaiement> kChoixPaiement = [
  ChoixPaiement(
    provider: MobileProvider.wallet,
    court: 'FC',
    nom: 'Solde wallet',
    couleur: AppColors.primary,
  ),
  ChoixPaiement(
    provider: MobileProvider.orangeMoney,
    court: 'OM',
    nom: 'Orange Money',
    couleur: Color(0xFFFF6B00),
  ),
  ChoixPaiement(
    provider: MobileProvider.mtnMomo,
    court: 'MTN',
    nom: 'MTN MoMo',
    couleur: Color(0xFFFFCC00),
    fonce: true,
  ),
  ChoixPaiement(
    provider: MobileProvider.wave,
    court: 'WV',
    nom: 'Wave',
    couleur: AppColors.primary,
  ),
];

/// Grille 2 colonnes des moyens de paiement. Le wallet affiche le solde
/// dispo en sous-texte vert.
class GrilleMethodesPaiement extends StatelessWidget {
  const GrilleMethodesPaiement({
    required this.selection,
    required this.soldeWallet,
    required this.onSelect,
    super.key,
  });

  final MobileProvider selection;
  final double soldeWallet;
  final ValueChanged<MobileProvider> onSelect;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 100,
      ),
      itemCount: kChoixPaiement.length,
      itemBuilder: (context, i) {
        final spec = kChoixPaiement[i];
        final active = spec.provider == selection;
        final String? sousTitre = spec.provider == MobileProvider.wallet
            ? '${nf.format(soldeWallet.round())} F dispo'
            : null;
        return InkWell(
          onTap: () => onSelect(spec.provider),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: active ? _kPrimarySoft : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: active ? 1.5 : AppDimens.borderThin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: spec.couleur,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    spec.court,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: spec.fonce ? Colors.black : Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  spec.nom,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (sousTitre != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: spec.provider == MobileProvider.wallet
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: spec.provider == MobileProvider.wallet
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
