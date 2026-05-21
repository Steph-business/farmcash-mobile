import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/negociation.dart';
import '../../../../services/negotiation_service.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarnSoft = Color(0xFFFFF8E1);
const Color _kWarn = Color(0xFFB26A00);
const Color _kRedSoft = Color(0xFFFDECEA);

enum _StatusFilter { toutes, pending, accepted, refused }

/// Une offre côté FARMER, peu importe son type (candidature d'un buyer sur
/// une annonce de vente, ou réponse FARMER→BUYER après contre-offre).
/// Unifie les deux modèles pour l'affichage et le traitement.
class _OffreUnifiee {
  const _OffreUnifiee({
    required this.id,
    required this.kind,
    required this.quantiteKg,
    required this.prixProposeKg,
    required this.status,
    this.message,
    this.createdAt,
  });

  final String id;
  final _OffreKind kind;
  final double quantiteKg;
  final double prixProposeKg;
  final NegotiationStatus status;
  final String? message;
  final DateTime? createdAt;

  factory _OffreUnifiee.fromCandidature(Candidature c) => _OffreUnifiee(
        id: c.id,
        kind: _OffreKind.candidature,
        quantiteKg: c.quantiteKg,
        prixProposeKg: c.prixProposeKg,
        status: c.status,
        message: c.message,
        createdAt: c.createdAt,
      );

  factory _OffreUnifiee.fromProposition(Proposition p) => _OffreUnifiee(
        id: p.id,
        kind: _OffreKind.proposition,
        quantiteKg: p.quantiteKg,
        prixProposeKg: p.prixProposeKg,
        status: p.status,
        message: p.message,
        createdAt: p.createdAt,
      );
}

enum _OffreKind { candidature, proposition }

/// Bundle des offres reçues : candidatures entrantes (acheteurs ayant
/// candidaté sur les annonces de vente du FARMER) + propositions sortantes
/// (le FARMER a proposé sur des annonces d'achat) que le buyer a traitées.
class _OffresBundle {
  const _OffresBundle({required this.offres});
  final List<_OffreUnifiee> offres;
}

final _offresProvider =
    FutureProvider.autoDispose<_OffresBundle>((ref) async {
  final svc = ref.read(negotiationServiceProvider);
  final results = await Future.wait<dynamic>([
    svc
        .listCandidatures(direction: 'incoming')
        .then<Object?>((v) => v)
        .catchError((_) => const <Candidature>[]),
    svc
        .listPropositions(direction: 'outgoing')
        .then<Object?>((v) => v)
        .catchError((_) => const <Proposition>[]),
  ]);
  final candidatures = results[0] as List<Candidature>;
  final propositions = results[1] as List<Proposition>;
  final offres = <_OffreUnifiee>[
    ...candidatures.map(_OffreUnifiee.fromCandidature),
    ...propositions.map(_OffreUnifiee.fromProposition),
  ];
  // Tri par date de création décroissante (les plus récentes en premier).
  offres.sort((a, b) {
    final aDt = a.createdAt ?? DateTime(1970);
    final bDt = b.createdAt ?? DateTime(1970);
    return bDt.compareTo(aDt);
  });
  return _OffresBundle(offres: offres);
});

/// Liste des offres reçues sur les annonces du producteur — branchée
/// sur `negotiationService`. Le FARMER peut accepter ou refuser ; les
/// candidatures vont vers `traiterCandidature`, les propositions vers
/// `traiterProposition`.
class OffresRecuesPage extends ConsumerStatefulWidget {
  const OffresRecuesPage({super.key});

  @override
  ConsumerState<OffresRecuesPage> createState() => _OffresRecuesPageState();
}

class _OffresRecuesPageState extends ConsumerState<OffresRecuesPage> {
  _StatusFilter _filter = _StatusFilter.toutes;
  String? _busyId;

  Future<void> _refresh() async {
    ref.invalidate(_offresProvider);
    await ref.read(_offresProvider.future);
  }

  List<_OffreUnifiee> _filter1(List<_OffreUnifiee> source) {
    switch (_filter) {
      case _StatusFilter.toutes:
        return source;
      case _StatusFilter.pending:
        return source
            .where((o) => o.status == NegotiationStatus.pending)
            .toList();
      case _StatusFilter.accepted:
        return source
            .where((o) => o.status == NegotiationStatus.accepted)
            .toList();
      case _StatusFilter.refused:
        return source
            .where((o) =>
                o.status == NegotiationStatus.rejected ||
                o.status == NegotiationStatus.cancelled)
            .toList();
    }
  }

