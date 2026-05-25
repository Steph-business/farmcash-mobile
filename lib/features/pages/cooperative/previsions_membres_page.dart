import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/prevision.dart';
import '../../../models/produit.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/cooperative/publications/bouton_sticky_previsions.dart';
import '../../widgets/cooperative/publications/corps_previsions.dart';
import '../../widgets/cooperative/publications/entete_previsions.dart';
import '../../widgets/cooperative/publications/etat_vide_previsions.dart';
import '../../widgets/cooperative/publications/filtres_previsions.dart';
import '../../widgets/cooperative/publications/groupe_prevision_card_model.dart';
import '../../widgets/cooperative/publications/sous_entete_previsions.dart';

/// Récupère les prévisions des membres assignées à la coop, puis les
/// agrège par produit côté client (l'agrégation n'est pas exposée en V1
/// côté back).
final _previsionsGroupsProvider =
    FutureProvider.autoDispose<List<GroupePrevisionCardModel>>((ref) async {
  final coop = ref.read(cooperativesServiceProvider);
  final market = ref.read(marketplaceServiceProvider);
  final results = await Future.wait<dynamic>([
    coop
        .listAssignedPrevisions()
        .then<Object?>((v) => v)
        .catchError((_) => const <Prevision>[]),
    market
        .listProduits()
        .then<Object?>((v) => v)
        .catchError((_) => const <Produit>[]),
  ]);
  final previsions = results[0] as List<Prevision>;
  final produits = results[1] as List<Produit>;
  final produitsParId = <String, Produit>{
    for (final p in produits) p.id: p,
  };
  return _aggregateByProduit(previsions, produitsParId);
});

/// Regroupe les prévisions par `produit_id` pour calculer les cumuls et
/// fenêtres de livraison utilisables côté coop.
List<GroupePrevisionCardModel> _aggregateByProduit(
  List<Prevision> previsions,
  Map<String, Produit> produitsParId,
) {
  final map = <String, List<Prevision>>{};
  for (final p in previsions) {
    map.putIfAbsent(p.produitId, () => <Prevision>[]).add(p);
  }
  final df = DateFormat('d MMM', 'fr_FR');
  return map.entries.map((entry) {
    final group = entry.value;
    final cumul = group.fold<double>(0, (s, p) => s + p.quantitePrevKg);
    final dates = group
        .map((p) => p.dateRecoltePrev)
        .whereType<DateTime>()
        .toList();
    dates.sort();
    final fenetre = dates.isEmpty
        ? 'À planifier'
        : (dates.length == 1
            ? df.format(dates.first)
            : '${df.format(dates.first)} – ${df.format(dates.last)}');
    // Seuils côté UI : 1 fournisseur = manque, < 7j = délai court, sinon ok.
    StatutChipPrevision chip = StatutChipPrevision.agregeable;
    if (group.length < 2) {
      chip = StatutChipPrevision.minFournisseurs;
    } else if (dates.isNotEmpty &&
        dates.first.difference(DateTime.now()).inDays < 7) {
      chip = StatutChipPrevision.delaiCourt;
    }
    return GroupePrevisionCardModel(
      produit: produitsParId[entry.key]?.nom ?? 'Produit',
      icon: Icons.eco_outlined,
      nbPrev: group.length,
      cumulKg: cumul.round(),
      fenetreLivraison: fenetre,
      chipStatus: chip,
    );
  }).toList(growable: false);
}

/// Prévisions agrégées par produit des membres de la coopérative.
/// Permet à la coop d'évaluer ce qui est "prêt à agréger" et de pousser
/// vers la publication marché.
class PrevisionsMembresPage extends ConsumerStatefulWidget {
  const PrevisionsMembresPage({super.key});

  @override
  ConsumerState<PrevisionsMembresPage> createState() =>
      _PrevisionsMembresPageState();
}

class _PrevisionsMembresPageState
    extends ConsumerState<PrevisionsMembresPage> {
  String _filtre = 'Tous';

  static const List<String> _filtres = [
    'Tous',
    'Maïs',
    'Manioc',
    'Tomate',
    'Banane plantain',
  ];

  void _onAgreger() {
    Snackbars.showInfo(
      context,
      'Agrégation Manioc → publication marché — à venir',
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_previsionsGroupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePrevisions(),
            const SousEntetePrevisions(),
            FiltresPrevisions(
              filtres: _filtres,
              selected: _filtre,
              onSelected: (f) => setState(() => _filtre = f),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: Center(
                    child: Text(
                      'Impossible de charger les prévisions. $e',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (groups) => groups.isEmpty
                    ? const EtatVidePrevisions()
                    : CorpsPrevisions(groups: _filtered(groups, _filtre)),
              ),
            ),
            BoutonStickyPrevisions(onTap: _onAgreger),
          ],
        ),
      ),
    );
  }

  static List<GroupePrevisionCardModel> _filtered(
    List<GroupePrevisionCardModel> all,
    String f,
  ) {
    if (f == 'Tous') return all;
    return all.where((g) => g.produit.toLowerCase().contains(
              f.toLowerCase().split(' ').first,
            )).toList();
  }
}
