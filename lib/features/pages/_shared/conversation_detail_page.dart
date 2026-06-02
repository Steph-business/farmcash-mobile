import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api_client/api_exception.dart';
import '../../../models/conversation.dart';
import '../../../models/message.dart';
import '../../../services/providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../state/auth_state.dart';
import '../../state/badges_state.dart';
import '../../widgets/communs/snackbars.dart';
import '../../widgets/messages/conversation/bulle_message.dart';
import '../../widgets/messages/conversation/composeur_message.dart';
import '../../widgets/messages/conversation/entete_chat.dart';
import '../../widgets/messages/conversation/etat_erreur_chat.dart';
import '../../widgets/messages/conversation/etat_vide_chat.dart';
import '../../widgets/messages/conversation/separateur_date.dart';

/// Bundle conversation + messages d'une vue chat. Le wrapper évite de
/// gérer deux providers séparés sur la même page.
class _ChatBundle {
  const _ChatBundle({required this.conversation, required this.messages});
  final Conversation conversation;
  final List<Message> messages;
}

/// Charge la conversation (pour récupérer les participants + leur user
/// joint) + la première page de messages. Le tri est inversé côté UI
/// pour afficher les plus anciens en haut → plus récents en bas, comme
/// dans WhatsApp.
///
/// Stratégie de robustesse :
///  • `listMessages` est CRITIQUE → si KO, le provider erreur explicitement
///    (l'utilisateur a besoin de voir les messages)
///  • `listConversations` est OPTIONNEL → si KO, on retombe sur un objet
///    `Conversation(id: convId)` factice (le header affichera "Conversation"
///    + "En ligne" en fallback, mais on ne bloque pas l'affichage chat)
final _chatBundleProvider = FutureProvider.autoDispose
    .family<_ChatBundle, String>((ref, convId) async {
  final svc = ref.watch(messagingServiceProvider);

  // 1. Messages — CRITIQUE. Si KO, le provider entre en error et
  // l'utilisateur voit le message d'erreur réel (403/404/500).
  final messages = await svc
      .listMessages(conversationId: convId, limit: 50)
      .then((p) => p.data);

  // 2. Conversation — best-effort. Le backend n'a pas d'endpoint
  // GET /conversations/:id direct, on dérive donc depuis la liste.
  // En cas d'échec : on continue avec une Conversation factice.
  List<Conversation> allConvs;
  try {
    allConvs = await svc.listConversations(limit: 50).then((p) => p.data);
  } catch (_) {
    allConvs = const [];
  }
  final conv = allConvs.firstWhere(
    (c) => c.id == convId,
    orElse: () => Conversation(id: convId),
  );

  // Backend retourne du plus récent au plus ancien → on inverse pour
  // afficher chronologiquement dans la ListView (anciens en haut).
  final ordered = messages.reversed.toList(growable: false);

  // Marquage best-effort : si on a des messages non-lus, on appelle
  // markConversationRead côté serveur. Pas bloquant.
  // On invalide aussi `unreadMessagesCountProvider` pour que le badge
  // du bottom nav baisse instantanément sans attendre le refresh.
  unawaited(
    svc.markConversationRead(convId).then((_) {
      ref.invalidate(unreadMessagesCountProvider);
    }).catchError((Object _) {}),
  );
  return _ChatBundle(conversation: conv, messages: ordered);
});

