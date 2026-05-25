import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'kyc_doc_type_kyc.dart';

/// Ouvre le bottom sheet « Type de justificatif » et retourne le type
/// choisi (ou `null` si l'utilisateur annule).
///
/// Affiche un ListTile par valeur de `KycDocTypeKyc`, separes par des
/// dividers fins.
Future<KycDocTypeKyc?> showSheetTypeDocKyc(BuildContext context) {
  return showModalBottomSheet<KycDocTypeKyc>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: AppDimens.brBottomSheet),
    builder: (ctx) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDimens.vGap8,
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space24,
              vertical: AppDimens.space8,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Type de justificatif',
                style: AppTextStyles.titleLarge,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          for (final t in KycDocTypeKyc.values) ...[
            ListTile(
              leading: Icon(t.icon, color: AppColors.primary),
              title: Text(t.label),
              onTap: () => Navigator.of(ctx).pop(t),
            ),
            if (t != KycDocTypeKyc.values.last)
              const Divider(height: 1, color: AppColors.border),
          ],
          AppDimens.vGap8,
        ],
      ),
    ),
  );
}
