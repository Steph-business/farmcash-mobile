import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Modes de paiement disponibles pour l'acheteur à la commande.
enum ModePaiementAcheteur {
  /// Paye 100 % en escrow à la création. L'argent est libéré au vendeur
  /// uniquement après confirmation de réception (la coop attend ~J+15).
  full,

  /// Paye un dépôt à la commande (20 % par défaut) + le solde à la
  /// livraison. La coop reçoit immédiatement 80 % du dépôt pour payer
  /// ses producteurs. Idéal pour les petites coops villageoises sans
  /// fonds propres.
  staged,

  /// Paye 5 % en escrow (engagement) + 95 % en espèces au transporteur
  /// à la livraison. Adresse les acheteurs non bancarisés qui veulent
  /// payer cash. Le transporteur valide la réception via scan QR.
  cashOnDelivery,
}

extension ModePaiementAcheteurX on ModePaiementAcheteur {
  String get apiValue {
    switch (this) {
      case ModePaiementAcheteur.full:
        return 'FULL';
      case ModePaiementAcheteur.staged:
        return 'STAGED';
      case ModePaiementAcheteur.cashOnDelivery:
        return 'CASH_ON_DELIVERY';
    }
  }
}

/// Pourcentage du dépôt pour le mode cash à la livraison.
const double cashDepotPct = 0.05;

/// Calcule le pourcentage de dépôt adaptatif selon le montant total —
/// miroir client de la grille backend (staged-payment.util.ts).
double calculerPctDepot(double montantTotal) {
  if (montantTotal < 500000) return 0.30;
  if (montantTotal < 5000000) return 0.20;
  return 0.10;
}

double calculerMontantDepot(double montantTotal) {
  return (montantTotal * calculerPctDepot(montantTotal)).roundToDouble();
}

/// Carte premium qui propose à l'acheteur le mode de paiement à la
/// commande. 2 options visuelles avec breakdown chiffré :
///
///   • Paiement intégral (100 % en escrow, libéré à la confirmation)
///   • Acompte + solde (X % maintenant, le reste à la livraison)
///
/// Le mode acompte aide les petites coopératives villageoises à payer
/// leurs producteurs dès la commande, sans attendre la livraison
/// (cf. note stratégique V2 — section 2.2).
class CarteChoixModePaiement extends StatelessWidget {
  const CarteChoixModePaiement({
    super.key,
    required this.montantTotal,
    required this.mode,
    required this.onChange,
  });

  final double montantTotal;
  final ModePaiementAcheteur mode;
  final ValueChanged<ModePaiementAcheteur> onChange;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final pct = calculerPctDepot(montantTotal);
    final depot = calculerMontantDepot(montantTotal);
    final solde = (montantTotal - depot).roundToDouble();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comment souhaites-tu payer ?',
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          // Option 1 : intégral
          _OptionPaiement(
            selectionne: mode == ModePaiementAcheteur.full,
            titre: 'Payer maintenant',
            sousTitre:
                'Verse ${nf.format(montantTotal.round())} F en escrow. '
                'Libéré au vendeur à la livraison.',
            chip: '100 %',
            onTap: () => onChange(ModePaiementAcheteur.full),
          ),
          const SizedBox(height: 8),
          // Option 2 : étagé
          _OptionPaiement(
            selectionne: mode == ModePaiementAcheteur.staged,
            titre: 'Acompte + solde à la livraison',
            sousTitre:
                'Verse ${nf.format(depot.round())} F maintenant '
                '(${(pct * 100).round()} %), puis '
                '${nf.format(solde.round())} F à la réception du lot.',
            chip: '${(pct * 100).round()} %',
            badgeRecommande: mode == ModePaiementAcheteur.staged ||
                montantTotal < 5000000,
            onTap: () => onChange(ModePaiementAcheteur.staged),
          ),
          const SizedBox(height: 8),
          // Option 3 : cash à la livraison
          _OptionPaiement(
            selectionne: mode == ModePaiementAcheteur.cashOnDelivery,
            titre: 'Cash à la livraison',
            sousTitre:
                'Verse ${nf.format((montantTotal * cashDepotPct).round())} F '
                "(5 %) maintenant, puis "
                '${nf.format((montantTotal * (1 - cashDepotPct)).round())} F '
                'en espèces au transporteur à la livraison.',
            chip: '5 %',
            onTap: () => onChange(ModePaiementAcheteur.cashOnDelivery),
          ),
          if (mode == ModePaiementAcheteur.staged) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ton acompte sert à payer les producteurs '
                      'immédiatement. Le solde reste protégé en escrow '
                      'jusqu\'à la livraison.',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (mode == ModePaiementAcheteur.cashOnDelivery) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.payments_rounded,
                    size: 16,
                    color: Color(0xFF92400E),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Prépare le cash en espèces. Le transporteur '
                      'le récupère contre marchandise et confirme la '
                      'transaction par scan QR.',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: const Color(0xFF92400E),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionPaiement extends StatelessWidget {
  const _OptionPaiement({
    required this.selectionne,
    required this.titre,
    required this.sousTitre,
    required this.chip,
    required this.onTap,
    this.badgeRecommande = false,
  });

  final bool selectionne;
  final String titre;
  final String sousTitre;
  final String chip;
  final bool badgeRecommande;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selectionne
          ? AppColors.primary.withValues(alpha: 0.06)
          : Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: selectionne ? AppColors.primary : AppColors.border,
              width: selectionne ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Row(
            children: [
              Icon(
                selectionne
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selectionne ? AppColors.primary : AppColors.textSubtle,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            titre,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sousTitre,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selectionne
                      ? AppColors.primary
                      : AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  chip,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: selectionne
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
