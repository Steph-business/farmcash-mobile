import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

// ─── Couleurs & photos (alignées maquette HTML) ─────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);

// Photos contributeurs (Unsplash — portraits neutres).
const String _kPhotoYao =
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce'
    '?w=120&h=120&fit=crop&auto=format';
const String _kPhotoAya =
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2'
    '?w=120&h=120&fit=crop&auto=format';
const String _kPhotoKouame =
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e'
    '?w=120&h=120&fit=crop&auto=format';
const String _kPhotoAkissi =
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9'
    '?w=120&h=120&fit=crop&auto=format';

/// Contributeur mock d'une distribution.
class _ContribMock {
  final String photo;
  final String nom; // FULL — la coop voit ses membres en clair (règle 3b).
  final String qty;
  final String pct;
  final String montant;
  const _ContribMock({
    required this.photo,
    required this.nom,
    required this.qty,
    required this.pct,
    required this.montant,
  });
}

const List<_ContribMock> _kContribs = [
  _ContribMock(
    photo: _kPhotoYao,
    nom: 'Yao Konan',
    qty: '175 kg',
    pct: '35%',
    montant: '61 250 F',
  ),
  _ContribMock(
    photo: _kPhotoAya,
    nom: 'Aya Diomandé',
    qty: '150 kg',
    pct: '30%',
    montant: '52 500 F',
  ),
  _ContribMock(
    photo: _kPhotoKouame,
    nom: 'Kouamé Brou',
    qty: '100 kg',
    pct: '20%',
    montant: '35 000 F',
  ),
  _ContribMock(
    photo: _kPhotoAkissi,
    nom: "Akissi N'Guessan",
    qty: '75 kg',
    pct: '15%',
    montant: '26 250 F',
  ),
];

/// Page Distribution détail — répartition entre contributeurs + frais
/// avant validation. Reproduction fidèle de
/// `mockups/cooperative/distribution_detail.html`.
///
/// CRITIQUE — règle 3b : la coop voit ses membres FULL (nom complet).
class DistributionDetailPage extends StatelessWidget {
  const DistributionDetailPage({super.key, required this.payoutId});

  /// Identifiant du payout (pour future API
  /// `financeService.getPayout(id)`).
  final String payoutId;

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
                children: const [
                  _HeroInfo(),
                  AppDimens.vGap24,
                  _SectionContribs(),
                  AppDimens.vGap24,
                  _SectionFrais(),
                ],
              ),
            ),
            _StickyConfirm(payoutId: payoutId),
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
                : context.go(RouteNames.cooperativePayoutsPath),
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
              'Distribution Maïs blanc',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

// ─── Hero info ───────────────────────────────────────────────────────────

class _HeroInfo extends StatelessWidget {
  const _HeroInfo();

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
            'Vente du 12/05/2026',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '500 kg @ 350 F/kg',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '175 000 F net',
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

// ─── Section contributeurs ───────────────────────────────────────────────

class _SectionContribs extends StatelessWidget {
  const _SectionContribs();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Répartition entre contributeurs',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _ContribsCard(items: _kContribs),
        const SizedBox(height: 10),
        const _TotalRow(label: 'Total contributeurs', value: '175 000 F'),
      ],
    );
  }
}

class _ContribsCard extends StatelessWidget {
  const _ContribsCard({required this.items});

  final List<_ContribMock> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(items.length, (i) {
          return _ContribRow(item: items[i], isLast: i == items.length - 1);
        }),
      ),
    );
  }
}

class _ContribRow extends StatelessWidget {
  const _ContribRow({required this.item, required this.isLast});

  final _ContribMock item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar 36x36 (Unsplash, fallback initiales)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: item.photo,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(color: _kPrimarySoft),
              errorWidget: (_, _, _) => Center(
                child: Text(
                  _initiales(item.nom),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
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
                  // FULL — coop voit ses membres en clair
                  item.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${item.qty} · ',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextSpan(
                        text: item.pct,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.montant,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: AppTextStyles.displayLarge.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontFamily: AppTextStyles.displayLarge.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section frais ───────────────────────────────────────────────────────

class _SectionFrais extends StatelessWidget {
  const _SectionFrais();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Frais déduits',
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppDimens.brCard,
            border: Border.all(
              color: AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: const Column(
            children: [
              _FeeRow(label: 'Commission plateforme 3%', value: '-5 250 F'),
              _FeeRow(
                label: 'Net distribuable',
                value: '169 750 F',
                isNet: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({
    required this.label,
    required this.value,
    this.isNet = false,
  });

  final String label;
  final String value;
  final bool isNet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isNet ? AppColors.surfaceSoft : AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: isNet ? Colors.transparent : AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: isNet ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: AppTextStyles.displayLarge.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isNet ? AppColors.primary : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky bottom : Confirmer la distribution ──────────────────────────

class _StickyConfirm extends StatelessWidget {
  const _StickyConfirm({required this.payoutId});

  final String payoutId;

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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: () => context.push(
            RouteNames.cooperativePayoutConfirmationPathFor(payoutId),
          ),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary,
                width: AppDimens.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Confirmer la distribution',
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 15,
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

// ─── Helpers ─────────────────────────────────────────────────────────────

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
