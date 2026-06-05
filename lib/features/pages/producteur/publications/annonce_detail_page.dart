import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/annonce_vente.dart';
import '../../../../models/enums.dart';
import '../../../../models/negociation.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/publications/banniere_motif_rejet.dart';
import '../../../widgets/producteur/publications/header_annonce_detail.dart';
import '../../../widgets/producteur/publications/hero_annonce_detail.dart';
import '../../../widgets/producteur/publications/kpi_row_annonce.dart';
import '../../../widgets/producteur/publications/section_acheteurs_interesses.dart';
import '../../../widgets/producteur/publications/section_caracteristiques_annonce.dart';
import '../../../widgets/producteur/publications/sticky_buttons_annonce.dart';

/// Provider familial : récupère une annonce de vente par id.
final _annonceDetailProvider = FutureProvider.autoDispose
    .family<AnnonceVente, String>((ref, id) async {
  return ref.watch(marketplaceServiceProvider).getAnnonceVente(id);
});

/// Provider familial : candidatures reçues sur l'annonce (filtre côté
/// client sur `annonceId` car l'endpoint backend retourne toutes les
/// candidatures incoming du farmer connecté).
final _candidaturesProvider = FutureProvider.autoDispose
    .family<List<Candidature>, String>((ref, annonceId) async {
  final svc = ref.watch(negotiationServiceProvider);
  final all = await svc.listCandidatures(direction: 'incoming');
  return all.where((c) => c.annonceId == annonceId).toList(growable: false);
});

/// Détail d'une annonce de vente côté producteur — hero, KPIs, caracs,
/// acheteurs intéressés, sticky bouton.
class AnnonceDetailPage extends ConsumerWidget {
  const AnnonceDetailPage({required this.annonceId, super.key});

  final String annonceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_annonceDetailProvider(annonceId));

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              HeaderAnnonceDetail(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const HeaderAnnonceDetail(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger l\'annonce.',
                    onRetry: () =>
                        ref.invalidate(_annonceDetailProvider(annonceId)),
                  ),
                ),
              ),
            ],
          ),
          data: (annonce) => _Content(annonce: annonce),
        ),
      ),
    );
  }
}

// ─── Actions sur l'annonce ───────────────────────────────────────────────

Future<void> _confirmAndPause(
  BuildContext context,
  WidgetRef ref,
  AnnonceVente annonce,
) async {
  final paused = annonce.status == ProductStatus.paused;
  final newStatus = paused ? ProductStatus.active : ProductStatus.paused;
  final label = paused ? 'Réactiver' : 'Mettre en pause';
  try {
    await ref
        .read(marketplaceServiceProvider)
        .updateAnnonceVente(annonce.id, status: newStatus);
    if (!context.mounted) return;
    ref.invalidate(_annonceDetailProvider(annonce.id));
    Snackbars.showSucces(
      context,
      paused ? 'Annonce réactivée.' : 'Annonce mise en pause.',
    );
  } on ApiException catch (e) {
    if (!context.mounted) return;
    Snackbars.showErreur(context, e.message);
  } catch (_) {
    if (!context.mounted) return;
    Snackbars.showErreur(context, 'Impossible de $label cette annonce.');
  }
}

Future<void> _confirmAndDelete(
  BuildContext context,
  WidgetRef ref,
  AnnonceVente annonce,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Supprimer cette annonce ?'),
      content: const Text(
        'Cette action est définitive. Les acheteurs ne pourront plus la voir.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Supprimer',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    await ref
        .read(marketplaceServiceProvider)
        .deleteAnnonceVente(annonce.id);
    if (!context.mounted) return;
    Snackbars.showSucces(context, 'Annonce supprimée.');
    Navigator.of(context).pop(true);
  } on ApiException catch (e) {
    if (!context.mounted) return;
    Snackbars.showErreur(context, e.message);
  } catch (_) {
    if (!context.mounted) return;
    Snackbars.showErreur(context, 'Impossible de supprimer l\'annonce.');
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.annonce});

  final AnnonceVente annonce;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidaturesAsync =
        ref.watch(_candidaturesProvider(annonce.id));
    final candidatures = candidaturesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => const <Candidature>[],
    );

    return Column(
      children: [
        HeaderAnnonceDetail(
          onEdit: () => _confirmAndDelete(context, ref, annonce),
          editIcon: Icons.delete_outline,
          editTooltip: 'Supprimer',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              HeroAnnonceDetail(annonce: annonce),
              // Motif de rejet coop — sous le hero pour visibilité max
              // quand l'annonce a été refusée par la coopérative.
              if (annonce.coopStatus == CoopAnnonceStatus.rejected) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.pagePaddingH,
                  ),
                  child: BanniereMotifRejet(motif: annonce.rejectedReason),
                ),
                const SizedBox(height: 8),
              ],
              KpiRowAnnonce(
                vues: annonce.viewsCount,
                messages: candidatures.length,
                commandes: candidatures
                    .where((c) => c.status == NegotiationStatus.accepted)
                    .length,
              ),
              SectionCaracteristiquesAnnonce(annonce: annonce),
              SectionAcheteursInteresses(
                async: candidaturesAsync,
                onRetry: () =>
                    ref.invalidate(_candidaturesProvider(annonce.id)),
                // Onglet shell → context.go pour que le bottom nav
                // active la branche Messages (sinon Accueil reste actif).
                onRepondre: (c) =>
                    context.go(RouteNames.producteurMessagesPath),
              ),
            ],
          ),
        ),
        StickyButtonsAnnonce(
          paused: annonce.status == ProductStatus.paused,
          onPause: () => _confirmAndPause(context, ref, annonce),
          onModifier: () => Snackbars.showInfo(
            context,
            'Édition — à venir',
          ),
        ),
      ],
    );
  }
}
