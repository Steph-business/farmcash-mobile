import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/ai_content.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/entete_page_standard.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';
import '../../../widgets/producteur/ai/bulle_message_assistant.dart';
import '../../../widgets/producteur/ai/empty_assistant.dart';
import '../../../widgets/producteur/ai/input_bar_assistant.dart';
import '../../../widgets/producteur/ai/suggestions_assistant.dart';
import '../../../widgets/producteur/ai/typing_bubble_assistant.dart';

/// Assistant agronomique conversationnel.
///
/// Pattern : chargement de l'historique au démarrage, envoi optimiste,
/// rollback du message user si l'envoi échoue.
class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  final List<AiChatMessage> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _isLoadingHistory = true;
  bool _historyError = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = false;
    });
    try {
      final history = await ref.read(aiServiceProvider).getAssistantHistory();
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(history);
        _isLoadingHistory = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingHistory = false;
        _historyError = true;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _envoyer(String contenu) async {
    final txt = contenu.trim();
    if (txt.isEmpty || _isSending) return;
    final optimistic = AiChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      role: 'user',
      content: txt,
      createdAt: DateTime.now(),
    );
    setState(() {
      _messages.add(optimistic);
      _ctrl.clear();
      _isSending = true;
    });
    _scrollToBottom();
    try {
      final response = await ref
          .read(aiServiceProvider)
          .sendAssistantMessage(content: txt);
      if (!mounted) return;
      setState(() {
        _messages.add(response);
        _isSending = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.remove(optimistic);
        _isSending = false;
      });
      Snackbars.showErreur(
        context,
        "L'envoi a échoué. Réessaie dans quelques instants.",
      );
    }
  }

  Future<void> _reset() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brCard),
        title: Text(
          'Effacer la conversation ?',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Cette action supprimera tous les messages échangés avec '
          "l'assistant.",
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Effacer',
              style: AppTextStyles.button.copyWith(
                fontSize: 14,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirme != true) return;
    if (!mounted) return;
    try {
      await ref.read(aiServiceProvider).resetAssistantSession();
      if (!mounted) return;
      setState(() => _messages.clear());
    } catch (_) {
      if (!mounted) return;
      Snackbars.showErreur(context, "Impossible d'effacer la conversation.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            EntetePageStandard(
              titre: 'Assistant FarmCash',
              actions: [
                IconButton(
                  onPressed: _messages.isEmpty ? null : _reset,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.textSecondary,
                  tooltip: 'Effacer',
                ),
              ],
            ),
            Expanded(child: _buildBody()),
            if (_messages.isEmpty && !_isLoadingHistory && !_historyError)
              SuggestionsAssistant(onTap: _envoyer),
            InputBarAssistant(
              controller: _ctrl,
              isSending: _isSending,
              onSubmit: _envoyer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingHistory) {
      return const Padding(
        padding: EdgeInsets.only(top: AppDimens.space32),
        child: Chargement(size: 22),
      );
    }
    if (_historyError) {
      return Padding(
        padding: const EdgeInsets.all(AppDimens.pagePaddingH),
        child: VueErreur(
          message: "Impossible de charger l'historique.",
          onRetry: _loadHistory,
        ),
      );
    }
    if (_messages.isEmpty) {
      return const EmptyAssistant();
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space16,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      itemCount: _messages.length + (_isSending ? 1 : 0),
      itemBuilder: (_, i) {
        if (_isSending && i == _messages.length) {
          return const TypingBubbleAssistant();
        }
        return BulleMessageAssistant(message: _messages[i]);
      },
    );
  }
}
