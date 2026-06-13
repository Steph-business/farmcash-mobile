// =====================================================================
//  Page : Créer un plan d'approvisionnement (acheteur)
//  ---------------------------------------------------------------------
//  Wizard mono-page avec sections claires. RCCM obligatoire côté backend
//  (le service rejette si pas renseigné). Volume total mini 1 000 kg.
//
//  Chantier 2 — Phase 3 mobile.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/produit.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/snackbars.dart';

final _produitsForPlanProvider =
    FutureProvider.autoDispose<List<Produit>>((ref) async {
  return ref.read(marketplaceServiceProvider).listProduits();
});

class CreerPlanPage extends ConsumerStatefulWidget {
  const CreerPlanPage({super.key});

  @override
  ConsumerState<CreerPlanPage> createState() => _CreerPlanPageState();
}

class _CreerPlanPageState extends ConsumerState<CreerPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Abidjan');
  final _notesCtrl = TextEditingController();

  Produit? _produit;
  int _durationMonths = 6;
  DateTime _startMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    1,
  );
  bool _busy = false;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startMonth,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Mois de démarrage du plan',
    );
    if (picked != null) {
      setState(() {
        _startMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;
    if (_produit == null) {
      Snackbars.showErreur(context, 'Choisis un produit.');
      return;
    }

    final qty = double.tryParse(_qtyCtrl.text.replaceAll(' ', '')) ?? 0;
    final price = double.tryParse(_priceCtrl.text.replaceAll(' ', '')) ?? 0;
    if (qty < 100) {
      Snackbars.showErreur(context, 'Quantité mensuelle minimum 100 kg.');
      return;
    }
    if (qty * _durationMonths < 1000) {
      Snackbars.showErreur(
        context,
        'Volume total minimum 1 000 kg (qté × durée).',
      );
      return;
    }
    if (price <= 0) {
      Snackbars.showErreur(context, 'Le prix doit être > 0.');
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(supplyPlansServiceProvider).createPlan(
            produitId: _produit!.id,
            qtyPerMonthKg: qty,
            durationMonths: _durationMonths,
            pricePerKg: price,
            startMonth: _startMonth,
            deliveryAddress: _addressCtrl.text.trim(),
            deliveryCity: _cityCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Plan soumis · validation FarmCash sous 24-48h.',
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
    final produitsAsync = ref.watch(_produitsForPlanProvider);
    final nf = NumberFormat('#,##0', 'fr_FR');
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(' ', '')) ?? 0;
    final price = double.tryParse(_priceCtrl.text.replaceAll(' ', '')) ?? 0;
    final totalKg = qty * _durationMonths;
    final totalValue = totalKg * price;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Nouveau plan B2B'),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    _Bandeau(
                      texte:
                          'Un plan engage l\'acheteur à acheter et le fournisseur '
                          'à livrer un volume mensuel stable sur 3 à 12 mois. '
                          'Validation FarmCash sous 24-48h.',
                    ),
                    const SizedBox(height: 14),
                    _SectionTitle('Produit'),
                    const SizedBox(height: 6),
                    produitsAsync.when(
                      data: (produits) => _SelecteurProduit(
                        produits: produits,
                        selection: _produit,
                        onChanged: (p) => setState(() => _produit = p),
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, _) => Text(
                        'Impossible de charger les produits ($e)',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle('Volume mensuel'),
                    const SizedBox(height: 6),
                    _ChampNombre(
                      controller: _qtyCtrl,
                      hint: 'Ex : 50000',
                      suffix: 'kg / mois',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle('Durée du plan'),
                    const SizedBox(height: 6),
                    _SelecteurDuree(
                      valeur: _durationMonths,
                      onChanged: (m) => setState(() => _durationMonths = m),
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle('Prix par kg'),
                    const SizedBox(height: 6),
                    _ChampNombre(
                      controller: _priceCtrl,
                      hint: 'Ex : 350',
                      suffix: 'F / kg',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle('Mois de démarrage'),
                    const SizedBox(height: 6),
                    _SelecteurMois(
                      valeur: _startMonth,
                      onTap: _pickStartMonth,
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle('Livraison'),
                    const SizedBox(height: 6),
                    _ChampTexte(
                      controller: _cityCtrl,
                      hint: 'Ville (ex: Abidjan)',
                      maxLength: 120,
                    ),
                    const SizedBox(height: 8),
                    _ChampTexte(
                      controller: _addressCtrl,
                      hint: 'Adresse de livraison complète',
                      maxLines: 2,
                      maxLength: 1000,
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle('Notes (optionnel)'),
                    const SizedBox(height: 6),
                    _ChampTexte(
                      controller: _notesCtrl,
                      hint:
                          'Spécifications qualité, conditions particulières...',
                      maxLines: 3,
                      maxLength: 5000,
                    ),
                    const SizedBox(height: 18),
                    if (qty > 0 && price > 0)
                      _CarteRecap(
                        produit: _produit?.nom ?? '-',
                        volumeTotal:
                            '${nf.format(totalKg.round())} kg sur '
                            '$_durationMonths mois',
                        valeurTotal: '${nf.format(totalValue.round())} F',
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // Sticky bottom
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
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
                            'Soumettre le plan pour validation',
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
}

// ───────────────────────────────────────────────────────────────────
//  Sous-widgets
// ───────────────────────────────────────────────────────────────────

class _Bandeau extends StatelessWidget {
  const _Bandeau({required this.texte});
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.factory_outlined,
            size: 17,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texte,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11.5,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.titleSmall.copyWith(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
    );
  }
}

class _SelecteurProduit extends StatelessWidget {
  const _SelecteurProduit({
    required this.produits,
    required this.selection,
    required this.onChanged,
  });
  final List<Produit> produits;
  final Produit? selection;
  final ValueChanged<Produit> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selection?.id,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        hintText: 'Choisir un produit',
        filled: true,
        fillColor: Colors.white,
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
      items: produits
          .map(
            (p) => DropdownMenuItem<String>(
              value: p.id,
              child: Text(p.nom, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (id) {
        if (id == null) return;
        final p = produits.firstWhere((x) => x.id == id);
        onChanged(p);
      },
    );
  }
}

class _ChampNombre extends StatelessWidget {
  const _ChampNombre({
    required this.controller,
    required this.hint,
    required this.suffix,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final String suffix;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlignVertical: TextAlignVertical.center,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
      ],
      onChanged: onChanged,
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
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
    );
  }
}

class _ChampTexte extends StatelessWidget {
  const _ChampTexte({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
  });
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        counterText: '',
      ),
      validator: maxLength != null
          ? (v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null
          : null,
    );
  }
}

class _SelecteurDuree extends StatelessWidget {
  const _SelecteurDuree({required this.valeur, required this.onChanged});
  final int valeur;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(10, (i) {
          final m = i + 3; // 3 à 12 mois
          final selected = m == valeur;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text('$m mois'),
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border,
              ),
              onSelected: (_) => onChanged(m),
            ),
          );
        }),
      ),
    );
  }
}

class _SelecteurMois extends StatelessWidget {
  const _SelecteurMois({required this.valeur, required this.onTap});
  final DateTime valeur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy', 'fr_FR').format(valeur),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarteRecap extends StatelessWidget {
  const _CarteRecap({
    required this.produit,
    required this.volumeTotal,
    required this.valeurTotal,
  });
  final String produit;
  final String volumeTotal;
  final String valeurTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          _ligne('Produit', produit),
          _ligne('Volume total', volumeTotal),
          _ligne('Valeur engagée', valeurTotal, bold: true),
        ],
      ),
    );
  }

  Widget _ligne(String label, String valeur, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            valeur,
            style: AppTextStyles.bodyMedium.copyWith(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
