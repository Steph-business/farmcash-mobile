import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../communs/snackbars.dart';
import 'parcelle_ajouter_culture_sheet.dart';
import 'parcelle_danger_link.dart';
import 'parcelle_detail_data.dart';
import 'parcelle_detail_header.dart';
import 'parcelle_hero_card.dart';
import 'parcelle_section_cultures.dart';

/// Contenu principal de la page détail parcelle (header + hero +
/// cultures + lien suppression).
///
/// Le `onCultureAjoutee` est appelé après un ajout réussi pour que le
/// parent rafraîchisse son provider de détail (la sheet ne sait pas
/// quelle clé invalider).
class ParcelleDetailContent extends ConsumerWidget {
  const ParcelleDetailContent({
    required this.data,
    required this.onCultureAjoutee,
    super.key,
  });

  final ParcelleDetailData data;
  final VoidCallback onCultureAjoutee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcelle = data.parcelle!;
    return Column(
      children: [
        ParcelleDetailHeader(
          titre: parcelle.nom,
          sousTitre: 'Détail de la parcelle',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePaddingH,
              0,
              AppDimens.pagePaddingH,
              AppDimens.space16,
            ),
            children: [
              ParcelleHeroCard(parcelle: parcelle),
              const SizedBox(height: AppDimens.space24),
              ParcelleSectionCultures(
                cultures: data.cultures,
                produitsById: data.produitsById,
                onAjouter: () => _ouvrirAjoutCulture(context, ref, data),
              ),
              const SizedBox(height: 18),
              ParcelleDangerLink(
                onTap: () => Snackbars.showInfo(
                  context,
                  'Supprimer la parcelle — à venir',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Ouvre le bottom-sheet d'ajout de culture. Au retour `true`, on
  /// notifie le parent pour qu'il refresh la liste cultures.
  Future<void> _ouvrirAjoutCulture(
    BuildContext context,
    WidgetRef ref,
    ParcelleDetailData data,
  ) async {
    final parcelle = data.parcelle!;
    // Calcule la superficie restante = superficie parcelle - somme des
    // cultures existantes. Backend rejette si on dépasse ; on affiche
    // l'info en helper pour guider la saisie.
    final totalCultures = data.cultures.fold<double>(
      0,
      (acc, c) => acc + (c.superficieHa ?? 0),
    );
    final restant = (parcelle.superficieHa ?? 0) - totalCultures;
    if (!context.mounted) return;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ParcelleAjouterCultureSheet(
        parcelleId: parcelle.id,
        produits: data.produitsById.values.toList(growable: false),
        superficieRestanteHa: restant > 0 ? restant : null,
      ),
    );
    if (saved == true) {
      onCultureAjoutee();
    }
  }
}
