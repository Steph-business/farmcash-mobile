import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/providers.dart';
import '../../../state/auth_state.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/acheteur/demandes/corps_mes_demandes.dart';
import '../../../widgets/acheteur/demandes/header_mes_demandes.dart';
import '../../../widgets/acheteur/demandes/mapper_annonce_achat.dart';
import '../../../widgets/acheteur/demandes/modele_demande_affichage.dart';
import '../../../widgets/acheteur/demandes/onglets_mes_demandes.dart';
import '../../../widgets/communs/chargement.dart';

final _mesDemandesProvider =
    FutureProvider.autoDispose<List<ModeleDemandeAffichage>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final p = await ref.read(marketplaceServiceProvider).listAnnoncesAchat();
  // Côté buyer : on filtre pour ne garder que les demandes de l'utilisateur.
  final mes = user == null
      ? p.data
      : p.data.where((a) => a.buyerId == user.id).toList();
  return mes.map(annonceAchatVersModeleAffichage).toList(growable: false);
});

/// Liste des demandes d'achat publiées par l'acheteur connecté.
/// Calque sur `mockups/acheteur/mes_demandes.html`.
class MesDemandesAcheteurPage extends ConsumerStatefulWidget {
  const MesDemandesAcheteurPage({super.key});

  @override
  ConsumerState<MesDemandesAcheteurPage> createState() =>
      _MesDemandesAcheteurPageState();
}

class _MesDemandesAcheteurPageState
    extends ConsumerState<MesDemandesAcheteurPage> {
  OngletMesDemandes _tab = OngletMesDemandes.actives;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_mesDemandesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderMesDemandes(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: Center(
                    child: Text(
                      'Impossible de charger les demandes. $e',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                data: (items) => CorpsMesDemandes(
                  items: items,
                  tab: _tab,
                  onTabChange: (t) => setState(() => _tab = t),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
