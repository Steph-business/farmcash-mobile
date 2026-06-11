// =====================================================================
//  Page : Mes contrats B2B actifs (coopérative / fournisseur)
//  ---------------------------------------------------------------------
//  Liste les contrats acceptés. Pour chaque contrat : produit + acheteur
//  + tranches mensuelles avec leur statut.
//
//  Chantier 2 — Phase 5 mobile.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/entete_page_compacte_coop.dart';

final _mesContratsProvider = FutureProvider.autoDispose<
    List<Map<String, dynamic>>>((ref) async {
  return ref
      .read(supplyPlansServiceProvider)
      .listMyContractsAsSupplier();
});

class MesContratsB2BPage extends ConsumerWidget {
  const MesContratsB2BPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contratsAsync = ref.watch(_mesContratsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageCompacteCoop(title: 'Mes contrats B2B'),
            Expanded(
              child: contratsAsync.when(
                data: (contrats) => contrats.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(_mesContratsProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          itemCount: contrats.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              _CarteContrat(data: contrats[i]),
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.assignment_outlined,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Aucun contrat B2B actif',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quand un acheteur accepte une de tes candidatures, '
              'le contrat apparaîtra ici avec ses tranches mensuelles.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────

class _CarteContrat extends StatelessWidget {
  const _CarteContrat({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final plan = data['supply_plans'] as Map<String, dynamic>?;
    final produit = plan?['produits_agricoles'] as Map<String, dynamic>?;
    final acheteur = plan?['users'] as Map<String, dynamic>?;
    final acheteurProfil =
        acheteur?['acheteur_profiles'] as Map<String, dynamic>?;
    final tranches = (data['supply_plan_tranches'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        const [];

    final qty = _toDouble(data['qty_per_month_kg']);
    final price = _toDouble(data['price_per_kg']);
    final months = (data['duration_months'] as int?) ?? 0;
    final status = (data['status'] as String?) ?? 'ACTIVE';
    final totalValue = qty * price * months;

    final tranchesPayees =
        tranches.where((t) => t['status'] == 'COMPLETED').length;
    final tranchesEnCours = tranches
        .where(
            (t) => t['status'] == 'INVOICED' || t['status'] == 'PAID')
        .length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimens.brCard,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.factory_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      produit?['nom'] as String? ?? 'Contrat',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      (acheteurProfil?['company_name'] as String?) ??
                          (acheteur?['full_name'] as String?) ??
                          'Acheteur',
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
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorForStatus(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _labelStatus(status),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _colorForStatus(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _miniRow(
                  'Engagement mensuel',
                  '${nf.format(qty.round())} kg × ${nf.format(price.round())} F/kg',
                ),
                const SizedBox(height: 4),
                _miniRow(
                  'Durée totale',
                  '$months mois',
                ),
                const SizedBox(height: 4),
                _miniRow(
                  'Valeur totale',
                  '${nf.format(totalValue.round())} F',
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Avancement',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '$tranchesPayees / ${tranches.length}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: tranches.isEmpty
                  ? 0
                  : tranchesPayees / tranches.length,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary),
            ),
          ),
          if (tranchesEnCours > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$tranchesEnCours commande${tranchesEnCours > 1 ? "s" : ""} en cours',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: const Color(0xFFD97706),
              ),
            ),
          ],
          if (tranches.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(
              'Tranches mensuelles',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...tranches.map((t) => _LigneTranche(tranche: t)),
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

  static Color _colorForStatus(String s) {
    switch (s) {
      case 'ACTIVE':
        return AppColors.primary;
      case 'SUSPENDED':
        return const Color(0xFFD97706);
      case 'CANCELLED':
        return const Color(0xFF991B1B);
      case 'COMPLETED':
        return const Color(0xFF1B7F3A);
      default:
        return AppColors.textSecondary;
    }
  }

  static String _labelStatus(String s) {
    switch (s) {
      case 'ACTIVE':
        return 'Actif';
      case 'SUSPENDED':
        return 'Suspendu';
      case 'CANCELLED':
        return 'Annulé';
      case 'COMPLETED':
        return 'Terminé';
      default:
        return s;
    }
  }
}

class _LigneTranche extends StatelessWidget {
  const _LigneTranche({required this.tranche});
  final Map<String, dynamic> tranche;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final month = DateTime.parse(tranche['month'] as String);
    final delivery =
        DateTime.parse(tranche['planned_delivery_date'] as String);
    final qty = _toDouble(tranche['qty_kg']);
    final amount = _toDouble(tranche['amount_total']);
    final status = (tranche['status'] as String?) ?? 'UPCOMING';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Icon(
              _iconForStatus(status),
              size: 16,
              color: _colorForStatus(status),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMMM yyyy', 'fr_FR').format(month),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  '${nf.format(qty.round())} kg · livraison '
                  'le ${DateFormat('d MMM', 'fr_FR').format(delivery)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${nf.format(amount.round())} F',
                style: AppTextStyles.bodySmall.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _labelForStatus(status),
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _colorForStatus(status),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  static IconData _iconForStatus(String s) {
    switch (s) {
      case 'COMPLETED':
        return Icons.check_circle_rounded;
      case 'PAID':
      case 'DELIVERED':
        return Icons.local_shipping_outlined;
      case 'INVOICED':
        return Icons.receipt_long_rounded;
      case 'DEFAULT':
        return Icons.error_outline_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  static Color _colorForStatus(String s) {
    switch (s) {
      case 'COMPLETED':
        return const Color(0xFF1B7F3A);
      case 'PAID':
      case 'DELIVERED':
      case 'INVOICED':
        return AppColors.primary;
      case 'DEFAULT':
        return const Color(0xFF991B1B);
      default:
        return AppColors.textSubtle;
    }
  }

  static String _labelForStatus(String s) {
    switch (s) {
      case 'UPCOMING':
        return 'À venir';
      case 'INVOICED':
        return 'À payer';
      case 'PAID':
        return 'Payé';
      case 'DELIVERED':
        return 'Livré';
      case 'COMPLETED':
        return 'Soldé';
      case 'DEFAULT':
        return 'En défaut';
      default:
        return s;
    }
  }
}
