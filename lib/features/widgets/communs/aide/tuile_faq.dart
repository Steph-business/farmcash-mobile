import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Question FAQ pliable. Click sur la question alterne entre ouvert /
/// fermé. La réponse apparaît en-dessous avec une animation discrète.
class TuileFaq extends StatefulWidget {
  /// Construit la ligne FAQ.
  const TuileFaq({
    super.key,
    required this.question,
    required this.reponse,
  });

  /// Question affichée (gras).
  final String question;

  /// Réponse affichée quand la tuile est ouverte.
  final String reponse;

  @override
  State<TuileFaq> createState() => _TuileFaqState();
}

class _TuileFaqState extends State<TuileFaq> {
  bool _ouvert = false;

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
            onTap: () => setState(() => _ouvert = !_ouvert),
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
                    _ouvert ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: AppColors.textSubtle,
                  ),
                ],
              ),
            ),
          ),
          if (_ouvert)
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
                  widget.reponse,
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
