import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/prevision.dart';
import '../../../../models/reservation_acheteur_info.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/publications/convertir_prevision_dialog.dart';
import '../../../widgets/producteur/publications/banniere_motif_rejet.dart';
import '../../../widgets/producteur/publications/coop_lock_banner.dart';
import '../../../widgets/producteur/publications/editer_prevision_dialog.dart';
import '../../../widgets/producteur/publications/header_prevision_detail.dart';
import '../../../widgets/producteur/publications/hero_prevision.dart';
import '../../../widgets/producteur/publications/info_card_prevision.dart';
import '../../../widgets/producteur/publications/section_actions_prevision.dart';
import '../../../widgets/producteur/publications/section_reservations_prevision.dart';
import '../../../widgets/producteur/publications/sticky_convertir.dart';

/// Provider familial. Comme `MarketplaceService.getPrevision(id)` n'existe
/// pas dans la version actuelle du service, on liste tout puis on filtre
/// côté client.
final _previsionDetailProvider = FutureProvider.autoDispose
    .family<Prevision?, String>((ref, id) async {
  final list = await ref.read(marketplaceServiceProvider).listPrevisions();
  return list.where((e) => e.id == id).firstOrNull;
});

/// Réservations des acheteurs sur cette prévision (vue propriétaire).
/// Le backend vérifie l'ownership ; en cas d'erreur, le widget affichera
/// un état d'erreur avec bouton Réessayer.
final _previsionReservationsProvider = FutureProvider.autoDispose
    .family<List<ReservationAcheteurInfo>, String>((ref, id) async {
  return ref
      .read(marketplaceServiceProvider)
      .listReservationsParPrevision(id);
});

/// Détail d'une prévision producteur — hero, info card, progression
/// réservations, liste réservants, actions, sticky bouton désactivé.
class PrevisionDetailPage extends ConsumerWidget {
  const PrevisionDetailPage({required this.previsionId, super.key});

  final String previsionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_previsionDetailProvider(previsionId));

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              HeaderPrevisionDetail(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (_, _) => Column(
            children: [
              const HeaderPrevisionDetail(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la prévision.',
                    onRetry: () =>
                        ref.invalidate(_previsionDetailProvider(previsionId)),
                  ),
                ),
              ),
            ],
          ),
          data: (prevision) {
            if (prevision == null) {
              return Column(
                children: [
                  const HeaderPrevisionDetail(),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                        child: Text(
                          'Cette prévision n\'existe plus.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return _Content(prevision: prevision);
          },
        ),
      ),
    );
  }
}

// ─── Contenu ─────────────────────────────────────────────────────────────

class _Content extends ConsumerWidget {
  const _Content({required this.prevision});

  final Prevision prevision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convertible = _isConvertible(prevision);
    final reasonNonConvertible = _whyNotConvertible(prevision);
    return Column(
      children: [
        const HeaderPrevisionDetail(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 130),
            children: [
              HeroPrevision(prevision: prevision),
              const InfoCardPrevision(),
              // Motif de rejet coop — affiché en priorité haute juste sous
              // le hero pour que le producteur le voie immédiatement et
              // comprenne quoi corriger avant de re-publier.
              if (prevision.coopStatus == 'REJECTED') ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.pagePaddingH,
                  ),
                  child: BanniereMotifRejet(motif: prevision.rejectedReason),
                ),
              ],
              const SizedBox(height: 6),
              // Acheteurs qui ont réservé cette prévision — vue propriétaire
              // (l'endpoint backend vérifie l'ownership ; sinon 403).
              Consumer(
                builder: (ctx, ref, _) {
                  final async = ref.watch(
                    _previsionReservationsProvider(prevision.id),
                  );
                  return SectionReservationsPrevision(
                    async: async,
                    onRetry: () => ref.invalidate(
                      _previsionReservationsProvider(prevision.id),
                    ),
                  );
                },
              ),
              // Banner d'info quand la coop a verrouillé la prévision —
              // le farmer voit clairement pourquoi il ne peut plus la
              // modifier (au lieu de cliquer dans le vide).
              if (prevision.isLockedByCoop) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.pagePaddingH,
                  ),
                  child: CoopLockBanner(coopStatus: prevision.coopStatus),
                ),
              ],
              SectionActionsPrevision(
                // Boutons désactivés si la prévision est figée :
                //  • statut non-OPEN (déjà convertie, expirée, etc.)
                //  • OU coop a VALIDATED / INCLUDED → c'est elle qui pilote.
                disabled: prevision.status != PrevisionStatus.open ||
                    prevision.isLockedByCoop,
                onModifierDate: () =>
                    _ouvrirEdition(context, ref, prevision),
                onAnnuler: () => _confirmerSuppression(context, ref, prevision),
              ),
            ],
          ),
        ),
        StickyConvertir(
          enabled: convertible,
          subtitle: reasonNonConvertible,
          onConvertir: () => _convertirPrevision(context, ref, prevision),
        ),
      ],
    );
  }
}

