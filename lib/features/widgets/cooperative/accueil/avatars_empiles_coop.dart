import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '_constantes_accueil_coop.dart';

/// Avatars empilés (overlap léger), pour signaler "X personnes concernées".
/// Affiché par exemple dans l'en-tête "Actions à traiter" pour montrer les
/// farmers ayant fait une demande d'adhésion.
class AvatarsEmpilesCoop extends StatelessWidget {
  const AvatarsEmpilesCoop({super.key, required this.seeds});

  final List<String> seeds;

  @override
  Widget build(BuildContext context) {
    if (seeds.isEmpty) return const SizedBox.shrink();
    const double avatarSize = 22;
    const double overlap = 6;
    final largeur = avatarSize + (seeds.length - 1) * (avatarSize - overlap);
    return SizedBox(
      width: largeur,
      height: avatarSize,
      child: Stack(
        children: [
          for (var i = 0; i < seeds.length; i++)
            Positioned(
              left: i * (avatarSize - overlap),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: kPrimarySoftCoop,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initialesAccueilCoop(seeds[i]),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
