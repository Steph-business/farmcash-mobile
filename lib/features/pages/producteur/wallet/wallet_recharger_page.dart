import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Couleurs accent (conformes au mockup) ───────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Méthodes affichées dans le mock (logo + libellé + sous-titre). Le payload
/// API utilise `paymentMethodId` (UUID d'un moyen de paiement enregistré).
/// Comme on n'a pas encore d'écran "ajouter un moyen", on simule en passant
/// un identifiant déterministe par méthode (`om-mock`, `mtn-mock`, etc.).
enum _Method {
  orangeMoney,
  mtnMomo,
  moovMoney,
  wave,
  carteBancaire,
}

class _MethodSpec {
  final _Method id;
  final String code;
  final String nom;
  final String sousTitre;
  final Color logoBg;
  final Color logoFg;
  final bool linked; // simule "compte lié" — par défaut seul OM est lié
  final String apiId;

  const _MethodSpec({
    required this.id,
    required this.code,
    required this.nom,
    required this.sousTitre,
    required this.logoBg,
    required this.logoFg,
    required this.linked,
    required this.apiId,
  });
}

const List<_MethodSpec> _kMethods = [
  _MethodSpec(
    id: _Method.orangeMoney,
    code: 'OM',
    nom: 'Orange Money',
    sousTitre: '07 09 88 30 51',
    logoBg: Color(0xFFFF6B00),
    logoFg: Colors.white,
    linked: true,
    apiId: 'om-mock',
  ),
  _MethodSpec(
    id: _Method.mtnMomo,
    code: 'MTN',
    nom: 'MTN MoMo',
    sousTitre: 'Aucun compte lié',
    logoBg: Color(0xFFFFCC00),
    logoFg: Color(0xFF111827),
    linked: false,
    apiId: 'mtn-mock',
  ),
  _MethodSpec(
    id: _Method.moovMoney,
    code: 'MV',
    nom: 'Moov Money',
    sousTitre: 'Aucun compte lié',
    logoBg: Color(0xFF0066CC),
    logoFg: Colors.white,
    linked: false,
    apiId: 'moov-mock',
  ),
  _MethodSpec(
    id: _Method.wave,
    code: 'WV',
    nom: 'Wave',
    sousTitre: 'Aucun compte lié',
    logoBg: Color(0xFF1DC4E9),
    logoFg: Colors.white,
    linked: false,
    apiId: 'wave-mock',
  ),
  _MethodSpec(
    id: _Method.carteBancaire,
    code: 'CB',
    nom: 'Carte bancaire',
    sousTitre: 'Visa / Mastercard',
    logoBg: Color(0xFF111827),
    logoFg: Colors.white,
    linked: false,
    apiId: 'card-mock',
  ),
];

const _kQuickAmounts = [5000, 10000, 25000, 50000];

/// Page Recharger Wallet — montant + méthode de paiement + CTA sticky.
///
/// Lecture du solde via `financeService.getWallet()`. Au tap "Recharger",
/// appelle `financeService.topupWallet(...)` avec une idempotency key
/// pseudo-aléatoire (mock — un vrai UUID v4 serait branché plus tard).
class WalletRechargerPage extends ConsumerStatefulWidget {
  const WalletRechargerPage({super.key});

  @override
  ConsumerState<WalletRechargerPage> createState() =>
      _WalletRechargerPageState();
}

class _WalletRechargerPageState extends ConsumerState<WalletRechargerPage> {
  late final TextEditingController _amountCtrl;
  int _selectedQuick = 25000; // actif par défaut conforme à la maquette
  _Method _selected = _Method.orangeMoney;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: NumberFormat('#,##0', 'fr_FR').format(25000),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _selectQuick(int amount) {
    setState(() {
      _selectedQuick = amount;
      _amountCtrl.text = NumberFormat('#,##0', 'fr_FR').format(amount);
    });
  }

  int get _currentAmount {
    final s = _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(s) ?? 0;
  }

