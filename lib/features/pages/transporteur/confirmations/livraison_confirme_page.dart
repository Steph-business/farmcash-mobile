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

/// Provider qui cherche la mission livrée parmi les missions du
/// transporteur (statut DELIVERED).
final _missionLivreeProvider = FutureProvider.autoDispose
    .family<Livraison?, String>((ref, id) async {
  final svc = ref.read(logisticsServiceProvider);
  final list = await svc.getMyMissions();
  for (final m in list) {
    if (m.id == id) return m;
  }
  return null;
});

/// Confirmation finale de livraison + crédit wallet transporteur.
class LivraisonConfirmePage extends ConsumerWidget {
  const LivraisonConfirmePage({required this.missionId, super.key});

  final String missionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_missionLivreeProvider(missionId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(title: 'Livraison confirmée'),
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
    final prix = m?.prixFinal ?? m?.prixDevis;
    final montantTxt = prix != null
        ? '+${_nf.format(prix.round())} F crédités sur ton wallet'
        : 'Paiement en cours de crédit sur ton wallet';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        _HeroCheck(
          title: 'Livraison confirmée !',
          subtitle: montantTxt,
        ),
        AppDimens.vGap24,
        if (m != null) _RecapCard(mission: m),
        AppDimens.vGap16,
        if (prix != null) _CommissionBanner(montant: prix),
        if (prix != null) AppDimens.vGap16,
        const _SectionTitle('Étapes complétées'),
        AppDimens.vGap8,
        const _MiniTimeline(
          items: [
            _TlData(icon: Icons.check, label: 'Enlèvement confirmé'),
            _TlData(
                icon: Icons.check, label: 'Livraison confirmée chez acheteur'),
          ],
        ),
      ],
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

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
    final qte = mission.quantiteKg != null
        ? '${_nf.format(mission.quantiteKg!.round())} kg'
        : null;
    final ref = mission.reference;
    final trajet = mission.itineraireLabel ??
        '${mission.pickupAddress ?? '—'} → ${mission.deliveryAddress ?? '—'}';
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_circle,
              size: 26,
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
                  ref != null ? 'Commande #$ref' : 'Mission livrée',
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
                  'Livrée · $trajet',
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

// ─── Commission banner ──────────────────────────────────────────────────

class _CommissionBanner extends StatelessWidget {
  const _CommissionBanner({required this.montant});

  final double montant;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPrimarySoft, width: AppDimens.borderThin),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.account_balance_wallet,
                size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+${_nf.format(montant.round())} F',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Crédit immédiat sur ton wallet FarmCash',
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

// ─── Mini timeline (toutes done) ────────────────────────────────────────

class _TlData {
  const _TlData({required this.icon, required this.label});

  final IconData icon;
  final String label;
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
            Padding(
              padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child:
                        Icon(items[i].icon, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[i].label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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

// ─── Sticky bar (3 actions : évaluation, wallet, missions) ──────────────

class _StickyBar extends StatelessWidget {
  const _StickyBar({required this.missionId});

  final String missionId;

  @override
  Widget build(BuildContext context) {
    final id = missionId;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
              color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (id.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.push(
                  RouteNames.transporteurMissionEvaluationPathFor(id),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Évaluer le client',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () =>
                  context.push(RouteNames.transporteurWalletPath),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                    color: AppColors.primary, width: AppDimens.borderThin),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Voir mon wallet',
                style: AppTextStyles.button.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () =>
                context.go(RouteNames.transporteurMissionsPath),
            child: Text(
              'Retour aux missions',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
