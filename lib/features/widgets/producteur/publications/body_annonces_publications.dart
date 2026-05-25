import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/annonce_vente.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/chargement.dart';
import '../../communs/vue_erreur.dart';
import 'carte_annonce_publication.dart';
import 'mes_publications_constants.dart';

/// Corps de l'onglet « Annonces actives » de la page « Mes publications »
/// producteur : grille 2 colonnes de cartes annonces, avec gestion des
/// états loading / erreur / vide. Le callback [onRetry] est appelé sur le
/// bouton « Réessayer » de la vue d'erreur.
class BodyAnnoncesPublications extends StatelessWidget {
  const BodyAnnoncesPublications({
    required this.async,
    required this.onRetry,
    super.key,
  });

  final AsyncValue<List<AnnonceVente>> async;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: AppDimens.space32),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger tes annonces.',
          onRetry: onRetry,
        ),
      ),
      data: (annonces) {
        if (annonces.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppDimens.pagePaddingH),
            child: Center(
              child: Text(
                'Aucune annonce active pour l\'instant.',
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
          itemCount: annonces.length,
          itemBuilder: (_, i) => CarteAnnoncePublication(
            annonce: annonces[i],
            photoFallback: kMesPublicationsPhotosFallback[
                i % kMesPublicationsPhotosFallback.length],
          ),
        );
      },
    );
  }
}
