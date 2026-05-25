import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/enums.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/app_text_styles.dart';

/// En-tête de la page Notifications partagée.
///
/// Affiche un bouton retour adapté au rôle (`top-level` pour coop /
/// transporteur, `maybePop` pour acheteur, `pop` standard pour
/// producteur), le titre "Notifications" et le lien "Tout lire" qui
/// déclenche [onToutMarquerLu].
///
/// Le rendu de la bordure et du padding diverge légèrement pour
/// l'acheteur, conformément aux mockups d'origine.
class EnteteNotifications extends StatelessWidget {
  const EnteteNotifications({
    required this.role,
    required this.onToutMarquerLu,
    super.key,
  });

  final UserRole? role;
  final VoidCallback onToutMarquerLu;

  @override
  Widget build(BuildContext context) {
    final isAcheteur = role == UserRole.buyer;
    final isCoop = role == UserRole.cooperative;
    return Container(
      decoration: isAcheteur
          ? const BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
            )
          : null,
      padding: isAcheteur
          ? const EdgeInsets.fromLTRB(8, 8, 16, 12)
          : const EdgeInsets.fromLTRB(
              AppDimens.pagePaddingH,
              AppDimens.space8,
              AppDimens.pagePaddingH,
              AppDimens.space12,
            ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (isCoop) {
                context.canPop()
                    ? context.pop()
                    : context.go(RouteNames.accueilCooperativePath);
              } else if (role == UserRole.transporter) {
                context.canPop()
                    ? context.pop()
                    : context.go(RouteNames.accueilTransporteurPath);
              } else if (isAcheteur) {
                Navigator.of(context).maybePop();
              } else {
                Navigator.of(context).pop();
              }
            },
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
              'Notifications',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: onToutMarquerLu,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
              child: Text(
                'Tout lire',
                style: AppTextStyles.link.copyWith(
                  fontSize: isAcheteur ? 12 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
