import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';

/// Avatar fixe pour l'assistant IA : icône `smart_toy` vert sur fond vert
/// pâle, sans photo URL. Distingue visuellement les conversations IA des
/// conversations humaines dans le header chat ET la liste des conversations.
class AvatarBot extends StatelessWidget {
  const AvatarBot({super.key});

  static const double size = 38;
  static const Color _kPrimarySoft = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _kPrimarySoft,
        shape: BoxShape.circle,
        border:
            Border.all(color: AppColors.border, width: AppDimens.borderThin),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.smart_toy_outlined,
        size: size * 0.5,
        color: AppColors.primary,
      ),
    );
  }
}
