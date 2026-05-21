import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/message.dart';
import '../../../../models/negociation.dart';
import '../../../../services/negotiation_service.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

// ─── Constantes ────────────────────────────────────────────────────────

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const Color _kWarn = Color(0xFFB45309);

// ─── Provider ──────────────────────────────────────────────────────────

final _propositionsAcheteurProvider = FutureProvider.autoDispose
    .family<List<Proposition>, String>((ref, demandeId) async {
  final all = await ref
      .read(negotiationServiceProvider)
      .listPropositions(direction: 'incoming');
  return all.where((p) => p.annonceAchatId == demandeId).toList();
});

/// Liste des propositions reçues sur une demande d'achat — côté ACHETEUR.
class PropositionDetailAcheteurPage extends ConsumerStatefulWidget {
  const PropositionDetailAcheteurPage({required this.demandeId, super.key});

  final String demandeId;

  @override
  ConsumerState<PropositionDetailAcheteurPage> createState() =>
      _PropositionDetailAcheteurPageState();
}

class _PropositionDetailAcheteurPageState
    extends ConsumerState<PropositionDetailAcheteurPage> {
  String? _opEnCours;

  Future<void> _refresh() async {
    ref.invalidate(_propositionsAcheteurProvider(widget.demandeId));
    await ref.read(_propositionsAcheteurProvider(widget.demandeId).future);
  }

  Future<void> _traiter(Proposition p, NegotiationAction action) async {
    if (_opEnCours != null) return;
    setState(() => _opEnCours = p.id);
    try {
      await ref.read(negotiationServiceProvider).traiterProposition(
            id: p.id,
            action: action,
          );
      await _refresh();
      if (!mounted) return;
      Snackbars.showSucces(
        context,
        action == NegotiationAction.accept
            ? 'Proposition acceptée'
            : 'Proposition refusée',
      );
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _opEnCours = null);
    }
  }

  Future<void> _discuter(Proposition p) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _DiscussionSheet(propositionId: p.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_propositionsAcheteurProvider(widget.demandeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              count: async.maybeWhen(data: (l) => l.length, orElse: () => 0),
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
                    message: 'Impossible de charger les propositions. $e',
                    onRetry: _refresh,
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return _emptyState(context);
                  }
                  final sorted = [...items]
                    ..sort((a, b) => a.prixProposeKg.compareTo(b.prixProposeKg));
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                      children: [
                        for (var i = 0; i < sorted.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PropositionCard(
                              proposition: sorted[i],
                              isBest: i == 0,
                              busy: _opEnCours == sorted[i].id,
                              onAccepter: () => _traiter(
                                sorted[i],
                                NegotiationAction.accept,
                              ),
                              onRefuser: () => _traiter(
                                sorted[i],
                                NegotiationAction.reject,
                              ),
                              onDiscuter: () => _discuter(sorted[i]),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 44,
              color: AppColors.textSubtle.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Aucune proposition reçue',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'Les producteurs n\'ont pas encore répondu\nà ta demande.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
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

// ─── Header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
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
              'Propositions reçues ($count)',
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

// ─── Card proposition ──────────────────────────────────────────────────

class _PropositionCard extends StatelessWidget {
  const _PropositionCard({
    required this.proposition,
    required this.isBest,
    required this.busy,
    required this.onAccepter,
    required this.onRefuser,
    required this.onDiscuter,
  });
  final Proposition proposition;
  final bool isBest;
  final bool busy;
  final VoidCallback onAccepter;
  final VoidCallback onRefuser;
  final VoidCallback onDiscuter;

  @override
  Widget build(BuildContext context) {
    final note = proposition.message?.trim();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isBest ? AppColors.primary : AppColors.border,
              width: AppDimens.borderThin,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OfferBox(proposition: proposition),
              if (note != null && note.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    '« $note »',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _Actions(
                busy: busy,
                onRefuser: onRefuser,
                onDiscuter: onDiscuter,
                onAccepter: onAccepter,
              ),
            ],
          ),
        ),
        if (isBest)
          Positioned(
            top: -9,
            left: 14,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primary,
                  width: AppDimens.borderThin,
                ),
              ),
              child: Text(
                'Meilleur prix',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OfferBox extends StatelessWidget {
  const _OfferBox({required this.proposition});
  final Proposition proposition;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QUANTITÉ',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_nf.format(proposition.quantiteKg.round())} kg dispo',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                if (proposition.status.name.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    proposition.status.name.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _kWarn,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_nf.format(proposition.prixProposeKg.round())} F',
                style: AppTextStyles.displaySmall.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '/kg',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.busy,
    required this.onRefuser,
    required this.onDiscuter,
    required this.onAccepter,
  });
  final bool busy;
  final VoidCallback onRefuser;
  final VoidCallback onDiscuter;
  final VoidCallback onAccepter;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            label: 'Refuser',
            onTap: busy ? null : onRefuser,
            color: AppColors.textSecondary,
            background: AppColors.background,
            borderColor: AppColors.border,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionBtn(
            label: 'Discuter',
            onTap: busy ? null : onDiscuter,
            color: AppColors.primary,
            background: AppColors.background,
            borderColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionBtn(
            label: busy ? '…' : 'Accepter',
            onTap: busy ? null : onAccepter,
            color: AppColors.onPrimary,
            background: AppColors.primary,
            borderColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.onTap,
    required this.color,
    required this.background,
    required this.borderColor,
  });
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Color background;
  final Color borderColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onTap == null ? AppColors.textSubtle : color,
          ),
        ),
      ),
    );
  }
}

// ─── Sheet discussion ──────────────────────────────────────────────────

class _DiscussionSheet extends ConsumerStatefulWidget {
  const _DiscussionSheet({required this.propositionId});
  final String propositionId;

  @override
  ConsumerState<_DiscussionSheet> createState() => _DiscussionSheetState();
}

class _DiscussionSheetState extends ConsumerState<_DiscussionSheet> {
  final _ctrl = TextEditingController();
  bool _sending = false;
  late Future<List<Message>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _messagesFuture = _loadMessages();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<List<Message>> _loadMessages() {
    return ref
        .read(negotiationServiceProvider)
        .listPropositionMessages(widget.propositionId);
  }

  Future<void> _send() async {
    final content = _ctrl.text.trim();
    if (content.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(negotiationServiceProvider).sendPropositionMessage(
            propositionId: widget.propositionId,
            content: content,
          );
      _ctrl.clear();
      setState(() => _messagesFuture = _loadMessages());
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Discussion',
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Message>>(
                future: _messagesFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Chargement(size: 20);
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(AppDimens.pagePaddingH),
                      child: VueErreur(
                        message: 'Impossible de charger les messages.',
                        onRetry: () => setState(() {
                          _messagesFuture = _loadMessages();
                        }),
                      ),
                    );
                  }
                  final messages = snap.data ?? const <Message>[];
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun message — démarre la discussion.',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _MessageBubble(message: messages[i]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Écris un message…',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _sending ? null : _send,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _sending
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: _sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              size: 18,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    final content = message.content ?? '';
    final date = message.createdAt;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: AppColors.text,
              height: 1.4,
            ),
          ),
          if (date != null) ...[
            const SizedBox(height: 4),
            Text(
              DateFormat('d MMM · HH:mm', 'fr_FR').format(date),
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                color: AppColors.textSubtle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────

final _nf = NumberFormat('#,##0', 'fr_FR');
