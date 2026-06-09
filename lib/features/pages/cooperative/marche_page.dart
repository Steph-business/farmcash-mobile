import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/communs/entete_page_compacte_coop.dart';
import '../../widgets/producteur/demandes/corps_liste_demandes_achat.dart';
import '../../widgets/producteur/demandes/demande_achat_modeles.dart';

/// Provider : demandes d'achat publiques que la coop peut couvrir avec
/// son stock ou ses publications agrégées. Réutilise l'endpoint public
/// `GET /marketplace/annonces-achat` — pas besoin d'endpoint coop dédié,
/// le marché est par nature ouvert à tous les vendeurs (producteurs +
/// coops).
final _marcheCoopProvider =
    FutureProvider.autoDispose<List<MockDemande>>((ref) async {
  final paginated =
      await ref.read(marketplaceServiceProvider).listAnnoncesAchat();
  return paginated.data.map(annonceAchatToMock).toList(growable: false);
});

/// Onglet « Marché » coopérative — refonte 2026-06-05 :
///
/// **Avant** : montrait les publications coop (= vitrine vendeur).
/// Problème : vide si la coop n'a rien publié, et le mot « Marché »
/// suggérait un vrai marché alors que c'était juste son catalogue.
///
/// **Maintenant** : montre les **demandes d'achat des acheteurs** dans
/// la zone (opportunités commerciales). La coop voit qui cherche quoi
/// et peut décider de publier un lot ou solliciter ses membres pour
/// y répondre. Symétrique au « Marché » côté producteur (cohérence
/// cross-acteurs : qui vend regarde qui achète).
///
/// Les publications coop ont été déplacées dans Stock → onglet
/// « Publications » (cf. `stock_page.dart`).
class MarcheCooperativePage extends ConsumerStatefulWidget {
  const MarcheCooperativePage({super.key});

  @override
  ConsumerState<MarcheCooperativePage> createState() =>
      _MarcheCooperativePageState();
}

class _MarcheCooperativePageState
    extends ConsumerState<MarcheCooperativePage> {
  String _activeFilter = 'all';

  List<MockDemande> _filtrer(List<MockDemande> items) {
    if (_activeFilter == 'all') return items;
    return items.where((d) {
      final n = d.produitNom.toLowerCase();
      switch (_activeFilter) {
        case 'mais':
          return n.contains('maïs') || n.contains('mais');
        case 'manioc':
          return n.contains('manioc');
        case 'tomate':
          return n.contains('tomate');
        case 'banane':
          return n.contains('banane') || n.contains('plantain');
        default:
          return true;
      }
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_marcheCoopProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header compact onglet — pas de back (onglet bottom-nav).
            const EntetePageCompacteCoop(
              title: 'Marché',
              showBack: false,
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
                      'Impossible de charger les demandes. $e',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (items) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(_marcheCoopProvider);
                    await ref.read(_marcheCoopProvider.future);
                  },
                  child: CorpsListeDemandesAchat(
                    items: _filtrer(items),
                    activeFilter: _activeFilter,
                    onFilterChange: (k) =>
                        setState(() => _activeFilter = k),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
