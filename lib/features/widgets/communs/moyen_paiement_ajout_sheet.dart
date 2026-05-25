import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/enums.dart';
import '../../../models/portefeuille.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import 'snackbars.dart';

/// Bottom sheet réutilisable pour ajouter un moyen de paiement (Mobile
/// Money) à un user. Utilisé typiquement :
///   • à l'achat d'une commande si l'acheteur n'a pas encore configuré
///     de moyen → on lui propose d'en créer un sur place ;
///   • depuis le profil / wallet en mode "Gérer mes moyens de paiement".
///
/// Retourne le `MoyenPayement` créé via `Navigator.pop(value)`, ou
/// `null` si l'utilisateur a annulé.
Future<MoyenPayement?> showAjouterMoyenPaiementSheet(BuildContext context) {
  return showModalBottomSheet<MoyenPayement>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _AjouterMoyenSheet(),
  );
}

class _AjouterMoyenSheet extends ConsumerStatefulWidget {
  const _AjouterMoyenSheet();

  @override
  ConsumerState<_AjouterMoyenSheet> createState() => _AjouterMoyenSheetState();
}

class _AjouterMoyenSheetState extends ConsumerState<_AjouterMoyenSheet> {
  MobileProvider _provider = MobileProvider.orangeMoney;
  final _phoneCtrl = TextEditingController();
  bool _isDefault = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_isSubmitting) return false;
    // Numéro CI : 10 chiffres locaux (+225 optionnel). On valide
    // simplement : au moins 8 chiffres.
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 8;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final mp = await ref.read(financeServiceProvider).addMoyenPayement(
            provider: _provider,
            phoneDisplay: _phoneCtrl.text.trim(),
            isDefault: _isDefault,
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Moyen de paiement ajouté.');
      Navigator.of(context).pop(mp);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Impossible d\'ajouter le moyen.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              'Ajouter un moyen de paiement',
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Indispensable pour acheter, recharger ton wallet ou recevoir des paiements.',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Opérateur',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // 4 providers Mobile Money disponibles en CI, ordonnés par
            // usage réel (Wave a explosé chez les 18-35 ans, Orange
            // reste roi sur l'ensemble du pays, MTN et Moov complètent).
            // L'enum backend supporte aussi VIREMENT et WALLET mais on
            // ne les expose pas dans cette UI low-tech.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ProviderChip(
                  label: 'Orange Money',
                  selected: _provider == MobileProvider.orangeMoney,
                  enabled: !_isSubmitting,
                  onTap: () =>
                      setState(() => _provider = MobileProvider.orangeMoney),
                ),
                _ProviderChip(
                  label: 'Wave',
                  selected: _provider == MobileProvider.wave,
                  enabled: !_isSubmitting,
                  onTap: () => setState(() => _provider = MobileProvider.wave),
                ),
                _ProviderChip(
                  label: 'MTN Money',
                  selected: _provider == MobileProvider.mtnMomo,
                  enabled: !_isSubmitting,
                  onTap: () =>
                      setState(() => _provider = MobileProvider.mtnMomo),
                ),
                _ProviderChip(
                  label: 'Moov Money',
                  selected: _provider == MobileProvider.moov,
                  enabled: !_isSubmitting,
                  onTap: () => setState(() => _provider = MobileProvider.moov),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Numéro de téléphone',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              enabled: !_isSubmitting,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9 +]')),
              ],
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 15),
              decoration: InputDecoration(
                hintText: '+225 07 XX XX XX XX',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isDefault,
              onChanged:
                  _isSubmitting ? null : (v) => setState(() => _isDefault = v),
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Définir par défaut',
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
              ),
              subtitle: Text(
                'Utilisé automatiquement pour tes achats et recharges.',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                        'Enregistrer',
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

class _ProviderChip extends StatelessWidget {
  const _ProviderChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                selected ? AppColors.onPrimary : AppColors.text,
          ),
        ),
      ),
    );
  }
}
