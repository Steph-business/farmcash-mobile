import 'package:flutter/material.dart';

import '../../../../models/kyc_document.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';
import 'kyc_doc_type_kyc.dart';
import 'status_chip_kyc.dart';
import 'thumb_kyc.dart';

/// Ligne KYC : vignette + libelle + chip d'etat (+ motif si rejete) +
/// bouton supprimer (uniquement pour les documents PENDING).
class DocRowKyc extends StatelessWidget {
  const DocRowKyc({
    required this.doc,
    required this.onDelete,
    super.key,
  });

  final KycDocument doc;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final type = KycDocTypeKyc.fromApi(doc.docType);
    final label = type?.label ?? doc.docType;
    final icon = type?.icon ?? Icons.description_outlined;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimens.brCard,
        border: Border.all(
          color: AppColors.border,
          width: AppDimens.borderThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ThumbKyc(url: doc.url, icon: icon),
          AppDimens.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                StatusChipKyc(status: doc.status),
                if (doc.status == 'REJECTED' &&
                    doc.rejectionReason != null &&
                    doc.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Motif : ${doc.rejectionReason}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null) ...[
            AppDimens.hGap8,
            IconButton(
              tooltip: 'Supprimer',
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
