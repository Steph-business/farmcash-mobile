import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/prevision.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/snackbars.dart';

/// Ouvre le dialog modal d'édition d'une prévision (quantité, date prévue,
/// prix cible, notes). Retourne `true` si l'enregistrement a réussi,
/// `null` si l'utilisateur a annulé.
Future<bool?> showEditerPrevisionDialog(
  BuildContext context, {
  required Prevision prevision,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => _EditerPrevisionDialog(prevision: prevision),
  );
}

/// Dialog modal pour modifier les champs éditables d'une prévision :
/// quantité, date de récolte prévue, prix cible, notes. La saison est
/// rarement modifiée — laissée hors du formulaire pour rester focused.
class _EditerPrevisionDialog extends ConsumerStatefulWidget {
  const _EditerPrevisionDialog({required this.prevision});

  final Prevision prevision;

  @override
  ConsumerState<_EditerPrevisionDialog> createState() =>
      _EditerPrevisionDialogState();
}

class _EditerPrevisionDialogState
    extends ConsumerState<_EditerPrevisionDialog> {
  late final TextEditingController _qteCtrl;
  late final TextEditingController _prixCtrl;
  late final TextEditingController _notesCtrl;
  DateTime? _date;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _qteCtrl = TextEditingController(
      text: widget.prevision.quantitePrevKg.toStringAsFixed(0),
    );
    _prixCtrl = TextEditingController(
      text: widget.prevision.prixCibleKg?.toStringAsFixed(0) ?? '',
    );
    _notesCtrl = TextEditingController(text: widget.prevision.notes ?? '');
    _date = widget.prevision.dateRecoltePrev;
  }

  @override
  void dispose() {
    _qteCtrl.dispose();
    _prixCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  static double? _parseDouble(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    // Si la date courante est déjà dans le passé (rare mais possible si
    // l'utilisateur tente de modifier une vieille prévision), on borne
    // initialDate à demain pour respecter `firstDate`.
    final initial = (_date != null && _date!.isAfter(tomorrow))
        ? _date!
        : tomorrow.add(const Duration(days: 14));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: tomorrow,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Date prévue de récolte',
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    final qte = _parseDouble(_qteCtrl.text);
    if (qte == null || qte <= 0) {
      setState(() => _errorMessage = 'Quantité invalide.');
      return;
    }
    final prix = _parseDouble(_prixCtrl.text);
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(marketplaceServiceProvider).updatePrevision(
            widget.prevision.id,
            quantitePrevKg: qte,
            dateRecoltePrev: _date,
            prixCibleKg: prix,
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Prévision modifiée.');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Modifier la prévision'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _qteCtrl,
              enabled: !_isSubmitting,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              decoration: const InputDecoration(
                labelText: 'Quantité estimée (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prixCtrl,
              enabled: !_isSubmitting,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              decoration: const InputDecoration(
                labelText: 'Prix cible (F/kg) — optionnel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _isSubmitting ? null : _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
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
                        _date == null
                            ? 'Date de récolte prévue (optionnel)'
                            : DateFormat('d MMM y', 'fr_FR').format(_date!),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          color: _date == null
                              ? AppColors.textSubtle
                              : AppColors.text,
                        ),
                      ),
                    ),
                    if (_date != null && !_isSubmitting)
                      InkWell(
                        onTap: () => setState(() => _date = null),
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
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
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              enabled: !_isSubmitting,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: AppTextStyles.errorText.copyWith(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}
