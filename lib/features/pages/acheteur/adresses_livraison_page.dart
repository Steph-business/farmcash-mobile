import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/models.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/communs/vue_erreur.dart';

// ─── Couleurs locales ───────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// ─── Provider ──────────────────────────────────────────────────────────

final _addressesProvider =
    FutureProvider.autoDispose<List<BuyerAddress>>((ref) async {
  return ref.read(buyerServiceProvider).listAddresses();
});

final _villesProvider = FutureProvider.autoDispose<List<Ville>>((ref) async {
  return ref.read(marketplaceServiceProvider).listVilles();
});

/// Page Adresses de livraison — liste des adresses enregistrées de l'acheteur.
///
/// Branche sur `BuyerService` (CRUD côté backend). Toutes les actions
/// invalident le provider pour rafraîchir la liste.
class AdressesLivraisonAcheteurPage extends ConsumerStatefulWidget {
  const AdressesLivraisonAcheteurPage({super.key});

  @override
  ConsumerState<AdressesLivraisonAcheteurPage> createState() =>
      _AdressesLivraisonAcheteurPageState();
}

class _AdressesLivraisonAcheteurPageState
    extends ConsumerState<AdressesLivraisonAcheteurPage> {
  String? _operationEnCours;

  Future<void> _refresh() async {
    ref.invalidate(_addressesProvider);
    await ref.read(_addressesProvider.future);
  }

  Future<void> _definirParDefaut(BuyerAddress a) async {
    if (_operationEnCours != null) return;
    setState(() => _operationEnCours = a.id);
    try {
      await ref
          .read(buyerServiceProvider)
          .updateAddress(a.id, isDefault: true);
      await _refresh();
      if (!mounted) return;
      Snackbars.showSucces(context, '${a.libelle} définie par défaut');
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _operationEnCours = null);
    }
  }

  Future<void> _supprimer(BuyerAddress a) async {
    if (_operationEnCours != null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'adresse'),
        content: Text('Supprimer « ${a.libelle} » ? Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _operationEnCours = a.id);
    try {
      await ref.read(buyerServiceProvider).deleteAddress(a.id);
      await _refresh();
      if (!mounted) return;
      Snackbars.showInfo(context, '${a.libelle} supprimée');
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _operationEnCours = null);
    }
  }

  Future<void> _ajouterAdresse() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => const _AddressFormSheet(),
    );
    if (created == true) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_addressesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les adresses. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (adresses) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refresh,
                  child: adresses.isEmpty
                      ? ListView(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          children: [
                            const SizedBox(height: 32),
                            const _EmptyState(),
                            const SizedBox(height: 24),
                            _AjouterBtn(onTap: _ajouterAdresse),
                          ],
                        )
                      : ListView(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          children: [
                            ...adresses.map(
                              (a) => _AdresseCard(
                                adresse: a,
                                busy: _operationEnCours == a.id,
                                onDefinirParDefaut: () =>
                                    _definirParDefaut(a),
                                onSupprimer: () => _supprimer(a),
                              ),
                            ),
                            const SizedBox(height: 4),
                            _AjouterBtn(onTap: _ajouterAdresse),
                          ],
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

// ─── Header (back + titre) ──────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.acheteurProfilPath);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Adresses de livraison',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}

// ─── Card adresse ───────────────────────────────────────────────────────

class _AdresseCard extends StatelessWidget {
  const _AdresseCard({
    required this.adresse,
    required this.busy,
    required this.onDefinirParDefaut,
    required this.onSupprimer,
  });

  final BuyerAddress adresse;
  final bool busy;
  final VoidCallback onDefinirParDefaut;
  final VoidCallback onSupprimer;

  @override
  Widget build(BuildContext context) {
    final adresseComplete = adresse.adresseComplete.trim();
    final ville = adresse.villeNom?.trim();
    final adresseDisplay = [
      if (adresseComplete.isNotEmpty) adresseComplete,
      if (ville != null && ville.isNotEmpty) ville,
    ].join(' · ');
    final contactNom = adresse.contactNom.trim();
    final contactPhone = adresse.contactPhone.trim();
    final contactDisplay = [
      if (contactNom.isNotEmpty) contactNom,
      if (contactPhone.isNotEmpty) contactPhone,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: adresse.isDefault ? AppColors.primary : AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kPrimarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            adresse.libelle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        if (adresse.isDefault) ...[
                          const SizedBox(width: 8),
                          const _ChipDefaut(),
                        ],
                      ],
                    ),
                    if (adresseDisplay.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        adresseDisplay,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (contactDisplay.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        contactDisplay,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (!adresse.isDefault)
                _LinkAction(
                  label: busy ? '…' : 'Définir par défaut',
                  onTap: busy ? null : onDefinirParDefaut,
                  color: AppColors.primary,
                ),
              if (!adresse.isDefault) const SizedBox(width: 16),
              _LinkAction(
                label: busy ? '…' : 'Supprimer',
                onTap: busy ? null : onSupprimer,
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipDefaut extends StatelessWidget {
  const _ChipDefaut();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Par défaut',
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _LinkAction extends StatelessWidget {
  const _LinkAction({
    required this.label,
    required this.onTap,
    required this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onTap == null ? AppColors.textSubtle : color,
          ),
        ),
      ),
    );
  }
}

// ─── Bouton « + Ajouter une adresse » ───────────────────────────────────

class _AjouterBtn extends StatelessWidget {
  const _AjouterBtn({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Ajouter une adresse',
              style: AppTextStyles.button.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucune adresse enregistrée',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'Ajoute ta première adresse pour faciliter\ntes commandes.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Formulaire d'ajout d'adresse ───────────────────────────────────────

/// Bottom sheet de création d'adresse. `pop(true)` si succès.
class _AddressFormSheet extends ConsumerStatefulWidget {
  const _AddressFormSheet();

  @override
  ConsumerState<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<_AddressFormSheet> {
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
            contactNom: _contactNomCtrl.text.trim().isEmpty
                ? null
                : _contactNomCtrl.text.trim(),
            contactPhone: _contactPhoneCtrl.text.trim().isEmpty
                ? null
                : _contactPhoneCtrl.text.trim(),
            adresseComplete: _adresseCompleteCtrl.text.trim().isEmpty
                ? null
                : _adresseCompleteCtrl.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final villesAsync = ref.watch(_villesProvider);
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
              _FieldLabel('Libellé *'),
              TextFormField(
                controller: _libelleCtrl,
                decoration: _inputDeco(hint: 'Restaurant Le Baoulé'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Saisis un libellé'
                    : null,
              ),
              const SizedBox(height: 12),
              _FieldLabel('Contact'),
              TextFormField(
                controller: _contactNomCtrl,
                decoration: _inputDeco(hint: 'Marie Y.'),
              ),
              const SizedBox(height: 12),
              _FieldLabel('Téléphone'),
              TextFormField(
                controller: _contactPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _inputDeco(hint: '+225 07 ** ** ** **'),
              ),
              const SizedBox(height: 12),
              _FieldLabel('Adresse complète'),
              TextFormField(
                controller: _adresseCompleteCtrl,
                maxLines: 3,
                decoration: _inputDeco(
                  hint: '22 Avenue Saint-Pierre, Cocody',
                ),
              ),
              const SizedBox(height: 12),
              _FieldLabel('Ville'),
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
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTextStyles.labelMedium.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
