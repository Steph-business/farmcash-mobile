// =====================================================================
//  Wizard : Onboarding essentiel PRODUCTEUR (2 étapes)
//  ---------------------------------------------------------------------
//  Forcé par le guard auth tant que `essential_fields_complete == false`.
//
//   Étape 1/2 : Où es-tu ? (région CI parmi 8)
//   Étape 2/2 : Qu'est-ce que tu cultives ? (≥ 1 produit)
//
//  À la fin → POST /auth/profile/producteur avec
//  { region_id, cultures_principales: [produit_id, …] }
//  puis /auth/me pour rafraîchir le flag + setAuthenticated → le guard
//  redirige automatiquement vers l'accueil producteur.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api_client/api_exception.dart' as api;
import '../../../../models/enums.dart';
import '../../../../models/produit.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/selecteur_region_ci.dart';
import '../../../widgets/communs/snackbars.dart';
import '_wizard_shell.dart';

class WizardEssentielProducteurPage extends ConsumerStatefulWidget {
  const WizardEssentielProducteurPage({super.key});

  @override
  ConsumerState<WizardEssentielProducteurPage> createState() =>
      _WizardEssentielProducteurPageState();
}

class _WizardEssentielProducteurPageState
    extends ConsumerState<WizardEssentielProducteurPage> {
  // ─ Step state ─────────────────────────────────────────────────────
  int _step = 0;

  // ─ Étape 1 : région ───────────────────────────────────────────────
  String? _regionId;

  // ─ Étape 2 : cultures ─────────────────────────────────────────────
  final Set<String> _produitIds = {};
  List<Produit> _produits = const [];
  bool _produitsLoading = false;
  bool _produitsLoaded = false;

  // ─ Submit ─────────────────────────────────────────────────────────
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Pré-charge le catalogue de produits dès l'ouverture pour éviter
    // une attente quand l'utilisateur passe à l'étape 2.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProduits());
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
        return _regionId != null;
      case 1:
        return _produitIds.isNotEmpty;
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
        role: UserRole.farmer,
        profile: {
          'region_id': _regionId,
          'cultures_principales': _produitIds.toList(),
        },
      );
      // Rafraîchit le user (essential_fields_complete = true côté back).
      final fresh = await auth.me();
      if (!mounted) return;
      ref.read(authStateProvider.notifier).setAuthenticated(fresh);
      // Le guard redirige automatiquement vers l'accueil producteur.
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
      title: _step == 0 ? 'Où es-tu ?' : 'Qu\'est-ce que tu cultives ?',
      subtitle: _step == 0
          ? 'Choisis ta région principale. Ça nous aide à te connecter aux bons acheteurs.'
          : 'Sélectionne au moins une culture. Tu pourras en ajouter d\'autres plus tard.',
      ctaLabel: isLast ? 'Terminer' : 'Continuer',
      onCta: _stepValid ? _onCta : null,
      busy: _busy,
      child: _step == 0 ? _buildRegionStep() : _buildCulturesStep(),
    );
  }

  Widget _buildRegionStep() {
    return SelecteurRegionCi(
      selectedId: _regionId,
      onChanged: (r) => setState(() => _regionId = r.id),
    );
  }

  Widget _buildCulturesStep() {
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
              'Impossible de charger les cultures.',
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
              '${_produitIds.length} culture${_produitIds.length > 1 ? "s" : ""} sélectionnée${_produitIds.length > 1 ? "s" : ""}',
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
            child: _CultureRow(
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
}

class _CultureRow extends StatelessWidget {
  const _CultureRow({
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
