import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/prevision.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/chargement.dart';
import '../../communs/vue_erreur.dart';
import 'carte_prevision_publication.dart';
import 'mes_publications_constants.dart';

/// Corps de l'onglet « Prévisions » de la page « Mes publications »
/// producteur : grille 2 colonnes de cartes prévisions, avec gestion des
/// états loading / erreur / vide.
class BodyPrevisionsPublications extends StatelessWidget {
  const BodyPrevisionsPublications({
    required this.async,
    required this.onRetry,
    super.key,
  });

  final AsyncValue<List<Prevision>> async;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: AppDimens.space32),
        child: Chargement(size: 22),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger tes prévisions.',
          onRetry: onRetry,
        ),
      ),
      data: (previsions) {
        if (previsions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppDimens.pagePaddingH),
            child: Center(
              child: Text(
                'Aucune prévision pour l\'instant.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pagePaddingH,
            0,
            AppDimens.pagePaddingH,
            AppDimens.space16,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.74,
          ),
          itemCount: previsions.length,
          itemBuilder: (_, i) => CartePrevisionPublication(
            prevision: previsions[i],
            photoFallback: kMesPublicationsPhotosFallback[
                i % kMesPublicationsPhotosFallback.length],
          ),
        );
      },
    );
  }
}
