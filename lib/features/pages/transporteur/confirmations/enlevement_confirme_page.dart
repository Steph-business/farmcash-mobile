import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const String _kPhoto =
    'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=200&h=200&fit=crop&auto=format';

/// Confirmation d'enlèvement chez le producteur — hero check vert,
/// récap mission, mini timeline et CTA pour démarrer la livraison.
class EnlevementConfirmePage extends ConsumerWidget {
  const EnlevementConfirmePage({required this.missionId, super.key});

  final String missionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(title: 'Enlèvement confirmé'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: const [
                  _HeroCheck(
                    title: 'Colis chargé !',
                    subtitle: 'Yao Konan a été crédité de 169 750 F',
                  ),
                  AppDimens.vGap24,
                  _RecapCard(),
                  AppDimens.vGap16,
                  _SectionTitle('Prochaine étape'),
                  AppDimens.vGap8,
                  _MiniTimeline(
                    items: [
                      _TlData(
                        icon: Icons.check,
                        label: 'Enlèvement confirmé',
                        state: _TlState.done,
                      ),
                      _TlData(
                        icon: Icons.local_shipping,
                        label: 'Livraison en cours',
                        state: _TlState.current,
                      ),
                      _TlData(
                        icon: Icons.qr_code_scanner,
                        label: 'Scan QR livraison chez acheteur',
                        state: _TlState.pending,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _StickyBar(missionId: missionId),
          ],
        ),
      ),
    );
  }
}

// ─── Header (centré + X à droite) ───────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
              color: AppColors.border, width: AppDimens.borderThin),
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
          const SizedBox(width: 40),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.close, size: 22, color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero check ─────────────────────────────────────────────────────────

class _HeroCheck extends StatelessWidget {
  const _HeroCheck({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.check, size: 44, color: Colors.white),
        ),
        AppDimens.vGap16,
        Text(
          title,
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Recap card ─────────────────────────────────────────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: _kPhoto,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                  width: 64, height: 64, color: AppColors.surfaceSoft),
              errorWidget: (_, _, _) => Container(
                width: 64,
                height: 64,
                color: AppColors.surfaceSoft,
                child: const Icon(Icons.image_outlined,
                    size: 22, color: AppColors.textSubtle),
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
                  'Maïs grain blanc',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '500 kg · Yao Konan',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vers Restaurant Le Baoulé · Cocody',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

// ─── Section title ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ─── Mini timeline ──────────────────────────────────────────────────────

enum _TlState { done, current, pending }

class _TlData {
  const _TlData({
    required this.icon,
    required this.label,
    required this.state,
  });

  final IconData icon;
  final String label;
  final _TlState state;
}

class _MiniTimeline extends StatelessWidget {
  const _MiniTimeline({required this.items});

  final List<_TlData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++)
            _MiniTlRow(data: items[i], isLast: i == items.length - 1),
        ],
      ),
    );
  }
}

class _MiniTlRow extends StatelessWidget {
  const _MiniTlRow({required this.data, required this.isLast});

  final _TlData data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    Color circleBg;
    Color iconColor;
    switch (data.state) {
      case _TlState.done:
        circleBg = AppColors.primary;
        iconColor = Colors.white;
      case _TlState.current:
        circleBg = _kPrimarySoft;
        iconColor = AppColors.primary;
      case _TlState.pending:
        circleBg = AppColors.surfaceSoft;
        iconColor = AppColors.textSubtle;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: circleBg,
              shape: BoxShape.circle,
              border: data.state == _TlState.pending
                  ? Border.all(
                      color: AppColors.border, width: AppDimens.borderThin)
                  : null,
            ),
            alignment: Alignment.center,
            child: Icon(data.icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: data.state == _TlState.pending
                    ? FontWeight.w500
                    : FontWeight.w600,
                color: data.state == _TlState.pending
                    ? AppColors.textSecondary
                    : AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky bar ─────────────────────────────────────────────────────────

class _StickyBar extends StatelessWidget {
  const _StickyBar({required this.missionId});

  final String missionId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
              color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () => context.push(
            RouteNames.transporteurMissionEnRoutePathFor(
                missionId.isEmpty ? 'M-2026-0089' : missionId),
          ),
          icon: const Icon(Icons.local_shipping, size: 20),
          label: Text(
            'Démarrer la livraison',
            style: AppTextStyles.button.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}

