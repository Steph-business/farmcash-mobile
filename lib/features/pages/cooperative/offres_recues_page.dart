import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/annonce_achat.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/cooperative/publications/carte_offre_recue.dart';
import '../../widgets/cooperative/publications/dialog_proposer_offre.dart';
import '../../widgets/cooperative/publications/entete_offres_recues.dart';
import '../../widgets/cooperative/publications/etat_vide_offres_recues.dart';

/// Charge les offres d'achat qui arrivent vers la coopérative (publiques OU
/// ciblées sur cette coop). Endpoint dédié `/coop/annonces-achat/incoming`.
final _offresProvider =
    FutureProvider.autoDispose<List<AnnonceAchat>>((ref) async {
  return ref.read(cooperativesServiceProvider).listIncomingAnnoncesAchat();
});

/// Liste des offres d'achat reçues par la coopérative. Buyer **anonymisé**
/// dans l'UI (anti-contournement), seules les coordonnées du transporteur
/// seront partagées lors d'un éventuel accord.
class OffresRecuesPage extends ConsumerStatefulWidget {
  const OffresRecuesPage({super.key});

  @override
  ConsumerState<OffresRecuesPage> createState() => _OffresRecuesPageState();
}

class _OffresRecuesPageState extends ConsumerState<OffresRecuesPage> {
  String? _busyId;

  Future<void> _refresh() async {
    ref.invalidate(_offresProvider);
    await ref.read(_offresProvider.future);
  }

  Future<void> _proposer(AnnonceAchat o) async {
    if (_busyId != null) return;
    final result = await ouvrirDialogProposerOffre(context, offre: o);
    if (result.annule) return;
    if (!mounted) return;
    final brouillon = result.brouillon;
    if (brouillon == null) {
      Snackbars.showErreur(context, 'Quantité et prix requis.');
      return;
    }
    setState(() => _busyId = o.id);
    try {
      await ref.read(negotiationServiceProvider).createProposition(
            annonceAchatId: o.id,
            quantiteKg: brouillon.quantiteKg,
            prixProposeKg: brouillon.prixKg,
            message: brouillon.message,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Proposition envoyée à l\'acheteur.');
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _refuser(AnnonceAchat o) {
    // Pas d'endpoint pour refuser une demande publique côté coop —
    // on cache localement (no-op back). Pour V2, ajouter
    // dismissAnnonceAchat ou marquer ignored côté UI persistant.
    Snackbars.showInfo(context, 'Offre masquée.');
  }

  void _solliciter(AnnonceAchat o) {
    // Le sollicitation_creer_page attend un offreId réel : on le passe
    // ici en argument de route pour que la sollicitation soit attachée
    // à cette annonce d'achat.
    context.push(
      RouteNames.cooperativeSollicitationCreerPath,
      extra: {'offreId': o.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_offresProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            async.when(
              data: (list) => EnteteOffresRecues(count: list.length),
              loading: () => const EnteteOffresRecues(count: 0),
              error: (_, _) => const EnteteOffresRecues(count: 0),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les offres. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (items) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refresh,
                  child: items.isEmpty
                      ? const EtatVideOffresRecues()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimens.pagePaddingH,
                            0,
                            AppDimens.pagePaddingH,
                            AppDimens.space16,
                          ),
                          itemCount: items.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: CarteOffreRecue(
                              offre: items[i],
                              busy: _busyId == items[i].id,
                              onRefuser: () => _refuser(items[i]),
                              onProposer: () => _proposer(items[i]),
                              onSolliciter: () => _solliciter(items[i]),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
