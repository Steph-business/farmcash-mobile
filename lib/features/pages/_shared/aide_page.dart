import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../state/auth_state.dart';
import '../../widgets/communs/aide/bouton_action_rapide.dart';
import '../../widgets/communs/aide/faq_par_role.dart';
import '../../widgets/communs/aide/tuile_faq.dart';
import '../../widgets/communs/profil_settings/entete_profil_settings.dart';
import '../../widgets/communs/snackbars.dart';

/// Centre d'aide partagé (tous rôles) — actions rapides + FAQ adaptée au
/// rôle de l'utilisateur courant + barre de recherche locale.
///
/// La FAQ est statique pour V1 (provient de `faqPourRole`) et la recherche
/// filtre côté client en case-insensitive sur question + réponse.
class AidePartageePage extends ConsumerStatefulWidget {
  /// Construit la page Aide.
  const AidePartageePage({super.key, required this.fallbackPath});

  /// Chemin de repli si la pile de navigation est vide (deep link).
  final String fallbackPath;

  @override
  ConsumerState<AidePartageePage> createState() => _AidePartageePageState();
}

class _AidePartageePageState extends ConsumerState<AidePartageePage> {
  final _rechercheCtrl = TextEditingController();
  String _terme = '';

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserProvider)?.role;
    final faq = faqPourRole(role);
    final termeBas = _terme.trim().toLowerCase();
    final faqFiltree = termeBas.isEmpty
        ? faq
        : faq
            .where((q) =>
                q.question.toLowerCase().contains(termeBas) ||
                q.reponse.toLowerCase().contains(termeBas))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EnteteProfilSettings(
              fallbackPath: widget.fallbackPath,
              titre: "Centre d'aide",
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePaddingH,
                  AppDimens.space8,
                  AppDimens.pagePaddingH,
                  AppDimens.space24,
                ),
                children: [
                  Text(
                    'Comment pouvons-nous t\'aider ?',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppDimens.vGap12,

                  // Barre de recherche
                  TextField(
                    controller: _rechercheCtrl,
                    onChanged: (v) => setState(() => _terme = v),
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Rechercher une question…',
                      hintStyle: AppTextStyles.hint,
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: AppColors.textSubtle,
                      ),
                      suffixIcon: _terme.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              color: AppColors.textSubtle,
                              onPressed: () {
                                _rechercheCtrl.clear();
                                setState(() => _terme = '');
                              },
                            ),
                      filled: true,
                      fillColor: AppColors.surfaceSoft,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.space12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppDimens.brInput,
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  AppDimens.vGap16,

                  // Actions rapides
                  Row(
                    children: [
                      Expanded(
                        child: BoutonActionRapideAide(
                          icone: Icons.chat_bubble_outline,
                          label: 'Chat',
                          onTap: () => Snackbars.showInfo(
                            context,
                            'Chat support — à venir',
                          ),
                        ),
                      ),
                      AppDimens.hGap12,
                      Expanded(
                        child: BoutonActionRapideAide(
                          icone: Icons.phone_outlined,
                          label: 'Appeler',
                          onTap: () => Snackbars.showInfo(
                            context,
                            'Appel support — à venir',
                          ),
                        ),
                      ),
                      AppDimens.hGap12,
                      Expanded(
                        child: BoutonActionRapideAide(
                          icone: Icons.message_outlined,
                          label: 'WhatsApp',
                          onTap: () => Snackbars.showInfo(
                            context,
                            'WhatsApp — à venir',
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppDimens.vGap24,

                  // FAQ
                  Text(
                    termeBas.isEmpty
                        ? 'Questions fréquentes'
                        : '${faqFiltree.length} résultat${faqFiltree.length > 1 ? "s" : ""}',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppDimens.vGap8,
                  if (faqFiltree.isEmpty)
                    _EmptyFaq(terme: _terme)
                  else
                    ...faqFiltree.map(
                      (q) => TuileFaq(
                        question: q.question,
                        reponse: q.reponse,
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

class _EmptyFaq extends StatelessWidget {
  const _EmptyFaq({required this.terme});

  final String terme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.space24,
        horizontal: AppDimens.space16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off,
            size: 32,
            color: AppColors.textSubtle,
          ),
          AppDimens.vGap8,
          Text(
            'Aucun résultat pour "$terme"',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          AppDimens.vGap4,
          Text(
            'Essaie un autre mot-clé ou contacte le support.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
