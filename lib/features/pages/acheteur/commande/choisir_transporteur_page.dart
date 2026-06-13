import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/models.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/commandes/args_devis_transporteur.dart';
import '../../../widgets/acheteur/commandes/carte_devis_transporteur.dart';
import '../../../widgets/acheteur/commandes/etats_vides_transporteur.dart';
import '../../../widgets/acheteur/commandes/info_trajet_transporteur.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/vue_erreur.dart';

final _quotesProvider = FutureProvider.autoDispose
    .family<List<TransportQuote>, ArgsDevisTransporteur>((ref, args) async {
  return ref.read(logisticsServiceProvider).getQuotes(
        origineZone: args.origineZone,
        destinationZone: args.destinationZone,
        quantiteKg: args.quantiteKg,
      );
});

/// Choix du transporteur depuis le flow de paiement acheteur.
///
/// Reçoit en arguments [origineZone], [destinationZone] et [quantiteKg]
/// via les `extras` de la route. Si l'un manque, on affiche un état vide
/// expliquant qu'il faut passer par le flow paiement.
class ChoisirTransporteurPage extends ConsumerWidget {
  const ChoisirTransporteurPage({
    super.key,
    this.origineZone,
    this.destinationZone,
    this.quantiteKg,
  });

  final String? origineZone;
  final String? destinationZone;
  final double? quantiteKg;

  bool get _hasArgs =>
      (origineZone?.isNotEmpty ?? false) &&
      (destinationZone?.isNotEmpty ?? false) &&
      quantiteKg != null &&
      quantiteKg! > 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Choisir mon transporteur'),
            Expanded(child: _body(context, ref)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref) {
    if (!_hasArgs) {
      return const EtatArgsManquantsTransporteur();
    }
    final args = ArgsDevisTransporteur(
      origineZone: origineZone!,
      destinationZone: destinationZone!,
      quantiteKg: quantiteKg!,
    );
    final async = ref.watch(_quotesProvider(args));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: AppDimens.space32),
        child: Chargement(size: 22),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: 'Impossible de charger les devis transport. $e',
          onRetry: () => ref.invalidate(_quotesProvider(args)),
        ),
      ),
      data: (quotes) {
        if (quotes.isEmpty) {
          return EtatAucunDevisTransporteur(args: args);
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          children: [
            InfoTrajetTransporteur(args: args),
            const SizedBox(height: 14),
            for (var i = 0; i < quotes.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CarteDevisTransporteur(
                  quote: quotes[i],
                  isBest: i == 0,
                  onChoose: () => Navigator.of(context).pop(quotes[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}
