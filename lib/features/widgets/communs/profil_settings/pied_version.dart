import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Footer "FarmCash mobile · vX.Y.Z" affiché en bas de la page
/// "Profil & paramètres" (commun aux 4 rôles).
class PiedVersion extends StatelessWidget {
  /// Construit le footer avec son texte (versionné).
  const PiedVersion({
    super.key,
    this.texte = 'FarmCash mobile · v0.4.2',
  });

  /// Texte affiché centré dans le footer.
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        texte,
        textAlign: TextAlign.center,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          color: AppColors.textSubtle,
        ),
      ),
    );
  }
}
