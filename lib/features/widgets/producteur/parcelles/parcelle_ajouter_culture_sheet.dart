import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/produit.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/snackbars.dart';

/// Modal de création d'une culture sur une parcelle existante.
///
/// Le producteur choisit un produit, indique la superficie en hectares,
/// et optionnellement la date de plantation. Le backend vérifie que la
/// somme des cultures de la parcelle ne dépasse pas sa superficie totale
/// (s'il dépasse → 400, on affiche le message backend).
///
/// Pop le sheet avec `true` après succès — le parent invalide alors le
/// provider de détail pour refresh la liste cultures.
class ParcelleAjouterCultureSheet extends ConsumerStatefulWidget {
  const ParcelleAjouterCultureSheet({
    required this.parcelleId,
    required this.produits,
    this.superficieRestanteHa,
    super.key,
  });

  final String parcelleId;
  final List<Produit> produits;
  final double? superficieRestanteHa;

  @override
  ConsumerState<ParcelleAjouterCultureSheet> createState() =>
      _ParcelleAjouterCultureSheetState();
}

class _ParcelleAjouterCultureSheetState
    extends ConsumerState<ParcelleAjouterCultureSheet> {
  String? _produitId;
  final _superficieCtrl = TextEditingController();
  DateTime? _datePlantation;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _superficieCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_isSubmitting) return false;
    if (_produitId == null) return false;
    final ha = _parseDouble(_superficieCtrl.text);
    if (ha == null || ha <= 0) return false;
    return true;
  }

  static double? _parseDouble(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _datePlantation ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      helpText: 'Date de plantation',
    );
    if (picked != null && mounted) {
      setState(() => _datePlantation = picked);
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    final ha = _parseDouble(_superficieCtrl.text)!;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final svc = ref.read(marketplaceServiceProvider);
      await svc.addCulture(
        parcelleId: widget.parcelleId,
        produitId: _produitId!,
        superficieHa: ha,
        datePlantation: _datePlantation,
      );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Culture ajoutée.');
      Navigator.of(context).pop(true);
    } on Exception catch (e) {
      // ApiException ou autre — on affiche le message tel quel (backend
      // peut renvoyer "Superficie cumulée dépasse la parcelle.")
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _errorMessage = msg);
      Snackbars.showErreur(context, msg);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding bas adapté au clavier ouvert.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle visuel de bottom sheet
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Ajouter une culture',
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.superficieRestanteHa != null) ...[
              const SizedBox(height: 4),
              Text(
                'Superficie restante : ${_formatHa(widget.superficieRestanteHa!)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              'Produit',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _produitId,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Choisis un produit',
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              items: widget.produits
                  .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          p.nom,
                          style:
                              AppTextStyles.bodyMedium.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (v) {
                      if (v != null) setState(() => _produitId = v);
                    },
            ),
            const SizedBox(height: 16),
            Text(
              'Superficie',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _superficieCtrl,
              enabled: !_isSubmitting,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ex: 1.5',
                suffix: Text(
                  'ha',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Date de plantation (optionnel)',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _isSubmitting ? null : _pickDate,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimens.borderThin,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _datePlantation == null
                            ? 'Choisir une date'
                            : '${_datePlantation!.day.toString().padLeft(2, '0')}/${_datePlantation!.month.toString().padLeft(2, '0')}/${_datePlantation!.year}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          color: _datePlantation == null
                              ? AppColors.textSubtle
                              : AppColors.text,
                        ),
                      ),
                    ),
                    if (_datePlantation != null && !_isSubmitting)
                      InkWell(
                        onTap: () => setState(() => _datePlantation = null),
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.textSubtle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: AppTextStyles.errorText.copyWith(fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: AppColors.borderStrong,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: _canSubmit ? _submit : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(
                        'Ajouter la culture',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
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

String _formatHa(double ha) {
  if (ha == ha.roundToDouble()) return '${ha.toStringAsFixed(0)} ha';
  return '${ha.toStringAsFixed(2)} ha';
}
