import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/post_acceptation_negociation.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

/// Provider racine — liste des contre-offres reçues par la coop sur ses
/// publications. Optionnellement filtrées par statut.
final _contreOffresRecuesCoopProvider = FutureProvider.autoDispose
    .family<List<ContreOffreCoop>, NegotiationStatus?>((ref, status) async {
  return ref.read(negotiationServiceProvider).listContreOffresCoop(
        direction: 'incoming',
        status: status,
      );
});

/// Page « Contre-offres reçues » côté coopérative.
///
/// Les acheteurs envoient des contre-offres sur les publications coop
/// (BUYER → COOP, table `contre_offres_coop`). La coop voit ici la liste
/// avec filtre statut (PENDING / ACCEPTED / REJECTED) et 3 actions sur
/// chaque PENDING :
///   - **Accepter** → backend crée la commande au prix négocié + envoie
///     l'acheteur sur le détail de la nouvelle commande (helper partagé
///     `apresAcceptationNegociation` avec `fromAcheteurSide: false`).
///   - **Rejeter** → dialog avec motif optionnel.
///   - **Contre-proposer** → sheet avec prix/quantité/message → backend
///     conserve la négociation en COUNTER_OFFERED.
class ContreOffresRecuesCoopPage extends ConsumerStatefulWidget {
  const ContreOffresRecuesCoopPage({super.key});

  @override
  ConsumerState<ContreOffresRecuesCoopPage> createState() =>
      _ContreOffresRecuesCoopPageState();
}

