import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/cooperative/sollicitations/body_suivi_sollicitation_coop.dart';
import '../../../widgets/cooperative/sollicitations/header_suivi_sollicitation_coop.dart';
import '../../../widgets/cooperative/sollicitations/modele_sollicitation_suivi_coop.dart';
import '../../../widgets/cooperative/sollicitations/sticky_suivi_sollicitation_coop.dart';

/// Suivi d'une sollicitation envoyée par la coop : progression du
/// remplissage, liste des réponses, actions (clôturer).
class SollicitationSuiviPage extends ConsumerWidget {
  const SollicitationSuiviPage({required this.sollicitationId, super.key});

  final String sollicitationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sollicitationSuiviCoopProvider(sollicitationId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderSuiviSollicitationCoop(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger la sollicitation. $e',
                    onRetry: () => ref.invalidate(
                      sollicitationSuiviCoopProvider(sollicitationId),
                    ),
                  ),
                ),
                data: (detail) => BodySuiviSollicitationCoop(
                  detail: detail,
                  sollicitationId: sollicitationId,
                ),
              ),
            ),
            StickySuiviSollicitationCoop(sollicitationId: sollicitationId),
          ],
        ),
      ),
    );
  }
}
