import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/produit.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/produit/selecteur_choix_premium.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/cooperative/membres/bouton_sticky_enregistrer_managed.dart';
import '../../../widgets/cooperative/membres/carte_info_managed.dart';
import '../../../widgets/cooperative/membres/champ_texte_managed.dart';
import '../../../widgets/cooperative/membres/entete_enregistrer_managed.dart';
import '../../../widgets/cooperative/membres/libelle_champ_managed.dart';

/// Catalogue produit — utilisé par le sélecteur. Best effort : si
/// l'endpoint échoue, le selecteur affichera simplement "indisponible".
final _produitsManagedProvider =
    FutureProvider.autoDispose<List<Produit>>((ref) async {
  try {
    return await ref.read(marketplaceServiceProvider).listProduits();
  } catch (_) {
    return const <Produit>[];
  }
});

/// Page d'enregistrement d'un farmer **géré** par la coopérative.
///
/// Cas d'usage : la coop saisit en présentiel un producteur sans
/// smartphone. Aucun OTP envoyé. La coop publiera ensuite les annonces
/// de ce farmer via `act_as_farmer_id` côté backend.
///
/// La page est en composition seule — toute la logique d'UI vit dans
/// `widgets/cooperative/membres/` (règle stricte).
class EnregistrerManagedPage extends ConsumerStatefulWidget {
  const EnregistrerManagedPage({super.key});

  @override
  ConsumerState<EnregistrerManagedPage> createState() =>
      _EnregistrerManagedPageState();
}

class _EnregistrerManagedPageState
    extends ConsumerState<EnregistrerManagedPage> {
  final _nomCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  Produit? _produit;
  // L'upload de photo est volontairement omis pour cette MVP — l'URL
  // peut être ajoutée plus tard depuis la fiche du membre.
  bool _busy = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _villageCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (_busy) return;
    final nom = _nomCtrl.text.trim();
    if (nom.length < 2) {
      Snackbars.showErreur(
        context,
        'Le nom complet doit faire au moins 2 caractères.',
      );
      return;
    }
    final village = _villageCtrl.text.trim();
    setState(() => _busy = true);
    try {
      final membre = await ref
          .read(cooperativesServiceProvider)
          .createManagedMember(
            fullName: nom,
            village: village.isEmpty ? null : village,
            defaultProductId: _produit?.id,
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Membre « ${membre.fullName ?? nom} » enregistré.',
      );
      if (context.canPop()) {
        context.pop(true);
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncProduits = ref.watch(_produitsManagedProvider);
    final produits = asyncProduits.value ?? const <Produit>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteEnregistrerManaged(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  const CarteInfoManaged(),
                  AppDimens.vGap24,
                  const LibelleChampManaged('Nom complet'),
                  AppDimens.vGap8,
                  ChampTexteManaged(
                    controller: _nomCtrl,
                    placeholder: 'Ex : Kouassi Adjoa',
                    enabled: !_busy,
                  ),
                  AppDimens.vGap16,
                  const LibelleChampManaged('Village (optionnel)'),
                  AppDimens.vGap8,
                  ChampTexteManaged(
                    controller: _villageCtrl,
                    placeholder: 'Ex : Yamoussoukro',
                    enabled: !_busy,
                  ),
                  AppDimens.vGap16,
                  const LibelleChampManaged('Produit principal (optionnel)'),
                  AppDimens.vGap8,
                  SelecteurChoixPremium<Produit>(
                    items: produits,
                    itemActuel: _produit,
                    onChanged: (p) => setState(() => _produit = p),
                    titreOf: (p) => p.nom,
                    sousTitreOf: (p) => 'Catalogue · ${p.slug}',
                    idOf: (p) => p.id,
                    placeholder: 'Choisir un produit',
                    titreSheet: 'Choisis le produit',
                    enabled: !_busy,
                  ),
                ],
              ),
            ),
            BoutonStickyEnregistrerManaged(
              busy: _busy,
              onTap: _enregistrer,
            ),
          ],
        ),
      ),
    );
  }
}
