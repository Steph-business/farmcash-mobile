import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Bandeau de confiance affiché en haut de la page paiement pour
/// rassurer l'acheteur sur la **protection escrow**. Sans ce bandeau,
/// un acheteur industriel hésite à payer 100% upfront pour 5 tonnes
/// (4-5M F) à un vendeur qu'il ne connaît pas.
///
/// Le message structure 3 promesses claires :
///   1. **Argent gardé en escrow** (pas transféré tant que livraison
///      n'est pas confirmée)
///   2. **Libération à la confirmation** (le contrôle reste à
///      l'acheteur)
///   3. **Refund automatique** si non-livraison
///
/// Variante COMPACTE pour les petits montants (< 100 000 F où le risque
/// perçu est faible) : 1 ligne avec icône bouclier seulement.
///
/// Variante PREMIUM pour gros volumes (>= 500 000 F) : carte complète
/// avec 3 puces et CTA optionnel « En savoir plus » (lien vers FAQ).
class BandeauConfianceEscrow extends StatelessWidget {
  const BandeauConfianceEscrow({
    super.key,
    required this.montantTotal,
  });

  final num montantTotal;

  /// Seuil au-dessus duquel on bascule sur la variante complète. En
  /// dessous, juste une ligne icône + texte court pour ne pas alourdir.
  static const double seuilPremium = 500000;

  bool get _isPremium => montantTotal >= seuilPremium;

  @override
  Widget build(BuildContext context) {
    return _isPremium ? _buildPremium() : _buildCompact();
  }

  // ─── Variante compacte (< 500 000 F) ──────────────────────────────

  Widget _buildCompact() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ton argent est gardé en escrow jusqu\'à la livraison.',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Variante premium (>= 500 000 F — gros volumes) ──────────────

  Widget _buildPremium() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.30),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.shield_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Paiement 100% sécurisé',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Protégé par FarmCash Escrow',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _PuceConfiance(
            icone: Icons.lock_outline_rounded,
            texte:
                'Ton argent reste bloqué par FarmCash jusqu\'à ce que tu confirmes la réception.',
          ),
          const SizedBox(height: 8),
          const _PuceConfiance(
            icone: Icons.verified_user_outlined,
            texte:
                'Le vendeur n\'est payé qu\'après ta confirmation — pas avant.',
          ),
          const SizedBox(height: 8),
          const _PuceConfiance(
            icone: Icons.refresh_rounded,
            texte:
                'Remboursement automatique si la livraison n\'est pas faite sous 7 jours.',
          ),
        ],
      ),
    );
  }
}

class _PuceConfiance extends StatelessWidget {
  const _PuceConfiance({required this.icone, required this.texte});
  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texte,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.5,
              color: AppColors.text,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
