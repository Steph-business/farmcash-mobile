import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/message.dart';
import '../../../../services/negotiation_service.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/post_acceptation_negociation.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/offres/offre_modeles.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');
const Color _kAmber = Color(0xFFB45309);

/// Page de discussion sur une offre côté **PRODUCTEUR**.
///
/// Symétrique de `DiscussionNegociationPage` (acheteur) — gère
/// indifféremment :
///
/// - **Candidature** : un acheteur a candidaté sur l'une de mes annonces
///   de vente. Le producteur décide → boutons Accepter / Refuser.
/// - **Proposition** : j'ai proposé sur une demande d'achat. Le buyer
///   décide. Le producteur peut juste discuter / annuler sa propre
///   proposition pendant qu'elle est encore PENDING.
///
/// Layout : header AppBar + carte contexte (produit / qté / prix actuel
/// + statut), liste WhatsApp-like, input bas, et — quand pertinent —
/// barre d'actions sticky au-dessus de l'input.
class DiscussionOffrePage extends ConsumerStatefulWidget {
  const DiscussionOffrePage({super.key, required this.offre});

  /// Offre source — sert à afficher le contexte permanent en haut et à
  /// router vers le bon endpoint backend (candidature vs proposition).
  final OffreUnifiee offre;

  @override
  ConsumerState<DiscussionOffrePage> createState() =>
      _DiscussionOffrePageState();
}

class _DiscussionOffrePageState extends ConsumerState<DiscussionOffrePage> {
  final _ctrl = TextEditingController();
  bool _sending = false;
  bool _acting = false; // accepter/refuser/annuler en cours
  late Future<List<Message>> _messagesFuture;

  /// Statut local (mis à jour après une action accepter/refuser pour
  /// rafraîchir le contexte + masquer les boutons sans reload de page).
  late NegotiationStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.offre.status;
    _messagesFuture = _loadMessages();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<List<Message>> _loadMessages() {
    final svc = ref.read(negotiationServiceProvider);
    return widget.offre.kind == OffreKind.candidature
        ? svc.listCandidatureMessages(widget.offre.id)
        : svc.listPropositionMessages(widget.offre.id);
  }

