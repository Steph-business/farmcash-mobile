import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Action secondaire = lien texte vert (PAS de bouton outlined coloré).
///
/// Pattern type :
///   `Pas encore de compte ? [Créer un compte]`
///
/// Utilise [LienTexte] pour la phrase complète avec préfixe gris.
class BoutonSecondaire extends StatelessWidget {
  const BoutonSecondaire({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: AppTextStyles.link),
    );
  }
}

/// Phrase mixte : texte gris secondaire + lien vert cliquable.
///
/// Exemple :
/// ```dart
/// LienTexte(
///   prefixe: 'Pas encore de compte ?',
///   lien: 'Créer un compte',
///   onPressed: () => ...,
/// )
/// ```
class LienTexte extends StatelessWidget {
  const LienTexte({
    required this.prefixe,
    required this.lien,
    required this.onPressed,
    super.key,
  });

  final String prefixe;
  final String lien;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prefixe,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        BoutonSecondaire(label: lien, onPressed: onPressed),
      ],
    );
  }
}