/// Page détail d'une conversation 1-1 ou groupe.
///
/// MVP :
/// - Affiche la liste des messages chronologiquement (anciens en haut)
/// - Champ de saisie + bouton envoyer en bas (sticky)
/// - Polling 5s pour rafraîchir les messages (SSE pas encore câblé)
/// - Marque la conversation comme lue à l'ouverture
class ConversationDetailPage extends ConsumerStatefulWidget {
  const ConversationDetailPage({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<ConversationDetailPage> createState() =>
      _ConversationDetailPageState();
}

/// État local d'un message optimiste (affiché immédiatement avant le
/// retour serveur). On garde le texte + un id temporaire pour dédupliquer
/// avec la réponse serveur, et un drapeau d'échec pour permettre un retry
/// manuel.
class _PendingMessage {
  _PendingMessage({
    required this.tempId,
    required this.content,
    required this.sentAt,
  });
  final String tempId;
  final String content;
  final DateTime sentAt;
  // Mutable : flippé à `true` quand l'envoi serveur échoue. Permet à
  // l'UI d'afficher un état "Échec — tape pour réessayer" sans recréer
  // l'objet (le widget retient la même référence).
  bool failed = false;
}

class _ConversationDetailPageState
    extends ConsumerState<ConversationDetailPage> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isSending = false;
  Timer? _pollTimer;
  // Messages envoyés depuis cet écran mais pas encore confirmés par le
  // backend (entre l'appui sur "envoyer" et la réponse 201). Listés en
  // bas de la conversation avec un état pending/failed pour que l'UX
  // soit instantanée. Une fois le serveur OK + refresh, le message
  // apparaît dans la liste réelle et on retire l'optimiste.
  final List<_PendingMessage> _pending = [];

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(_onTextChange);
    // Polling toutes les 5s : tant qu'on n'a pas de SSE, c'est la voie
    // raisonnable. À remplacer par un stream SSE quand le client supporte
    // bien `package:eventsource_plus` (cf. `notificationsService.streamUrl`).
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        ref.invalidate(_chatBundleProvider(widget.conversationId));
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _textCtrl.removeListener(_onTextChange);
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onTextChange() {
    if (mounted) setState(() {});
  }

  bool get _canSend => !_isSending && _textCtrl.text.trim().isNotEmpty;

  Future<void> _envoyer() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _isSending) return;
    // OPTIMISTIC UI : on insère localement le message AVANT l'appel
    // serveur pour que l'utilisateur voie sa bulle immédiatement (UX
    // WhatsApp-like). Si le serveur échoue, on marque le message
    // `failed = true` et on l'affiche avec une icône warning + tap
    // pour retry (TODO).
    final tempId = 't-${DateTime.now().microsecondsSinceEpoch}';
    final pending = _PendingMessage(
      tempId: tempId,
      content: text,
      sentAt: DateTime.now(),
    );
    setState(() {
      _isSending = true;
      _pending.add(pending);
    });
    _textCtrl.clear();
    // Scroll immédiat pour faire apparaître la bulle pending en bas.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollEnBas());

