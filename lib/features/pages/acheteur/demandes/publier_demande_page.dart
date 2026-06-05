import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/produit.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../widgets/acheteur/demandes/champ_date_demande.dart';
import '../../../widgets/acheteur/demandes/chips_qualite_demande.dart';
import '../../../widgets/acheteur/demandes/dropdown_coop_demande.dart';
import '../../../widgets/acheteur/demandes/header_publier_demande.dart';
import '../../../widgets/acheteur/demandes/hero_photo_demande.dart';
import '../../../widgets/acheteur/demandes/input_unite_demande.dart';
import '../../../widgets/acheteur/demandes/publier_demande_constants.dart';
import '../../../widgets/acheteur/demandes/sticky_publier_demande.dart';
import '../../../widgets/acheteur/demandes/titre_section_demande.dart';
import '../../../widgets/acheteur/demandes/tuile_cible_demande.dart';
// Sélecteur produit générique partagé (cohérence cross-acteurs).
import '../../../widgets/communs/produit/selecteur_choix_premium.dart';
import '../../../widgets/communs/snackbars.dart';

/// Transforme un `Produit` backend en `PublierDemandeProduitOption`
/// avec une heuristique sur le nom pour choisir une photo de qualité.
PublierDemandeProduitOption _toProduitOption(Produit p) {
  final lower = p.nom.toLowerCase();
  String photo;
  if (lower.contains('manioc')) {
    photo = kPublierDemandeManiocPhoto;
  } else if (lower.contains('tomate')) {
    photo = kPublierDemandeTomatePhoto;
  } else {
    photo = p.imageUrl ?? kPublierDemandeMaisPhoto;
  }
  return PublierDemandeProduitOption(id: p.id, nom: p.nom, photoUrl: photo);
}

/// Charge le catalogue produits une seule fois.
final _produitsOptionsProvider = FutureProvider.autoDispose<
    List<PublierDemandeProduitOption>>((ref) async {
  final list = await ref.read(marketplaceServiceProvider).listProduits();
  return list.map(_toProduitOption).toList(growable: false);
});

/// Charge le référentiel villes (avec leur `region_id`) — utilisé pour
/// dériver une région obligatoire à passer au backend.
final _villesProvider = FutureProvider.autoDispose((ref) {
  return ref.read(marketplaceServiceProvider).listVilles();
});

/// Publier une demande d'achat — calque sur la maquette
/// `mockups/acheteur/publier_demande.html`.
class PublierDemandePage extends ConsumerStatefulWidget {
  const PublierDemandePage({super.key});

  @override
  ConsumerState<PublierDemandePage> createState() => _PublierDemandePageState();
}

