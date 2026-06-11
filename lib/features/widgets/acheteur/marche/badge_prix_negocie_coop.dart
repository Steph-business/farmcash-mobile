// =====================================================================
//  Badge premium « Prix négocié X F/kg » — publication coop
//  ---------------------------------------------------------------------
//  Affiché sur la fiche détail d'une publication coop UNIQUEMENT pour
//  l'acheteur courant s'il a une contre-offre ACCEPTED sur cette publication.
//
//  Symétrique de `badge_prix_negocie.dart` (annonces vente) mais cible
//  les `contre_offres_coop` (BUYER → COOP). Même look premium, même logique
//  best-effort silencieux.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/negociation.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Provider best-effort : retourne la contre-offre coop ACCEPTED de
/// l'acheteur pour cette publication, ou null s'il n'en a pas / l'endpoint
/// échoue.
final mesContreOffresCoopAccepteesProvider = FutureProvider.autoDispose
    .family<ContreOffreCoop?, String>((ref, publicationCoopId) async {
  try {
    final all = await ref
        .read(negotiationServiceProvider)
        .listContreOffresCoop(
          direction: 'outgoing',
          status: NegotiationStatus.accepted,
        );
    return all
        .where((c) => c.publicationCoopId == publicationCoopId)
        .cast<ContreOffreCoop?>()
        .firstWhere(
          (c) => c != null,
          orElse: () => null,
        );
  } catch (_) {
    return null;
  }
});

class BadgePrixNegocieCoop extends ConsumerWidget {
  const BadgePrixNegocieCoop({
    super.key,
    required this.publicationCoopId,
    required this.prixMarcheKg,
  });

  final String publicationCoopId;
  final double prixMarcheKg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async =
        ref.watch(mesContreOffresCoopAccepteesProvider(publicationCoopId));
    final contre = async.valueOrNull;
    if (contre == null) return const SizedBox.shrink();

    final nf = NumberFormat('#,##0', 'fr_FR');
    final prixMarche = prixMarcheKg.round();
    final prixNegocie = contre.prixProposeKg.round();
    final economie = prixMarche - prixNegocie;
    final isAvantage = economie > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.handshake_rounded,
              size: 17,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ton prix négocié',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${nf.format(prixNegocie)} F/kg',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'au lieu de ${nf.format(prixMarche)} F',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSubtle,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                if (isAvantage) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Tu économises ${nf.format(economie)} F/kg.',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
