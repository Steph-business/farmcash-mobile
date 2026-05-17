import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// Bouton central de la bottom nav (FAB-like, mais intégré dans la barre).
///
/// Cercle 56px vert primaire, icône `+` blanche, sans ombre prononcée.
class BoutonAjoutCentral extends StatelessWidget {
  const BoutonAjoutCentral({
    required this.onTap,
    this.icon = Icons.add,
    this.semanticsLabel = 'Action',
    super.key,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(
              icon,
              color: AppColors.onPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

/// Affiche un menu d'actions sobre depuis le bouton central.
///
/// Exemple :
/// ```dart
/// showMenuActions(context, actions: [
///   MenuAction(icon: Icons.campaign_outlined, label: 'Annonce de vente', onTap: () => ...),
///   MenuAction(icon: Icons.calendar_today_outlined, label: 'Prévision', onTap: () => ...),
/// ]);
/// ```
Future<void> showMenuActions(
  BuildContext context, {
  required List<MenuAction> actions,
  String? title,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: false,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space24,
            vertical: AppDimens.space16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Text(title, style: AppTextStyles.titleMedium),
                AppDimens.vGap16,
              ],
              for (final a in actions) ...[
                InkWell(
                  borderRadius: AppDimens.brInput,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    a.onTap();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space12,
                      vertical: AppDimens.space16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          a.icon,
                          color: AppColors.primary,
                          size: AppDimens.iconL,
                        ),
                        AppDimens.hGap16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(a.label, style: AppTextStyles.titleSmall),
                              if (a.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  a.subtitle!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSubtle,
                          size: AppDimens.iconL,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              AppDimens.vGap8,
            ],
          ),
        ),
      );
    },
  );
}

class MenuAction {
  const MenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
}
