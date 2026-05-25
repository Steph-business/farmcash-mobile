import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/commande.dart';
import '../../../models/enums.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Carte pédagogique qui montre **où est l'argent** à chaque étape d'une
/// commande. Pensée pour un utilisateur low-tech qui ne connaît pas les
/// concepts financiers (escrow / libération) : couleur claire, icône
/// dédiée à chaque état, montant en gros.
///
/// États couverts :
///   • [_State.bloque]   → cadenas violet (escrow en attente).
///   • [_State.libere]   → wallet vert (escrow released).
///   • [_State.litige]   → marteau ambré (commande en dispute).
///   • [_State.annule]   → flèche retour bleu (annulé / refusé).
///
/// Le wording s'adapte selon [viewerIsBuyer] : « ton paiement bloqué » vs
/// « tu vas recevoir », « remboursé » vs « commande annulée », etc.
class CarteArgentCommande extends StatelessWidget {
  const CarteArgentCommande({
    required this.commande,
    required this.viewerIsBuyer,
    super.key,
  });

  /// Commande dont on affiche l'état financier.
  final Commande commande;

  /// `true` côté acheteur, `false` côté producteur. Change le wording
  /// (« ton paiement » vs « tu vas recevoir »).
  final bool viewerIsBuyer;

  @override
  Widget build(BuildContext context) {
    final state = _resolveState(commande);
    final visual = _visualFor(state);
    final montant =
        NumberFormat('#,##0', 'fr_FR').format(commande.montantTotal.round());

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: visual.soft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: visual.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(visual.icon, size: 22, color: visual.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$montant F',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: visual.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        visual.titre(viewerIsBuyer),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: visual.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  visual.sousTitre(viewerIsBuyer),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _State _resolveState(Commande c) {
    if (c.status == OrderStatus.disputed) return _State.litige;
    if (c.status == OrderStatus.cancelled ||
        c.status == OrderStatus.rejected) {
      return _State.annule;
    }
    if (c.escrowReleased) return _State.libere;
    return _State.bloque;
  }

  _Visual _visualFor(_State state) {
    switch (state) {
      case _State.litige:
        return const _Visual(
          icon: Icons.gavel,
          color: Color(0xFFB45309),
          soft: Color(0xFFFEF3C7),
          titreBuyer: 'Litige en cours',
          titreSeller: 'Litige en cours',
          sousTitreBuyer:
              "L'argent reste protégé tant que le litige n'est pas résolu.",
          sousTitreSeller:
              "L'argent est gelé jusqu'à la résolution du litige.",
        );
      case _State.annule:
        return const _Visual(
          icon: Icons.replay,
          color: Color(0xFF1D4ED8),
          soft: Color(0xFFDBEAFE),
          titreBuyer: 'Remboursé',
          titreSeller: 'Commande annulée',
          sousTitreBuyer: 'Le montant est revenu dans ton wallet.',
          sousTitreSeller: "Aucun paiement n'a été versé.",
        );
      case _State.libere:
        return const _Visual(
          icon: Icons.account_balance_wallet,
          color: Color(0xFF166534),
          soft: Color(0xFFDCFCE7),
          titreBuyer: 'Vendeur payé',
          titreSeller: 'Argent dans ton wallet',
          sousTitreBuyer:
              "L'escrow a été libéré : le vendeur a été crédité.",
          sousTitreSeller: 'Tu peux le dépenser ou le retirer maintenant.',
        );
      case _State.bloque:
        return const _Visual(
          icon: Icons.lock_outline,
          color: Color(0xFF7C3AED),
          soft: Color(0xFFEDE9FE),
          titreBuyer: 'Ton paiement est bloqué',
          titreSeller: 'Argent en attente',
          sousTitreBuyer:
              "Il sera libéré au vendeur à la livraison confirmée.",
          sousTitreSeller:
              "Arrive sur ton wallet dès que l'acheteur confirme la livraison.",
        );
    }
  }
}

enum _State { bloque, libere, litige, annule }

class _Visual {
  const _Visual({
    required this.icon,
    required this.color,
    required this.soft,
    required this.titreBuyer,
    required this.titreSeller,
    required this.sousTitreBuyer,
    required this.sousTitreSeller,
  });

  final IconData icon;
  final Color color;
  final Color soft;
  final String titreBuyer;
  final String titreSeller;
  final String sousTitreBuyer;
  final String sousTitreSeller;

  String titre(bool isBuyer) => isBuyer ? titreBuyer : titreSeller;
  String sousTitre(bool isBuyer) =>
      isBuyer ? sousTitreBuyer : sousTitreSeller;
}
