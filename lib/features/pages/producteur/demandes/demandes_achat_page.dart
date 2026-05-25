import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/producteur/demandes/corps_liste_demandes_achat.dart';
import '../../../widgets/producteur/demandes/demande_achat_modeles.dart';
import '../../../widgets/producteur/demandes/header_demandes_achat.dart';

/// Récupère les demandes d'achat publiques depuis le backend. Pas de
/// fallback mock — si l'API renvoie vide ou échoue, l'UI affiche un état
/// vide / erreur honnête.
final _demandesProvider =
    FutureProvider.autoDispose<List<MockDemande>>((ref) async {
  final paginated =
      await ref.read(marketplaceServiceProvider).listAnnoncesAchat();
  return paginated.data.map(annonceAchatToMock).toList(growable: false);
});

/// Liste des demandes d'achat qui matchent les cultures du producteur.
class DemandesAchatPage extends ConsumerStatefulWidget {
  const DemandesAchatPage({super.key});

  @override
  ConsumerState<DemandesAchatPage> createState() => _DemandesAchatPageState();
}

class _DemandesAchatPageState extends ConsumerState<DemandesAchatPage> {
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
    final async = ref.watch(_demandesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderDemandesAchat(),
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
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (items) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(_demandesProvider);
                    await ref.read(_demandesProvider.future);
                  },
                  child: CorpsListeDemandesAchat(
                    items: _filtrer(items),
                    activeFilter: _activeFilter,
                    onFilterChange: (k) => setState(() => _activeFilter = k),
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