  Future<void> _send() async {
    final content = _ctrl.text.trim();
    if (content.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final svc = ref.read(negotiationServiceProvider);
      if (widget.offre.kind == OffreKind.candidature) {
        await svc.sendCandidatureMessage(
          candidatureId: widget.offre.id,
          content: content,
        );
      } else {
        await svc.sendPropositionMessage(
          propositionId: widget.offre.id,
          content: content,
        );
      }
      _ctrl.clear();
      setState(() => _messagesFuture = _loadMessages());
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _agir(NegotiationAction action) async {
    if (_acting) return;
    setState(() => _acting = true);
    try {
      final svc = ref.read(negotiationServiceProvider);
      final result = widget.offre.kind == OffreKind.candidature
          ? await svc.traiterCandidature(id: widget.offre.id, action: action)
          : await svc.traiterProposition(id: widget.offre.id, action: action);
      if (!mounted) return;
      // Côté producteur (vendeur), si ACCEPTED la commande est créée pour
      // l'acheteur — on lui notifie que c'est en attente de paiement.
      if (action == NegotiationAction.accept && result.commandeId != null) {
        await apresAcceptationNegociation(
          context,
          result,
          fromAcheteurSide: false,
        );
      }
      // MAJ locale du statut pour basculer l'UI immédiatement.
      setState(() {
        switch (action) {
          case NegotiationAction.accept:
            _status = NegotiationStatus.accepted;
            break;
          case NegotiationAction.reject:
            _status = NegotiationStatus.rejected;
            break;
          case NegotiationAction.cancel:
            _status = NegotiationStatus.cancelled;
            break;
          case NegotiationAction.counter:
            _status = NegotiationStatus.counterOffered;
            break;
        }
      });
      // Snackbar simple uniquement si pas d'acceptation (sinon le helper
      // au-dessus a déjà affiché un snackbar enrichi).
      if (action != NegotiationAction.accept) {
        Snackbars.showSucces(context, _toastForAction(action));
      }
    } on ApiException catch (e) {
      if (mounted) Snackbars.showErreur(context, e.message);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  String _toastForAction(NegotiationAction a) {
    switch (a) {
      case NegotiationAction.accept:
        return 'Offre acceptée — une commande va être créée.';
      case NegotiationAction.reject:
        return 'Offre refusée.';
      case NegotiationAction.cancel:
        return 'Ma proposition a été annulée.';
      case NegotiationAction.counter:
        return 'Contre-offre envoyée.';
    }
  }

  Future<void> _confirmerEtAgir(NegotiationAction action) async {
    final libelle = action == NegotiationAction.accept
        ? 'Accepter cette offre'
        : action == NegotiationAction.reject
        ? 'Refuser cette offre'
        : 'Annuler ma proposition';
    final corps = action == NegotiationAction.accept
        ? 'En acceptant, une commande sera créée et l\'acheteur sera notifié.'
        : action == NegotiationAction.reject
        ? "L'offre sera marquée comme refusée. Cette action est définitive."
        : 'Ta proposition sera retirée de la liste de l\'acheteur.';

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(libelle),
        content: Text(corps),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: action == NegotiationAction.accept
                  ? AppColors.primary
                  : AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              action == NegotiationAction.accept ? 'Accepter' : 'Confirmer',
            ),
          ),
        ],
      ),
    );
    if (ok == true) await _agir(action);
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider)?.id;
    final isCandidature = widget.offre.kind == OffreKind.candidature;
    final isPending = _status == NegotiationStatus.pending;
    final canDecide = isCandidature && isPending;
    final canCancel = !isCandidature && isPending;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EntetePageStandard(
              titre: isCandidature
                  ? 'Discussion avec l\'acheteur'
                  : 'Ma proposition',
            ),
            _CarteContexteOffre(
              kind: widget.offre.kind,
              quantiteKg: widget.offre.quantiteKg,
              prixProposeKg: widget.offre.prixProposeKg,
              status: _status,
            ),
            Expanded(
              child: FutureBuilder<List<Message>>(
                future: _messagesFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Chargement(size: 20);
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
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
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          isCandidature
                              ? "Aucun message — engage la discussion avec l'acheteur."
                              : 'Aucun message — précise ton offre à l\'acheteur.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (_, i) => _MessageBubble(
                      message: messages[i],
                      isMine: messages[i].senderId == userId,
                    ),
                  );
                },
              ),
            ),

            // Barre d'actions — visible UNIQUEMENT quand pertinent :
            //   - candidature pending → Accepter / Refuser
            //   - proposition pending → Annuler ma proposition
            if (canDecide || canCancel) ...[
              const Divider(height: 1, color: AppColors.border),
              SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: canDecide
                      ? _BarreActionsCandidature(
                          busy: _acting,
                          onAccepter: () =>
                              _confirmerEtAgir(NegotiationAction.accept),
                          onRefuser: () =>
                              _confirmerEtAgir(NegotiationAction.reject),
                        )
                      : _BoutonAnnulerProposition(
                          busy: _acting,
                          onAnnuler: () =>
                              _confirmerEtAgir(NegotiationAction.cancel),
                        ),
                ),
              ),
            ],

            // Input bas — adapté au clavier via SafeArea + viewInsets.
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  6,
                  16,
                  MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 14,
                ),
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
                          // Theme global applique filled+fillColor :
                          // on force transparent pour ne pas avoir un
                          // rectangle blanc dépareillé.
                          filled: false,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _sending ? null : _send,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _sending
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : AppColors.primary,
                          shape: BoxShape.circle,
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
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Carte contexte (produit / qté / prix / statut) ────────────────

class _CarteContexteOffre extends StatelessWidget {
  const _CarteContexteOffre({
    required this.kind,
    required this.quantiteKg,
    required this.prixProposeKg,
    required this.status,
  });

  final OffreKind kind;
  final double quantiteKg;
  final double prixProposeKg;
  final NegotiationStatus status;

