import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

/// Footer légal commun aux 4 pages profil : "FarmCash · v1.0.0" sur la
/// première ligne, "Made in Côte d'Ivoire" sur la deuxième, le tout centré
/// en gris subtle.
class PiedLegalProfil extends StatelessWidget {
  /// Construit le footer.
  const PiedLegalProfil({
    super.key,
    this.version = 'FarmCash · v1.0.0',
    this.mention = "Made in Côte d'Ivoire",
  });

  /// Texte de la première ligne (version).
  final String version;

  /// Texte de la deuxième ligne (mention "Made in…").
  final String mention;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.labelSmall.copyWith(
      fontSize: 11,
      color: AppColors.textSubtle,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(version, textAlign: TextAlign.center, style: style),
          const SizedBox(height: 4),
          Text(mention, textAlign: TextAlign.center, style: style),
        ],
      ),
    );
  }
}
