// =====================================================================
//  Page : Détail d'un plan d'approvisionnement (acheteur)
//  ---------------------------------------------------------------------
//  Affiche les infos du plan + la liste des candidatures reçues.
//  L'acheteur peut accepter ou rejeter chaque candidature. Acceptation
//  → crée un contract + bascule plan ACTIVE.
//
//  Chantier 2 — Phase 4 mobile.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/supply_plan.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/entete_page_compacte_acheteur.dart';
import '../../../widgets/communs/snackbars.dart';

/// Bundle = plan + candidatures (2 appels parallélisés).
class _DetailPlanBundle {
  _DetailPlanBundle({required this.plan, required this.candidatures});
  final SupplyPlan plan;
  final List<Map<String, dynamic>> candidatures;
}

final _detailPlanBundleProvider = FutureProvider.autoDispose
    .family<_DetailPlanBundle, String>((ref, planId) async {
  final svc = ref.watch(supplyPlansServiceProvider);
  final results = await Future.wait([
    svc.getPlanById(planId),
    svc.listCandidatures(planId),
  ]);
  return _DetailPlanBundle(
    plan: results[0] as SupplyPlan,
    candidatures: results[1] as List<Map<String, dynamic>>,
  );
});

class DetailPlanPage extends ConsumerWidget {
  const DetailPlanPage({super.key, required this.planId});
  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundleAsync = ref.watch(_detailPlanBundleProvider(planId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageCompacteAcheteur(title: 'Détail du plan'),
            Expanded(
              child: bundleAsync.when(
                data: (b) => RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(_detailPlanBundleProvider(planId)),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      _CarteInfoPlan(plan: b.plan),
                      const SizedBox(height: 16),
                      _SectionCandidatures(
                        candidatures: b.candidatures,
                        canAct: b.plan.status == 'PUBLISHED' ||
                            b.plan.status == 'NEGOTIATING',
                        onAccept: (id) =>
                            _accepter(context, ref, id, planId),
                        onReject: (id) =>
                            _rejeter(context, ref, id, planId),
                      ),
                    ],
                  ),
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Erreur : $e',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _accepter(
    BuildContext context,
    WidgetRef ref,
    String candidatureId,
    String planId,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accepter cette candidature ?'),
        content: const Text(
          'Un contrat sera créé immédiatement et activé. '
          'Tu pourras accepter d\'autres candidatures si tu veux couvrir '
          'plusieurs fournisseurs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref
          .read(supplyPlansServiceProvider)
          .acceptCandidature(candidatureId);
      if (context.mounted) {
        Snackbars.showSucces(context, 'Candidature acceptée · contrat créé.');
      }
      ref.invalidate(_detailPlanBundleProvider(planId));
    } on ApiException catch (e) {
      if (context.mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (context.mounted) Snackbars.showErreurInattendue(context, e);
    }
  }

  Future<void> _rejeter(
    BuildContext context,
    WidgetRef ref,
    String candidatureId,
    String planId,
  ) async {
    final motifCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeter cette candidature ?'),
        content: TextField(
          controller: motifCtrl,
          maxLines: 3,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Motif (optionnel — visible côté fournisseur)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF991B1B),
            ),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(supplyPlansServiceProvider).rejectCandidature(
            candidatureId,
            motif: motifCtrl.text.trim().isEmpty
                ? null
                : motifCtrl.text.trim(),
          );
      if (context.mounted) {
        Snackbars.showSucces(context, 'Candidature rejetée.');
      }
      ref.invalidate(_detailPlanBundleProvider(planId));
    } on ApiException catch (e) {
      if (context.mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (context.mounted) Snackbars.showErreurInattendue(context, e);
    }
  }
}

// ───────────────────────────────────────────────────────────────────
//  Carte info plan
// ───────────────────────────────────────────────────────────────────

class _CarteInfoPlan extends StatelessWidget {
  const _CarteInfoPlan({required this.plan});
  final SupplyPlan plan;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final statusColor = _colorForStatus(plan.status);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.factory_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  plan.produitNom ?? 'Plan',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  labelStatutPlan(plan.status),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (plan.status == 'REJECTED' &&
              plan.adminRejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 16,
                    color: Color(0xFF991B1B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Motif : ${plan.adminRejectionReason}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF991B1B),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          _ligne(
            'Volume mensuel',
            '${nf.format(plan.qtyPerMonthKg.round())} kg / mois',
          ),
          _ligne(
            'Durée',
            '${plan.durationMonths} mois',
          ),
          _ligne(
            'Prix proposé',
            '${nf.format(plan.pricePerKg.round())} F / kg',
          ),
          _ligne(
            'Démarrage',
            plan.formatStartMonth(),
          ),
          _ligne(
            'Livraison',
            '${plan.deliveryCity} · ${plan.deliveryAddress}',
            multiline: true,
          ),
          if (plan.notes != null && plan.notes!.isNotEmpty)
            _ligne('Notes', plan.notes!, multiline: true),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Valeur totale engagée',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              Text(
                '${nf.format(plan.totalValue.round())} F',
                style: AppTextStyles.titleSmall.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ligne(String label, String value, {bool multiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                height: multiline ? 1.4 : 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForStatus(String status) {
    switch (status) {
      case 'PUBLISHED':
      case 'ACTIVE':
        return AppColors.primary;
      case 'NEGOTIATING':
        return const Color(0xFFD97706);
      case 'PENDING_VALIDATION':
        return const Color(0xFF6B7280);
      case 'REJECTED':
      case 'CANCELLED':
        return const Color(0xFF991B1B);
      case 'COMPLETED':
        return const Color(0xFF1B7F3A);
      default:
        return AppColors.textSecondary;
    }
  }
}

// ───────────────────────────────────────────────────────────────────
//  Section candidatures
// ───────────────────────────────────────────────────────────────────

class _SectionCandidatures extends StatelessWidget {
  const _SectionCandidatures({
    required this.candidatures,
    required this.canAct,
    required this.onAccept,
    required this.onReject,
  });

  final List<Map<String, dynamic>> candidatures;
  final bool canAct;
  final ValueChanged<String> onAccept;
  final ValueChanged<String> onReject;

  @override
  Widget build(BuildContext context) {
    if (candidatures.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.handshake_outlined,
              size: 32,
              color: AppColors.textSubtle,
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune candidature pour l\'instant',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Les fournisseurs verront ton plan dès qu\'il sera publié. '
              'Tu recevras une notif à chaque candidature.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Candidatures reçues (${candidatures.length})',
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...candidatures.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CarteCandidature(
              data: c,
              canAct: canAct,
              onAccept: onAccept,
              onReject: onReject,
            ),
          ),
        ),
      ],
    );
  }
}

class _CarteCandidature extends StatelessWidget {
  const _CarteCandidature({
    required this.data,
    required this.canAct,
    required this.onAccept,
    required this.onReject,
  });