class _ContreOffresRecuesCoopPageState
    extends ConsumerState<ContreOffresRecuesCoopPage> {
  /// `null` = onglet « Toutes ». Sinon filtre statut backend.
  NegotiationStatus? _filtre;
  String? _busyId;

  Future<void> _refresh() async {
    ref.invalidate(_contreOffresRecuesCoopProvider(_filtre));
    await ref.read(_contreOffresRecuesCoopProvider(_filtre).future);
  }

  Future<void> _accepter(ContreOffreCoop c) async {
    if (_busyId != null) return;
    setState(() => _busyId = c.id);
    try {
      final result =
          await ref.read(negotiationServiceProvider).traiterContreOffreCoop(
                id: c.id,
                action: NegotiationAction.accept,
              );
      if (!mounted) return;
      // Côté COOP (vendeur) : pas de paiement à effectuer, juste un
      // snackbar succès avec la réf commande créée.
      await apresAcceptationNegociation(
        context,
        result,
        fromAcheteurSide: false,
      );
      if (!mounted) return;
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _rejeter(ContreOffreCoop c) async {
    if (_busyId != null) return;
    final motif = await _ouvrirDialogRejet(context);
    // null = annule, '' ou texte = confirme.
    if (motif == null) return;
    if (!mounted) return;
    setState(() => _busyId = c.id);
    try {
      await ref.read(negotiationServiceProvider).traiterContreOffreCoop(
            id: c.id,
            action: NegotiationAction.reject,
            message: motif.trim().isEmpty ? null : motif.trim(),
          );
      if (!mounted) return;
      Snackbars.showSucces(context, 'Contre-offre rejetée.');
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _contreProposer(ContreOffreCoop c) async {
    if (_busyId != null) return;
    final brouillon = await _ouvrirSheetContreProposer(
      context,
      offreInitiale: c,
    );
    if (brouillon == null) return;
    if (!mounted) return;
    setState(() => _busyId = c.id);
    try {
      await ref.read(negotiationServiceProvider).traiterContreOffreCoop(
            id: c.id,
            action: NegotiationAction.counter,
            prixContreOffreKg: brouillon.prixKg,
            quantiteContreOffreKg: brouillon.quantiteKg,
            message: brouillon.message,
          );
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        'Contre-proposition envoyée à l\'acheteur.',
      );
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } catch (e) {
      if (mounted) Snackbars.showErreurInattendue(context, e);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_contreOffresRecuesCoopProvider(_filtre));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Contre-offres reçues'),
            _FiltresStatut(
              actif: _filtre,
              onChange: (v) => setState(() => _filtre = v),
            ),
            Expanded(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppDimens.space32),
                  child: Chargement(size: 22),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                  child: VueErreur(
                    message: 'Impossible de charger les contre-offres. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (items) => RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refresh,
                  child: items.isEmpty
                      ? const _EtatVideContreOffres()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimens.pagePaddingH,
                            AppDimens.space8,
                            AppDimens.pagePaddingH,
                            AppDimens.space16,
                          ),
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            final c = items[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CarteContreOffreRecue(
                                contre: c,
                                busy: _busyId == c.id,
                                onAccepter: () => _accepter(c),
                                onRejeter: () => _rejeter(c),
                                onContreProposer: () => _contreProposer(c),
                              ),
                            );
                          },
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

// ─── Filtres statut (chips horizontaux) ──────────────────────────────────

class _FiltresStatut extends StatelessWidget {
  const _FiltresStatut({required this.actif, required this.onChange});
  final NegotiationStatus? actif;
  final ValueChanged<NegotiationStatus?> onChange;

  @override
  Widget build(BuildContext context) {
    final filtres = <(String, NegotiationStatus?)>[
      ('Toutes', null),
      ('En attente', NegotiationStatus.pending),
      ('Acceptées', NegotiationStatus.accepted),
      ('Rejetées', NegotiationStatus.rejected),
    ];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pagePaddingH,
          6,
          AppDimens.pagePaddingH,
          6,
        ),
        itemCount: filtres.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, status) = filtres[i];
          final isActive = actif == status;
          return InkWell(
            onTap: () => onChange(status),
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppColors.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Carte « contre-offre reçue » ────────────────────────────────────────

class _CarteContreOffreRecue extends StatelessWidget {
  const _CarteContreOffreRecue({
    required this.contre,
    required this.busy,
    required this.onAccepter,
    required this.onRejeter,
    required this.onContreProposer,
  });

  final ContreOffreCoop contre;
  final bool busy;
  final VoidCallback onAccepter;
  final VoidCallback onRejeter;
  final VoidCallback onContreProposer;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final total = (contre.quantiteKg * contre.prixProposeKg).round();
    final isPending = contre.status == NegotiationStatus.pending;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.handshake_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contre-offre acheteur',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sur publication ${_shortId(contre.publicationCoopId)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              _BadgeStatut(status: contre.status),
            ],
          ),
          const SizedBox(height: 12),
          // Ligne chiffres : prix proposé · qté · total
          _LigneChiffre(
            label: 'Prix proposé',
            value: '${nf.format(contre.prixProposeKg.round())} F/kg',
          ),
          _LigneChiffre(
            label: 'Quantité',
            value: '${nf.format(contre.quantiteKg.round())} kg',
          ),
          _LigneChiffre(
            label: 'Montant total',
            value: '${nf.format(total)} F',
            highlight: true,
          ),
          if (contre.message != null && contre.message!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: 14,
                    color: AppColors.textSubtle,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      contre.message!.trim(),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 12),
            // 3 boutons : Rejeter (outline rouge) · Contre-proposer (outline)
            // · Accepter (plein vert). On laisse 8 px entre chaque.
            Row(
              children: [
                Expanded(
                  child: _BoutonOutline(
                    label: 'Rejeter',
                    couleur: AppColors.error,
                    busy: busy,
                    onTap: onRejeter,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _BoutonOutline(
                    label: 'Contre',
                    couleur: AppColors.text,
                    busy: busy,
                    onTap: onContreProposer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _BoutonPlein(
                    label: 'Accepter',
                    busy: busy,
                    onTap: onAccepter,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _shortId(String id) {
    final t = id.trim();
    if (t.isEmpty) return '?';
    final tail = t.contains('-') ? t.split('-').last : t;
    return tail.length > 6 ? tail.substring(0, 6) : tail;
  }
}

class _LigneChiffre extends StatelessWidget {
  const _LigneChiffre({
    required this.label,
    required this.value,
    this.highlight = false,
  });
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: highlight ? 14 : 13,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              color: highlight ? AppColors.primary : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeStatut extends StatelessWidget {
  const _BadgeStatut({required this.status});
  final NegotiationStatus status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color fg;
    switch (status) {
      case NegotiationStatus.pending:
        label = 'En attente';
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        break;
      case NegotiationStatus.accepted:
        label = 'Acceptée';
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
      case NegotiationStatus.rejected:
        label = 'Rejetée';
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      case NegotiationStatus.counterOffered:
        label = 'Contre-proposée';
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        break;
      case NegotiationStatus.cancelled:
        label = 'Annulée';
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF374151);
        break;
      case NegotiationStatus.unknown:
        label = '—';
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF374151);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _BoutonPlein extends StatelessWidget {
  const _BoutonPlein({
    required this.label,
    required this.busy,
    required this.onTap,
  });
  final String label;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: BorderRadius.circular(AppDimens.radius),
      child: Container(
        height: AppDimens.buttonHeightSmall,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: busy
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimens.radius),
        ),
        child: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.button.copyWith(
                  fontSize: 12.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _BoutonOutline extends StatelessWidget {
  const _BoutonOutline({
    required this.label,
    required this.couleur,
    required this.busy,
    required this.onTap,
  });
  final String label;
  final Color couleur;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: BorderRadius.circular(AppDimens.radius),
      child: Container(
        height: AppDimens.buttonHeightSmall,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimens.radius),
          border: Border.all(
            color: busy ? AppColors.border : couleur,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            fontSize: 12.5,
            color: busy ? AppColors.textSubtle : couleur,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── État vide ───────────────────────────────────────────────────────────

class _EtatVideContreOffres extends StatelessWidget {
  const _EtatVideContreOffres();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space48,
        AppDimens.pagePaddingH,
        AppDimens.space32,
      ),
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.handshake_outlined,
            size: 32,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Aucune contre-offre reçue',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleSmall.copyWith(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Quand un acheteur proposera un prix différent sur l\'une de tes '
          'publications, sa contre-offre apparaîtra ici.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

// ─── Dialog rejet (motif optionnel) ──────────────────────────────────────

Future<String?> _ouvrirDialogRejet(BuildContext context) async {
  final ctrl = TextEditingController();
  final res = await showDialog<String?>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        ),
        title: Text(
          'Rejeter la contre-offre',
          style: AppTextStyles.titleSmall.copyWith(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Motif (optionnel)',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: ctrl,
              maxLines: 3,
              minLines: 2,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Ex: Prix trop bas pour ce lot.',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radius),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                hintStyle: AppTextStyles.hint.copyWith(
                  fontSize: 12.5,
                  color: AppColors.textSubtle,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radius),
              ),
            ),
            child: const Text('Rejeter'),
          ),
        ],
      );
    },
  );
  ctrl.dispose();
  return res;
}

// ─── Sheet « contre-proposer » ───────────────────────────────────────────

class _BrouillonContreProposition {
  const _BrouillonContreProposition({
    required this.prixKg,
    required this.quantiteKg,
    this.message,
  });
  final double prixKg;
  final double quantiteKg;
  final String? message;
}

Future<_BrouillonContreProposition?> _ouvrirSheetContreProposer(
  BuildContext context, {
  required ContreOffreCoop offreInitiale,
}) {
  return showModalBottomSheet<_BrouillonContreProposition>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _SheetContreProposer(offreInitiale: offreInitiale),
  );
}

class _SheetContreProposer extends StatefulWidget {
  const _SheetContreProposer({required this.offreInitiale});
  final ContreOffreCoop offreInitiale;

  @override
  State<_SheetContreProposer> createState() => _SheetContreProposerState();
}

class _SheetContreProposerState extends State<_SheetContreProposer> {
  late final TextEditingController _prixCtrl;
  late final TextEditingController _qteCtrl;
  final _messageCtrl = TextEditingController();
  final _nf = NumberFormat('#,##0', 'fr_FR');

  @override
  void initState() {
    super.initState();
    // Pré-remplit avec la contre-offre de l'acheteur — la coop ajuste.
    _prixCtrl = TextEditingController(
      text: widget.offreInitiale.prixProposeKg.round().toString(),
    );
    _qteCtrl = TextEditingController(
      text: widget.offreInitiale.quantiteKg.round().toString(),
    );
  }

  @override
  void dispose() {
    _prixCtrl.dispose();
    _qteCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _envoyer() {
    final prix = double.tryParse(_prixCtrl.text.trim());
    final qte = double.tryParse(_qteCtrl.text.trim());
    if (prix == null || prix <= 0) {
      Snackbars.showErreur(context, 'Saisis un prix valide.');
      return;
    }
    if (qte == null || qte <= 0) {
      Snackbars.showErreur(context, 'Saisis une quantité valide.');
      return;
    }
    Navigator.of(context).pop(
      _BrouillonContreProposition(
        prixKg: prix,
        quantiteKg: qte,
        message: _messageCtrl.text.trim().isEmpty
            ? null
            : _messageCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final montant = (double.tryParse(_qteCtrl.text.trim()) ?? 0) *
        (double.tryParse(_prixCtrl.text.trim()) ?? 0);
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Contre-proposer à l\'acheteur',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'L\'acheteur propose ${_nf.format(widget.offreInitiale.prixProposeKg.round())} F/kg '
                'pour ${_nf.format(widget.offreInitiale.quantiteKg.round())} kg',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const _LabelChamp(label: 'Ton prix (F/kg)'),
              const SizedBox(height: 4),
              TextField(
                controller: _prixCtrl,
                keyboardType: TextInputType.number,
                textAlignVertical: TextAlignVertical.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: _inputDeco('Ex: 700'),
              ),
              const SizedBox(height: 12),
              const _LabelChamp(label: 'Quantité (kg)'),
              const SizedBox(height: 4),
              TextField(
                controller: _qteCtrl,
                keyboardType: TextInputType.number,
                textAlignVertical: TextAlignVertical.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: _inputDeco('Ex: 200'),
              ),
              const SizedBox(height: 12),
              const _LabelChamp(label: 'Message (optionnel)'),
              const SizedBox(height: 4),
              TextField(
                controller: _messageCtrl,
                maxLines: 3,
                minLines: 2,
                textAlignVertical: TextAlignVertical.center,
                decoration: _inputDeco(
                  'Ex: Voici notre meilleur prix pour cette quantité.',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Montant total si accepté',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    Text(
                      '${_nf.format(montant.round())} F',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _envoyer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Envoyer ma contre-proposition'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: false,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      hintStyle: AppTextStyles.hint.copyWith(
        fontSize: 13,
        color: AppColors.textSubtle,
      ),
    );
  }
}

class _LabelChamp extends StatelessWidget {
  const _LabelChamp({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}
