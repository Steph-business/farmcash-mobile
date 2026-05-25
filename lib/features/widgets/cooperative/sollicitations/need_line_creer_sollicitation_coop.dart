import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

const Color _kOrange = Color(0xFFE65100);

/// Ligne d'une [NeedCardCreerSollicitationCoop] : libellé à gauche +
/// valeur typographiée à droite. La couleur de la valeur dépend de [ok]
/// — vert primary si ok, orange souligné sinon (manque à combler).
class NeedLineCreerSollicitationCoop extends StatelessWidget {
  const NeedLineCreerSollicitationCoop({
    required this.label,
    required this.value,
    required this.ok,
    required this.isLast,
    super.key,
  });

  final String label;
  final String value;
  final bool ok;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ok ? AppColors.primary : _kOrange,
              decoration: ok ? null : TextDecoration.underline,
              decorationColor: _kOrange,
            ),
          ),
        ],
      ),
    );
  }
}
