import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/membre_coop.dart';
import '../../../../models/portefeuille.dart';
import '../../../../models/wallet_with_transactions.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// ─── Provider ───────────────────────────────────────────────────────

/// Bundle initial : membres + solde du wallet coop.
class _AvanceBundle {
  const _AvanceBundle({required this.membres, this.wallet});
  final List<MembreCoop> membres;
  final Portefeuille? wallet;
}

final _avanceBundleProvider =
    FutureProvider.autoDispose<_AvanceBundle>((ref) async {
  final coop = ref.read(cooperativesServiceProvider);
  final finance = ref.read(financeServiceProvider);
  final results = await Future.wait<dynamic>([
    coop.listMembers().then<Object?>((v) => v),
    finance
        .getWallet(limit: 1)
        .then<Object?>((v) => v)
        .catchError((_) => null),
  ]);
  final membresPage = results[0] as dynamic;
  final list = (membresPage.data as List<MembreCoop>);
  final walletBundle = results[1] as WalletWithTransactions?;
  return _AvanceBundle(membres: list, wallet: walletBundle?.wallet);
});

/// Verser une avance à un membre. Appelle réellement `payAdvance`
/// — qui crée la ligne `coop_advance_payments` côté back, débite le wallet
/// coop et crédite le farmer (transaction atomique).
class VerserAvancePage extends ConsumerStatefulWidget {
  const VerserAvancePage({super.key, this.membreIdInitial});

  final String? membreIdInitial;

  @override
  ConsumerState<VerserAvancePage> createState() => _VerserAvancePageState();
}

class _VerserAvancePageState extends ConsumerState<VerserAvancePage> {
  final _montantCtrl = TextEditingController();
  final _motifCtrl = TextEditingController();
  MembreCoop? _membre;
  bool _busy = false;
  bool _hydrated = false;

  @override
  void dispose() {
    _montantCtrl.dispose();
    _motifCtrl.dispose();
    super.dispose();
  }

  /// Pré-sélectionne le membre si `membreIdInitial` est passé.
  void _hydrateOnce(_AvanceBundle bundle) {
    if (_hydrated) return;
    _hydrated = true;
    if (widget.membreIdInitial != null && bundle.membres.isNotEmpty) {
      for (final m in bundle.membres) {
        if (m.userId == widget.membreIdInitial || m.id == widget.membreIdInitial) {
          _membre = m;
          break;
        }
      }
    }
  }

  int get _montantValeur {
    final raw = _montantCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 0;
  }

