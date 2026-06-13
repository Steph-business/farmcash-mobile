import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../api_client/api_exception.dart';
import '../../../../models/enums.dart';
import '../../../../models/message.dart';
import '../../../../models/negociation.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../state/auth_state.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'fr_FR');

/// Page de discussion sur une proposition de vente.
///
/// Avant 2026-05-27 c'était une `showModalBottomSheet` — l'utilisateur a
/// préféré une vraie page avec flèche back (plus naturel quand la
/// conversation s'éternise sur plusieurs écrans de scroll).
///
/// Le contenu : header carte contexte (produit / qté / prix / statut)
/// rappelle en permanence ce qu'on négocie + liste WhatsApp-like des
/// messages + input bas pour répondre.
class DiscussionNegociationPage extends ConsumerStatefulWidget {
  const DiscussionNegociationPage({super.key, required this.proposition});

  /// Proposition source — sert à afficher le contexte (produit, qté,
  /// prix actuel) en haut de la page et à lister les messages liés.
  final Proposition proposition;

  @override
  ConsumerState<DiscussionNegociationPage> createState() =>
      _DiscussionNegociationPageState();
}

class _DiscussionNegociationPageState
    extends ConsumerState<DiscussionNegociationPage> {
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
        .listPropositionMessages(widget.proposition.id);
  }

  Future<void> _send() async {
    final content = _ctrl.text.trim();
    if (content.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(negotiationServiceProvider).sendPropositionMessage(
            propositionId: widget.proposition.id,
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
    final userId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: 'Discussion'),
            // Carte contexte (produit + qté + prix + statut négociation).
            _CarteContexteNego(proposition: widget.proposition),
            // Liste messages.
            Expanded(
              child: FutureBuilder<List<Message>>(
                future: _messagesFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Chargement(size: 20);
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding:
                          const EdgeInsets.all(AppDimens.pagePaddingH),
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
                          'Aucun message — démarre la discussion.',
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
            // Input bas — adapté au clavier via SafeArea + Padding bottom.
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 16,
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
                          // Force transparent : le theme global applique
                          // `filled:true + fillColor:background` ce qui
                          // ferait un rectangle blanc dépareillé ici.
                          filled: false,
                          fillColor: Colors.transparent,
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

/// Carte contexte de négociation — affichée en haut pour que les deux
/// parties voient en permanence ce qu'elles négocient (quantité, prix
/// actuel proposé, statut).
class _CarteContexteNego extends StatelessWidget {
  const _CarteContexteNego({required this.proposition});

  final Proposition proposition;

  String _statusLabel(NegotiationStatus s) {
    switch (s) {
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

  /// Titre du bandeau adapté au statut. Avant le bandeau disait
  /// toujours « En négociation » même quand la proposition était
  /// acceptée ou refusée → contradictoire (« acceptée + en
  /// négociation »). Maintenant c'est cohérent avec la pastille.
  String _headerLabel(NegotiationStatus s) {
    switch (s) {
      case NegotiationStatus.accepted:
        return 'Accord conclu';
      case NegotiationStatus.rejected:
        return 'Négociation refusée';
      case NegotiationStatus.cancelled:
        return 'Négociation annulée';
      case NegotiationStatus.counterOffered:
        return 'Contre-offre en cours';
      case NegotiationStatus.pending:
      case NegotiationStatus.unknown:
        return 'En négociation';
    }
  }

  Color _statusColor(NegotiationStatus s) {
    switch (s) {
      case NegotiationStatus.accepted:
        return AppColors.primary;
      case NegotiationStatus.rejected:
      case NegotiationStatus.cancelled:
        return AppColors.error;
      case NegotiationStatus.counterOffered:
        return const Color(0xFFB45309);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final qte = _nf.format(proposition.quantiteKg.round());
    final prix = _nf.format(proposition.prixProposeKg.round());
    final statut = _statusLabel(proposition.status);
    final headerLabel = _headerLabel(proposition.status);
    final statutColor = _statusColor(proposition.status);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.eco_outlined,
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
                  headerLabel.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statutColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$qte kg · $prix F/kg',
                  style: AppTextStyles.bodyMedium.copyWith(
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
              border: Border.all(
                color: statutColor.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              statut,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statutColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bulle de message style WhatsApp : verte (primary) à droite si c'est
/// moi, grise pastel à gauche si c'est l'autre partie + petit avatar
/// rond pour appuyer visuellement la provenance.
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
      mainAxisAlignment:
          isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: isMine
          ? [bubble]
          : [avatar, const SizedBox(width: 6), Flexible(child: bubble)],
    );
  }
}