  String _headerLabel() {
    switch (status) {
      case NegotiationStatus.accepted:
        return 'Accord conclu';
      case NegotiationStatus.rejected:
        return 'Offre refusée';
      case NegotiationStatus.cancelled:
        return 'Négociation annulée';
      case NegotiationStatus.counterOffered:
        return 'Contre-offre en cours';
      case NegotiationStatus.pending:
      case NegotiationStatus.unknown:
        return kind == OffreKind.candidature
            ? "L'acheteur attend ta réponse"
            : "En attente de l'acheteur";
    }
  }

  String _statusLabel() {
    switch (status) {
      case NegotiationStatus.pending:
        return 'En attente';
      case NegotiationStatus.accepted:
        return 'Acceptée';
      case NegotiationStatus.rejected:
        return 'Refusée';
      case NegotiationStatus.counterOffered:
        return 'Contre-offre';
      case NegotiationStatus.cancelled:
        return 'Annulée';
      case NegotiationStatus.unknown:
        return '—';
    }
  }

  Color _statusColor() {
    switch (status) {
      case NegotiationStatus.accepted:
        return AppColors.primary;
      case NegotiationStatus.rejected:
      case NegotiationStatus.cancelled:
        return AppColors.error;
      case NegotiationStatus.counterOffered:
        return _kAmber;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final qte = _nf.format(quantiteKg.round());
    final prix = _nf.format(prixProposeKg.round());
    final total = _nf.format((quantiteKg * prixProposeKg).round());
    final color = _statusColor();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  kind == OffreKind.candidature
                      ? Icons.call_received_rounded
                      : Icons.call_made_rounded,
                  size: 22,
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
                      _headerLabel().toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$qte kg · $prix F/kg',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  _statusLabel(),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Ligne total estimé — pour rappeler en gros la valeur en jeu.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  'Total estimé',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$total F',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
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

// ─── Bulle de message ──────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final content = message.content ?? '';
    final date = message.createdAt;

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      decoration: BoxDecoration(
        color: isMine ? AppColors.primary : AppColors.surfaceSoft,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(14),
          bottomLeft: Radius.circular(isMine ? 14 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              color: isMine ? AppColors.onPrimary : AppColors.text,
              height: 1.4,
            ),
          ),
          if (date != null) ...[
            const SizedBox(height: 2),
            Text(
              DateFormat('HH:mm', 'fr_FR').format(date),
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                color: isMine
                    ? AppColors.onPrimary.withValues(alpha: 0.7)
                    : AppColors.textSubtle,
              ),
            ),
          ],
        ],
      ),
    );

    final avatar = Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_outline,
        size: 16,
        color: AppColors.primary,
      ),
    );

    return Row(
      mainAxisAlignment: isMine
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: isMine
          ? [bubble]
          : [avatar, const SizedBox(width: 6), Flexible(child: bubble)],
    );
  }
}

// ─── Barres d'action ───────────────────────────────────────────────

class _BarreActionsCandidature extends StatelessWidget {
  const _BarreActionsCandidature({
    required this.busy,
    required this.onAccepter,
    required this.onRefuser,
  });

  final bool busy;
  final VoidCallback onAccepter;
  final VoidCallback onRefuser;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            label: 'Refuser',
            color: AppColors.error,
            outlined: true,
            busy: false,
            onTap: busy ? null : onRefuser,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _ActionBtn(
            label: 'Accepter',
            color: AppColors.primary,
            outlined: false,
            busy: busy,
            onTap: busy ? null : onAccepter,
          ),
        ),
      ],
    );
  }
}

class _BoutonAnnulerProposition extends StatelessWidget {
  const _BoutonAnnulerProposition({
    required this.busy,
    required this.onAnnuler,
  });

  final bool busy;
  final VoidCallback onAnnuler;

  @override
  Widget build(BuildContext context) {
    return _ActionBtn(
      label: 'Annuler ma proposition',
      color: AppColors.error,
      outlined: true,
      busy: busy,
      onTap: busy ? null : onAnnuler,
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.outlined,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool outlined;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outlined ? Colors.transparent : color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: outlined
                ? Border.all(color: color.withValues(alpha: 0.6), width: 1.2)
                : null,
          ),
          alignment: Alignment.center,
          child: busy
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: outlined ? color : Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: outlined ? color : Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
