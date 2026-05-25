import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimens.dart';

/// Header sans titre, affiché pendant le chargement du détail parcelle.
///
/// Évite un flash visuel "header → no header → header avec titre" en
/// gardant un bouton retour visible dès l'apparition de la page.
class ParcelleDetailHeaderLoading extends StatelessWidget {
  const ParcelleDetailHeaderLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePaddingH,
        AppDimens.space8,
        AppDimens.pagePaddingH,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
