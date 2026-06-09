import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/annonce_vente.dart';
import '../../../routing/route_names.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/chargement.dart';
import '../../widgets/communs/vue_erreur.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Une vente coop (vue producteur) — modèle aplati du contexte renvoyé
/// par `GET /coop/my-annonces/:id/context` du backend. Manuel (pas
/// freezed) car consommé à un seul endroit + le shape backend est
/// hétéroclite (compose plusieurs sous-objets).
class _VenteCoop {
  const _VenteCoop({
    required this.annonce,
    required this.publicationId,
    required this.publicationStatus,
    required this.maQuantiteKg,
    required this.maPartPct,
    required this.brutAttendu,
    required this.farmcashFee,
    required this.coopCommission,
    required this.avancesRecues,
    required this.netFinal,
    this.paidAmount,
    this.paidAt,
  });

  final AnnonceVente annonce;
  final String publicationId;

  /// 'ACTIVE' / 'CLOSED' — statut de la publication coop.
  final String publicationStatus;

  final double maQuantiteKg;
  /// Part dans le lot (0.0 - 1.0).
  final double maPartPct;

  /// Cascade revenu : brut → FarmCash → commission coop → avances → net.
  final double brutAttendu;
  final double farmcashFee;
  final double coopCommission;
  final double avancesRecues;
  final double netFinal;

  /// Si déjà payé : montant et date. Null si pas encore distribué.
  final double? paidAmount;
  final DateTime? paidAt;

  bool get isPaid => paidAt != null;
}

/// Provider — charge la liste des ventes coop du producteur en N+1
/// (liste annonces + contexte par annonce). TODO backend : endpoint
/// agrégé `GET /producteur/mes-contributions-coop` pour économiser
/// les round-trips quand le producteur a 20+ annonces dans la coop.
final _ventesCoopProvider =
    FutureProvider.autoDispose<List<_VenteCoop>>((ref) async {
  final svc = ref.read(cooperativesServiceProvider);
  final annonces = await svc.listMyAnnoncesInCoop();
  if (annonces.isEmpty) return const <_VenteCoop>[];

  // Fetch chaque contexte en parallèle (tolérant aux erreurs : si UN
  // fetch échoue, on garde les autres).
  final contexts = await Future.wait(
    annonces.map(
      (a) => svc.getMyAnnonceContext(a.id).then<Map<String, dynamic>?>(
            (v) => v,
          ).catchError((_) => null),
    ),
  );

  final ventes = <_VenteCoop>[];
  for (var i = 0; i < annonces.length; i++) {
    final ctx = contexts[i];
    if (ctx == null) continue;
    final pub = ctx['publication'];
    if (pub is! Map) continue; // annonce pas encore dans une publication
    final myShare = ctx['my_share'] as Map?;
    final revenue = ctx['projected_revenue'] as Map?;
    ventes.add(_VenteCoop(
      annonce: annonces[i],
      publicationId: pub['id'] as String? ?? '',
      publicationStatus: pub['status'] as String? ?? 'ACTIVE',
      maQuantiteKg: _toDouble(myShare?['quantite_kg']),
      maPartPct: _toDouble(myShare?['part_pct']),
      brutAttendu: _toDouble(revenue?['gross']),
      farmcashFee: _toDouble(revenue?['farmcash_fee']),
      coopCommission: _toDouble(revenue?['coop_commission']),
      avancesRecues: _toDouble(revenue?['advances_received']),
      netFinal: _toDouble(revenue?['net_after_advances']),
      paidAmount: myShare?['paid_amount'] != null
          ? _toDouble(myShare?['paid_amount'])
          : null,
      paidAt: myShare?['paid_at'] is String
          ? DateTime.tryParse(myShare!['paid_at'] as String)
          : null,
    ));
  }
  return ventes;
});

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

