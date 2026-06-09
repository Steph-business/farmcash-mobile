import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/membre_coop.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';
import '../../widgets/cooperative/membres/carte_adhesion.dart';
import '../../widgets/cooperative/membres/entete_adhesions.dart';
import '../../widgets/cooperative/membres/etat_vide_adhesions.dart';

// ─── Provider racine — appel API uniquement ─────────────────────────────

/// Liste des demandes d'adhésion en attente côté coop. Aucune fallback
/// mock : si la liste est vide, l'UI affiche un empty-state honnête.
final _adhesionsCoopProvider =
    FutureProvider.autoDispose<List<_AdhesionView>>((ref) async {
  final coopSvc = ref.read(cooperativesServiceProvider);
  final api = await coopSvc.listJoinRequests();
  return api
      .where((r) => r.status.toUpperCase() == 'PENDING')
      .map((r) => _AdhesionView.fromApi(r))
      .toList(growable: false);
});

/// Vue d'affichage d'une demande d'adhésion. Le backend ne renvoie pas
/// encore le profil complet du demandeur — on affiche un id court en
/// attendant l'enrichissement back.
class _AdhesionView {
  final String id;
  final String nom;
  final String? avatarUrl;
  final String? ville;
  final String? tel;
  final String? time;

  _AdhesionView({
    required this.id,
    required this.nom,
    required this.avatarUrl,
    required this.ville,
    required this.tel,
    required this.time,
  });

  factory _AdhesionView.fromApi(CoopJoinRequest r) => _AdhesionView(
        id: r.id,
        nom: 'Demandeur ${_short(r.farmerId)}',
        avatarUrl: null,
        ville: null,
        tel: null,
        time: r.message,
      );

  static String _short(String id) {
    final t = id.trim();
    if (t.isEmpty) return '?';
    final tail = t.contains('_') ? t.split('_').last : t;
    return tail.length > 6 ? tail.substring(0, 6) : tail;
  }
}

/// Page Demandes d'adhésion — coop voit la liste des farmers qui
/// souhaitent rejoindre. Reproduction fidèle de
/// `mockups/cooperative/adhesions.html`.
class AdhesionsCooperativePage extends ConsumerWidget {
  const AdhesionsCooperativePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_adhesionsCoopProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteAdhesions(
              count: async.maybeWhen(
                data: (list) => list.length,
                orElse: () => 0,
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Chargement(size: 22),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: "Impossible de charger les demandes.",
                    onRetry: () => ref.invalidate(_adhesionsCoopProvider),
                  ),
                ),
                data: (items) => items.isEmpty
                    ? const EtatVideAdhesions()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.pagePaddingH,
                          AppDimens.space16,
                          AppDimens.pagePaddingH,
                          AppDimens.space16,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final a = items[i];
                          return CarteAdhesion(
                            nom: a.nom,
                            avatarUrl: a.avatarUrl,
                            ville: a.ville,
                            tel: a.tel,
                            time: a.time,
                            onAccepter: () => _handle(
                              context,
                              ref,
                              a,
                              accept: true,
                            ),
                            onRefuser: () => _handle(
                              context,
                              ref,
                              a,
                              accept: false,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _AdhesionView a, {
    required bool accept,
  }) async {
    try {
      await ref.read(cooperativesServiceProvider).handleJoinRequest(
            id: a.id,
            accept: accept,
          );
      if (context.mounted) {
        Snackbars.showSucces(
          context,
          accept ? 'Demande acceptée' : 'Demande refusée',
        );
      }
      ref.invalidate(_adhesionsCoopProvider);
    } catch (e) {
      if (context.mounted) {
        Snackbars.showErreurInattendue(context, e);
      }
    }
  }
}