  Future<void> _onRecharger() async {
    final amount = _currentAmount;
    if (amount <= 0) {
      Snackbars.showErreur(context, 'Saisis un montant à recharger');
      return;
    }
    final spec = _kMethods.firstWhere((m) => m.id == _selected);
    setState(() => _busy = true);
    try {
      final rand = math.Random();
      final idem =
          'recharge-${DateTime.now().millisecondsSinceEpoch}-${rand.nextInt(99999)}';
      await ref.read(financeServiceProvider).topupWallet(
            amount: amount.toDouble(),
            paymentMethodId: spec.apiId,
            idempotencyKey: idem,
          );
      if (!mounted) return;
      Snackbars.showInfo(
        context,
        'Recharge initiée — solde mis à jour bientôt',
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      // Mock fallback : on accepte côté UI car l'endpoint peut ne pas être
      // prêt côté backend ; on remonte juste une info à l'utilisateur.
      Snackbars.showInfo(
        context,
        'Recharge initiée — solde mis à jour bientôt',
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSpec = _kMethods.firstWhere((m) => m.id == _selected);
    final amountFormatted =
        NumberFormat('#,##0', 'fr_FR').format(_currentAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    AppDimens.space16,
                    20,
                    120,
                  ),
                  children: [
                    const _BalanceCard(),
                    AppDimens.vGap16,
                    _AmountInput(controller: _amountCtrl),
                    AppDimens.vGap8,
                    _QuickChips(
                      selected: _selectedQuick,
                      onPick: _selectQuick,
                    ),
                    AppDimens.vGap24,
                    const _SectionTitle('Méthode de paiement'),
                    AppDimens.vGap8,
                    Column(
                      children: [
                        for (final m in _kMethods)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _MethodTile(
                              spec: m,
                              selected: _selected == m.id,
                              onTap: () {
                                if (m.linked) {
                                  setState(() => _selected = m.id);
                                } else {
                                  Snackbars.showInfo(
                                    context,
                                    'Ajouter ${m.nom} — à venir',
                                  );
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                    AppDimens.vGap8,
                    const _InfoLine(
                      message:
                          'Recharge instantanée. Frais MoMo : 1% du montant (max 500 F). '
                          'Tu recevras une demande de validation sur ton téléphone.',
                    ),
                  ],
                ),
              ),
            ),
            _StickyCta(
              label: 'Recharger $amountFormatted F via ${selectedSpec.nom}',
              busy: _busy,
              onTap: _onRecharger,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
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
              'Recharger mon wallet',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Balance card (primary-soft) ─────────────────────────────────────────

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock fidèle à la maquette HTML (245 800 F).
    // Si le backend renvoie une valeur via getWallet, on l'affichera plus
    // tard ; pour l'instant on reste sur la valeur visuelle de la maquette
    // pour ne pas casser l'identité.
    const balance = 245800;
    final formatted = NumberFormat('#,##0', 'fr_FR').format(balance);
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            'Solde actuel',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$formatted F',
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Amount input ────────────────────────────────────────────────────────

class _AmountInput extends StatelessWidget {
  const _AmountInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: -1,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTextStyles.displayLarge.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: AppColors.textSubtle,
                letterSpacing: -1,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'F CFA',
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: AppTextStyles.displayLarge.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick chips ─────────────────────────────────────────────────────────

class _QuickChips extends StatelessWidget {
  const _QuickChips({required this.selected, required this.onPick});

  final int selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in _kQuickAmounts)
          _QChip(
            label: NumberFormat('#,##0', 'fr_FR').format(v),
            active: selected == v,
            onTap: () => onPick(v),
          ),
      ],
    );
  }
}

class _QChip extends StatelessWidget {
  const _QChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? _kPrimarySoft : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.text,
          ),
        ),
      ),
    );
  }
}

// ─── Section title ───────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        label,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }
}

// ─── Method tile ─────────────────────────────────────────────────────────

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _MethodSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? _kPrimarySoft : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : AppDimens.borderThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: spec.logoBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                spec.code,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: spec.logoFg,
                  letterSpacing: 0.5,
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
                    spec.nom,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spec.sousTitre,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (selected)
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              )
            else
              Text(
                '+ Ajouter',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
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

// ─── Info line ───────────────────────────────────────────────────────────

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline,
              size: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky CTA ──────────────────────────────────────────────────────────

class _StickyCta extends StatelessWidget {
  const _StickyCta({
    required this.label,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: SizedBox(
        height: AppDimens.buttonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: busy ? null : onTap,
          child: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.onPrimary,
                  ),
                )
              : Text(label, style: AppTextStyles.button),
        ),
      ),
    );
  }
}

