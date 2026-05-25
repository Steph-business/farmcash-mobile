import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/produit.dart';
import '../../../../models/ville.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/cooperative/publications/bouton_sticky_publication.dart';
import '../../../widgets/cooperative/publications/champ_grand_publication.dart';
import '../../../widgets/cooperative/publications/champ_multiligne_publication.dart';
import '../../../widgets/cooperative/publications/champ_titre_publication.dart';
import '../../../widgets/cooperative/publications/chip_qualite_publication.dart';
import '../../../widgets/cooperative/publications/entete_publication_creer.dart';
import '../../../widgets/cooperative/publications/feuille_choix_produit.dart';
import '../../../widgets/cooperative/publications/libelle_section_publication.dart';
import '../../../widgets/cooperative/publications/selecteur_produit_publication.dart';

/// Bundle de chargement : catalogue produits (pour le dropdown).
final _publicationBundleProvider =
    FutureProvider.autoDispose<List<Produit>>((ref) async {
  try {
    return await ref.read(marketplaceServiceProvider).listProduits();
  } catch (_) {
    return const <Produit>[];
  }
});

/// Liste des villes — utilisée pour dériver `region_id` + `ville_id`
/// requis par `CreatePublicationCoopDto`.
final _villesProvider = FutureProvider.autoDispose<List<Ville>>((ref) {
  return ref.read(marketplaceServiceProvider).listVilles();
});

/// Création d'une publication coopérative — formulaire complet branché sur
/// `coopService.createPublication`. La publication est ensuite visible
/// côté marketplace acheteur (`PublicationCoop`).
class PublicationCreerPage extends ConsumerStatefulWidget {
  const PublicationCreerPage({super.key});

  @override
  ConsumerState<PublicationCreerPage> createState() =>
      _PublicationCreerPageState();
}

class _PublicationCreerPageState extends ConsumerState<PublicationCreerPage> {
  final _titreCtrl = TextEditingController();
  final _quantiteCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  Produit? _produit;
  ProductQuality _qualite = ProductQuality.standard;
  bool _busy = false;

  static const List<ProductQuality> _qualites = [
    ProductQuality.standard,
    ProductQuality.premium,
    ProductQuality.bio,
    ProductQuality.equitable,
  ];

  @override
  void dispose() {
    _titreCtrl.dispose();
    _quantiteCtrl.dispose();
    _prixCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _choisirProduit(List<Produit> produits) async {
    if (produits.isEmpty) {
      Snackbars.showInfo(context, 'Catalogue produit indisponible');
      return;
    }
    final selected = await showModalBottomSheet<Produit>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => FeuilleChoixProduit(
        produits: produits,
        selectedId: _produit?.id,
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        _produit = selected;
        if (_titreCtrl.text.trim().isEmpty) {
          _titreCtrl.text = selected.nom;
        }
      });
    }
  }

  Future<void> _publier() async {
    if (_busy) return;
    if (_produit == null) {
      Snackbars.showErreur(context, 'Choisis un produit.');
      return;
    }
    final qte = double.tryParse(_quantiteCtrl.text.replaceAll(',', '.'));
    final prix = double.tryParse(_prixCtrl.text.replaceAll(',', '.'));
    if (qte == null || qte <= 0) {
      Snackbars.showErreur(context, 'Quantité (kg) invalide.');
      return;
    }
    if (prix == null || prix <= 0) {
      Snackbars.showErreur(context, 'Prix au kg invalide.');
      return;
    }
    // Région/ville requises par le backend. On prend la première ville
    // du référentiel comme fallback documenté — l'écran prévu pourra
    // ajouter un picker de ville pour la coop.
    // TODO(geoloc): brancher un picker ville + Geolocator pour les coords.
    final villes = ref.read(_villesProvider).value;
    if (villes == null || villes.isEmpty) {
      Snackbars.showErreur(context, 'Référentiel villes indisponible.');
      return;
    }
    final ville = villes.first;
    setState(() => _busy = true);
    try {
      await ref.read(cooperativesServiceProvider).createPublication(
            produitId: _produit!.id,
            quantiteKg: qte,
            prixParKg: prix,
            qualite: _qualite,
            regionId: ville.regionId,
            villeId: ville.id,
            lat: 5.345317,
            lng: -4.024429,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Publication créée et visible sur le marché.');
      if (context.canPop()) {
        context.pop(true);
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncProduits = ref.watch(_publicationBundleProvider);
    // Pré-charge la liste des villes pour pouvoir dériver region_id +
    // ville_id à la soumission (requis par le backend).
    ref.watch(_villesProvider);
    final produits = asyncProduits.value ?? const <Produit>[];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePublicationCreer(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  const LibelleSectionPublication(label: 'Produit à publier'),
                  AppDimens.vGap8,
                  SelecteurProduitPublication(
                    produit: _produit,
                    onTap: () => _choisirProduit(produits),
                  ),
                  AppDimens.vGap24,
                  const LibelleSectionPublication(label: 'Titre de l\'annonce'),
                  AppDimens.vGap8,
                  ChampTitrePublication(controller: _titreCtrl, enabled: !_busy),
                  AppDimens.vGap24,
                  const LibelleSectionPublication(label: 'Quantité à publier'),
                  AppDimens.vGap8,
                  ChampGrandPublication(
                    controller: _quantiteCtrl,
                    suffix: 'kg',
                    hint: 'Ex : 500',
                    enabled: !_busy,
                  ),
                  AppDimens.vGap24,
                  const LibelleSectionPublication(label: 'Prix par kg'),
                  AppDimens.vGap8,
                  ChampGrandPublication(
                    controller: _prixCtrl,
                    suffix: 'F CFA / kg',
                    hint: 'Ex : 350',
                    enabled: !_busy,
                  ),
                  AppDimens.vGap24,
                  const LibelleSectionPublication(label: 'Qualité'),
                  AppDimens.vGap8,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_qualites.length, (i) {
                      final q = _qualites[i];
                      return ChipQualitePublication(
                        label: _qualiteLabel(q),
                        selected: _qualite == q,
                        onTap: () => setState(() => _qualite = q),
                      );
                    }),
                  ),
                  AppDimens.vGap24,
                  const LibelleSectionPublication(
                    label: 'Description (optionnelle)',
                  ),
                  AppDimens.vGap8,
                  ChampMultilignePublication(
                    controller: _descriptionCtrl,
                    enabled: !_busy,
                    placeholder:
                        'Conditions de stockage, dates de récolte, etc.',
                  ),
                ],
              ),
            ),
            BoutonStickyPublication(busy: _busy, onTap: _publier),
          ],
        ),
      ),
    );
  }
}

String _qualiteLabel(ProductQuality q) {
  switch (q) {
    case ProductQuality.standard:
      return 'Standard';
    case ProductQuality.premium:
      return 'Premium';
    case ProductQuality.bio:
      return 'Bio';
    case ProductQuality.equitable:
      return 'Équitable';
    case ProductQuality.unknown:
      return 'Standard';
  }
}
