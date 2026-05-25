import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/annonce_achat.dart';
import '../../../../services/providers.dart';
import '../../../state/auth_state.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/acheteur/demandes/corps_mes_demandes.dart';
import '../../../widgets/acheteur/demandes/header_mes_demandes.dart';
import '../../../widgets/acheteur/demandes/modele_demande_affichage.dart';
import '../../../widgets/acheteur/demandes/onglets_mes_demandes.dart';
import '../../../widgets/communs/chargement.dart';

// ─── Photos auto par produit ───────────────────────────────────────────

const String _kMaisThumb =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';
const String _kManiocThumb =
    'https://images.unsplash.com/photo-1574484284002-952d92456975?w=200&h=200&fit=crop&auto=format';
const String _kTomateThumb =
    'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=200&h=200&fit=crop&auto=format';
const String _kBananeThumb =
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=200&h=200&fit=crop&auto=format';

String _thumbForProduit(String produitNom) {
  final n = produitNom.toLowerCase();
  if (n.contains('manioc')) return _kManiocThumb;
  if (n.contains('tomate')) return _kTomateThumb;
  if (n.contains('banane') || n.contains('plantain')) return _kBananeThumb;
  return _kMaisThumb;
}

ModeleDemandeAffichage _annonceAchatToMock(AnnonceAchat a) {
  final produit = a.titre ?? 'Produit';
  return ModeleDemandeAffichage(
    id: a.id,
    produitNom: produit,
    quantite: '${a.quantiteKg.toStringAsFixed(0)} kg',
    prixMaxLabel: 'max ${a.prixMaxKg.toStringAsFixed(0)} F/kg',
    villeLabel: a.regionId ?? '—',
    propositions: 0,
    publieIlYa: 'publiée récemment',
    photoUrl: _thumbForProduit(produit),
  );
}

final _mesDemandesProvider =
    FutureProvider.autoDispose<List<ModeleDemandeAffichage>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final p = await ref.read(marketplaceServiceProvider).listAnnoncesAchat();
  // Côté buyer : on filtre pour ne garder que les demandes de l'utilisateur.
  final mes = user == null
      ? p.data
      : p.data.where((a) => a.buyerId == user.id).toList();
  return mes.map(_annonceAchatToMock).toList(growable: false);
});

/// Liste des demandes d'achat publiées par l'acheteur connecté.
/// Calque sur `mockups/acheteur/mes_demandes.html`.
class MesDemandesAcheteurPage extends ConsumerStatefulWidget {
  const MesDemandesAcheteurPage({super.key});

  @override
  ConsumerState<MesDemandesAcheteurPage> createState() =>
      _MesDemandesAcheteurPageState();
}

class _MesDemandesAcheteurPageState
    extends ConsumerState<MesDemandesAcheteurPage> {
  OngletMesDemandes _tab = OngletMesDemandes.actives;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_mesDemandesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderMesDemandes(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: Center(
                    child: Text(
                      'Impossible de charger les demandes. $e',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                data: (items) => CorpsMesDemandes(
                  items: items,
                  tab: _tab,
                  onTabChange: (t) => setState(() => _tab = t),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
