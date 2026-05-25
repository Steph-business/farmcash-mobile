import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/parcelle.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/chargement.dart';
import 'btn_lancer_analyse.dart';
import 'hero_analyse_plante.dart';
import 'historique_court_analyses.dart';
import 'notes_field_analyse.dart';
import 'parcelle_dropdown.dart';

/// Parcelles du farmer pour le dropdown — fail silencieusement à liste vide
/// (un farmer sans parcelles doit pouvoir analyser quand même).
final _parcellesPourAnalyseAiProvider =
    FutureProvider.autoDispose<List<Parcelle>>((ref) async {
  try {
    return await ref.watch(marketplaceServiceProvider).listParcelles();
  } catch (_) {
    return const <Parcelle>[];
  }
});

/// Phase 1 du flow diagnostic : sélection photo + champs optionnels
/// (parcelle, notes) + bouton "Lancer l'analyse". Affiche aussi l'historique
/// court (5 dernières analyses) en bas de page.
class SaisieViewAnalyse extends ConsumerWidget {
  const SaisieViewAnalyse({
    required this.photo,
    required this.parcelleId,
    required this.notesCtrl,
    required this.isAnalyzing,
    required this.onPickPhoto,
    required this.onChangeParcelle,
    required this.onLancer,
    super.key,
  });

  final File? photo;
  final String? parcelleId;
  final TextEditingController notesCtrl;
  final bool isAnalyzing;
  final VoidCallback onPickPhoto;
  final ValueChanged<String?> onChangeParcelle;
  final VoidCallback onLancer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcellesAsync = ref.watch(_parcellesPourAnalyseAiProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space24,
      ),
      children: [
        HeroAnalysePlante(photo: photo, onTap: onPickPhoto),
        if (photo != null) ...[
          AppDimens.vGap24,
          const _LabelSaisie('Parcelle (optionnel)'),
          AppDimens.vGap8,
          parcellesAsync.when(
            loading: () => const SizedBox(
              height: 50,
              child: Chargement(size: 18),
            ),
            error: (_, _) => ParcelleDropdown(
              value: null,
              parcelles: const [],
              onChanged: onChangeParcelle,
            ),
            data: (parcelles) => ParcelleDropdown(
              value: parcelleId,
              parcelles: parcelles,
              onChanged: onChangeParcelle,
            ),
          ),
          AppDimens.vGap16,
          const _LabelSaisie('Notes (optionnel)'),
          AppDimens.vGap8,
          NotesFieldAnalyse(controller: notesCtrl),
          AppDimens.vGap24,
          BtnLancerAnalyse(isAnalyzing: isAnalyzing, onTap: onLancer),
        ],
        AppDimens.vGap32,
        const HistoriqueCourtAnalyses(),
      ],
    );
  }
}

/// Petit label gris au-dessus d'un champ. Visuellement aligné aux design
/// tokens (`labelMedium` + couleur `text`).
class _LabelSaisie extends StatelessWidget {
  const _LabelSaisie(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      ),
    );
  }
}
