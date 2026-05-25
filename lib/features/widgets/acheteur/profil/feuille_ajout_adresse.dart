import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/models.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/chargement.dart';
import '../../communs/snackbars.dart';
import 'libelle_champ_adresse.dart';

/// Provider des villes utilise par le bottom sheet d'ajout d'adresse.
final villesAdresseAcheteurProvider =
    FutureProvider.autoDispose<List<Ville>>((ref) async {
  return ref.read(marketplaceServiceProvider).listVilles();
});

/// Bottom sheet de creation d'une adresse de livraison acheteur. `pop(true)`
/// si la creation reussit (le caller invalide alors la liste des adresses),
/// sinon `pop(null)`. Affiche un formulaire avec libelle, contact, telephone,
/// adresse complete, ville (dropdown) et switch "Definir par defaut".
class FeuilleAjoutAdresse extends ConsumerStatefulWidget {
  const FeuilleAjoutAdresse({super.key});

  @override
  ConsumerState<FeuilleAjoutAdresse> createState() =>
      _FeuilleAjoutAdresseState();
}

class _FeuilleAjoutAdresseState extends ConsumerState<FeuilleAjoutAdresse> {
  final _formKey = GlobalKey<FormState>();
  final _libelleCtrl = TextEditingController();
  final _contactNomCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _adresseCompleteCtrl = TextEditingController();
  String? _villeId;
  bool _isDefault = false;
  bool _submitting = false;

  @override
  void dispose() {
    _libelleCtrl.dispose();
    _contactNomCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _adresseCompleteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await ref.read(buyerServiceProvider).createAddress(
            libelle: _libelleCtrl.text.trim(),
            contactNom: _contactNomCtrl.text.trim(),
            contactPhone: _contactPhoneCtrl.text.trim(),
            adresseComplete: _adresseCompleteCtrl.text.trim(),
            villeId: _villeId,
            isDefault: _isDefault,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Adresse ajoutée');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _inputDeco({required String hint}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final villesAsync = ref.watch(villesAdresseAcheteurProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Nouvelle adresse',
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const LibelleChampAdresse('Libellé *'),
              TextFormField(
                controller: _libelleCtrl,
                decoration: _inputDeco(hint: 'Restaurant Le Baoulé'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Saisis un libellé'
                    : null,
              ),
              const SizedBox(height: 12),
              const LibelleChampAdresse('Contact'),
              TextFormField(
                controller: _contactNomCtrl,
                decoration: _inputDeco(hint: 'Marie Y.'),
              ),
              const SizedBox(height: 12),
              const LibelleChampAdresse('Téléphone'),
              TextFormField(
                controller: _contactPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _inputDeco(hint: '+225 07 ** ** ** **'),
              ),
              const SizedBox(height: 12),
              const LibelleChampAdresse('Adresse complète'),
              TextFormField(
                controller: _adresseCompleteCtrl,
                maxLines: 3,
                decoration: _inputDeco(
                  hint: '22 Avenue Saint-Pierre, Cocody',
                ),
              ),
              const SizedBox(height: 12),
              const LibelleChampAdresse('Ville'),
              villesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Chargement(size: 18),
                ),
                error: (_, _) => Text(
                  'Impossible de charger les villes',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.error, fontSize: 12),
                ),
                data: (villes) => DropdownButtonFormField<String>(
                  initialValue: _villeId,
                  isExpanded: true,
                  decoration: _inputDeco(hint: 'Sélectionner une ville'),
                  items: villes
                      .map(
                        (v) => DropdownMenuItem<String>(
                          value: v.id,
                          child: Text(v.displayWithRegion),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _villeId = v),
                ),
              ),
              const SizedBox(height: 14),
              SwitchListTile.adaptive(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                title: Text(
                  'Définir par défaut',
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                ),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHeight,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimens.brButton,
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Enregistrer',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 14,
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
