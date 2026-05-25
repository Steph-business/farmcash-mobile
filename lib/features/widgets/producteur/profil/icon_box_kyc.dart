import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import 'kyc_doc_type_kyc.dart';

/// Vignette carree 44x44 px (fond vert pale, coin arrondi 10) affichant
/// une icone de fallback quand on n'a pas d'image (ou que l'URL ne
/// ressemble pas a une image).
class IconBoxKyc extends StatelessWidget {
  const IconBoxKyc({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: kPrimarySoftKyc,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: AppColors.primary),
    );
  }
}
