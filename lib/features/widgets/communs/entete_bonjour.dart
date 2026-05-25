import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// En-tête personnalisé en haut de l'accueil acheteur :
/// « Bonjour, [Prénom] 👋 » + une question d'intention.
///
/// Crée une accroche chaleureuse — particulièrement importante pour
/// un user low-tech qui doit se sentir guidé dès l'ouverture de l'app.
class EnteteBonjour extends StatelessWidget {
  const EnteteBonjour({
    required this.prenom,
    this.question = 'Que souhaitez-vous faire aujourd\'hui ?',
    super.key,
  });

  /// Prénom à afficher après « Bonjour, ». Si vide, on tombe sur « toi ».
  final String prenom;

  /// Question d'intention affichée en sous-titre (override possible).
  final String question;

  @override
  Widget build(BuildContext context) {
    final affichage = prenom.trim().isNotEmpty ? prenom.trim() : 'toi';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                'Bonjour, $affichage',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium.copyWith(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text('👋', style: TextStyle(fontSize: 20)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          question,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