    try {
      final svc = ref.read(messagingServiceProvider);
      await svc.sendMessage(
        conversationId: widget.conversationId,
        content: text,
      );
      // Serveur OK → on retire le pending (le message va apparaître
      // dans la liste réelle au prochain refresh).
      if (mounted) {
        setState(() {
          _pending.removeWhere((p) => p.tempId == tempId);
        });
      }
      // Refresh immédiat — sans attendre le polling de 5s.
      ref.invalidate(_chatBundleProvider(widget.conversationId));
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollEnBas());
    } on ApiException catch (e) {
      if (!mounted) return;
      // Garde le pending visible avec l'état failed pour UX.
      setState(() {
        final p = _pending.firstWhere((p) => p.tempId == tempId);
        p.failed = true;
      });
      Snackbars.showErreur(context, e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final p = _pending.firstWhere((p) => p.tempId == tempId);
        p.failed = true;
      });
      Snackbars.showErreur(context, 'Impossible d\'envoyer.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  /// Retry d'un message en échec : on supprime le pending et on remet
  /// son texte dans le composer pour que l'utilisateur puisse modifier
  /// ou re-envoyer immédiatement.
  void _retryMessage(_PendingMessage p) {
    setState(() {
      _pending.removeWhere((x) => x.tempId == p.tempId);
      _textCtrl.text = p.content;
    });
  }

  void _scrollEnBas() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  /// Calcule (name, sousTitre, isAi, photoUrl) pour l'en-tête à partir
  /// de l'état conversation. Si non chargée encore (loading/erreur), on
  /// affiche un header neutre "Conversation" pour éviter le flash de
  /// libellé incorrect.
  _HeaderData _headerDataFor(AsyncValue<_ChatBundle> async, String? meId) {
    final conv = async.valueOrNull?.conversation;
    final isAi = conv?.isAiSession ?? false;
    if (isAi) {
      return const _HeaderData(
        name: 'Assistant agronomique',
        sousTitre: 'Bot IA · répond instantanément',
        isAi: true,
        photoUrl: null,
      );
    }
    final other = conv == null ? null : _otherParticipant(conv, meId);
    final name = (other?.fullName?.trim().isNotEmpty ?? false)
        ? other!.fullName!.trim()
        : 'Conversation';
    return _HeaderData(
      name: name,
      sousTitre: 'En ligne',
      isAi: false,
      photoUrl: other?.photoUrl,
    );
  }

  /// Refresh manuel partagé entre l'état vide et l'état rempli — invalide
  /// le provider puis attend la nouvelle valeur pour que `RefreshIndicator`
  /// fasse disparaître son spinner au bon moment.
  Future<void> _refreshBundle() async {
    ref.invalidate(_chatBundleProvider(widget.conversationId));
    await ref.read(_chatBundleProvider(widget.conversationId).future);
  }

  Widget _buildMessagesList(_ChatBundle bundle, String? meId) {
    // Schedule scroll en bas après le premier rendu de la liste. Sans
    // cela, la ListView ouvre au début (en haut) qui n'est pas l'attendu
    // pour un chat.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
    // Items = messages réels confirmés + messages pending (optimistic
    // UI, affichés en bas, en dégradé pour signaler leur état non-
    // confirmé).
    final totalItems = bundle.messages.length + _pending.length;
    return ListView.builder(
      controller: _scrollCtrl,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.pagePaddingH,
        vertical: AppDimens.space12,
      ),
      itemCount: totalItems,
      itemBuilder: (_, i) {
        if (i < bundle.messages.length) {
          // Bulle réelle (depuis l'API)
          final msg = bundle.messages[i];
          final isMine = meId == msg.senderId;
          final prevMsg = i > 0 ? bundle.messages[i - 1] : null;
          final showDate = prevMsg == null ||
              !_sameDay(prevMsg.createdAt, msg.createdAt);
          return Column(
            children: [
              if (showDate) SeparateurDate(when: msg.createdAt),
              BulleMessage(message: msg, isMine: isMine),
            ],
          );
        }
        // Bulle pending : index décalé après les messages réels.
        // Toujours côté droit (c'est forcément un message que JE viens
        // d'envoyer).
        final p = _pending[i - bundle.messages.length];
        return BulleMessage.pending(
          pendingContent: p.content,
          pendingFailed: p.failed,
          onRetry: () => _retryMessage(p),
        );
      },
    );
  }

  Widget _buildBody(AsyncValue<_ChatBundle> async, String? meId) {
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, _) {
        // Message d'erreur réel pour debug. ApiException porte déjà un
        // message backend lisible. Pour les autres types (parsing,
        // network), on affiche `toString()` qui donne au moins la classe
        // d'exception + le message brut. Ça évite le générique
        // "Chargement échoué" qui cachait la vraie cause et empêchait le
        // debug runtime.
        final msg = e is ApiException
            ? e.message
            : 'Impossible de charger la conversation.\n${e.toString()}';
        return EtatErreurChat(
          message: msg,
          onRetry: () =>
              ref.invalidate(_chatBundleProvider(widget.conversationId)),
        );
      },
      data: (bundle) {
        final hasAnyContent =
            bundle.messages.isNotEmpty || _pending.isNotEmpty;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refreshBundle,
          child: hasAnyContent
              ? _buildMessagesList(bundle, meId)
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    EtatVideChat(),
                  ],
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserProvider);
    final async = ref.watch(_chatBundleProvider(widget.conversationId));
    final header = _headerDataFor(async, me?.id);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteChat(
              name: header.name,
              sousTitre: header.sousTitre,
              isAi: header.isAi,
              photoUrl: header.photoUrl,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(child: _buildBody(async, me?.id)),
            ComposeurMessage(
              controller: _textCtrl,
              enabled: !_isSending,
              canSend: _canSend,
              isSending: _isSending,
              onSend: _envoyer,
            ),
          ],
        ),
      ),
    );
  }

  static bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Données dérivées pour l'en-tête, calculées une fois par build à partir
/// de l'état conversation. Évite de dupliquer la logique entre les modes
/// IA et humain.
class _HeaderData {
  const _HeaderData({
    required this.name,
    required this.sousTitre,
    required this.isAi,
    required this.photoUrl,
  });
  final String name;
  final String sousTitre;
  final bool isAi;
  final String? photoUrl;
}

ConversationParticipant? _otherParticipant(
  Conversation conv,
  String? currentUserId,
) {
  if (conv.participants.isEmpty) return null;
  if (currentUserId == null) return conv.participants.first;
  return conv.participants.firstWhere(
    (p) => p.userId != currentUserId,
    orElse: () => conv.participants.first,
  );
}
