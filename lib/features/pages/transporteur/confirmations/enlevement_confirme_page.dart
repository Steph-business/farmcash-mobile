import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/livraison.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Provider qui récupère une mission via `getMyMissions()` (la mission est
/// nécessairement acceptée par le transporteur à ce stade — sinon elle ne
/// serait pas LOADING).
final _missionByIdProvider = FutureProvider.autoDispose
    .family<Livraison?, String>((ref, id) async {
  final svc = ref.read(logisticsServiceProvider);
  final list = await svc.getMyMissions();
  for (final m in list) {
    if (m.id == id) return m;
  }
  return null;
});

/// Confirmation d'enlèvement chez le producteur — hero check vert,
/// récap mission, mini timeline et CTA pour démarrer la livraison.
class EnlevementConfirmePage extends ConsumerWidget {
  const EnlevementConfirmePage({required this.missionId, super.key});

  final String missionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_missionByIdProvider(missionId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(title: 'Enlèvement confirmé'),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (_, _) => _Contenu(mission: null),
                data: (m) => _Contenu(mission: m),
              ),
            ),
            _StickyBar(missionId: missionId),
          ],
        ),
      ),
    );
  }
}

class _Contenu extends StatelessWidget {
  const _Contenu({required this.mission});

  final Livraison? mission;

  @override
  Widget build(BuildContext context) {
    final m = mission;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const _HeroCheck(
          title: 'Colis chargé !',
          subtitle: 'Direction le point de livraison',
        ),
        AppDimens.vGap24,
        if (m != null) _RecapCard(mission: m),
        AppDimens.vGap16,
        const _SectionTitle('Prochaine étape'),
        AppDimens.vGap8,
        const _MiniTimeline(
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
  const _RecapCard({required this.mission});

  final Livraison mission;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final qte = mission.quantiteKg != null
        ? '${nf.format(mission.quantiteKg!.round())} kg'
        : null;
    final ref = mission.reference;
    final trajet = mission.itineraireLabel ??
        '${mission.pickupAddress ?? '—'} → ${mission.deliveryAddress ?? '—'}';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 22,
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
                  ref != null ? 'Commande #$ref' : 'Mission en cours',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (qte != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    qte,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  trajet,
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
          onPressed: missionId.isEmpty
              ? null
              : () => context.push(
                    RouteNames.transporteurMissionEnRoutePathFor(missionId),
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
