import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import 'need_line_creer_sollicitation_coop.dart';

/// Card « Besoin à combler » : encadré blanc affichant l'écart entre le
/// stock coop actuel et la quantité demandée. Deux lignes empilées —
/// stock OK (vert) puis manque à combler (orange souligné).
class NeedCardCreerSollicitationCoop extends StatelessWidget {
  const NeedCardCreerSollicitationCoop({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: const Column(
        children: [
          NeedLineCreerSollicitationCoop(
            label: 'Stock coop actuel',
            value: '2 000 kg',
            ok: true,
            isLast: false,
          ),
          NeedLineCreerSollicitationCoop(
            label: 'Manque à compléter',
            value: '3 000 kg',
            ok: false,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