bool _isConvertible(Prevision p) {
  if (p.status != PrevisionStatus.open) return false;
  final date = p.dateRecoltePrev;
  if (date == null) return true; // pas de date → on autorise tout de suite
  // On considère convertible à partir de 5 jours avant la date prévue.
  final threshold = date.subtract(const Duration(days: 5));
  return DateTime.now().isAfter(threshold);
}

String? _whyNotConvertible(Prevision p) {
  if (p.status == PrevisionStatus.converted) {
    return 'Déjà convertie en annonce';
  }
  if (p.status == PrevisionStatus.cancelled) return 'Prévision annulée';
  if (p.status == PrevisionStatus.expired) return 'Prévision expirée';
  final date = p.dateRecoltePrev;
  if (date == null) return null;
  final threshold = date.subtract(const Duration(days: 5));
  if (DateTime.now().isBefore(threshold)) {
    return 'Disponible à partir du '
        '${DateFormat('d MMM', 'fr_FR').format(threshold)}';
  }
  return null;
}

/// Ouvre un dialog d'édition (date + prix cible + notes) puis appelle
/// `updatePrevision`. Au succès → invalide le provider parent pour
/// rafraîchir le détail.
Future<void> _ouvrirEdition(
  BuildContext context,
  WidgetRef ref,
  Prevision prevision,
) async {
  final updated = await showEditerPrevisionDialog(
    context,
    prevision: prevision,
  );
  if (updated == true && context.mounted) {
    // Invalide les 2 providers susceptibles d'afficher la prévision :
    // détail (cette page) ET liste (mes_publications).
    ref.invalidate(_previsionDetailProvider(prevision.id));
  }
}

/// Demande confirmation, puis supprime la prévision. Si des acheteurs
/// ont déjà réservé, le backend les rembourse AUTOMATIQUEMENT (crédite
/// leur wallet + notif). On informe le farmer du nombre de remboursements
/// dans la confirmation pour qu'il prenne une décision éclairée.
Future<void> _confirmerSuppression(
  BuildContext context,
  WidgetRef ref,
  Prevision prevision,
) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Annuler cette prévision ?'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cette action est définitive.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Si des acheteurs ont déjà réservé, leur acompte sera '
            'automatiquement remboursé sur leur wallet et ils recevront '
            'une notification.',
            style: TextStyle(height: 1.4),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Confirmer la suppression'),
        ),
      ],
    ),
  );
  if (confirm != true || !context.mounted) return;
  try {
    final result =
        await ref.read(marketplaceServiceProvider).deletePrevision(prevision.id);
    if (!context.mounted) return;
    // Message contextuel : si remboursements effectués, on affiche le
    // détail (nombre + montant). Sinon message simple.
    if (result.refundedCount > 0) {
      Snackbars.showSucces(context, result.message);
    } else {
      Snackbars.showSucces(context, 'Prévision supprimée.');
    }
    Navigator.of(context).pop();
  } on ApiException catch (e) {
    if (context.mounted) Snackbars.showErreur(context, e.message);
  } catch (e) {
    if (context.mounted) {
      Snackbars.showErreur(context, 'Suppression échouée : $e');
    }
  }
}

Future<void> _convertirPrevision(
  BuildContext context,
  WidgetRef ref,
  Prevision prevision,
) async {
  final villes = await ref.read(marketplaceServiceProvider).listVilles();
  if (!context.mounted) return;
  if (villes.isEmpty) {
    Snackbars.showErreur(context, 'Référentiel villes indisponible.');
    return;
  }

  final params = await showConvertirPrevisionDialog(
    context,
    prevision: prevision,
    villes: villes,
  );
  if (params == null || !context.mounted) return;

  try {
    // Coordonnées : pas de GPS embarqué ici → on prend le centre
    // d'Abidjan par défaut (5.345, -4.024). Le producteur pourra
    // affiner via "Modifier l'annonce" une fois créée.
    // TODO(geoloc): brancher Geolocator pour capturer la position réelle.
    final annonce = await ref
        .read(marketplaceServiceProvider)
        .convertPrevision(
          prevision.id,
          titre: params.titre,
          prixParKg: params.prix,
          quantiteMinKg: params.quantiteMinKg,
          qualite: params.qualite,
          regionId: params.regionId,
          villeId: params.villeId,
          lat: 5.345317,
          lng: -4.024429,
        );
    if (!context.mounted) return;
    Snackbars.showSucces(context, 'Prévision convertie en annonce.');
    ref.invalidate(_previsionDetailProvider(prevision.id));
    context.push(
      RouteNames.producteurAnnonceDetailPathFor(annonce.id),
    );
  } on ApiException catch (e) {
    if (!context.mounted) return;
    Snackbars.showErreur(context, e.message);
  } catch (_) {
    if (!context.mounted) return;
    Snackbars.showErreur(context, 'Impossible de convertir la prévision.');
  }
}
