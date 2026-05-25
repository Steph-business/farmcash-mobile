import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/membre_coop.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/cooperative/membres/bouton_promouvoir_membre.dart';
import '../../../widgets/cooperative/membres/carte_actions_membre.dart';
import '../../../widgets/cooperative/membres/carte_hero_membre.dart';
import '../../../widgets/cooperative/membres/entete_membre_detail.dart';
import '../../../widgets/cooperative/membres/feuille_promouvoir_membre.dart';
import '../../../widgets/cooperative/membres/titre_section_membre.dart';

/// Provider qui retrouve un membre via `listMembers()` filtré par userId.
///
/// Le backend n'a pas de `GET /coop/members/:id` ; on récupère la liste
/// complète paginée (limite 100) puis on filtre côté client par `userId`,
/// qui est le paramètre passé dans l'URL.
final _membreDetailProvider = FutureProvider.autoDispose
    .family<MembreCoop?, String>((ref, userId) async {
  final svc = ref.read(cooperativesServiceProvider);
  final page = await svc.listMembers(limit: 100);
  for (final m in page.data) {
    if (m.userId == userId || m.id == userId) return m;
  }
  return null;
});

/// Fiche d'un membre de la coopérative (accès via la liste membres).
///
/// CRITIQUE — règle chantier 3b "anti-contournement" :
/// La coopérative voit FULL ses membres. Cet écran affiche donc :
///   • le nom complet réel (header, hero) ;
///   • le téléphone réel ;
///   • le rôle réel ;
///   • la date d'adhésion.
///
/// Cette EXCEPTION s'applique UNIQUEMENT entre la coop et SES membres.
class MembreDetailPage extends ConsumerStatefulWidget {
  const MembreDetailPage({super.key, required this.membreId});

  /// `userId` du membre — c'est ce qui figure dans l'URL `/membres/:id`.
  final String membreId;

  @override
  ConsumerState<MembreDetailPage> createState() => _MembreDetailPageState();
}

class _MembreDetailPageState extends ConsumerState<MembreDetailPage> {
  bool _promoting = false;

  Future<void> _promouvoir(MembreCoop membre) async {
    if (_promoting) return;
    final phone = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => FeuillePromouvoirMembre(nomMembre: membre.fullName),
    );
    if (phone == null || phone.isEmpty) return;
    if (!mounted) return;
    setState(() => _promoting = true);
    try {
      await ref.read(cooperativesServiceProvider).promoteManagedMember(
            memberUserId: membre.userId,
            phone: phone,
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Promotion lancée — un OTP a été envoyé à $phone.',
      );
      ref.invalidate(_membreDetailProvider(widget.membreId));
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _promoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_membreDetailProvider(widget.membreId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteMembreDetail(
              nom: async.maybeWhen(
                data: (m) => m?.fullName ?? 'Membre',
                orElse: () => 'Membre',
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger ce membre. $e',
                    onRetry: () => ref
                        .invalidate(_membreDetailProvider(widget.membreId)),
                  ),
                ),
                data: (membre) {
                  if (membre == null) {
                    return Padding(
                      padding:
                          const EdgeInsets.all(AppDimens.pagePaddingH),
                      child: Text(
                        'Membre introuvable.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    );
                  }
                  return _Body(
                    membre: membre,
                    promoting: _promoting,
                    onPromouvoir: () => _promouvoir(membre),
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

class _Body extends StatelessWidget {
  const _Body({
    required this.membre,
    required this.promoting,
    required this.onPromouvoir,
  });

  final MembreCoop membre;
  final bool promoting;
  final VoidCallback onPromouvoir;

  @override
  Widget build(BuildContext context) {
    final fullName = membre.fullName ?? 'Membre';
    final phone = membre.phone;
    final photoUrl = membre.photoUrl;
    final dateAdhesion = membre.joinedAt;
    final membreDepuisLabel = dateAdhesion == null
        ? 'Adhésion récente'
        : 'Membre depuis ${DateFormat('MM/y').format(dateAdhesion)}';
    final roleLabel = _roleLabel(membre.role);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        CarteHeroMembre(
          nom: fullName,
          phone: phone,
          photoUrl: photoUrl,
          membreDepuis: membreDepuisLabel,
          roleLabel: roleLabel,
          onAppeler: () => _snack(context, 'Appel en cours — à venir'),
          onMessage: () => _snack(context, 'Message — à venir'),
        ),
        AppDimens.vGap16,
        const TitreSectionMembre(titre: 'Actions'),
        CarteActionsMembre(
          onVerserAvance: () => context.push(
            '${RouteNames.cooperativeVerserAvancePath}?membreId=${membre.userId}',
          ),
        ),
        if (membre.estGere) ...[
          AppDimens.vGap16,
          BoutonPromouvoirMembre(
            busy: promoting,
            onTap: onPromouvoir,
          ),
        ],
      ],
    );
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

String _roleLabel(CoopMemberRole role) {
  switch (role) {
    case CoopMemberRole.president:
      return 'Président';
    case CoopMemberRole.gerant:
      return 'Gérant';
    case CoopMemberRole.tresorier:
      return 'Trésorier';
    case CoopMemberRole.membre:
      return 'Membre';
    case CoopMemberRole.unknown:
      return 'Membre';
  }
}