  Future<void> _choisirMembre(List<MembreCoop> membres) async {
    if (_busy) return;
    final selected = await showModalBottomSheet<MembreCoop>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _MembreSheet(membres: membres, selectedId: _membre?.id),
    );
    if (selected != null && mounted) {
      setState(() => _membre = selected);
    }
  }

  Future<void> _verser(double soldeCoop) async {
    if (_busy) return;
    if (_membre == null) {
      Snackbars.showErreur(context, 'Choisis d\'abord un membre.');
      return;
    }
    final montant = _montantValeur;
    if (montant <= 0) {
      Snackbars.showErreur(context, 'Saisis un montant valide.');
      return;
    }
    if (montant > soldeCoop) {
      Snackbars.showErreur(
        context,
        'Solde insuffisant. Solde coop : ${_fmtFcfa(soldeCoop)} F.',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(cooperativesServiceProvider).payAdvance(
            farmerId: _membre!.userId,
            amount: montant.toDouble(),
            motif: _motifCtrl.text.trim().isEmpty
                ? null
                : _motifCtrl.text.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Avance de ${_fmtFcfa(montant.toDouble())} F versée à ${_membre!.fullName ?? 'le membre'}.',
      );
      // Force le refresh du wallet/avances dans le reste de l'app.
      ref.invalidate(_avanceBundleProvider);
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(RouteNames.accueilCooperativePath);
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_avanceBundleProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Column(
            children: [
              _Header(),
              Expanded(child: Chargement(size: 22)),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const _Header(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les membres. $e',
                    onRetry: () => ref.invalidate(_avanceBundleProvider),
                  ),
                ),
              ),
            ],
          ),
          data: (bundle) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _hydrateOnce(bundle);
            });
            return _build(bundle);
          },
        ),
      ),
    );
  }

  Widget _build(_AvanceBundle bundle) {
    final soldeCoop = bundle.wallet?.balance ?? 0;
    return Column(
      children: [
        const _Header(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePaddingH,
              0,
              AppDimens.pagePaddingH,
              AppDimens.space16,
            ),
            children: [
              const _FieldLabel('Membre'),
              AppDimens.vGap8,
              if (_membre == null)
                _ChoisirMembreButton(
                  onTap: () => _choisirMembre(bundle.membres),
                )
              else
                _SelectedMember(
                  membre: _membre!,
                  onChange: () => _choisirMembre(bundle.membres),
                ),
              if (bundle.membres.isEmpty) ...[
                AppDimens.vGap8,
                Text(
                  'Aucun membre dans ta coopérative.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              AppDimens.vGap16,
              _CoopBalanceCard(solde: soldeCoop),
              AppDimens.vGap24,
              _AmountBlock(controller: _montantCtrl),
              AppDimens.vGap24,
              const _FieldLabel('Motif (optionnel)'),
              AppDimens.vGap8,
              _MotifInput(controller: _motifCtrl, enabled: !_busy),
            ],
          ),
        ),
        _StickyVerserButton(
          montant: _montantValeur,
          busy: _busy,
          enabled: _membre != null && _montantValeur > 0,
          onTap: () => _verser(soldeCoop),
        ),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(RouteNames.accueilCooperativePath),
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
              'Verser une avance',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}

// ─── Sélection membre ───────────────────────────────────────────

class _ChoisirMembreButton extends StatelessWidget {
  const _ChoisirMembreButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brCard,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_add_alt_1,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Choisir un membre',
              style: AppTextStyles.labelLarge.copyWith(
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

class _SelectedMember extends StatelessWidget {
  const _SelectedMember({required this.membre, required this.onChange});
  final MembreCoop membre;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final nom = membre.fullName ?? 'Membre';
    final phone = membre.phone ?? '';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _initiales(nom),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onChange,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              child: Text(
                'Changer',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom-sheet de sélection ─────────────────────────────────────

class _MembreSheet extends StatelessWidget {
  const _MembreSheet({required this.membres, this.selectedId});
  final List<MembreCoop> membres;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choisir un membre',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: membres.length,
                itemBuilder: (_, i) {
                  final m = membres[i];
                  final selected = m.id == selectedId;
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _kPrimarySoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initiales(m.fullName ?? '?'),
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      m.fullName ?? 'Membre',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: m.phone != null
                        ? Text(
                            m.phone!,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : null,
                    trailing: selected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(m),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Carte solde coop ──────────────────────────────────────────────

class _CoopBalanceCard extends StatelessWidget {
  const _CoopBalanceCard({required this.solde});
  final double solde;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
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
              Icons.account_balance_wallet_outlined,
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
                Text(
                  'Solde coop disponible',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmtFcfa(solde)} F',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 16,
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
}

// ─── Bloc montant ──────────────────────────────────────────────────

class _AmountBlock extends StatelessWidget {
  const _AmountBlock({required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Montant à verser',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            color: AppColors.text,
          ),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
            hintText: '0',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'FCFA',
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            color: AppColors.textSubtle,
          ),
        ),
      ],
    );
  }
}

class _MotifInput extends StatelessWidget {
  const _MotifInput({required this.controller, required this.enabled});
  final TextEditingController controller;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brInput,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: 'Ex : Avance récolte juin',
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSubtle,
          ),
        ),
        style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
      ),
    );
  }
}

// ─── Sticky bottom ──────────────────────────────────────────────────

class _StickyVerserButton extends StatelessWidget {
  const _StickyVerserButton({
    required this.montant,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });
  final int montant;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final actif = enabled && !busy;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: actif ? onTap : null,
          borderRadius: AppDimens.brCard,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: actif ? AppColors.primary : AppColors.borderStrong,
              borderRadius: AppDimens.brCard,
            ),
            alignment: Alignment.center,
            child: busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    montant > 0
                        ? 'Verser ${_fmtFcfa(montant.toDouble())} F maintenant'
                        : 'Saisir un montant',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');

String _fmtFcfa(double v) => _nf.format(v.round());

String _initiales(String s) {
  final t = s.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'[\s\-_]+'))..removeWhere((p) => p.isEmpty);
  if (parts.length >= 2) {
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  if (t.length == 1) return t.toUpperCase();
  return t.substring(0, 2).toUpperCase();
}
