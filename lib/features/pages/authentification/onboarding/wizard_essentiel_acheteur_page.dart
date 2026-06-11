// =====================================================================
//  Wizard : Onboarding essentiel ACHETEUR (2 étapes)
//  ---------------------------------------------------------------------
//   Étape 1/2 : Es-tu une entreprise ? (toggle Particulier / Entreprise +
//               nom si entreprise)
//   Étape 2/2 : Où achètes-tu ? (multi-select régions CI, ≥ 1)
//
//  POST /auth/profile/acheteur avec { company_name, zones_achat }
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart' as api;
import '../../../../models/enums.dart';
import '../../../../models/ocr_extraction.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/scanner_document_page.dart';
import '../../../widgets/communs/selecteur_region_ci.dart';
import '../../../widgets/communs/sheet_preview_ocr.dart';
import '../../../widgets/communs/snackbars.dart';
import '_wizard_shell.dart';

class WizardEssentielAcheteurPage extends ConsumerStatefulWidget {
  const WizardEssentielAcheteurPage({super.key});

  @override
  ConsumerState<WizardEssentielAcheteurPage> createState() =>
      _WizardEssentielAcheteurPageState();
}

class _WizardEssentielAcheteurPageState
    extends ConsumerState<WizardEssentielAcheteurPage> {
  int _step = 0;

  // ─ Étape 1 ─────────────────────────────────────────────────────────
  /// `true` = entreprise (saisie nom obligatoire), `false` = particulier.
  bool _isCompany = false;
  final TextEditingController _companyCtrl = TextEditingController();

  // ─ Étape 2 ─────────────────────────────────────────────────────────
  final Set<String> _zonesIds = {};

  // ─ Submit ─────────────────────────────────────────────────────────
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _companyCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    super.dispose();
  }

  bool get _stepValid {
    switch (_step) {
      case 0:
        return !_isCompany || _companyCtrl.text.trim().length >= 2;
      case 1:
        return _zonesIds.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _onCta() async {
    if (!_stepValid || _busy) return;
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }
    await _submit();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      final auth = ref.read(authServiceProvider);
      await auth.updateRoleProfile(
        role: UserRole.buyer,
        profile: {
          // company_name = null si particulier (le backend gère)
          'company_name':
              _isCompany ? _companyCtrl.text.trim() : null,
          'zones_achat': _zonesIds.toList(),
        },
      );
      final fresh = await auth.me();
      if (!mounted) return;
      ref.read(authStateProvider.notifier).setAuthenticated(fresh);
    } on api.ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _step == 1;
    return OnboardingWizardShell(
      stepIndex: _step,
      stepCount: 2,
      title: _step == 0 ? 'Qui es-tu ?' : 'Où achètes-tu ?',
      subtitle: _step == 0
          ? 'Particulier ou entreprise, indique-nous comment tu te présentes.'
          : 'Choisis les régions où tu cherches des produits. Tu peux en sélectionner plusieurs.',
      ctaLabel: isLast ? 'Terminer' : 'Continuer',
      onCta: _stepValid ? _onCta : null,
      busy: _busy,
      child: _step == 0 ? _buildIdentityStep() : _buildZonesStep(),
    );
  }

  Widget _buildIdentityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _TogglePill(
                label: 'Particulier',
                icon: Icons.person_rounded,
                selected: !_isCompany,
                onTap: () => setState(() => _isCompany = false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TogglePill(
                label: 'Entreprise',
                icon: Icons.storefront_rounded,
                selected: _isCompany,
                onTap: () => setState(() => _isCompany = true),
              ),
            ),
          ],
        ),
        if (_isCompany) ...[
          const SizedBox(height: 20),
          Text(
            'Nom de l\'entreprise',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _companyCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15,
              color: AppColors.text,
            ),
            decoration: InputDecoration(
              hintText: 'Ex. Société SODIA Sarl',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSubtle,
                fontSize: 14.5,
              ),
              filled: true,
              fillColor: AppColors.surfaceSoft,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _BoutonScanRccm(onTap: _busy ? null : _openScanRccm),
        ],
      ],
    );
  }

  /// Lance le flow scan RCCM → preview → pré-remplissage du nom.
  Future<void> _openScanRccm() async {
    final ocr = ref.read(ocrServiceProvider);
    final extraction = await Navigator.of(context).push<RccmExtraction>(
      MaterialPageRoute(
        builder: (_) => ScannerDocumentPage<RccmExtraction>(
          title: 'Scanner mon RCCM',
          subtitle:
              "Place ton attestation RCCM bien à plat, puis prends une photo nette.",
          helpLine: 'JPEG ou PNG, jusqu\'à 10 Mo.',
          heroIcon: Icons.business_center_outlined,
          onScanned: (file) => ocr.extractRccm(file),
          buildPreview: (ctx, e) => SheetPreviewOcr(
            title: 'Infos extraites de ton RCCM',
            confidence: e.confidence,
            isMock: e.isMock,
            fields: [
              OcrPreviewField(
                label: "Nom de l'entreprise",
                value: e.companyName,
                icon: Icons.storefront_outlined,
              ),
              OcrPreviewField(
                label: 'Numéro RCCM',
                value: e.rccmNumber,
                icon: Icons.tag_rounded,
              ),
              OcrPreviewField(
                label: 'Adresse',
                value: e.address,
                icon: Icons.place_outlined,
              ),
              OcrPreviewField(
                label: "Activité",
                value: e.activity,
                icon: Icons.work_outline_rounded,
              ),
            ],
            onAccept: () => Navigator.of(ctx).pop(true),
          ),
        ),
      ),
    );
    if (extraction == null || !mounted) return;
    final company = extraction.companyName?.trim();
    if (company != null && company.isNotEmpty) {
      setState(() => _companyCtrl.text = company);
    }
    Snackbars.showSucces(
      context,
      'Infos extraites depuis ton RCCM. Vérifie et continue.',
    );
  }

  Widget _buildZonesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_zonesIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${_zonesIds.length} zone${_zonesIds.length > 1 ? "s" : ""} sélectionnée${_zonesIds.length > 1 ? "s" : ""}',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        SelecteurRegionsCiMulti(
          selectedIds: _zonesIds,
          onToggle: (r) {
            setState(() {
              if (_zonesIds.contains(r.id)) {
                _zonesIds.remove(r.id);
              } else {
                _zonesIds.add(r.id);
              }
            });
          },
        ),
      ],
    );
  }
}

/// Bouton outline « Scanner mon RCCM » — gain de temps onboarding.
class _BoutonScanRccm extends StatelessWidget {
  const _BoutonScanRccm({required this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: AppColors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.document_scanner_outlined,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Scanner mon RCCM',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Pré-remplit le nom automatiquement.",
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: disabled
                    ? AppColors.textSubtle
                    : AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
