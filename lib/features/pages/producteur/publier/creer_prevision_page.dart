import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/parcelle.dart';
import '../../../../models/produit.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/publier/date_picker_prevision.dart';
import '../../../widgets/producteur/publier/help_text_prevision.dart';
import '../../../widgets/producteur/publier/input_unit_prevision.dart';
import '../../../widgets/producteur/publier/intro_help_prevision.dart';
import '../../../widgets/producteur/publier/parcelle_selector_prevision.dart';
import '../../../widgets/producteur/publier/produit_selector_prevision.dart';
import '../../../widgets/producteur/publier/sticky_creer_prevision.dart';
import '../../../widgets/producteur/publier/titre_section_prevision.dart';

/// Bundle des données nécessaires au formulaire — catalogue produits +
/// parcelles du producteur (pour suggérer la parcelle source).
class _CreerPrevisionBundle {
  const _CreerPrevisionBundle({
    required this.produits,
    required this.parcelles,
  });
  final List<Produit> produits;
  final List<Parcelle> parcelles;
}

/// Charge le catalogue produit + les parcelles du producteur en parallèle.
/// Le catalogue produit est CRITIQUE (sans lui, on ne peut pas créer de
/// prévision) → on laisse l'erreur remonter. Les parcelles sont optionnelles.
final _creerPrevisionBundleProvider =
    FutureProvider.autoDispose<_CreerPrevisionBundle>((ref) async {
  final svc = ref.watch(marketplaceServiceProvider);
  final results = await Future.wait<dynamic>([
    svc.listProduits(),
    svc.listParcelles().then<Object?>((v) => v).catchError(
      (Object _) => const <Parcelle>[],
    ),
  ]);
  return _CreerPrevisionBundle(
    produits: results[0] as List<Produit>,
    parcelles: results[1] as List<Parcelle>,
  );
});

/// Page de création d'une **prévision de récolte**.
///
/// Une prévision = annonce d'une récolte à venir (j-30 à j-90 typiquement).
/// Les acheteurs peuvent réserver une part avec acompte 10%, le producteur
/// la convertit en annonce de vente quand la récolte est prête.
///
/// Champs obligatoires (alignés sur `CreatePrevisionDto`) :
///   - `produit_id` : ce que je vais récolter
///   - `quantite_prev_kg` : combien j'attends
/// Optionnels mais recommandés :
///   - `date_recolte_prev` : à quelle date je pense récolter
///   - `prix_cible_kg` : à quel prix j'aimerais vendre (≠ prix final)
///   - `parcelle_id` : sur quelle parcelle (traçabilité)
class CreerPrevisionPage extends ConsumerStatefulWidget {
  const CreerPrevisionPage({super.key});

  @override
  ConsumerState<CreerPrevisionPage> createState() => _CreerPrevisionPageState();
}

class _CreerPrevisionPageState extends ConsumerState<CreerPrevisionPage> {
  String? _produitId;
  String? _parcelleId;
  final _quantiteCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  DateTime? _dateRecolte;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _quantiteCtrl.dispose();
    _prixCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_isSubmitting) return false;
    if (_produitId == null) return false;
    final qte = _parseDouble(_quantiteCtrl.text);
    if (qte == null || qte <= 0) return false;
    return true;
  }

  static double? _parseDouble(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  Future<void> _pickDate() async {
    final now = DateTime.now();
    // `firstDate` = demain (et pas aujourd'hui) car le backend rejette
    // strictement `target.getTime() <= Date.now()` → si on sélectionne
    // aujourd'hui à 8h mais qu'on submit à 9h, getTime serait dans le
    // passé. En partant de demain, on est tranquille.
    final tomorrow = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateRecolte ?? tomorrow.add(const Duration(days: 29)),
      firstDate: tomorrow,
      // Une récolte au-delà de 1 an n'a pas de sens en prévision.
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Date prévue de récolte',
    );
    if (picked != null && mounted) {
      setState(() => _dateRecolte = picked);
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    final quantite = _parseDouble(_quantiteCtrl.text)!;
    final prix = _parseDouble(_prixCtrl.text);

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final svc = ref.read(marketplaceServiceProvider);
      await svc.createPrevision(
        produitId: _produitId!,
        quantitePrevKg: quantite,
        dateRecoltePrev: _dateRecolte,
        prixCibleKg: prix,
        parcelleId: _parcelleId,
      );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Prévision créée avec succès.');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
      Snackbars.showErreur(context, e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Impossible de créer la prévision.');
      Snackbars.showErreur(context, 'Impossible de créer la prévision.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_creerPrevisionBundleProvider);
    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: AppDimens.iconL),
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Nouvelle prévision',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: async.when(
            loading: () => const Center(child: Chargement(size: 22)),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(AppDimens.pagePaddingH),
              child: VueErreur(
                message: e is ApiException
                    ? e.message
                    : 'Impossible de charger le catalogue produit.',
                onRetry: () => ref.invalidate(_creerPrevisionBundleProvider),
              ),
            ),
            data: (bundle) => _buildForm(bundle),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(_CreerPrevisionBundle bundle) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              const IntroHelpPrevision(),
              AppDimens.vGap16,
              const TitreSectionPrevision(title: 'Quel produit ?'),
              AppDimens.vGap8,
              ProduitSelectorPrevision(
                produits: bundle.produits,
                selectedId: _produitId,
                enabled: !_isSubmitting,
                onChanged: (id) => setState(() => _produitId = id),
              ),
              AppDimens.vGap16,
              const TitreSectionPrevision(title: 'Quantité estimée'),
              AppDimens.vGap8,
              InputUnitPrevision(
                controller: _quantiteCtrl,
                unit: 'kg',
                enabled: !_isSubmitting,
                onChanged: (_) => setState(() {}),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
              AppDimens.vGap16,
              const TitreSectionPrevision(
                title: 'Date de récolte prévue (optionnel)',
              ),
              AppDimens.vGap8,
              DatePickerPrevision(
                value: _dateRecolte,
                enabled: !_isSubmitting,
                onTap: _pickDate,
                onClear: () => setState(() => _dateRecolte = null),
              ),
              AppDimens.vGap16,
              const TitreSectionPrevision(
                title: 'Prix cible par kg (optionnel)',
              ),
              AppDimens.vGap8,
              InputUnitPrevision(
                controller: _prixCtrl,
                unit: 'F / kg',
                enabled: !_isSubmitting,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
              AppDimens.vGap8,
              const HelpTextPrevision(
                text:
                    'Indique ce que tu voudrais idéalement obtenir. Le prix '
                    'final sera négocié avec l\'acheteur à la récolte.',
              ),
              if (bundle.parcelles.isNotEmpty) ...[
                AppDimens.vGap16,
                const TitreSectionPrevision(
                  title: 'Sur quelle parcelle ? (optionnel)',
                ),
                AppDimens.vGap8,
                ParcelleSelectorPrevision(
                  parcelles: bundle.parcelles,
                  selectedId: _parcelleId,
                  enabled: !_isSubmitting,
                  onChanged: (id) => setState(() => _parcelleId = id),
                ),
              ],
              if (_errorMessage != null) ...[
                AppDimens.vGap16,
                Text(_errorMessage!, style: AppTextStyles.errorText),
              ],
            ],
          ),
        ),
        // Sticky bouton créer — pas de Refuser, on est en création.
        StickyCreerPrevision(
          isSubmitting: _isSubmitting,
          canSubmit: _canSubmit,
          onPressed: _submit,
        ),
      ],
    );
  }
}
