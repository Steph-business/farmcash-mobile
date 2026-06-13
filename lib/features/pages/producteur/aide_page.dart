import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';
import '../../widgets/communs/entete_page_standard.dart';
import '../../widgets/communs/snackbars.dart';

const Color _kPrimarySoft = Color(0xFFE8F5E9);

/// Centre d’aide producteur — FAQ + boutons contact (chat/téléphone/WhatsApp).
class AidePage extends ConsumerWidget {
  const AidePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const EntetePageStandard(titre: "Centre d'aide"),
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
                    'Comment pouvons-nous t’aider ?',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppDimens.vGap16,
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.chat_bubble_outline,
                          label: 'Chat',
                          onTap: () => Snackbars.showInfo(
                            context,
                            'Chat support — à venir',
                          ),
                        ),
                      ),
                      AppDimens.hGap12,
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.phone_outlined,
                          label: 'Appeler',
                          onTap: () => Snackbars.showInfo(
                            context,
                            'Appel support — à venir',
                          ),
                        ),
                      ),
                      AppDimens.hGap12,
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.message_outlined,
                          label: 'WhatsApp',
                          onTap: () =>
                              Snackbars.showInfo(context, 'WhatsApp — à venir'),
                        ),
                      ),
                    ],
                  ),
                  AppDimens.vGap24,
                  Text(
                    'Questions fréquentes',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppDimens.vGap8,
                  const _FaqItem(
                    question: 'Comment publier ma première annonce ?',
                    answer:
                        'Appuie sur le bouton + au centre de la barre du bas, '
                        'choisis "Annonce de vente" puis sélectionne ta culture, '
                        'indique quantité, prix et photo. Tu peux relire avant '
                        'publication.',
                  ),
                  const _FaqItem(
                    question: 'Comment fonctionnent les paiements ?',
                    answer:
                        'Le paiement est sécurisé : l’acheteur dépose le montant '
                        'sur ton wallet bloqué. Une fois la livraison confirmée, les '
                        'fonds sont débloqués et retirables.',
                  ),
                  const _FaqItem(
                    question: 'Quels documents pour la KYC ?',
                    answer:
                        'Pièce d’identité (CNI recto/verso), justificatif '
                        'd’adresse et photos de ton exploitation. Tout est chiffré '
                        'et vérifié sous 48h.',
                  ),
                  const _FaqItem(
                    question: 'Comment rejoindre une coopérative ?',
                    answer:
                        'Demande au président de ta coop d’envoyer une '
                        'invitation, ou contacte le support pour qu’on te mette en '
                        'relation.',
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brCard,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.space16,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppDimens.brCard,
          border: Border.all(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kPrimarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            AppDimens.vGap8,
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _open ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: AppColors.textSubtle,
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.space16,
                0,
                AppDimens.space16,
                AppDimens.space16,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.answer,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