class _PublierDemandePageState extends ConsumerState<PublierDemandePage> {
  PublierDemandeProduitOption? _produit;
  String _qualite = kPublierDemandeQualites.first;
  final _qteCtrl = TextEditingController(text: '500');
  final _prixCtrl = TextEditingController(text: '850');
  // `_dateLimite` reste dans l'UI pour gérer le futur ajout serveur,
  // mais n'est plus envoyée — le backend ne le supporte pas.
  DateTime _dateLimite = DateTime.now().add(const Duration(days: 14));
  PublierDemandeCible _cible = PublierDemandeCible.public;
  PublierDemandeCoopOption? _coopChoisie;
  // Région choisie par l'acheteur (requise côté backend).
  String? _regionId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _qteCtrl.dispose();
    _prixCtrl.dispose();
    super.dispose();
  }

  Future<void> _ouvrirDatePicker() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _dateLimite.isBefore(now) ? now : _dateLimite,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (result != null) {
      setState(() => _dateLimite = result);
    }
  }

  BuyOfferAudience get _audienceApi {
    switch (_cible) {
      case PublierDemandeCible.public:
        return BuyOfferAudience.public;
      case PublierDemandeCible.allCoops:
        return BuyOfferAudience.allCooperatives;
      case PublierDemandeCible.specificCoop:
        return BuyOfferAudience.specificCooperative;
    }
  }

  Future<void> _publier() async {
    if (_isSubmitting) return;
    if (_produit == null) {
      Snackbars.showErreur(context, 'Choisis un produit avant de publier.');
      return;
    }
    final qte = double.tryParse(_qteCtrl.text.trim().replaceAll(',', '.'));
    final prix = double.tryParse(_prixCtrl.text.trim().replaceAll(',', '.'));
    if (qte == null || qte <= 0 || prix == null || prix <= 0) {
      Snackbars.showErreur(
        context,
        'Indique une quantité et un prix max valides.',
      );
      return;
    }
    // Région requise par le backend. Si l'utilisateur n'a pas choisi,
    // on prend la région de la première ville du référentiel comme
    // fallback documenté (l'UI prévue ajoutera une étape sélection).
    var regionId = _regionId;
    if (regionId == null) {
      final villes = ref.read(_villesProvider).value;
      if (villes != null && villes.isNotEmpty) {
        regionId = villes.first.regionId;
      }
    }
    if (regionId == null) {
      Snackbars.showErreur(
        context,
        'Choisis une région avant de publier ta demande.',
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(marketplaceServiceProvider).createAnnonceAchat(
            produitId: _produit!.id,
            quantiteKg: qte,
            regionId: regionId,
            prixMaxKg: prix,
            audience: _audienceApi,
            targetCooperativeId: _cible == PublierDemandeCible.specificCoop
                ? _coopChoisie?.id
                : null,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Demande publiée — propositions à venir.');
      Navigator.of(context).maybePop();
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncProduits = ref.watch(_produitsOptionsProvider);
    final produits =
        asyncProduits.value ?? const <PublierDemandeProduitOption>[];
    // Initialise la sélection au premier produit dès qu'on a la liste.
    if (_produit == null && produits.isNotEmpty) {
      _produit = produits.first;
    }
    final produit = _produit;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderPublierDemande(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                children: [
                  const TitreSectionDemande(title: 'Que cherches-tu ?'),
                  AppDimens.vGap12,
                  SelecteurChoixPremium<PublierDemandeProduitOption>(
                    items: produits,
                    itemActuel: produit,
                    onChanged: (p) => setState(() => _produit = p),
                    titreOf: (p) => p.nom,
                    idOf: (p) => p.id,
                    placeholder: 'Choisir un produit',
                    titreSheet: 'Choisis ton produit',
                  ),
                  AppDimens.vGap12,
                  if (produit != null) HeroPhotoDemande(photoUrl: produit.photoUrl),
                  AppDimens.vGap12,
                  const SousLabelDemande(label: 'Qualité'),
                  const SizedBox(height: 8),
                  ChipsQualiteDemande(
                    selected: _qualite,
                    onChange: (q) => setState(() => _qualite = q),
                  ),
                  AppDimens.vGap24,
                  const TitreSectionDemande(title: 'Quantité & prix'),
                  AppDimens.vGap12,
                  const SousLabelDemande(label: 'Quantité voulue'),
                  const SizedBox(height: 6),
                  InputUniteDemande(
                    controller: _qteCtrl,
                    unit: 'kg',
                    enabled: !_isSubmitting,
                  ),
                  AppDimens.vGap16,
                  const SousLabelDemande(label: 'Prix max accepté'),
                  const SizedBox(height: 6),
                  InputUniteDemande(
                    controller: _prixCtrl,
                    unit: 'F/kg',
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 6),
                  const TexteAideDemande(
                    text:
                        'Indication marché : Maïs blanc se négocie entre 750 et 900 F/kg',
                  ),
                  AppDimens.vGap24,
                  const TitreSectionDemande(title: 'Date limite de livraison'),
                  AppDimens.vGap12,
                  ChampDateDemande(
                    date: _dateLimite,
                    onTap: _ouvrirDatePicker,
                  ),
                  AppDimens.vGap24,
                  const TitreSectionDemande(
                    title: 'À qui s\'adresse ta demande ?',
                  ),
                  AppDimens.vGap12,
                  TuileCibleDemande(
                    emoji: '🌍',
                    label: 'Public (tous les producteurs)',
                    selected: _cible == PublierDemandeCible.public,
                    onTap: () =>
                        setState(() => _cible = PublierDemandeCible.public),
                  ),
                  const SizedBox(height: 8),
                  TuileCibleDemande(
                    emoji: '🤝',
                    label: 'Toutes les coopératives',
                    selected: _cible == PublierDemandeCible.allCoops,
                    onTap: () =>
                        setState(() => _cible = PublierDemandeCible.allCoops),
                  ),
                  const SizedBox(height: 8),
                  TuileCibleDemande(
                    emoji: '📌',
                    label: 'Une coopérative spécifique',
                    selected: _cible == PublierDemandeCible.specificCoop,
                    onTap: () => setState(
                      () => _cible = PublierDemandeCible.specificCoop,
                    ),
                  ),
                  if (_cible == PublierDemandeCible.specificCoop) ...[
                    const SizedBox(height: 10),
                    DropdownCoopDemande(
                      value: _coopChoisie,
                      onChange: (c) => setState(() => _coopChoisie = c),
                    ),
                  ],
                  AppDimens.vGap16,
                ],
              ),
            ),
            StickyPublierDemande(
              isSubmitting: _isSubmitting,
              onPublier: _publier,
            ),
          ],
        ),
      ),
    );
  }
}
