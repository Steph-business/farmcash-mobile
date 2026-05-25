import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'carte_groupe_prevision.dart';
import 'groupe_prevision_card_model.dart';

/// Liste scrollable des cartes de groupe de prevision. Affiche un titre de
/// section "Pretes a agreger (par produit)" puis enchaine les cartes avec
/// un espacement vertical.
class CorpsPrevisions extends StatelessWidget {
  const CorpsPrevisions({required this.groups, super.key});

  final List<GroupePrevisionCardModel> groups;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        0,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      children: [
        Text(
          'Prêtes à agréger (par produit)',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        AppDimens.vGap12,
        for (final g in groups) ...[
          CarteGroupePrevision(group: g),
          AppDimens.vGap12,
        ],
      ],
    );
  }
}
