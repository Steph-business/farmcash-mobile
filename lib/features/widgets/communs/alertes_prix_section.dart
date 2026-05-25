import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

const Color _kPastelVert = Color(0xFFE8F5E9);
const Color _kPastelRouge = Color(0xFFFEE2E2);

/// Une alerte de prix : un produit + variation %. Variation négative
/// (prix en baisse) → opportunité d'achat (vert). Positive → hausse
/// → on l'affiche en rouge pour signaler le coût additionnel.
class AlertePrix {
  const AlertePrix({
    required this.produit,
    required this.variationPct,
  });

  final String produit;

  /// Variation en pourcentage entier. Négatif = baisse (-5 → −5 %).
  /// Positif = hausse.
  final int variationPct;

  bool get estBaisse => variationPct < 0;
}

/// Section « Alertes prix » sur l'accueil acheteur. Affiche en ligne
/// des pastilles compactes (Cacao −5 %, Anacarde −3 %, etc.) qui
/// donnent envie d'aller voir le marché. Si la liste est vide → on
/// cache la section pour ne pas afficher un placeholder vide.
class AlertesPrixSection extends StatelessWidget {
  const AlertesPrixSection({
    required this.alertes,
    required this.onVoirTout,
    super.key,
  });

  /// Liste des alertes. Si vide, le widget renvoie SizedBox.shrink().
  final List<AlertePrix> alertes;

  /// Callback tap sur « Voir toutes » à droite du titre.
  final VoidCallback onVoirTout;

  @override
  Widget build(BuildContext context) {
    if (alertes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Alertes prix',
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
            InkWell(
              onTap: onVoirTout,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Voir toutes',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < alertes.length; i++) ...[
              Expanded(child: _ChipAlerte(alerte: alertes[i])),
              if (i < alertes.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class _ChipAlerte extends StatelessWidget {
  const _ChipAlerte({required this.alerte});
  final AlertePrix alerte;

  @override
  Widget build(BuildContext context) {
    final positif = alerte.estBaisse;
    final couleur = positif ? AppColors.primary : AppColors.error;
    final fond = positif ? _kPastelVert : _kPastelRouge;
    final signe = alerte.variationPct > 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: couleur.withValues(alpha: 0.2),
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              alerte.produit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$signe${alerte.variationPct} %',
            style: AppTextStyles.bodyMedium.copyWith(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }
}
