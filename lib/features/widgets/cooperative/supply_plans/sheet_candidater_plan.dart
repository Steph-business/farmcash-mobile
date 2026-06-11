// =====================================================================
//  Sheet : Candidater à un plan d'approvisionnement
//  ---------------------------------------------------------------------
//  Bottom sheet réutilisable. Pré-remplit qty/mois & prix avec les valeurs
//  du plan, le fournisseur peut négocier à la baisse/hausse selon ses
//  capacités. Valide côté backend qty ≤ plan.qty, months ≤ plan.duration.
//
//  Chantier 2 — Phase 3 mobile.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/supply_plan.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/snackbars.dart';

class SheetCandidaterPlan extends ConsumerStatefulWidget {
  const SheetCandidaterPlan({super.key, required this.plan});
  final SupplyPlan plan;

  @override
  ConsumerState<SheetCandidaterPlan> createState() =>
      _SheetCandidaterPlanState();
}

class _SheetCandidaterPlanState
    extends ConsumerState<SheetCandidaterPlan> {
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _priceCtrl;
  final _messageCtrl = TextEditingController();
  late int _monthsOffered;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplit avec les valeurs demandées par l'acheteur.
    _qtyCtrl = TextEditingController(
      text: widget.plan.qtyPerMonthKg.round().toString(),
    );
    _priceCtrl = TextEditingController(
      text: widget.plan.pricePerKg.round().toString(),
    );
    _monthsOffered = widget.plan.durationMonths;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(' ', '')) ?? 0;
    final price =
        double.tryParse(_priceCtrl.text.replaceAll(' ', '')) ?? 0;

    if (qty < 100) {
      Snackbars.showErreur(context, 'Quantité minimum 100 kg / mois.');
      return;
    }
    if (qty > widget.plan.qtyPerMonthKg) {
      Snackbars.showErreur(
        context,
        'Tu ne peux pas proposer plus que la demande '
        '(${widget.plan.qtyPerMonthKg.round()} kg/mois).',
      );
      return;
    }
    if (price <= 0) {
      Snackbars.showErreur(context, 'Le prix doit être > 0.');
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(supplyPlansServiceProvider).createCandidature(
            planId: widget.plan.id,
            qtyOfferedKg: qty,
            monthsOffered: _monthsOffered,
            priceOffered: price,
            message: _messageCtrl.text.trim().isEmpty
                ? null
                : _messageCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Candidature envoyée à l\'acheteur.',
      );
      Navigator.of(context).pop(true);
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
    final mq = MediaQuery.of(context);
    final nf = NumberFormat('#,##0', 'fr_FR');
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(' ', '')) ?? 0;
    final price =
        double.tryParse(_priceCtrl.text.replaceAll(' ', '')) ?? 0;
    final totalValue = qty * price * _monthsOffered;

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(22)),
        ),
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                children: [
                  Text(
                    'Candidater à ce plan',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.plan.produitNom ?? 'Plan',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _rappel(
                    icon: Icons.flag_outlined,
                    label: 'Demande de l\'acheteur',
                    valeur:
                        '${nf.format(widget.plan.qtyPerMonthKg.round())} kg/mois '
                        '× ${widget.plan.durationMonths} mois · '
                        '${nf.format(widget.plan.pricePerKg.round())} F/kg',
                  ),
                  const SizedBox(height: 18),
                  _label('Volume que je peux livrer / mois'),
                  const SizedBox(height: 6),
                  _champNombre(
                    controller: _qtyCtrl,
                    hint:
                        'Max ${nf.format(widget.plan.qtyPerMonthKg.round())} kg',
                    suffix: 'kg/mois',
                  ),
                  const SizedBox(height: 14),
                  _label('Sur combien de mois ?'),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(
                        widget.plan.durationMonths,
                        (i) {
                          final m = i + 1;
                          final selected = m == _monthsOffered;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              selected: selected,
                              label: Text('$m mois'),
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.text,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                              selectedColor: AppColors.primary,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                              onSelected: (_) =>
                                  setState(() => _monthsOffered = m),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label('Mon prix par kg'),
                  const SizedBox(height: 6),
                  _champNombre(
                    controller: _priceCtrl,
                    hint: 'Ex : 360',
                    suffix: 'F/kg',
                  ),
                  const SizedBox(height: 14),
                  _label('Message à l\'acheteur (optionnel)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _messageCtrl,
                    maxLines: 3,
                    maxLength: 2000,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText:
                          'Ex : Lot bio certifié, livraison mensuelle '
                          'le 15 du mois...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      counterText: '',
                    ),
                  ),
                  if (qty > 0 && price > 0) ...[
                    const SizedBox(height: 16),
                    _cardTotal(
                      'Valeur totale de mon engagement',
                      '${nf.format(totalValue.round())} F',
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimens.brButton,
                      ),
                      elevation: 0,
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Envoyer ma candidature',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers d'UI ────────────────────────────────────────────

  Widget _rappel({
    required IconData icon,
    required String label,
    required String valeur,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valeur,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: AppTextStyles.labelMedium.copyWith(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      );

  Widget _champNombre({
    required TextEditingController controller,
    required String hint,
    required String suffix,
  }) {
    return TextField(
      controller: controller,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]'))],
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        filled: true,
        fillColor: Colors.white,
        isCollapsed: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _cardTotal(String label, String valeur) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            valeur,
            style: AppTextStyles.titleLarge.copyWith(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
