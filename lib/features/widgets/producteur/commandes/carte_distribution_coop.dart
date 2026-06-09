import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/distribution_publication.dart';
import '../../../../models/publication_coop.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../communs/chargement.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Bundle joint preview + contributions (pour enrichir le breakdown
/// avec les noms des producteurs).
class _DistribBundle {
  const _DistribBundle({required this.preview, required this.contributions});
  final DistributionPreview preview;
  final List<CoopContribution> contributions;
}

/// Provider familial (clé = publicationCoopId) qui fetch en parallèle
/// la preview distribution + la liste des contributions, puis enrichit
/// les lignes du breakdown avec les noms des producteurs.
final _distribProvider = FutureProvider.autoDispose
    .family<_DistribBundle, String>((ref, publicationCoopId) async {
  final svc = ref.read(cooperativesServiceProvider);
  final results = await Future.wait<dynamic>([
    svc.previewDistribution(publicationCoopId),
    svc.getPublicationContributions(publicationCoopId),
  ]);
  final preview = results[0] as DistributionPreview;
  final contribs = results[1] as List<CoopContribution>;

  // Enrichit chaque ligne du breakdown avec le nom du producteur
  // (joint via la table contributions).
  final byContribId = {for (final c in contribs) c.id: c};
  final enriched = preview.breakdown.map((line) {
    final c = byContribId[line.contributionId];
    return c != null ? line.copyWithName(c.farmerName) : line;
  }).toList(growable: false);

  return _DistribBundle(
    preview: DistributionPreview(
      totalSold: preview.totalSold,
      coopCommission: preview.coopCommission,
      distributable: preview.distributable,
      farmcashFee: preview.farmcashFee,
      breakdown: enriched,
      executed: preview.executed,
    ),
    contributions: contribs,
  );
});

/// Carte « Distribution aux membres » affichée sur le détail commande
/// coop. Montre la **transparence des paiements** aux producteurs
/// membres : cascade des frais (FarmCash → commission coop → reste) +
/// liste détaillée de qui reçoit combien.
///
/// Visible UNIQUEMENT pour le rôle COOPERATIVE quand la commande est
/// issue d'une publication coop agrégée (`publicationCoopId != null`).
/// C'est la garantie anti-litige interne : « la coop ne peut pas dire
/// qu'elle a payé moins, la trace est dans l'app ».
class CarteDistributionCoop extends ConsumerWidget {
  const CarteDistributionCoop({super.key, required this.publicationCoopId});

  final String publicationCoopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_distribProvider(publicationCoopId));
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EnteteSection(),
          const SizedBox(height: 14),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Chargement(size: 18),
            ),
            error: (_, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Impossible de charger la distribution.',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            data: (bundle) => _BodyDistribution(bundle: bundle),
          ),
        ],
      ),
    );
  }
}

class _EnteteSection extends StatelessWidget {
  const _EnteteSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Distribution aux membres',
            style: AppTextStyles.titleSmall.copyWith(
              fontFamily: 'Poppins',
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _BodyDistribution extends StatelessWidget {
  const _BodyDistribution({required this.bundle});
  final _DistribBundle bundle;

  @override
  Widget build(BuildContext context) {
    final p = bundle.preview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── Cascade des frais ──────────────────────────────────────
        _LigneCascade(label: 'Total acheteur', valeur: p.totalSold),
        const SizedBox(height: 6),
        _LigneCascade(
          label: '− FarmCash (3 %)',
          valeur: p.farmcashFee,
          negative: true,
        ),
        const SizedBox(height: 4),
        _LigneCascade(
          label: '− Ma commission',
          valeur: p.coopCommission,
          negative: true,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1, color: AppColors.border),
        ),
        _LigneCascade(
          label: 'Distribué aux producteurs',
          valeur: p.distributable,
          highlight: true,
        ),

        // ─── Détail par producteur ──────────────────────────────────
        if (p.breakdown.isNotEmpty) ...[
          const SizedBox(height: 14),
          for (var i = 0; i < p.breakdown.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _CarteProducteur(line: p.breakdown[i]),
          ],
        ],

        const SizedBox(height: 12),
        // Mention statut : exécuté ou en attente
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: p.executed
                ? AppColors.primary.withValues(alpha: 0.08)
                : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                p.executed
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                size: 15,
                color: p.executed
                    ? AppColors.primary
                    : const Color(0xFFB45309),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p.executed
                      ? 'Distribution effectuée — producteurs payés.'
                      : 'Distribution automatique à la confirmation de réception par l\'acheteur.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: p.executed
                        ? AppColors.primary
                        : const Color(0xFFB45309),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LigneCascade extends StatelessWidget {
  const _LigneCascade({
    required this.label,
    required this.valeur,
    this.negative = false,
    this.highlight = false,
  });

  final String label;
  final double valeur;
  final bool negative;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? AppColors.primary
        : negative
            ? AppColors.textSecondary
            : AppColors.text;
    final fontSize = highlight ? 15.0 : 13.0;
    final weight = highlight ? FontWeight.w800 : FontWeight.w600;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: fontSize,
              fontWeight: weight,
              color: color,
            ),
          ),
        ),
        Text(
          '${_nf.format(valeur.round())} F',
          style: AppTextStyles.bodyMedium.copyWith(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w700,
            color: color,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _CarteProducteur extends StatelessWidget {
  const _CarteProducteur({required this.line});
  final DistributionLine line;

  @override
  Widget build(BuildContext context) {
    final qte = _nf.format(line.quantiteKg.round());
    final pct = (line.partPct * 100).round();
    final amount = _nf.format(line.amount.round());
    final nom = line.farmerName ?? 'Producteur';
    final initiale = nom.trim().isEmpty
        ? '?'
        : nom.trim().substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Avatar monogramme
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initiale,
              style: AppTextStyles.bodyMedium.copyWith(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '$qte kg · $pct %',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$amount F',
            style: AppTextStyles.bodyMedium.copyWith(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
