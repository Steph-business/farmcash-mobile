import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/producteur/commandes/contenu_reservations_recues.dart';

/// Page autonome « Réservations reçues » — accessible depuis le bandeau
/// au-dessus de l'onglet Prévisions de « Mes publications ». Cette
/// page existe pour les producteurs qui arrivent par un deep-link ou
/// le bandeau ; la même donnée est aussi visible dans l'onglet
/// « Réservations » de la page Commandes (top-level).
class MesReservationsRecuesPage extends ConsumerWidget {
  const MesReservationsRecuesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const SafeArea(
        bottom: false,
        child: Column(
          children: [
            EntetePageStandard(titre: 'Réservations reçues'),
            Expanded(child: ContenuReservationsRecues()),
          ],
        ),
      ),
    );
  }
}