/// Page « Mes ventes coop » — vue producteur qui liste toutes les fois
/// où sa marchandise a été agrégée dans une publication coop, avec le
/// breakdown clair : ce qu'il devait toucher (brut), ce qui a été
/// retenu (FarmCash, commission coop, avances) et son net final.
///
/// C'est la **garantie de transparence** demandée par l'utilisateur —
/// si le producteur a un doute sur ce que la coop lui doit, il vient
/// ici et voit chaque ligne avec son calcul.
class VentesCoopPage extends ConsumerWidget {
  const VentesCoopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_ventesCoopProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              count: async.maybeWhen(
                data: (l) => l.length,
                orElse: () => 0,
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: VueErreur(
                    message: 'Impossible de charger tes ventes coop. $e',
                    onRetry: () => ref.invalidate(_ventesCoopProvider),
                  ),
                ),
                data: (items) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(_ventesCoopProvider);
                    await ref.read(_ventesCoopProvider.future);
                  },
                  child: items.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(20),
                          children: const [
                            SizedBox(height: 24),
                            _EtatVide(),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _CarteVente(vente: items[i]),
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

class _Header extends StatelessWidget {
  const _Header({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mes ventes coop',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  count == 0
                      ? 'Tes contributions aux lots de la coop'
                      : '$count contribution${count > 1 ? "s" : ""}',
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

class _CarteVente extends StatelessWidget {
  const _CarteVente({required this.vente});
  final _VenteCoop vente;

  @override
  Widget build(BuildContext context) {
    final isPaid = vente.isPaid;
    final qte = _nf.format(vente.maQuantiteKg.round());
    final pct = (vente.maPartPct * 100).round();
    final montant = _nf.format(
      (vente.paidAmount ?? vente.netFinal).round(),
    );
    final pubRef = vente.publicationId.length >= 8
        ? vente.publicationId.substring(0, 8).toUpperCase()
        : vente.publicationId.toUpperCase();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _ouvrirBreakdown(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Publication $pubRef',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$qte kg · $pct %',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPaid ? 'PAYÉ' : 'EN ATTENTE',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isPaid
                            ? AppColors.primary
                            : const Color(0xFFB45309),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    isPaid ? 'Reçu' : 'À recevoir',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$montant F',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _ouvrirBreakdown(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetBreakdown(vente: vente),
    );
  }
}

class _SheetBreakdown extends StatelessWidget {
  const _SheetBreakdown({required this.vente});
  final _VenteCoop vente;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Détail de ma vente',
                style: AppTextStyles.titleLarge.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Publication ${vente.publicationId.substring(0, 8).toUpperCase()}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _LigneBreakdown(label: 'Mon brut attendu', val: vente.brutAttendu),
              const SizedBox(height: 6),
              _LigneBreakdown(
                label: '− FarmCash (3 %)',
                val: vente.farmcashFee,
                negative: true,
              ),
              const SizedBox(height: 6),
              _LigneBreakdown(
                label: '− Commission coop',
                val: vente.coopCommission,
                negative: true,
              ),
              if (vente.avancesRecues > 0) ...[
                const SizedBox(height: 6),
                _LigneBreakdown(
                  label: '− Avances déjà reçues',
                  val: vente.avancesRecues,
                  negative: true,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppColors.border),
              ),
              _LigneBreakdown(
                label: vente.isPaid ? 'Net reçu' : 'Net à recevoir',
                val: vente.paidAmount ?? vente.netFinal,
                highlight: true,
              ),
              const SizedBox(height: 20),
              if (vente.isPaid)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payé le ${DateFormat('d MMMM y', 'fr_FR').format(vente.paidAt!)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Color(0xFFB45309),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tu seras payé automatiquement quand l\'acheteur confirmera la réception.',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFB45309),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(
                    RouteNames.producteurPublicationCoopDetailPathFor(
                      vente.publicationId,
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_outward_rounded, size: 18),
                label: const Text('Voir la publication'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LigneBreakdown extends StatelessWidget {
  const _LigneBreakdown({
    required this.label,
    required this.val,
    this.negative = false,
    this.highlight = false,
  });

  final String label;
  final double val;
  final bool negative;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? AppColors.primary
        : (negative ? AppColors.textSecondary : AppColors.text);
    final fontSize = highlight ? 17.0 : 13.5;
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
          '${_nf.format(val.round())} F',
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

class _EtatVide extends StatelessWidget {
  const _EtatVide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Aucune vente coop pour l\'instant',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Tes contributions aux publications agrégées de la '
                'coop apparaîtront ici quand un acheteur achètera.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