  final Map<String, dynamic> data;
  final bool canAct;
  final ValueChanged<String> onAccept;
  final ValueChanged<String> onReject;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final id = data['id'] as String;
    final status = (data['status'] as String?) ?? 'PENDING';
    final qty = _toDouble(data['qty_offered_kg']);
    final months = (data['months_offered'] as int?) ?? 0;
    final price = _toDouble(data['price_offered']);
    final message = data['message'] as String?;
    final user = data['users'] as Map<String, dynamic>?;
    final candidateName =
        (user?['full_name'] as String?) ?? 'Fournisseur';
    final photo = user?['photo_url'] as String?;

    final totalValue = qty * price * months;
    final canAccept = canAct && status == 'PENDING';

    final statusColor = _colorForCandStatus(status);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    AppColors.primary.withValues(alpha: 0.12),
                backgroundImage:
                    photo != null ? NetworkImage(photo) : null,
                child: photo == null
                    ? Text(
                        candidateName.isNotEmpty
                            ? candidateName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      candidateName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      '${nf.format(price.round())} F/kg',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _labelCand(status),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _miniRow(
                  'Volume mensuel',
                  '${nf.format(qty.round())} kg',
                ),
                const SizedBox(height: 3),
                _miniRow('Durée engagement', '$months mois'),
                const SizedBox(height: 3),
                _miniRow(
                  'Valeur totale',
                  '${nf.format(totalValue.round())} F',
                  bold: true,
                ),
              ],
            ),
          ),
          if (message != null && message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.18)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      message,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (canAccept) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onReject(id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF991B1B),
                      side: const BorderSide(
                          color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Rejeter',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAccept(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Accepter',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniRow(String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  static String _labelCand(String s) {
    switch (s) {
      case 'PENDING':
        return 'En attente';
      case 'ACCEPTED':
        return 'Acceptée';
      case 'REJECTED':
        return 'Rejetée';
      case 'WITHDRAWN':
        return 'Retirée';
      default:
        return s;
    }
  }

  static Color _colorForCandStatus(String s) {
    switch (s) {
      case 'ACCEPTED':
        return AppColors.primary;
      case 'REJECTED':
      case 'WITHDRAWN':
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFFD97706);
    }
  }
}
