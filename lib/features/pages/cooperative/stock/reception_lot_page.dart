import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/produit.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/produit/selecteur_choix_premium.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/cooperative/stock/bouton_sticky_lot.dart';
import '../../../widgets/cooperative/stock/champ_date_lot.dart';
import '../../../widgets/cooperative/stock/champ_unite_lot.dart';
import '../../../widgets/cooperative/stock/chip_lot.dart';
import '../../../widgets/cooperative/stock/entete_reception_lot.dart';
import '../../../widgets/cooperative/stock/etiquette_champ_lot.dart';
import '../../../widgets/cooperative/stock/titre_section_lot.dart';

/// Sources possibles → mappées sur le champ `type` du lot.
/// COLLECTE = livraison farmer, ACHAT_EXTERNE = achat direct hors coop.
const List<({String label, String apiType})> _kSources = [
  (label: 'Depuis une livraison farmer', apiType: 'COLLECTE'),
  (label: 'Lot externe (achat direct)', apiType: 'ACHAT_EXTERNE'),
];

const List<({String label, ProductQuality api})> _kQualites = [
  (label: 'Standard', api: ProductQuality.standard),
  (label: 'Premium', api: ProductQuality.premium),
  (label: 'Bio', api: ProductQuality.bio),
  (label: 'Équitable', api: ProductQuality.equitable),
];

/// Provider qui charge la liste des produits pour le sélecteur.
final _produitsProvider = FutureProvider.autoDispose<List<Produit>>((ref) {
  return ref.read(marketplaceServiceProvider).listProduits();
});

/// Formulaire de réception d'un nouveau lot dans un entrepôt.
class ReceptionLotPage extends ConsumerStatefulWidget {
  const ReceptionLotPage({super.key});

  @override
  ConsumerState<ReceptionLotPage> createState() => _ReceptionLotPageState();
}

class _ReceptionLotPageState extends ConsumerState<ReceptionLotPage> {
  final TextEditingController _qteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  int _sourceIndex = 0;
  int _qualiteIndex = 0;
  Produit? _produit;
  bool _busy = false;

  @override
  void dispose() {
    _qteCtrl.dispose();
    super.dispose();
  }

  String get _dateLabel {
    const moisPlein = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${_date.day} ${moisPlein[_date.month - 1]} ${_date.year}';
  }

  Future<void> _pickDate() async {
    final res = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 1),
      lastDate: DateTime(_date.year + 1),
    );
    if (res != null && mounted) {
      setState(() => _date = res);
    }
  }

  Future<void> _enregistrer() async {
    if (_busy) return;
    final user = ref.read(currentUserProvider);
    final coopId = user?.cooperativeId;
    final produit = _produit;
    final quantiteText = _qteCtrl.text.replaceAll(',', '.').trim();
    final quantite = double.tryParse(quantiteText);

    if (produit == null) {
      Snackbars.showErreur(context, 'Choisissez un produit');
      return;
    }
    if (quantite == null || quantite <= 0) {
      Snackbars.showErreur(context, 'Quantité invalide');
      return;
    }
    if (coopId == null || coopId.isEmpty) {
      Snackbars.showErreur(
        context,
        "Aucune coopérative liée à votre compte",
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final source = _kSources[_sourceIndex];
      // Génération d'un code lot lisible : préfixe COOP/IND + date + suffixe
      // aléatoire court. Le backend exige `lot_code` (3..30 chars).
      final now = DateTime.now();
      final prefix = source.apiType == 'COOPERATIVE' ? 'COOP' : 'IND';
      final stamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 10000}';
      final lotCode = '$prefix-$stamp';
      await ref.read(marketplaceServiceProvider).createLot(
            lotCode: lotCode,
            type: source.apiType,
            produitId: produit.id,
            quantiteKg: quantite,
            qualite: _kQualites[_qualiteIndex].api,
            dateRecolte: _date,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Lot enregistré');
      if (context.canPop()) context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncProduits = ref.watch(_produitsProvider);
    final produits = asyncProduits.value ?? const <Produit>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EnteteReceptionLot(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  const TitreSectionLot('Source du lot'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < _kSources.length; i++)
                        ChipLot(
                          label: _kSources[i].label,
                          active: _sourceIndex == i,
                          onTap: () => setState(() => _sourceIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const TitreSectionLot('Détails du lot'),
                  const SizedBox(height: 12),
                  const EtiquetteChampLot('Produit'),
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 14),
                  const EtiquetteChampLot('Quantité réceptionnée'),
                  const SizedBox(height: 6),
                  ChampUniteLot(
                    controller: _qteCtrl,
                    unit: 'kg',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    placeholder: '0',
                  ),
                  const SizedBox(height: 14),
                  const EtiquetteChampLot('Qualité'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < _kQualites.length; i++)
                        ChipLot(
                          label: _kQualites[i].label,
                          active: _qualiteIndex == i,
                          onTap: () => setState(() => _qualiteIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const EtiquetteChampLot('Date de récolte'),
                  const SizedBox(height: 6),
                  ChampDateLot(
                    label: _dateLabel,
                    onTap: _busy ? null : _pickDate,
                  ),
                ],
              ),
            ),
            BoutonStickyLot(onTap: _enregistrer, busy: _busy),
          ],
        ),
      ),
    );
  }
}
