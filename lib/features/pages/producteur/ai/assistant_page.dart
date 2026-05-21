import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/ai_content.dart';
import '../../../../services/providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../widgets/communs/chargement.dart';
import '../../../widgets/communs/snackbars.dart';
import '../../../widgets/communs/vue_erreur.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);
const List<String> _kSuggestions = <String>[
  'Quand semer le maïs ?',
  'Comment lutter contre la pyrale ?',
  'Quel prix pour le manioc ?',
  'Combien arroser une parcelle de tomates ?',
];

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
      final history =
          await ref.read(aiServiceProvider).getAssistantHistory();
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: AppColors.text),
        title: Text(
          'Assistant FarmCash',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _messages.isEmpty ? null : _reset,
            icon: const Icon(Icons.delete_outline),
            color: AppColors.textSecondary,
            tooltip: 'Effacer',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: _buildBody()),
            if (_messages.isEmpty && !_isLoadingHistory && !_historyError)
              _Suggestions(onTap: _envoyer),
            _InputBar(
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
      return const _EmptyAssistant();
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
          return const _TypingBubble();
        }
        return _Bubble(message: _messages[i]);
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final bg = isUser ? AppColors.primary : AppColors.surfaceSoft;
    final fg = isUser ? AppColors.onPrimary : AppColors.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: _kPrimarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.auto_awesome_outlined,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12).copyWith(
                  bottomRight:
                      isUser ? const Radius.circular(2) : null,
                  bottomLeft:
                      !isUser ? const Radius.circular(2) : null,
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: AppColors.border,
                        width: AppDimens.borderThin,
                      ),
              ),
              child: Text(
                message.content,
                style: AppTextStyles.bodyMedium.copyWith(color: fg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: _kPrimarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.auto_awesome_outlined,
              size: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12).copyWith(
                bottomLeft: const Radius.circular(2),
              ),
              border: Border.all(
                color: AppColors.border,
                width: AppDimens.borderThin,
              ),
            ),
            child: const SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAssistant extends StatelessWidget {
  const _EmptyAssistant();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: _kPrimarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.auto_awesome_outlined,
                size: 26,
                color: AppColors.primary,
              ),
            ),
            AppDimens.vGap12,
            Text(
              'Pose ta question',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppDimens.vGap4,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "L'assistant FarmCash répond aux questions agricoles : "
                'semis, traitements, prix, conseils.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space8,
      ),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _kSuggestions.length,
          separatorBuilder: (_, _) => AppDimens.hGap8,
          itemBuilder: (_, i) {
            final s = _kSuggestions[i];
            return _SuggestionChip(label: s, onTap: () => onTap(s));
          },
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSending;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space12,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 110),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Écrire un message…',
                  hintStyle: AppTextStyles.hint,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppDimens.brInput,
                    borderSide: const BorderSide(
                      color: AppColors.borderStrong,
                      width: AppDimens.borderThin,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppDimens.brInput,
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: AppDimens.borderThin,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _SendButton(
            isSending: isSending,
            onTap: () => onSubmit(controller.text),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.isSending, required this.onTap});

  final bool isSending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: isSending ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : const Icon(
                    Icons.arrow_upward,
                    color: AppColors.onPrimary,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
