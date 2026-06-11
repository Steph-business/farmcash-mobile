// =====================================================================
//  Wizard : Onboarding essentiel COOPÉRATIVE (3 étapes)
//  ---------------------------------------------------------------------
//   Étape 1/3 : Nom de la coopérative + région
//   Étape 2/3 : Numéro d'agrément (régulatoire — obligatoire)
//   Étape 3/3 : Produits gérés (≥ 1)
//
//  POST /auth/profile/cooperative avec
//  { nom, numero_agrement, region_id, produits: [produit_id, …] }
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart' as api;
import '../../../../models/enums.dart';
import '../../../../models/ocr_extraction.dart';
import '../../../../models/produit.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/scanner_document_page.dart';
import '../../../widgets/communs/selecteur_region_ci.dart';
import '../../../widgets/communs/sheet_preview_ocr.dart';
import '../../../widgets/communs/snackbars.dart';
import '_wizard_shell.dart';

class WizardEssentielCooperativePage extends ConsumerStatefulWidget {
  const WizardEssentielCooperativePage({super.key});

  @override
  ConsumerState<WizardEssentielCooperativePage> createState() =>
      _WizardEssentielCooperativePageState();
}

class _WizardEssentielCooperativePageState
    extends ConsumerState<WizardEssentielCooperativePage> {
  int _step = 0;

  // ─ Étape 1 ─────────────────────────────────────────────────────────
  final TextEditingController _nameCtrl = TextEditingController();
  String? _regionId;

  // ─ Étape 2 ─────────────────────────────────────────────────────────
  final TextEditingController _agrementCtrl = TextEditingController();

  // ─ Étape 3 ─────────────────────────────────────────────────────────
  final Set<String> _produitIds = {};
  List<Produit> _produits = const [];
  bool _produitsLoading = false;
  bool _produitsLoaded = false;

  // ─ Submit ─────────────────────────────────────────────────────────
  bool _busy = false;

  // ─ État OCR partagé entre étape 1 et étape 2 ───────────────────────
  /// Dernière extraction RCCM réussie — utilisée pour pré-remplir
  /// `_agrementCtrl` au passage à l'étape 2 sans relancer un scan.
  RccmExtraction? _lastRccm;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
    _agrementCtrl.addListener(() => setState(() {}));
    // Pré-charge le catalogue de produits dès le départ.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProduits());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _agrementCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProduits() async {
    if (_produitsLoaded || _produitsLoading) return;
    setState(() => _produitsLoading = true);
    try {
      final list = await ref.read(marketplaceServiceProvider).listProduits();
      if (!mounted) return;
      setState(() {
        _produits = list;
        _produitsLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _produitsLoading = false);
    }
  }

  bool get _stepValid {
    switch (_step) {
      case 0:
        return _nameCtrl.text.trim().length >= 2 && _regionId != null;
      case 1:
        return _agrementCtrl.text.trim().length >= 3;
      case 2:
        return _produitIds.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _onCta() async {
    if (!_stepValid || _busy) return;
    if (_step < 2) {
      setState(() {
        final next = _step + 1;
        // Si on arrive sur l'étape 2 (numéro d'agrément) sans avoir
        // encore renseigné le champ et qu'on a déjà une extraction RCCM
        // en mémoire (scannée à l'étape 1), on pré-remplit ici aussi en
        // filet de sécurité — utile si l'user a effacé le champ avant
        // de passer à l'étape suivante.
        if (next == 1 && _agrementCtrl.text.trim().isEmpty) {
          final rccm = _lastRccm?.rccmNumber?.trim();
          if (rccm != null && rccm.isNotEmpty) {
            _agrementCtrl.text = rccm;
          }
        }
        _step = next;
      });
      return;
    }
    await _submit();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      final auth = ref.read(authServiceProvider);
      await auth.updateRoleProfile(
        role: UserRole.cooperative,
        profile: {
          'nom': _nameCtrl.text.trim(),
          'numero_agrement': _agrementCtrl.text.trim(),
          'region_id': _regionId,
          'produits': _produitIds.toList(),
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
    final isLast = _step == 2;
    return OnboardingWizardShell(
      stepIndex: _step,
      stepCount: 3,
      title: _titreEtape,
      subtitle: _sousTitreEtape,
      ctaLabel: isLast ? 'Terminer' : 'Continuer',
      onCta: _stepValid ? _onCta : null,
      busy: _busy,
      child: _buildStep(),
    );
  }

  String get _titreEtape {
    switch (_step) {
      case 0:
        return 'Ta coopérative';
      case 1:
        return 'Numéro d\'agrément';
      case 2:
        return 'Une dernière info';
      default:
        return '';
    }
  }

  String get _sousTitreEtape {
    switch (_step) {
      case 0:
        return 'Donne-nous le nom et la région où ta coopérative est basée.';
      case 1:
        return 'Le numéro d\'agrément officiel délivré par les autorités. Obligatoire pour publier sur le marché.';
      case 2:
        return 'Quels produits ta coopérative gère ? Sélectionne-en au moins un.';
      default:
        return '';
    }
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildNameRegionStep();
      case 1:
        return _buildAgrementStep();
      case 2:
        return _buildProduitsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNameRegionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BoutonScanRccm(
          onTap: _busy ? null : _openScanRccm,
          sousTitre: 'Pré-remplit le nom et le numéro d\'agrément.',
        ),
        const SizedBox(height: 18),
        Text(
          'Nom de la coopérative',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 15,
            color: AppColors.text,
          ),
          decoration: _inputDecoration('Ex. COOP-CI Yamoussoukro'),
        ),
        const SizedBox(height: 20),
        Text(
          'Région principale',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        SelecteurRegionCi(
          selectedId: _regionId,
          onChanged: (r) => setState(() => _regionId = r.id),
        ),
      ],
    );
  }

  Widget _buildAgrementStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Le numéro d\'agrément prouve aux acheteurs que ta coopérative est officiellement reconnue.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.5,
                    color: AppColors.text,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _BoutonScanRccm(
          onTap: _busy ? null : _openScanRccm,
          sousTitre: 'Lit le numéro et l\'écrit pour toi.',
        ),
        const SizedBox(height: 18),
        Text(
          'Numéro d\'agrément',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _agrementCtrl,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 15,
            color: AppColors.text,
          ),
          decoration: _inputDecoration('Ex. CI-COOP-2024-1234'),
        ),
      ],
    );
  }

  /// Lance le scan RCCM puis pré-remplit nom + agrément en fonction des
  /// champs trouvés. Stocke aussi l'extraction dans `_lastRccm` pour
  /// disposer du numéro à l'étape suivante (cas où l'user scanne dès
  /// l'étape 1 mais que `_agrementCtrl` est encore vide).
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
                label: 'Nom de la coopérative',
                value: e.companyName,
                icon: Icons.storefront_outlined,
              ),
              OcrPreviewField(
                label: "Numéro d'agrément (RCCM)",
                value: e.rccmNumber,
                icon: Icons.tag_rounded,
              ),
              OcrPreviewField(
                label: 'Adresse',
                value: e.address,
                icon: Icons.place_outlined,
              ),
              OcrPreviewField(
                label: 'Activité',
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
    final name = extraction.companyName?.trim();
    final rccm = extraction.rccmNumber?.trim();
    setState(() {
      _lastRccm = extraction;
      if (name != null && name.isNotEmpty) {
        _nameCtrl.text = name;
      }
      if (rccm != null && rccm.isNotEmpty) {
        _agrementCtrl.text = rccm;
      }
    });
    Snackbars.showSucces(
      context,
      'Infos extraites depuis ton RCCM. Vérifie chaque champ avant de continuer.',
    );
  }

  Widget _buildProduitsStep() {
    if (_produitsLoading && !_produitsLoaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_produits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 40,
              color: AppColors.textSubtle,
            ),
            const SizedBox(height: 12),
            Text(
              'Impossible de charger les produits.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadProduits,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_produitIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${_produitIds.length} produit${_produitIds.length > 1 ? "s" : ""} sélectionné${_produitIds.length > 1 ? "s" : ""}',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        for (final p in _produits)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ProduitRow(
              nom: p.nom,
              selected: _produitIds.contains(p.id),
              onTap: () {
                setState(() {
                  if (_produitIds.contains(p.id)) {
                    _produitIds.remove(p.id);
                  } else {
                    _produitIds.add(p.id);
                  }
                });
              },
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }
}

/// Bouton outline « Scanner mon RCCM » — gain de temps onboarding.
class _BoutonScanRccm extends StatelessWidget {
  const _BoutonScanRccm({required this.onTap, required this.sousTitre});
  final VoidCallback? onTap;
  final String sousTitre;

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
                      sousTitre,
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

class _ProduitRow extends StatelessWidget {
  const _ProduitRow({
    required this.nom,
    required this.selected,
    required this.onTap,
  });

  final String nom;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final monogram = nom.isEmpty ? '?' : nom.trim().substring(0, 1).toUpperCase();
    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.16)
                      : AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  monogram,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSubtle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nom,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.borderStrong,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
