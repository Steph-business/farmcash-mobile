import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../communs/chargement.dart';
import '../../communs/vue_erreur.dart';
import '../demandes/carte_demande_acheteur.dart';
import '../demandes/mapper_annonce_achat.dart';
import '../demandes/modele_demande_affichage.dart';

// ─── Provider ────────────────────────────────────────────────────────

/// Charge les demandes d'achat publiées par l'acheteur connecté et les
/// convertit en modèle d'affichage. Source de vérité pour l'onglet
/// Négociations.
final ongletNegociationsProvider =
    FutureProvider.autoDispose<List<ModeleDemandeAffichage>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final page = await ref.read(marketplaceServiceProvider).listAnnoncesAchat();
  final mes = user == null
      ? page.data
      : page.data.where((a) => a.buyerId == user.id).toList();
  return mes.map(annonceAchatVersModeleAffichage).toList(growable: false);
});

/// Contenu de l'onglet « Négociations » de la page Mes commandes acheteur.
///
/// On affiche les demandes d'achat publiées par l'utilisateur — chaque
/// carte regroupe ses propositions reçues du côté vendeur. Le tap ouvre
/// la page de propositions reçues (`/acheteur/demandes/:id/propositions`)
/// où l'utilisateur peut négocier / accepter / refuser.
///
/// Si l'acheteur n'a aucune demande, un CTA l'invite à en publier une.
class OngletNegociations extends ConsumerWidget {
  const OngletNegociations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ongletNegociationsProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger les négociations. $e',
          onRetry: () => ref.invalidate(ongletNegociationsProvider),
        ),
      ),
      data: (demandes) {
        if (demandes.isEmpty) return const _VideNegociations();
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(ongletNegociationsProvider);
            await ref.read(ongletNegociationsProvider.future);
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: demandes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => CarteDemandeAcheteur(demande: demandes[i]),
          ),
        );
      },
    );
  }
}

/// État vide : pas de demande publiée → l'acheteur ne reçoit donc aucune
/// proposition. On lui propose de publier sa première demande.
class _VideNegociations extends StatelessWidget {
  const _VideNegociations();

  @override
  Widget build(BuildContext context) {
    return ListView(
      // ListView au lieu de Center pour rester pull-to-refresh-friendly
      // si on l'enroule plus tard dans un RefreshIndicator.
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      children: [
        const Icon(
          Icons.handshake_outlined,
          size: 48,
          color: AppColors.textSubtle,
        ),
        const SizedBox(height: 12),
        Text(
          'Aucune négociation en cours',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Publie une demande d\'achat — les producteurs te répondront '
          'avec leurs propositions.',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        Align(
          child: SizedBox(
            width: 220,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.push(RouteNames.acheteurDemandePublierPath),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Publier une demande'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
