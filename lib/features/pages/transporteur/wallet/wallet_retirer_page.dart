import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/snackbars.dart';

// ─── Couleurs accent (conformes au mockup) ───────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

const _kQuickAmounts = [10000, 50000, 100000]; // + chip "Tout"

/// Page Retirer Wallet transporteur — montant à retirer, destinataire (OM),
/// code PIN MoMo (visuel 2/4), CTA sticky « Confirmer le retrait ».
///
/// Note service : pas d'endpoint « withdraw » exposé ; à la confirmation on
/// affiche un snackbar puis on pop comme pour le producteur.
class WalletRetirerTransporteurPage extends ConsumerStatefulWidget {
  const WalletRetirerTransporteurPage({super.key});

  @override
  ConsumerState<WalletRetirerTransporteurPage> createState() =>
      _WalletRetirerTransporteurPageState();
}

class _WalletRetirerTransporteurPageState
    extends ConsumerState<WalletRetirerTransporteurPage> {
  late final TextEditingController _amountCtrl;
  int _selectedChip = 50000; // valeur par défaut conforme à la maquette
  bool _toutChipActive = false;
  static const double _kBalance = 145600;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: NumberFormat('#,##0', 'fr_FR').format(50000),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _pickChip(int amount) {
    setState(() {
      _selectedChip = amount;
      _toutChipActive = false;
      _amountCtrl.text = NumberFormat('#,##0', 'fr_FR').format(amount);
    });
  }

  void _pickAll() {
    setState(() {
      _toutChipActive = true;
      _selectedChip = -1;
      _amountCtrl.text =
          NumberFormat('#,##0', 'fr_FR').format(_kBalance.toInt());
    });
  }

  void _onConfirmer() {
    Snackbars.showInfo(context, 'Demande de retrait envoyée');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                      selected: _selectedChip,
                      toutActive: _toutChipActive,
                      onPick: _pickChip,
                      onPickAll: _pickAll,
                    ),
                    AppDimens.vGap24,
                    const _SectionTitle('Destinataire'),
                    AppDimens.vGap8,
                    const _DestinataireSelector(),
                    AppDimens.vGap16,
                    const _SectionTitle('Code PIN MoMo'),
                    AppDimens.vGap8,
                    const _PinDots(),
                    AppDimens.vGap8,
                    const _InfoLine(
                      message:
                          'Le retrait sera disponible dans ~5 minutes. '
                          'Frais MoMo : 0 F (offert par FarmCash).',
                    ),
                  ],
                ),
              ),
            ),
            _StickyCta(onTap: _onConfirmer),
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
              'Retirer mon argent',
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,##0', 'fr_FR').format(145600);
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
            'Solde disponible',
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
  const _QuickChips({
    required this.selected,
    required this.toutActive,
    required this.onPick,
    required this.onPickAll,
  });

  final int selected;
  final bool toutActive;
  final ValueChanged<int> onPick;
  final VoidCallback onPickAll;

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
            highlighted: false,
            active: !toutActive && selected == v,
            onTap: () => onPick(v),
          ),
        // « Tout » → bordure verte permanente
        _QChip(
          label: 'Tout',
          highlighted: true,
          active: toutActive,
          onTap: onPickAll,
        ),
      ],
    );
  }
}

class _QChip extends StatelessWidget {
  const _QChip({
    required this.label,
    required this.highlighted,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool highlighted;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? _kPrimarySoft
        : (highlighted ? AppColors.background : AppColors.surfaceSoft);
    final borderColor =
        (highlighted || active) ? AppColors.primary : AppColors.border;
    final fg = (highlighted || active) ? AppColors.primary : AppColors.text;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: AppDimens.borderThin),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
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

// ─── Destinataire selector ───────────────────────────────────────────────

class _DestinataireSelector extends StatelessWidget {
  const _DestinataireSelector();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.border, width: AppDimens.borderThin),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                'OM',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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
                    'Mon numéro MoMo',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '07 11 22 33 44 · Orange Money',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PIN dots (visuel 2/4) ───────────────────────────────────────────────

class _PinDots extends StatelessWidget {
  const _PinDots();

  @override
  Widget build(BuildContext context) {
    // 2 remplis, 2 vides — strictement la maquette transporteur.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PinDot(filled: true),
          const SizedBox(width: 14),
          _PinDot(filled: true),
          const SizedBox(width: 14),
          _PinDot(filled: false),
          const SizedBox(width: 14),
          _PinDot(filled: false),
        ],
      ),
    );
  }
}

class _PinDot extends StatelessWidget {
  // ignore: unused_element_parameter
  const _PinDot({this.filled = false});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 54,
      decoration: BoxDecoration(
        color: filled ? AppColors.background : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: filled ? AppColors.primary : AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      alignment: Alignment.center,
      child: filled
          ? Text(
              '●',
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            )
          : Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textSubtle.withValues(alpha: 0.4),
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
  const _StickyCta({required this.onTap});

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
          onPressed: onTap,
          child: Text('Confirmer le retrait', style: AppTextStyles.button),
        ),
      ),
    );
  }
}

