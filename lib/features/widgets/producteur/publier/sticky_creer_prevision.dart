import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../communs/bouton_principal.dart';

/// Sticky bouton « Creer ma prevision » au pied du formulaire.
///
/// Bordure fine en haut, padding standard + SafeArea bottom. Pas de
/// secondaire (en creation, on ne refuse pas).
class StickyCreerPrevision extends StatelessWidget {
  const StickyCreerPrevision({
    required this.isSubmitting,
    required this.canSubmit,
    required this.onPressed,
    super.key,
  });

  final bool isSubmitting;
  final bool canSubmit;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space12,
        AppDimens.pagePaddingH,
        AppDimens.space16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimens.borderThin,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppDimens.space4),
        child: BoutonPrincipal(
          label: 'Créer ma prévision',
          isLoading: isSubmitting,
          enabled: canSubmit,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
