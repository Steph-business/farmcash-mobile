import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/models.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../widgets/acheteur/profil/bouton_ajouter_adresse.dart';
import '../../widgets/acheteur/profil/carte_adresse_livraison.dart';
import '../../widgets/acheteur/profil/etat_vide_adresses.dart';
import '../../widgets/acheteur/profil/feuille_ajout_adresse.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/entete_page_standard.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

final _addressesProvider =
    FutureProvider.autoDispose<List<BuyerAddress>>((ref) async {
  return ref.read(buyerServiceProvider).listAddresses();
});

/// Page Adresses de livraison — liste des adresses enregistrées de l'acheteur.
///
/// Branche sur `BuyerService` (CRUD côté backend). Toutes les actions
/// invalident le provider pour rafraîchir la liste.
class AdressesLivraisonAcheteurPage extends ConsumerStatefulWidget {
  const AdressesLivraisonAcheteurPage({super.key});

  @override
  ConsumerState<AdressesLivraisonAcheteurPage> createState() =>
      _AdressesLivraisonAcheteurPageState();
}

class _AdressesLivraisonAcheteurPageState
    extends ConsumerState<AdressesLivraisonAcheteurPage> {
  String? _operationEnCours;

  Future<void> _refresh() async {
    ref.invalidate(_addressesProvider);
    await ref.read(_addressesProvider.future);
  }

  Future<void> _definirParDefaut(BuyerAddress a) async {
    if (_operationEnCours != null) return;
    setState(() => _operationEnCours = a.id);
    try {
      await ref
          .read(buyerServiceProvider)
          .updateAddress(a.id, isDefault: true);
      await _refresh();
      if (!mounted) return;
      Snackbars.showSucces(context, '${a.libelle} définie par défaut');
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _operationEnCours = null);
    }
  }

  Future<void> _supprimer(BuyerAddress a) async {
    if (_operationEnCours != null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'adresse'),
        content: Text('Supprimer « ${a.libelle} » ? Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _operationEnCours = a.id);
    try {
      await ref.read(buyerServiceProvider).deleteAddress(a.id);
      await _refresh();
      if (!mounted) return;
      Snackbars.showInfo(context, '${a.libelle} supprimée');
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _operationEnCours = null);
    }
  }

  Future<void> _ajouterAdresse() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => const FeuilleAjoutAdresse(),
    );
    if (created == true) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_addressesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Adresses de livraison'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les adresses. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (adresses) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refresh,
                  child: adresses.isEmpty
                      ? ListView(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          children: [
                            const SizedBox(height: 32),
                            const EtatVideAdresses(),
                            const SizedBox(height: 24),
                            BoutonAjouterAdresse(onTap: _ajouterAdresse),
                          ],
                        )
                      : ListView(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          children: [
                            ...adresses.map(
                              (a) => CarteAdresseLivraison(
                                adresse: a,
                                busy: _operationEnCours == a.id,
                                onDefinirParDefaut: () =>
                                    _definirParDefaut(a),
                                onSupprimer: () => _supprimer(a),
                              ),
                            ),
                            const SizedBox(height: 4),
                            BoutonAjouterAdresse(onTap: _ajouterAdresse),
                          ],
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
