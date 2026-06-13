import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/annonce_vente.dart';
import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/entete_page_standard.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── Constantes locales ─────────────────────────────────────────────────
const Color _kPrimarySoft = Color(0xFFE8F5E9);
const BorderRadius _kBrCard14 = BorderRadius.all(Radius.circular(14));
const BorderRadius _kBrThumb = BorderRadius.all(Radius.circular(10));

/// Annonces de vente en attente de validation / pesée par la coop.
final _collecteProvider =
    FutureProvider.autoDispose<List<AnnonceVente>>((ref) {
  return ref
      .read(cooperativesServiceProvider)
      .listAssignedAnnoncesVente(coopStatus: CoopAnnonceStatus.pending);
});

/// Page Collecte coopérative — livraisons farmer en attente de pesée.
///
/// Le backend n'a pas d'endpoint dédié "collecte du jour". On utilise
/// `listAssignedAnnoncesVente(coopStatus: PENDING)` qui liste les
/// annonces que la coop doit encore valider — équivalent fonctionnel
/// pour "j'attends de peser chez moi".
class CollecteCooperativePage extends ConsumerWidget {
  const CollecteCooperativePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_collecteProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Collecte du jour'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la collecte. $e',
                    onRetry: () => ref.invalidate(_collecteProvider),
                  ),
                ),
                data: (annonces) {
                  if (annonces.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.space24),
                        child: Text(
                          'Aucune livraison à peser pour le moment.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(_collecteProvider);
                      await ref.read(_collecteProvider.future);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.pagePaddingH,
                        AppDimens.space8,
                        AppDimens.pagePaddingH,
                        AppDimens.space16,
                      ),
                      itemCount: annonces.length,
                      itemBuilder: (_, i) {
                        final a = annonces[i];
                        return _CollecteCard(
                          annonce: a,
                          onPeser: () => context.push(
                            RouteNames.cooperativePeseePathFor(a.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card d'une livraison ───────────────────────────────────────────────

class _CollecteCard extends StatelessWidget {
  const _CollecteCard({required this.annonce, required this.onPeser});

  final AnnonceVente annonce;
  final VoidCallback onPeser;

  @override
  Widget build(BuildContext context) {
    final produit = annonce.produitNom ?? annonce.titre;
    final farmer = annonce.vendeurNom ?? 'Producteur';
    final qte = '${_fmtKg(annonce.quantiteKg)} kg';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: _kBrCard14,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: _kBrThumb,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  produit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  qte,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  farmer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onPeser,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            child: Text(
              'Peser',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _fmtKg(double kg) {
  final i = kg.round();
  if (i < 1000) return '$i';
  final s = '$i';
  final buf = StringBuffer();
  for (var k = 0; k < s.length; k++) {
    if (k > 0 && (s.length - k) % 3 == 0) buf.write(' ');
    buf.write(s[k]);
  }
  return buf.toString();
}
