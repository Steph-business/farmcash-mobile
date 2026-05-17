import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

// ─── Couleurs accent (conformes au mockup) ───────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Distribution mock conforme à la maquette HTML.
class _PayoutMock {
  final String id;
  final String titre;
  final String sousTitre;
  final String date;
  const _PayoutMock({
    required this.id,
    required this.titre,
    required this.sousTitre,
    required this.date,
  });
}

const List<_PayoutMock> _kPayouts = [
  _PayoutMock(
    id: 'po-mais-blanc-500',
    titre: 'Publication Maïs blanc · 500 kg',
    sousTitre: '4 farmers contributeurs · 175 000 F net',
    date: 'Vente clôturée 12/05',
  ),
  _PayoutMock(
    id: 'po-manioc-1t',
    titre: 'Publication Manioc · 1 t',
    sousTitre: '6 farmers contributeurs · 95 000 F net',
    date: 'Vente clôturée 11/05',
  ),
  _PayoutMock(
    id: 'po-riz-200',
    titre: 'Publication Riz local · 200 kg',
    sousTitre: '2 farmers contributeurs · 72 000 F net',
    date: 'Vente clôturée 10/05',
  ),
  _PayoutMock(
    id: 'po-igname-300',
    titre: 'Publication Igname · 300 kg',
    sousTitre: '3 farmers contributeurs · 48 000 F net',
    date: 'Vente clôturée 09/05',
  ),
  _PayoutMock(
    id: 'po-cacao-80',
    titre: 'Publication Cacao fève · 80 kg',
    sousTitre: '2 farmers contributeurs · 35 000 F net',
    date: 'Vente clôturée 08/05',
  ),
];

/// Tabs disponibles sur la liste des distributions.
enum _PayoutTab { aDistribuer, historique }

/// Page Distributions coopérative — liste des publications clôturées
/// pour lesquelles la coop doit payer les contributeurs.
/// Reproduction fidèle de `mockups/cooperative/payouts.html`.
class PayoutsCooperativePage extends StatefulWidget {
  const PayoutsCooperativePage({super.key});

  @override
  State<PayoutsCooperativePage> createState() => _PayoutsCooperativePageState();
}

class _PayoutsCooperativePageState extends State<PayoutsCooperativePage> {
  _PayoutTab _tab = _PayoutTab.aDistribuer;

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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  0,
                  AppDimens.pagePaddingH,
                  AppDimens.space16,
                ),
                children: [
                  // Compteur primary-soft : total à distribuer
                  const _CounterCard(
                    value: '5 distributions à faire',
                    sub: '425 000 F total',
                  ),
                  AppDimens.vGap16,
                  _TabsBar(
                    tab: _tab,
                    onChange: (t) => setState(() => _tab = t),
                  ),
                  AppDimens.vGap16,
                  for (final p in _kPayouts) ...[
                    _PayoutCard(payout: p),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space16,
        AppDimens.space8,
        AppDimens.space16,
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
              'Distributions',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.search, size: 20, color: AppColors.text),
          ),
          _NotifsButton(
            onTap: () => context.push(RouteNames.cooperativeNotificationsPath),
          ),
        ],
      ),
    );
  }
}

class _NotifsButton extends StatelessWidget {
  const _NotifsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.notifications_none,
                size: 22,
                color: AppColors.text,
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.background,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '5',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
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

// ─── Counter card (primary-soft) ─────────────────────────────────────────

class _CounterCard extends StatelessWidget {
  const _CounterCard({required this.value, required this.sub});

  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tabs (À distribuer / Historique) ────────────────────────────────────

class _TabsBar extends StatelessWidget {
  const _TabsBar({required this.tab, required this.onChange});

  final _PayoutTab tab;
  final ValueChanged<_PayoutTab> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'À distribuer (${_kPayouts.length})',
            active: tab == _PayoutTab.aDistribuer,
            onTap: () => onChange(_PayoutTab.aDistribuer),
          ),
          _TabItem(
            label: 'Historique',
            active: tab == _PayoutTab.historique,
            onTap: () => onChange(_PayoutTab.historique),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Payout card ─────────────────────────────────────────────────────────

class _PayoutCard extends StatelessWidget {
  const _PayoutCard({required this.payout});

  final _PayoutMock payout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            payout.titre,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            payout.sousTitre,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            payout.date,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.textSubtle,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const _ChipStatus(label: 'Prête à distribuer'),
              const Spacer(),
              _MiniButton(
                label: 'Distribuer',
                onTap: () => context.push(
                  RouteNames.cooperativePayoutDetailPathFor(payout.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipStatus extends StatelessWidget {
  const _ChipStatus({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

