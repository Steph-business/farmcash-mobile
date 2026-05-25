import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Sticky bottom de la page détail prévision : stepper quantité +/- à
/// gauche et grand bouton "Réserver (acompte 10%)" à droite.
class StickyBottomPrevision extends StatelessWidget {
  const StickyBottomPrevision({
    required this.qte,
    required this.onMinus,
    required this.onPlus,
    required this.onReserver,
    super.key,
  });

  final int qte;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onReserver;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top:
              BorderSide(color: AppColors.border, width: AppDimens.borderThin),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimens.borderThin,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  InkWell(
                    onTap: onMinus,
                    child: Container(
                      width: 36,
                      height: 44,
                      color: AppColors.surfaceSoft,
                      alignment: Alignment.center,
                      child: const Text(
                        '−',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 44,
                    alignment: Alignment.center,
                    child: Text(
                      '$qte',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onPlus,
                    child: Container(
                      width: 36,
                      height: 44,
                      color: AppColors.surfaceSoft,
                      alignment: Alignment.center,
                      child: const Text(
                        '+',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: onReserver,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Réserver (acompte 10%)',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