  Future<void> _traiter(_OffreUnifiee offre, NegotiationAction action) async {
    if (_busyId != null) return;
    setState(() => _busyId = offre.id);
    try {
      final svc = ref.read(negotiationServiceProvider);
      if (offre.kind == _OffreKind.candidature) {
        await svc.traiterCandidature(id: offre.id, action: action);
      } else {
        await svc.traiterProposition(id: offre.id, action: action);
      }
      await _refresh();
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        action == NegotiationAction.accept
            ? 'Offre acceptée'
            : 'Offre refusée',
      );
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreur(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_offresProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les offres. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (bundle) => _buildBody(bundle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(_OffresBundle bundle) {
    final pendingCount = bundle.offres
        .where((o) => o.status == NegotiationStatus.pending)
        .length;
    final filtered = _filter1(bundle.offres);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          0,
          AppDimens.pagePaddingH,
          AppDimens.space24,
        ),
        children: [
          _SousTitre(count: pendingCount),
          AppDimens.vGap12,
          _Filtres(
            selection: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          AppDimens.vGap16,
          if (filtered.isEmpty)
            const _EmptyState()
          else
            ...filtered.map(
              (o) => _OffreCard(
                offre: o,
                busy: _busyId == o.id,
                onAccepter: () => _traiter(o, NegotiationAction.accept),
                onRefuser: () => _traiter(o, NegotiationAction.reject),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
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
              'Offres reçues',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sous-titre ──────────────────────────────────────────────────────

class _SousTitre extends StatelessWidget {
  const _SousTitre({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        count == 0
            ? 'Aucune offre en attente'
            : '$count offre${count > 1 ? 's' : ''} en attente',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Filtres ─────────────────────────────────────────────────────────

class _Filtres extends StatelessWidget {
  const _Filtres({required this.selection, required this.onChanged});
  final _StatusFilter selection;
  final ValueChanged<_StatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _chip('Toutes', _StatusFilter.toutes),
          const SizedBox(width: 8),
          _chip('En attente', _StatusFilter.pending),
          const SizedBox(width: 8),
          _chip('Acceptées', _StatusFilter.accepted),
          const SizedBox(width: 8),
          _chip('Refusées', _StatusFilter.refused),
        ],
      ),
    );
  }

  Widget _chip(String label, _StatusFilter value) {
    final active = value == selection;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.onPrimary : AppColors.text,
          ),
        ),
      ),
    );
  }
}

// ─── Card offre ──────────────────────────────────────────────────────

class _OffreCard extends StatelessWidget {
  const _OffreCard({
    required this.offre,
    required this.busy,
    required this.onAccepter,
    required this.onRefuser,
  });

  final _OffreUnifiee offre;
  final bool busy;
  final VoidCallback onAccepter;
  final VoidCallback onRefuser;

  @override
  Widget build(BuildContext context) {
    final qte = '${_nf.format(offre.quantiteKg.round())} kg';
    final prix = '${_nf.format(offre.prixProposeKg.round())} F/kg';
    final df = DateFormat('d MMM', 'fr_FR');
    final dateLabel =
        offre.createdAt != null ? df.format(offre.createdAt!) : '—';
    final montantTotal = '${_nf.format(
      (offre.quantiteKg * offre.prixProposeKg).round(),
    )} F';
    final kindLabel = offre.kind == _OffreKind.candidature
        ? 'Candidature acheteur'
        : 'Proposition envoyée';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kPrimarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    offre.kind == _OffreKind.candidature
                        ? Icons.call_received
                        : Icons.call_made,
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
                        kindLabel,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$qte · $prix',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: offre.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total : $montantTotal',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Text(
                  dateLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textSubtle,
                  ),
                ),
              ],
            ),
            if (offre.message != null && offre.message!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  offre.message!,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.text,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            // Actions disponibles uniquement quand l'offre est PENDING et
            // que c'est une candidature (le FARMER décide).
            if (offre.status == NegotiationStatus.pending &&
                offre.kind == _OffreKind.candidature) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: busy ? null : onRefuser,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderStrong,
                            width: AppDimens.borderThin,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Refuser',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: busy ? null : onAccepter,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Accepter',
                                style: AppTextStyles.button.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final NegotiationStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _spec();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  (Color, Color, String) _spec() {
    switch (status) {
      case NegotiationStatus.pending:
        return (_kWarnSoft, _kWarn, 'EN ATTENTE');
      case NegotiationStatus.accepted:
        return (_kPrimarySoft, AppColors.primary, 'ACCEPTÉE');
      case NegotiationStatus.rejected:
        return (_kRedSoft, AppColors.error, 'REFUSÉE');
      case NegotiationStatus.counterOffered:
        return (_kWarnSoft, _kWarn, 'CONTRE-OFFRE');
      case NegotiationStatus.cancelled:
        return (const Color(0xFFE5E7EB), AppColors.textSecondary, 'ANNULÉE');
      case NegotiationStatus.unknown:
        return (const Color(0xFFE5E7EB), AppColors.textSecondary, '—');
    }
  }
}

// ─── Empty state ────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 40,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune offre pour le moment',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Tu verras ici les candidatures des acheteurs sur tes annonces et tes propositions sur leurs demandes.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _nf = NumberFormat('#,##0', 'fr_FR');
