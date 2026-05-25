import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'offre_modeles.dart';

/// Rangée horizontale de chips de filtres pour les offres reçues.
class FiltresOffres extends StatelessWidget {
  const FiltresOffres({
    super.key,
    required this.selection,
    required this.onChanged,
  });

  final StatusFilter selection;
  final ValueChanged<StatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _chip('Toutes', StatusFilter.toutes),
          const SizedBox(width: 8),
          _chip('En attente', StatusFilter.pending),
          const SizedBox(width: 8),
          _chip('Acceptées', StatusFilter.accepted),
          const SizedBox(width: 8),
          _chip('Refusées', StatusFilter.refused),
        ],
      ),
    );
  }

  Widget _chip(String label, StatusFilter value) {
    final active = value == selection;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.borderStrong,
            width: AppDimens.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.onPrimary : AppColors.text,
          ),
        ),
      ),
    );
  }
}
