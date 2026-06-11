// =====================================================================
//  Badge premium « Prix négocié X F/kg »
//  ---------------------------------------------------------------------
//  Affiché sur la fiche détail d'une annonce vente UNIQUEMENT pour
//  l'acheteur courant s'il a une candidature ACCEPTED sur cette annonce.
//
//  C'est ce que le PO appelle « la vue marché personnalisée » : pour cet
//  acheteur, le prix est sa version négociée ; pour les autres, le prix
//  marché d'origine reste affiché. Pas de mutation côté annonce.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/enums.dart';
import '../../../../models/negociation.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Provider best-effort : retourne la candidature ACCEPTED de l'acheteur
/// pour cette annonce, ou null s'il n'en a pas / l'endpoint échoue.
final mesCandidaturesAccepteesProvider = FutureProvider.autoDispose
    .family<Candidature?, String>((ref, annonceId) async {
  try {
    final all = await ref
        .read(negotiationServiceProvider)
        .listCandidatures(
          direction: 'outgoing',
          status: NegotiationStatus.accepted,
        );
    return all.where((c) => c.annonceId == annonceId).cast<Candidature?>().firstWhere(
          (c) => c != null,
          orElse: () => null,
        );
  } catch (_) {
    return null;
  }
});

class BadgePrixNegocie extends ConsumerWidget {
  const BadgePrixNegocie({
    super.key,
    required this.annonceId,
    required this.prixMarcheKg,
  });

  final String annonceId;
  final double prixMarcheKg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mesCandidaturesAccepteesProvider(annonceId));
    final cand = async.valueOrNull;
    if (cand == null) return const SizedBox.shrink();

    final nf = NumberFormat('#,##0', 'fr_FR');
    final prixMarche = prixMarcheKg.round();
    final prixNegocie = cand.prixProposeKg.round();
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
