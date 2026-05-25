import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';
import '../../../../theme/app_text_styles.dart';

/// Ouvre le bottom sheet « Source du document » et retourne `camera` /
/// `gallery` ou `null` (annulation).
Future<ImageSource?> showSheetSourceDocKyc(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.surface,
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
                'Source du document',
                style: AppTextStyles.titleLarge,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ListTile(
            leading: const Icon(
              Icons.photo_camera_outlined,
              color: AppColors.primary,
            ),
            title: const Text('Prendre une photo'),
            onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
          ),
          const Divider(height: 1, color: AppColors.border),
          ListTile(
            leading: const Icon(
              Icons.photo_library_outlined,
              color: AppColors.primary,
            ),
            title: const Text('Choisir dans la galerie'),
            onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
          ),
          AppDimens.vGap8,
        ],
      ),
    ),
  );
}
